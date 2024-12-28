package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class OneScoreSetArgs extends Message
   {
      public var score:int;
      
      public function OneScoreSetArgs(param1:int)
      {
         super();
         registerField("score","",5,1,1);
         this.score = param1;
      }
   }
}

