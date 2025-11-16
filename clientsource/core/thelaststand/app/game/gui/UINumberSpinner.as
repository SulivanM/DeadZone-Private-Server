package thelaststand.app.game.gui
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldType;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.utils.GraphicUtils;
   
   public class UINumberSpinner extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _padding:int = 8;
      
      private var _value:Number = 0;
      
      private var _minValue:Number = 0;
      
      private var _maxValue:Number = 10;
      
      private var _step:Number = 1;
      
      private var _precision:Number = 0;
      
      private var _spinDir:int = 0;
      
      private var _timer:Timer;
      
      private var txt_value:BodyTextField;
      
      private var btn_increase:PushButton;
      
      private var btn_decrease:PushButton;
      
      public var changed:Signal = new Signal(UINumberSpinner);
      
      public function UINumberSpinner()
      {
         super();
         this.txt_value = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":17,
            "bold":true,
            "autoSize":"none",
            "align":"center",
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_value.addEventListener(FocusEvent.FOCUS_IN,this.onValueFocusIn,false,0,true);
         this.txt_value.addEventListener(FocusEvent.FOCUS_OUT,this.onValueFocusOut,false,0,true);
         this.txt_value.type = TextFieldType.INPUT;
         this.txt_value.selectable = true;
         this.txt_value.mouseEnabled = true;
         addChild(this.txt_value);
         this.btn_decrease = new PushButton("",new BmpIconButtonPrev());
         this.btn_decrease.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonMouseDown,false,0,true);
         this.btn_decrease.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         addChild(this.btn_decrease);
         this.btn_increase = new PushButton("",new BmpIconButtonNext());
         this.btn_increase.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonMouseDown,false,0,true);
         this.btn_increase.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         addChild(this.btn_increase);
         this._height = int(this.btn_decrease.height + 4);
         this._timer = new Timer(1000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
      }
      
      public function get minValue() : Number
      {
         return this._minValue;
      }
      
      public function set minValue(param1:Number) : void
      {
         if(param1 == this._minValue)
         {
            return;
         }
         if(param1 > this._maxValue)
         {
            param1 = this._maxValue;
         }
         this._minValue = param1;
         this.updateValue();
      }
      
      public function get maxValue() : Number
      {
         return this._maxValue;
      }
      
      public function set maxValue(param1:Number) : void
      {
         if(param1 == this._maxValue)
         {
            return;
         }
         if(param1 < this._minValue)
         {
            param1 = this._minValue;
         }
         this._maxValue = param1;
         this.updateValue();
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 == this._value)
         {
            return;
         }
         this._value = param1;
         this.updateValue();
      }
      
      public function get precision() : int
      {
         return this._precision;
      }
      
      public function set precision(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._precision = param1;
         this.updateValue();
      }
      
      public function get step() : Number
      {
         return this._step;
      }
      
      public function set step(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._step = param1;
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
         this.btn_increase.dispose();
         this.btn_decrease.dispose();
         this.txt_value.dispose();
         this._timer.stop();
      }
      
      override protected function draw() : void
      {
         this.btn_decrease.height = this.btn_increase.height = this.btn_increase.width = this.btn_decrease.width = int(this._height - 4);
         var _loc1_:int = int(this.btn_decrease.x + this.btn_decrease.width + this._padding);
         var _loc2_:int = int(this._width - this.btn_decrease.width - this.btn_increase.width - this._padding * 2);
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,_loc2_,this._height,_loc1_,0);
         this.txt_value.x = _loc1_;
         this.txt_value.y = int((this._height - this.txt_value.height) * 0.5 - 1);
         this.txt_value.width = _loc2_;
         this.txt_value.maxWidth = _loc2_;
         this.btn_decrease.x = 0;
         this.btn_decrease.y = int((this._height - this.btn_decrease.height) * 0.5);
         this.btn_increase.x = int(this._width - this.btn_increase.width);
         this.btn_increase.y = int(this.btn_decrease.y);
      }
      
      private function updateValue() : void
      {
         this._value += this._spinDir;
         if(this._value < this._minValue)
         {
            this._value = this._minValue;
         }
         else if(this._value > this._maxValue)
         {
            this._value = this._maxValue;
         }
         if(isNaN(this._value))
         {
            this._value = this._minValue;
         }
         this.txt_value.text = NumberFormatter.format(this._value,this._precision);
         this.btn_decrease.enabled = this._value > this._minValue;
         this.btn_increase.enabled = this._value < this._maxValue;
         this.changed.dispatch(this);
      }
      
      private function onButtonMouseDown(param1:MouseEvent) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         switch(param1.currentTarget)
         {
            case this.btn_decrease:
               this._spinDir = -1;
               break;
            case this.btn_increase:
               this._spinDir = 1;
         }
         this._timer.delay = 250;
         this._timer.reset();
         this._timer.start();
         this.updateValue();
      }
      
      private function onButtonMouseUp(param1:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp);
         this._spinDir = 0;
         this._timer.stop();
      }
      
      private function onValueFocusIn(param1:FocusEvent) : void
      {
         this.txt_value.text = this._value.toString();
         this.txt_value.restrict = "0-9" + (this._precision > 0 ? "." : "");
         this.txt_value.setSelection(0,this.txt_value.text.length);
      }
      
      private function onValueFocusOut(param1:FocusEvent) : void
      {
         this._spinDir = 0;
         this.value = Number(this.txt_value.text);
         this.txt_value.restrict = null;
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this._timer.delay *= 0.9;
         this.updateValue();
      }
   }
}

