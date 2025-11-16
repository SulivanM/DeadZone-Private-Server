package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PlayerInsightTrackEventsArgs extends Message
   {
      
      public var events:Array = [];
      
      public var eventsDummy:PlayerInsightEvent = null;
      
      public function PlayerInsightTrackEventsArgs(param1:Array)
      {
         super();
         registerField("events","playerio.generated.messages.PlayerInsightEvent",11,3,1);
         this.events = param1;
      }
   }
}

