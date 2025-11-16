package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.alliance.AllianceTask;
   import thelaststand.app.game.gui.alliance.UIAllianceTaskItem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Tasks_Overview extends UIComponent
   {
      
      private var _width:int = 720;
      
      private var _height:int = 126;
      
      private var _padding:int = 3;
      
      private var _panelArea:Rectangle;
      
      private var _panelWidth:int;
      
      private var _panelHeight:int;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _resetTimer:Timer;
      
      private var _items:Vector.<UIAllianceTaskItem>;
      
      private var _newRoundWaiting:Boolean = false;
      
      private var _icons:Vector.<TaskIcon>;
      
      private var iconContainer:Sprite;
      
      private var btn_help:HelpButton;
      
      private var ui_titleBar:UITitleBar;
      
      private var ui_subtitleBar:UITitleBar;
      
      private var ui_iconBG:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var mc_blocker:Sprite;
      
      public function AlliancePage_Tasks_Overview()
      {
         super();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.add(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.add(this.onAllianceRoundEnded);
         this._items = new Vector.<UIAllianceTaskItem>();
         this._icons = new Vector.<TaskIcon>();
         this.ui_titleBar = new UITitleBar(null,6194996);
         this.ui_titleBar.width = int(244);
         this.ui_titleBar.height = 35;
         this.ui_titleBar.x = this.ui_titleBar.y = this._padding;
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":12379027,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.text = Language.getInstance().getString("alliance.overview_tasks_title").toUpperCase();
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         this.txt_title.x = int((this.ui_titleBar.width - this.txt_title.width) * 0.5);
         addChild(this.txt_title);
         this.ui_subtitleBar = new UITitleBar(null,4017710);
         this.ui_subtitleBar.width = this.ui_titleBar.width;
         this.ui_subtitleBar.height = 25;
         this.ui_subtitleBar.x = this._padding;
         this.ui_subtitleBar.y = this._height - this._padding - this.ui_subtitleBar.height;
         addChild(this.ui_subtitleBar);
         this.txt_time = new BodyTextField({
            "text":" ",
            "color":13818571,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_time.y = int(this.ui_subtitleBar.y + (this.ui_subtitleBar.height - this.txt_time.height) * 0.5);
         addChild(this.txt_time);
         this.ui_iconBG = new UITitleBar(null,2960685);
         this.ui_iconBG.width = this.ui_titleBar.width;
         this.ui_iconBG.height = this.ui_subtitleBar.y - (this.ui_titleBar.y + this.ui_titleBar.height);
         this.ui_iconBG.x = this.ui_titleBar.x;
         this.ui_iconBG.y = this.ui_titleBar.y + this.ui_titleBar.height;
         addChildAt(this.ui_iconBG,getChildIndex(this.ui_titleBar));
         this.iconContainer = new Sprite();
         addChild(this.iconContainer);
         this.btn_help = new HelpButton("alliance.task_help");
         this.btn_help.height = 18;
         this.btn_help.scaleX = this.btn_help.scaleY;
         this.btn_help.x = int(this.txt_title.x + this.txt_title.width + 6);
         this.btn_help.y = int(this.txt_title.y + (this.txt_title.height - this.btn_help.height) * 0.5);
         this._panelArea = new Rectangle(250,this._padding + 1,int(this._width - 250 - this._padding - 2),int(this._height - this._padding * 2));
         this._panelWidth = int((this._panelArea.width - this._padding) / 2);
         this._panelHeight = int((this._panelArea.height - this._padding * 2) / 2);
         this._resetTimer = new Timer(60000);
         this._resetTimer.addEventListener(TimerEvent.TIMER,this.onResetTimerTick,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         this.drawTasks();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIAllianceTaskItem = null;
         var _loc2_:TaskIcon = null;
         super.dispose();
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.remove(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.remove(this.onAllianceRoundEnded);
         this._allianceSystem = null;
         this._resetTimer.stop();
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         for each(_loc2_ in this._icons)
         {
            _loc2_.dispose();
         }
         this._icons = null;
         this.ui_titleBar.dispose();
         this.ui_subtitleBar.dispose();
         this.txt_time.dispose();
         this.txt_title.dispose();
         this.btn_help.dispose();
      }
      
      private function drawTasks() : void
      {
         var _loc1_:UIAllianceTaskItem = null;
         var _loc2_:TaskIcon = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:AllianceTask = null;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items.length = 0;
         for each(_loc2_ in this._icons)
         {
            _loc2_.dispose();
         }
         this._icons.length = 0;
         _loc4_ = this._panelArea.x;
         _loc5_ = this._panelArea.y;
         _loc6_ = AllianceSystem.getInstance().alliance.numTasks;
         this._items.length = _loc6_;
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = AllianceSystem.getInstance().alliance.getTask(_loc7_);
            _loc1_ = new UIAllianceTaskItem(_loc8_,this._panelWidth,this._panelHeight);
            _loc1_.x = _loc4_;
            _loc1_.y = _loc5_;
            if(!this._allianceSystem.canContributeToRound)
            {
               _loc1_.filters = [Effects.GREYSCALE.filter];
            }
            if(++_loc3_ >= 2)
            {
               _loc5_ += int(_loc1_.height + this._padding);
               _loc4_ = this._panelArea.x;
               _loc3_ = 0;
            }
            else
            {
               _loc4_ += int(_loc1_.width + this._padding);
            }
            addChild(_loc1_);
            this._items[_loc7_] = _loc1_;
            _loc2_ = new TaskIcon(_loc8_);
            if(_loc7_ > 0)
            {
               _loc2_.x = this.iconContainer.width + 12;
            }
            this.iconContainer.addChild(_loc2_);
            this._icons[_loc7_] = _loc2_;
            _loc7_++;
         }
         this.iconContainer.x = this.ui_iconBG.x + int((this.ui_iconBG.width - this.iconContainer.width) * 0.5);
         this.iconContainer.y = this.ui_iconBG.y + int((this.ui_iconBG.height - this.iconContainer.height) * 0.5);
      }
      
      private function updateResetTime() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!this._allianceSystem.canContributeToRound)
         {
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_availnextround");
         }
         else if(this._newRoundWaiting)
         {
            _loc1_ = int((this._allianceSystem.round.activeTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_tasks_available",DateTimeUtils.secondsToString(_loc1_,true,false,true).replace("<","&lt;"));
         }
         else
         {
            _loc2_ = int((this._allianceSystem.round.endTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc2_ <= 0)
            {
               _loc2_ = 0;
            }
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_tasks_reset",DateTimeUtils.secondsToString(_loc2_,true,false,true).replace("<","&lt;"));
         }
         this.txt_time.x = int(this.ui_subtitleBar.x + (this.ui_subtitleBar.width - this.txt_time.width) * 0.5);
      }
      
      private function lock() : void
      {
         var _loc1_:TaskIcon = null;
         var _loc2_:UIAllianceTaskItem = null;
         if(this.mc_blocker == null)
         {
            this.mc_blocker = new Sprite();
            this.mc_blocker.buttonMode = true;
            this.mc_blocker.useHandCursor = false;
         }
         --this._panelArea.x;
         --this._panelArea.y;
         this.mc_blocker.graphics.clear();
         this.mc_blocker.graphics.beginFill(0,0.8);
         this.mc_blocker.graphics.drawRect(0,0,this._panelArea.width + 2,this._panelArea.height + 2);
         this.mc_blocker.graphics.endFill();
         addChild(this.mc_blocker);
         for each(_loc1_ in this._icons)
         {
            _loc1_.mouseEnabled = false;
            _loc1_.alpha = 0.3;
         }
         for each(_loc2_ in this._items)
         {
            _loc2_.showRequirements = false;
         }
      }
      
      private function unlock() : void
      {
         var _loc1_:TaskIcon = null;
         var _loc2_:UIAllianceTaskItem = null;
         if(this.mc_blocker == null)
         {
            return;
         }
         mouseChildren = true;
         if(this.mc_blocker.parent != null)
         {
            this.mc_blocker.parent.removeChild(this.mc_blocker);
         }
         for each(_loc1_ in this._icons)
         {
            _loc1_.mouseEnabled = true;
            _loc1_.alpha = 1;
         }
         for each(_loc2_ in this._items)
         {
            _loc2_.showRequirements = true;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._resetTimer.start();
         this._newRoundWaiting = Network.getInstance().serverTime < this._allianceSystem.round.activeTime.time;
         this.updateResetTime();
         if(this._newRoundWaiting)
         {
            this.lock();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._resetTimer.stop();
      }
      
      private function onResetTimerTick(param1:TimerEvent) : void
      {
         this.updateResetTime();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this._resetTimer.stop();
         this.lock();
      }
      
      private function onAllianceRoundStarted() : void
      {
         this._newRoundWaiting = false;
         this.drawTasks();
         this.updateResetTime();
         this.unlock();
      }
      
      private function onAllianceRoundEnded() : void
      {
         this._newRoundWaiting = true;
         this.updateResetTime();
         this.lock();
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import com.greensock.TweenMax;
import flash.filters.GlowFilter;
import flash.geom.Point;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.alliance.AllianceTask;
import thelaststand.app.gui.TooltipDirection;
import thelaststand.app.gui.TooltipManager;
import thelaststand.app.gui.UIImage;
import thelaststand.common.lang.Language;

class TaskIcon extends UIImage
{
   
   private var _task:AllianceTask;
   
   public function TaskIcon(param1:AllianceTask)
   {
      this._task = param1;
      super(46,46,0);
      uri = param1.imageURI;
      this._task.progressChanged.add(this.onTaskProgressChanged);
      this.updateBorder();
      TooltipManager.getInstance().add(this,this.getTooltip,new Point(NaN,6),TooltipDirection.DIRECTION_DOWN,0);
   }
   
   override public function dispose() : void
   {
      super.dispose();
      TweenMax.killTweensOf(this);
      TweenMax.killChildTweensOf(this);
      TooltipManager.getInstance().removeAllFromParent(this);
      this._task.progressChanged.remove(this.onTaskProgressChanged);
      this._task = null;
   }
   
   private function updateBorder() : void
   {
      var _loc1_:uint = 4934475;
      if(this._task.isComplete)
      {
         _loc1_ = 4609338;
      }
      filters = [new GlowFilter(_loc1_,1,1.5,1.5,10,1),Effects.ICON_SHADOW];
   }
   
   private function onTaskProgressChanged(param1:AllianceTask) : void
   {
      if(this._task.isComplete)
      {
         this.updateBorder();
         if(stage != null)
         {
            TweenMax.from(this,1,{"colorTransform":{"exposure":2}});
         }
      }
   }
   
   private function getTooltip() : String
   {
      var _loc1_:String = Language.getInstance().getString("alliance.taskprogress",NumberFormatter.format(this._task.value,0) + " / " + NumberFormatter.format(this._task.goal,0));
      return this._task.getDescription() + "<br/><br/>" + _loc1_;
   }
}
