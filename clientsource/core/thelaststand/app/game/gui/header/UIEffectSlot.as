package thelaststand.app.game.gui.header
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.gui.UISquarePieTimer;
   import thelaststand.app.gui.UIImage;
   
   public class UIEffectSlot extends Sprite
   {
      
      private static const BMD_EMPTY_SLOT:BitmapData = new BmpEffectSlotEmpty();
      
      private static const BMD_EMPTY_TACTICS:BitmapData = new BmpEffectSlotTactics();
      
      private static const OUTLINE_EMPTY:GlowFilter = new GlowFilter(1644825,1,2,2,10,1);
      
      private var _effect:Effect;
      
      private var _outline:GlowFilter;
      
      private var _group:String;
      
      private var bmp_empty:Bitmap;
      
      private var ui_image:UIImage;
      
      private var ui_timer:UISquarePieTimer;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public var mouseOut:NativeSignal;
      
      public function UIEffectSlot(param1:String = null)
      {
         super();
         this._group = param1;
         var _loc2_:BitmapData = this._group == "tactics" ? BMD_EMPTY_TACTICS : BMD_EMPTY_SLOT;
         this.bmp_empty = new Bitmap(_loc2_);
         addChild(this.bmp_empty);
         this.ui_image = new UIImage(this.bmp_empty.width,this.bmp_empty.height);
         this.ui_timer = new UISquarePieTimer(this.ui_image.width,16711680,0.5);
         this.ui_timer.blendMode = BlendMode.SCREEN;
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
         this.update();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this._effect != null)
         {
            this._effect.expired.remove(this.onEffectExpired);
         }
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._effect = null;
         this.bmp_empty.bitmapData = null;
         this.bmp_empty.filters = [];
         this.clicked.removeAll();
         this.mouseOver.removeAll();
         this.mouseOut.removeAll();
      }
      
      private function update() : void
      {
         if(this._effect == null)
         {
            if(this.ui_image.parent != null)
            {
               this.ui_image.parent.removeChild(this.ui_image);
            }
            if(this.ui_timer.parent != null)
            {
               this.ui_timer.parent.removeChild(this.ui_timer);
            }
            this.bmp_empty.filters = [OUTLINE_EMPTY];
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            return;
         }
         if(this._outline == null)
         {
            this._outline = new GlowFilter(0,1,2,2,10,1);
         }
         this._outline.color = this._effect.group == "global" || this._effect.group == "alliance" || this._effect.group == "tactics" ? 0 : uint(Effects["COLOR_EFFECT_" + this._effect.group.toUpperCase()]);
         this.bmp_empty.filters = [this._outline];
         this.ui_image.uri = this._effect.iconURI;
         addChild(this.ui_image);
         if(this._effect.timer != null)
         {
            this.ui_timer.progress = 0;
            addChild(this.ui_timer);
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._effect == null || this._effect.timer == null)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            return;
         }
         this.ui_timer.progress = this._effect.timer.getProgress();
      }
      
      private function onEffectExpired(param1:Effect) : void
      {
         Audio.sound.play("sound/interface/int-effect-timeout.mp3");
      }
      
      public function get effect() : Effect
      {
         return this._effect;
      }
      
      public function set effect(param1:Effect) : void
      {
         if(param1 != this._effect)
         {
            if(this._effect != null)
            {
               this._effect.expired.remove(this.onEffectExpired);
            }
            this._effect = param1;
            if(this._effect != null)
            {
               this._effect.expired.addOnce(this.onEffectExpired);
            }
         }
         this.update();
      }
      
      override public function get width() : Number
      {
         return this.bmp_empty.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.bmp_empty.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get group() : String
      {
         return this._group;
      }
   }
}

