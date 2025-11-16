package thelaststand.app.game.gui
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class UISquarePieTimer extends Sprite
   {
      
      private var _size:int = 64;
      
      private var _sides:int = 6;
      
      private var _color:uint;
      
      private var _alpha:Number = 1;
      
      private var _radius:Number = 0;
      
      private var _progress:Number = 0;
      
      private var mc_timer:Shape;
      
      private var mc_mask:Shape;
      
      public function UISquarePieTimer(param1:int, param2:uint, param3:Number = 1)
      {
         super();
         this._size = param1;
         this._color = param2;
         this._alpha = param3;
         mouseEnabled = mouseChildren = false;
         this.mc_timer = new Shape();
         addChild(this.mc_timer);
         this.mc_mask = new Shape();
         addChild(this.mc_mask);
         this.mc_timer.mask = this.mc_mask;
         this.setSize(this._size);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function setSize(param1:int) : void
      {
         this.mc_mask.graphics.clear();
         this.mc_mask.graphics.beginFill(65280);
         this.mc_mask.graphics.drawRect(0,0,this._size,this._size);
         this.mc_mask.graphics.endFill();
         this._radius = this._size * (1 / 1.4) / Math.cos(1 / this._sides * Math.PI);
      }
      
      private function draw() : void
      {
         this.mc_timer.graphics.clear();
         this.mc_timer.graphics.beginFill(this._color,this._alpha);
         this.drawSegments(this.mc_timer.graphics,this._progress,this._size * 0.5,this._size * 0.5,-Math.PI * 0.5);
         this.mc_timer.graphics.endFill();
      }
      
      private function drawSegments(param1:Graphics, param2:Number, param3:Number = 0, param4:Number = 0, param5:Number = 0) : void
      {
         param1.moveTo(param3,param4);
         var _loc6_:Number = 0;
         var _loc7_:int = int(param2 * this._sides);
         var _loc8_:int = 0;
         while(_loc8_ <= _loc7_)
         {
            _loc6_ = _loc8_ / this._sides * (Math.PI * 2) + param5;
            param1.lineTo(Math.cos(_loc6_) * this._radius + param3,Math.sin(_loc6_) * this._radius + param4);
            _loc8_++;
         }
         if(param2 * this._sides != _loc7_)
         {
            _loc6_ = param2 * (Math.PI * 2) + param5;
            param1.lineTo(Math.cos(_loc6_) * this._radius + param3,Math.sin(_loc6_) * this._radius + param4);
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
         this.draw();
      }
      
      override public function get width() : Number
      {
         return this._size;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._size;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

