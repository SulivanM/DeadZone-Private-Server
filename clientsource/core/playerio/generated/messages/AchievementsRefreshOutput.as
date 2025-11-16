package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AchievementsRefreshOutput extends Message
   {
      
      public var version:String;
      
      public var achievements:Array = [];
      
      public var achievementsDummy:Achievement = null;
      
      public function AchievementsRefreshOutput()
      {
         super();
         registerField("version","",9,1,1);
         registerField("achievements","playerio.generated.messages.Achievement",11,3,2);
      }
   }
}

