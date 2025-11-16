package thelaststand.app.game.gui.map
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class UIHighActivityZoneMarker extends Sprite
   {
      
      private var _animation:MovieClip;
      
      private var _shape:Shape;
      
      private var _bmpFill:BitmapData;
      
      private var _width:Number = 100;
      
      private var _height:Number = 100;
      
      public function UIHighActivityZoneMarker(param1:Number = 100, param2:Number = 100)
      {
         super();
         mouseChildren = mouseEnabled = false;
         this._animation = new HighActivityMarkerPulseMC();
         addChild(this._animation);
         this._shape = new Shape();
         addChild(this._shape);
         this._bmpFill = new BmpRedHazardTile();
         this._width = param1;
         this._height = param2;
         this.redraw();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._bmpFill != null)
         {
            this._bmpFill.dispose();
         }
         this._bmpFill = null;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this.redraw();
      }
      
      private function redraw() : void
      {
         this._animation.width = this._width;
         this._animation.height = this._height;
         var _loc1_:Graphics = this._shape.graphics;
         _loc1_.clear();
         _loc1_.beginBitmapFill(this._bmpFill,null,true);
         _loc1_.drawRect(4,4,this._width - 8,this._height - 8);
         _loc1_.drawRect(10,10,this._width - 20,this._height - 20);
         _loc1_.endFill();
      }
   }
}

