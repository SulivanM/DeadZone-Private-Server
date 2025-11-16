package thelaststand.app.game.gui.footer
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   
   public class UIVolumeSlider extends Sprite
   {
      
      private var _mouseOutTimer:Timer;
      
      private var _slideBounds:Rectangle;
      
      private var _volume:Number = 1;
      
      private var bmp_background:Bitmap;
      
      private var bmp_thumb:Bitmap;
      
      public var changed:Signal;
      
      public var mouseOut:Signal;
      
      public function UIVolumeSlider()
      {
         super();
         this._slideBounds = new Rectangle(11,11,5,58);
         this._mouseOutTimer = new Timer(1000,1);
         this._mouseOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onMouseOutTimerComplete,false,0,true);
         this.changed = new Signal(Number);
         this.mouseOut = new Signal(UIVolumeSlider);
         this.bmp_background = new Bitmap(new BmpVolumeSlider());
         this.bmp_background.filters = [new DropShadowFilter(0,0,0,1,8,8,0.75,2)];
         addChild(this.bmp_background);
         this.bmp_thumb = new Bitmap(new BmpVolumeSliderThumb());
         this.bmp_thumb.filters = [new DropShadowFilter(2,45,0,1,6,6,0.75,2)];
         this.bmp_thumb.x = int(this._slideBounds.x + (this._slideBounds.width - this.bmp_thumb.width) * 0.5);
         this.bmp_thumb.y = int(this._slideBounds.y - this.bmp_thumb.height * 0.5);
         addChild(this.bmp_thumb);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      }
      
      public function dispose() : void
      {
         this.bmp_background.bitmapData.dispose();
         this.bmp_background.bitmapData = null;
         this.bmp_thumb.bitmapData.dispose();
         this.bmp_thumb.bitmapData = null;
         this._mouseOutTimer.stop();
         this._mouseOutTimer = null;
         this.changed.removeAll();
         this.changed = null;
         this.mouseOut.removeAll();
         this.mouseOut = null;
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function updateThumbPosition() : void
      {
         var _loc1_:int = this._slideBounds.y + this._slideBounds.height * (1 - this._volume) - this.bmp_thumb.height * 0.5;
         var _loc2_:int = this._slideBounds.y - this.bmp_thumb.height * 0.5;
         var _loc3_:int = this._slideBounds.bottom - this.bmp_thumb.height * 0.5;
         if(_loc1_ < _loc2_)
         {
            _loc1_ = _loc2_;
         }
         if(_loc1_ > _loc3_)
         {
            _loc1_ = _loc3_;
         }
         this.bmp_thumb.x = int(this._slideBounds.x + (this._slideBounds.width - this.bmp_thumb.width) * 0.5);
         this.bmp_thumb.y = _loc1_;
      }
      
      private function onDrag(param1:Event) : void
      {
         var _loc2_:Number = this._volume;
         var _loc3_:Number = 1 - (mouseY - this._slideBounds.y) / this._slideBounds.height;
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         else if(_loc3_ > 1)
         {
            _loc3_ = 1;
         }
         this._volume = _loc3_;
         if(_loc3_ != _loc2_)
         {
            this.updateThumbPosition();
            this.changed.dispatch(this._volume);
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(stage != null)
         {
            stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         }
         addEventListener(Event.ENTER_FRAME,this.onDrag,false,0,true);
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(stage != null)
         {
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         }
         removeEventListener(Event.ENTER_FRAME,this.onDrag);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this._mouseOutTimer.stop();
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         this._mouseOutTimer.reset();
         this._mouseOutTimer.start();
      }
      
      private function onMouseOutTimerComplete(param1:TimerEvent) : void
      {
         this.mouseOut.dispatch(this);
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set volume(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._volume = param1;
         this.updateThumbPosition();
      }
   }
}

