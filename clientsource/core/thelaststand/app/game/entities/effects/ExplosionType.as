package thelaststand.app.game.entities.effects
{
   public class ExplosionType
   {
      
      public static const FRAG:String = "frag";
      
      public static const SMOKE:String = "smoke";
      
      public function ExplosionType()
      {
         super();
         throw new Error("ExplosionType cannot be directly instantiated.");
      }
   }
}

