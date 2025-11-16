package thelaststand.app.game.data.effects
{
   public class EffectSaveFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const CONSUMABLE:uint = 1;
      
      public static const PERMANENT:uint = 2;
      
      public static const LINKED_ITEM:uint = 4;
      
      public function EffectSaveFlags()
      {
         super();
         throw new Error("EffectSaveFlags cannot be directly instantiated.");
      }
   }
}

