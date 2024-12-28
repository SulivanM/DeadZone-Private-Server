package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PlayerInsightEvent extends Message
   {
      public var eventType:String;
      
      public var value:int;
      
      public function PlayerInsightEvent()
      {
         super();
         registerField("eventType","",9,1,1);
         registerField("value","",5,1,2);
      }
   }
}

