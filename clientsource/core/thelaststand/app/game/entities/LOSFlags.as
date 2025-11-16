package thelaststand.app.game.entities
{
   public class LOSFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const SMOKE:uint = 1;
      
      public static const ALL:uint = 65535;
      
      public function LOSFlags()
      {
         super();
         throw new Error("LOSFlags cannot be directly instantiated.");
      }
   }
}

