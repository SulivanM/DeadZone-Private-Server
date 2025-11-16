package thelaststand.app.game.gui.compound
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.common.lang.Language;
   
   public class UIEarnFuelDisplay extends Sprite
   {
      
      private var _value:int;
      
      private var _tweenDummy:Object = {"value":0};
      
      private var _tweenAnimation:TweenMax;
      
      private var _width:int;
      
      private var _height:int;
      
      private var bmp_blob:Bitmap;
      
      private var bmp_bar:Bitmap;
      
      private var bmp_icon:Bitmap;
      
      private var bmp_add:Bitmap;
      
      private var txt_label:BodyTextField;
      
      public var clicked:NativeSignal;
      
      public function UIEarnFuelDisplay()
      {
         super();
         this.bmp_bar = new Bitmap(new BmpBarFuel());
         this.bmp_bar.cacheAsBitmap = true;
         addChild(this.bmp_bar);
         this._width = this.bmp_bar.width;
         this._height = this.bmp_bar.height;
         this.bmp_blob = new Bitmap(new BmpEarnFuelBlob(),"auto",true);
         this.bmp_blob.x = -int(this.bmp_blob.width * 0.5) - 3;
         this.bmp_blob.y = int((this._height - this.bmp_blob.width) * 0.5) - 1;
         addChildAt(this.bmp_blob,0);
         this.bmp_icon = new Bitmap(new BmpIconFuel(),"auto",true);
         this.bmp_icon.scaleX = this.bmp_icon.scaleY = 0.75;
         this.bmp_icon.x = -int(this.bmp_icon.width * 0.75);
         this.bmp_icon.y = int(this.bmp_bar.y + (this.bmp_bar.height - this.bmp_icon.height) * 0.5);
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         this.bmp_add = new Bitmap(new BmpIconAddResource());
         this.bmp_add.x = int(this.bmp_bar.x + this.bmp_bar.width - this.bmp_add.width - 6);
         this.bmp_add.y = int(this.bmp_bar.y + (this.bmp_bar.height - this.bmp_add.height) * 0.5);
         addChild(this.bmp_add);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "autoSize":"none",
            "size":13,
            "bold":true
         });
         this.txt_label.text = Language.getInstance().getString("earn_fuel");
         this.txt_label.x = int(this.bmp_icon.x + this.bmp_icon.width + 4);
         this.txt_label.y = int(this.bmp_bar.y + (this.bmp_bar.height - this.txt_label.height) * 0.5 - 2);
         this.txt_label.width = int(this.bmp_add.x - this.txt_label.x - 4);
         this.txt_label.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_label);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_bar.bitmapData.dispose();
         this.bmp_bar.bitmapData = null;
         this.bmp_add.bitmapData.dispose();
         this.bmp_add.bitmapData = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_blob.bitmapData.dispose();
         this.bmp_blob.bitmapData = null;
         this.txt_label.dispose();
         this.txt_label = null;
         this.clicked.removeAll();
         this._tweenAnimation = null;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         TweenMax.to(this.bmp_add,0,{
            "colorTransform":{"exposure":1.1},
            "glowFilter":{
               "color":7065090,
               "alpha":1,
               "blurX":8,
               "blurY":8,
               "strength":2,
               "quality":1
            },
            "overwrite":true
         });
         TweenMax.to(this.bmp_bar,0,{
            "colorTransform":{"exposure":1.08},
            "overwrite":true
         });
         TweenMax.to(this.bmp_blob,0.05,{"transformAroundCenter":{
            "scaleX":1.1,
            "scaleY":1.1,
            "rotation":(Math.random() * 2 - 1) * 5
         }});
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_add,0.25,{
            "colorTransform":{"exposure":1},
            "glowFilter":{
               "alpha":0,
               "remove":true
            }
         });
         TweenMax.to(this.bmp_bar,0.25,{"colorTransform":{"exposure":1}});
         TweenMax.to(this.bmp_blob,0.25,{"transformAroundCenter":{
            "scaleX":1,
            "scaleY":1,
            "rotation":0
         }});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_bar,0,{
            "colorTransform":{"exposure":1.25},
            "overwrite":true
         });
         TweenMax.to(this.bmp_bar,0.5,{
            "delay":0.05,
            "colorTransform":{"exposure":1}
         });
         Audio.sound.play("sound/interface/int-click.mp3");
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

