package thelaststand.app.display
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class RushVignette extends Sprite
   {
      
      private var _intensity:Number = 1;
      
      private var _pulseTime:Number = 0.1;
      
      private var bmp_vignette:Bitmap;
      
      public function RushVignette()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.bmp_vignette = new Bitmap(new BmpOverlayVignetteRush(),"auto",true);
         addChild(this.bmp_vignette);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.bmp_vignette.bitmapData.dispose();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.bmp_vignette.alpha = this._intensity;
         stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         this.onStageResize(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(Event.RESIZE,this.onStageResize);
         TweenMax.killTweensOf(this);
         TweenMax.killTweensOf(this.bmp_vignette);
      }
      
      private function onStageResize(param1:Event) : void
      {
         this.bmp_vignette.width = stage.stageWidth;
         this.bmp_vignette.height = stage.stageHeight;
      }
   }
}

