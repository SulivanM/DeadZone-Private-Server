package thelaststand.app.game.gui.lists
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.gui.UIImage;
   
   public class UISchematicListItem extends UIPagedListItem
   {
      
      private static const BMP_BACKGROUND_SCHEMATIC:BitmapData = new BmpSchematicSlotBG();
      
      private static const BMP_BACKGROUND_SCHEMATIC_PREMIUM:BitmapData = new BmpSchematicSlotBGPremium();
      
      private static const BMP_BACKGROUND_SCHEMATIC_INFAMOUS:BitmapData = new BmpSchematicSlotBGInfamous();
      
      private static const BMP_NEW_ICON:BitmapData = new BmpIconNewItem();
      
      private static const BMP_LIMITED_ICON:BitmapData = new BmpIconSearchTimer();
      
      private static const NEW_ICON_GLOW:GlowFilter = new GlowFilter(14191125,1,6,6,1,1);
      
      private static const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,1,2,2,1,1);
      
      private static const COLOR_LOCKED:ColorMatrix = new ColorMatrix();
      
      private static const COLOR_NULL:ColorMatrix = new ColorMatrix();
      
      COLOR_LOCKED.colorize(13369344);
      COLOR_NULL.desaturate();
      COLOR_NULL.adjustBrightness(-25);
      
      private const STROKE:GlowFilter = new GlowFilter(5460819,1,4,4,10,1);
      
      private const IMAGE_STROKE:GlowFilter = new GlowFilter(1385288,1,3,3,10,1);
      
      private var _schematic:Schematic;
      
      private var _imageWidth:int = 64;
      
      private var _imageHeight:int = 64;
      
      private var _borderSize:int = 2;
      
      private var _strokeColor:uint = 5460819;
      
      private var _locked:Boolean = false;
      
      private var bmp_background:Bitmap;
      
      private var bmp_newIcon:Bitmap;
      
      private var bmp_limited:Bitmap;
      
      private var mc_shape:Shape;
      
      private var mc_image:UIImage;
      
      private var txt_quantity:BodyTextField;
      
      public function UISchematicListItem(param1:int = 64)
      {
         super();
         mouseChildren = false;
         this._imageHeight = this._imageWidth = param1;
         _width = int(this._imageWidth + this._borderSize * 2);
         _height = int(this._imageHeight + this._borderSize * 2);
         this.mc_shape = new Shape();
         this.mc_shape.graphics.beginFill(0,1);
         this.mc_shape.graphics.drawRect(0,0,this._imageWidth,this._imageHeight);
         this.mc_shape.graphics.endFill();
         this.mc_shape.x = this.mc_shape.y = this._borderSize;
         this.mc_shape.filters = [this.STROKE,SHADOW];
         addChild(this.mc_shape);
         this.bmp_background = new Bitmap(BMP_BACKGROUND_SCHEMATIC);
         this.bmp_background.x = this.bmp_background.y = this._borderSize;
         addChild(this.bmp_background);
         var _loc2_:int = 2;
         this.mc_image = new UIImage(this._imageWidth - _loc2_ * 2,this._imageHeight - _loc2_ * 2,0,0);
         this.mc_image.x = this.mc_image.y = this._borderSize + _loc2_;
         this.mc_image.bitmap.filters = [this.IMAGE_STROKE];
         this.mc_image.mouseEnabled = false;
         addChild(this.mc_image);
         this.txt_quantity = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true
         });
         this.txt_quantity.text = " ";
         this.txt_quantity.x = int(this.mc_shape.width - this.txt_quantity.width - 4);
         this.txt_quantity.y = int(this.mc_shape.height - this.txt_quantity.height);
         this.txt_quantity.maxWidth = int(this.mc_image.width * 0.66);
         this.txt_quantity.filters = [Effects.STROKE_MEDIUM];
         this.bmp_newIcon = new Bitmap(BMP_NEW_ICON);
         this.bmp_newIcon.filters = [NEW_ICON_GLOW];
         this.bmp_newIcon.x = this.mc_shape.x + 2;
         this.bmp_newIcon.y = this.mc_shape.y + 2;
         this.bmp_limited = new Bitmap(BMP_LIMITED_ICON);
         this.bmp_limited.x = int(this.mc_shape.x + this.mc_shape.width - this.bmp_limited.width - 4);
         this.bmp_limited.y = int(this.mc_shape.y + this.mc_shape.height - this.bmp_limited.height - 4);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      override public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         super.dispose();
         this._schematic = null;
         this.txt_quantity.dispose();
         this.mc_image.dispose();
         this.mc_shape.filters = [];
         this.bmp_background.bitmapData = null;
         this.bmp_background.filters = [];
         this.bmp_newIcon.bitmapData = null;
         this.bmp_newIcon.filters = [];
         this.bmp_limited.bitmapData = null;
         this.bmp_limited.filters = [];
      }
      
      private function updateStrokeColor() : void
      {
         var _loc1_:Color = null;
         this._strokeColor = 5460819;
         if(this._schematic != null)
         {
            _loc1_ = new Color(Effects["COLOR_" + ItemQualityType.getName(this._schematic.outputItem.qualityType)]);
            if(_loc1_ != null)
            {
               _loc1_.tint(0,0.5);
               this._strokeColor = _loc1_.RGB;
            }
         }
         this.STROKE.color = this._strokeColor;
         this.mc_shape.filters = [this.STROKE,SHADOW];
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected || !enabled)
         {
            return;
         }
         TweenMax.to(this.mc_shape,0.1,{"glowFilter":{"color":11184810}});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected || !enabled)
         {
            return;
         }
         TweenMax.to(this.mc_shape,0.25,{"glowFilter":{"color":this._strokeColor}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected || !enabled)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get schematic() : Schematic
      {
         return this._schematic;
      }
      
      public function set schematic(param1:Schematic) : void
      {
         this._schematic = param1;
         if(this.txt_quantity.parent != null)
         {
            this.txt_quantity.parent.removeChild(this.txt_quantity);
         }
         if(this.bmp_newIcon.parent != null)
         {
            this.bmp_newIcon.parent.removeChild(this.bmp_newIcon);
         }
         if(this.bmp_limited.parent != null)
         {
            this.bmp_limited.parent.removeChild(this.bmp_limited);
         }
         if(this._schematic == null)
         {
            this.bmp_background.bitmapData = BMP_BACKGROUND_SCHEMATIC;
            this.bmp_background.smoothing = true;
         }
         else
         {
            this.mc_image.uri = this._schematic.outputItem.getImageURI();
            this.updateStrokeColor();
            if(this._schematic.outputItem.qualityType == ItemQualityType.PREMIUM)
            {
               this.bmp_background.bitmapData = BMP_BACKGROUND_SCHEMATIC_PREMIUM;
            }
            else if(this._schematic.outputItem.qualityType == ItemQualityType.INFAMOUS)
            {
               this.bmp_background.bitmapData = BMP_BACKGROUND_SCHEMATIC_INFAMOUS;
            }
            else
            {
               this.bmp_background.bitmapData = BMP_BACKGROUND_SCHEMATIC;
            }
            this.bmp_background.smoothing = true;
            if(this._schematic.outputItem.quantity > 1)
            {
               this.txt_quantity.text = NumberFormatter.format(this._schematic.outputItem.quantity,0);
               this.txt_quantity.x = int(this.mc_shape.width - this.txt_quantity.width - 4);
               addChild(this.txt_quantity);
            }
            if(this._schematic.isNew)
            {
               addChild(this.bmp_newIcon);
            }
            if(this._schematic.getExpiryDate() != null || this._schematic.getMaxLevel() < int.MAX_VALUE)
            {
               addChild(this.bmp_limited);
            }
         }
         this.locked = this._locked;
      }
      
      public function get locked() : Boolean
      {
         return this._locked;
      }
      
      public function set locked(param1:Boolean) : void
      {
         this._locked = param1;
         this.bmp_background.filters = this._schematic == null ? [COLOR_NULL.filter] : (this._locked ? [COLOR_LOCKED.filter] : []);
         this.IMAGE_STROKE.color = this._locked ? 1903628 : 1385288;
         this.mc_image.bitmap.filters = this._locked ? [COLOR_LOCKED.filter,this.IMAGE_STROKE] : [this.IMAGE_STROKE];
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         mouseEnabled = super.enabled;
         this.alpha = super.enabled ? 1 : 0.3;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         TweenMax.to(this.mc_shape,0.1,{"glowFilter":{"color":(selected ? 16777215 : this._strokeColor)}});
      }
   }
}

