package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormatAlign;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class GenericTextInputDialogue extends BaseDialogue
   {
      
      public var onSubmit:Signal;
      
      private var _lang:Language;
      
      private var mc_container:Sprite;
      
      private var btn_ok:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var txt_desc:BodyTextField;
      
      private var ui_input:UIInputField;
      
      public var allowBlank:Boolean = false;
      
      public function GenericTextInputDialogue(param1:String, param2:String, param3:String = "", param4:String = "", param5:String = "")
      {
         var _loc6_:Language = null;
         var _loc7_:int = 0;
         _loc6_ = Language.getInstance();
         this.onSubmit = new Signal(String);
         this.mc_container = new Sprite();
         super("generic-textinput",this.mc_container,true);
         _autoSize = false;
         _width = 340;
         this._lang = Language.getInstance();
         addTitle(param1);
         _loc7_ = _padding * 0.5;
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_desc.htmlText = StringUtils.htmlSetDoubleBreakLeading(param2);
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.txt_desc.x = 1;
         this.txt_desc.y = _loc7_ + 1;
         this.txt_desc.width = int(_width - this.txt_desc.x - _padding * 2);
         this.mc_container.addChild(this.txt_desc);
         this.ui_input = new UIInputField({
            "color":16777215,
            "size":20,
            "align":TextFormatAlign.LEFT
         });
         this.ui_input.textField.addEventListener(Event.CHANGE,this.onNameChanged,false,0,true);
         this.ui_input.textField.restrict = "a-zA-Z0-9 ";
         this.ui_input.textField.maxChars = 22;
         this.ui_input.value = param3;
         this.ui_input.width = int(this.txt_desc.width - 4);
         this.ui_input.height = 34;
         this.ui_input.x = int(this.txt_desc.x + 2);
         this.ui_input.y = int(this.txt_desc.y + this.txt_desc.height + 6);
         this.mc_container.addChild(this.ui_input);
         if(param4 == "")
         {
            param4 = _loc6_.getString("generic_dialogue_ok");
         }
         this.btn_ok = new PushButton(param4);
         this.btn_ok.backgroundColor = Effects.BUTTON_GREEN;
         this.btn_ok.clicked.add(this.onButtonClick);
         this.btn_ok.width = 120;
         this.btn_ok.x = int(this.ui_input.x + this.ui_input.width - this.btn_ok.width - 2);
         this.btn_ok.y = int(this.ui_input.y + this.ui_input.height + 10);
         this.mc_container.addChild(this.btn_ok);
         if(param5 == "")
         {
            param5 = _loc6_.getString("generic_dialogue_cancel");
         }
         this.btn_cancel = new PushButton(param5);
         this.btn_cancel.clicked.add(this.onButtonClick);
         this.btn_cancel.width = this.btn_cancel.width;
         this.btn_cancel.x = int(this.btn_ok.x - this.btn_ok.width - 10);
         this.btn_cancel.y = this.btn_ok.y;
         this.mc_container.addChild(this.btn_cancel);
         _height = this.btn_ok.y + this.btn_ok.height + 36;
         this.onNameChanged();
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         super.dispose();
         this.btn_cancel.dispose();
         this.txt_desc.dispose();
         this.btn_ok.dispose();
         this.onSubmit.removeAll();
      }
      
      private function onNameChanged(param1:Event = null) : void
      {
         this.btn_ok.enabled = this.allowBlank == true || this.ui_input.value.replace(/\s*/ig,"").length > 0;
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_cancel:
               close();
               break;
            case this.btn_ok:
               this.onSubmit.dispatch(this.ui_input.value);
         }
      }
      
      public function get input() : UIInputField
      {
         return this.ui_input;
      }
   }
}

