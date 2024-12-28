package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class OneScoreValue extends Message
   {
      public var userId:String;
      
      public var score:int;
      
      public var percentile:Number;
      
      public var topRank:int;
      
      public function OneScoreValue()
      {
         super();
         registerField("userId","",9,1,1);
         registerField("score","",5,1,2);
         registerField("percentile","",2,1,3);
         registerField("topRank","",5,1,4);
      }
   }
}

