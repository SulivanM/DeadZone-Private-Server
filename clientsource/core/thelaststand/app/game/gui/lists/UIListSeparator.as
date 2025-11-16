package thelaststand.app.game.gui.lists
{
   import flash.display.Sprite;
   
   public class UIListSeparator extends Sprite
   {
      
      private var _width:int = 4;
      
      private var _height:int = 10;
      
      public function UIListSeparator(param1:int = 10)
      {
         super();
         this._height = param1;
         this.draw();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      private function draw() : void
      {
         graphics.clear();
         graphics.beginFill(9605778,0.25);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(0,1);
         graphics.drawRect(1,0,this._width - 2,this._height);
         graphics.endFill();
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
         this._height = param1;
         this.draw();
      }
   }
}

