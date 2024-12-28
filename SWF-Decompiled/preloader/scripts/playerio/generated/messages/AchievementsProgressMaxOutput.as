package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AchievementsProgressMaxOutput extends Message
   {
      public var achievement:Achievement;
      
      public var achievementDummy:Achievement = null;
      
      public var completedNow:Boolean;
      
      public function AchievementsProgressMaxOutput()
      {
         super();
         registerField("achievement","playerio.generated.messages.Achievement",11,1,1);
         registerField("completedNow","",8,1,2);
      }
   }
}

