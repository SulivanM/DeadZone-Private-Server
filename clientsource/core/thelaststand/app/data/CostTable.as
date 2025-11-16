package thelaststand.app.data
{
   import flash.utils.Dictionary;
   import playerio.DatabaseObject;
   import playerio.PlayerIOError;
   import thelaststand.app.network.Network;
   
   public class CostTable
   {
      
      public static const CATEGORY_SPEED_UPS:String = "speed_ups";
      
      private var _categories:Dictionary;
      
      private var _objectsByKey:Dictionary;
      
      public function CostTable()
      {
         super();
         this._categories = new Dictionary(true);
         this._objectsByKey = new Dictionary(true);
      }
      
      public function getCost(param1:Object) : int
      {
         if(param1.hasOwnProperty("PriceCoins"))
         {
            return int(param1.PriceCoins);
         }
         return 0;
      }
      
      public function getCostForTime(param1:Object, param2:int = 0) : int
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1.hasOwnProperty("PriceCoins"))
         {
            _loc3_ = param1.hasOwnProperty("minCost") ? int(param1.minCost) : 0;
            if(param1.hasOwnProperty("percent"))
            {
               _loc4_ = Number(param1.percent);
               if(_loc4_ < 0)
               {
                  _loc4_ = 0;
               }
               else if(_loc4_ > 1)
               {
                  _loc4_ = 1;
               }
               param2 = Math.floor(param2 * _loc4_);
            }
            else if(param1.hasOwnProperty("time"))
            {
               param2 = int(param1.time);
            }
            if(param1.hasOwnProperty("costPerMin"))
            {
               _loc5_ = Number(param1.costPerMin);
               return Math.max(_loc3_,Math.floor(param2 / 60 * _loc5_));
            }
            return Math.max(_loc3_,int(param1.PriceCoins));
         }
         return 0;
      }
      
      public function getItemByKey(param1:String) : Object
      {
         var _loc2_:Object = this._objectsByKey[param1];
         return _loc2_ || this._objectsByKey[param1.toLowerCase()];
      }
      
      public function getOrLoadItemByKey(param1:String, param2:Function) : void
      {
         var key:String = param1;
         var onComplete:Function = param2;
         var item:Object = this.getItemByKey(key);
         if(item != null)
         {
            onComplete(item);
            return;
         }
         Network.getInstance().client.bigDB.load("PayVaultItems",key,function(param1:DatabaseObject):void
         {
            if(param1 != null)
            {
               _objectsByKey[param1.key] = param1;
            }
            onComplete(param1);
         },function(param1:PlayerIOError):void
         {
            onComplete(null);
         });
      }
      
      public function getItems(param1:Object) : Vector.<Object>
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Vector.<Object> = new Vector.<Object>();
         if(param1 is String)
         {
            _loc3_ = String(param1);
            for each(_loc2_ in Dictionary(this._categories[_loc3_]))
            {
               _loc4_.push(_loc2_);
            }
         }
         else if(param1 is Array || param1 is Vector.<String>)
         {
            for each(_loc3_ in param1)
            {
               for each(_loc2_ in Dictionary(this._categories[_loc3_]))
               {
                  _loc4_.push(_loc2_);
               }
            }
         }
         return _loc4_;
      }
      
      public function update(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Dictionary = null;
         this._categories = new Dictionary(true);
         this._objectsByKey = new Dictionary(true);
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            _loc3_.key = _loc2_;
            this._objectsByKey[_loc2_] = _loc3_;
            if(_loc3_.hasOwnProperty("type"))
            {
               _loc4_ = String(_loc3_.type);
               _loc5_ = this._categories[_loc4_];
               if(_loc5_ == null)
               {
                  _loc5_ = this._categories[_loc4_] = new Dictionary(true);
               }
               _loc5_[_loc2_] = _loc3_;
            }
         }
      }
   }
}

