package thelaststand.app.network
{
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.Survivor;
   
   public class OfferSystem
   {
      
      private static var _instance:OfferSystem;
      
      private var _initialized:Boolean = false;
      
      private var _allOffers:Vector.<Object>;
      
      private var _currentOffers:Vector.<Object>;
      
      public var changed:Signal;
      
      public function OfferSystem(param1:OfferSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("OfferSystem is a Singleton and cannot be directly instantiated. Use OfferSystem.getInstance().");
         }
         this.changed = new Signal();
      }
      
      public static function getInstance() : OfferSystem
      {
         if(!_instance)
         {
            _instance = new OfferSystem(new OfferSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public function get numOffers() : int
      {
         return this._currentOffers.length;
      }
      
      public function init() : void
      {
         if(this._initialized)
         {
            return;
         }
         this._initialized = true;
         this._allOffers = new Vector.<Object>();
         this._currentOffers = new Vector.<Object>();
         if(!Settings.getInstance().offersEnabled)
         {
            return;
         }
         Network.getInstance().save(null,SaveDataMethod.GET_OFFERS,function(param1:Object):void
         {
            var _loc2_:String = null;
            var _loc3_:Object = null;
            if(param1 == null || param1.success === false)
            {
               return;
            }
            for(_loc2_ in param1.offers)
            {
               _loc3_ = param1.offers[_loc2_];
               _loc3_.key = _loc2_;
               _loc3_.viewed = Settings.getInstance().getData("o_" + _loc3_.key + "_v",false);
               if(_loc3_.expires)
               {
                  _loc3_.expires = new Date(_loc3_.expires);
                  _loc3_.expires.minutes -= _loc3_.expires.timezoneOffset;
               }
               _currentOffers.push(_loc3_);
               _allOffers.push(_loc3_);
            }
            changed.dispatch();
            Network.getInstance().playerData.getPlayerSurvivor().levelIncreased.add(onPlayerLevelIncreased);
         });
      }
      
      public function getOffer(param1:int) : Object
      {
         if(param1 < 0 || param1 >= this._currentOffers.length)
         {
            return null;
         }
         return this._currentOffers[param1];
      }
      
      public function getOfferById(param1:String) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this._allOffers)
         {
            if(_loc2_.key == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getOffers() : Vector.<Object>
      {
         return this._currentOffers.concat();
      }
      
      public function hasUnviewedOffers() : Boolean
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this._currentOffers)
         {
            if(!_loc1_.viewed)
            {
               return true;
            }
         }
         return false;
      }
      
      public function removeOffer(param1:String) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = int(this._currentOffers.length - 1);
         while(_loc3_ >= 0)
         {
            _loc4_ = this._currentOffers[_loc3_];
            if(_loc4_ != null && _loc4_.key == param1)
            {
               this._currentOffers.splice(_loc3_,1);
               _loc2_ = true;
            }
            _loc3_--;
         }
         if(_loc2_)
         {
            this.changed.dispatch();
         }
      }
      
      public function setOfferViewedState(param1:Object, param2:Boolean) : void
      {
         param1.viewed = param2;
         Settings.getInstance().setData("o_" + param1.key + "_v",param2);
      }
      
      private function onPlayerLevelIncreased(param1:Survivor, param2:int) : void
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:int = int(this._currentOffers.length - 1);
         while(_loc4_ >= 0)
         {
            _loc5_ = this._currentOffers[_loc4_];
            if(_loc5_ != null)
            {
               _loc6_ = "levelMin" in _loc5_ ? int(_loc5_.levelMin) : 0;
               _loc7_ = "levelMax" in _loc5_ ? int(_loc5_.levelMax) : int.MAX_VALUE;
               if(param2 < _loc6_ || param2 > _loc7_)
               {
                  this._currentOffers.splice(_loc4_,1);
                  _loc3_ = true;
               }
            }
            _loc4_--;
         }
         if(_loc3_)
         {
            this.changed.dispatch();
         }
      }
   }
}

class OfferSystemSingletonEnforcer
{
   
   public function OfferSystemSingletonEnforcer()
   {
      super();
   }
}
