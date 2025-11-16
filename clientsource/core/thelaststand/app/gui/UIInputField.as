package thelaststand.app.gui
{
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import flash.ui.MouseCursor;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BasicTextField;
   import thelaststand.app.display.TitleTextField;
   
   public class UIInputField extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _defaultValue:String = "";
      
      private var _value:String = "";
      
      private var _backgroundColor:uint = 0;
      
      private var txt_input:TitleTextField;
      
      public var enterPressed:Signal;
      
      public function UIInputField(param1:Object = null)
      {
         super();
         param1 ||= {};
         param1.text = " ";
         param1.type = TextFieldType.INPUT;
         param1.mouseEnabled = param1.selectable = true;
         param1.autoSize = "none";
         if(!param1.hasOwnProperty("color"))
         {
            param1.color = 16777215;
         }
         if(!param1.hasOwnProperty("size"))
         {
            param1.size = 22;
         }
         if(!param1.hasOwnProperty("antiAliasType"))
         {
            param1.antiAliasType = AntiAliasType.ADVANCED;
         }
         this.enterPressed = new Signal();
         this.txt_input = new TitleTextField(param1);
         this.txt_input.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this.txt_input.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         this.txt_input.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn,false,0,true);
         this.txt_input.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut,false,0,true);
         this.txt_input.addEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease,false,0,true);
         this.txt_input.addEventListener(Event.CHANGE,this.onChange,false,0,true);
         BasicTextField.setFieldSelectionColor(this.txt_input,16777215);
         addChild(this.txt_input);
         this.txt_input.x = 3;
         this._height = this.txt_input.height + 6;
         redraw();
      }
      
      public function get backgroundColor() : uint
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         this._backgroundColor = param1;
         invalidate();
      }
      
      public function get defaultValue() : String
      {
         return this._defaultValue;
      }
      
      public function set defaultValue(param1:String) : void
      {
         this._defaultValue = param1;
         this.txt_input.text = this._value || this._defaultValue || "";
      }
      
      public function get value() : String
      {
         return this._value;
      }
      
      public function set value(param1:String) : void
      {
         this._value = param1;
         this.txt_input.text = this._value || this._defaultValue || "";
      }
      
      public function get textField() : BasicTextField
      {
         return this.txt_input;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.enterPressed.removeAll();
         this.txt_input.dispose();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         graphics.beginFill(7171437);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(this._backgroundColor);
         graphics.drawRect(1,1,this._width - 2,this._height - 2);
         graphics.endFill();
         if(this.txt_input.multiline)
         {
            this.txt_input.y = this.txt_input.x;
            this.txt_input.height = int(this._height - this.txt_input.y * 2);
         }
         else
         {
            this.txt_input.y = int((this._height - this.txt_input.height) * 0.5 - 1);
         }
         this.txt_input.width = int(this._width - this.txt_input.x * 2);
      }
      
      private function onFocusIn(param1:FocusEvent) : void
      {
         if(this.txt_input.text == this._defaultValue)
         {
            this.txt_input.text = "";
         }
      }
      
      private function onFocusOut(param1:FocusEvent) : void
      {
         if(this.txt_input.text == "")
         {
            this.txt_input.text = this._defaultValue || "";
         }
      }
      
      private function onKeyRelease(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.enterPressed.dispatch();
         }
      }
      
      private function onChange(param1:Event) : void
      {
         this._value = this.txt_input.text;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         MouseCursors.setCursor(MouseCursor.IBEAM);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         MouseCursors.setCursor(MouseCursors.DEFAULT);
      }
   }
}

