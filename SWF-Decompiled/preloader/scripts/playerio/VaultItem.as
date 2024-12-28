package playerio
{
   public dynamic class VaultItem
   {
      private var _id:String;
      
      private var _itemKey:String;
      
      private var _purchaseDate:Date;
      
      private var prefix:String = "    ";
      
      public function VaultItem(param1:String, param2:String, param3:Date)
      {
         super();
         this._id = param1;
         this._itemKey = param2;
         this._purchaseDate = param3;
      }
      
      public function get id() : String
      {
         return _id;
      }
      
      public function get itemKey() : String
      {
         return _itemKey;
      }
      
      public function get purchaseDate() : Date
      {
         return _purchaseDate;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "[playerio.VaultItem]";
         return _loc1_ + ("[itemKey=\"" + _itemKey + "\", id=\"" + _id + "\", purchaseDate=" + _purchaseDate + "] = " + serialize(prefix,this));
      }
      
      private function serialize(param1:String, param2:*) : String
      {
         var _loc4_:int = 0;
         var _loc3_:String = "";
         var _loc6_:String = "";
         var _loc5_:Array = [];
         if(param2 is String)
         {
            return "\"" + param2 + "\"";
         }
         if(param2 is Array)
         {
            _loc3_ = "[\n";
            for(_loc6_ in param2)
            {
               if(param2[_loc6_] !== undefined)
               {
                  _loc5_.push({
                     "id":_loc6_,
                     "value":serialize(param1 + prefix,param2[_loc6_])
                  });
               }
            }
            _loc5_.sortOn("id",16);
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               _loc3_ += param1 + _loc5_[_loc4_].id + ":" + _loc5_[_loc4_].value + "\n";
               _loc4_++;
            }
            return _loc3_ + (param1.substring(4) + "]");
         }
         if(param2 is Object)
         {
            if(param2.constructor == Object || param2.constructor == VaultItem)
            {
               _loc3_ = "{\n";
               for(_loc6_ in param2)
               {
                  if(param2[_loc6_] !== undefined)
                  {
                     _loc5_.push({
                        "id":_loc6_,
                        "value":serialize(param1 + prefix,param2[_loc6_])
                     });
                  }
               }
               _loc5_.sortOn("id");
               _loc4_ = 0;
               while(_loc4_ < _loc5_.length)
               {
                  _loc3_ += param1 + _loc5_[_loc4_].id + ":" + _loc5_[_loc4_].value + "\n";
                  _loc4_++;
               }
               return _loc3_ + (param1.substring(4) + "}");
            }
         }
         if(param2 == null)
         {
            return param2;
         }
         return param2.toString();
      }
   }
}

