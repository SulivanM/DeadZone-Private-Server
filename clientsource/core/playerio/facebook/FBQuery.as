package playerio.facebook
{
   import flash.events.*;
   import flash.external.*;
   import flash.net.*;
   import flash.system.*;
   
   public class FBQuery extends FBWaitable
   {
      
      private static var counter:int = 0;
      
      public var name:String = "";
      
      public var hasDependency:Boolean = false;
      
      public var fields:Array = [];
      
      public var table:String = null;
      
      public var where:Object = null;
      
      public function FBQuery()
      {
         super();
         this.name = "v_" + counter++;
      }
      
      internal function parse(param1:String, param2:Array) : FBQuery
      {
         var _loc3_:String = FB.stringFormat(param1,param2);
         var _loc4_:Object = /^select (.*?) from (\w+)\s+where (.*)$/i.exec(_loc3_);
         this.fields = this._toFields(_loc4_[1]);
         this.table = _loc4_[2];
         this.where = this._parseWhere(_loc4_[3]);
         var _loc5_:uint = 0;
         while(_loc5_ < param2.length)
         {
            if(param2[_loc5_] is FBQuery)
            {
               param2[_loc5_].hasDependency = true;
            }
            _loc5_++;
         }
         return this;
      }
      
      public function toFql() : String
      {
         var _loc1_:* = "select " + this.fields.join(",") + " from " + this.table + " where ";
         switch(this.where.type)
         {
            case "unknown":
               _loc1_ += this.where.value;
               break;
            case "index":
               _loc1_ += this.where.key + "=" + this._encode(this.where.value);
               break;
            case "in":
               if(this.where.value.length == 1)
               {
                  _loc1_ += this.where.key + "=" + this._encode(this.where.value[0]);
                  break;
               }
               _loc1_ += this.where.key + " in (" + FB.arrayMap(this.where.value,this._encode).join(",") + ")";
         }
         return _loc1_;
      }
      
      private function _encode(param1:Object) : String
      {
         return typeof param1 == "string" ? FB.stringQuote(param1 + "") : param1 + "";
      }
      
      public function toString() : String
      {
         return "#" + this.name;
      }
      
      private function _toFields(param1:String) : Array
      {
         return FB.arrayMap(param1.split(","),FB.stringTrim);
      }
      
      private function _parseWhere(param1:String) : Object
      {
         var _loc2_:Object = /^\s*(\w+)\s*=\s*(.*)\s*$/i.exec(param1);
         var _loc3_:Object = null;
         var _loc4_:* = null;
         var _loc5_:String = "unknown";
         if(_loc2_)
         {
            _loc4_ = _loc2_[2];
            if(/^(["'])(?:\\?.)*?\1$/.test(_loc4_))
            {
               _loc4_ = JSON2.deserialize(_loc4_);
               _loc5_ = "index";
            }
            else if(/^\d+\.?\d*$/.test(_loc4_))
            {
               _loc5_ = "index";
            }
         }
         if(_loc5_ == "index")
         {
            _loc3_ = {
               "type":"index",
               "key":_loc2_[1],
               "value":_loc4_
            };
         }
         else
         {
            _loc3_ = {
               "type":"unknown",
               "value":param1
            };
         }
         return _loc3_;
      }
   }
}

