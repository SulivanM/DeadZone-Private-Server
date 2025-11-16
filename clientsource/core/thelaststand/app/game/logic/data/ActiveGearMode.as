package thelaststand.app.game.logic.data
{
   public class ActiveGearMode
   {
      
      public static const NONE:uint = 0;
      
      public static const THROW:uint = 1;
      
      public static const PLACE:uint = 2;
      
      public static const SELECT:uint = 3;
      
      public static const SELF:uint = 4;
      
      public function ActiveGearMode()
      {
         super();
         throw new Error("ActiveGearMode cannot be directly instantiated.");
      }
   }
}

