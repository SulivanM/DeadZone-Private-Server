package thelaststand.app.game.gui.lists
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.network.Network;
   
   public class UIInventoryListItem extends UIPagedListItem
   {
      
      private static const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,1,4,4,1,1);
      
      private static const ICON_STROKE:GlowFilter = new GlowFilter(0,1,4,4,10,1);
      
      private static const BMP_NEW_ICON:BitmapData = new BmpIconNewItem();
      
      private static const NEW_ICON_GLOW:GlowFilter = new GlowFilter(14191125,1,6,6,1,1);
      
      private static const UNEQUIPPABLE_COLOR:ColorMatrix = new ColorMatrix();
      
      private static const BMP_EQUIPPED_OFFENCE:BitmapData = new BmpIconEquipped();
      
      private static const BMP_EQUIPPED_DEFENCE:BitmapData = new BmpIconEquippedDefence();
      
      private static const BMP_SPECIALIZED:BitmapData = new BmpIconSpecialized();
      
      private static const BMP_ICON_EFFECT_TIME:BitmapData = new BmpIconSearchTimer();
      
      UNEQUIPPABLE_COLOR.colorize(13369344,1);
      
      private const STROKE:GlowFilter = new GlowFilter(5460819,1,4,4,10,1);
      
      private var _imageWidth:int = 64;
      
      private var _imageHeight:int = 64;
      
      private var _borderSize:int = 2;
      
      private var _unequippable:Boolean;
      
      private var _showNewIcons:Boolean = true;
      
      private var _showSpecializedIcon:Boolean = false;
      
      private var _itemData:Item;
      
      private var _itemXML:XML;
      
      private var _strokeColor:uint = 5460819;
      
      private var _effective:Boolean = true;
      
      private var _tint:int = -1;
      
      public var displayRollOver:Boolean = true;
      
      public var selectable:Boolean = true;
      
      private var bmp_timed:Bitmap;
      
      private var bmp_equipOffence:Bitmap;
      
      private var bmp_equipDefence:Bitmap;
      
      private var bmp_specialized:Bitmap;
      
      private var bmp_overlay:Bitmap;
      
      private var bmp_newIcon:Bitmap;
      
      private var mc_image:UIItemImage;
      
      private var mc_shape:Shape;
      
      public function UIInventoryListItem(param1:int = 64, param2:Boolean = false)
      {
         super();
         mouseChildren = false;
         this._imageWidth = this._imageHeight = param1;
         _width = int(this._imageWidth + this._borderSize * 2);
         _height = int(this._imageHeight + this._borderSize * 2);
         this.mc_shape = new Shape();
         this.mc_shape.graphics.beginFill(0,1);
         this.mc_shape.graphics.drawRect(0,0,this._imageWidth,this._imageHeight);
         this.mc_shape.graphics.endFill();
         this.mc_shape.x = this.mc_shape.y = this._borderSize;
         this.mc_shape.filters = [this.STROKE,SHADOW];
         addChild(this.mc_shape);
         this.mc_image = new UIItemImage(this._imageWidth,this._imageHeight);
         if(param2)
         {
            this.mc_image.uri = "images/items/none.jpg";
         }
         this.mc_image.x = this.mc_image.y = this._borderSize;
         this.mc_image.mouseEnabled = false;
         addChild(this.mc_image);
         this.bmp_newIcon = new Bitmap(BMP_NEW_ICON);
         this.bmp_newIcon.filters = [NEW_ICON_GLOW];
         this.bmp_newIcon.x = this.mc_shape.x + 2;
         this.bmp_newIcon.y = this.mc_shape.y + 2;
         this.bmp_equipOffence = new Bitmap(BMP_EQUIPPED_OFFENCE);
         this.bmp_equipOffence.x = int(this._borderSize - 1);
         this.bmp_equipOffence.y = int(_height - this._borderSize - this.bmp_equipOffence.height + 1);
         this.bmp_equipDefence = new Bitmap(BMP_EQUIPPED_DEFENCE);
         this.bmp_equipDefence.x = int(this._borderSize - 2);
         this.bmp_equipDefence.y = int(_height - this._borderSize - this.bmp_equipDefence.height + 1);
         this.bmp_specialized = new Bitmap(BMP_SPECIALIZED);
         this.bmp_specialized.x = int(_width - this.bmp_specialized.width - this._borderSize);
         this.bmp_specialized.y = int(_height - this.bmp_specialized.height - this._borderSize);
         this.bmp_overlay = new Bitmap();
         this.bmp_overlay.filters = [new DropShadowFilter(0,0,0,1,5,5,0.75,2)];
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public static function getStrokeColor(param1:Item) : int
      {
         var _loc2_:Color = new Color(5460819);
         if(param1 != null)
         {
            if(param1.qualityType == ItemQualityType.PREMIUM)
            {
               _loc2_.RGB = Effects.COLOR_PREMIUM;
               _loc2_.tint(0,0.5);
            }
            else if(param1.qualityType != ItemQualityType.WHITE)
            {
               _loc2_.RGB = Effects["COLOR_" + ItemQualityType.getName(param1.qualityType)];
               switch(param1.qualityType)
               {
                  case ItemQualityType.RARE:
                  case ItemQualityType.UNIQUE:
                  case ItemQualityType.INFAMOUS:
                     break;
                  default:
                     _loc2_.tint(0,0.5);
               }
            }
         }
         return _loc2_.RGB;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.mc_shape.filters = [];
         this.mc_image.dispose();
         if(this.bmp_overlay.bitmapData != null)
         {
            this.bmp_overlay.bitmapData = null;
         }
         this.bmp_overlay.filters = [];
         this.bmp_newIcon.bitmapData = null;
         this.bmp_equipOffence.bitmapData = null;
         this.bmp_equipDefence.bitmapData = null;
         this.bmp_specialized.bitmapData = null;
         if(this.bmp_timed != null)
         {
            this.bmp_timed.bitmapData = null;
         }
         this._itemData = null;
         this._itemXML = null;
      }
      
      public function setOverlay(param1:BitmapData = null) : void
      {
         this.bmp_overlay.bitmapData = param1;
         this.bmp_overlay.x = int((_width - this.bmp_overlay.width) * 0.5);
         this.bmp_overlay.y = int((_height - this.bmp_overlay.height) * 0.5);
         if(param1 == null)
         {
            if(this.bmp_overlay.parent != null)
            {
               this.bmp_overlay.parent.removeChild(this.bmp_overlay);
            }
         }
         else
         {
            addChild(this.bmp_overlay);
         }
      }
      
      public function updateNewFlag() : void
      {
         if(this._itemData == null)
         {
            return;
         }
         if(this._showNewIcons && this._itemData.isNew == true)
         {
            addChild(this.bmp_newIcon);
         }
         else if(this.bmp_newIcon.parent != null)
         {
            this.bmp_newIcon.parent.removeChild(this.bmp_newIcon);
         }
      }
      
      public function forceNewIconDisplay(param1:Boolean) : void
      {
         if(param1)
         {
            addChild(this.bmp_newIcon);
         }
         else if(this.bmp_newIcon.parent != null)
         {
            this.bmp_newIcon.parent.removeChild(this.bmp_newIcon);
         }
      }
      
      private function updateStrokeColor() : void
      {
         this._strokeColor = 5460819;
         if(this._itemData != null)
         {
            if(!this._effective)
            {
               this._strokeColor = 8978432;
            }
            else
            {
               this._strokeColor = getStrokeColor(this._itemData);
            }
         }
         this.STROKE.color = this._strokeColor;
         this.mc_shape.filters = [this.STROKE,SHADOW];
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected || !enabled || !this.displayRollOver)
         {
            return;
         }
         TweenMax.to(this.mc_shape,0.1,{"glowFilter":{"color":11184810}});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected || !enabled || !this.displayRollOver)
         {
            return;
         }
         TweenMax.to(this.mc_shape,0.25,{"glowFilter":{"color":this._strokeColor}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(this._itemData != null)
         {
            if(param1.shiftKey)
            {
               _loc2_ = JSON.stringify(this._itemData.toChatObject());
               dispatchEvent(new ChatLinkEvent(ChatLinkEvent.ADD_TO_CHAT,ChatLinkEvent.LT_ITEM,_loc2_));
            }
            if(param1.ctrlKey && Network.getInstance().playerData.isAdmin)
            {
               Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,this._itemData.id,false);
            }
         }
         if(selected || !enabled)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get image() : UIItemImage
      {
         return this.mc_image;
      }
      
      public function get itemData() : Item
      {
         return this._itemData;
      }
      
      public function set itemData(param1:Item) : void
      {
         var _loc2_:int = 0;
         this._itemData = param1;
         this._itemXML = this._itemData != null ? this._itemData.xml : null;
         id = this._itemData != null ? this._itemData.id : null;
         this.mc_image.item = this._itemData;
         if(this.bmp_equipOffence.parent != null)
         {
            this.bmp_equipOffence.parent.removeChild(this.bmp_equipOffence);
         }
         if(this.bmp_equipDefence.parent != null)
         {
            this.bmp_equipDefence.parent.removeChild(this.bmp_equipDefence);
         }
         if(this.bmp_newIcon.parent != null)
         {
            this.bmp_newIcon.parent.removeChild(this.bmp_newIcon);
         }
         if(this.bmp_timed != null && this.bmp_timed.parent != null)
         {
            this.bmp_timed.parent.removeChild(this.bmp_timed);
         }
         if(this._itemData == null)
         {
            if(this.bmp_specialized.parent != null)
            {
               this.bmp_specialized.parent.removeChild(this.bmp_specialized);
            }
         }
         else
         {
            _loc2_ = int(this._borderSize - 1);
            if(this._itemData.category == "weapon" || this._itemData.category == "gear")
            {
               if(Network.getInstance().playerData.loadoutManager.isEquippedToOffence(this._itemData))
               {
                  this.bmp_equipOffence.x = _loc2_;
                  _loc2_ += int(this.bmp_equipOffence.width - 6);
                  addChild(this.bmp_equipOffence);
               }
               if(Network.getInstance().playerData.loadoutManager.isEquippedToDefence(this._itemData))
               {
                  this.bmp_equipDefence.x = _loc2_;
                  addChild(this.bmp_equipDefence);
               }
            }
            else if(this._itemData.category == "clothing")
            {
               if(Network.getInstance().playerData.loadoutManager.isEquippedClothing(ClothingAccessory(this._itemData)))
               {
                  this.bmp_equipOffence.x = _loc2_;
                  _loc2_ += int(this.bmp_equipOffence.width - 6);
                  addChild(this.bmp_equipOffence);
               }
            }
            else if(this._itemData.category == "effect")
            {
               if(EffectItem(this._itemData).effect.time > 0)
               {
                  if(this.bmp_timed == null)
                  {
                     this.bmp_timed = new Bitmap(BMP_ICON_EFFECT_TIME);
                  }
                  this.bmp_timed.x = int(_width - this.bmp_timed.width - 4);
                  this.bmp_timed.y = int(_height - this.bmp_timed.height - 4);
                  addChild(this.bmp_timed);
               }
               if(Network.getInstance().playerData.compound.effects.containsEffect(EffectItem(this._itemData).effect))
               {
                  this.bmp_equipOffence.x = _loc2_;
                  this.bmp_equipOffence.visible = true;
                  addChild(this.bmp_equipOffence);
               }
            }
         }
         this.updateStrokeColor();
         this.updateNewFlag();
      }
      
      public function get unequippable() : Boolean
      {
         return this._unequippable;
      }
      
      public function set unequippable(param1:Boolean) : void
      {
         this._unequippable = param1;
         filters = !this._effective || this._unequippable ? [UNEQUIPPABLE_COLOR.filter] : null;
         cacheAsBitmap = this._unequippable ? true : false;
         if(this._tint != -1)
         {
            this.tint = this._tint;
         }
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         TweenMax.to(this.mc_shape,0.1,{"glowFilter":{"color":(selected ? 16777215 : this._strokeColor)}});
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         mouseEnabled = super.enabled;
         this.alpha = super.enabled ? 1 : 0.3;
      }
      
      public function get showEquippedIcon() : Boolean
      {
         return this.bmp_equipOffence.visible;
      }
      
      public function set showEquippedIcon(param1:Boolean) : void
      {
         this.bmp_equipOffence.visible = param1;
         this.bmp_equipDefence.visible = param1;
      }
      
      public function get showSpecializedIcon() : Boolean
      {
         return this._showSpecializedIcon;
      }
      
      public function set showSpecializedIcon(param1:Boolean) : void
      {
         this._showSpecializedIcon = param1;
         if(this._showSpecializedIcon)
         {
            addChild(this.bmp_specialized);
         }
         else if(this.bmp_specialized.parent != null)
         {
            this.bmp_specialized.parent.removeChild(this.bmp_specialized);
         }
      }
      
      public function get showNewIcon() : Boolean
      {
         return this._showNewIcons;
      }
      
      public function set showNewIcon(param1:Boolean) : void
      {
         this._showNewIcons = param1;
         this.updateNewFlag();
      }
      
      public function get effective() : Boolean
      {
         return this._effective;
      }
      
      public function set effective(param1:Boolean) : void
      {
         this._effective = param1;
         this.updateStrokeColor();
         filters = !this._effective || this._unequippable ? [UNEQUIPPABLE_COLOR.filter] : null;
      }
      
      public function get tint() : int
      {
         return this._tint;
      }
      
      public function set tint(param1:int) : void
      {
         var _loc2_:ColorMatrix = null;
         this._tint = param1;
         if(this._tint < 0 || this._tint > 16777215)
         {
            this._tint = -1;
            filters = null;
            this.selectable = true;
            if(this._unequippable)
            {
               this.unequippable = this._unequippable;
            }
         }
         else
         {
            _loc2_ = new ColorMatrix();
            _loc2_.colorize(this._tint,1);
            filters = [_loc2_.filter];
            this.selectable = false;
         }
      }
   }
}

