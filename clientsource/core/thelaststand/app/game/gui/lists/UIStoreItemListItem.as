package thelaststand.app.game.gui.lists
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.text.TextFormatAlign;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.BitmapLibrary;
   import thelaststand.app.data.Currency;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.common.lang.Language;
   
   public class UIStoreItemListItem extends UIPagedListItem
   {
      
      private static const BMP_CASH_BG:BitmapData = new BmpCashItemBg();
      
      private static const BMP_NEW_ICON:BitmapData = new BmpIconNewItem();
      
      private static const NEW_ICON_GLOW:GlowFilter = new GlowFilter(14191125,1,6,6,1,1);
      
      private static const UNEQUIPPABLE_COLOR:ColorMatrix = new ColorMatrix();
      
      private static const BMP_ICON_EFFECT_TIME:BitmapData = new BmpIconSearchTimer();
      
      UNEQUIPPABLE_COLOR.colorize(13369344,1);
      
      private const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,1,4,4,1,1);
      
      private const STROKE:GlowFilter = new GlowFilter(5460819,1,4,4,10,1);
      
      private var _borderSize:int = 2;
      
      private var _costAreaHeight:int = 20;
      
      private var _imageWidth:int;
      
      private var _imageHeight:int;
      
      private var _item:Item;
      
      private var _strokeColor:uint = 5460819;
      
      private var _showRed:Boolean = false;
      
      private var _showCost:Boolean = true;
      
      private var _storeItem:StoreItem;
      
      private var bmp_timed:Bitmap;
      
      private var bmp_sash:Bitmap;
      
      private var bmp_currencyIcon:Bitmap;
      
      private var bmp_newIcon:Bitmap;
      
      private var bmp_cashBg:Bitmap;
      
      private var mc_image:UIItemImage;
      
      private var mc_shape:Sprite;
      
      private var mc_costBackground:Sprite;
      
      private var txt_cost:BodyTextField;
      
      private var txt_sale:BodyTextField;
      
      private var txt_admin:BodyTextField;
      
      public function UIStoreItemListItem()
      {
         super();
         this._imageWidth = this._imageHeight = 64;
         _width = int(this._imageWidth + this._borderSize * 2);
         _height = int(this._imageHeight + this._costAreaHeight + this._borderSize * 2);
         this.mc_shape = new Sprite();
         this.mc_shape.graphics.beginFill(0,1);
         this.mc_shape.graphics.drawRect(0,0,this._imageWidth,this._imageHeight + this._costAreaHeight);
         this.mc_shape.graphics.endFill();
         this.mc_shape.x = this.mc_shape.y = this._borderSize;
         this.mc_shape.filters = [this.STROKE,this.SHADOW];
         addChild(this.mc_shape);
         this.mc_image = new UIItemImage(this._imageWidth,this._imageHeight);
         this.mc_image.mouseEnabled = this.mc_image.mouseChildren = false;
         this.mc_image.showSchematicOutputItem = true;
         this.mc_image.x = this.mc_image.y = this._borderSize;
         addChild(this.mc_image);
         this.mc_costBackground = new Sprite();
         this.mc_costBackground.x = this.mc_shape.x;
         this.mc_costBackground.y = int(this.mc_shape.y + this._imageHeight);
         addChild(this.mc_costBackground);
         this.bmp_newIcon = new Bitmap(BMP_NEW_ICON);
         this.bmp_newIcon.filters = [NEW_ICON_GLOW];
         this.bmp_newIcon.x = this.mc_shape.x + 2;
         this.bmp_newIcon.y = this.mc_shape.y + 2;
         this.bmp_currencyIcon = new Bitmap();
         this.bmp_currencyIcon.filters = [Effects.ICON_SHADOW];
         this.txt_cost = new BodyTextField({
            "text":"0",
            "color":16777215,
            "size":13,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_cost.y = int(this.mc_costBackground.y + (this._costAreaHeight - this.txt_cost.height) * 0.5);
         mouseChildren = false;
         hitArea = this.mc_shape;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      private function drawCostBackground() : void
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc1_:Boolean = !this._showCost || this._storeItem == null || this._storeItem.isCollectionOnly;
         if(_loc1_ || this._storeItem.currency == Currency.FUEL || this._storeItem.currency == Currency.ALLIANCE_TOKENS)
         {
            if(_loc1_)
            {
               _loc2_ = 2302755;
            }
            else
            {
               switch(this._storeItem.currency)
               {
                  case Currency.FUEL:
                     _loc2_ = 4083477;
                     break;
                  case Currency.ALLIANCE_TOKENS:
                     _loc2_ = 12072974;
               }
            }
            this.mc_costBackground.graphics.clear();
            this.mc_costBackground.graphics.beginFill(Color.scale(_loc2_,0.35));
            this.mc_costBackground.graphics.drawRect(0,0,this._imageWidth,this._costAreaHeight);
            this.mc_costBackground.graphics.drawRect(1,1,this._imageWidth - 2,this._costAreaHeight - 2);
            this.mc_costBackground.graphics.endFill();
            this.mc_costBackground.graphics.beginFill(_loc2_);
            this.mc_costBackground.graphics.drawRect(1,1,this._imageWidth - 2,this._costAreaHeight - 2);
            this.mc_costBackground.graphics.endFill();
            if(this.bmp_cashBg != null && this.bmp_cashBg.parent != null)
            {
               this.bmp_cashBg.parent.removeChild(this.bmp_cashBg);
            }
         }
         else
         {
            this.mc_costBackground.graphics.clear();
            this.mc_costBackground.graphics.beginFill(2510085);
            this.mc_costBackground.graphics.drawRect(0,0,this._imageWidth,this._costAreaHeight);
            _loc3_ = 2;
            if(this.bmp_cashBg == null)
            {
               this.bmp_cashBg = new Bitmap(BMP_CASH_BG);
            }
            this.bmp_cashBg.width = int(this._imageWidth - _loc3_ * 2);
            this.bmp_cashBg.height = int(this._costAreaHeight - _loc3_ * 2);
            this.bmp_cashBg.x = _loc3_;
            this.bmp_cashBg.y = _loc3_;
            this.mc_costBackground.addChild(this.bmp_cashBg);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TweenMax.killChildTweensOf(this);
         this.txt_cost.dispose();
         this.txt_cost = null;
         this.bmp_currencyIcon.bitmapData = null;
         this.bmp_currencyIcon.filters = [];
         this.bmp_currencyIcon = null;
         this.bmp_newIcon.bitmapData = null;
         this.bmp_newIcon.filters = [];
         this.bmp_newIcon = null;
         this.mc_image.dispose();
         this.mc_image = null;
         if(this.bmp_cashBg != null)
         {
            this.bmp_cashBg.bitmapData = null;
         }
         if(this.txt_admin != null)
         {
            this.txt_admin.dispose();
         }
         if(this.txt_sale != null)
         {
            this.txt_sale.dispose();
         }
         if(this.bmp_sash != null)
         {
            this.bmp_sash.bitmapData.dispose();
         }
         if(this.bmp_timed != null)
         {
            this.bmp_timed.bitmapData = null;
         }
         this._item = null;
      }
      
      private function setCurrencyIcon(param1:String) : void
      {
         this.bmp_currencyIcon.scaleX = this.bmp_currencyIcon.scaleY = 1;
         this.bmp_currencyIcon.bitmapData = BitmapLibrary.getIcon(param1);
         this.bmp_currencyIcon.visible = this.bmp_currencyIcon.bitmapData != null;
         this.bmp_currencyIcon.pixelSnapping = PixelSnapping.AUTO;
         this.bmp_currencyIcon.smoothing = true;
         this.bmp_currencyIcon.height = this._costAreaHeight - 4;
         this.bmp_currencyIcon.scaleX = this.bmp_currencyIcon.scaleY;
         this.bmp_currencyIcon.y = int(this.mc_costBackground.y + (this._costAreaHeight - this.bmp_currencyIcon.height) * 0.5);
      }
      
      private function updateDisplay() : void
      {
         var _loc1_:String = null;
         var _loc2_:Matrix = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         if(this.bmp_timed != null && this.bmp_timed.parent != null)
         {
            this.bmp_timed.parent.removeChild(this.bmp_timed);
         }
         if(this.bmp_sash != null && this.bmp_sash.parent != null)
         {
            this.bmp_sash.parent.removeChild(this.bmp_sash);
         }
         if(this.txt_sale != null && this.txt_sale.parent != null)
         {
            this.txt_sale.parent.removeChild(this.txt_sale);
         }
         if(this.bmp_newIcon.parent != null)
         {
            this.bmp_newIcon.parent.removeChild(this.bmp_newIcon);
         }
         if(this.txt_admin != null && this.txt_admin.parent != null)
         {
            this.txt_admin.parent.removeChild(this.txt_admin);
         }
         if(this._storeItem == null)
         {
            if(this.bmp_currencyIcon.parent != null)
            {
               this.bmp_currencyIcon.parent.removeChild(this.bmp_currencyIcon);
            }
            if(this.txt_cost.parent != null)
            {
               this.txt_cost.parent.removeChild(this.txt_cost);
            }
            this.mc_image.item = null;
            this.drawCostBackground();
            this._strokeColor = this.STROKE.color = 5460819;
            this.mc_shape.filters = [this.STROKE,this.SHADOW];
            return;
         }
         this.mc_image.item = this._storeItem.item;
         if(this._storeItem.isNew)
         {
            addChild(this.bmp_newIcon);
         }
         if(this._storeItem.isOnSale)
         {
            if(this.txt_sale == null)
            {
               this.txt_sale = new BodyTextField({
                  "color":16777215,
                  "size":10,
                  "bold":true,
                  "align":TextFormatAlign.CENTER,
                  "filters":[new GlowFilter(4330246,1,3,3,10,1)]
               });
            }
            if(this.bmp_sash == null)
            {
               this.bmp_sash = new Bitmap(new BmpSaleItemSash());
            }
            if(this._storeItem.showOriginalCost)
            {
               _loc1_ = Language.getInstance().getString("sale_was",NumberFormatter.format(this._storeItem.originalCost,0));
            }
            else
            {
               _loc1_ = Language.getInstance().getString("sale_perc",Math.ceil(this._storeItem.savingPercentage * 100) + "%");
            }
            _loc2_ = new Matrix();
            this.txt_sale.transform.matrix = _loc2_;
            this.txt_sale.text = _loc1_;
            this.bmp_sash.x = -4;
            this.bmp_sash.y = -3;
            _loc3_ = this.txt_sale.width * 0.5;
            _loc4_ = this.txt_sale.height * 0.5;
            _loc5_ = 21.5;
            _loc6_ = 15;
            _loc2_.translate(-_loc3_,-_loc4_);
            _loc2_.rotate(-32 * Math.PI / 180);
            _loc2_.translate(this.bmp_sash.x + _loc5_,this.bmp_sash.y + _loc6_);
            this.txt_sale.transform.matrix = _loc2_;
            addChild(this.bmp_sash);
            addChild(this.txt_sale);
         }
         if(this._storeItem.item is EffectItem)
         {
            if(EffectItem(this._storeItem.item).effect.time > 0)
            {
               if(this.bmp_timed == null)
               {
                  this.bmp_timed = new Bitmap(BMP_ICON_EFFECT_TIME);
               }
               this.bmp_timed.x = int(_width - this.bmp_timed.width - 4);
               this.bmp_timed.y = int(_height - this._costAreaHeight - this.bmp_timed.height - 4);
               addChild(this.bmp_timed);
            }
         }
         this.drawCostBackground();
         if(this._showCost && !this._storeItem.isCollectionOnly)
         {
            _loc7_ = this._storeItem.cost;
            this.setCurrencyIcon(this._storeItem.currency);
            this.txt_cost.textColor = this._storeItem.currency == Currency.FUEL ? 16777215 : 12189549;
            if(this._storeItem.currency == Currency.US_DOLLARS)
            {
               this.txt_cost.text = "$" + NumberFormatter.format(_loc7_,2,",",false);
            }
            else
            {
               this.txt_cost.text = NumberFormatter.format(_loc7_,0);
            }
            _loc8_ = this.txt_cost.width + this.bmp_currencyIcon.width + 2;
            this.txt_cost.x = int((_width - _loc8_) * 0.5);
            this.bmp_currencyIcon.x = int(this.txt_cost.x + this.txt_cost.width + 2);
            if(this.bmp_currencyIcon.parent == null)
            {
               addChild(this.bmp_currencyIcon);
            }
            if(this.txt_cost.parent == null)
            {
               addChild(this.txt_cost);
            }
         }
         if(this._storeItem.item != null && (this._storeItem.item.qualityType == ItemQualityType.PREMIUM || this._storeItem.item.qualityType != ItemQualityType.WHITE))
         {
            this._strokeColor = new Color(Effects["COLOR_" + ItemQualityType.getName(this._storeItem.item.qualityType)]).tint(0,0.5).RGB;
         }
         else
         {
            this._strokeColor = 5460819;
         }
         this.STROKE.color = this._strokeColor;
         this.mc_shape.filters = [this.STROKE,this.SHADOW];
         if(this._storeItem.adminOnly)
         {
            if(this.txt_admin == null)
            {
               this.txt_admin = new BodyTextField({
                  "color":11141120,
                  "size":24,
                  "bold":true,
                  "filters":[Effects.STROKE]
               });
            }
            this.txt_admin.text = "ADMIN";
            this.txt_admin.alpha = 0.75;
            this.txt_admin.rotation = 45;
            this.txt_admin.x = int((_width - this.txt_admin.width) * 0.5 + 25);
            this.txt_admin.y = int((_height - this._costAreaHeight - this.txt_admin.height) * 0.5 - 5);
            addChild(this.txt_admin);
         }
         else if(this.txt_admin != null)
         {
            if(this.txt_admin.parent != null)
            {
               this.txt_admin.parent.removeChild(this.txt_admin);
            }
         }
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
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         mouseEnabled = super.enabled;
         alpha = super.enabled ? 1 : 0.3;
         this.txt_cost.visible = this.bmp_currencyIcon.visible = super.enabled;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         TweenMax.to(this.mc_shape,0.1,{"glowFilter":{"color":(selected ? 16777215 : this._strokeColor)}});
      }
      
      public function get showRed() : Boolean
      {
         return this._showRed;
      }
      
      public function set showRed(param1:Boolean) : void
      {
         this._showRed = param1;
         this.mc_image.filters = this._showRed ? [UNEQUIPPABLE_COLOR.filter] : [];
      }
      
      public function get storeItem() : StoreItem
      {
         return this._storeItem;
      }
      
      public function set storeItem(param1:StoreItem) : void
      {
         this._storeItem = param1;
         this.updateDisplay();
      }
      
      public function get showCost() : Boolean
      {
         return this._showCost;
      }
      
      public function set showCost(param1:Boolean) : void
      {
         this._showCost = param1;
         this.updateDisplay();
      }
   }
}

