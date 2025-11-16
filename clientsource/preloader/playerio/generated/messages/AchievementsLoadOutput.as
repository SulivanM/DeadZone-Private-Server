package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AchievementsLoadOutput extends Message
   {
      
      public var userAchievements:Array = [];
      
      public var userAchievementsDummy:UserAchievements = null;
      
      public function AchievementsLoadOutput()
      {
         super();
         registerField("userAchievements","playerio.generated.messages.UserAchievements",11,3,1);
      }
   }
}

