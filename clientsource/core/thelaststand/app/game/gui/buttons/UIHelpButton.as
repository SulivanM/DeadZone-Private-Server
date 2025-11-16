package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   
   public class UIHelpButton extends Sprite
   {
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      private var _width:int;
      
      private var _height:int;
      
      private var bmp_icon:Bitmap;
      
      public function UIHelpButton()
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         this.bmp_icon = new Bitmap(new BmpIconHelp(),"auto",true);
         addChild(this.bmp_icon);
         this._width = this.bmp_icon.width;
         this._height = this.bmp_icon.height;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_icon,0.15,{
            "transformAroundCenter":{
               "scaleX":1.15,
               "scaleY":1.15
            },
            "ease":Back.easeOut
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_icon,0.25,{"transformAroundCenter":{
            "scaleX":1,
            "scaleY":1
         }});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_icon,0,{"colorTransform":{"exposure":1.75}});
         TweenMax.to(this.bmp_icon,0.25,{
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
      }
   }
}

