package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class OneScoreSetOutput extends Message
   {
      public var oneScore:OneScoreValue;
      
      public var oneScoreDummy:OneScoreValue = null;
      
      public function OneScoreSetOutput()
      {
         super();
         registerField("oneScore","playerio.generated.messages.OneScoreValue",11,1,1);
      }
   }
}

