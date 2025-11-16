package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class Notification extends Message
   {
      
      public var recipient:String;
      
      public var endpointType:String;
      
      public var oldKeyValueData:Array = [];
      
      public var oldKeyValueDataDummy:KeyValuePair = null;
      
      public var data:Array = [];
      
      public var dataDummy:ObjectProperty = null;
      
      public function Notification()
      {
         super();
         registerField("recipient","",9,1,1);
         registerField("endpointType","",9,1,2);
         registerField("oldKeyValueData","playerio.generated.messages.KeyValuePair",11,3,3);
         registerField("data","playerio.generated.messages.ObjectProperty",11,3,4);
      }
   }
}

