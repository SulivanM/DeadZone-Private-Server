package thelaststand.app.game.gui.dialogues
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.common.lang.Language;
   
   public class AllianceMessageCreateDialogue extends BaseDialogue
   {
      
      public var onSuccess:Signal = new Signal();
      
      private var _lang:Language;
      
      private var mc_container:Sprite = new Sprite();
      
      private var input_title:UIInputField;
      
      private var input_message:UIInputField;
      
      private var txt_count:BodyTextField;
      
      private var btn_continue:PushButton;
      
      private var btn_cancel:PushButton;
      
      public function AllianceMessageCreateDialogue()
      {
         super("alliance-messageCreate",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 430;
         _height = 215;
         addTitle(this._lang.getString("alliance.messages_create_windowTitle"),TITLE_COLOR_GREY);
         var _loc1_:int = _padding * 0.5;
         this.input_title = new UIInputField({
            "value":"Test",
            "color":16777215,
            "size":14,
            "font":Language.getInstance().getFontName("body"),
            "bold":true
         });
         this.input_title.y = 5;
         this.input_title.width = 400;
         this.input_title.textField.maxChars = 30;
         this.input_title.defaultValue = this._lang.getString("alliance.messages_create_titleLabel");
         this.mc_container.addChild(this.input_title);
         this.input_title.addEventListener(Event.CHANGE,this.validate);
         this.input_message = new UIInputField({
            "color":16777215,
            "size":14,
            "multiline":true,
            "wordWrap":true,
            "font":Language.getInstance().getFontName("body"),
            "bold":true
         });
         this.input_message.y = this.input_title.y + this.input_title.height + 8;
         this.input_message.width = this.input_title.width;
         this.input_message.height = 110;
         this.input_message.textField.maxChars = 260;
         this.input_message.defaultValue = this._lang.getString("alliance.messages_create_msgLabel");
         this.mc_container.addChild(this.input_message);
         this.input_message.addEventListener(Event.CHANGE,this.validate);
         this.input_title.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,0,true);
         this.input_message.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,0,true);
         this.txt_count = new BodyTextField({
            "color":16777215,
            "size":12,
            "multiline":false,
            "autoSize":"left",
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_count.x = int(this.input_message.x);
         this.txt_count.y = int(this.input_message.y + this.input_message.height + 2);
         this.mc_container.addChild(this.txt_count);
         this.btn_continue = new PushButton(this._lang.getString("alliance.messages_create_btnCreate"));
         this.btn_continue.backgroundColor = Effects.BUTTON_GREEN;
         this.btn_continue.clicked.add(this.onButtonClick);
         this.btn_continue.width = 120;
         this.btn_continue.x = int(this.input_message.x + this.input_message.width - this.btn_continue.width - 5);
         this.btn_continue.y = int(this.input_message.y + this.input_message.height + 10);
         this.mc_container.addChild(this.btn_continue);
         this.btn_cancel = new PushButton(this._lang.getString("alliance.messages_create_btnCancel"));
         this.btn_cancel.clicked.add(this.onButtonClick);
         this.btn_cancel.width = 120;
         this.btn_cancel.x = int(this.btn_continue.x - this.btn_cancel.width - 10);
         this.btn_cancel.y = this.btn_continue.y;
         this.mc_container.addChild(this.btn_cancel);
         this.validate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.btn_continue.dispose();
         this.btn_cancel.dispose();
         this.input_title.dispose();
         this.input_message.dispose();
         this.txt_count.dispose();
         this.input_title.removeEventListener(Event.CHANGE,this.validate);
         this.input_message.removeEventListener(Event.CHANGE,this.validate);
         this.input_title.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.input_message.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.onSuccess.removeAll();
      }
      
      private function validate(param1:Event = null) : void
      {
         this.btn_continue.enabled = this.input_message.value.replace(/[\s\r\n]*/ig,"") != "" && this.input_title.value.replace(/[\s\r\n]*/ig,"") != "";
         this.txt_count.text = this.input_message.value.length + "/" + this.input_message.textField.maxChars;
      }
      
      private function submit() : void
      {
         var busyDialogue:BusyDialogue = null;
         busyDialogue = new BusyDialogue(this._lang.getString("alliance.messages_create_busy"));
         busyDialogue.open();
         AllianceSystem.getInstance().postMessage(this.input_title.value,this.input_message.value,function(param1:RPCResponse):void
         {
            var _loc3_:MessageBox = null;
            busyDialogue.close();
            var _loc2_:Language = Language.getInstance();
            if(!param1.success)
            {
               _loc3_ = new MessageBox(_loc2_.getString("alliance.messages_create_errorMsg"),"messageError");
               _loc3_.addTitle(_loc2_.getString("alliance.messages_create_errorTitle"));
               _loc3_.addButton(_loc2_.getString("alliance.messages_create_errorOK"));
               _loc3_.open();
            }
            else
            {
               onSuccess.dispatch();
               close();
            }
         });
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.TAB)
         {
            if(param1.target == this.input_title.textField)
            {
               DisplayObject(param1.target).stage.focus = this.input_message.textField;
            }
            else
            {
               DisplayObject(param1.target).stage.focus = this.input_title.textField;
            }
         }
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_cancel:
               close();
               break;
            case this.btn_continue:
               this.submit();
         }
      }
   }
}

