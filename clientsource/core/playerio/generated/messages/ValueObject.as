package playerio.generated.messages
{
   import com.protobuf.Message;
   import flash.utils.ByteArray;
   
   public final class ValueObject extends Message
   {
      
      public var valueType:int;
      
      public var string:String;
      
      public var int32:int;
      
      public var uInt:uint;
      
      public var long:Number;
      
      public var bool:Boolean;
      
      public var float:Number;
      
      public var double:Number;
      
      public var byteArray:ByteArray;
      
      public var dateTime:Number;
      
      public var arrayProperties:Array = [];
      
      public var arrayPropertiesDummy:ArrayProperty = null;
      
      public var objectProperties:Array = [];
      
      public var objectPropertiesDummy:ObjectProperty = null;
      
      public function ValueObject()
      {
         super();
         registerField("valueType","",14,1,1);
         registerField("string","",9,1,2);
         registerField("int32","",5,1,3);
         registerField("uInt","",13,1,4);
         registerField("long","",3,1,5);
         registerField("bool","",8,1,6);
         registerField("float","",2,1,7);
         registerField("double","",1,1,8);
         registerField("byteArray","",12,1,9);
         registerField("dateTime","",3,1,10);
         registerField("arrayProperties","playerio.generated.messages.ArrayProperty",11,3,11);
         registerField("objectProperties","playerio.generated.messages.ObjectProperty",11,3,12);
      }
   }
}

