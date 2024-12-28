package playerio
{
   public dynamic class PayVaultHistoryEntry
   {
      private var _amount:int;
      
      private var _type:String;
      
      private var _timestamp:Date;
      
      private var _itemKeys:Array;
      
      private var _reason:String;
      
      private var _providerTransactionId:String;
      
      private var _providerPrice:String;
      
      public function PayVaultHistoryEntry(param1:int, param2:String, param3:Date, param4:Array, param5:String, param6:String, param7:String)
      {
         super();
         this._amount = param1;
         this._type = param2;
         this._timestamp = param3;
         this._itemKeys = param4;
         this._reason = param5;
         this._providerTransactionId = param6;
         this._providerPrice = param7;
      }
      
      public function get amount() : int
      {
         return _amount;
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function get timestamp() : Date
      {
         return _timestamp;
      }
      
      public function get itemKeys() : Array
      {
         return _itemKeys;
      }
      
      public function get reason() : String
      {
         return _reason;
      }
      
      public function get providerTransactionId() : String
      {
         return _providerTransactionId;
      }
      
      public function get providerPrice() : String
      {
         return _providerPrice;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "[playerio.PayVaultHistoryEntry] = {\n";
         _loc1_ += "\ttype:\"" + _type + "\"\n";
         _loc1_ += "\tamount:" + _amount + "\n";
         _loc1_ += "\ttimestamp:" + _timestamp + "\n";
         _loc1_ += "\titemKeys:[" + _itemKeys + "]\n";
         _loc1_ += "\treason:\"" + _reason + "\"\n";
         _loc1_ += "\tproviderTransactionId:" + (_providerTransactionId !== null ? "\"" + _providerTransactionId + "\"" : "null") + "\n";
         _loc1_ += "\tproviderPrice:\"" + _providerPrice + "\"\n";
         return _loc1_ + "}";
      }
   }
}

