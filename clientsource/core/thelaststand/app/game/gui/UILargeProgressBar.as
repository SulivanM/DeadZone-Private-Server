package thelaststand.app.game.gui
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   
   public class UILargeProgressBar extends Sprite
   {
      
      public static const ALIGN_LEFT:String = "left";
      
      public static const ALIGN_RIGHT:String = "right";
      
      private var _align:String;
      
      private var _color1:uint;
      
      private var _color2:uint;
      
      private var _fillMatrix:Matrix;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _value:Number = 0;
      
      private var _maxValue:Number = 1;
      
      private var _barTween:TweenMax;
      
      private var bmd_grime:BitmapData;
      
      private var mc_bar:Shape;
      
      private var mc_grime:Shape;
      
      public var animate:Boolean = true;
      
      public function UILargeProgressBar(param1:uint, param2:int = 188, param3:int = 20, param4:String = "left")
      {
         super();
         this._align = param4;
         this._color1 = param1;
         this._color2 = new Color(this._color1).adjustBrightness(0.75).RGB;
         this._fillMatrix = new Matrix();
         this.mc_bar = new Shape();
         addChild(this.mc_bar);
         this.mc_grime = new Shape();
         this.mc_grime.alpha = 0.2;
         this.mc_grime.cacheAsBitmap = true;
         addChild(this.mc_grime);
         this.bmd_grime = new BmpXPBarGrime();
         this.setSize(param2,param3);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.bmd_grime.dispose();
         this.bmd_grime = null;
         this._fillMatrix = null;
         this._barTween = null;
      }
      
      private function animateBar() : void
      {
         if(!this.animate || stage == null)
         {
            this.mc_bar.width = this.getTargetWidth();
            this.drawGrimeLayer();
            return;
         }
         if(this._barTween != null && this._barTween.totalProgress < 1)
         {
            this._barTween.updateTo({"width":this.getTargetWidth()});
            return;
         }
         this._barTween = TweenMax.to(this.mc_bar,0.25,{
            "width":this.getTargetWidth(),
            "onUpdate":this.drawGrimeLayer,
            "onComplete":function():void
            {
               _barTween = null;
            }
         });
      }
      
      private function drawBar() : void
      {
         this._fillMatrix.createGradientBox(this._width,this._height,Math.PI * 0.5);
         var _loc1_:int = this._align == ALIGN_LEFT ? 0 : this._width;
         var _loc2_:int = this._width * (this._align == ALIGN_LEFT ? 1 : -1);
         this.mc_bar.scaleX = 1;
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginGradientFill(GradientType.LINEAR,[this._color1,this._color2],[1,1],[0,255],this._fillMatrix);
         this.mc_bar.graphics.drawRect(_loc1_,0,_loc2_,this._height);
         this.mc_bar.graphics.endFill();
         this.mc_bar.width = this.getTargetWidth();
      }
      
      private function drawGrimeLayer() : void
      {
         var _loc1_:int = this._align == ALIGN_LEFT ? 0 : this._width;
         this.mc_grime.scaleX = 1;
         this.mc_grime.graphics.clear();
         this.mc_grime.graphics.beginBitmapFill(this.bmd_grime);
         this.mc_grime.graphics.drawRect(_loc1_,0,this.mc_bar.width,this._height);
         this.mc_grime.graphics.endFill();
      }
      
      private function getTargetWidth() : int
      {
         if(this._value == 0 && this._maxValue == 0)
         {
            return int(this._width * (this._align == ALIGN_LEFT ? 1 : -1));
         }
         return int(this._width * (this._value / this._maxValue) * (this._align == ALIGN_LEFT ? 1 : -1));
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         this.drawBar();
         this.drawGrimeLayer();
      }
      
      public function get barWidth() : Number
      {
         return this.getTargetWidth();
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 > this._maxValue)
         {
            param1 = this._maxValue;
         }
         this._value = param1;
         this.animateBar();
      }
      
      public function get maxValue() : Number
      {
         return this._maxValue;
      }
      
      public function set maxValue(param1:Number) : void
      {
         this._maxValue = param1;
         this.animateBar();
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
   }
}

