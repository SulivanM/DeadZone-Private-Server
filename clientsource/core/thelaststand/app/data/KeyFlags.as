package thelaststand.app.data
{
   public class KeyFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const CONTROL:uint = 1;
      
      public static const SHIFT:uint = 2;
      
      public function KeyFlags()
      {
         super();
         throw new Error("KeyFlags cannot be directly instantiated.");
      }
   }
}

