package thelaststand.app.game.gui.chat.components
{
   import com.exileetiquette.math.MathUtils;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatMessageData;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.common.lang.Language;
   
   public class UIChatMessageList extends Sprite
   {
      
      public static const ROW_HEIGHT:Number = 17;
      
      private static const MAX_MESSAGE_COUNT:uint = 200;
      
      public static const MESSAGE_TYPE_NORMAL:String = "normal";
      
      public static const MESSAGE_TYPE_TRADE:String = "trade";
      
      public static const MESSAGE_TYPE_ALLIANCE:String = "alliance";
      
      private var _chatSystem:ChatSystem;
      
      private var _channel:String;
      
      private var _secondaryChannels:Array;
      
      private var _width:Number = 300;
      
      private var _height:Number = 200;
      
      private var _scollbarContainer:Sprite;
      
      private var _scrollbar:UIScrollBar;
      
      private var _stage:Stage;
      
      private var _messageContainer:Sprite;
      
      private var _messageContainerMask:Shape;
      
      private var _messages:Vector.<IChatMessageDisplayData> = new Vector.<IChatMessageDisplayData>();
      
      private var _offsetLookup:Dictionary = new Dictionary();
      
      private var _dummyMessageDisplay:Dictionary = new Dictionary();
      
      private var _messageDisplays_active:Vector.<IChatMessageDisplay> = new Vector.<IChatMessageDisplay>();
      
      private var _messageDisplays_inactive:Dictionary = new Dictionary();
      
      private var _totalMessageRowCount:Number = 0;
      
      private var _maxRowsDisplayed:int = 0;
      
      private var _offset:int = 0;
      
      private var _offsetMin:int = 0;
      
      private var _offsetMax:int = 0;
      
      private var _ignoreScrollBar:Boolean;
      
      private var _messageDisplayWidth:Number = this._width;
      
      private var _newMessagePulse:Shape;
      
      private var _userPopup:UIChatUserPopupMenu;
      
      public var messageConnecting:String = "";
      
      public var messageConnected:String = "";
      
      public var messageDisconnected:String = "";
      
      public var newMessagedDisplayed:Signal = new Signal(UIChatMessageList);
      
      public function UIChatMessageList(param1:String, param2:Array = null)
      {
         super();
         this._channel = param1;
         this._secondaryChannels = param2 == null ? [] : param2;
         this._secondaryChannels.push(ChatSystem.CHANNEL_ALL);
         this._chatSystem = Network.getInstance().chatSystem;
         this._chatSystem.onChatStatusChange.remove(this.onChatStatusChange);
         this._chatSystem.onChatMessageReceived.remove(this.onMessageReceived);
         this._chatSystem.onChatStatusChange.add(this.onChatStatusChange);
         this._chatSystem.onChatMessageReceived.add(this.onMessageReceived);
         this._scollbarContainer = new Sprite();
         addChild(this._scollbarContainer);
         this._scrollbar = new UIScrollBar();
         this._scrollbar.changed.add(this.onScrollbarChange);
         this._scollbarContainer.addChild(this._scrollbar);
         this._scrollbar.x = int((22 - this._scrollbar.width) * 0.5);
         this._scrollbar.y = this._scrollbar.x;
         this._dummyMessageDisplay = new Dictionary();
         this._dummyMessageDisplay[MESSAGE_TYPE_NORMAL] = new ChatMessageDisplay_Normal();
         this._dummyMessageDisplay[MESSAGE_TYPE_TRADE] = new ChatMessageDisplay_Trade();
         this._dummyMessageDisplay[MESSAGE_TYPE_ALLIANCE] = new ChatMessageDisplay_Alliance();
         this._messageContainerMask = new Shape();
         addChild(this._messageContainerMask);
         this._messageContainer = new Sprite();
         this._messageContainer.x = this._messageContainerMask.x = 24;
         addChild(this._messageContainer);
         this._messageContainer.mask = this._messageContainerMask;
         this._newMessagePulse = new Shape();
         this._newMessagePulse.graphics.beginFill(15597568,1);
         this._newMessagePulse.graphics.drawRect(0,0,100,3);
         addChild(this._newMessagePulse);
         this._newMessagePulse.alpha = 0;
         this._userPopup = new UIChatUserPopupMenu();
         this.setSize(this._width,this.height);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedtoStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(ChatLinkEvent.LINK_CLICK,this.onLinkClick,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:String = null;
         var _loc2_:IChatMessageDisplayData = null;
         var _loc3_:IChatMessageDisplay = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedtoStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         removeEventListener(ChatLinkEvent.LINK_CLICK,this.onLinkClick);
         this._chatSystem.onChatStatusChange.remove(this.onChatStatusChange);
         this._chatSystem.onChatMessageReceived.remove(this.onMessageReceived);
         this._chatSystem = null;
         this._userPopup.dispose();
         this._userPopup = null;
         while(this._messageDisplays_active.length > 0)
         {
            this.releaseMessageDisplay(this._messageDisplays_active.pop());
         }
         for(_loc1_ in this._dummyMessageDisplay)
         {
            this._dummyMessageDisplay[_loc1_].dispose();
            if(this._messageDisplays_inactive[_loc1_])
            {
               for each(_loc3_ in this._messageDisplays_inactive[_loc1_])
               {
                  _loc3_.dispose();
               }
               delete this._messageDisplays_inactive[_loc1_];
            }
         }
         this._dummyMessageDisplay = null;
         for each(_loc2_ in this._messages)
         {
            _loc2_.dispose();
         }
         this._messages = null;
         this.newMessagedDisplayed.removeAll();
      }
      
      public function clear() : void
      {
         this._offsetLookup = new Dictionary();
         while(this._messageDisplays_active.length > 0)
         {
            this.releaseMessageDisplay(this._messageDisplays_active.pop());
         }
         this._totalMessageRowCount = 0;
         this._offset = 0;
         this._offsetMin = this._offsetMax = 0;
         this._messages = new Vector.<IChatMessageDisplayData>();
         this.updateDisplayedMessages();
      }
      
      private function onChatStatusChange(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         if(param1 != this._channel)
         {
            return;
         }
         switch(param2)
         {
            case ChatSystem.STATUS_CONNECTED:
               if(this.messageConnected != "")
               {
                  _loc3_ = this.messageConnected;
                  break;
               }
               _loc3_ = Language.getInstance().getString("chat.welcome_message");
               break;
            case ChatSystem.STATUS_CONNECTING:
               if(this.messageConnecting != "")
               {
                  _loc3_ = this.messageConnecting;
                  break;
               }
               _loc3_ = Language.getInstance().getString("chat.connecting_message");
               break;
            case ChatSystem.STATUS_DISCONNECTED:
               if(this.messageDisconnected != "")
               {
                  _loc3_ = this.messageDisconnected;
                  break;
               }
               _loc3_ = Language.getInstance().getString("chat.disconnected_message");
               break;
            default:
               return;
         }
         this.clear();
         var _loc4_:ChatMessageData = new ChatMessageData(this._channel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc4_.posterNickName = ChatSystem.USER_NAME_COMMAND;
         _loc4_.message = _loc3_;
         this.onMessageReceived(_loc4_,true);
      }
      
      private function onMessageReceived(param1:ChatMessageData, param2:Boolean = false) : void
      {
         var _loc3_:IChatMessageDisplayData = null;
         if(!(param1.channel == this._channel || this._secondaryChannels.indexOf(param1.channel) > -1))
         {
            return;
         }
         if(param2 == false && this._chatSystem.isConnected(this._channel) == false)
         {
            return;
         }
         if(this._offset < this._offsetMax)
         {
            this._newMessagePulse.alpha = 0.8;
            TweenMax.to(this._newMessagePulse,1,{"alpha":0});
         }
         this.newMessagedDisplayed.dispatch(this);
         if(param1.messageType == ChatSystem.MESSAGE_TYPE_SYSTEM)
         {
            switch(param1.message)
            {
               case "*recap*":
                  param1.message = this.generateUserRecap(param1.toNickName);
                  break;
               case "*clear*":
                  this.clear();
                  return;
            }
         }
         var _loc4_:String = MESSAGE_TYPE_NORMAL;
         switch(param1.messageType)
         {
            case ChatSystem.MESSAGE_TYPE_TRADE_REQUEST:
               _loc3_ = ChatMessageDisplay_Trade.generateDisplayDataObj(param1);
               _loc4_ = MESSAGE_TYPE_TRADE;
               break;
            case ChatSystem.MESSAGE_TYPE_ALLIANCE_INVITE:
               _loc3_ = ChatMessageDisplay_Alliance.generateDisplayDataObj(param1);
               _loc4_ = MESSAGE_TYPE_ALLIANCE;
               break;
            default:
               _loc3_ = ChatMessageDisplay_Normal.generateDisplayDataObj(param1);
         }
         var _loc5_:IChatMessageDisplay = this._dummyMessageDisplay[_loc4_];
         _loc5_.width = this._messageDisplayWidth;
         _loc5_.populate(_loc3_);
         _loc3_.rows = _loc5_.rows;
         _loc3_.display = null;
         this.addMessageData(_loc3_);
      }
      
      private function addMessageData(param1:IChatMessageDisplayData) : void
      {
         var _loc2_:IChatMessageDisplayData = null;
         var _loc3_:int = 0;
         var _loc4_:* = this._offset == this._offsetMax;
         if(this._messages.length > 0)
         {
            _loc2_ = this._messages[this._messages.length - 1];
            param1.alternate = !_loc2_.alternate;
            param1.offset = _loc2_.offset + _loc2_.rows;
         }
         this._messages.push(param1);
         this._offsetLookup[param1.offset] = param1;
         this._totalMessageRowCount += param1.rows;
         while(this._messages.length > MAX_MESSAGE_COUNT)
         {
            _loc2_ = this._messages.shift();
            delete this._offsetLookup[_loc2_.offset];
         }
         if(param1.offset > 30)
         {
            this._offset -= this._messages[0].offset;
            if(this._offset < 0)
            {
               this._offset = 0;
            }
            delete this._offsetLookup[this._messages[0].offset];
            this._messages[0].offset = 0;
            this._offsetLookup[0] = this._messages[0];
            _loc3_ = 1;
            while(_loc3_ < this._messages.length)
            {
               _loc2_ = this._messages[_loc3_ - 1];
               delete this._offsetLookup[this._messages[_loc3_].offset];
               this._messages[_loc3_].offset = _loc2_.offset + _loc2_.rows;
               this._offsetLookup[this._messages[_loc3_].offset] = this._messages[_loc3_];
               _loc3_++;
            }
         }
         this.calculateOffsetRange();
         if(_loc4_)
         {
            this._offset = this._offsetMax;
         }
         this._ignoreScrollBar = true;
         this._scrollbar.contentHeight = this._totalMessageRowCount;
         if(this._offsetMax > 0)
         {
            this._scrollbar.value = this._offset / (this._offsetMax - this._offsetMin);
         }
         this._ignoreScrollBar = false;
         this.updateDisplayedMessages();
      }
      
      private function calculateOffsetRange() : void
      {
         if(this._messages.length == 0)
         {
            this._offsetMin = this._offsetMax = 0;
         }
         else
         {
            this._offsetMin = this._messages[0].offset;
            this._offsetMax = this._messages[this._messages.length - 1].offset + this._messages[this._messages.length - 1].rows - this._maxRowsDisplayed;
            if(this._offsetMax < this._offsetMin)
            {
               this._offsetMax = this._offsetMin;
            }
         }
         if(this._offset < this._offsetMin)
         {
            this._offset = this._offsetMin;
         }
      }
      
      private function changeOffset(param1:int) : void
      {
         param1 = MathUtils.clamp(param1,this._offsetMin,this._offsetMax);
         if(this._offset == param1)
         {
            return;
         }
         this._offset = param1;
         this.updateDisplayedMessages();
      }
      
      private function updateDisplayedMessages() : void
      {
         var _loc1_:IChatMessageDisplay = null;
         var _loc3_:IChatMessageDisplayData = null;
         if(this._messages.length == 0)
         {
            this._scrollbar.contentHeight = 0;
            return;
         }
         var _loc2_:int = 0;
         while(!_loc3_)
         {
            _loc3_ = this._offsetLookup[this._offset - _loc2_];
            if(!_loc3_)
            {
               _loc2_++;
            }
            if(_loc2_ > 100)
            {
               return;
            }
         }
         var _loc4_:Vector.<IChatMessageDisplay> = new Vector.<IChatMessageDisplay>();
         _loc1_ = this.getMessageDisplay(_loc3_);
         _loc4_.push(_loc1_);
         _loc1_.y = _loc2_ * -ROW_HEIGHT;
         var _loc5_:int = _loc3_.rows - _loc2_;
         var _loc6_:int = this._messages.indexOf(_loc3_) + 1;
         var _loc7_:int = 0;
         while(_loc5_ < this._maxRowsDisplayed && _loc6_ < this._messages.length)
         {
            _loc1_ = this.getMessageDisplay(this._messages[_loc6_]);
            _loc4_.push(_loc1_);
            _loc1_.y = this._messages[_loc6_ - 1].display.y + this._messages[_loc6_ - 1].rows * ROW_HEIGHT;
            _loc5_ += this._messages[_loc6_].rows;
            _loc6_++;
            if(++_loc7_ > 300)
            {
               throw new Error("ChatPanelMessageList: Displayed row count has exceeded maximum");
            }
         }
         while(this._messageDisplays_active.length > 0)
         {
            this.releaseMessageDisplay(this._messageDisplays_active.pop());
         }
         this._messageDisplays_active = _loc4_;
      }
      
      private function getMessageDisplay(param1:IChatMessageDisplayData) : IChatMessageDisplay
      {
         var _loc2_:IChatMessageDisplay = null;
         var _loc3_:int = 0;
         if(param1.display)
         {
            _loc2_ = param1.display;
            _loc3_ = int(this._messageDisplays_active.indexOf(_loc2_));
            if(_loc3_ > -1)
            {
               this._messageDisplays_active.splice(_loc3_,1);
            }
         }
         else
         {
            if(!this._messageDisplays_inactive[param1.messageDisplayType])
            {
               this._messageDisplays_inactive[param1.messageDisplayType] = new Vector.<IChatMessageDisplay>();
            }
            if(this._messageDisplays_inactive[param1.messageDisplayType].length == 0)
            {
               switch(param1.messageDisplayType)
               {
                  case MESSAGE_TYPE_TRADE:
                     _loc2_ = new ChatMessageDisplay_Trade();
                     break;
                  case MESSAGE_TYPE_ALLIANCE:
                     _loc2_ = new ChatMessageDisplay_Alliance();
                     break;
                  case MESSAGE_TYPE_NORMAL:
                  default:
                     _loc2_ = new ChatMessageDisplay_Normal();
               }
               this._messageDisplays_inactive[param1.messageDisplayType].push(_loc2_);
            }
            _loc2_ = this._messageDisplays_inactive[param1.messageDisplayType].pop();
            _loc2_.width = this._messageDisplayWidth;
            _loc2_.populate(param1);
         }
         this._messageContainer.addChild(DisplayObject(_loc2_));
         return _loc2_;
      }
      
      private function releaseMessageDisplay(param1:IChatMessageDisplay) : void
      {
         if(Boolean(param1.messageData) && param1.messageData.display == param1)
         {
            param1.messageData.display = null;
         }
         if(param1.parent)
         {
            param1.parent.removeChild(DisplayObject(param1));
         }
         this._messageDisplays_inactive[param1.type].push(param1);
      }
      
      private function onScrollbarChange(param1:Number) : void
      {
         if(this._ignoreScrollBar)
         {
            return;
         }
         this.changeOffset(Math.round(param1 * (this._offsetMax - this._offsetMin)));
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         var _loc5_:IChatMessageDisplay = null;
         var _loc7_:int = 0;
         var _loc8_:IChatMessageDisplayData = null;
         var _loc9_:IChatMessageDisplayData = null;
         var _loc3_:* = this._width != param1;
         this._width = param1;
         this._height = param2;
         var _loc4_:* = this._offset == this._offsetMax;
         this._messageDisplayWidth = this._width - (this._messageContainerMask.x + 4);
         this._maxRowsDisplayed = Math.floor((this._height - 26) / ROW_HEIGHT);
         if(_loc3_)
         {
            this._totalMessageRowCount = 0;
            this._offsetLookup = new Dictionary();
            this._totalMessageRowCount = 0;
            while(this._messageDisplays_active.length > 0)
            {
               this.releaseMessageDisplay(this._messageDisplays_active.pop());
            }
            _loc7_ = 0;
            while(_loc7_ < this._messages.length)
            {
               _loc8_ = this._messages[_loc7_];
               _loc9_ = _loc7_ == 0 ? null : this._messages[_loc7_ - 1];
               _loc5_ = this._dummyMessageDisplay[_loc8_.messageDisplayType];
               _loc5_.width = this._messageDisplayWidth;
               _loc5_.populate(_loc8_);
               _loc8_.rows = _loc5_.rows;
               _loc8_.display = null;
               _loc8_.offset = _loc9_ == null ? 0 : _loc9_.offset + _loc9_.rows;
               this._offsetLookup[_loc8_.offset] = _loc8_;
               this._totalMessageRowCount += _loc8_.rows;
               _loc7_++;
            }
         }
         this.calculateOffsetRange();
         if(_loc4_)
         {
            this._offset = this._offsetMax;
         }
         var _loc6_:Graphics = this._messageContainerMask.graphics;
         _loc6_.clear();
         _loc6_.beginFill(16711680);
         _loc6_.drawRect(0,0,this._messageDisplayWidth,this._maxRowsDisplayed * ROW_HEIGHT);
         _loc6_.endFill();
         _loc6_ = this._scollbarContainer.graphics;
         _loc6_.clear();
         _loc6_.beginFill(0,0.45);
         _loc6_.drawRect(0,0,22,this._height);
         _loc6_.endFill();
         _loc6_ = graphics;
         _loc6_.clear();
         _loc6_.beginFill(16711680,0);
         _loc6_.drawRect(0,0,this._width,this._height);
         this._scrollbar.height = this._height - this._scrollbar.x * 2;
         this._ignoreScrollBar = true;
         this._scrollbar.scrollHeight = this._maxRowsDisplayed;
         this._scrollbar.contentHeight = this._totalMessageRowCount;
         if(this._offsetMax > 0)
         {
            this._scrollbar.value = this._offset / (this._offsetMax - this._offsetMin);
         }
         this._ignoreScrollBar = false;
         this._newMessagePulse.width = this._messageDisplayWidth;
         this._newMessagePulse.x = this._messageContainerMask.x;
         this._newMessagePulse.y = this._messageContainerMask.y + this._messageContainerMask.height;
         this.updateDisplayedMessages();
      }
      
      public function ContentsToString() : String
      {
         var _loc1_:String = "";
         var _loc2_:TextField = new TextField();
         var _loc3_:int = 0;
         while(_loc3_ < this._messages.length)
         {
            _loc2_.htmlText = this._messages[_loc3_].message;
            _loc1_ += _loc2_.text + " \n";
            _loc3_++;
         }
         return _loc1_;
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
      
      private function onAddedtoStage(param1:Event) : void
      {
         this._stage = stage;
         this._stage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         parent.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         parent.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         this._stage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         var _loc2_:ChatMessageData = null;
         if(this._stage.displayState != StageDisplayState.NORMAL)
         {
            _loc2_ = new ChatMessageData(ChatSystem.CHANNEL_ALL,ChatSystem.MESSAGE_TYPE_SYSTEM);
            _loc2_.posterNickName = ChatSystem.USER_NAME_NOTHING;
            _loc2_.message = Language.getInstance().getString("chat.fullscreen");
            this.onMessageReceived(_loc2_);
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         if(!parent)
         {
            return;
         }
         if(parent.mouseX < 0 || parent.mouseX > parent.width || parent.mouseY < 0 || parent.mouseY > parent.height)
         {
            return;
         }
         param1.stopPropagation();
         this._offset = MathUtils.clamp(this._offset - param1.delta,this._offsetMin,this._offsetMax);
         this.updateDisplayedMessages();
         this._ignoreScrollBar = true;
         this._scrollbar.value = (this._offset - this._offsetMin) / (this._offsetMax - this._offsetMin);
         this._ignoreScrollBar = false;
      }
      
      private function onLinkClick(param1:ChatLinkEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         if(param1.linkType == ChatLinkEvent.LT_USERMENU)
         {
            _loc2_ = param1.data[0];
            _loc3_ = param1.data.length > 1 ? param1.data[1] : "0";
            this._userPopup.populate(_loc2_,_loc3_,this._channel,this);
            _loc4_ = new Point();
            _loc4_.x = mouseX - 3;
            _loc4_.y = mouseY - 3;
            if(_loc4_.y + this._userPopup.height > this._height)
            {
               _loc4_.y = this._height - (this._userPopup.height + 3);
            }
            _loc5_ = localToGlobal(_loc4_);
            if(_loc5_.y < 0)
            {
               _loc5_.y = 0;
            }
            if(_loc5_.x < 0)
            {
               _loc5_.x = 0;
            }
            this._userPopup.x = _loc5_.x;
            this._userPopup.y = _loc5_.y;
            Global.stage.addChild(this._userPopup);
         }
      }
      
      private function generateUserRecap(param1:String) : String
      {
         var _loc3_:IChatMessageDisplayData = null;
         var _loc2_:* = "Recapping " + param1;
         for each(_loc3_ in this._messages)
         {
            if(_loc3_.nickName == param1)
            {
               if(_loc3_.messageDisplayType == MESSAGE_TYPE_TRADE)
               {
                  _loc2_ += "\nTrade Request";
               }
               else if(_loc3_.messageDisplayType == MESSAGE_TYPE_ALLIANCE)
               {
                  _loc2_ += "\n Alliance Invite";
               }
               else
               {
                  _loc2_ += "\n" + _loc3_.message;
               }
            }
         }
         return _loc2_ + "\nRecap Complete";
      }
      
      public function findMessageByUniqueId(param1:String) : IChatMessageDisplayData
      {
         var _loc2_:IChatMessageDisplayData = null;
         var _loc3_:int = int(this._messages.length - 1);
         while(_loc3_ >= 0)
         {
            if(this._messages[_loc3_].messageData.uniqueId == param1)
            {
               _loc2_ = this._messages[_loc3_];
               break;
            }
            _loc3_--;
         }
         return _loc2_;
      }
   }
}

