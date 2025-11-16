package mx.rpc
{
   public class Fault extends Error
   {
      
      public var content:Object;
      
      public var rootCause:Object;
      
      protected var _faultCode:String;
      
      protected var _faultString:String;
      
      protected var _faultDetail:String;
      
      public function Fault(param1:String, param2:String, param3:String = null)
      {
         super("faultCode:" + param1 + " faultString:\'" + param2 + "\' faultDetail:\'" + param3 + "\'");
         this._faultCode = param1;
         this._faultString = param2 ? param2 : "";
         this._faultDetail = param3;
      }
      
      public function get faultCode() : String
      {
         return this._faultCode;
      }
      
      public function get faultDetail() : String
      {
         return this._faultDetail;
      }
      
      public function get faultString() : String
      {
         return this._faultString;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "[RPC Fault";
         _loc1_ += " faultString=\"" + this.faultString + "\"";
         _loc1_ += " faultCode=\"" + this.faultCode + "\"";
         return _loc1_ + (" faultDetail=\"" + this.faultDetail + "\"]");
      }
   }
}

