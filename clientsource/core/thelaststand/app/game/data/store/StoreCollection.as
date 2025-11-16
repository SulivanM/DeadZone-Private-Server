package thelaststand.app.game.data.store
{
   import playerio.DatabaseObject;
   import thelaststand.app.data.Currency;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.lang.Language;
   
   public class StoreCollection
   {
      
      private var _id:String;
      
      private var _key:String;
      
      private var _itemKeys:Vector.<String>;
      
      private var _cost:Number;
      
      private var _currency:String;
      
      private var _adminOnly:Boolean;
      
      private var _dateStart:Date;
      
      private var _dateEnd:Date;
      
      private var _levelMin:int;
      
      private var _levelMax:int;
      
      private var _isNew:Boolean;
      
      private var _allowIndividualPurchases:Boolean;
      
      public function StoreCollection(param1:String, param2:DatabaseObject)
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         super();
         this._key = param2.key;
         this._id = param1;
         this._adminOnly = param2.admin === true;
         this._isNew = param2["new"] === true;
         this._allowIndividualPurchases = param2.individualPurchases !== false;
         this._levelMin = "levelMin" in param2 ? int(param2.levelMin) : 0;
         this._levelMax = "levelMax" in param2 ? int(param2.levelMax) : int.MAX_VALUE;
         this._dateStart = "start" in param2 ? new Date(param2.start) : null;
         this._dateEnd = "end" in param2 ? new Date(param2.end) : null;
         this._itemKeys = new Vector.<String>();
         if(param2.items is Array)
         {
            _loc3_ = 0;
            while(_loc3_ < param2.items.length)
            {
               _loc4_ = String(param2.items[_loc3_]);
               if(_loc4_ == null)
               {
                  return;
               }
               this._itemKeys.push(_loc4_);
               _loc3_++;
            }
         }
         if(int(param2.PriceCoins) > 0)
         {
            this._cost = int(param2.PriceCoins);
            this._currency = Currency.FUEL;
         }
         else
         {
            this._currency = PlayerIOConnector.getInstance().user.defaultCurrency;
            switch(this._currency)
            {
               case Currency.US_DOLLARS:
                  this._cost = Number((param2.PriceUSD / 100).toFixed(2));
                  break;
               case Currency.KONGREGATE_KREDS:
                  this._cost = int(param2.PriceKKR);
                  break;
               default:
                  this._cost = 0;
            }
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get allowIndividualPurchases() : Boolean
      {
         return this._allowIndividualPurchases;
      }
      
      public function get isNew() : Boolean
      {
         return this._isNew;
      }
      
      public function get adminOnly() : Boolean
      {
         return this._adminOnly;
      }
      
      public function get itemKeys() : Vector.<String>
      {
         return this._itemKeys;
      }
      
      public function get canBuyAll() : Boolean
      {
         return this._cost > 0;
      }
      
      public function get cost() : Number
      {
         return this._cost;
      }
      
      public function get currency() : String
      {
         return this._currency;
      }
      
      public function get dateStart() : Date
      {
         return this._dateStart;
      }
      
      public function get dateEnd() : Date
      {
         return this._dateEnd;
      }
      
      public function get levelMin() : int
      {
         return this._levelMin;
      }
      
      public function get levelMax() : int
      {
         return this._levelMax;
      }
      
      public function isActive() : Boolean
      {
         if(this._adminOnly && Network.getInstance().playerData.isAdmin)
         {
            return true;
         }
         var _loc1_:Number = Network.getInstance().serverTime;
         if(this._dateStart != null && _loc1_ < this._dateStart.time || this._dateEnd != null && _loc1_ > this._dateEnd.time)
         {
            return false;
         }
         var _loc2_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         if(_loc2_ < this._levelMin || _loc2_ > this._levelMax)
         {
            return false;
         }
         return true;
      }
      
      public function getName() : String
      {
         return Language.getInstance().getString("itemcollection." + this._key);
      }
   }
}

