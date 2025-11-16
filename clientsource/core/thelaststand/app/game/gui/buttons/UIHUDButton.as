package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   
   public class UIHUDButton extends Sprite
   {
      
      private static const ICON_DROPSHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,8,8,0.75,1);
      
      private static const DISABLED_MATRIX:ColorMatrix = new ColorMatrix();
      
      DISABLED_MATRIX.desaturate();
      DISABLED_MATRIX.adjustBrightness(-75);
      
      protected const DEFAULT_SCALE:Number = 0.85;
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      protected var mc_hitArea:Sprite;
      
      protected var mc_icon:DisplayObject;
      
      public var id:String;
      
      public var offset:Point = new Point();
      
      public var clicked:NativeSignal;
      
      public var spacing:Number = 0;
      
      public function UIHUDButton(param1:String, param2:DisplayObject = null)
      {
         super();
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         buttonMode = true;
         mouseChildren = false;
         hitArea = this.mc_hitArea;
         this.id = param1;
         this.icon = param2;
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,int.MAX_VALUE,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.CLICK,this.onClick);
         var _loc1_:Bitmap = this.mc_icon as Bitmap;
         if(_loc1_ != null)
         {
            _loc1_.bitmapData.dispose();
            _loc1_.bitmapData = null;
         }
         if(this.mc_icon != null)
         {
            this.mc_icon.filters = [];
            this.mc_icon = null;
         }
         filters = [];
         this.clicked.removeAll();
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         if(!this._enabled || param1.buttonDown || this.mc_icon == null)
         {
            return;
         }
         TweenMax.to(this.mc_icon,0.15,{
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1
            },
            "colorTransform":{"exposure":1},
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      protected function onMouseOut(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            return;
         }
         TweenMax.to(this.mc_icon,0.25,{
            "transformAroundCenter":{
               "scaleX":this.DEFAULT_SCALE,
               "scaleY":this.DEFAULT_SCALE
            },
            "colorTransform":{"exposure":1},
            "ease":Quad.easeOut,
            "overwrite":true
         });
      }
      
      protected function onMouseDown(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
         TweenMax.to(this.mc_icon,0,{"colorTransform":{"exposure":1.5}});
         TweenMax.to(this.mc_icon,0.25,{
            "delay":0.05,
            "colorTransform":{"exposure":1}
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      protected function onClick(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         filters = this._enabled ? [] : [DISABLED_MATRIX.filter];
      }
      
      public function get icon() : DisplayObject
      {
         return this.mc_icon;
      }
      
      public function set icon(param1:DisplayObject) : void
      {
         var _loc2_:Bitmap = null;
         if(this.mc_icon != null)
         {
            if(this.mc_icon.parent != null)
            {
               this.mc_icon.parent.removeChild(this.mc_icon);
            }
            _loc2_ = this.mc_icon as Bitmap;
            if(_loc2_ != null)
            {
               _loc2_.bitmapData.dispose();
               _loc2_.bitmapData = null;
            }
         }
         this.mc_icon = param1;
         if(this.mc_icon != null)
         {
            if(this.mc_icon is Bitmap)
            {
               Bitmap(this.icon).smoothing = true;
            }
            this.mc_icon.filters = [ICON_DROPSHADOW];
            addChild(this.mc_icon);
            TweenMax.to(this.mc_icon,0,{"transformAroundCenter":{
               "scaleX":this.DEFAULT_SCALE,
               "scaleY":this.DEFAULT_SCALE
            }});
            this.mc_hitArea.width = this.mc_icon.width;
            this.mc_hitArea.height = this.mc_icon.height;
            this.mc_hitArea.x = this.mc_icon.x;
            this.mc_hitArea.y = this.mc_icon.y;
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
   }
}

