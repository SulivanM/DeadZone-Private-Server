package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.research.ResearchEffect;
   
   public class SurvivorLoadout
   {
      
      public static const SLOT_WEAPON:String = "weapon";
      
      public static const SLOT_GEAR_PASSIVE:String = "gearPassive";
      
      public static const SLOT_GEAR_ACTIVE:String = "gearActive";
      
      public static const TYPE_OFFENCE:String = "offence";
      
      public static const TYPE_DEFENCE:String = "defence";
      
      private var _type:String;
      
      private var _survivor:Survivor;
      
      private var _weapon:SurvivorLoadoutData;
      
      private var _gearPassive:SurvivorLoadoutData;
      
      private var _gearActive:SurvivorLoadoutData;
      
      private var _supressChanges:Boolean = false;
      
      public var changed:Signal;
      
      internal var itemAdded:Signal;
      
      internal var itemRemoved:Signal;
      
      public function SurvivorLoadout(param1:Survivor, param2:String)
      {
         super();
         this._survivor = param1;
         this._type = param2;
         this._weapon = new SurvivorLoadoutData(this,SurvivorLoadout.SLOT_WEAPON);
         this._weapon.changed.add(this.onLoadoutChanged);
         this._gearPassive = new SurvivorLoadoutData(this,SurvivorLoadout.SLOT_GEAR_PASSIVE);
         this._gearPassive.changed.add(this.onLoadoutChanged);
         this._gearActive = new SurvivorLoadoutData(this,SurvivorLoadout.SLOT_GEAR_ACTIVE);
         this._gearActive.changed.add(this.onLoadoutChanged);
         this.changed = new Signal();
         this.itemAdded = new Signal(SurvivorLoadout,SurvivorLoadoutData,Item);
         this.itemRemoved = new Signal(SurvivorLoadout,SurvivorLoadoutData,Item);
      }
      
      public function dispose() : void
      {
         this.changed.removeAll();
         this.itemAdded.removeAll();
         this.itemRemoved.removeAll();
         this._weapon.dispose();
         this._gearPassive.dispose();
         this._gearActive.dispose();
      }
      
      public function getAssets(param1:Array, param2:Boolean = true) : Array
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         param1 ||= [];
         if(this._weapon.item is Weapon)
         {
            param1.push(this._weapon.item.xml.mdl.@uri.toString());
            param1.push("models/anim/human-weapons-" + Weapon(this._weapon.item).animType + ".anim");
            for each(_loc3_ in this._weapon.item.xml.weap.snd.children())
            {
               param1.push(_loc3_.toString());
            }
         }
         if(this._gearPassive.item is Gear)
         {
            _loc4_ = this._gearPassive.item.xml.mdl[0];
            if(_loc4_ != null)
            {
               param1.push(_loc4_.@uri.toString());
            }
            for each(_loc3_ in this._gearPassive.item.xml.gear.snd.children())
            {
               param1.push(_loc3_.toString());
            }
         }
         if(param2)
         {
            if(this._gearActive.item is Gear)
            {
               _loc4_ = this._gearActive.item.xml.mdl[0];
               if(_loc4_ != null)
               {
                  param1.push(_loc4_.@uri.toString());
               }
               param1.push("models/anim/human-weapons-" + Gear(this._gearActive.item).animType + ".anim");
               for each(_loc3_ in this._gearActive.item.xml.gear.snd.children())
               {
                  param1.push(_loc3_.toString());
               }
            }
         }
         return param1;
      }
      
      public function getDataForItem(param1:Item) : SurvivorLoadoutData
      {
         if(this.weapon.item == param1)
         {
            return this.weapon;
         }
         if(this.gearPassive.item == param1)
         {
            return this.gearPassive;
         }
         if(this.gearActive.item == param1)
         {
            return this.gearActive;
         }
         return null;
      }
      
      public function getCarryLimit(param1:Item, param2:Item = null) : int
      {
         var _loc3_:Gear = param1 as Gear;
         if(_loc3_ == null)
         {
            return 0;
         }
         var _loc4_:int = _loc3_.carryLimit;
         return int(_loc4_ + (this.getLoadoutAttributeBase(ItemAttributes.GROUP_SURVIVOR,"equip",null,param2) + this.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"equip",null,param2)));
      }
      
      public function getGearLoadoutAttributeMod(param1:String, param2:String, param3:Weapon = null, param4:Item = null) : Number
      {
         var _loc6_:Gear = null;
         var _loc8_:ClothingAccessory = null;
         if(param3 == null)
         {
            param3 = this._weapon.item as Weapon;
         }
         var _loc5_:Number = 0;
         if(this._gearPassive.item != null && this._gearPassive.item != param4)
         {
            _loc6_ = Gear(this._gearPassive.item);
            if(param1 != ItemAttributes.GROUP_WEAPON || _loc6_.supportsWeapon(param3))
            {
               _loc5_ += _loc6_.attributes.getModValue(param1,param2);
            }
            if(param1 == ItemAttributes.GROUP_SURVIVOR && param2 == Attributes.HEALTH)
            {
               if(this._survivor.researchEffects != null)
               {
                  _loc5_ += Number(this._survivor.researchEffects[ResearchEffect.GearHealth]) || 0;
               }
            }
         }
         if(this._gearActive.item != null && this._gearActive.item != param4)
         {
            _loc6_ = Gear(this._gearActive.item);
            if(param1 != ItemAttributes.GROUP_WEAPON || _loc6_.supportsWeapon(param3))
            {
               _loc5_ += _loc6_.attributes.getModValue(param1,param2);
            }
         }
         var _loc7_:int = 0;
         while(_loc7_ < this._survivor.maxClothingAccessories)
         {
            _loc8_ = this._survivor.getAccessory(_loc7_);
            if(!(_loc8_ == null || _loc8_ == param4))
            {
               if(param1 != ItemAttributes.GROUP_WEAPON || _loc8_.supportsWeapon(param3))
               {
                  _loc5_ += _loc8_.attributes.getModValue(param1,param2);
               }
            }
            _loc7_++;
         }
         return ItemAttributes.cap(param2,_loc5_);
      }
      
      public function getLoadoutAttributeMod(param1:String, param2:String, param3:Weapon = null, param4:Item = null) : Number
      {
         if(param3 == null)
         {
            param3 = this._weapon.item as Weapon;
         }
         var _loc5_:Number = 0;
         if(param3 != null && param3 != param4)
         {
            _loc5_ += param3.attributes.getModValue(param1,param2);
         }
         _loc5_ += this.getGearLoadoutAttributeMod(param1,param2,param3,param4);
         return ItemAttributes.cap(param2,_loc5_);
      }
      
      public function getLoadoutAttributeBase(param1:String, param2:String, param3:Weapon = null, param4:Item = null) : Number
      {
         var _loc6_:Gear = null;
         var _loc8_:ClothingAccessory = null;
         if(param3 == null)
         {
            param3 = this._weapon.item as Weapon;
         }
         var _loc5_:Number = 0;
         if(param3 != null && param3 != param4)
         {
            _loc5_ += param3.attributes.getBaseValue(param1,param2);
         }
         if(this._gearPassive.item != null && this._gearPassive.item != param4)
         {
            _loc6_ = Gear(this._gearPassive.item);
            if(param1 != ItemAttributes.GROUP_WEAPON || _loc6_.supportsWeapon(param3))
            {
               _loc5_ += _loc6_.attributes.getBaseValue(param1,param2);
            }
         }
         if(this._gearActive.item != null && this._gearActive.item != param4)
         {
            _loc6_ = Gear(this._gearActive.item);
            if(param1 != ItemAttributes.GROUP_WEAPON || _loc6_.supportsWeapon(param3))
            {
               _loc5_ += _loc6_.attributes.getBaseValue(param1,param2);
            }
         }
         var _loc7_:int = 0;
         while(_loc7_ < this._survivor.maxClothingAccessories)
         {
            _loc8_ = this._survivor.getAccessory(_loc7_);
            if(!(_loc8_ == null || _loc8_ != param4))
            {
               if(param1 != ItemAttributes.GROUP_WEAPON || _loc8_.supportsWeapon(param3))
               {
                  _loc5_ += _loc8_.attributes.getBaseValue(param1,param2);
               }
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      public function isAttributeAffectedByGear(param1:String, param2:String, param3:Weapon = null) : Boolean
      {
         var _loc4_:Gear = null;
         var _loc6_:ClothingAccessory = null;
         if(param3 == null)
         {
            param3 = this._weapon.item as Weapon;
         }
         if(param3 != null)
         {
            if(param3.attributes.getValue(param1,param2))
            {
               return true;
            }
         }
         _loc4_ = this._gearPassive.item as Gear;
         if(_loc4_ != null && _loc4_.supportsWeapon(param3))
         {
            if(_loc4_.attributes.getValue(param1,param2))
            {
               return true;
            }
         }
         _loc4_ = this._gearActive.item as Gear;
         if(_loc4_ != null && _loc4_.supportsWeapon(param3))
         {
            if(_loc4_.attributes.getValue(param1,param2))
            {
               return true;
            }
         }
         var _loc5_:int = 0;
         while(_loc5_ < this._survivor.maxClothingAccessories)
         {
            _loc6_ = this._survivor.getAccessory(_loc5_);
            if(_loc6_ != null)
            {
               if(_loc6_.supportsWeapon(param3))
               {
                  if(_loc6_.attributes.getValue(param1,param2))
                  {
                     return true;
                  }
               }
            }
            _loc5_++;
         }
         return false;
      }
      
      public function getAffectedAttributeDescription(param1:String, param2:String) : String
      {
         var _loc4_:String = null;
         var _loc5_:Gear = null;
         var _loc8_:ClothingAccessory = null;
         var _loc3_:String = "";
         var _loc6_:Weapon = this._weapon.item as Weapon;
         if(_loc6_ != null)
         {
            _loc4_ = _loc6_.getAttributeDescription(param1,param2);
            if(_loc4_.length > 0)
            {
               _loc3_ += "<b>" + _loc6_.getName() + "</b><br/>";
               _loc3_ += "    " + _loc4_ + "<br/>";
            }
         }
         _loc5_ = this._gearPassive.item as Gear;
         if(_loc5_ != null)
         {
            _loc4_ = _loc5_.getAttributeDescription(param1,param2);
            if(_loc4_.length > 0)
            {
               _loc3_ += "<b>" + _loc5_.getName() + "</b><br/>";
               _loc3_ += "    " + _loc4_ + "<br/>";
            }
         }
         _loc5_ = this._gearActive.item as Gear;
         if(_loc5_ != null)
         {
            _loc4_ = _loc5_.getAttributeDescription(param1,param2);
            if(_loc4_.length > 0)
            {
               _loc3_ += "<b>" + _loc5_.getName() + "</b><br/>";
               _loc3_ += "    " + _loc4_ + "<br/>";
            }
         }
         var _loc7_:int = 0;
         while(_loc7_ < this._survivor.maxClothingAccessories)
         {
            _loc8_ = this._survivor.getAccessory(_loc7_);
            if(_loc8_ != null)
            {
               _loc4_ = _loc8_.getAttributeDescription(param1,param2);
               if(_loc4_.length > 0)
               {
                  _loc3_ += "<b>" + _loc8_.getName() + "</b><br/>";
                  _loc3_ += "    " + _loc4_ + "<br/>";
               }
            }
            _loc7_++;
         }
         return _loc3_;
      }
      
      public function getQuantityEquipped(param1:Item) : int
      {
         var _loc2_:int = 0;
         if(this._weapon.item == param1)
         {
            _loc2_ += this._weapon.quantity;
         }
         if(this._gearPassive.item == param1)
         {
            _loc2_ += this._gearPassive.quantity;
         }
         if(this._gearActive.item == param1)
         {
            _loc2_ += this._gearActive.quantity;
         }
         return _loc2_;
      }
      
      internal function removeUnusableItems(param1:Dictionary, param2:int = 0) : Boolean
      {
         var _loc5_:Item = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:int = this._survivor.level - param2;
         var _loc6_:* = (this._survivor.state & SurvivorState.ON_ASSIGNMENT) != 0;
         this._supressChanges = true;
         if(this._weapon.item != null && !_loc6_)
         {
            if(this._weapon.item.level > _loc4_)
            {
               _loc5_ = this._gearActive.item;
               this._weapon.item = null;
               this.itemRemoved.dispatch(this,this._weapon,_loc5_);
               _loc3_ = true;
            }
         }
         if(this._gearPassive.item != null && !_loc6_)
         {
            if(this._gearPassive.item.level > _loc4_)
            {
               _loc5_ = this._gearActive.item;
               this._gearPassive.item = null;
               this.itemRemoved.dispatch(this,this._gearPassive,_loc5_);
               _loc3_ = true;
            }
         }
         if(this._gearActive.item != null && !_loc6_)
         {
            if(this._gearActive.item.level > _loc4_)
            {
               _loc5_ = this._gearActive.item;
               this._gearActive.item = null;
               this.itemRemoved.dispatch(this,this._gearActive,_loc5_);
               _loc3_ = true;
            }
            else
            {
               _loc7_ = this.getCarryLimit(this._gearActive.item);
               if(this._gearActive.quantity > _loc7_)
               {
                  this._gearActive.quantity = _loc7_;
                  _loc3_ = true;
               }
               _loc8_ = int(this.gearActive.item.quantity);
               _loc9_ = this._gearActive.item.id;
               _loc10_ = int(param1[_loc9_]);
               _loc11_ = Math.max(_loc8_ - _loc10_,0);
               if(this._gearActive.quantity > _loc11_)
               {
                  this._gearActive.quantity = _loc11_;
                  _loc3_ = true;
               }
               param1[_loc9_] = _loc10_ + this._gearActive.quantity;
            }
         }
         this._supressChanges = false;
         if(_loc3_)
         {
            this.changed.dispatch();
         }
         return _loc3_;
      }
      
      public function removeItem(param1:Item) : Boolean
      {
         var _loc3_:Item = null;
         var _loc2_:Boolean = false;
         this._supressChanges = true;
         if(this._weapon.item == param1)
         {
            _loc3_ = this._weapon.item;
            this._weapon.item = null;
            this.itemRemoved.dispatch(this,this._weapon,_loc3_);
            _loc2_ = true;
         }
         if(this._gearPassive.item == param1)
         {
            _loc3_ = this._gearPassive.item;
            this._gearPassive.item = null;
            this.itemRemoved.dispatch(this,this._gearPassive,_loc3_);
            _loc2_ = true;
         }
         if(this._gearActive.item == param1)
         {
            _loc3_ = this._gearActive.item;
            this._gearActive.item = null;
            this.itemRemoved.dispatch(this,this._gearActive,_loc3_);
            _loc2_ = true;
         }
         this._supressChanges = false;
         if(_loc2_)
         {
            this.changed.dispatch();
         }
         return _loc2_;
      }
      
      public function clearItems() : void
      {
         var _loc2_:Item = null;
         var _loc1_:Boolean = false;
         this._supressChanges = true;
         if(this._weapon.item != null)
         {
            _loc2_ = this._weapon.item;
            this._weapon.item = null;
            this.itemRemoved.dispatch(this,this._weapon,_loc2_);
            _loc1_ = true;
         }
         if(this._gearPassive.item != null)
         {
            _loc2_ = this._gearPassive.item;
            this._gearPassive.item = null;
            this.itemRemoved.dispatch(this,this._gearPassive,_loc2_);
            _loc1_ = true;
         }
         if(this._gearActive.item != null)
         {
            _loc2_ = this._gearActive.item;
            this._gearActive.item = null;
            this.itemRemoved.dispatch(this,this._gearActive,_loc2_);
            _loc1_ = true;
         }
         this._supressChanges = false;
         if(_loc1_)
         {
            this.changed.dispatch();
         }
      }
      
      public function toHashtable() : Object
      {
         var _loc1_:Object = {};
         _loc1_.survivor = this._survivor.id.toUpperCase();
         if(this._weapon.item != null)
         {
            _loc1_.weapon = this._weapon.toHashtable();
         }
         if(this._gearPassive.item != null)
         {
            _loc1_.gearPassive = this._gearPassive.toHashtable();
         }
         if(this._gearActive.item != null)
         {
            _loc1_.gearActive = this._gearActive.toHashtable();
         }
         return _loc1_;
      }
      
      public function giveBestWeapon(param1:Vector.<Item>, param2:int = 0, param3:Boolean = false) : Weapon
      {
         var i:int;
         var len:int;
         var worstWeapon:Weapon;
         var weaponData:WeaponData = null;
         var weapon:Weapon = null;
         var weaponList:Vector.<Item> = param1;
         var maxLevel:int = param2;
         var sortListByDPS:Boolean = param3;
         if(sortListByDPS)
         {
            weaponData = new WeaponData();
            weaponList.sort(function(param1:Weapon, param2:Weapon):int
            {
               weaponData.populate(null,param1);
               var _loc3_:Number = weaponData.getDPS();
               weaponData.populate(null,param2);
               var _loc4_:Number = weaponData.getDPS();
               if(_loc4_ < _loc3_)
               {
                  return -1;
               }
               if(_loc4_ > _loc3_)
               {
                  return 1;
               }
               return 0;
            });
         }
         i = 0;
         len = int(weaponList.length);
         while(i < len)
         {
            weapon = weaponList[i] as Weapon;
            if(weapon != null)
            {
               if(weapon.level <= maxLevel)
               {
                  this.weapon.item = weapon;
                  return weapon;
               }
            }
            i++;
         }
         worstWeapon = ItemFactory.createItemFromTypeId("lawson22") as Weapon;
         this.weapon.item = worstWeapon;
         return worstWeapon;
      }
      
      private function onLoadoutChanged(param1:SurvivorLoadoutData, param2:Item = null, param3:Item = null) : void
      {
         var _loc4_:int = 0;
         if(this._gearActive.item != null)
         {
            _loc4_ = this.getCarryLimit(this._gearActive.item);
            if(this._gearActive.quantity > _loc4_)
            {
               this._gearActive.quantity = _loc4_;
            }
         }
         if(this._supressChanges)
         {
            return;
         }
         if(param2 == null)
         {
            this.itemRemoved.dispatch(this,param1,param3);
         }
         else
         {
            this.itemAdded.dispatch(this,param1,param3);
         }
         this.changed.dispatch();
      }
      
      public function get weapon() : SurvivorLoadoutData
      {
         return this._weapon;
      }
      
      public function get gearPassive() : SurvivorLoadoutData
      {
         return this._gearPassive;
      }
      
      public function get gearActive() : SurvivorLoadoutData
      {
         return this._gearActive;
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function get type() : String
      {
         return this._type;
      }
   }
}

