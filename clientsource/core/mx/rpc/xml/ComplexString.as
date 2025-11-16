package mx.rpc.xml
{
   internal dynamic class ComplexString
   {
      
      public var value:String;
      
      public function ComplexString(param1:String)
      {
         super();
         this.value = param1;
      }
      
      public function toString() : String
      {
         return this.value;
      }
      
      public function valueOf() : Object
      {
         return SimpleXMLDecoder.simpleType(this.value);
      }
   }
}

