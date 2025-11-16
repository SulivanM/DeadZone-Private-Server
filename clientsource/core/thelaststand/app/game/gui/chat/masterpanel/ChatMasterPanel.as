package thelaststand.app.game.gui.chat.masterpanel
{
   import com.exileetiquette.math.MathUtils;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import playerio.PlayerIOError;
   import playerio.RoomInfo;
   import thelaststand.app.game.gui.chat.UIChatPanel;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RoomType;
   import thelaststand.app.network.chat.ChatMessageData;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.utils.BadWordFilter;
   
   public class ChatMasterPanel extends Sprite
   {
      
      private static const ALERT_CHANNEL:String = "_alert_";
      
      private var _stage:Stage;
      
      private var _container:Sprite;
      
      private var _titleBar:TitleBar;
      
      private var _roomList:RoomList;
      
      private var _tileArea:Sprite;
      
      private var _tileContainer:Sprite;
      
      private var _tileMask:Shape;
      
      private var _tiles:Vector.<ChatTile> = new Vector.<ChatTile>();
      
      private var _tileThumb:Sprite;
      
      private var btn_close:Sprite;
      
      private var btn_fullscreen:Sprite;
      
      private var btn_clear:Sprite;
      
      private var _network:Network;
      
      private var _chatSystem:ChatSystem;
      
      private var _roomsByNickName:Dictionary = new Dictionary();
      
      private var _roomsByChannel:Dictionary = new Dictionary();
      
      private var _timer:Timer;
      
      private var _dragDelta:Number = 0;
      
      private var _alertPanel:Sprite;
      
      private var _alertChatPanel:UIChatPanel;
      
      private var _filter:BadWordFilter;
      
      private var _servicePrefix:String = "";
      
      public function ChatMasterPanel()
      {
         super();
         this._network = Network.getInstance();
         this._chatSystem = this._network.chatSystem;
         this._chatSystem.onChatStatusChange.add(this.onChatStatusChange);
         this._chatSystem.onChatMessageReceived.add(this.onChatMessageRecieved);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         switch(Network.getInstance().service)
         {
            case "fb":
            case "armor":
               this._servicePrefix = "";
               break;
            default:
               this._servicePrefix = Network.getInstance().service;
         }
         this._container = new Sprite();
         this._container.y = 40;
         addChild(this._container);
         this._titleBar = new TitleBar();
         this._container.addChild(this._titleBar);
         this.btn_close = new Sprite();
         this.btn_close.addChild(new Bitmap(new BmpIconChatClose()));
         this.btn_close.y = int((this._titleBar.height - this.btn_close.height) * 0.5);
         this.btn_close.mouseChildren = false;
         this.btn_close.buttonMode = true;
         this.btn_close.addEventListener(MouseEvent.CLICK,this.onClose,false,0,true);
         this._container.addChild(this.btn_close);
         this.btn_fullscreen = new Sprite();
         this.btn_fullscreen.addChild(new Bitmap(new BmpIconFullscreen()));
         this.btn_fullscreen.y = int((this._titleBar.height - this.btn_fullscreen.height) * 0.5);
         this.btn_fullscreen.mouseChildren = false;
         this.btn_fullscreen.buttonMode = true;
         this.btn_fullscreen.addEventListener(MouseEvent.CLICK,this.onFullScreen,false,0,true);
         this._container.addChild(this.btn_fullscreen);
         this._roomList = new RoomList();
         this._roomList.y = this._titleBar.height + 1;
         this._container.addChild(this._roomList);
         this._tileArea = new Sprite();
         this._tileArea.x = this._roomList.width + 1;
         this._tileArea.y = this._roomList.y;
         this._container.addChild(this._tileArea);
         this._tileContainer = new Sprite();
         this._tileArea.addChild(this._tileContainer);
         this._tileMask = new Shape();
         this._tileMask.graphics.beginFill(16711680,0.5);
         this._tileMask.graphics.drawRect(0,0,300,200);
         this._tileArea.addChild(this._tileMask);
         this._tileContainer.mask = this._tileMask;
         this._tileThumb = new Sprite();
         this._tileThumb.graphics.beginFill(8421504,1);
         this._tileThumb.graphics.drawRect(0,0,200,20);
         this._tileArea.addChild(this._tileThumb);
         this._tileThumb.addEventListener(MouseEvent.MOUSE_DOWN,this.onThumbDown,false,0,true);
         this._alertPanel = new Sprite();
         this._alertPanel.y = this._titleBar.height + 1;
         this._container.addChild(this._alertPanel);
         this._alertChatPanel = new UIChatPanel(ChatSystem.ADMIN_CHANNEL_ALERT);
         this._alertChatPanel.x = 1;
         this._alertChatPanel.width = 200;
         this._alertChatPanel.allowInput = false;
         this._alertPanel.addChild(this._alertChatPanel);
         this._chatSystem.onChatStatusChange.dispatch(ChatSystem.ADMIN_CHANNEL_ALERT,ChatSystem.STATUS_CONNECTED);
         this._alertChatPanel.clearMessages();
         var _loc1_:ChatMessageData = new ChatMessageData(ALERT_CHANNEL,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc1_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc1_.posterIsAdmin = true;
         _loc1_.message = "Alert system loading...";
         this._chatSystem.onChatMessageReceived.dispatch(_loc1_);
         this.btn_clear = new Sprite();
         this.btn_clear.addChild(new Bitmap(new BmpIconCameraRotate()));
         this.btn_clear.mouseChildren = false;
         this.btn_clear.buttonMode = true;
         this.btn_clear.addEventListener(MouseEvent.CLICK,this.onClearAlerts,false,0,true);
         this._container.addChild(this.btn_clear);
         var _loc2_:ChatTile = new ChatTile(ChatSystem.CHANNEL_PRIVATE);
         this._tileContainer.addChild(_loc2_);
         this._tiles.push(_loc2_);
         _loc2_ = new ChatTile(ChatSystem.CHANNEL_ALLIANCE);
         this._tileContainer.addChild(_loc2_);
         this._tiles.push(_loc2_);
         var _loc3_:Object = {};
         _loc3_ = {"type":ResourceManager.TYPE_GZIP};
         _loc3_.onComplete = this.onBadwordLoaded;
         ResourceManager.getInstance().load("xml/badwords.xml",_loc3_);
         addEventListener(ChatLinkEvent.LINK_CLICK,this.onShowChatTileLink,false,0,true);
         if(this._chatSystem.getStatus(ChatSystem.CHANNEL_PRIVATE) == ChatSystem.STATUS_DISCONNECTED)
         {
            this._chatSystem.connect(ChatSystem.CHANNEL_PRIVATE);
         }
         else
         {
            this.performInitialRefresh();
         }
      }
      
      private function onChatStatusChange(param1:String, param2:String) : void
      {
         if(param1 == ChatSystem.CHANNEL_PRIVATE && param2 == ChatSystem.STATUS_CONNECTED)
         {
            this.performInitialRefresh();
         }
      }
      
      private function performInitialRefresh() : void
      {
         this._timer = new Timer(30000,1);
         this._timer.addEventListener(TimerEvent.TIMER,this.refreshRoomList,false,0,true);
         this.refreshRoomList();
      }
      
      private function onChatMessageRecieved(param1:ChatMessageData) : void
      {
         var _loc2_:ChatMessageData = null;
         var _loc3_:Date = null;
         var _loc4_:String = null;
         var _loc5_:ChatTile = null;
         if(param1.channel == ChatSystem.ADMIN_CHANNEL_ALERT || this._roomsByChannel[param1.channel] == null)
         {
            return;
         }
         if(!this._filter)
         {
            return;
         }
         if(this._filter.filter(param1.message,BadWordFilter.FILTER_TEST))
         {
            _loc2_ = new ChatMessageData(ALERT_CHANNEL,param1.messageType);
            _loc2_.posterId = param1.posterId;
            _loc2_.posterNickName = param1.posterNickName;
            _loc2_.posterIsAdmin = param1.posterIsAdmin;
            _loc2_.toNickName = param1.toNickName;
            _loc3_ = new Date();
            _loc4_ = String(_loc3_.hours + ":" + NumberFormatter.addLeadingZero(_loc3_.minutes,2));
            _loc2_.message = "<font color=\'#FF8040\'><a href=\'event:showChatTile:" + param1.channel + "\'>" + _loc4_ + " | Room: " + param1.channel + "</a><br/>" + param1.message + "</font>";
            this._chatSystem.onChatMessageReceived.dispatch(_loc2_);
            for each(_loc5_ in this._tiles)
            {
               if(_loc5_.channel == param1.channel)
               {
                  _loc5_.pulse();
                  break;
               }
            }
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:ChatTile = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this._network = null;
         this._chatSystem = null;
         if(this._stage)
         {
            this._stage.removeEventListener(Event.RESIZE,this.onResize);
            this._stage = null;
         }
         this._roomsByNickName = null;
         this._roomList.dispose();
         for each(_loc1_ in this._tiles)
         {
            _loc1_.dispose();
         }
         this._tiles = null;
         this._alertChatPanel.dispose();
         this._alertChatPanel = null;
      }
      
      private function refreshRoomList(param1:TimerEvent = null) : void
      {
         var _loc3_:String = null;
         if(this._timer.running)
         {
            this._timer.stop();
         }
         var _loc2_:Array = ["_public_","_tradepublic_"];
         for each(_loc3_ in _loc2_)
         {
            this.refreshPart2(_loc3_);
         }
      }
      
      private function refreshPart2(param1:String) : void
      {
         var roomNickName:String = param1;
         this._network.client.multiplayer.listRooms(RoomType.CHAT,{"NickName":this._servicePrefix + roomNickName},100,0,function(param1:Array):void
         {
            onListRoomSuccess(roomNickName,param1);
         },this.onListRoomsFail);
      }
      
      private function onListRoomSuccess(param1:String, param2:Array) : void
      {
         var _loc5_:RoomInfo = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:RoomData = null;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:RoomData = null;
         var _loc12_:String = null;
         var _loc13_:ChatTile = null;
         if(this._roomsByNickName[param1] == null)
         {
            this._roomsByNickName[param1] = [];
         }
         var _loc3_:Array = this._roomsByNickName[param1];
         var _loc4_:Boolean = false;
         for each(_loc5_ in param2)
         {
            _loc8_ = new RoomData(_loc5_);
            _loc9_ = false;
            _loc10_ = 0;
            while(_loc10_ < _loc3_.length)
            {
               _loc11_ = _loc3_[_loc10_];
               if(_loc11_.id == _loc8_.id)
               {
                  _loc3_[_loc10_] = _loc8_;
                  _loc9_ = true;
                  break;
               }
               _loc10_++;
            }
            if(!_loc9_)
            {
               _loc3_.push(_loc8_);
               _loc12_ = _loc8_.id;
               if(this._servicePrefix != "" && _loc12_.indexOf(this._servicePrefix) == 0)
               {
                  _loc12_ = _loc12_.substr(this._servicePrefix.length);
               }
               this._chatSystem.connect(_loc12_,RoomType.CHAT);
               this._roomsByChannel[_loc12_] = _loc8_;
               _loc13_ = new ChatTile(_loc12_);
               this._tileContainer.addChild(_loc13_);
               this._tiles.push(_loc13_);
               _loc4_ = true;
            }
         }
         this._roomsByNickName[param1] = _loc3_.sortOn("id");
         _loc6_ = [];
         for each(_loc7_ in this._roomsByNickName)
         {
            _loc6_ = _loc6_.concat(_loc7_);
         }
         this._roomList.update(_loc6_);
         if(_loc4_)
         {
            this.layoutTiles();
         }
         if(this._timer.running == false)
         {
            this._timer.start();
         }
      }
      
      private function onListRoomsFail(param1:PlayerIOError) : void
      {
         if(Boolean(this._timer) && this._timer.running == false)
         {
            this._timer.start();
         }
      }
      
      private function layoutTiles() : void
      {
         var _loc2_:ChatTile = null;
         var _loc1_:Point = new Point();
         for each(_loc2_ in this._tiles)
         {
            _loc2_.x = _loc1_.x;
            _loc2_.y = _loc1_.y;
            _loc1_.y = _loc2_.y + _loc2_.height + 2;
            if(_loc2_.y > 0 && _loc2_.y + _loc2_.height > this._tileThumb.y)
            {
               _loc2_.x = _loc2_.x + _loc2_.width + 2;
               _loc2_.y = 0;
               _loc1_.x = _loc2_.x;
               _loc1_.y = _loc2_.y + _loc2_.height + 2;
            }
         }
         if(this._tileContainer.width + this._tileContainer.x < this._tileMask.width)
         {
            this._tileContainer.x = this._tileMask.width - this._tileContainer.width;
         }
         if(this._tileContainer.x > 0)
         {
            this._tileContainer.x = 0;
         }
         this._tileThumb.width = this._tileMask.width * MathUtils.clamp(this._tileMask.width / this._tileContainer.width,0,1);
         this.updateThumbPosition();
      }
      
      private function onBadwordLoaded() : void
      {
         var _loc1_:XML = ResourceManager.getInstance().getResource("xml/badwords.xml").content as XML;
         this._filter = new BadWordFilter(_loc1_.wordlist[0]);
         this._alertChatPanel.clearMessages();
         var _loc2_:ChatMessageData = new ChatMessageData(ALERT_CHANNEL,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc2_.posterIsAdmin = true;
         _loc2_.message = "Filter ready :)";
         this._chatSystem.onChatMessageReceived.dispatch(_loc2_);
      }
      
      private function scrollToChatTile(param1:String) : void
      {
         var _loc3_:ChatTile = null;
         var _loc2_:ChatTile = null;
         for each(_loc3_ in this._tiles)
         {
            if(_loc3_.channel == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_ == null)
         {
            return;
         }
         var _loc4_:Number = -_loc2_.x;
         if(_loc4_ < -(this._tileContainer.width - this._tileMask.width))
         {
            _loc4_ = -(this._tileContainer.width - this._tileMask.width);
         }
         if(_loc4_ > 0)
         {
            _loc4_ = 0;
         }
         this._tileContainer.x = _loc4_;
         _loc2_.pulse();
         this.updateThumbPosition();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._stage = stage;
         this._stage.addEventListener(Event.RESIZE,this.onResize,false,0,true);
         this.onResize();
      }
      
      private function onResize(param1:Event = null) : void
      {
         var _loc2_:Number = this._stage.stageWidth;
         var _loc3_:Number = this._stage.stageHeight;
         graphics.clear();
         graphics.beginFill(0,1);
         graphics.drawRect(0,0,_loc2_,_loc3_);
         graphics.endFill();
         _loc3_ -= this._container.y * 2;
         this.btn_close.x = _loc2_ - this.btn_close.width - 5;
         this.btn_fullscreen.x = this.btn_close.x - this.btn_fullscreen.width - 10;
         this.btn_clear.x = _loc2_ - 5 - this.btn_clear.width;
         this.btn_clear.y = _loc3_ - 5 - this.btn_clear.height;
         this._titleBar.width = _loc2_;
         this._roomList.height = _loc3_ - this._roomList.y;
         this._alertPanel.x = _loc2_ - this._alertPanel.width;
         this._alertChatPanel.graphics.clear();
         this._alertChatPanel.graphics.beginFill(6710886,1);
         this._alertChatPanel.graphics.drawRect(0,0,this._alertChatPanel.width + 2,this._roomList.height);
         this._alertChatPanel.graphics.beginFill(13421772,1);
         this._alertChatPanel.graphics.drawRect(-1,0,1,this._roomList.height);
         this._alertChatPanel.height = this._roomList.height - 2;
         this._tileThumb.y = _loc3_ - this._tileArea.y - this._tileThumb.height - 1;
         this._tileMask.width = _loc2_ - this._tileArea.x - this._alertChatPanel.width;
         this._tileMask.height = _loc3_ - this._tileThumb.height;
         this.layoutTiles();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function onFullScreen(param1:MouseEvent) : void
      {
         if(stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
         {
            stage.displayState = StageDisplayState.NORMAL;
         }
         else
         {
            stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
         }
      }
      
      private function onClearAlerts(param1:MouseEvent) : void
      {
         this._alertChatPanel.clearMessages();
      }
      
      private function onThumbDown(param1:MouseEvent) : void
      {
         this.stopThumbDrag();
         addEventListener(Event.ENTER_FRAME,this.onDragThumb,false,0,true);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.stopThumbDrag,false,0,true);
         this._stage.addEventListener(Event.DEACTIVATE,this.stopThumbDrag,false,0,true);
         this._dragDelta = this._tileThumb.x - this._tileArea.mouseX;
      }
      
      private function onDragThumb(param1:Event = null) : void
      {
         var _loc2_:Number = MathUtils.clamp((this._tileArea.mouseX + this._dragDelta) / (this._tileMask.width - this._tileThumb.width),0,1);
         var _loc3_:Number = 0;
         if(_loc2_ == 1)
         {
            _loc3_ = this._tileMask.width - this._tileContainer.width;
         }
         else
         {
            _loc3_ = (this._tileContainer.width - this._tileMask.width) * -_loc2_;
         }
         if(_loc3_ > 0)
         {
            _loc3_ = 0;
         }
         this._tileContainer.x = _loc3_;
         this.updateThumbPosition();
      }
      
      private function stopThumbDrag(param1:Event = null) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onDragThumb);
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.stopThumbDrag);
         this._stage.removeEventListener(Event.DEACTIVATE,this.stopThumbDrag);
      }
      
      private function updateThumbPosition() : void
      {
         var _loc1_:Number = 0;
         if(this._tileContainer.x != 0)
         {
            _loc1_ = this._tileContainer.x / (this._tileContainer.width - this._tileMask.width);
         }
         this._tileThumb.x = (this._tileMask.width - this._tileThumb.width) * -_loc1_;
      }
      
      private function onShowChatTileLink(param1:ChatLinkEvent) : void
      {
         if(param1.linkType == "showChatTile")
         {
            this.scrollToChatTile(param1.data);
         }
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.game.gui.chat.UIChatPanel;
import thelaststand.app.game.gui.chat.events.ChatLinkEvent;

class TitleBar extends Sprite
{
   
   private var _label:BodyTextField;
   
   private var _width:Number = 300;
   
   private var _height:Number = 30;
   
   public function TitleBar()
   {
      super();
      this._label = new BodyTextField({
         "text":"Chat Command Center :D",
         "color":16777215,
         "size":16
      });
      this._label.x = 10;
      this._label.y = int((this._height - this._label.height) * 0.5);
      addChild(this._label);
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      graphics.clear();
      graphics.beginFill(4079166,1);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
   }
   
   override public function get height() : Number
   {
      return this._height;
   }
   
   override public function set height(param1:Number) : void
   {
   }
}

class RoomData
{
   
   public var id:String;
   
   public var onlineUsers:int;
   
   public var uiPanel:UIChatPanel;
   
   public function RoomData(param1:Object)
   {
      super();
      this.id = param1.id;
      this.onlineUsers = param1.onlineUsers;
   }
}

class RoomList extends Sprite
{
   
   private var _width:Number = 140;
   
   private var _height:Number = 500;
   
   private var _bg:Shape;
   
   private var _mask:Shape;
   
   private var _container:Sprite;
   
   private var _items:Vector.<RoomListItem> = new Vector.<RoomListItem>();
   
   public function RoomList()
   {
      super();
      this._bg = new Shape();
      this._bg.graphics.beginFill(2236962,1);
      this._bg.graphics.drawRect(0,0,this._width,500);
      addChild(this._bg);
      this._container = new Sprite();
      addChild(this._container);
      this._mask = new Shape();
      this._mask.graphics.beginFill(16711680,1);
      this._mask.graphics.drawRect(0,0,this._width,500);
      addChild(this._mask);
      this._container.mask = this._mask;
   }
   
   public function dispose() : void
   {
      var _loc1_:RoomListItem = null;
      if(parent)
      {
         parent.removeChild(this);
      }
      for each(_loc1_ in this._items)
      {
         _loc1_.dispose();
      }
      this._items = null;
   }
   
   public function update(param1:Array) : void
   {
      var _loc2_:RoomListItem = null;
      var _loc4_:RoomData = null;
      var _loc3_:int = 0;
      while(_loc3_ < param1.length)
      {
         _loc4_ = param1[_loc3_];
         if(_loc3_ >= this._items.length)
         {
            _loc2_ = new RoomListItem();
            this._items.push(_loc2_);
            this._container.addChild(_loc2_);
         }
         _loc2_ = this._items[_loc3_];
         _loc2_.setInfo(_loc4_);
         _loc2_.y = _loc3_ * _loc2_.height;
         _loc3_++;
      }
      while(this._items.length > param1.length)
      {
         _loc2_ = this._items.pop();
         _loc2_.dispose();
         _loc3_++;
      }
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
      this._height = param1;
      this._bg.height = this._height;
      this._mask.height = this._height;
   }
}

class RoomListItem extends Sprite
{
   
   private var _channel:String;
   
   private var _bg:Shape;
   
   private var _label:BodyTextField;
   
   private var _info:RoomData;
   
   public function RoomListItem()
   {
      super();
      mouseChildren = false;
      this._bg = new Shape();
      this._bg.graphics.beginFill(6710886,1);
      this._bg.graphics.drawRect(0,0,140,30);
      this._bg.graphics.beginFill(10066329,1);
      this._bg.graphics.drawRect(0,29,140,1);
      addChild(this._bg);
      this._label = new BodyTextField({
         "text":"hellow there",
         "color":16777215,
         "size":13
      });
      this._label.x = 10;
      this._label.maxWidth = this._bg.width - this._label.x * 2;
      this._label.y = (this._bg.height - this._label.height) * 0.5;
      addChild(this._label);
      addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
   }
   
   public function dispose() : void
   {
      this._label.dispose();
      this._info = null;
   }
   
   public function setInfo(param1:RoomData) : void
   {
      this._channel = param1.id;
      this._label.text = param1.id + "  (" + param1.onlineUsers + ")";
   }
   
   private function onClick(param1:MouseEvent) : void
   {
      dispatchEvent(new ChatLinkEvent(ChatLinkEvent.LINK_CLICK,"showChatTile",this._channel));
   }
}

class ChatTile extends Sprite
{
   
   public var channel:String;
   
   private var _panel:UIChatPanel;
   
   private var _label:BodyTextField;
   
   private var _bg:Shape;
   
   public function ChatTile(param1:String)
   {
      super();
      this.channel = param1;
      this._label = new BodyTextField({
         "text":param1,
         "color":16777215,
         "size":13
      });
      addChild(this._label);
      this._panel = new UIChatPanel(param1);
      this._panel.x = 1;
      this._panel.y = this._label.height;
      this._panel.height = 600;
      addChild(this._panel);
      this._bg = new Shape();
      this._bg.graphics.beginFill(16744448,1);
      this._bg.graphics.drawRect(0,0,this._panel.width,this._label.height);
      this._bg.alpha = 0;
      addChildAt(this._bg,0);
      graphics.beginFill(7829367,1);
      graphics.drawRect(0,0,this._panel.width + 1,this._panel.y + this._panel.height + 1);
      graphics.beginFill(0,1);
      graphics.drawRect(1,1,this._panel.width - 1,this._panel.y + this._panel.height - 1);
   }
   
   public function pulse() : void
   {
      this._bg.alpha = 0.5;
      TweenMax.killTweensOf(this._bg);
      TweenMax.to(this._bg,1,{"alpha":0});
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this._label.dispose();
      this._label = null;
      this._panel.dispose();
      this._panel = null;
   }
}
