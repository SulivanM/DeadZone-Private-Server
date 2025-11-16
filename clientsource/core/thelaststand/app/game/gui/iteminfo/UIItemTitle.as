package thelaststand.app.game.gui.iteminfo
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.AttireFlags;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.GearType;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemBindState;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.MedicalItem;
   import thelaststand.app.game.data.SchematicItem;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponType;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIItemTitle extends UIComponent
   {
      
      private static const BMP_BIND_ON_EQUIP:BitmapData = new BmpIconUnlockedTiny();
      
      private static const BMP_BIND_BOUND:BitmapData = new BmpIconLockedTiny();
      
      private var _item:Item;
      
      private var _loadout:SurvivorLoadout;
      
      private var _options:Object;
      
      private var _width:int = 274;
      
      private var _height:int = 0;
      
      private var _showTypeGlobal:Boolean = true;
      
      private var _showLevelGlobal:Boolean = true;
      
      private var _showLevelItem:Boolean = true;
      
      private var _limitInfos:Vector.<UILimitInfo> = new Vector.<UILimitInfo>();
      
      private var bmp_titleBar:Bitmap;
      
      private var bmp_bind:Bitmap;
      
      private var txt_itemName:BodyTextField;
      
      private var txt_itemType:BodyTextField;
      
      private var txt_itemLevel:BodyTextField;
      
      private var txt_itemBind:BodyTextField;
      
      public function UIItemTitle()
      {
         super();
         this.bmp_titleBar = new Bitmap(new BmpTopBarBackground(),"always",true);
         this.bmp_titleBar.width = this._width;
         this.bmp_titleBar.height = 28;
         addChild(this.bmp_titleBar);
         this.txt_itemName = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":15,
            "bold":true
         });
         this.txt_itemName.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_itemName);
         this.txt_itemType = new BodyTextField({
            "text":" ",
            "color":14854212,
            "size":12,
            "antiAliasType":AntiAliasType.ADVANCED,
            "thickness":150
         });
         this.txt_itemType.x = 2;
         this.txt_itemType.y = int(this.bmp_titleBar.y + this.bmp_titleBar.height + 4);
         addChild(this.txt_itemType);
         this.txt_itemLevel = new BodyTextField({
            "text":" ",
            "color":Effects.COLOR_NEUTRAL,
            "size":12,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_itemLevel.x = this._width;
         this.txt_itemLevel.y = int(this.txt_itemType.y);
         addChild(this.txt_itemLevel);
         this._height = int(this.txt_itemType.y + this.txt_itemType.height);
      }
      
      public function get showType() : Boolean
      {
         return this._showTypeGlobal;
      }
      
      public function set showType(param1:Boolean) : void
      {
         this._showTypeGlobal = param1;
         this.txt_itemType.visible = this._showTypeGlobal;
      }
      
      public function get showLevel() : Boolean
      {
         return this._showLevelGlobal;
      }
      
      public function set showLevel(param1:Boolean) : void
      {
         this._showLevelGlobal = param1;
         this.txt_itemLevel.visible = this._showLevelGlobal && this._showLevelItem;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_titleBar.bitmapData.dispose();
         this.txt_itemName.dispose();
         this.txt_itemType.dispose();
         this.txt_itemLevel.dispose();
         if(this.bmp_bind != null)
         {
            this.bmp_bind.bitmapData = null;
         }
         if(this.txt_itemBind != null)
         {
            this.txt_itemBind.dispose();
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._limitInfos.length)
         {
            this._limitInfos[_loc1_].dispose();
            _loc1_++;
         }
         this._limitInfos = null;
      }
      
      public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc4_:int = 0;
         while(_loc4_ < this._limitInfos.length)
         {
            this._limitInfos[_loc4_].dispose();
            _loc4_++;
         }
         this._limitInfos.length = 0;
         this._item = param1;
         this._loadout = param2;
         this._options = param3 || {};
         redraw();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc3_:EffectItem = null;
         var _loc4_:ColorTransform = null;
         var _loc5_:uint = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:UILimitInfo = null;
         var _loc13_:Array = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:Weapon = null;
         var _loc17_:MedicalItem = null;
         var _loc18_:ClothingAccessory = null;
         var _loc19_:String = null;
         var _loc20_:uint = 0;
         var _loc21_:Gear = null;
         var _loc22_:XMLList = null;
         var _loc23_:String = null;
         if(this._item == null)
         {
            this.bmp_titleBar.transform.colorTransform = Effects.CT_DEFAULT;
            this.txt_itemLevel.visible = false;
            this.txt_itemType.visible = false;
            this.txt_itemName.visible = false;
            return;
         }
         var _loc2_:Language = Language.getInstance();
         this.bmp_titleBar.width = this._width;
         if(this._item is EffectItem && this._item.qualityType == ItemQualityType.NONE)
         {
            _loc3_ = EffectItem(this._item);
            _loc10_ = _loc3_.effect.group.toUpperCase();
            _loc4_ = Effects["CT_EFFECT_BG_" + _loc10_];
            _loc5_ = new Color(Effects["COLOR_EFFECT_" + _loc10_]).multiply(2).RGB;
         }
         else
         {
            _loc11_ = ItemQualityType.getName(this._item.qualityType);
            _loc4_ = Effects["CT_MAGIC_BG_" + _loc11_];
            _loc5_ = uint(Effects["COLOR_" + _loc11_]);
            switch(this._item.qualityType)
            {
               case ItemQualityType.RARE:
               case ItemQualityType.UNIQUE:
               case ItemQualityType.INFAMOUS:
                  _loc5_ = new Color(_loc5_).multiply(2).RGB;
            }
         }
         if(_loc4_ != null)
         {
            this.bmp_titleBar.transform.colorTransform = _loc4_;
         }
         var _loc6_:String = this._item.getName();
         var _loc7_:Number = this._item.quantity;
         if(this._loadout != null && this._item.quantifiable)
         {
            if(this._options.showEquippedQuantity)
            {
               _loc7_ = this._loadout.getQuantityEquipped(this._item);
            }
            else
            {
               _loc7_ = Network.getInstance().playerData.loadoutManager.getAvailableQuantity(this._item,this._loadout.survivor,this._loadout.type);
            }
         }
         if(this._item.quantifiable && _loc7_ > 1)
         {
            _loc6_ += " x " + NumberFormatter.format(_loc7_,0);
         }
         if(this._options.adminOnly === true)
         {
            _loc6_ = "<font color=\'#AA0000\'><b>[ADMIN]</b></font> " + _loc6_;
         }
         this.txt_itemName.htmlText = _loc6_;
         this.txt_itemName.textColor = _loc5_;
         this.txt_itemName.maxWidth = int(this.bmp_titleBar.width - 20);
         this.txt_itemName.x = int(this.bmp_titleBar.x + (this.bmp_titleBar.width - this.txt_itemName.width) * 0.5);
         this.txt_itemName.y = Math.round(this.bmp_titleBar.y + (this.bmp_titleBar.height - this.txt_itemName.height) * 0.5);
         var _loc8_:int = int(this.bmp_titleBar.y + this.bmp_titleBar.height + 4);
         if(this._options.limits != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this._options.limits.length)
            {
               _loc12_ = this._options.limits[_loc1_];
               _loc12_.width = this._width;
               _loc12_.x = this.bmp_titleBar.x;
               _loc12_.y = _loc8_;
               _loc12_.redraw();
               addChild(_loc12_);
               this._limitInfos.push(_loc12_);
               _loc8_ += _loc12_.height + 4;
               _loc1_++;
            }
         }
         var _loc9_:int = int(_loc8_);
         this.txt_itemType.visible = this._showTypeGlobal;
         if(this.txt_itemType.visible)
         {
            this._showLevelItem = false;
            _loc13_ = [];
            if(this._item.craftData != null && this._item.qualityType != ItemQualityType.INFAMOUS)
            {
               _loc13_.push(_loc2_.getString("itm_types.crafted_prefix"));
            }
            if(this._item is SchematicItem)
            {
               _loc13_.push(_loc2_.getString("itm_types.schematic"));
               this._showLevelItem = true;
            }
            else if(this._item is EffectItem)
            {
               _loc3_ = EffectItem(this._item);
               _loc15_ = _loc2_.getString("effect_group." + _loc3_.effect.group);
               switch(_loc3_.effect.group)
               {
                  case "war":
                     _loc13_.push(_loc2_.getString("itm_types.effect-war",_loc15_));
                     break;
                  case "alliance":
                     _loc13_.push(_loc2_.getString("itm_types.effect-alliance",_loc15_));
                     break;
                  case "misc":
                     _loc13_.push(_loc2_.getString("itm_types.effect-misc",_loc15_));
                     break;
                  case "tactics":
                     _loc13_.push(_loc2_.getString("itm_types.effect-tactics",_loc15_));
                     this._showLevelItem = true;
                     break;
                  default:
                     _loc13_.push(_loc2_.getString("itm_types.effect-book",_loc15_));
               }
            }
            else if(this._item is Weapon)
            {
               _loc16_ = Weapon(this._item);
               _loc13_.push(_loc2_.getString("weap_class." + _loc16_.weaponClass));
               this._showLevelItem = true;
            }
            else if(this._item is MedicalItem)
            {
               _loc17_ = MedicalItem(this._item);
               this._showLevelItem = false;
               _loc13_.push(_loc2_.getString("itm_types." + this._item.category),"-",_loc2_.getString("med_class." + _loc17_.medicalClass),"-",_loc2_.getString("med_grade",_loc17_.medicalGrade));
            }
            else if(this._item is ClothingAccessory)
            {
               _loc18_ = ClothingAccessory(this._item);
               this._showLevelItem = false;
               _loc20_ = uint(_loc18_.getAttireFlags(Gender.MALE) | _loc18_.getAttireFlags(Gender.FEMALE));
               if((_loc20_ & AttireFlags.CLOTHING) != 0)
               {
                  _loc19_ = _loc2_.getString("itm_types.clothing");
               }
               else
               {
                  _loc19_ = _loc2_.getString("itm_types.clothing_acc");
               }
               _loc13_.push(_loc19_);
            }
            else if(this._item is Gear)
            {
               _loc21_ = Gear(this._item);
               this._showLevelItem = true;
               if(_loc21_.gearType & GearType.ACTIVE)
               {
                  _loc13_.push(_loc2_.getString("gear_type.active",_loc2_.getString("itm_types." + this._item.category)));
               }
               else
               {
                  _loc13_.push(_loc2_.getString("itm_types." + this._item.category));
               }
            }
            else if(this._item.category == "craftkit")
            {
               _loc22_ = this._item.xml.kit.category;
               if(_loc22_.length() == 1)
               {
                  _loc13_.push(_loc2_.getString("craftkit_type." + _loc22_[0].toString(),_loc2_.getString("itm_types." + this._item.category)));
               }
               else
               {
                  _loc13_.push(_loc2_.getString("itm_types." + this._item.category));
               }
            }
            else
            {
               _loc13_.push(_loc2_.getString("itm_types." + this._item.category));
            }
            _loc14_ = _loc13_.join(" ");
            if(this.showQualityPrefix(this._item))
            {
               _loc14_ = _loc2_.getString("quality_type." + ItemQualityType.getName(this._item.qualityType).toLowerCase(),_loc14_);
            }
            if(this._item is Weapon)
            {
               if(Weapon(this._item).weaponType & WeaponType.IMPROVISED)
               {
                  _loc14_ = _loc2_.getString("quality_type.improvised",_loc14_);
               }
            }
            if(this._item.isVintage)
            {
               _loc14_ = Language.getInstance().getString("quality_type.vintage",_loc14_);
            }
            this.txt_itemType.text = _loc14_;
            this.txt_itemType.y = _loc9_;
         }
         this.txt_itemLevel.visible = this._showLevelGlobal && this._showLevelItem;
         if(this.txt_itemLevel.visible)
         {
            _loc23_ = this._item.level < 0 ? "?" : String(this._item.level + 1);
            this.txt_itemLevel.text = _loc2_.getString("level",_loc23_);
            this.txt_itemLevel.x = int(this._width - this.txt_itemLevel.width - this.txt_itemType.x);
            this.txt_itemLevel.y = _loc9_;
            this.txt_itemLevel.textColor = this._loadout != null && this._item.level > this._loadout.survivor.level ? Effects.COLOR_WARNING : Effects.COLOR_NEUTRAL;
         }
         if(this.txt_itemLevel.visible || this.txt_itemType.visible)
         {
            _loc8_ += int(this.txt_itemType.height + 4);
         }
         if(this._item.bindState != ItemBindState.NotBindable)
         {
            if(this.txt_itemBind == null)
            {
               this.txt_itemBind = new BodyTextField({
                  "color":Effects.COLOR_NEUTRAL,
                  "size":12,
                  "bold":true,
                  "antiAliasType":AntiAliasType.ADVANCED
               });
            }
            if(this.bmp_bind == null)
            {
               this.bmp_bind = new Bitmap();
            }
            addChild(this.bmp_bind);
            addChild(this.txt_itemBind);
            if(this._item.isAccountBound)
            {
               this.bmp_bind.bitmapData = BMP_BIND_BOUND;
               this.bmp_bind.transform.colorTransform = Effects.CT_GOOD;
               this.txt_itemBind.text = Language.getInstance().getString("bound");
               this.txt_itemBind.textColor = Effects.COLOR_GOOD;
            }
            else
            {
               this.bmp_bind.bitmapData = BMP_BIND_ON_EQUIP;
               this.bmp_bind.transform.colorTransform = Effects.CT_DEFAULT;
               this.txt_itemBind.text = Language.getInstance().getString("bindonequip");
               this.txt_itemBind.textColor = Effects.COLOR_NEUTRAL;
            }
            this.bmp_bind.x = this.txt_itemType.x + 3;
            this.bmp_bind.y = int(_loc8_);
            this.txt_itemBind.x = int(this.bmp_bind.x + this.bmp_bind.width + 2);
            this.txt_itemBind.y = int(this.bmp_bind.y + (this.bmp_bind.height - this.txt_itemBind.height) * 0.5 + 1);
            _loc8_ = Math.max(this.bmp_bind.y + this.bmp_bind.height,this.txt_itemBind.y + this.txt_itemBind.height - 4);
         }
         else
         {
            if(this.txt_itemBind != null && this.txt_itemBind.parent != null)
            {
               this.txt_itemBind.parent.removeChild(this.txt_itemBind);
            }
            if(this.bmp_bind != null && this.bmp_bind.parent != null)
            {
               this.bmp_bind.parent.removeChild(this.bmp_bind);
            }
         }
         this._height = _loc8_;
      }
      
      private function showQualityPrefix(param1:Item) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1.category == "research" || param1.category == "research-note")
         {
            return false;
         }
         return true;
      }
   }
}

