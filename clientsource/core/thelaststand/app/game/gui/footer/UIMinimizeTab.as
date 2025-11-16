package thelaststand.app.game.gui.footer
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   
   public class UIMinimizeTab extends Sprite
   {
      
      public static const STATE_DOWN:String = "down";
      
      public static const STATE_UP:String = "up";
      
      private const ARROW_ALPHA:Number = 0.4;
      
      private var _state:String = "down";
      
      private var bmp_tab:Bitmap;
      
      private var bmp_arrow:Bitmap;
      
      public function UIMinimizeTab()
      {
         super();
         mouseChildren = false;
         buttonMode = true;
         this.bmp_tab = new Bitmap(new BmpTab());
         addChild(this.bmp_tab);
         this.bmp_arrow = new Bitmap(new BmpTabArrow());
         this.bmp_arrow.alpha = this.ARROW_ALPHA;
         addChild(this.bmp_arrow);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.update();
      }
      
      public function destroy() : void
      {
         this.bmp_arrow.bitmapData.dispose();
         this.bmp_arrow.bitmapData = null;
         this.bmp_tab.bitmapData.dispose();
         this.bmp_tab.bitmapData = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      private function update() : void
      {
         this.bmp_arrow.scaleY = this._state == STATE_DOWN ? 1 : -1;
         this.bmp_arrow.y = int(this.bmp_tab.y + (this.bmp_tab.height - this.bmp_arrow.height) * 0.5 + (this._state == STATE_DOWN ? 0 : this.bmp_arrow.height + 2));
         this.bmp_arrow.x = int(this.bmp_tab.x + (this.bmp_tab.width - this.bmp_arrow.width) * 0.5);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_arrow,0.15,{"alpha":1});
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_arrow,0.25,{"alpha":this.ARROW_ALPHA});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      public function set state(param1:String) : void
      {
         this._state = param1;
         this.update();
      }
      
      override public function get width() : Number
      {
         return this.bmp_tab.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.bmp_tab.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

