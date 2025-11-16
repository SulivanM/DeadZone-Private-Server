package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   
   public class UIBarButton extends Sprite
   {
      
      private static const BMP_BACKGROUND:BitmapData = new BmpTopBarButtonBackground();
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      private var bmp_background:Bitmap;
      
      private var mc_icon:DisplayObject;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public var mouseOut:NativeSignal;
      
      public function UIBarButton(param1:DisplayObject = null)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
         this.bmp_background = new Bitmap(BMP_BACKGROUND);
         addChild(this.bmp_background);
         if(param1 != null)
         {
            this.icon = param1;
         }
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function destroy() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.clicked.removeAll();
         this.mouseOver.removeAll();
         this.mouseOut.removeAll();
         this.mc_icon = null;
         this.bmp_background.bitmapData = null;
         this.bmp_background = null;
         TweenMax.killChildTweensOf(this);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         TweenMax.to(this.bmp_background,0,{
            "colorTransform":{"exposure":1.05},
            "overwrite":true
         });
         TweenMax.to(this.mc_icon,0,{
            "colorTransform":{"exposure":1.25},
            "overwrite":true
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_background,0.25,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
         TweenMax.to(this.mc_icon,0.25,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_background,0,{"colorTransform":{"exposure":1.2}});
         TweenMax.to(this.bmp_background,0.25,{
            "delay":0.05,
            "colorTransform":{"exposure":1}
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled && !this._selected;
         if(this.mc_icon != null)
         {
            this.mc_icon.alpha = this._enabled ? 1 : 0.3;
         }
      }
      
      public function get icon() : DisplayObject
      {
         return this.mc_icon;
      }
      
      public function set icon(param1:DisplayObject) : void
      {
         if(this.mc_icon != null)
         {
            if(this.mc_icon.parent)
            {
               this.mc_icon.parent.removeChild(this.mc_icon);
            }
         }
         this.mc_icon = param1;
         if(this.mc_icon != null)
         {
            this.mc_icon.x = Math.round(this.bmp_background.x + (this.bmp_background.width - this.mc_icon.width) * 0.5);
            this.mc_icon.y = Math.round(this.bmp_background.y + (this.bmp_background.height - this.mc_icon.height) * 0.5);
            this.mc_icon.alpha = this._enabled ? 1 : 0.3;
            addChild(this.mc_icon);
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         mouseEnabled = this._enabled && !this._selected;
      }
      
      override public function get width() : Number
      {
         return this.bmp_background.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.bmp_background.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

