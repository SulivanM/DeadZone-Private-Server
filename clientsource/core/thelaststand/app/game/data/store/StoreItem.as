package thelaststand.app.game.data.store
{
   import playerio.DatabaseObject;
   import thelaststand.app.data.Currency;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class StoreItem
   {
      
      private var _key:String;
      
      private var _cost:Number;
      
      private var _currency:String;
      
      private var _item:Item;
      
      private var _isNew:Boolean;
      
      private var _isDeal:Boolean;
      
      private var _isPromoted:Boolean;
      
      private var _isCollectionOnly:Boolean;
      
      private var _adminOnly:Boolean;
      
      private var _dateStart:Date;
      
      private var _dateEnd:Date;
      
      private var _levelMin:int;
      
      private var _levelMax:int;
      
      private var _saleId:String;
      
      private var _originalCost:int;
      
      private var _savingPerc:Number;
      
      private var _showOrgPrice:Boolean;
      
      private var _priority:int;
      
      public function StoreItem(param1:DatabaseObject)
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         super();
         this._key = param1.key;
         this._item = ItemFactory.createItemFromObject(param1.item);
         this._isNew = param1["new"] === true;
         this._isDeal = param1.deal === true;
         this._isPromoted = param1.promo === true;
         this._isCollectionOnly = param1.collectionOnly === true;
         this._adminOnly = param1.admin === true;
         this._saleId = "sale" in param1 ? String(param1.sale) : null;
         this._savingPerc = "savingPerc" in param1 ? Number(param1.savingPerc) : 0;
         this._priority = int(param1.priority);
         this._levelMin = "levelMin" in param1 ? int(param1.levelMin) : 0;
         this._levelMax = "levelMax" in param1 ? int(param1.levelMax) : int.MAX_VALUE;
         this._dateStart = "start" in param1 ? new Date(param1.start) : null;
         this._dateEnd = "end" in param1 ? new Date(param1.end) : null;
         if(int(param1.PriceCoins) > 0)
         {
            this._cost = int(param1.PriceCoins);
            this._currency = Currency.FUEL;
         }
         else
         {
            this._currency = PlayerIOConnector.getInstance().user.defaultCurrency;
            switch(this._currency)
            {
               case Currency.US_DOLLARS:
                  this._cost = Number((param1.PriceUSD / 100).toFixed(2));
                  break;
               case Currency.KONGREGATE_KREDS:
                  this._cost = int(param1.PriceKKR);
                  break;
               default:
                  this._cost = 0;
            }
         }
         if(this._saleId != null)
         {
            _loc2_ = "orgPrice" + this._currency;
            if(_loc2_ in param1)
            {
               _loc3_ = int(param1[_loc2_]);
               this._originalCost = this._currency == Currency.US_DOLLARS ? int(Number((_loc3_ / 100).toFixed(2))) : int(_loc3_);
               this._showOrgPrice = Boolean(param1.showOrgPrice) && this._originalCost != this._cost;
            }
         }
         else
         {
            this._originalCost = 0;
            this._showOrgPrice = false;
         }
      }
      
      public function get adminOnly() : Boolean
      {
         return this._adminOnly;
      }
      
      public function get priority() : int
      {
         return this._priority;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function get isNew() : Boolean
      {
         return this._isNew;
      }
      
      public function get isCollectionOnly() : Boolean
      {
         return this._isCollectionOnly;
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
      
      public function get isDeal() : Boolean
      {
         return this._isDeal;
      }
      
      public function get isPromoted() : Boolean
      {
         return this._isPromoted;
      }
      
      public function get isOnSale() : Boolean
      {
         return this._saleId != null;
      }
      
      public function get saleId() : String
      {
         return this._saleId;
      }
      
      public function get originalCost() : int
      {
         return this._originalCost;
      }
      
      public function get savingPercentage() : Number
      {
         return this._savingPerc;
      }
      
      public function get showOriginalCost() : Boolean
      {
         return this._showOrgPrice;
      }
   }
}

