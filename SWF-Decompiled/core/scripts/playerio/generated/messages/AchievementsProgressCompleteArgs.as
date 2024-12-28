package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AchievementsProgressCompleteArgs extends Message
   {
      public var achievementId:String;
      
      public function AchievementsProgressCompleteArgs(param1:String)
      {
         super();
         registerField("achievementId","",9,1,1);
         this.achievementId = param1;
      }
   }
}

