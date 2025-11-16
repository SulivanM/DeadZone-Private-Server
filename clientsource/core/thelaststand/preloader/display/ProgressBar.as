package thelaststand.preloader.display
{
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class ProgressBar extends Sprite
   {
      
      private var _progress:Number = 0;
      
      private var _width:int = 940;
      
      private var _height:int = 10;
      
      private var mc_track:Shape;
      
      private var mc_bar:Shape;
      
      public function ProgressBar()
      {
         super();
         this.mc_track = new Shape();
         this.mc_bar = new Shape();
         addChild(this.mc_track);
         addChild(this.mc_bar);
         this.draw();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function draw() : void
      {
         this.mc_track.graphics.clear();
         this.mc_track.graphics.beginFill(3222824);
         this.mc_track.graphics.drawRect(0,0,this._width,this._height);
         this.mc_track.graphics.endFill();
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginFill(7545099);
         this.mc_bar.graphics.drawRect(0,0,this._width,this._height);
         this.mc_bar.graphics.endFill();
         this.mc_bar.width = this._width * this._progress;
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
         this.mc_bar.width = this._width * this._progress;
      }
   }
}

