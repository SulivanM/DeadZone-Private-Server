package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PlayerInsightRefreshOutput extends Message
   {
      public var state:PlayerInsightState;
      
      public var stateDummy:PlayerInsightState = null;
      
      public function PlayerInsightRefreshOutput()
      {
         super();
         registerField("state","playerio.generated.messages.PlayerInsightState",11,1,1);
      }
   }
}

