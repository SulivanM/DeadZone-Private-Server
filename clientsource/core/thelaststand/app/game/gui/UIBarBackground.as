package thelaststand.app.game.gui
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class UIBarBackground extends Sprite
   {
      
      private var bmd_bg:BitmapData;
      
      private var bmd_grime:BitmapData;
      
      private var mc_grime:Shape;
      
      public function UIBarBackground()
      {
         super();
         this.bmd_bg = new BmpTopBarBackground();
         this.bmd_grime = new BmpTopBarGrime();
         this.mc_grime = new Shape();
         this.mc_grime.alpha = 0.15;
         this.mc_grime.cacheAsBitmap = true;
         addChild(this.mc_grime);
         this.draw();
         cacheAsBitmap = true;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmd_bg.dispose();
         this.bmd_bg = null;
         this.bmd_grime.dispose();
         this.bmd_grime = null;
      }
      
      private function draw() : void
      {
         graphics.clear();
         graphics.beginBitmapFill(this.bmd_bg,null);
         graphics.drawRect(0,0,this.bmd_bg.width,this.bmd_bg.height);
         graphics.endFill();
         this.mc_grime.graphics.clear();
         this.mc_grime.graphics.beginBitmapFill(this.bmd_grime);
         this.mc_grime.graphics.drawRect(0,0,this.bmd_bg.width,this.bmd_bg.height);
         this.mc_grime.graphics.endFill();
      }
   }
}

