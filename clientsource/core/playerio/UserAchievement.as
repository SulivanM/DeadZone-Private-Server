package playerio
{
   internal class UserAchievement
   {
      
      private var _userId:String = "";
      
      private var _achievements:Array = [];
      
      public function UserAchievement(param1:String, param2:Array)
      {
         super();
         _achievements = param2;
         _userId = param1;
      }
      
      public function get userId() : String
      {
         return _userId;
      }
      
      public function get achievements() : Array
      {
         return _achievements;
      }
   }
}

