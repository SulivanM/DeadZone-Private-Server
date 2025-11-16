package mx.rpc.http
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class SerializationFilter
   {
      
      mx_internal static var filterForResultFormatTable:Object = new Object();
      
      public function SerializationFilter()
      {
         super();
      }
      
      public static function registerFilterForResultFormat(param1:String, param2:SerializationFilter) : SerializationFilter
      {
         var _loc3_:SerializationFilter = mx_internal::filterForResultFormatTable[param1];
         mx_internal::filterForResultFormatTable[param1] = param2;
         return _loc3_;
      }
      
      public function deserializeResult(param1:AbstractOperation, param2:Object) : Object
      {
         return param2;
      }
      
      public function getRequestContentType(param1:AbstractOperation, param2:Object, param3:String) : String
      {
         return param3;
      }
      
      public function serializeParameters(param1:AbstractOperation, param2:Array) : Object
      {
         var _loc3_:Array = param1.argumentNames;
         if(param2 == null || param2.length == 0)
         {
            return param2;
         }
         if(_loc3_ == null || param2.length != _loc3_.length)
         {
            throw new ArgumentError("HTTPMultiService operation called with " + (_loc3_ == null ? 0 : _loc3_.length) + " argumentNames and " + param2.length + " number of parameters.  When argumentNames is specified, it must match the number of arguments passed to the invocation");
         }
         var _loc4_:Object = new Object();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc4_[_loc3_[_loc5_]] = param2[_loc5_];
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function serializeBody(param1:AbstractOperation, param2:Object) : Object
      {
         return param2;
      }
      
      public function serializeURL(param1:AbstractOperation, param2:Object, param3:String) : String
      {
         return param3;
      }
   }
}

