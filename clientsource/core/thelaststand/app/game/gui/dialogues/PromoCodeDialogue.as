package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class PromoCodeDialogue extends BaseDialogue
   {
      
      private var _numFields:int = 4;
      
      private var _charsPerField:int = 4;
      
      private var _fields:Vector.<UIInputField>;
      
      private var _code:String = "";
      
      private var mc_container:Sprite;
      
      private var btn_redeem:PushButton;
      
      private var txt_desc:BodyTextField;
      
      private var txt_pasteField:TextField;
      
      public function PromoCodeDialogue()
      {
         var _loc4_:UIInputField = null;
         this._fields = new Vector.<UIInputField>();
         this.mc_container = new Sprite();
         super("redeemcode",this.mc_container,true);
         _autoSize = false;
         _width = 274;
         _height = 142;
         addTitle(Language.getInstance().getString("promocode_title"),BaseDialogue.TITLE_COLOR_BUY);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this.btn_redeem = PushButton(addButton(Language.getInstance().getString("promocode_ok"),false));
         this.btn_redeem.width = 140;
         this.btn_redeem.enabled = false;
         this.btn_redeem.clicked.add(this.onClickRedeem);
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_desc.text = Language.getInstance().getString("promocode_msg");
         this.txt_desc.x = int((_width - _padding * 2 - this.txt_desc.width) * 0.5);
         this.txt_desc.y = int(_padding * 0.25);
         this.mc_container.addChild(this.txt_desc);
         var _loc1_:int = 0;
         var _loc2_:int = int(this.txt_desc.y + this.txt_desc.height + 6);
         var _loc3_:int = 0;
         while(_loc3_ < this._numFields)
         {
            _loc4_ = new UIInputField({"align":"center"});
            _loc4_.textField.addEventListener(Event.CHANGE,this.onInputChanged,false,0,true);
            _loc4_.textField.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress,false,0,true);
            _loc4_.textField.restrict = "a-zA-Z0-9";
            _loc4_.textField.maxChars = this._charsPerField;
            _loc4_.textField.text = "";
            _loc4_.backgroundColor = 2434341;
            _loc4_.width = 54;
            _loc4_.height = 34;
            _loc4_.x = _loc1_;
            _loc4_.y = _loc2_;
            this.mc_container.addChild(_loc4_);
            _loc1_ += int(_loc4_.width + 10);
            this._fields.push(_loc4_);
            _loc3_++;
         }
         this.txt_pasteField = new TextField();
         this.txt_pasteField.addEventListener(Event.CHANGE,this.onPasteFieldChanged,false,0,true);
         this.txt_pasteField.width = this.txt_pasteField.height = 10;
         this.txt_pasteField.visible = false;
         this.txt_pasteField.type = TextFieldType.INPUT;
         this.mc_container.addChild(this.txt_pasteField);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.updateCode();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIInputField = null;
         super.dispose();
         this.btn_redeem = null;
         this.txt_desc.dispose();
         for each(_loc1_ in this._fields)
         {
            _loc1_.dispose();
         }
      }
      
      private function handlePaste(param1:String) : void
      {
         var _loc4_:TextField = null;
         var _loc2_:String = param1.replace(/-/ig,"").toUpperCase();
         var _loc3_:int = 0;
         while(_loc3_ < this._numFields)
         {
            _loc4_ = this._fields[_loc3_].textField;
            _loc4_.text = _loc2_.substr(_loc3_ * this._charsPerField,4);
            _loc3_++;
         }
         this.updateCode();
      }
      
      private function updateCode() : void
      {
         this._code = "";
         var _loc1_:int = 0;
         while(_loc1_ < this._fields.length)
         {
            this._code += this._fields[_loc1_].textField.text.toUpperCase();
            _loc1_++;
         }
         this.btn_redeem.enabled = this._code.length == this._numFields * this._charsPerField;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.mc_container.stage.focus = this._fields[0].textField;
      }
      
      private function onInputChanged(param1:Event) : void
      {
         var _loc2_:UIInputField = UIInputField(param1.currentTarget.parent);
         var _loc3_:int = int(this._fields.indexOf(_loc2_));
         _loc2_.textField.text = _loc2_.textField.text.toUpperCase();
         if(_loc3_ < this._numFields - 1)
         {
            if(_loc2_.textField.text.length >= this._charsPerField)
            {
               this.mc_container.stage.focus = this._fields[_loc3_ + 1].textField;
            }
         }
         this.updateCode();
      }
      
      private function onKeyPress(param1:KeyboardEvent) : void
      {
         var _loc4_:TextField = null;
         if(param1.keyCode == Keyboard.CONTROL)
         {
            this.mc_container.stage.focus = this.txt_pasteField;
            return;
         }
         var _loc2_:UIInputField = UIInputField(param1.currentTarget.parent);
         var _loc3_:int = int(this._fields.indexOf(_loc2_));
         if(param1.keyCode == Keyboard.TAB)
         {
            if(param1.shiftKey)
            {
               if(_loc3_ > 0)
               {
                  _loc4_ = this._fields[_loc3_ - 1].textField;
               }
            }
            else if(_loc3_ < this._numFields - 1)
            {
               _loc4_ = this._fields[_loc3_ + 1].textField;
            }
            this.mc_container.stage.focus = _loc4_;
            return;
         }
         if(_loc3_ > 0 && param1.keyCode == Keyboard.BACKSPACE)
         {
            if(_loc2_.textField.text.length == 0)
            {
               this.mc_container.stage.focus = this._fields[_loc3_ - 1].textField;
            }
         }
      }
      
      private function onPasteFieldChanged(param1:Event) : void
      {
         var _loc2_:String = this.txt_pasteField.text;
         this.txt_pasteField.text = "";
         this.handlePaste(_loc2_);
      }
      
      private function onClickRedeem(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.updateCode();
         PaymentSystem.getInstance().claimPromoCode(this._code,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
   }
}

