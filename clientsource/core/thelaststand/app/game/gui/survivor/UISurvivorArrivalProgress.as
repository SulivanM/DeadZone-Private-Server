package thelaststand.app.game.gui.survivor
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import thelaststand.app.game.gui.UILargeProgressBar;
   
   public class UISurvivorArrivalProgress extends Sprite
   {
      
      private const TRACK_GLOW:GlowFilter = new GlowFilter(7039851,1,3,3,3,2);
      
      private const BAR_PADDING:int = 2;
      
      private var _width:int = 200;
      
      private var _height:int = 24;
      
      private var bmp_icon:Bitmap;
      
      private var mc_bar:UILargeProgressBar;
      
      private var mc_track:Shape;
      
      private var mc_iconBG:Shape;
      
      public function UISurvivorArrivalProgress()
      {
         super();
         this.mc_track = new Shape();
         this.mc_track.graphics.beginFill(2631204);
         this.mc_track.graphics.drawRect(0,0,this._width,this._height);
         this.mc_track.graphics.endFill();
         this.mc_track.filters = [this.TRACK_GLOW];
         this.mc_track.cacheAsBitmap = true;
         addChild(this.mc_track);
         this.mc_iconBG = new Shape();
         this.mc_iconBG.graphics.beginFill(3958902);
         this.mc_iconBG.graphics.drawRect(0,0,26,this._height - this.BAR_PADDING * 2);
         this.mc_iconBG.graphics.endFill();
         this.mc_iconBG.x = this._width - this.mc_iconBG.width - this.BAR_PADDING;
         this.mc_iconBG.y = this.BAR_PADDING;
         this.mc_iconBG.filters = [new GlowFilter(0,0.25,2,2,10,1,true)];
         addChild(this.mc_iconBG);
         this.bmp_icon = new Bitmap(new BmpIconSurvivorArrival());
         this.bmp_icon.x = int(this.mc_iconBG.x + (this.mc_iconBG.width - this.bmp_icon.width) * 0.5);
         this.bmp_icon.y = int(this.mc_iconBG.y + (this.mc_iconBG.height - this.bmp_icon.height) * 0.5);
         addChild(this.bmp_icon);
         this.mc_bar = new UILargeProgressBar(42723,this.mc_iconBG.x - this.BAR_PADDING * 2,this._height - this.BAR_PADDING * 2);
         this.mc_bar.x = this.mc_bar.y = this.BAR_PADDING;
         this.mc_bar.maxValue = 1;
         this.mc_bar.value = 0;
         addChild(this.mc_bar);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
         this.mc_track.filters = [];
         this.mc_iconBG.filters = [];
         this.mc_bar.dispose();
         this.mc_bar = null;
      }
      
      private function setSize(param1:int) : void
      {
         this._width = param1;
         scaleX = scaleY = 1;
         this.mc_track.graphics.clear();
         this.mc_track.graphics.beginFill(2631204);
         this.mc_track.graphics.drawRect(0,0,this._width,this._height);
         this.mc_track.graphics.endFill();
         this.mc_iconBG.x = this._width - this.mc_iconBG.width - this.BAR_PADDING;
         this.bmp_icon.x = int(this.mc_iconBG.x + (this.mc_iconBG.width - this.bmp_icon.width) * 0.5);
         this.mc_bar.width = this.mc_iconBG.x - this.BAR_PADDING * 2;
      }
      
      public function get progress() : Number
      {
         return this.mc_bar.value;
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
         this.mc_bar.value = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1);
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

