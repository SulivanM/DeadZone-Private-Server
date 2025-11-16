package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PlayerInsightState extends Message
   {
      
      public var playersOnline:int;
      
      public var segments:Array = [];
      
      public var segmentsDummy:KeyValuePair = null;
      
      public function PlayerInsightState()
      {
         super();
         registerField("playersOnline","",5,1,1);
         registerField("segments","playerio.generated.messages.KeyValuePair",11,3,2);
      }
   }
}

