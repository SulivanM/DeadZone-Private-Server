package thelaststand.app.game.gui.iteminfo
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.GearType;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.WeaponType;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.StringUtils;
   
   public class UIGearInfo extends UIGenericItemInfo
   {
      
      private static var _survivorPropList:Array = [];
      
      private static var _weaponPropList:Array = [];
      
      private static var _gearPropList:Array = ["throwrngmin","throwrngmax","dmg","dmg_bld","rng","dur","dettime","duration","heal","equip","carry"];
      
      private var _gear:Gear;
      
      private var bmp_equipOffence:Bitmap;
      
      private var bmp_equipDefence:Bitmap;
      
      private var txt_modInfo:BodyTextField;
      
      private var txt_equipOffence:BodyTextField;
      
      private var txt_equipDefence:BodyTextField;
      
      private var txt_levelRequired:BodyTextField;
      
      private var txt_classRequired:BodyTextField;
      
      private var txt_weaponRequired:BodyTextField;
      
      private var txt_numAvailable:BodyTextField;
      
      private var ui_stats:UIItemStatTable;
      
      public function UIGearInfo()
      {
         super();
         this.txt_modInfo = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "multiline":true,
            "size":14,
            "leading":1
         });
         this.txt_modInfo.width = _width;
         this.bmp_equipOffence = new Bitmap(new BmpIconEquipped());
         this.bmp_equipOffence.x = -2;
         this.txt_equipOffence = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_equipOffence.x = int(this.bmp_equipOffence.x + this.bmp_equipOffence.width);
         this.bmp_equipDefence = new Bitmap(new BmpIconEquippedDefence());
         this.bmp_equipDefence.x = -2;
         this.txt_equipDefence = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_levelRequired = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":13,
            "bold":true
         });
         this.txt_levelRequired.maxWidth = _width;
         this.txt_classRequired = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true,
            "multiline":true,
            "leading":-1
         });
         this.txt_classRequired.width = _width;
         this.txt_weaponRequired = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true,
            "multiline":true,
            "leading":-1
         });
         this.txt_weaponRequired.width = _width;
         this.txt_numAvailable = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_numAvailable.maxWidth = _width;
         this.ui_stats = new UIItemStatTable(_width);
      }
      
      override public function dispose() : void
      {
         this._gear = null;
         super.dispose();
         this.bmp_equipOffence.bitmapData.dispose();
         this.bmp_equipOffence.bitmapData = null;
         this.bmp_equipDefence.bitmapData.dispose();
         this.bmp_equipDefence.bitmapData = null;
         this.txt_classRequired.dispose();
         this.txt_equipOffence.dispose();
         this.txt_equipDefence.dispose();
         this.txt_levelRequired.dispose();
         this.txt_modInfo.dispose();
         this.txt_weaponRequired.dispose();
         this.txt_numAvailable.dispose();
         this.ui_stats.dispose();
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc12_:* = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:Survivor = null;
         var _loc16_:int = 0;
         var _loc17_:SurvivorLoadout = null;
         var _loc18_:SurvivorLoadout = null;
         var _loc19_:String = null;
         if(!(param1 is Gear))
         {
            throw new Error("Item is not Gear");
         }
         this._gear = param1 as Gear;
         param3 ||= {};
         super.setItem(param1,param2,param3);
         if(this._gear.quantifiable)
         {
            if(param2 != null)
            {
               if(param3.showEquippedQuantity)
               {
                  mc_image.image.quantity = param2.getQuantityEquipped(this._gear);
               }
               else
               {
                  mc_image.image.quantity = Network.getInstance().playerData.loadoutManager.getAvailableQuantity(this._gear,param2.survivor,param2.type);
               }
            }
            else
            {
               mc_image.image.quantityFieldSize = 14;
               mc_image.image.quantityAvailable = Network.getInstance().playerData.loadoutManager.getAvailableQuantity(this._gear);
               this.txt_numAvailable.text = _lang.getString("itm_details.num_available",NumberFormatter.format(mc_image.image.quantityAvailable,0),NumberFormatter.format(this._gear.quantity,0));
               this.txt_numAvailable.y = _height + 10;
               addChild(this.txt_numAvailable);
               _height = int(this.txt_numAvailable.y + this.txt_numAvailable.height);
            }
         }
         var _loc4_:Gear = null;
         if(this._gear.isActiveGear)
         {
            _loc4_ = _loadout != null ? _loadout.gearActive.item as Gear : null;
         }
         else
         {
            _loc4_ = _loadout != null ? _loadout.gearPassive.item as Gear : null;
         }
         this.populateStats(ItemAttributes.GROUP_GEAR,_gearPropList,_loc4_);
         this.populateStats(ItemAttributes.GROUP_SURVIVOR,_survivorPropList,_loc4_);
         this.populateStats(ItemAttributes.GROUP_WEAPON,_weaponPropList,_loc4_);
         if(this.ui_stats.height > 0)
         {
            this.ui_stats.y = int(_height + 10);
            addChild(this.ui_stats);
            _height = int(this.ui_stats.y + this.ui_stats.height - 4);
         }
         else if(this.ui_stats.parent != null)
         {
            this.ui_stats.parent.removeChild(this.ui_stats);
         }
         var _loc5_:String = "";
         if(this._gear.activeAttributes != null)
         {
            _loc5_ += this.getActiveAttributes() + "<br/>";
         }
         _loc5_ += this._gear.getAttributeDescriptionsForGroups(ItemAttributes.GROUP_WEAPON,ItemAttributes.GROUP_SURVIVOR);
         if(_loc5_.length > 0)
         {
            this.txt_modInfo.htmlText = _loc5_;
            this.txt_modInfo.y = _height + 10;
            addChild(this.txt_modInfo);
            _height = int(this.txt_modInfo.y + this.txt_modInfo.height);
         }
         if(this.txt_classRequired.parent != null)
         {
            this.txt_classRequired.parent.removeChild(this.txt_classRequired);
         }
         if(this.txt_weaponRequired.parent != null)
         {
            this.txt_weaponRequired.parent.removeChild(this.txt_weaponRequired);
         }
         if(this._gear.survivorClasses.length > 0)
         {
            _loc12_ = _lang.getString("itm_details.requires") + " ";
            for each(_loc13_ in this._gear.survivorClasses)
            {
               _loc12_ += _lang.getString("survivor_classes." + _loc13_) + " / ";
            }
            if(this._gear.survivorClasses.indexOf(SurvivorClass.PLAYER) == -1)
            {
               _loc12_ += _lang.getString("survivor_classes." + SurvivorClass.PLAYER);
            }
            else
            {
               _loc12_ = _loc12_.substr(0,_loc12_.length - 3);
            }
            this.txt_classRequired.text = _loc12_;
            this.txt_classRequired.y = _height + 10;
            addChild(this.txt_classRequired);
            _height = int(this.txt_classRequired.y + this.txt_classRequired.height);
         }
         else if(this.txt_classRequired.parent != null)
         {
            this.txt_classRequired.parent.removeChild(this.txt_classRequired);
         }
         var _loc6_:* = "";
         if(this._gear.weaponClasses.length > 0)
         {
            _loc6_ = _lang.getString("itm_details.requires") + " ";
            for each(_loc14_ in this._gear.weaponClasses)
            {
               _loc6_ += _lang.getString("weap_class." + _loc14_) + ", ";
            }
            _loc6_ = _loc6_.substr(0,_loc6_.length - 2);
            if(this._gear.weaponTypes != WeaponType.NONE)
            {
               _loc6_ += " (" + this.printRequiredWeaponTypes(this._gear) + ")";
            }
         }
         else if(this._gear.weaponTypes != WeaponType.NONE)
         {
            _loc6_ = _lang.getString("itm_details.requires") + " " + this.printRequiredWeaponTypes(this._gear) + " " + _lang.getString("weapon");
         }
         if(_loc6_.length > 0)
         {
            this.txt_weaponRequired.htmlText = _loc6_;
            this.txt_weaponRequired.y = _height + 10;
            addChild(this.txt_weaponRequired);
            _height = int(this.txt_weaponRequired.y + this.txt_weaponRequired.height);
         }
         else if(this.txt_weaponRequired.parent != null)
         {
            this.txt_weaponRequired.parent.removeChild(this.txt_weaponRequired);
         }
         if(this.txt_equipOffence.parent != null)
         {
            this.txt_equipOffence.parent.removeChild(this.txt_equipOffence);
         }
         if(this.bmp_equipOffence.parent != null)
         {
            this.bmp_equipOffence.parent.removeChild(this.bmp_equipOffence);
         }
         if(this.txt_equipDefence.parent != null)
         {
            this.txt_equipDefence.parent.removeChild(this.txt_equipDefence);
         }
         if(this.bmp_equipDefence.parent != null)
         {
            this.bmp_equipDefence.parent.removeChild(this.bmp_equipDefence);
         }
         var _loc9_:Boolean = !this._gear.quantifiable || param2 == null && this._gear.quantifiable;
         if(_loc9_)
         {
            if(this._gear.category == "clothing")
            {
               _loc15_ = Network.getInstance().playerData.loadoutManager.getItemClothingSurvivor(this._gear as ClothingAccessory);
               if(_loc15_ != null && _loc15_ != _survivor)
               {
                  this.bmp_equipOffence.y = _height + 10;
                  this.txt_equipOffence.text = _lang.getString("itm_details.equipped",_loc15_.fullName);
                  this.txt_equipOffence.y = int(this.bmp_equipOffence.y + (this.bmp_equipOffence.height - this.txt_equipOffence.height) * 0.5);
                  addChild(this.bmp_equipOffence);
                  addChild(this.txt_equipOffence);
                  _height = int(this.txt_equipOffence.y + this.txt_equipOffence.height);
               }
            }
            else
            {
               _loc17_ = Network.getInstance().playerData.loadoutManager.getItemOffensiveLoadout(_item);
               if(_loc17_ != null && _loc17_.survivor != _survivor)
               {
                  this.bmp_equipOffence.y = _height + 10;
                  addChild(this.bmp_equipOffence);
                  this.txt_equipOffence.maxWidth = _width;
                  if(this._gear.quantifiable)
                  {
                     _loc16_ = Network.getInstance().playerData.loadoutManager.getQuantityEquipped(this._gear,SurvivorLoadout.TYPE_OFFENCE);
                     this.txt_equipOffence.text = _lang.getString("itm_details.equipped_count",NumberFormatter.format(_loc16_,0),NumberFormatter.format(this._gear.quantity,0));
                  }
                  else
                  {
                     this.txt_equipOffence.text = _lang.getString("itm_details.equipped",_loc17_.survivor.fullName);
                  }
                  this.txt_equipOffence.y = int(this.bmp_equipOffence.y + (this.bmp_equipOffence.height - this.txt_equipOffence.height) * 0.5);
                  addChild(this.txt_equipOffence);
                  _height = int(this.txt_equipOffence.y + this.txt_equipOffence.height);
               }
               _loc18_ = Network.getInstance().playerData.loadoutManager.getItemDefensiveLoadout(_item);
               if(_loc18_ != null && _loc18_.survivor != _survivor)
               {
                  this.bmp_equipDefence.y = _height + 10;
                  addChild(this.bmp_equipDefence);
                  _loc19_ = "";
                  this.txt_equipDefence.maxWidth = _width;
                  this.txt_equipDefence.x = int(this.bmp_equipDefence.x + this.bmp_equipDefence.width);
                  if(this._gear.quantifiable)
                  {
                     _loc16_ = Network.getInstance().playerData.loadoutManager.getQuantityEquipped(this._gear,SurvivorLoadout.TYPE_DEFENCE);
                     _loc19_ += _lang.getString("itm_details.equipped_defence_count",NumberFormatter.format(_loc16_,0),NumberFormatter.format(this._gear.quantity,0));
                  }
                  else
                  {
                     _loc19_ += _lang.getString("itm_details.equipped_defence",_loc18_.survivor.fullName);
                  }
                  if(Boolean(this._gear.gearType & GearType.ACTIVE) && (param2 == null || param2.type == SurvivorLoadout.TYPE_DEFENCE))
                  {
                     this.txt_equipDefence.multiline = true;
                     this.txt_equipDefence.width = int(_width - this.txt_equipDefence.x);
                     _loc19_ += "<br/>" + _lang.getString("itm_details.equipped_nopvp");
                  }
                  this.txt_equipDefence.htmlText = _loc19_;
                  this.txt_equipDefence.y = int(this.bmp_equipDefence.y - 1);
                  addChild(this.txt_equipDefence);
                  _height = int(this.txt_equipDefence.y + this.txt_equipDefence.height);
               }
               else if(Boolean(this._gear.gearType & GearType.ACTIVE) && (param2 == null || param2.type == SurvivorLoadout.TYPE_DEFENCE))
               {
                  this.txt_equipDefence.x = 0;
                  this.txt_equipDefence.y = int(_height + 10);
                  this.txt_equipDefence.multiline = false;
                  this.txt_equipDefence.maxWidth = _width;
                  this.txt_equipDefence.htmlText = _lang.getString("itm_details.equipped_nopvp");
                  addChild(this.txt_equipDefence);
                  _height = int(this.txt_equipDefence.y + this.txt_equipDefence.height);
               }
            }
         }
         var _loc10_:int = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("WeaponGearLevelLimit"));
         var _loc11_:int = _survivor != null ? _survivor.level - _loc10_ : 0;
         if(_survivor != null && this._gear.level > _loc11_)
         {
            this.txt_levelRequired.text = _lang.getString("itm_details.level_required",this._gear.level + 1);
            if(_loc10_ != 0)
            {
               this.txt_levelRequired.text += " " + _lang.getString("itm_details.level_required_mod");
            }
            this.txt_levelRequired.y = _height + 10;
            addChild(this.txt_levelRequired);
            _height = int(this.txt_levelRequired.y + this.txt_levelRequired.height);
         }
         else if(this.txt_levelRequired.parent != null)
         {
            this.txt_levelRequired.parent.removeChild(this.txt_levelRequired);
         }
      }
      
      private function printRequiredWeaponTypes(param1:Gear) : String
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc2_:String = "";
         for each(_loc3_ in describeType(WeaponType).constant)
         {
            _loc4_ = _loc3_.@name.toString();
            if(param1.weaponTypes & WeaponType[_loc4_.toUpperCase()])
            {
               _loc2_ += _lang.getString("weap_type." + _loc4_.toLowerCase()) + " / ";
            }
         }
         return _loc2_.substr(0,_loc2_.length - 3);
      }
      
      private function getActiveAttributes() : String
      {
         var _loc1_:Dictionary = this._gear.activeAttributes.getValues(ItemAttributes.GROUP_SURVIVOR);
         var _loc2_:String = _item.getAttributeDescriptionsForDict(ItemAttributes.GROUP_SURVIVOR,_loc1_);
         _loc2_ = StringUtils.htmlRemoveTrailingBreaks(_loc2_);
         return StringUtils.htmlSetDoubleBreakLeading(_loc2_);
      }
      
      private function populateStats(param1:String, param2:Array, param3:Gear = null) : void
      {
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            _loc5_ = param2[_loc4_];
            _loc6_ = this._gear.attributes.getValue(param1,_loc5_);
            this.addStatRow(param1,_loc5_,_loc6_,param3);
            _loc4_++;
         }
      }
      
      private function addStatRow(param1:String, param2:String, param3:Number, param4:Gear = null) : void
      {
         var _loc10_:Number = NaN;
         var _loc13_:Boolean = false;
         var _loc14_:Number = NaN;
         if(isNaN(param3) || param3 == 0)
         {
            return;
         }
         var _loc5_:Boolean = ItemAttributes.isAdditive(param2);
         if(_loadout != null)
         {
            if(param2 == "equip")
            {
               param3 = _loadout.getCarryLimit(this._gear,param4);
            }
            else if(_loc5_)
            {
               param3 += _loadout.getLoadoutAttributeMod(param1,param2,null,param4);
            }
            else
            {
               param3 *= 1 + _loadout.getLoadoutAttributeMod(param1,param2,null,param4);
            }
         }
         var _loc6_:Number = this._gear.attributes.getBaseValue(param1,param2);
         var _loc7_:Number = param3 - _loc6_;
         var _loc8_:* = _loc7_ != 0;
         var _loc9_:uint = Effects.COLOR_NEUTRAL;
         if(_loc8_)
         {
            _loc13_ = this._gear.isLowerBetter(param2);
            if(_loc7_ < 0)
            {
               _loc9_ = _loc13_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
            }
            else
            {
               _loc9_ = _loc13_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
            }
         }
         switch(param2)
         {
            case "dmg_bld":
               param3 *= this._gear.attributes.getValue(param1,"dmg");
         }
         var _loc11_:uint = 0;
         if(param4 != null && param4 != this._gear)
         {
            _loc10_ = 0;
            _loc14_ = param4.attributes.getValue(param1,param2);
            if(_loadout != null)
            {
               if(param2 == "equip")
               {
                  _loc14_ = _loadout.getCarryLimit(param4,this._gear);
               }
               else if(_loc5_)
               {
                  _loc14_ += _loadout.getLoadoutAttributeMod(param1,param2,null,param4);
               }
               else
               {
                  _loc14_ *= 1 + _loadout.getLoadoutAttributeMod(param1,param2,null,param4);
               }
            }
            if(!isNaN(_loc14_) && _loc14_ != 0)
            {
               if(param2 == "dmg_bld")
               {
                  _loc14_ *= param4.attributes.getValue(param1,"dmg");
               }
               _loc10_ = param3 < _loc14_ ? -1 : (param3 > _loc14_ ? 1 : 0);
               if(param2 == "dettime")
               {
                  _loc11_ = Effects.COLOR_NEUTRAL;
               }
               else if(this._gear.isLowerBetter(param2))
               {
                  _loc11_ = _loc10_ < 0 ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
               }
               else
               {
                  _loc11_ = _loc10_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
               }
            }
         }
         else
         {
            _loc10_ = NaN;
         }
         switch(param2)
         {
            case "dmg":
            case "dmg_bld":
            case "heal":
               param3 *= 100;
         }
         var _loc12_:* = NumberFormatter.format(param3,2,",",false);
         if(_loc5_)
         {
            if(param1 != ItemAttributes.GROUP_GEAR && _loc8_ && _loc7_ > 0)
            {
               _loc12_ = "+" + _loc12_;
            }
         }
         switch(param2)
         {
            case "dur":
            case "dettime":
               _loc12_ += " " + _lang.getString("sec");
               break;
            case "heal":
               _loc12_ += "%";
         }
         this.ui_stats.addRow(_lang.getString("itm_details." + param2),_loc12_,_loc9_,_loc10_,_loc11_);
      }
   }
}

