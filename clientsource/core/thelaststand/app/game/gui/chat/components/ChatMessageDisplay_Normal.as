package thelaststand.app.game.gui.chat.components
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.network.chat.ChatMessageData;
   
   public class ChatMessageDisplay_Normal extends Sprite implements IChatMessageDisplay
   {
      
      private static var _styleSheet:StyleSheet;
      
      private var _bg:Shape;
      
      private var _label:TextField;
      
      private var _messageData:IChatMessageDisplayData;
      
      private var _rows:int;
      
      public function ChatMessageDisplay_Normal()
      {
         super();
         if(!_styleSheet)
         {
            _styleSheet = new StyleSheet();
            _styleSheet.parseCSS(Config.constant.CHAT_MESSAGE_DISPLAY_CSS);
         }
         this._bg = new Shape();
         this._bg.graphics.beginFill(5658198,0.4);
         this._bg.graphics.drawRect(0,0,400,UIChatMessageList.ROW_HEIGHT);
         this._bg.graphics.endFill();
         addChild(this._bg);
         var _loc1_:TextFormat = new TextFormat("_sans",12,16777215);
         _loc1_.leading = 2;
         this._label = new TextField();
         this._label.defaultTextFormat = _loc1_;
         this._label.multiline = this._label.wordWrap = true;
         this._label.selectable = true;
         this._label.styleSheet = _styleSheet;
         this._label.autoSize = TextFieldAutoSize.LEFT;
         this._label.mouseWheelEnabled = false;
         this._label.x = 4;
         this._label.y = -2;
         this._label.width = this._bg.width - this._label.x * 2;
         addChild(this._label);
         this._label.filters = [new GlowFilter(0,1,2,2,5)];
         this._label.addEventListener(TextEvent.LINK,this.onTextLink,false,0,true);
      }
      
      public static function generateDisplayDataObj(param1:ChatMessageData) : IChatMessageDisplayData
      {
         return new NormalMessageDisplayData(param1);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.populate(null);
         this._label.removeEventListener(TextEvent.LINK,this.onTextLink);
      }
      
      public function populate(param1:IChatMessageDisplayData) : void
      {
         if(this._messageData)
         {
            if(this._messageData.display == this)
            {
               this._messageData.display = null;
            }
         }
         this._messageData = param1;
         if(this._messageData)
         {
            this._messageData.display = this;
         }
         this._label.text = "";
         if(this._messageData)
         {
            this._label.htmlText = this._messageData.message;
         }
         this._rows = Math.ceil((this._label.height + this._label.y * 2) / UIChatMessageList.ROW_HEIGHT);
         this._bg.height = this._rows * UIChatMessageList.ROW_HEIGHT;
         if(this._messageData)
         {
            this._bg.visible = this._messageData.alternate;
         }
      }
      
      private function onTextLink(param1:TextEvent) : void
      {
         var _loc2_:Array = param1.text.split(":");
         var _loc3_:String = _loc2_.shift();
         var _loc4_:ChatLinkEvent = new ChatLinkEvent(ChatLinkEvent.LINK_CLICK,_loc3_);
         switch(_loc3_)
         {
            case ChatLinkEvent.LT_JOINBALANCED:
            case ChatLinkEvent.LT_JOIN:
               _loc4_.data = _loc2_;
               break;
            case ChatLinkEvent.LT_USERMENU:
               _loc4_.data = _loc2_;
               break;
            case ChatLinkEvent.LT_HYPERLINK:
               _loc4_.data = _loc2_.join(":");
               break;
            case "showChatTile":
               _loc4_.data = _loc2_[0];
               break;
            case ChatLinkEvent.LT_ALLIANCE_SHOW:
               _loc4_.data = _loc2_[0];
               break;
            case ChatLinkEvent.LT_PASTE:
               _loc4_.data = _loc2_[0];
               break;
            case ChatLinkEvent.LT_ITEM:
            default:
               _loc4_.data = this._messageData.linkData[int(_loc2_[0])];
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
         return this._bg.width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._bg.width = param1;
         this._label.width = this._bg.width - this._label.x * 2;
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
         return UIChatMessageList.MESSAGE_TYPE_NORMAL;
      }
   }
}

import thelaststand.app.data.PlayerData;
import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
import thelaststand.app.network.Network;
import thelaststand.app.network.chat.ChatMessageData;
import thelaststand.app.network.chat.ChatSystem;
import thelaststand.app.utils.StringUtils;

class NormalMessageDisplayData implements IChatMessageDisplayData
{
   
   private static var IncomingLinkRegExp:RegExp = /\[link:.*?:(.*?):(.*?)]/ig;
   
   private var _nickName:String;
   
   private var _cmd:ChatMessageData;
   
   private var _display:IChatMessageDisplay;
   
   private var _msg:String = "";
   
   private var _linkData:Array;
   
   private var _alternate:Boolean;
   
   private var _offset:uint = 0;
   
   private var _rows:uint = 1;
   
   public function NormalMessageDisplayData(param1:ChatMessageData)
   {
      var _loc16_:Object = null;
      var _loc17_:int = 0;
      var _loc18_:String = null;
      var _loc19_:* = null;
      var _loc20_:Object = null;
      var _loc21_:String = null;
      var _loc22_:* = null;
      super();
      this._cmd = param1;
      this._linkData = param1.linkData;
      this._nickName = param1.messageType == ChatSystem.MESSAGE_TYPE_ADMIN_PUBLIC ? param1.customNickName : param1.posterNickName;
      var _loc2_:String = this._nickName ? this._nickName : "";
      var _loc3_:String = "defaultOverall";
      var _loc4_:String = "defaultNickname";
      var _loc5_:String = "defaultBody";
      var _loc6_:PlayerData = Network.getInstance().playerData;
      if(_loc6_.id != param1.posterId && _loc6_.allianceId != null && _loc6_.allianceId == param1.posterAllianceId)
      {
         _loc3_ = "allianceOverall";
         _loc4_ = "allianceNickname";
         _loc5_ = "allianceBody";
      }
      if(param1.posterIsAdmin)
      {
         _loc3_ = "adminOverall";
         _loc4_ = "adminNickname";
         _loc5_ = "adminBody";
      }
      switch(param1.messageType)
      {
         case ChatSystem.MESSAGE_TYPE_PRIVATE:
         case ChatSystem.MESSAGE_TYPE_ADMIN_PRIVATE:
            _loc3_ = "privateOverall";
            if(param1.posterId == _loc6_.id)
            {
               _loc3_ = "privateOutgoingOverall";
            }
            _loc4_ = "privateNickname";
            _loc5_ = "privateBody";
            break;
         case ChatSystem.MESSAGE_TYPE_SYSTEM:
            _loc3_ = "systemNormOverall";
            _loc4_ = "systemNormNickname";
            _loc5_ = "systemNormBody";
            if(_loc2_ == ChatSystem.USER_NAME_BAN)
            {
               _loc3_ = "systemBanOverall";
               _loc4_ = "systemBanNickname";
               _loc5_ = "systemBanBody";
               break;
            }
            if(_loc2_ == ChatSystem.USER_NAME_WARNING || _loc2_ == ChatSystem.USER_NAME_WARNING_PERSONAL)
            {
               _loc3_ = "systemWarnOverall";
               _loc4_ = "systemWarnNickname";
               _loc5_ = "systemWarnBody";
               break;
            }
            if(_loc2_ == ChatSystem.USER_NAME_ERROR)
            {
               _loc3_ = "systemErrorOverall";
               _loc4_ = "systemErrorNickname";
               _loc5_ = "systemErrorBody";
            }
            break;
         case ChatSystem.MESSAGE_TYPE_ALLIANCE_FEEDBACK:
         case ChatSystem.MESSAGE_TYPE_ALLIANCE_INVITE:
            _loc3_ = "allianceFeedbackOverall";
            _loc4_ = "allianceFeedbackNickname";
            _loc5_ = "allianceFeedbackBody";
            break;
         case ChatSystem.MESSAGE_TYPE_WARNING:
            _loc3_ = "systemWarnOverall";
            _loc4_ = "systemWarnNickname";
            _loc5_ = "systemWarnBody";
            break;
         case ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK:
            _loc3_ = "systemNormOverall";
            _loc4_ = "systemNormNickname";
            _loc5_ = "systemNormBody";
            if(_loc2_ == ChatSystem.USER_TRADE_IN)
            {
               _loc3_ = "tradeInOverall";
            }
            else if(_loc2_ == ChatSystem.USER_TRADE_OUT)
            {
               _loc3_ = "tradeOutOverall";
            }
            else if(_loc2_ == ChatSystem.USER_TRADE_USERLEFT)
            {
               _loc3_ = "tradeUserLeftOverall";
            }
            _loc2_ = "";
      }
      var _loc7_:* = param1.message;
      if(Boolean(this._linkData) && this._linkData.length > 0)
      {
         IncomingLinkRegExp.lastIndex = 0;
         _loc16_ = IncomingLinkRegExp.exec(_loc7_);
         _loc17_ = 0;
         while(_loc16_)
         {
            _loc18_ = "defaultLink";
            try
            {
               _loc20_ = JSON.parse(this._linkData[_loc17_]);
               if(_loc20_.hasOwnProperty("linkClass"))
               {
                  _loc18_ = _loc20_.linkClass;
               }
            }
            catch(e:Error)
            {
            }
            _loc19_ = "<a href=\'event:" + _loc16_[1] + ":" + _loc17_ + "\' class=\'" + _loc18_ + "\'>[" + unescape(_loc16_[2]) + "]</a>";
            _loc7_ = _loc7_.replace(_loc16_[0],_loc19_);
            _loc17_++;
            IncomingLinkRegExp.lastIndex = _loc16_.index + 1;
            _loc16_ = IncomingLinkRegExp.exec(_loc7_);
         }
      }
      var _loc8_:* = "";
      var _loc9_:String = "";
      var _loc10_:* = "";
      var _loc11_:String = "";
      if(param1.customNameColor != "")
      {
         _loc8_ = "<font color=\'" + param1.customNameColor + "\'/>";
         _loc9_ = "</font>";
      }
      if(param1.customMsgColor != "")
      {
         _loc10_ = "<font color=\'" + param1.customMsgColor + "\'/>";
         _loc11_ = "</font>";
      }
      var _loc12_:* = "";
      var _loc13_:String = _loc2_;
      if(_loc2_.length > 0)
      {
         if(Boolean(param1.posterAllianceTag) && Boolean(param1.posterAllianceId))
         {
            _loc12_ = " [<a href=\'event:" + ChatLinkEvent.LT_ALLIANCE_SHOW + ":" + param1.posterAllianceId + "\' class=\'messagealliance\'>" + param1.posterAllianceTag + "</a>]: ";
         }
         else
         {
            _loc12_ = ": ";
         }
      }
      var _loc14_:String = ChatLinkEvent.LT_USERMENU;
      var _loc15_:* = "";
      if(param1.messageType == ChatSystem.MESSAGE_TYPE_PRIVATE)
      {
         _loc21_ = "";
         _loc22_ = "";
         if(_loc13_ != "")
         {
            if(_loc13_ == Network.getInstance().chatSystem.userData.nickName)
            {
               _loc21_ = "To " + param1.toNickName;
               _loc22_ = param1.toNickName + ":0";
               _loc12_ = ": ";
            }
            else
            {
               _loc21_ = "From " + _loc2_;
               _loc22_ = _loc2_ + ":" + this._cmd.uniqueId;
            }
            _loc15_ = "<span class=\'" + _loc4_ + "\'/><a href=\'event:" + _loc14_ + ":" + _loc22_ + "\' class=\'messageNickName\'>" + _loc21_ + "</a>" + _loc12_ + "</span>";
         }
      }
      else if(param1.posterId)
      {
         if(_loc13_ == Network.getInstance().chatSystem.userData.nickName)
         {
            _loc14_ = ChatLinkEvent.LT_PASTE;
         }
         _loc15_ = "<span class=\'" + _loc4_ + "\'/><a href=\'event:" + _loc14_ + ":" + _loc2_ + ":" + this._cmd.uniqueId + "\' class=\'messageNickName\'>" + _loc8_ + _loc2_ + _loc9_ + "</a>" + _loc8_ + _loc12_ + _loc9_ + "</span>";
      }
      else
      {
         if(_loc13_ == Network.getInstance().chatSystem.userData.nickName)
         {
            _loc14_ = ChatLinkEvent.LT_PASTE;
         }
         _loc15_ = "<span class=\'" + _loc4_ + "\'/>" + _loc9_ + _loc2_ + _loc12_ + _loc9_ + "</span>";
      }
      if(!param1.posterIsAdmin && (param1.messageType == ChatSystem.MESSAGE_TYPE_PUBLIC || param1.messageType == ChatSystem.MESSAGE_TYPE_PRIVATE))
      {
         _loc7_ = Network.getInstance().chatSystem.badwords.cleanString(_loc7_);
      }
      _loc7_ = "<span class=\'" + _loc3_ + "\'>" + _loc15_ + "<span class=\'" + _loc5_ + "\'>" + _loc10_ + _loc7_ + _loc11_ + "</span></span>";
      _loc7_ = _loc7_.replace("%nickname",Network.getInstance().playerData.nickname);
      this._msg = StringUtils.htmlSetDoubleBreakLeading(_loc7_);
   }
   
   public function get messageDisplayType() : String
   {
      return UIChatMessageList.MESSAGE_TYPE_NORMAL;
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
   }
}
