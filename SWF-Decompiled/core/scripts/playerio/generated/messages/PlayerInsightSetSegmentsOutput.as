package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PlayerInsightSetSegmentsOutput extends Message
   {
      public var state:PlayerInsightState;
      
      public var stateDummy:PlayerInsightState = null;
      
      public function PlayerInsightSetSegmentsOutput()
      {
         super();
         registerField("state","playerio.generated.messages.PlayerInsightState",11,1,1);
      }
   }
}

