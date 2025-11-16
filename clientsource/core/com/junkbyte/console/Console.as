package com.junkbyte.console
{
   import com.junkbyte.console.core.CommandLine;
   import com.junkbyte.console.core.ConsoleTools;
   import com.junkbyte.console.core.Graphing;
   import com.junkbyte.console.core.KeyBinder;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.core.MemoryMonitor;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.view.RollerPanel;
   import com.junkbyte.console.vos.Log;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.system.Capabilities;
   import flash.utils.getTimer;
   
   public class Console extends Sprite
   {
      
      public static const VERSION:Number = 2.6;
      
      public static const VERSION_STAGE:String = "";
      
      public static const BUILD:int = 611;
      
      public static const BUILD_DATE:String = "2012/02/22 00:11";
      
      public static const LOG:uint = 1;
      
      public static const INFO:uint = 3;
      
      public static const DEBUG:uint = 6;
      
      public static const WARN:uint = 8;
      
      public static const ERROR:uint = 9;
      
      public static const FATAL:uint = 10;
      
      public static const GLOBAL_CHANNEL:String = " * ";
      
      public static const DEFAULT_CHANNEL:String = "-";
      
      public static const CONSOLE_CHANNEL:String = "C";
      
      public static const FILTER_CHANNEL:String = "~";
      
      private var _config:ConsoleConfig;
      
      private var _panels:PanelsManager;
      
      private var _cl:CommandLine;
      
      private var _kb:KeyBinder;
      
      private var _refs:LogReferences;
      
      private var _mm:MemoryMonitor;
      
      private var _graphing:Graphing;
      
      private var _remoter:Remoting;
      
      private var _tools:ConsoleTools;
      
      private var _topTries:int = 50;
      
      private var _paused:Boolean;
      
      private var _rollerKey:KeyBind;
      
      private var _logs:Logs;
      
      private var _so:SharedObject;
      
      private var _soData:Object;
      
      public function Console(param1:String = "", param2:ConsoleConfig = null)
      {
         var password:String = param1;
         var config:ConsoleConfig = param2;
         this._soData = {};
         super();
         name = "Console";
         if(config == null)
         {
            config = new ConsoleConfig();
         }
         this._config = config;
         if(password)
         {
            this._config.keystrokePassword = password;
         }
         this._remoter = new Remoting(this);
         this._logs = new Logs(this);
         this._refs = new LogReferences(this);
         this._cl = new CommandLine(this);
         this._tools = new ConsoleTools(this);
         this._graphing = new Graphing(this);
         this._mm = new MemoryMonitor(this);
         this._kb = new KeyBinder(this);
         this.cl.addCLCmd("remotingSocket",function(param1:String = ""):void
         {
            var _loc2_:Array = param1.split(/\s+|\:/);
            remotingSocket(_loc2_[0],_loc2_[1]);
         },"Connect to socket remote. /remotingSocket ip port");
         if(this._config.sharedObjectName)
         {
            try
            {
               this._so = SharedObject.getLocal(this._config.sharedObjectName,this._config.sharedObjectPath);
               this._soData = this._so.data;
            }
            catch(e:Error)
            {
            }
         }
         this._config.style.updateStyleSheet();
         this._panels = new PanelsManager(this);
         if(password)
         {
            this.visible = false;
         }
         this.report("<b>Console v" + VERSION + VERSION_STAGE + "</b> build " + BUILD + ". " + Capabilities.playerType + " " + Capabilities.version + ".",-2);
         addEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
      }
      
      public static function MakeChannelName(param1:*) : String
      {
         if(param1 is String)
         {
            return param1 as String;
         }
         if(param1)
         {
            return LogReferences.ShortClassName(param1);
         }
         return DEFAULT_CHANNEL;
      }
      
      private function stageAddedHandle(param1:Event = null) : void
      {
         if(this._cl.base == null)
         {
            this._cl.base = parent;
         }
         if(loaderInfo)
         {
            this.listenUncaughtErrors(loaderInfo);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
         addEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle);
         stage.addEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this._kb.keyDownHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this._kb.keyUpHandler,false,0,true);
      }
      
      private function stageRemovedHandle(param1:Event = null) : void
      {
         this._cl.base = null;
         removeEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
         stage.removeEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this._kb.keyDownHandler);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this._kb.keyUpHandler);
      }
      
      private function onStageMouseLeave(param1:Event) : void
      {
         this._panels.tooltip(null);
      }
      
      public function listenUncaughtErrors(param1:LoaderInfo) : void
      {
         var uncaughtErrorEvents:IEventDispatcher = null;
         var loaderinfo:LoaderInfo = param1;
         try
         {
            uncaughtErrorEvents = loaderinfo["uncaughtErrorEvents"];
            if(uncaughtErrorEvents)
            {
               uncaughtErrorEvents.addEventListener("uncaughtError",this.uncaughtErrorHandle,false,0,true);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function uncaughtErrorHandle(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc2_:* = param1.hasOwnProperty("error") ? param1["error"] : param1;
         if(_loc2_ is Error)
         {
            _loc3_ = this._refs.makeString(_loc2_);
         }
         else if(_loc2_ is ErrorEvent)
         {
            _loc3_ = ErrorEvent(_loc2_).text;
         }
         if(!_loc3_)
         {
            _loc3_ = String(_loc2_);
         }
         this.report(_loc3_,FATAL,false);
      }
      
      public function addGraph(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : void
      {
         this._graphing.add(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function fixGraphRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         this._graphing.fixRange(param1,param2,param3);
      }
      
      public function removeGraph(param1:String, param2:Object = null, param3:String = null) : void
      {
         this._graphing.remove(param1,param2,param3);
      }
      
      public function bindKey(param1:KeyBind, param2:Function, param3:Array = null) : void
      {
         if(param1)
         {
            this._kb.bindKey(param1,param2,param3);
         }
      }
      
      public function addMenu(param1:String, param2:Function, param3:Array = null, param4:String = null) : void
      {
         this.panels.mainPanel.addMenu(param1,param2,param3,param4);
      }
      
      public function get displayRoller() : Boolean
      {
         return this._panels.displayRoller;
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         this._panels.displayRoller = param1;
      }
      
      public function setRollerCaptureKey(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : void
      {
         if(this._rollerKey)
         {
            this.bindKey(this._rollerKey,null);
            this._rollerKey = null;
         }
         if(Boolean(param1) && param1.length == 1)
         {
            this._rollerKey = new KeyBind(param1,param2,param3,param4);
            this.bindKey(this._rollerKey,this.onRollerCaptureKey);
         }
      }
      
      public function get rollerCaptureKey() : KeyBind
      {
         return this._rollerKey;
      }
      
      private function onRollerCaptureKey() : void
      {
         if(this.displayRoller)
         {
            this.report("Display Roller Capture:<br/>" + RollerPanel(this._panels.getPanel(RollerPanel.NAME)).getMapString(true),-1);
         }
      }
      
      public function get fpsMonitor() : Boolean
      {
         return this._graphing.fpsMonitor;
      }
      
      public function set fpsMonitor(param1:Boolean) : void
      {
         this._graphing.fpsMonitor = param1;
      }
      
      public function get memoryMonitor() : Boolean
      {
         return this._graphing.memoryMonitor;
      }
      
      public function set memoryMonitor(param1:Boolean) : void
      {
         this._graphing.memoryMonitor = param1;
      }
      
      public function watch(param1:Object, param2:String = null) : String
      {
         return this._mm.watch(param1,param2);
      }
      
      public function unwatch(param1:String) : void
      {
         this._mm.unwatch(param1);
      }
      
      public function gc() : void
      {
         this._mm.gc();
      }
      
      public function store(param1:String, param2:Object, param3:Boolean = false) : void
      {
         this._cl.store(param1,param2,param3);
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         this._tools.map(param1,param2,DEFAULT_CHANNEL);
      }
      
      public function mapch(param1:*, param2:DisplayObjectContainer, param3:uint = 0) : void
      {
         this._tools.map(param2,param3,MakeChannelName(param1));
      }
      
      public function inspect(param1:Object, param2:Boolean = true) : void
      {
         this._refs.inspect(param1,param2,DEFAULT_CHANNEL);
      }
      
      public function inspectch(param1:*, param2:Object, param3:Boolean = true) : void
      {
         this._refs.inspect(param2,param3,MakeChannelName(param1));
      }
      
      public function explode(param1:Object, param2:int = 3) : void
      {
         this.addLine(new Array(this._tools.explode(param1,param2)),1,null,false,true);
      }
      
      public function explodech(param1:*, param2:Object, param3:int = 3) : void
      {
         this.addLine(new Array(this._tools.explode(param2,param3)),1,param1,false,true);
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(this._paused == param1)
         {
            return;
         }
         if(param1)
         {
            this.report("Paused",10);
         }
         else
         {
            this.report("Resumed",-1);
         }
         this._paused = param1;
         this._panels.mainPanel.setPaused(param1);
      }
      
      override public function get width() : Number
      {
         return this._panels.mainPanel.width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._panels.mainPanel.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         this._panels.mainPanel.height = param1;
      }
      
      override public function get height() : Number
      {
         return this._panels.mainPanel.height;
      }
      
      override public function get x() : Number
      {
         return this._panels.mainPanel.x;
      }
      
      override public function set x(param1:Number) : void
      {
         this._panels.mainPanel.x = param1;
      }
      
      override public function set y(param1:Number) : void
      {
         this._panels.mainPanel.y = param1;
      }
      
      override public function get y() : Number
      {
         return this._panels.mainPanel.y;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            this._panels.mainPanel.visible = true;
         }
      }
      
      private function _onEnterFrame(param1:Event) : void
      {
         var _loc4_:Array = null;
         var _loc2_:int = getTimer();
         var _loc3_:Boolean = this._logs.update(_loc2_);
         this._refs.update(_loc2_);
         this._mm.update();
         if(this.remoter.remoting != Remoting.RECIEVER)
         {
            _loc4_ = this._graphing.update(stage ? stage.frameRate : 0);
         }
         this._remoter.update();
         if(visible && Boolean(parent))
         {
            if(this.config.alwaysOnTop && parent.getChildAt(parent.numChildren - 1) != this && this._topTries > 0)
            {
               --this._topTries;
               parent.addChild(this);
               this.report("Moved console on top (alwaysOnTop enabled), " + this._topTries + " attempts left.",-1);
            }
            this._panels.update(this._paused,_loc3_);
            if(_loc4_)
            {
               this._panels.updateGraphs(_loc4_);
            }
         }
      }
      
      public function get remoting() : Boolean
      {
         return this._remoter.remoting == Remoting.SENDER;
      }
      
      public function set remoting(param1:Boolean) : void
      {
         this._remoter.remoting = param1 ? Remoting.SENDER : Remoting.NONE;
      }
      
      public function remotingSocket(param1:String, param2:int) : void
      {
         this._remoter.remotingSocket(param1,param2);
      }
      
      public function setViewingChannels(... rest) : void
      {
         this._panels.mainPanel.setViewingChannels.apply(this,rest);
      }
      
      public function setIgnoredChannels(... rest) : void
      {
         this._panels.mainPanel.setIgnoredChannels.apply(this,rest);
      }
      
      public function set minimumPriority(param1:uint) : void
      {
         this._panels.mainPanel.priority = param1;
      }
      
      public function report(param1:*, param2:int = 0, param3:Boolean = true, param4:String = null) : void
      {
         if(!param4)
         {
            param4 = this._panels.mainPanel.reportChannel;
         }
         this.addLine([param1],param2,param4,false,param3,0);
      }
      
      public function addLine(param1:Array, param2:int = 0, param3:* = null, param4:Boolean = false, param5:Boolean = false, param6:int = -1) : void
      {
         var _loc7_:String = "";
         var _loc8_:int = int(param1.length);
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc7_ += (_loc9_ ? " " : "") + this._refs.makeString(param1[_loc9_],null,param5);
            _loc9_++;
         }
         if(param2 >= this._config.autoStackPriority && param6 < 0)
         {
            param6 = this._config.defaultStackDepth;
         }
         if(!param5 && param6 > 0)
         {
            _loc7_ += this._tools.getStack(param6,param2);
         }
         this._logs.add(new Log(_loc7_,MakeChannelName(param3),param2,param4,param5));
      }
      
      public function set commandLine(param1:Boolean) : void
      {
         this._panels.mainPanel.commandLine = param1;
      }
      
      public function get commandLine() : Boolean
      {
         return this._panels.mainPanel.commandLine;
      }
      
      public function addSlashCommand(param1:String, param2:Function, param3:String = "", param4:Boolean = true, param5:String = ";") : void
      {
         this._cl.addSlashCommand(param1,param2,param3,param4,param5);
      }
      
      public function add(param1:*, param2:int = 2, param3:Boolean = false) : void
      {
         this.addLine([param1],param2,DEFAULT_CHANNEL,param3);
      }
      
      public function stack(param1:*, param2:int = -1, param3:int = 5) : void
      {
         this.addLine([param1],param3,DEFAULT_CHANNEL,false,false,param2 >= 0 ? param2 : this._config.defaultStackDepth);
      }
      
      public function stackch(param1:*, param2:*, param3:int = -1, param4:int = 5) : void
      {
         this.addLine([param2],param4,param1,false,false,param3 >= 0 ? param3 : this._config.defaultStackDepth);
      }
      
      public function log(... rest) : void
      {
         this.addLine(rest,LOG);
      }
      
      public function info(... rest) : void
      {
         this.addLine(rest,INFO);
      }
      
      public function debug(... rest) : void
      {
         this.addLine(rest,DEBUG);
      }
      
      public function warn(... rest) : void
      {
         this.addLine(rest,WARN);
      }
      
      public function error(... rest) : void
      {
         this.addLine(rest,ERROR);
      }
      
      public function fatal(... rest) : void
      {
         this.addLine(rest,FATAL);
      }
      
      public function ch(param1:*, param2:*, param3:int = 2, param4:Boolean = false) : void
      {
         this.addLine([param2],param3,param1,param4);
      }
      
      public function logch(param1:*, ... rest) : void
      {
         this.addLine(rest,LOG,param1);
      }
      
      public function infoch(param1:*, ... rest) : void
      {
         this.addLine(rest,INFO,param1);
      }
      
      public function debugch(param1:*, ... rest) : void
      {
         this.addLine(rest,DEBUG,param1);
      }
      
      public function warnch(param1:*, ... rest) : void
      {
         this.addLine(rest,WARN,param1);
      }
      
      public function errorch(param1:*, ... rest) : void
      {
         this.addLine(rest,ERROR,param1);
      }
      
      public function fatalch(param1:*, ... rest) : void
      {
         this.addLine(rest,FATAL,param1);
      }
      
      public function addCh(param1:*, param2:Array, param3:int = 2, param4:Boolean = false) : void
      {
         this.addLine(param2,param3,param1,param4);
      }
      
      public function addHTML(... rest) : void
      {
         this.addLine(rest,2,DEFAULT_CHANNEL,false,this.testHTML(rest));
      }
      
      public function addHTMLch(param1:*, param2:int, ... rest) : void
      {
         this.addLine(rest,param2,param1,false,this.testHTML(rest));
      }
      
      private function testHTML(param1:Array) : Boolean
      {
         var args:Array = param1;
         try
         {
            new XML("<p>" + args.join("") + "</p>");
         }
         catch(err:Error)
         {
            return false;
         }
         return true;
      }
      
      public function clear(param1:String = null) : void
      {
         this._logs.clear(param1);
         if(!this._paused)
         {
            this._panels.mainPanel.updateToBottom();
         }
         this._panels.updateMenu();
      }
      
      public function getAllLog(param1:String = "\r\n") : String
      {
         return this._logs.getLogsAsString(param1);
      }
      
      public function get config() : ConsoleConfig
      {
         return this._config;
      }
      
      public function get panels() : PanelsManager
      {
         return this._panels;
      }
      
      public function get cl() : CommandLine
      {
         return this._cl;
      }
      
      public function get remoter() : Remoting
      {
         return this._remoter;
      }
      
      public function get graphing() : Graphing
      {
         return this._graphing;
      }
      
      public function get refs() : LogReferences
      {
         return this._refs;
      }
      
      public function get logs() : Logs
      {
         return this._logs;
      }
      
      public function get mapper() : ConsoleTools
      {
         return this._tools;
      }
      
      public function get so() : Object
      {
         return this._soData;
      }
      
      public function updateSO(param1:String = null) : void
      {
         if(this._so)
         {
            if(param1)
            {
               this._so.setDirty(param1);
            }
            else
            {
               this._so.clear();
            }
         }
      }
   }
}

