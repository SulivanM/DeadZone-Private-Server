package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class GameRequestsDeleteArgs extends Message
   {
      
      public var requestIds:Array = [];
      
      public function GameRequestsDeleteArgs(param1:Array)
      {
         super();
         registerField("requestIds","",9,3,1);
         this.requestIds = param1;
      }
   }
}

