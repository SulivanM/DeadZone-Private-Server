package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   
   public class UIHUDMapButton extends UIHUDButton
   {
      
      private var bmp_arrow:Bitmap;
      
      public function UIHUDMapButton(param1:String)
      {
         super(param1,new Bitmap(new BmpIconHUDWorldMap()));
         this.bmp_arrow = new Bitmap(new BmpIconHUDWorldMapArrow());
         this.bmp_arrow.smoothing = true;
         this.bmp_arrow.x = int(icon.x + (icon.width - this.bmp_arrow.width) * 0.5);
         this.bmp_arrow.y = int(icon.y + (icon.height - this.bmp_arrow.height) * 0.5);
         addChild(this.bmp_arrow);
         TweenMax.to(this.bmp_arrow,0,{"transformAroundCenter":{
            "scaleX":DEFAULT_SCALE,
            "scaleY":DEFAULT_SCALE
         }});
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_arrow.bitmapData.dispose();
         this.bmp_arrow.bitmapData = null;
         this.bmp_arrow.filters = [];
         this.bmp_arrow = null;
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown || icon == null || !enabled)
         {
            return;
         }
         TweenMax.to(icon,0.15,{
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1
            },
            "colorTransform":{"exposure":1},
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
         var _loc2_:int = int(icon.x + (icon.width - this.bmp_arrow.width) * 0.5) + 10;
         this.bmp_arrow.alpha = 1;
         TweenMax.to(this.bmp_arrow,0.75,{
            "x":_loc2_,
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1
            },
            "alpha":1,
            "yoyo":true,
            "repeat":-1,
            "ease":Quad.easeInOut,
            "overwrite":true
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(icon,0.25,{
            "transformAroundCenter":{
               "scaleX":DEFAULT_SCALE,
               "scaleY":DEFAULT_SCALE
            },
            "colorTransform":{"exposure":1},
            "ease":Quad.easeOut,
            "overwrite":true
         });
         var _loc2_:int = int(icon.x + (icon.width - this.bmp_arrow.width) * 0.5);
         TweenMax.to(this.bmp_arrow,0.5,{
            "x":_loc2_,
            "transformAroundCenter":{
               "scaleX":DEFAULT_SCALE,
               "scaleY":DEFAULT_SCALE
            },
            "ease":Quad.easeOut,
            "overwrite":true
         });
      }
      
      override protected function onMouseDown(param1:MouseEvent) : void
      {
         var ax:int = 0;
         var e:MouseEvent = param1;
         if(!enabled)
         {
            return;
         }
         super.onMouseDown(e);
         ax = int(icon.x + (icon.width - this.bmp_arrow.width) * 0.5);
         TweenMax.to(this.bmp_arrow,0.25,{
            "x":ax + 60,
            "alpha":0,
            "ease":Quad.easeIn,
            "overwrite":true,
            "onComplete":function():void
            {
               bmp_arrow.x = ax - 20;
               TweenMax.to(bmp_arrow,0.25,{
                  "x":ax,
                  "alpha":1,
                  "ease":Quad.easeOut
               });
            }
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
   }
}

