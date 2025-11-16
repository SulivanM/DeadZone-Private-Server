package thelaststand.app.game.gui.chat.components
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.network.chat.ChatMessageData;
   import thelaststand.common.lang.Language;
   
   public class ChatMessageDisplay_Trade extends Sprite implements IChatMessageDisplay
   {
      
      private var _width:Number = 400;
      
      private var _bg:Shape;
      
      private var _icon:Bitmap;
      
      private var _label:TextField;
      
      private var _messageData:IChatMessageDisplayData;
      
      private var _rows:int = 2;
      
      private var _textLinks:TextField;
      
      private var _linkSpaceRequired:Number;
      
      private var _lang:Language = Language.getInstance();
      
      private var _acceptRejectStr:String = "<font color=\'#6eb91c\'><b><a href=\'event:accept\'>" + this._lang.getString("trade.tradeChatLinkAccept") + "</a></b></font>  <font color=\'#dd785d\'><b><a href=\'event:reject\'>" + this._lang.getString("trade.tradeChatLinkReject") + "</a></b></font>";
      
      public function ChatMessageDisplay_Trade()
      {
         super();
         this._bg = new Shape();
         addChild(this._bg);
         this._icon = new Bitmap(new BmpIconTradeSmall());
         this._icon.x = 2;
         this._icon.y = int(UIChatMessageList.ROW_HEIGHT - this._icon.height * 0.5);
         addChild(this._icon);
         var _loc1_:StyleSheet = new StyleSheet();
         _loc1_.setStyle("a:link",{"textDecoration":"none"});
         _loc1_.setStyle("a:hover",{"textDecoration":"underline"});
         var _loc2_:TextFormat = new TextFormat("_sans",13,16777215);
         _loc2_.leading = 2;
         this._textLinks = new TextField();
         this._textLinks.defaultTextFormat = _loc2_;
         this._textLinks.styleSheet = _loc1_;
         this._textLinks.multiline = this._textLinks.wordWrap = false;
         this._textLinks.selectable = false;
         this._textLinks.autoSize = TextFieldAutoSize.LEFT;
         this._textLinks.mouseWheelEnabled = false;
         this._textLinks.htmlText = this._acceptRejectStr;
         this._textLinks.x = this._width - this._textLinks.width - 10;
         this._textLinks.y = UIChatMessageList.ROW_HEIGHT - this._textLinks.height * 0.5;
         addChild(this._textLinks);
         this._textLinks.filters = [new GlowFilter(0,1,2,2,5)];
         this._linkSpaceRequired = this._textLinks.width + 20;
         this._label = new TextField();
         this._label.defaultTextFormat = _loc2_;
         this._label.styleSheet = _loc1_;
         this._label.multiline = this._label.wordWrap = false;
         this._label.selectable = true;
         this._label.autoSize = TextFieldAutoSize.LEFT;
         this._label.mouseWheelEnabled = false;
         this._label.text = "test";
         this._label.x = this._icon.x + this._icon.width;
         this._label.y = UIChatMessageList.ROW_HEIGHT - this._label.height * 0.5;
         this._label.width = this._width - (this._label.x - this._linkSpaceRequired);
         addChild(this._label);
         this._label.filters = [new GlowFilter(0,1,2,2,5)];
         this._label.addEventListener(TextEvent.LINK,this.onTextLink,false,0,true);
         this._textLinks.addEventListener(TextEvent.LINK,this.onTextLink,false,0,true);
      }
      
      public static function generateDisplayDataObj(param1:ChatMessageData) : IChatMessageDisplayData
      {
         return new TradeMessageDisplayData(param1);
      }
      
      public function dispose() : void
      {
         this.populate(null);
         if(parent)
         {
            parent.removeChild(this);
         }
         this._label.removeEventListener(TextEvent.LINK,this.onTextLink);
         this._textLinks.removeEventListener(TextEvent.LINK,this.onTextLink);
         this._icon.bitmapData.dispose();
         this._icon = null;
      }
      
      public function populate(param1:IChatMessageDisplayData) : void
      {
         if(this._messageData)
         {
            if(this._messageData.display == this)
            {
               this._messageData.display = null;
            }
            TradeMessageDisplayData(this._messageData).onExpiration.remove(this.refreshLayout);
         }
         this._messageData = param1;
         if(this._messageData)
         {
            this._messageData.display = this;
            TradeMessageDisplayData(this._messageData).onExpiration.add(this.refreshLayout);
         }
         this.refreshLayout();
      }
      
      private function redrawBG() : void
      {
         var _loc1_:Graphics = this._bg.graphics;
         _loc1_.clear();
         _loc1_.beginFill(5933094,1);
         _loc1_.drawRect(0,0,this._width,UIChatMessageList.ROW_HEIGHT * this._rows - 1);
         var _loc2_:Number = this._rows * UIChatMessageList.ROW_HEIGHT;
         var _loc3_:Matrix = new Matrix();
         _loc3_.createGradientBox(this._width,_loc2_,Math.PI * 0.5);
         _loc1_.beginGradientFill(GradientType.LINEAR,[4025354,5071924],[1,1],[0,255],_loc3_);
         _loc1_.drawRect(1,1,this._width - 2,_loc2_ - 3);
         _loc1_.endFill();
      }
      
      private function refreshLayout() : void
      {
         this._textLinks.text = "";
         this._textLinks.htmlText = "";
         if(!this._messageData)
         {
            return;
         }
         var _loc1_:TradeMessageDisplayData = TradeMessageDisplayData(this._messageData);
         if(_loc1_.expired)
         {
            switch(_loc1_.status)
            {
               case TradeMessageDisplayData.STATUS_ACCEPED:
                  this._textLinks.htmlText = this._lang.getString("trade.tradeChatLinkAccepted");
                  break;
               case TradeMessageDisplayData.STATUS_REJECTED:
                  this._textLinks.htmlText = this._lang.getString("trade.tradeChatLinkRejected");
                  break;
               case TradeMessageDisplayData.STATUS_EXPIRED:
               default:
                  this._textLinks.htmlText = this._lang.getString("trade.tradeChatLinkExpired");
            }
            TweenMax.to(this,0,{"colorMatrixFilter":{"saturation":0}});
         }
         else
         {
            this._textLinks.htmlText = this._acceptRejectStr;
            TweenMax.to(this,0,{"colorMatrixFilter":{
               "saturation":1,
               "remove":true
            }});
         }
         this._textLinks.x = this._width - this._linkSpaceRequired + (this._linkSpaceRequired - this._textLinks.width - 10);
         this._label.text = "";
         this._label.width = this._width - (this._label.x + this._linkSpaceRequired);
         if(this.messageData)
         {
            this._label.htmlText = this.messageData.message;
         }
         this._label.y = (this._bg.height - this._label.height) * 0.5;
      }
      
      private function onTextLink(param1:TextEvent) : void
      {
         var _loc2_:Array = param1.text.split(":");
         var _loc3_:String = _loc2_.shift();
         var _loc4_:ChatLinkEvent = new ChatLinkEvent(ChatLinkEvent.LINK_CLICK,_loc3_);
         switch(_loc3_)
         {
            case ChatLinkEvent.LT_USERMENU:
               _loc4_.data = _loc2_[0];
               break;
            case ChatLinkEvent.LT_ALLIANCE_SHOW:
               _loc4_.data = _loc2_[0];
               break;
            case "accept":
               TradeSystem.getInstance().acceptTradeRequest(TradeMessageDisplayData(this._messageData).nickName);
               break;
            case "reject":
               TradeSystem.getInstance().rejectTradeRequest(TradeMessageDisplayData(this._messageData).nickName,TradeSystem.NO_REASON);
               break;
            default:
               return;
         }
         dispatchEvent(_loc4_);
      }
      
      public function get messageData() : IChatMessageDisplayData
      {
         return this._messageData;
      }
      
      public function get rows() : uint
      {
         return this._rows;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.redrawBG();
         this._label.width = this._width - (this._label.x - this._linkSpaceRequired);
         this.refreshLayout();
      }
      
      override public function get height() : Number
      {
         return this._bg.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get type() : String
      {
         return UIChatMessageList.MESSAGE_TYPE_TRADE;
      }
   }
}

import flash.utils.clearInterval;
import flash.utils.setInterval;
import org.osflash.signals.Signal;
import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
import thelaststand.app.game.logic.TradeSystem;
import thelaststand.app.network.Network;
import thelaststand.app.network.chat.ChatMessageData;
import thelaststand.common.lang.Language;

class TradeMessageDisplayData implements IChatMessageDisplayData
{
   
   public static const STATUS_ACCEPED:String = "accepted";
   
   public static const STATUS_REJECTED:String = "rejected";
   
   public static const STATUS_EXPIRED:String = "expired";
   
   public var expired:Boolean = false;
   
   public var status:String = "";
   
   public var onExpiration:Signal = new Signal();
   
   private var _cmd:ChatMessageData;
   
   private var _expireTime:Number;
   
   private var _intervalId:uint;
   
   private var _nickName:String;
   
   private var _display:IChatMessageDisplay;
   
   private var _msg:String;
   
   private var _linkData:Array;
   
   private var _alternate:Boolean;
   
   private var _offset:uint = 0;
   
   private var _rows:uint = 2;
   
   public function TradeMessageDisplayData(param1:ChatMessageData)
   {
      super();
      this._cmd = param1;
      this._nickName = param1.posterNickName;
      var _loc2_:* = "<a href=\'event:" + ChatLinkEvent.LT_USERMENU + ":" + this._nickName + ":0\'>" + this._nickName + "</a>";
      if(Boolean(param1.posterAllianceId) && Boolean(param1.posterAllianceTag))
      {
         _loc2_ += " [<a href=\'event:" + ChatLinkEvent.LT_ALLIANCE_SHOW + ":" + param1.posterAllianceId + "\' class=\'messagealliance\'>" + param1.posterAllianceTag + "</a>]";
      }
      this._msg = Language.getInstance().getString("trade.tradeChatMessage");
      this._msg = this._msg.replace("%user",_loc2_);
      this._expireTime = Network.getInstance().serverTime + 25 * 1000;
      this._intervalId = setInterval(this.checkForTimeExipration,1000);
      Network.getInstance().chatSystem.onTargetUserNotOnline.add(this.onTargetUserNotOnline);
      TradeSystem.getInstance().onTradeRequestResponse.add(this.onTradeRequestResponse);
      TradeSystem.getInstance().onCancelTradeRequests.add(this.expire);
   }
   
   private function checkForTimeExipration() : void
   {
      if(Network.getInstance().serverTime > this._expireTime)
      {
         this.expire();
      }
   }
   
   public function expire(param1:String = "expired") : void
   {
      clearInterval(this._intervalId);
      this.expired = true;
      this.status = param1;
      Network.getInstance().chatSystem.onTargetUserNotOnline.remove(this.onTargetUserNotOnline);
      TradeSystem.getInstance().onTradeRequestResponse.remove(this.onTradeRequestResponse);
      TradeSystem.getInstance().onCancelTradeRequests.remove(this.expire);
      this.onExpiration.dispatch();
   }
   
   private function onTradeRequestResponse(param1:String, param2:Boolean, param3:int) : void
   {
      if(param1 == this._nickName)
      {
         this.expire(param2 ? STATUS_ACCEPED : (param3 == TradeSystem.CANCEL_REQUEST_CANCELED ? STATUS_EXPIRED : STATUS_REJECTED));
      }
      else if(param2)
      {
         this.expire(STATUS_REJECTED);
      }
   }
   
   private function onTargetUserNotOnline(param1:String) : void
   {
      if(param1 == this._nickName)
      {
         this.expire();
      }
   }
   
   public function get messageDisplayType() : String
   {
      return UIChatMessageList.MESSAGE_TYPE_TRADE;
   }
   
   public function get display() : IChatMessageDisplay
   {
      return this._display;
   }
   
   public function set display(param1:IChatMessageDisplay) : void
   {
      this._display = param1;
   }
   
   public function get message() : String
   {
      return this._msg;
   }
   
   public function set message(param1:String) : void
   {
      this._msg = param1;
   }
   
   public function get linkData() : Array
   {
      return this._linkData;
   }
   
   public function set linkData(param1:Array) : void
   {
      this._linkData = param1;
   }
   
   public function get alternate() : Boolean
   {
      return this._alternate;
   }
   
   public function set alternate(param1:Boolean) : void
   {
      this._alternate = param1;
   }
   
   public function get offset() : uint
   {
      return this._offset;
   }
   
   public function set offset(param1:uint) : void
   {
      this._offset = param1;
   }
   
   public function get rows() : uint
   {
      return this._rows;
   }
   
   public function set rows(param1:uint) : void
   {
      this._rows = param1;
   }
   
   public function get nickName() : String
   {
      return this._nickName;
   }
   
   public function get messageData() : ChatMessageData
   {
      return this._cmd;
   }
   
   public function dispose() : void
   {
      this.display = null;
      clearInterval(this._intervalId);
      this.onExpiration.removeAll();
      Network.getInstance().chatSystem.onTargetUserNotOnline.remove(this.onTargetUserNotOnline);
      TradeSystem.getInstance().onTradeRequestResponse.remove(this.onTradeRequestResponse);
      TradeSystem.getInstance().onCancelTradeRequests.remove(this.expire);
   }
}
