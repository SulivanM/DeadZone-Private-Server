package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class UserAchievements extends Message
   {
      
      public var userId:String;
      
      public var achievements:Array = [];
      
      public var achievementsDummy:Achievement = null;
      
      public function UserAchievements()
      {
         super();
         registerField("userId","",9,1,1);
         registerField("achievements","playerio.generated.messages.Achievement",11,3,2);
      }
   }
}

