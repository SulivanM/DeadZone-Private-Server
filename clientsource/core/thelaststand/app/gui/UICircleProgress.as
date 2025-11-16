package thelaststand.app.gui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   
   public class UICircleProgress extends Sprite
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _radius:Number = 8;
      
      private var _progress:Number = 0;
      
      private var _color:uint = 13500416;
      
      private var mc_shape:Shape;
      
      private var mc_container:Sprite;
      
      private var mc_half1:Shape;
      
      private var mc_half2:Shape;
      
      private var mc_mask1:Shape;
      
      private var mc_mask2:Shape;
      
      public function UICircleProgress(param1:uint = 13500416, param2:uint = 4210752, param3:Number = 8)
      {
         super();
         mouseEnabled = false;
         this._color = param1;
         this._radius = param3;
         this._width = this._radius * 2;
         this._height = this._radius * 2;
         this.mc_container = new Sprite();
         this.mc_container.filters = [new GlowFilter(0,0.75,6,6,1,1)];
         addChild(this.mc_container);
         this.mc_half1 = new Shape();
         this.mc_half1.graphics.beginFill(this._color);
         this.mc_half1.graphics.drawRoundRectComplex(0,-this._radius,this._radius,this._radius * 2,0,this._radius,0,this._radius);
         this.mc_half1.graphics.endFill();
         this.mc_container.addChild(this.mc_half1);
         this.mc_mask1 = new Shape();
         this.mc_mask1.graphics.beginFill(65280,0.5);
         this.mc_mask1.graphics.drawRect(0,-this._radius,this._radius,this._radius * 2);
         this.mc_mask1.graphics.endFill();
         this.mc_half1.mask = this.mc_mask1;
         this.mc_container.addChild(this.mc_mask1);
         this.mc_half2 = new Shape();
         this.mc_half2.graphics.beginFill(this._color);
         this.mc_half2.graphics.drawRoundRectComplex(-this._radius,-this._radius,this._radius,this._radius * 2,this._radius,0,this._radius,0);
         this.mc_half2.graphics.endFill();
         this.mc_container.addChild(this.mc_half2);
         this.mc_mask2 = new Shape();
         this.mc_mask2.graphics.beginFill(65280,0.5);
         this.mc_mask2.graphics.drawRect(-this._radius,-this._radius,this._radius,this._radius * 2);
         this.mc_mask2.graphics.endFill();
         this.mc_half2.mask = this.mc_mask2;
         this.mc_container.addChild(this.mc_mask2);
         this.mc_shape = new Shape();
         this.mc_shape.graphics.beginFill(param2);
         this.mc_shape.graphics.drawCircle(0,0,this._radius);
         this.mc_shape.graphics.endFill();
         this.mc_shape.filters = [new GlowFilter(0,1,2,2,10,1)];
         addChildAt(this.mc_shape,0);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
      
      public function set progress(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._progress = param1;
         if(this._progress < 0.5)
         {
            this.mc_mask1.rotation = this._progress * 2 * 180 - 180;
            this.mc_mask2.rotation = 180;
         }
         else
         {
            this.mc_mask1.rotation = 0;
            this.mc_mask2.rotation = this._progress * 2 * 180;
         }
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
   }
}

