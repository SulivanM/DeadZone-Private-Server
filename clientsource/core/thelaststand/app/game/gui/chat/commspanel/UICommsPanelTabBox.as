package thelaststand.app.game.gui.chat.commspanel
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.buttons.UIBitmapButton;
   import thelaststand.app.game.gui.chat.components.UIChatMessageList;
   import thelaststand.app.game.gui.chat.components.UIChatTextEntry;
   import thelaststand.app.game.gui.chat.events.ChatOptionsMenuEvent;
   import thelaststand.app.game.gui.chat.events.ChatUserMenuEvent;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.common.lang.Language;
   
   public class UICommsPanelTabBox extends Sprite
   {
      
      private var HEADER_HEIGHT:int = 22;
      
      private var PANEL_HEIGHT_NORMAL:int = 200;
      
      private var PANEL_HEIGHT_EXPANDED:int = this.HEADER_HEIGHT + 20 * UIChatMessageList.ROW_HEIGHT;
      
      private var PANEL_WIDTH_UNDOCKED:int = 400;
      
      private var _chatSystem:ChatSystem;
      
      private var _stage:Stage;
      
      private var _stageBoundaries:Object = {
         "left":10,
         "right":10,
         "top":30,
         "bottom":30
      };
      
      private var _width:Number = 400;
      
      private var _height:Number = 400;
      
      private var _expanded:Boolean;
      
      private var _docked:Boolean = true;
      
      private var _input:UIChatTextEntry;
      
      private var _tabContainer:Sprite;
      
      private var _tabsBtns:Vector.<UICommsPanelTabButton> = new Vector.<UICommsPanelTabButton>();
      
      private var _chatMessageList:Vector.<UIChatMessageList> = new Vector.<UIChatMessageList>();
      
      private var _currentMessageList:UIChatMessageList;
      
      private var _playerData:PlayerData;
      
      private var mc_background:Sprite;
      
      private var btn_docked:UIBitmapButton;
      
      private var bd_dock:BitmapData;
      
      private var bd_undock:BitmapData;
      
      private var btn_close:UIBitmapButton;
      
      private var btn_expand:ExpandArrowButton;
      
      private var tab_recruiting:UICommsPanelTabButton;
      
      private var tab_alliance:UICommsPanelTabButton;
      
      private var tab_admin:UICommsPanelTabButton;
      
      private var mc_headerBtnContainer:Sprite;
      
      private var pulseTimestamps:Dictionary = new Dictionary();
      
      private var totalTabWidths:Number = 0;
      
      public var onDockedChange:Signal = new Signal(Boolean);
      
      public var onClosed:Signal = new Signal();
      
      public function UICommsPanelTabBox()
      {
         super();
         this._chatSystem = Network.getInstance().chatSystem;
         this._chatSystem.onChatStatusChange.add(this.onChatStatusChange);
         this._chatSystem.onAllowedChannelsChange.add(this.updateAvailableTabs);
         this._playerData = Network.getInstance().playerData;
         this.mc_background = new UIChatPanelBG();
         this.mc_background.width = 508;
         addChild(this.mc_background);
         var _loc1_:ChatCornerIcon = new ChatCornerIcon();
         _loc1_.x = _loc1_.y = 1;
         addChild(_loc1_);
         this.mc_headerBtnContainer = new Sprite();
         addChild(this.mc_headerBtnContainer);
         this.btn_expand = new ExpandArrowButton();
         this.btn_expand.y = 6;
         this.mc_headerBtnContainer.addChild(this.btn_expand);
         this.btn_expand.addEventListener(MouseEvent.MOUSE_DOWN,this.onExpandMouseDown,false,0,true);
         TooltipManager.getInstance().add(this.btn_expand,this.getExpandTooltip,new Point(5,0),TooltipDirection.DIRECTION_DOWN,Number.NaN);
         this.bd_dock = new BmpIconPanelDock();
         this.bd_undock = new BmpIconPanelUndock();
         this.btn_docked = new UIBitmapButton(this.bd_undock);
         this.btn_docked.x = this.btn_expand.x + this.btn_expand.width + 7;
         this.btn_docked.y = 6;
         this.mc_headerBtnContainer.addChild(this.btn_docked);
         this.btn_docked.addEventListener(MouseEvent.MOUSE_DOWN,this.onDockedMouseDown,false,0,true);
         TooltipManager.getInstance().add(this.btn_docked,this.getDockTooltip,new Point(5,0),TooltipDirection.DIRECTION_DOWN,Number.NaN);
         this.btn_close = new UIBitmapButton(new BmpIconChatClose());
         this.btn_close.x = this.btn_docked.x + this.btn_docked.width + 14;
         this.btn_close.y = 6;
         this.mc_headerBtnContainer.addChild(this.btn_close);
         this.btn_close.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseMouseDown,false,0,true);
         TooltipManager.getInstance().add(this.btn_close,Language.getInstance().getString("chat.tooltip_close"),new Point(5,0),TooltipDirection.DIRECTION_DOWN,Number.NaN);
         this._tabContainer = new Sprite();
         this._tabContainer.x = 28;
         this._tabContainer.y = 3;
         addChild(this._tabContainer);
         this.createTab(Language.getInstance().getString("chat.public_room_name"),ChatSystem.CHANNEL_PUBLIC);
         this.createTab(Language.getInstance().getString("chat.trade_room_name"),ChatSystem.CHANNEL_TRADE_PUBLIC);
         this.tab_recruiting = this.createTab(Language.getInstance().getString("chat.recruiting_room_name"),ChatSystem.CHANNEL_RECRUITING);
         this.tab_alliance = this.createTab("ALLIANCE",ChatSystem.CHANNEL_ALLIANCE);
         this.tab_admin = this.createTab("ADMIN",ChatSystem.CHANNEL_ADMIN);
         this._input = new UIChatTextEntry(this._chatSystem);
         this._input.x = 25;
         addChild(this._input);
         AllianceSystem.getInstance().connected.add(this.updateAvailableTabs);
         AllianceSystem.getInstance().disconnected.add(this.updateAvailableTabs);
         this.setExpanded(false);
         this.setDocked(true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
      }
      
      internal function connectInititalTabs() : void
      {
         var _loc1_:UICommsPanelTabButton = this._tabsBtns[0];
         if(this._chatSystem.getStatus(_loc1_.channelId) == ChatSystem.STATUS_DISCONNECTED)
         {
            this._chatSystem.connect(_loc1_.channelId);
         }
         this.selectChatById(_loc1_.channelId);
         if(!this._chatSystem.isConnected(ChatSystem.CHANNEL_PRIVATE))
         {
            this._chatSystem.connect(ChatSystem.CHANNEL_PRIVATE);
         }
      }
      
      internal function disconnectAllTabs() : void
      {
         var _loc1_:UICommsPanelTabButton = null;
         for each(_loc1_ in this._tabsBtns)
         {
            this._chatSystem.disconnect(_loc1_.channelId);
         }
         this._chatSystem.disconnect(ChatSystem.CHANNEL_PRIVATE);
      }
      
      private function createTab(param1:String, param2:String) : UICommsPanelTabButton
      {
         var _loc3_:UICommsPanelTabButton = null;
         _loc3_ = new UICommsPanelTabButton(param1,param2);
         _loc3_.addEventListener(UICommsPanelTabButton.SELECT_TAB,this.onTabSelect,false,0,true);
         _loc3_.addEventListener(UICommsPanelTabButton.TOGGLE_STATUS,this.onTabToggleStatus,false,0,true);
         this._tabsBtns.push(_loc3_);
         var _loc4_:UIChatMessageList = new UIChatMessageList(param2,[ChatSystem.CHANNEL_PRIVATE]);
         _loc4_.newMessagedDisplayed.add(this.onNewMessageDisplayed);
         this._chatMessageList.push(_loc4_);
         _loc4_.x = 2;
         _loc4_.y = this.HEADER_HEIGHT + 1;
         return _loc3_;
      }
      
      private function refreshAllianceTabLabel() : void
      {
         if(!AllianceSystem.getInstance().inAlliance)
         {
            return;
         }
         this.tab_alliance.Label = Language.getInstance().getString("chat.alliance_room_name") + " [" + this._playerData.allianceTag + "]";
      }
      
      private function updateAvailableTabs() : void
      {
         var _loc2_:UICommsPanelTabButton = null;
         var _loc4_:UICommsPanelTabButton = null;
         var _loc5_:Boolean = false;
         var _loc1_:String = "";
         var _loc3_:Boolean = false;
         this.totalTabWidths = 0;
         for each(_loc4_ in this._tabsBtns)
         {
            _loc4_.compactMode = false;
            _loc5_ = this._chatSystem.isChannelAllowed(_loc4_.channelId);
            if((_loc5_) && _loc4_.channelId == ChatSystem.CHANNEL_ALLIANCE)
            {
               if(this._playerData.allianceId == null)
               {
                  _loc5_ = false;
               }
               else
               {
                  this.refreshAllianceTabLabel();
               }
            }
            if(_loc5_ && _loc4_.channelId == ChatSystem.CHANNEL_ADMIN && _loc4_.parent == null)
            {
               _loc3_ = true;
            }
            if(_loc5_)
            {
               this._tabContainer.addChild(_loc4_);
               if(_loc4_.selected)
               {
                  _loc1_ = _loc4_.channelId;
               }
               if(!_loc2_)
               {
                  _loc2_ = _loc4_;
               }
               this.totalTabWidths += _loc4_.width;
            }
            else if(_loc4_.parent)
            {
               _loc4_.parent.removeChild(_loc4_);
               this._chatSystem.disconnect(_loc4_.channelId);
            }
         }
         if(_loc3_)
         {
            _loc1_ = ChatSystem.CHANNEL_ADMIN;
         }
         if(_loc1_ == "" && Boolean(_loc2_))
         {
            _loc1_ = _loc2_.channelId;
         }
         this.selectChatById(_loc1_);
         this.layoutTabPositions();
         if(!_loc2_)
         {
            this.onClosed.dispatch();
         }
      }
      
      private function layoutTabPositions() : void
      {
         var _loc3_:UICommsPanelTabButton = null;
         var _loc1_:* = this._width - 80 < this.totalTabWidths;
         var _loc2_:int = 0;
         for each(_loc3_ in this._tabsBtns)
         {
            if(_loc3_.parent)
            {
               _loc3_.compactMode = _loc1_;
               _loc3_.x = _loc2_;
               _loc2_ = _loc3_.x + _loc3_.width + 3;
            }
         }
      }
      
      private function getExpandTooltip() : String
      {
         return Language.getInstance().getString(this._expanded ? "chat.tooltip_collapse" : "chat.tooltip_expand");
      }
      
      private function getDockTooltip() : String
      {
         return Language.getInstance().getString(this._docked ? "chat.tooltip_undock" : "chat.tooltip_dock");
      }
      
      private function onTabToggleStatus(param1:Event) : void
      {
         var _loc2_:UICommsPanelTabButton = UICommsPanelTabButton(param1.target);
         if(_loc2_.status)
         {
            this._chatSystem.connect(_loc2_.channelId);
         }
         else
         {
            this._chatSystem.disconnect(_loc2_.channelId);
         }
      }
      
      private function onTabSelect(param1:Event) : void
      {
         var _loc2_:UICommsPanelTabButton = UICommsPanelTabButton(param1.target);
         if(_loc2_.toggleDelayed == false && this._chatSystem.getStatus(_loc2_.channelId) == ChatSystem.STATUS_DISCONNECTED)
         {
            this._chatSystem.connect(_loc2_.channelId);
         }
         this.selectChatById(_loc2_.channelId);
      }
      
      private function selectChatById(param1:String) : void
      {
         var _loc3_:UICommsPanelTabButton = null;
         var _loc4_:UIChatMessageList = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._tabsBtns.length)
         {
            _loc3_ = this._tabsBtns[_loc2_];
            _loc3_.selected = _loc3_.channelId == param1;
            _loc4_ = this._chatMessageList[_loc2_];
            if(_loc3_.selected)
            {
               this._currentMessageList = _loc4_;
               if(!_loc4_.parent)
               {
                  this.updateCurrentMessageListSize();
                  addChild(_loc4_);
               }
            }
            else if(!_loc3_.selected && Boolean(_loc4_.parent))
            {
               _loc4_.parent.removeChild(_loc4_);
            }
            _loc2_++;
         }
         this._input.changeCurrentChannel(param1);
         addChild(this._input);
      }
      
      private function onChatStatusChange(param1:String, param2:String) : void
      {
         var _loc3_:UICommsPanelTabButton = null;
         for each(_loc3_ in this._tabsBtns)
         {
            if(_loc3_.channelId == param1)
            {
               _loc3_.status = param2 != ChatSystem.STATUS_DISCONNECTED;
            }
         }
      }
      
      private function updateCurrentMessageListSize() : void
      {
         if(!this._currentMessageList)
         {
            return;
         }
         this._currentMessageList.width = this._width;
         this._currentMessageList.height = this._height - (this.HEADER_HEIGHT + 3);
      }
      
      private function onExpandMouseDown(param1:MouseEvent) : void
      {
         this.setExpanded(!this._expanded);
      }
      
      private function setExpanded(param1:Boolean) : void
      {
         this._expanded = param1;
         this.btn_expand.expanded = this._expanded;
         this.setSize(this._width,this._expanded ? this.PANEL_HEIGHT_EXPANDED : this.PANEL_HEIGHT_NORMAL);
         if(!this._docked)
         {
            Settings.getInstance().setData("ChatPanel_expanded",this._expanded);
         }
      }
      
      private function onNewMessageDisplayed(param1:UIChatMessageList) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:int = int(this._chatMessageList.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         var _loc3_:UICommsPanelTabButton = this._tabsBtns[_loc2_];
         if(_loc3_.selected == false)
         {
            _loc4_ = this.pulseTimestamps[_loc3_] ? Number(this.pulseTimestamps[_loc3_]) : 0;
            if(getTimer() - _loc4_ > 5000)
            {
               _loc3_.pulse();
               this.pulseTimestamps[_loc3_] = getTimer();
            }
         }
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         this._width = param1;
         this._height = param2;
         this.mc_background.width = this._width;
         this.mc_background.height = this._height;
         this.mc_headerBtnContainer.x = this.mc_background.width - this.mc_headerBtnContainer.width - 7;
         this._input.y = this.mc_background.height - this._input.height - 2;
         this._input.width = this._width - this._input.x - 2;
         this.updateCurrentMessageListSize();
         this.layoutTabPositions();
      }
      
      private function onDockedMouseDown(param1:MouseEvent) : void
      {
         this.setDocked(!this._docked);
      }
      
      private function setDocked(param1:Boolean) : void
      {
         this._docked = param1;
         this.btn_docked.normalBD = this._docked ? this.bd_undock : this.bd_dock;
         this.btn_expand.visible = !this._docked;
         if(this._docked)
         {
            if(this._expanded)
            {
               this.setExpanded(false);
            }
         }
         this.onDockedChange.dispatch(this._docked);
      }
      
      private function onCloseMouseDown(param1:MouseEvent) : void
      {
         this.disconnectAllTabs();
         if(!this._docked)
         {
            this.setDocked(true);
         }
         this.onClosed.dispatch();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._stage == null)
         {
            stage.addEventListener(ChatUserMenuEvent.MENU_ITEM_CLICK,this.onChatUserMenuClick,false,0,true);
            stage.addEventListener(ChatOptionsMenuEvent.MENU_ITEM_CLICK,this.onOptionsMenuClick,false,0,true);
         }
         this._stage = stage;
         this.updateAvailableTabs();
         if(this._docked)
         {
            if(this._expanded)
            {
               this.setExpanded(false);
            }
         }
         else
         {
            this._stage.addEventListener(Event.RESIZE,this.positionAtStoredLocation,false,0,true);
            this.mc_background.addEventListener(MouseEvent.MOUSE_DOWN,this.startMouseDrag,false,0,true);
            this.setSize(this.PANEL_WIDTH_UNDOCKED,this._height);
            this.setExpanded(Settings.getInstance().getData("ChatPanel_expanded",false));
            this.positionAtStoredLocation();
         }
      }
      
      private function onChatUserMenuClick(param1:ChatUserMenuEvent) : void
      {
         this._input.parseUserMenuClickEvent(param1);
      }
      
      private function onOptionsMenuClick(param1:ChatOptionsMenuEvent) : void
      {
         this._input.parseOptionsMenuClickEvent(param1);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this.mc_background.removeEventListener(MouseEvent.MOUSE_DOWN,this.startMouseDrag);
         this._stage.removeEventListener(Event.RESIZE,this.positionAtStoredLocation);
      }
      
      private function startMouseDrag(param1:MouseEvent) : void
      {
         var _loc2_:Point = parent.globalToLocal(new Point(this._stageBoundaries.left,this._stageBoundaries.top));
         var _loc3_:Point = parent.globalToLocal(new Point(this._stage.stageWidth - this._stageBoundaries.right - this.mc_background.width,stage.stageHeight - this._stageBoundaries.bottom - this.mc_background.height));
         startDrag(false,new Rectangle(_loc2_.x,_loc2_.y,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y));
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.stopMouseDrag,false,0,true);
         this._stage.addEventListener(Event.DEACTIVATE,this.stopMouseDrag,false,0,true);
      }
      
      private function stopMouseDrag(param1:MouseEvent) : void
      {
         stopDrag();
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.stopMouseDrag);
         this._stage.removeEventListener(Event.DEACTIVATE,this.stopMouseDrag);
         var _loc2_:Point = parent.localToGlobal(new Point(x,y));
         Settings.getInstance().setData("ChatPanel_x",_loc2_.x);
         Settings.getInstance().setData("ChatPanel_y",_loc2_.y);
         this.constrianToStageBounds();
      }
      
      private function positionAtStoredLocation(param1:Event = null) : void
      {
         var _loc2_:Point = parent.globalToLocal(new Point(Settings.getInstance().getData("ChatPanel_x",50),Settings.getInstance().getData("ChatPanel_y",50)));
         x = _loc2_.x;
         y = _loc2_.y;
         this.constrianToStageBounds();
      }
      
      private function constrianToStageBounds() : void
      {
         var _loc1_:Point = parent.globalToLocal(new Point(this._stageBoundaries.left,this._stageBoundaries.top));
         var _loc2_:Point = parent.globalToLocal(new Point(this._stage.stageWidth - this._stageBoundaries.right,stage.stageHeight - this._stageBoundaries.bottom));
         if(x + this.mc_background.width > _loc2_.x)
         {
            x = _loc2_.x - this.mc_background.width;
         }
         if(x < _loc1_.x)
         {
            x = _loc1_.x;
         }
         if(y + this.mc_background.height > _loc2_.y)
         {
            y = _loc2_.y - this.mc_background.height;
         }
         if(y < _loc1_.y)
         {
            y = _loc1_.y = _loc1_.y;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(this._input.visible)
         {
            if(param1.target is TextField)
            {
               if(TextField(param1.target).selectedText == "" || this._input.contains(DisplayObject(param1.target)))
               {
                  stage.focus = this._input;
               }
            }
            else
            {
               stage.focus = this._input;
            }
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this._height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this._width,param1);
      }
      
      public function get docked() : Boolean
      {
         return this._docked;
      }
      
      public function set docked(param1:Boolean) : void
      {
         this.setDocked(param1);
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BevelFilter;

class ChatCornerIcon extends Sprite
{
   
   private var bg:Shape;
   
   public function ChatCornerIcon()
   {
      super();
      mouseEnabled = mouseChildren = false;
      this.bg = new Shape();
      this.bg.graphics.beginFill(4605510,1);
      this.bg.graphics.drawRoundRectComplex(0,0,24,21,1,0,1,0);
      addChild(this.bg);
      this.bg.filters = [new BevelFilter(1,45,16777215,0.4,0,0.4,1,1,1,1)];
      var _loc1_:Bitmap = new Bitmap(new BmpIconChatBubble());
      _loc1_.x = int((this.bg.width - _loc1_.width) * 0.5);
      _loc1_.y = int((this.bg.height - _loc1_.height) * 0.5);
      addChild(_loc1_);
   }
}

class ExpandArrowButton extends Sprite
{
   
   private var bitmap:Bitmap;
   
   private var bd_expand:BitmapData;
   
   private var bd_contract:BitmapData;
   
   public function ExpandArrowButton()
   {
      super();
      buttonMode = true;
      mouseChildren = false;
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      graphics.beginFill(16711680,0);
      graphics.drawRect(0,0,12,12);
      this.bd_expand = new BmpIconPanelExpand();
      this.bd_contract = new BmpIconPanelContract();
      this.bitmap = new Bitmap();
      addChild(this.bitmap);
   }
   
   public function get expanded() : Boolean
   {
      return this.bitmap.bitmapData == this.bd_contract;
   }
   
   public function set expanded(param1:Boolean) : void
   {
      this.bitmap.bitmapData = param1 ? this.bd_contract : this.bd_expand;
      this.bitmap.x = int(6 - this.bitmap.width * 0.5);
      this.bitmap.y = int(6 - this.bitmap.height * 0.5);
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bitmap,0.1,{"alpha":1});
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bitmap,0.1,{"alpha":0.8});
   }
}
