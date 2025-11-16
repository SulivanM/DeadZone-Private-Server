package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.chat.components.IChatMessageDisplayData;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatUserData;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class ChatCommentReportDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var mc_container:Sprite;
      
      private var btn_ok:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var txt_desc:BodyTextField;
      
      private var txt_comment:BodyTextField;
      
      private var txt_reasonLabel:BodyTextField;
      
      private var txt_disclaimer:BodyTextField;
      
      private var ui_input:UIInputField;
      
      private var targetUserData:ChatUserData;
      
      private var messageData:IChatMessageDisplayData;
      
      private var channel:String;
      
      private var extraInfo:String;
      
      public var allowBlank:Boolean = false;
      
      public function ChatCommentReportDialogue(param1:ChatUserData, param2:IChatMessageDisplayData, param3:String, param4:String = "")
      {
         var _loc5_:Language = null;
         _loc5_ = Language.getInstance();
         this.targetUserData = param1;
         this.messageData = param2;
         this.channel = param3;
         this.extraInfo = param4;
         this.mc_container = new Sprite();
         super("chat-report",this.mc_container,true);
         _autoSize = false;
         _width = 460;
         this._lang = Language.getInstance();
         addTitle(_loc5_.getString("chat.report_dlg_title",param1.nickName));
         var _loc6_:int = _padding * 0.5;
         var _loc7_:TextField = new TextField();
         _loc7_.htmlText = param2.message;
         var _loc8_:String = _loc7_.text;
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_desc.htmlText = _loc5_.getString("chat.report_dlg_desc",param1.nickName);
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.txt_desc.x = 1;
         this.txt_desc.y = _loc6_ + 1;
         this.txt_desc.width = int(_width - this.txt_desc.x - _padding * 2);
         this.mc_container.addChild(this.txt_desc);
         this.txt_comment = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_comment.text = _loc8_;
         this.txt_comment.filters = [Effects.TEXT_SHADOW];
         this.txt_comment.x = this.txt_desc.x;
         this.txt_comment.y = int(this.txt_desc.y + this.txt_desc.height + 6);
         this.txt_comment.width = this.txt_desc.width;
         this.mc_container.addChild(this.txt_comment);
         this.txt_reasonLabel = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_reasonLabel.htmlText = _loc5_.getString("chat.report_dlg_reason");
         this.txt_reasonLabel.filters = [Effects.TEXT_SHADOW];
         this.txt_reasonLabel.x = this.txt_desc.x;
         this.txt_reasonLabel.y = int(this.txt_comment.y + this.txt_comment.height + 6);
         this.txt_reasonLabel.width = this.txt_desc.width;
         this.mc_container.addChild(this.txt_reasonLabel);
         this.ui_input = new UIInputField({
            "color":16777215,
            "size":16,
            "align":TextFormatAlign.LEFT,
            "font":Language.getInstance().getFontName("body")
         });
         this.ui_input.textField.addEventListener(Event.CHANGE,this.onNameChanged,false,0,true);
         this.ui_input.textField.maxChars = 256;
         this.ui_input.value = "";
         this.ui_input.width = int(this.txt_desc.width - 4);
         this.ui_input.height = 28;
         this.ui_input.x = int(this.txt_desc.x + 2);
         this.ui_input.y = int(this.txt_reasonLabel.y + this.txt_reasonLabel.height + 6);
         this.mc_container.addChild(this.ui_input);
         this.txt_disclaimer = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_disclaimer.htmlText = _loc5_.getString("chat.report_dlg_disclaimer");
         this.txt_disclaimer.filters = [Effects.TEXT_SHADOW];
         this.txt_disclaimer.x = this.txt_desc.x;
         this.txt_disclaimer.y = int(this.ui_input.y + this.ui_input.height + 6);
         this.txt_disclaimer.width = this.txt_desc.width;
         this.mc_container.addChild(this.txt_disclaimer);
         this.btn_ok = new PushButton(_loc5_.getString("chat.report_dlg_btn_report"));
         this.btn_ok.backgroundColor = Effects.BUTTON_WARNING_RED;
         this.btn_ok.clicked.add(this.onButtonClick);
         this.btn_ok.width = 120;
         this.btn_ok.x = int(this.ui_input.x + this.ui_input.width - this.btn_ok.width - 2);
         this.btn_ok.y = int(this.txt_disclaimer.y + this.txt_disclaimer.height + 10);
         this.mc_container.addChild(this.btn_ok);
         this.btn_cancel = new PushButton(_loc5_.getString("chat.report_dlg_btn_cancel"));
         this.btn_cancel.clicked.add(this.onButtonClick);
         this.btn_cancel.width = this.btn_cancel.width;
         this.btn_cancel.x = int(this.btn_ok.x - this.btn_ok.width - 10);
         this.btn_cancel.y = this.btn_ok.y;
         this.mc_container.addChild(this.btn_cancel);
         _height = this.btn_ok.y + this.btn_ok.height + 36;
         this.onNameChanged();
         opened.addOnce(this.OnOpened);
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         super.dispose();
         this.btn_cancel.dispose();
         this.txt_desc.dispose();
         this.txt_comment.dispose();
         this.txt_reasonLabel.dispose();
         this.txt_disclaimer.dispose();
         this.btn_ok.dispose();
      }
      
      private function submitReport() : void
      {
         var _loc1_:String = this.messageData.message + "\n\n" + this.extraInfo;
         Network.getInstance().chatSystem.sendReport(this.channel,this.targetUserData.nickName,this.targetUserData.userId,this.messageData.messageData.uniqueId,_loc1_,this.ui_input.value);
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("chat.report_dlg_submitted"),"reported-msg",true);
         _loc2_.open();
      }
      
      private function OnOpened(param1:Dialogue) : void
      {
         this.mc_container.stage.focus = this.ui_input.textField;
      }
      
      private function onNameChanged(param1:Event = null) : void
      {
         this.btn_ok.enabled = this.ui_input.value.replace(/\s*/ig,"").length > 0;
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_cancel:
               close();
               break;
            case this.btn_ok:
               this.submitReport();
               close();
         }
      }
      
      public function get input() : UIInputField
      {
         return this.ui_input;
      }
   }
}

