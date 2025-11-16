package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import thelaststand.app.core.Config;
   
   public class ItemAttributes
   {
      
      private static var _allGroups:Array = [GROUP_GEAR,GROUP_SURVIVOR,GROUP_WEAPON];
      
      private static var _additionAttributes:Array = ["carry","equip","infected_kill_xp","survivor_kill_xp","human_kill_xp"];
      
      private static var _ignoreAttributes:Array = ["cls","type","ammo","srv","weap","gear","anim","snd","swing","proj","rldanim","exp"];
      
      private static var _lowMods:Array = ["noise","rate","rldtime","ammo_cost","injuryChance","rng_min_eff"];
      
      private static var _reverseSignMods:Array = ["rate","rldtime"];
      
      public static const GROUP_GEAR:String = "gear";
      
      public static const GROUP_SURVIVOR:String = "srv";
      
      public static const GROUP_WEAPON:String = "weap";
      
      private var _baseValues:Dictionary = new Dictionary(true);
      
      private var _modValues:Dictionary = new Dictionary(true);
      
      private var _attCaps:Dictionary = new Dictionary(true);
      
      private var _modCapGlobal:Number = 0;
      
      public function ItemAttributes()
      {
         super();
         this.clear();
      }
      
      public static function getAllGroups() : Array
      {
         return _allGroups;
      }
      
      public static function cap(param1:String, param2:Number) : Number
      {
         switch(param1)
         {
            case "dmg_res_exp":
            case "dmg_res_melee":
            case "dmg_res_proj":
            case "sup_res":
               return param2 > Config.constant.MAX_RESISTANCE ? Number(Config.constant.MAX_RESISTANCE) : param2;
            default:
               return param2;
         }
      }
      
      public static function isAdditive(param1:String) : Boolean
      {
         return _additionAttributes.indexOf(param1) > -1;
      }
      
      private static function ignoreAttribute(param1:String) : Boolean
      {
         return _ignoreAttributes.indexOf(param1) > -1;
      }
      
      public static function isLowerBetter(param1:String) : Boolean
      {
         return _lowMods.indexOf(param1) > -1;
      }
      
      public static function reverseSign(param1:String) : Boolean
      {
         return _reverseSignMods.indexOf(param1) > -1;
      }
      
      public function get globalModCap() : Number
      {
         return this._modCapGlobal;
      }
      
      public function set globalModCap(param1:Number) : void
      {
         this._modCapGlobal = param1;
      }
      
      public function clone() : ItemAttributes
      {
         var _loc1_:ItemAttributes = new ItemAttributes();
         _loc1_.copyFrom(this);
         return _loc1_;
      }
      
      public function clear() : void
      {
         var _loc1_:String = null;
         for each(_loc1_ in _allGroups)
         {
            this._baseValues[_loc1_] = new Dictionary(true);
            this._modValues[_loc1_] = new Dictionary(true);
            this._attCaps[_loc1_] = new Dictionary(true);
         }
      }
      
      public function merge(param1:ItemAttributes) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in _allGroups)
         {
            this.mergeValues(param1._baseValues[_loc2_],this._baseValues[_loc2_]);
            this.mergeValues(param1._modValues[_loc2_],this._modValues[_loc2_]);
            this.mergeValues(param1._attCaps[_loc2_],this._attCaps[_loc2_]);
         }
      }
      
      private function mergeValues(param1:Dictionary, param2:Dictionary) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         for(_loc3_ in param1)
         {
            _loc4_ = Number(Number(param1[_loc3_]) || 0);
            if(!(isNaN(_loc4_) || _loc4_ == 0))
            {
               _loc5_ = Number(Number(param2[_loc3_]) || 0);
               if(isNaN(_loc5_))
               {
                  _loc5_ = 0;
               }
               param2[_loc3_] = _loc5_ + _loc4_;
            }
         }
      }
      
      public function addBaseValuesFromXML(param1:String, param2:XMLList, param3:int, param4:int = 0) : void
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         for each(_loc5_ in param2)
         {
            _loc6_ = _loc5_.localName();
            if(!ignoreAttribute(_loc6_))
            {
               _loc7_ = Number(_loc5_.toString());
               if(!isNaN(_loc7_))
               {
                  _loc8_ = "@lvl" in _loc5_ ? Number(_loc5_.@lvl.toString()) : 1;
                  _loc9_ = Item.calcLeveledValue(_loc7_,_loc8_,param3,param4);
                  this.addBaseValue(param1,_loc6_,_loc9_);
               }
            }
         }
      }
      
      public function addModValuesFromXML(param1:String, param2:XMLList, param3:int, param4:int = 0) : void
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         for each(_loc5_ in param2)
         {
            _loc6_ = _loc5_.localName();
            if(!ignoreAttribute(_loc6_))
            {
               _loc7_ = Number(_loc5_.toString());
               if(!isNaN(_loc7_))
               {
                  if(_loc6_.indexOf("cap_") == 0)
                  {
                     this.addAttributeCap(param1,_loc6_.substr(4),_loc7_);
                  }
                  else
                  {
                     _loc8_ = "@lvl" in _loc5_ ? Number(_loc5_.@lvl.toString()) : 1;
                     _loc9_ = Item.calcLeveledValue(_loc7_,_loc8_,param3,param4);
                     this.addModValue(param1,_loc6_,_loc9_);
                  }
               }
            }
         }
      }
      
      public function addBaseValue(param1:String, param2:String, param3:Number) : void
      {
         var _loc4_:Number = this.getBaseValue(param1,param2);
         _loc4_ = _loc4_ + param3;
         this._baseValues[param1][param2] = param3;
      }
      
      public function addModValue(param1:String, param2:String, param3:Number) : void
      {
         var _loc6_:Number = NaN;
         if(!isAdditive(param2))
         {
            param3--;
         }
         var _loc4_:Number = this.getModValue(param1,param2);
         _loc4_ = _loc4_ + param3;
         var _loc5_:Number = this._modCapGlobal;
         if(_loc5_ != 0)
         {
            _loc6_ = _loc4_ < 0 ? -_loc4_ : _loc4_;
            if(_loc6_ > _loc5_)
            {
               _loc4_ = _loc5_ * (_loc4_ < 0 ? -1 : 1);
            }
         }
         this._modValues[param1][param2] = _loc4_;
      }
      
      public function addAttributeCap(param1:String, param2:String, param3:Number) : void
      {
         if(isNaN(param3))
         {
            return;
         }
         if(!isAdditive(param2))
         {
            param3--;
         }
         var _loc4_:Number = Number(this._attCaps[param1][param2]);
         if(isNaN(_loc4_))
         {
            this._attCaps[param1][param2] = param3;
         }
         else
         {
            this._attCaps[param1][param2] = Math.min(_loc4_,param3);
         }
      }
      
      public function getBaseValues(param1:String) : Dictionary
      {
         return this._baseValues[param1];
      }
      
      public function getBaseValue(param1:String, param2:String) : Number
      {
         var _loc3_:Number = Number(this._baseValues[param1][param2]);
         return isNaN(_loc3_) ? 0 : _loc3_;
      }
      
      public function getModValues(param1:String) : Dictionary
      {
         return this._modValues[param1];
      }
      
      public function getModValue(param1:String, param2:String) : Number
      {
         var _loc3_:Number = Number(this._modValues[param1][param2]);
         if(!isNaN(_loc3_))
         {
            return ItemAttributes.cap(param2,_loc3_);
         }
         return 0;
      }
      
      public function getCappedModValue(param1:String, param2:String) : Number
      {
         var _loc3_:Number = this.getValue(param1,param2);
         var _loc4_:Number = this.getBaseValue(param1,param2);
         var _loc5_:Number = _loc3_ - _loc4_;
         if(isAdditive(param2) || _loc4_ == 0)
         {
            return _loc5_;
         }
         return _loc3_ / _loc4_ - 1;
      }
      
      public function isCapped(param1:String, param2:String) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc3_:Number = this.getUncappedValue(param1,param2);
         if(!isNaN(_loc3_))
         {
            _loc4_ = this.getValue(param1,param2);
            return _loc4_ != _loc3_;
         }
         return false;
      }
      
      public function getValues(param1:String) : Dictionary
      {
         var _loc5_:String = null;
         var _loc2_:Dictionary = new Dictionary(true);
         var _loc3_:Dictionary = this._baseValues[param1];
         var _loc4_:Dictionary = this._modValues[param1];
         for(_loc5_ in _loc3_)
         {
            _loc2_[_loc5_] = this.getValue(param1,_loc5_);
         }
         for(_loc5_ in _loc4_)
         {
            if(!(_loc5_ in _loc2_))
            {
               _loc2_[_loc5_] = this.getValue(param1,_loc5_);
            }
         }
         return _loc2_;
      }
      
      public function getValueForBase(param1:String, param2:String, param3:Number) : Number
      {
         var _loc4_:Number = this.getUncappedValueForBase(param1,param2,param3);
         var _loc5_:Number = Number(this._attCaps[param1][param2]);
         if(!isNaN(_loc5_))
         {
            if(_loc4_ < 0)
            {
               _loc4_ = Math.max(_loc4_,_loc5_);
            }
            else
            {
               _loc4_ = Math.min(_loc4_,_loc5_);
            }
         }
         return ItemAttributes.cap(param2,_loc4_);
      }
      
      private function getUncappedValueForBase(param1:String, param2:String, param3:Number) : Number
      {
         var _loc6_:Number = NaN;
         var _loc4_:String = param2;
         switch(param2)
         {
            case "dmg_min":
            case "dmg_max":
               _loc4_ = "dmg";
               break;
            case "brst_min":
            case "brst_max":
               _loc4_ = "brst";
               break;
            default:
               _loc4_ = param2;
         }
         var _loc5_:Number = Number(this._modValues[param1][_loc4_]);
         if(isNaN(_loc5_))
         {
            _loc5_ = 0;
         }
         if(isAdditive(param2))
         {
            _loc6_ = param3 + _loc5_;
         }
         else if(!(param2 in this._baseValues[param1]))
         {
            _loc6_ = _loc5_;
         }
         else
         {
            _loc6_ = param3 + param3 * _loc5_;
         }
         return _loc6_;
      }
      
      public function getValue(param1:String, param2:String) : Number
      {
         return this.getValueForBase(param1,param2,this.getBaseValue(param1,param2));
      }
      
      public function getUncappedValue(param1:String, param2:String) : Number
      {
         return this.getUncappedValueForBase(param1,param2,this.getBaseValue(param1,param2));
      }
      
      protected function copyFrom(param1:ItemAttributes) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Dictionary = null;
         var _loc5_:Dictionary = null;
         var _loc6_:Dictionary = null;
         for each(_loc3_ in _allGroups)
         {
            _loc4_ = param1._baseValues[_loc3_];
            _loc5_ = param1._modValues[_loc3_];
            _loc6_ = param1._attCaps[_loc3_];
            for(_loc2_ in _loc4_)
            {
               this._baseValues[_loc3_][_loc2_] = _loc4_[_loc2_];
            }
            for(_loc2_ in _loc5_)
            {
               this._modValues[_loc3_][_loc2_] = _loc5_[_loc2_];
            }
            for(_loc2_ in _loc6_)
            {
               this._attCaps[_loc3_][_loc2_] = _loc6_[_loc2_];
            }
         }
      }
   }
}

