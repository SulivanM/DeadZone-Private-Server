package thelaststand.app.game.gui
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.SchematicItem;
   import thelaststand.app.gui.UIImage;
   
   public class UIItemImage extends Sprite
   {
      
      private static const BMP_BACKGROUND_EMPTY:BitmapData = new BmpInventorySlotEmpty();
      
      private static const BMP_BACKGROUND_WEAPON:BitmapData = new BmpInventorySlotEmpty();
      
      private static const BMP_BACKGROUND_PREMIUM:BitmapData = new BmpInventorySlotPremium();
      
      private static const BMP_BACKGROUND_RARE:BitmapData = new BmpInventorySlotRare();
      
      private static const BMP_BACKGROUND_UNIQUE:BitmapData = new BmpInventorySlotUnique();
      
      private static const BMP_BACKGROUND_INFAMOUS:BitmapData = new BmpInventorySlotInfamous();
      
      private static const BMP_ICON_SCHEMATIC:BitmapData = new BmpIconGear();
      
      private static const ICON_STROKE:GlowFilter = new GlowFilter(0,1,4,4,10,1);
      
      private var _item:Item;
      
      private var _displayItem:Item;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _quantity:int = -1;
      
      private var _quantityAvailable:int = -1;
      
      private var _quantityFieldSize:int = 16;
      
      private var _showQuantityWhenOne:Boolean = false;
      
      private var _showSchematicOutputItem:Boolean = false;
      
      private var _borderColor:Color = null;
      
      private var bmp_background:Bitmap;
      
      private var bmp_schemIcon:Bitmap;
      
      private var txt_quantity:BodyTextField;
      
      private var mc_image:UIImage;
      
      private var mc_border:Shape;
      
      public var imageDisplayed:Signal;
      
      public function UIItemImage(param1:int, param2:int, param3:uint = 0)
      {
         super();
         this._width = param1;
         this._height = param2;
         mouseChildren = false;
         if(param3 > 0)
         {
            this.mc_border = new Shape();
            this.mc_border.graphics.beginFill(0);
            this.mc_border.graphics.drawRoundRect(0,0,param1 + param3 * 2,param2 + param3 * 2,param3,param3);
            this.mc_border.graphics.endFill();
            this.mc_border.x = -param3;
            this.mc_border.y = -param3;
            addChild(this.mc_border);
         }
         this.bmp_background = new Bitmap(BMP_BACKGROUND_EMPTY,"auto",true);
         this.bmp_background.width = param1;
         this.bmp_background.height = param2;
         addChild(this.bmp_background);
         this.mc_image = new UIImage(param1,param2,0,0,true);
         addChild(this.mc_image);
         this.txt_quantity = new BodyTextField({
            "color":16777215,
            "size":this._quantityFieldSize,
            "bold":true
         });
         this.txt_quantity.text = " ";
         this.txt_quantity.x = int(this.mc_image.width - this.txt_quantity.width - 2);
         this.txt_quantity.y = int(this.mc_image.height - this.txt_quantity.height);
         this.txt_quantity.maxWidth = int(this.mc_image.width * 0.66);
         this.txt_quantity.filters = [Effects.STROKE_MEDIUM];
         this.imageDisplayed = new Signal(UIItemImage);
         this.mc_image.imageDisplayed.add(this.onImageDisplayed);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._item = null;
         this._displayItem = null;
         this.imageDisplayed.removeAll();
         this.bmp_background.bitmapData = null;
         this.bmp_background = null;
         this.mc_image.imageDisplayed.remove(this.onImageDisplayed);
         this.mc_image.dispose();
         this.mc_image = null;
         if(this.bmp_schemIcon != null)
         {
            this.bmp_schemIcon.bitmapData = null;
         }
         this.txt_quantity.dispose();
         this.txt_quantity = null;
         filters = [];
      }
      
      private function updateItemDisplay() : void
      {
         var _loc1_:Color = null;
         var _loc3_:String = null;
         if(this.bmp_schemIcon != null && this.bmp_schemIcon.parent != null)
         {
            this.bmp_schemIcon.parent.removeChild(this.bmp_schemIcon);
         }
         if(this._displayItem == null)
         {
            this.mc_image.uri = null;
            this.mc_image.filters = null;
            this.bmp_background.bitmapData = BMP_BACKGROUND_EMPTY;
            this.bmp_background.transform.colorTransform = Effects.CT_DEFAULT;
            if(this.mc_border != null)
            {
               if(this._borderColor != null)
               {
                  this.mc_border.transform.colorTransform = this._borderColor.toColorTransform();
                  this.mc_border.alpha = 1;
               }
               else
               {
                  this.mc_border.transform.colorTransform = Effects.CT_DEFAULT;
               }
            }
            if(this.txt_quantity.parent != null)
            {
               this.txt_quantity.parent.removeChild(this.txt_quantity);
            }
            return;
         }
         this._quantity = -1;
         this._quantityAvailable = -1;
         var _loc2_:* = this._displayItem.category == "clothing";
         if(this._displayItem.qualityType == ItemQualityType.PREMIUM)
         {
            this.bmp_background.bitmapData = _loc2_ ? BMP_BACKGROUND_EMPTY : BMP_BACKGROUND_PREMIUM;
            this.bmp_background.transform.colorTransform = Effects.CT_DEFAULT;
            _loc1_ = new Color(Effects.COLOR_PREMIUM);
         }
         else
         {
            _loc3_ = ItemQualityType.getName(this._displayItem.qualityType);
            this.bmp_background.transform.colorTransform = Effects.CT_DEFAULT;
            _loc1_ = new Color(Effects["COLOR_" + _loc3_]);
            switch(this._displayItem.category)
            {
               case "weapon":
               case "gear":
               case "schematic":
                  this.bmp_background.bitmapData = BMP_BACKGROUND_WEAPON;
                  break;
               default:
                  this.bmp_background.bitmapData = BMP_BACKGROUND_EMPTY;
            }
            switch(this._displayItem.qualityType)
            {
               case ItemQualityType.RARE:
                  this.bmp_background.bitmapData = BMP_BACKGROUND_RARE;
                  break;
               case ItemQualityType.UNIQUE:
                  this.bmp_background.bitmapData = BMP_BACKGROUND_UNIQUE;
                  break;
               case ItemQualityType.INFAMOUS:
                  this.bmp_background.bitmapData = BMP_BACKGROUND_INFAMOUS;
                  break;
               default:
                  this.bmp_background.transform.colorTransform = Effects["CT_MAGIC_BG_" + _loc3_];
            }
         }
         if(this._showSchematicOutputItem && this._item.category == "schematic")
         {
            if(this.bmp_schemIcon == null)
            {
               this.bmp_schemIcon = new Bitmap(BMP_ICON_SCHEMATIC);
               this.bmp_schemIcon.alpha = 0.5;
            }
            this.bmp_schemIcon.x = 2;
            this.bmp_schemIcon.y = int(this._height - this.bmp_schemIcon.height - 2);
            addChild(this.bmp_schemIcon);
         }
         this.updateQuantityDisplay();
         if(this.mc_border != null)
         {
            if(this._borderColor == null)
            {
               _loc1_.tint(0,0.75);
               this.mc_border.transform.colorTransform = _loc1_.toColorTransform();
               this.mc_border.alpha = 1;
            }
            else
            {
               this.mc_border.transform.colorTransform = this._borderColor.toColorTransform();
               this.mc_border.alpha = 1;
            }
         }
         this.mc_image.filters = null;
         this.mc_image.uri = this._displayItem.getImageURI();
         this.bmp_background.smoothing = true;
      }
      
      private function updateQuantityDisplay() : void
      {
         var _loc2_:String = null;
         if(this._displayItem == null)
         {
            return;
         }
         var _loc1_:int = this._quantity >= 0 ? this._quantity : int(this._displayItem.quantity);
         if(this._displayItem.quantifiable && (this._showQuantityWhenOne || _loc1_ > 1 || this._displayItem.category == "resource" && _loc1_ == 0))
         {
            if(this._quantityAvailable > -1)
            {
               _loc2_ = NumberFormatter.format(this._quantityAvailable,0) + "/" + NumberFormatter.format(_loc1_,0);
            }
            else
            {
               _loc2_ = NumberFormatter.format(_loc1_,0);
            }
            this.txt_quantity.text = _loc2_;
            this.txt_quantity.setProperty("size",this._quantityFieldSize);
            this.txt_quantity.x = int(this.mc_image.x + this.mc_image.width - this.txt_quantity.width - 2);
            this.txt_quantity.y = int(this.mc_image.height - this.txt_quantity.height);
            addChild(this.txt_quantity);
         }
         else if(this.txt_quantity.parent != null)
         {
            this.txt_quantity.parent.removeChild(this.txt_quantity);
         }
      }
      
      private function onImageDisplayed(param1:UIImage) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:GlowFilter = null;
         var _loc5_:GlowFilter = null;
         if(this._displayItem == null)
         {
            return;
         }
         if(this.mc_image.isPNG && this._displayItem.xml != null && this._displayItem.xml.img.@noGlow != "1")
         {
            _loc2_ = [];
            _loc3_ = this._width / 64;
            _loc4_ = ICON_STROKE.clone() as GlowFilter;
            _loc4_.blurX = _loc4_.blurY = Math.max(_loc3_ * ICON_STROKE.blurX,2);
            _loc2_.push(_loc4_);
            _loc5_ = Effects["GLOW_MAGIC_" + ItemQualityType.getName(this._displayItem.qualityType)];
            if(_loc5_ != null)
            {
               _loc5_ = _loc5_.clone() as GlowFilter;
               _loc5_.blurX = _loc5_.blurY = Math.max(_loc3_ * _loc5_.blurX,2);
               _loc2_.push(_loc5_);
            }
            this.mc_image.filters = _loc2_;
         }
         this.imageDisplayed.dispatch(this);
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function set item(param1:Item) : void
      {
         this._item = param1;
         this._displayItem = this._item != null && this._item.category == "schematic" && this._showSchematicOutputItem ? SchematicItem(this._item).schematicItem : this._item;
         this.updateItemDisplay();
      }
      
      public function get displayItem() : Item
      {
         return this._displayItem;
      }
      
      public function set displayItem(param1:Item) : void
      {
         this._displayItem = param1;
      }
      
      public function get uri() : String
      {
         return this.mc_image.uri;
      }
      
      public function set uri(param1:String) : void
      {
         this.mc_image.uri = param1;
      }
      
      public function get showQuantity() : Boolean
      {
         return this.txt_quantity.visible;
      }
      
      public function set showQuantity(param1:Boolean) : void
      {
         this.txt_quantity.visible = param1;
      }
      
      public function get quantity() : int
      {
         return this._quantity;
      }
      
      public function set quantity(param1:int) : void
      {
         this._quantity = param1;
         this.updateQuantityDisplay();
      }
      
      public function get quantityAvailable() : int
      {
         return this._quantityAvailable;
      }
      
      public function set quantityAvailable(param1:int) : void
      {
         this._quantityAvailable = param1;
         this.updateQuantityDisplay();
      }
      
      public function get quantityFieldSize() : Number
      {
         return this._quantityFieldSize;
      }
      
      public function set quantityFieldSize(param1:Number) : void
      {
         this._quantityFieldSize = param1;
         this.updateQuantityDisplay();
      }
      
      public function get showQuantityWhenOne() : Boolean
      {
         return this._showQuantityWhenOne;
      }
      
      public function set showQuantityWhenOne(param1:Boolean) : void
      {
         this._showQuantityWhenOne = param1;
      }
      
      public function get showSchematicOutputItem() : Boolean
      {
         return this._showSchematicOutputItem;
      }
      
      public function set showSchematicOutputItem(param1:Boolean) : void
      {
         this._showSchematicOutputItem = param1;
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
      
      public function get borderColor() : Color
      {
         return this._borderColor;
      }
      
      public function set borderColor(param1:Color) : void
      {
         this._borderColor = param1;
         this.updateItemDisplay();
      }
   }
}

