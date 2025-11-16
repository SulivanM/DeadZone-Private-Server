package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   import thelaststand.common.io.ISerializable;
   
   public class GameResources implements ISerializable
   {
      
      public static const CASH:String = "cash";
      
      public static const WOOD:String = "wood";
      
      public static const METAL:String = "metal";
      
      public static const CLOTH:String = "cloth";
      
      public static const WATER:String = "water";
      
      public static const FOOD:String = "food";
      
      public static const AMMUNITION:String = "ammunition";
      
      public static const RESOURCE_COLORS:Dictionary = new Dictionary(true);
      
      RESOURCE_COLORS[GameResources.WOOD] = 11576467;
      RESOURCE_COLORS[GameResources.METAL] = 10266807;
      RESOURCE_COLORS[GameResources.CLOTH] = 12235674;
      RESOURCE_COLORS[GameResources.FOOD] = 10017587;
      RESOURCE_COLORS[GameResources.WATER] = 4363464;
      RESOURCE_COLORS[GameResources.CASH] = 3920209;
      RESOURCE_COLORS[GameResources.AMMUNITION] = 15179546;
      
      private var _cash:Number = 0;
      
      private var _wood:Number = 0;
      
      private var _metal:Number = 0;
      
      private var _cloth:Number = 0;
      
      private var _water:Number = 0;
      
      private var _food:Number = 0;
      
      private var _ammunition:Number = 0;
      
      private var _compound:CompoundData;
      
      public var resourceChanged:Signal;
      
      public var storageCapacityChanged:Signal;
      
      public function GameResources(param1:CompoundData)
      {
         super();
         this._compound = param1;
         this.resourceChanged = new Signal(String,Number);
         this.storageCapacityChanged = new Signal(String);
      }
      
      public static function getResourceList() : Array
      {
         return [CASH,WOOD,METAL,CLOTH,FOOD,WATER,AMMUNITION];
      }
      
      public function addAmount(param1:String, param2:Number) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param2 == 0 || !param1 || param1 == "undefined")
         {
            return;
         }
         var _loc3_:Number = Number(this["_" + param1]);
         if(param1 == GameResources.CASH)
         {
            this["_" + param1] += param2;
         }
         else
         {
            _loc4_ = this.getTotalStorageCapacity(param1);
            if(param2 > 0)
            {
               param2 = Math.min(param2,this.getAvailableStorageCapacity(param1));
            }
            _loc5_ = Math.max(_loc3_ + param2,0);
            this["_" + param1] = _loc5_;
         }
         if(this["_" + param1] != _loc3_)
         {
            this.resourceChanged.dispatch(param1,this["_" + param1]);
         }
      }
      
      public function dispose() : void
      {
         this._compound = null;
         this.resourceChanged.removeAll();
      }
      
      public function setAmount(param1:String, param2:int) : void
      {
         if(param1 == null || param1 == "undefined" || param1 == "key")
         {
            return;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         var _loc3_:Number = Number(this["_" + param1]);
         this["_" + param1] = param2;
         if(this["_" + param1] != _loc3_)
         {
            this.resourceChanged.dispatch(param1,this["_" + param1]);
         }
      }
      
      public function add(param1:*, param2:Number = 1) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc7_:XML = null;
         var _loc5_:XMLList = param1 as XMLList;
         if(_loc5_ != null)
         {
            for each(_loc7_ in _loc5_)
            {
               if(_loc7_.localName() == "res")
               {
                  _loc3_ = _loc7_.@id.toString();
                  _loc4_ = Number(_loc7_.toString());
                  if(_loc3_ == FOOD || _loc3_ == WATER)
                  {
                     this.addAmount(_loc3_,_loc4_ * param2);
                  }
                  else
                  {
                     this.addAmount(_loc3_,Math.floor(_loc4_ * param2));
                  }
               }
            }
            return;
         }
         var _loc6_:Object = param1;
         if(_loc6_ != null)
         {
            for(_loc3_ in _loc6_)
            {
               _loc4_ = Number(_loc6_[_loc3_]);
               if(_loc3_ == FOOD || _loc3_ == WATER)
               {
                  this.addAmount(_loc3_,_loc4_ * param2);
               }
               else
               {
                  this.addAmount(_loc3_,Math.floor(_loc4_ * param2));
               }
            }
            return;
         }
      }
      
      public function getAmount(param1:String) : Number
      {
         var _loc3_:Number = NaN;
         if(!param1 || param1 == "undefined")
         {
            return 0;
         }
         var _loc2_:Number = Number(this["_" + param1]);
         if(param1 != CASH)
         {
            _loc3_ = this.getTotalStorageCapacity(param1);
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            if(_loc2_ > _loc3_ - 1 && _loc2_ < _loc3_)
            {
               _loc2_ = _loc3_;
            }
         }
         return _loc2_;
      }
      
      public function getResourceDaysRemaining(param1:String, param2:Boolean = true) : Number
      {
         var _loc7_:Number = NaN;
         var _loc3_:int = 24 * 60 * 60;
         var _loc4_:Number = this.getAmount(param1);
         var _loc5_:int = 0;
         var _loc6_:Number = 0;
         switch(param1)
         {
            case GameResources.FOOD:
               _loc6_ = param2 ? Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("FoodConsumption")) / 100 : 1;
               _loc5_ = int(Config.constant.SURVIVOR_ADULT_FOOD_CONSUMPTION);
               break;
            case GameResources.WATER:
               _loc6_ = param2 ? Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("WaterConsumption")) / 100 : 1;
               _loc5_ = int(Config.constant.SURVIVOR_ADULT_WATER_CONSUMPTION);
               break;
            default:
               return 0;
         }
         if(_loc5_ == 0)
         {
            return 0;
         }
         if(_loc6_ <= -1)
         {
            return Number.POSITIVE_INFINITY;
         }
         _loc7_ = _loc4_ / (int(_loc3_ / _loc5_) * (1 + _loc6_) * this._compound.survivors.length);
         var _loc8_:Number = 0.5;
         return Math.floor(_loc7_ / _loc8_) * _loc8_;
      }
      
      public function getResourceDaysRequired(param1:String) : Number
      {
         switch(param1)
         {
            case GameResources.FOOD:
               return Number(Config.constant.SURVIVOR_FOOD_DAYS_REQ);
            case GameResources.WATER:
               return Number(Config.constant.SURVIVOR_WATER_DAYS_REQ);
            default:
               return 0;
         }
      }
      
      public function getTotalStorageCapacity(param1:String) : Number
      {
         var _loc5_:Building = null;
         var _loc2_:int = 0;
         var _loc3_:Vector.<Building> = this._compound.buildings.getBuildingsOfType("storage-" + param1);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            if(_loc5_.storageResource == param1)
            {
               if(!_loc5_.isUnderConstruction())
               {
                  _loc2_ += Building.getResourceCapacity(_loc5_);
               }
            }
            _loc4_++;
         }
         return Math.floor(Math.max(this.getMinCapacity(param1),_loc2_));
      }
      
      public function getMinCapacity(param1:String) : Number
      {
         var _loc2_:* = "MIN_" + param1.toUpperCase() + "_CAPACITY";
         return Config.constant[_loc2_] != null ? Number(Config.constant[_loc2_]) : 0;
      }
      
      public function getAvailableStorageCapacity(param1:String) : Number
      {
         var _loc2_:int = int(this.getTotalStorageCapacity(param1));
         var _loc3_:int = Math.floor(this.getAmount(param1));
         return int(Math.max(_loc2_ - _loc3_,0));
      }
      
      public function getTotalProductionRate(param1:String) : Number
      {
         var _loc5_:Building = null;
         var _loc2_:Number = 0;
         var _loc3_:Vector.<Building> = this._compound.buildings.getBuildingsOfType("resource-" + param1);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            if(_loc5_.productionResource == param1)
            {
               if(!_loc5_.isUnderConstruction())
               {
                  _loc2_ += Building.getProductionRate(_loc5_);
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function hasResources(param1:*) : Boolean
      {
         var dict:Dictionary;
         var type:String = null;
         var curValue:Number = NaN;
         var reqValue:Number = NaN;
         var node:XML = null;
         var dictOrXMLList:* = param1;
         var xmlList:XMLList = dictOrXMLList as XMLList;
         if(xmlList != null)
         {
            for each(node in xmlList)
            {
               if(node.localName() == "res")
               {
                  type = node.@id.toString();
                  curValue = Math.floor(this.getAmount(type));
                  reqValue = Number(node.toString());
                  if(curValue < reqValue)
                  {
                     return false;
                  }
               }
            }
            return true;
         }
         dict = dictOrXMLList as Dictionary;
         if(dict != null)
         {
            for(type in dict)
            {
               try
               {
                  curValue = Math.floor(this.getAmount(type));
               }
               catch(err:Error)
               {
                  continue;
               }
               reqValue = Number(dict[type]);
               if(curValue < reqValue)
               {
                  return false;
               }
            }
            return true;
         }
         return true;
      }
      
      public function remove(param1:*, param2:Number = 1) : void
      {
         this.add(param1,-param2);
      }
      
      public function toString() : String
      {
         return "(cash= " + this._cash + ", wood=" + this._wood + ", metal=" + this._metal + ", cloth=" + this._cloth + ", water=" + this._water + ", food=" + this._food + ", ammo=" + this._ammunition + ")";
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         if(!param1)
         {
            param1 = {};
         }
         param1.wood = this._wood;
         param1.metal = this._metal;
         param1.cloth = this._cloth;
         param1.food = this._food;
         param1.water = this._water;
         param1.cash = this._cash;
         param1.ammunition = this._ammunition;
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(!(!_loc2_ || _loc2_ == "undefined" || _loc2_ == "key"))
            {
               this.setAmount(_loc2_,param1[_loc2_]);
            }
         }
      }
   }
}

