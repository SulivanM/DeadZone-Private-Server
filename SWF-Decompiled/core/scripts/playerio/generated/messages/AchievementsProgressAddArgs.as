package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AchievementsProgressAddArgs extends Message
   {
      public var achievementId:String;
      
      public var progressDelta:int;
      
      public function AchievementsProgressAddArgs(param1:String, param2:int)
      {
         super();
         registerField("achievementId","",9,1,1);
         registerField("progressDelta","",5,1,2);
         this.achievementId = param1;
         this.progressDelta = param2;
      }
   }
}

