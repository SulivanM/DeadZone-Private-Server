package thelaststand.app.game.gui.chat.components
{
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.alliance.AllianceLifetimeStats;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.gui.chat.events.ChatOptionsMenuEvent;
   import thelaststand.app.game.gui.chat.events.ChatUserMenuEvent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatSystem;
   
   public class UIChatTextEntry extends Sprite
   {
      
      public static const MESSAGE_WIDTH:int = 456;
      
      private static const REPLY_REG_EXP:RegExp = /^\/r /;
      
      private var _chatSystem:ChatSystem;
      
      private var txt_input:TextField;
      
      private var _selectionStart:int = 0;
      
      private var _selectionEnd:int = 0;
      
      private var _messageItemList:Array;
      
      private var _currentChannel:String;
      
      private var _enabled:Boolean = true;
      
      private var _width:Number = 100;
      
      private var _height:Number = 26;
      
      private var btn_icon:ChatIconButton;
      
      private var _optionsPopup:UIChatOptionsPopupMenu;
      
      private var aLinkExtract:RegExp = /\[<a.+?href="event:(.*?):([\w\s\-\.'"%:\(\)&#!\*]+)".*?>.*?<\/a>\]/ig;
      
      private var linkCodeRegExp:RegExp = /\[link:(.*?):([\w\s\-\.'"%:\(\)&#!\*]+)\]/ig;
      
      private var adminLinkRegExp:RegExp = /<(.*?)>/ig;
      
      private var _stage:Stage;
      
      public function UIChatTextEntry(param1:ChatSystem)
      {
         super();
         this._chatSystem = param1;
         this._chatSystem.onChatStatusChange.add(this.onChatStatusChange);
         this._optionsPopup = new UIChatOptionsPopupMenu(this);
         this.btn_icon = new ChatIconButton();
         this.btn_icon.clicked.add(this.showOptionsPopup);
         var _loc2_:TextFormat = new TextFormat("_sans",13,16777215);
         _loc2_.leading = 2;
         this.txt_input = new TextField();
         this.txt_input.defaultTextFormat = _loc2_;
         this.txt_input.multiline = this.txt_input.wordWrap = false;
         this.txt_input.selectable = true;
         this.txt_input.type = TextFieldType.INPUT;
         this.txt_input.border = false;
         this.txt_input.x = this.btn_icon.x + this.btn_icon.width + 2;
         this.txt_input.y = 3;
         this.txt_input.width = this.width - this.txt_input.x - 2;
         this.txt_input.height = this.height - this.txt_input.y * 2;
         addChild(this.txt_input);
         this.txt_input.addEventListener(TextEvent.LINK,this.onLink,false,0,true);
         this.txt_input.maxChars = Config.constant.CHAT_MESSAGE_MAX_LENGTH;
         this.txt_input.restrict = "^<>[]";
         if(Network.getInstance().playerData.isAdmin)
         {
            this.txt_input.restrict = "^[]";
         }
         this.txt_input.text = "";
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         focusRect = false;
         addEventListener(FocusEvent.FOCUS_IN,this.onPanelFocus,false,0,true);
         this.txt_input.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn,false,0,true);
         this.txt_input.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut,false,0,true);
         this.txt_input.addEventListener(Event.CHANGE,this.onTextChange,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         this.updateEnabledState();
         this.setSize(this._width,this._height);
         addChild(this.btn_icon);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._chatSystem.onChatStatusChange.remove(this.onChatStatusChange);
         this._chatSystem = null;
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(FocusEvent.FOCUS_IN,this.onPanelFocus);
         this.txt_input.removeEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
         this.txt_input.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         this.txt_input.removeEventListener(Event.CHANGE,this.onTextChange);
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this._optionsPopup.dispose();
         this._optionsPopup = null;
         this.btn_icon.dispose();
      }
      
      public function changeCurrentChannel(param1:String) : void
      {
         this._currentChannel = param1;
         this.clear();
         this.updateEnabledState();
      }
      
      public function clear() : void
      {
         this.txt_input.text = "";
         this._messageItemList = null;
         this.txt_input.maxChars = Config.constant.CHAT_MESSAGE_MAX_LENGTH;
      }
      
      public function addItemFromEvent(param1:ChatLinkEvent) : void
      {
         this.onAddToChat(param1);
      }
      
      public function parseChatLinkEvent(param1:ChatLinkEvent) : void
      {
         var _loc2_:int = 0;
         switch(param1.linkType)
         {
            case ChatLinkEvent.LT_PASTE:
               _loc2_ = this.txt_input.selectionBeginIndex + String(param1.data[0]).length;
               this.txt_input.replaceSelectedText(param1.data + " ");
               this.txt_input.setSelection(_loc2_,_loc2_);
         }
      }
      
      public function parseOptionsMenuClickEvent(param1:ChatOptionsMenuEvent) : void
      {
         if(!visible)
         {
            return;
         }
         switch(param1.command)
         {
            case ChatOptionsMenuEvent.CMD_INSERT_WAR_STATS:
               this.InsertWarStats();
               param1.stopImmediatePropagation();
         }
      }
      
      public function parseUserMenuClickEvent(param1:ChatUserMenuEvent) : void
      {
         var _loc2_:int = 0;
         switch(param1.command)
         {
            case ChatUserMenuEvent.CMD_PASTE:
               _loc2_ = this.txt_input.selectionBeginIndex + String(param1.data[0]).length;
               this.txt_input.replaceSelectedText(param1.data + " ");
               this.txt_input.setSelection(_loc2_,_loc2_);
               break;
            case ChatUserMenuEvent.CMD_MESSAGE:
               this.txt_input.text = "/w " + param1.data[0] + " ";
               this.txt_input.setSelection(this.txt_input.length,this.txt_input.length);
               break;
            case ChatUserMenuEvent.CMD_SILENCE:
               this.txt_input.text = "/silence " + param1.data[0] + " 5";
               this.txt_input.setSelection(this.txt_input.length,this.txt_input.length);
               break;
            case ChatUserMenuEvent.CMD_KICK:
               this.txt_input.text = "/kick " + param1.data[0] + " 5";
               this.txt_input.setSelection(this.txt_input.length,this.txt_input.length);
               break;
            case ChatUserMenuEvent.CMD_KICKSILENT:
               this.txt_input.text = "/ninjakick " + param1.data[0] + " 5";
               this.txt_input.setSelection(this.txt_input.length,this.txt_input.length);
               break;
            case ChatUserMenuEvent.CMD_TRADEBAN:
               this.txt_input.text = "/tradeban " + param1.data[0] + " 5";
               this.txt_input.setSelection(this.txt_input.length,this.txt_input.length);
               break;
            case ChatUserMenuEvent.CMD_STRIKE:
               this.txt_input.text = "/strike " + param1.data[0] + " 0";
               this.txt_input.setSelection(this.txt_input.length,this.txt_input.length);
         }
      }
      
      private function onPanelFocus(param1:FocusEvent) : void
      {
         if(Boolean(stage) && visible)
         {
            stage.focus = this.txt_input;
         }
      }
      
      private function onFocusIn(param1:FocusEvent) : void
      {
         this.txt_input.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,1,true);
         this.txt_input.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,1,true);
      }
      
      private function onFocusOut(param1:FocusEvent) : void
      {
         this.txt_input.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.txt_input.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = this.txt_input.caretIndex;
         switch(param1.keyCode)
         {
            case Keyboard.BACKSPACE:
               if(_loc2_ > 0 && this.txt_input.text.charAt(_loc2_ - 1) == "]")
               {
                  this._selectionStart = _loc2_;
                  this._selectionEnd = this.txt_input.text.lastIndexOf("[",_loc2_ - 1) + 1;
                  this.txt_input.setSelection(this._selectionStart,this._selectionEnd);
                  this.txt_input.replaceSelectedText("");
                  break;
               }
               this.adjustKeySelection(_loc2_ - 1,false,-1);
               this.invalidateTextField();
               break;
            case Keyboard.DELETE:
               if(this.txt_input.text.charAt(_loc2_) == "[")
               {
                  this._selectionStart = _loc2_;
                  this._selectionEnd = this.txt_input.text.indexOf("]",_loc2_);
                  this.txt_input.setSelection(this._selectionStart,this._selectionEnd);
                  this.txt_input.replaceSelectedText("");
               }
               break;
            case Keyboard.UP:
            case Keyboard.HOME:
               this.adjustKeySelection(0,param1.shiftKey,-1);
               this.invalidateTextField();
               break;
            case Keyboard.LEFT:
               _loc3_ = _loc2_ - 1;
               if(param1.ctrlKey)
               {
                  _loc3_ = this.txt_input.text.lastIndexOf(" ",_loc2_ - 2) + 1;
               }
               this.adjustKeySelection(_loc3_,param1.shiftKey,-1);
               this.invalidateTextField();
               break;
            case Keyboard.RIGHT:
               _loc3_ = _loc2_ + 1;
               if(param1.ctrlKey)
               {
                  _loc3_ = int(this.txt_input.text.indexOf(" ",_loc2_ + 2));
                  if(_loc3_ == -1)
                  {
                     _loc3_ = this.txt_input.text.length;
                  }
               }
               this.adjustKeySelection(_loc3_,param1.shiftKey,1);
               this.invalidateTextField();
               break;
            case Keyboard.DOWN:
            case Keyboard.END:
               this.adjustKeySelection(this.txt_input.text.length,param1.shiftKey,1);
               this.invalidateTextField();
               break;
            case Keyboard.ENTER:
               this.sendCurrentMessage();
         }
      }
      
      private function adjustKeySelection(param1:int, param2:Boolean, param3:int) : void
      {
         this._selectionEnd = this._selectionStart = param1;
         if(param2)
         {
            this._selectionStart = this.txt_input.caretIndex == this.txt_input.selectionEndIndex ? this.txt_input.selectionBeginIndex : this.txt_input.selectionEndIndex;
         }
         this.expandKeySelections(param3);
      }
      
      private function expandKeySelections(param1:int) : void
      {
         var _loc2_:* = this._selectionStart == this._selectionEnd;
         var _loc3_:String = this.txt_input.text;
         var _loc4_:String = _loc3_.charAt(this._selectionEnd);
         var _loc5_:String = _loc3_.charAt(this._selectionEnd - 1);
         var _loc6_:int = this._selectionEnd;
         var _loc7_:int = this._selectionStart;
         if(param1 > 0)
         {
            if(_loc5_ == "[")
            {
               this._selectionEnd = _loc3_.indexOf("]",this._selectionEnd) + 1;
               if(_loc2_)
               {
                  --this._selectionStart;
               }
            }
            else if(_loc4_ == "[" && _loc5_ == "]")
            {
               this._selectionEnd = _loc3_.indexOf("]",this._selectionEnd) + 1;
            }
            else if(_loc5_ == "]")
            {
               ++this._selectionEnd;
               if(_loc2_)
               {
                  this._selectionStart = this._selectionEnd;
               }
            }
         }
         else if(param1 < 0)
         {
            if(_loc5_ == "]" && _loc4_ == "[")
            {
               this._selectionEnd = _loc3_.lastIndexOf("[",this._selectionEnd - 1);
            }
            else if(_loc4_ == "]")
            {
               this._selectionEnd = _loc3_.lastIndexOf("[",this._selectionEnd);
               if(_loc2_)
               {
                  ++this._selectionStart;
               }
            }
            else if(_loc5_ == "]")
            {
               if(_loc2_)
               {
                  this._selectionEnd = _loc3_.lastIndexOf("[",this._selectionEnd - 1);
               }
            }
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this._selectionStart = this.txt_input.selectionBeginIndex;
         this._selectionEnd = this.txt_input.selectionEndIndex;
         _loc2_ = int(this.txt_input.text.indexOf("]",this._selectionStart));
         if(_loc2_ > -1)
         {
            _loc3_ = int(this.txt_input.text.lastIndexOf("[",_loc2_));
            if(_loc3_ <= this._selectionStart)
            {
               this._selectionStart = _loc3_;
               if(this._selectionEnd < this._selectionStart)
               {
                  this._selectionEnd = this._selectionStart;
               }
            }
         }
         _loc2_ = int(this.txt_input.text.lastIndexOf("[",this._selectionEnd));
         if(_loc2_ > -1)
         {
            _loc3_ = int(this.txt_input.text.indexOf("]",_loc2_));
            if(_loc3_ > -1)
            {
               _loc3_++;
            }
            if(_loc3_ > this._selectionEnd)
            {
               this._selectionEnd = _loc3_;
               if(this._selectionEnd < this._selectionStart)
               {
                  this._selectionStart = this._selectionEnd;
               }
            }
         }
         this.invalidateTextField();
      }
      
      private function invalidateTextField() : void
      {
         this.txt_input.addEventListener(Event.RENDER,this.onTextFieldRender,false,0,true);
         stage.invalidate();
      }
      
      private function onTextFieldRender(param1:Event) : void
      {
         this.txt_input.removeEventListener(Event.RENDER,this.onTextFieldRender);
         this.txt_input.setSelection(this._selectionStart,this._selectionEnd);
      }
      
      private function sendCurrentMessage() : void
      {
         var _loc5_:String = null;
         this.txt_input.maxChars = 0;
         if(this.txt_input.text == "")
         {
            return;
         }
         var _loc1_:Boolean = Network.getInstance().chatSystem.testTradeBan(false,this._currentChannel);
         this.txt_input.htmlText = this.txt_input.htmlText.replace(this.aLinkExtract,_loc1_ ? "[REDACTED]" : "[link:$1:$2]");
         var _loc2_:String = this.txt_input.text;
         var _loc3_:Array = [];
         this.linkCodeRegExp.lastIndex = 0;
         var _loc4_:Object = this.linkCodeRegExp.exec(_loc2_);
         while(_loc4_)
         {
            _loc5_ = JSON.stringify(this._messageItemList[int(_loc4_[1])]);
            _loc3_.push(_loc5_);
            _loc4_ = this.linkCodeRegExp.exec(_loc2_);
         }
         if(Network.getInstance().playerData.isAdmin)
         {
            _loc2_ = _loc2_.replace(this.adminLinkRegExp,"<a href=\'event:" + ChatLinkEvent.LT_HYPERLINK + ":$1\'>$1</a>");
         }
         this._chatSystem.sendMessage(_loc2_,_loc3_,this._currentChannel);
         this.clear();
      }
      
      private function onChatStatusChange(param1:String, param2:String) : void
      {
         if(param1 != this._currentChannel)
         {
            return;
         }
         this.updateEnabledState();
      }
      
      private function updateEnabledState() : void
      {
         var _loc1_:Boolean = false;
         _loc1_ = this._enabled && this._chatSystem.isConnected(this._currentChannel);
         mouseChildren = mouseEnabled = _loc1_;
         visible = _loc1_;
         if(visible && Boolean(stage))
         {
            stage.focus = this.txt_input;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(param1.target == this.txt_input || param1.target == this.btn_icon)
         {
            return;
         }
         this.txt_input.setSelection(0,int.MAX_VALUE);
         stage.focus = this.txt_input;
      }
      
      private function onLink(param1:TextEvent) : void
      {
         param1.preventDefault();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._stage = stage;
         this._stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false,0,true);
         this._stage.addEventListener(ChatLinkEvent.ADD_TO_CHAT,this.onAddToChat,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         this._stage.removeEventListener(ChatLinkEvent.ADD_TO_CHAT,this.onAddToChat);
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case Keyboard.ENTER:
               if(stage && visible && !(stage.focus is TextField))
               {
                  stage.focus = this.txt_input;
               }
         }
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         this._width = param1;
         this._height = param2;
         graphics.clear();
         graphics.beginFill(0,0.2);
         graphics.drawRect(0,0,this._width,this._height);
         this.txt_input.width = this._width - this.txt_input.x - 2;
      }
      
      private function onAddToChat(param1:ChatLinkEvent) : void
      {
         if(!visible)
         {
            return;
         }
         var _loc2_:Object = JSON.parse(param1.data);
         this.insertItemLink(_loc2_.name,param1.linkType,_loc2_);
         param1.stopImmediatePropagation();
      }
      
      private function InsertWarStats() : void
      {
         AllianceSystem.getInstance().getLifetimeStats(function(param1:Boolean, param2:AllianceLifetimeStats):void
         {
            if(!param1 || param2 == null || enabled == false || !visible)
            {
               return;
            }
            insertItemLink(_chatSystem.userData.nickName + " - War Stats",ChatLinkEvent.LT_WARSTATS,param2);
         });
      }
      
      private function insertItemLink(param1:String, param2:String, param3:Object) : void
      {
         if(this.txt_input.text.length + param1.length + 2 > this.txt_input.maxChars)
         {
            return;
         }
         if(!this._messageItemList)
         {
            this._messageItemList = [];
         }
         var _loc4_:int = int(this._messageItemList.length);
         this._messageItemList.push(param3);
         this.txt_input.replaceSelectedText("[] ");
         var _loc5_:int = this.txt_input.text.length - this.txt_input.text.indexOf("[]") - 3;
         var _loc6_:String = _loc4_ + ":" + param2 + ":" + escape(param1);
         var _loc7_:String = this.txt_input.htmlText.replace("[]","[<a href=\'event:" + _loc6_ + "\'>" + param1 + "</a>]");
         this.txt_input.htmlText = _loc7_;
         this.txt_input.setSelection(this.txt_input.text.length - _loc5_,this.txt_input.text.length - _loc5_);
         stage.focus = this.txt_input;
      }
      
      private function onTextChange(param1:Event) : void
      {
         REPLY_REG_EXP.lastIndex = 0;
         if(this._chatSystem.lastPrivateMsgSender != "" && Boolean(this.txt_input.text.match(REPLY_REG_EXP)))
         {
            this.txt_input.text = this.txt_input.text.replace(REPLY_REG_EXP,"/w " + this._chatSystem.lastPrivateMsgSender + " ");
            this.txt_input.setSelection(this.txt_input.text.length,this.txt_input.text.length);
         }
      }
      
      private function showOptionsPopup(param1:MouseEvent) : void
      {
         this._optionsPopup.populate(this._currentChannel);
         this._optionsPopup.x = this.btn_icon.x;
         this._optionsPopup.y = this.btn_icon.y - this._optionsPopup.height;
         addChild(this._optionsPopup);
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
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         this.updateEnabledState();
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.events.MouseEvent;
import org.osflash.signals.natives.NativeSignal;
import thelaststand.app.gui.UIComponent;

class ChatIconButton extends UIComponent
{
   
   private var _bg:Shape;
   
   private var bmp_icon:Bitmap;
   
   private var _width:int = 26;
   
   private var _height:int = 26;
   
   public var mouseOver:NativeSignal;
   
   public var mouseDown:NativeSignal;
   
   public var mouseOut:NativeSignal;
   
   public var clicked:NativeSignal;
   
   public function ChatIconButton()
   {
      super();
      this._bg = new Shape();
      addChild(this._bg);
      this.bmp_icon = new Bitmap(new BmpIconChatBubble());
      addChild(this.bmp_icon);
      this.bmp_icon.alpha = 0.8;
      mouseEnabled = true;
      mouseChildren = false;
      this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
      this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
      this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
      this.mouseDown = new NativeSignal(this,MouseEvent.MOUSE_DOWN,MouseEvent);
      this.mouseOver.add(this.onMouseOver);
      this.mouseOut.add(this.onMouseOut);
      this.mouseDown.add(this.onMouseDown);
      TweenMax.to(this._bg,0,{"tint":0});
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
      super.dispose();
      this.bmp_icon.bitmapData.dispose();
      this.mouseOver.removeAll();
      this.mouseOut.removeAll();
      this.clicked.removeAll();
      this.mouseDown.removeAll();
   }
   
   override protected function draw() : void
   {
      super.draw();
      this._width = this._height = 26;
      this._bg.graphics.clear();
      this._bg.graphics.beginFill(16777215,1);
      this._bg.graphics.drawRect(0,0,this._width,this._height);
      this.bmp_icon.x = int((this._width - this.bmp_icon.width) / 2);
      this.bmp_icon.y = int((this._height - this.bmp_icon.height) / 2);
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this._bg,0,{
         "tint":3355443,
         "overwrite":true
      });
      TweenMax.to(this.bmp_icon,0,{
         "alpha":1,
         "overwrite":true
      });
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this._bg,0.25,{"tint":0});
      TweenMax.to(this.bmp_icon,0.25,{
         "alpha":0.8,
         "overwrite":true
      });
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      var e:MouseEvent = param1;
      TweenMax.to(this._bg,0,{
         "tint":10066329,
         "overwrite":true,
         "onComplete":function():void
         {
            TweenMax.to(_bg,0.25,{
               "tint":3355443,
               "overwrite":true
            });
         }
      });
   }
}
