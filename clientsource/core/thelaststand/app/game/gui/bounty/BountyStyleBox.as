package thelaststand.app.game.gui.bounty
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   
   public class BountyStyleBox extends Sprite
   {
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _gritBD:BitmapData;
      
      private var _tapeBD:BitmapData;
      
      private var _tl:Bitmap;
      
      private var _tr:Bitmap;
      
      private var _bl:Bitmap;
      
      private var _br:Bitmap;
      
      public var container:Sprite;
      
      public function BountyStyleBox(param1:Number = 200, param2:Number = 200)
      {
         super();
         this._width = param1;
         this._height = param2;
         this.container = new Sprite();
         this.container.x = 3;
         this.container.y = 3;
         addChild(this.container);
         this._gritBD = new BmpDialogueBackground();
         this._tapeBD = new BmpClearTape();
         this._tl = new Bitmap(this._tapeBD);
         addChild(this._tl);
         this._tr = new Bitmap(this._tapeBD);
         addChild(this._tr);
         this._bl = new Bitmap(this._tapeBD);
         addChild(this._bl);
         this._br = new Bitmap(this._tapeBD);
         addChild(this._br);
         this.redraw();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._gritBD.dispose();
         this._tapeBD.dispose();
      }
      
      private function redraw() : void
      {
         graphics.clear();
         graphics.beginFill(15263976,1);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.beginFill(12959661,1);
         graphics.drawRect(3,3,this._width - 6,this._height - 6);
         graphics.beginBitmapFill(this._gritBD);
         graphics.drawRect(3,3,this._width - 6,this._height - 6);
         graphics.beginFill(12959661,0.93);
         graphics.drawRect(3,3,this._width - 6,this._height - 6);
         this._tl.rotation = -39;
         this._tl.x = -14;
         this._tl.y = 12;
         this._tr.rotation = 39;
         this._tr.x = this._width - 17;
         this._tr.y = -14;
         this._bl.rotation = 39;
         this._bl.x = -9;
         this._bl.y = this._height - 20;
         this._br.rotation = -39;
         this._br.x = this._width - 24;
         this._br.y = this._height + 3;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.redraw();
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
   }
}

