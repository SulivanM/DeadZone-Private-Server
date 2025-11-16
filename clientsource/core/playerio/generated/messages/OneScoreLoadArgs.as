package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class OneScoreLoadArgs extends Message
   {
      
      public var userIds:Array = [];
      
      public function OneScoreLoadArgs(param1:Array)
      {
         super();
         registerField("userIds","",9,3,1);
         this.userIds = param1;
      }
   }
}

