package thelaststand.app.game.data
{
   public class AttributeOptions
   {
      
      public static const INCLUDE_NONE:uint = 0;
      
      public static const INCLUDE_INJURIES:uint = 1;
      
      public static const INCLUDE_MORALE:uint = 2;
      
      public static const INCLUDE_AI_EFFECTS:uint = 4;
      
      public static const INCLUDE_RESEARCH:uint = 8;
      
      public static const INCLUDE_EFFECTS:uint = 16;
      
      public static const INCLUDE_ALL:uint = INCLUDE_INJURIES | INCLUDE_MORALE | INCLUDE_AI_EFFECTS | INCLUDE_RESEARCH | INCLUDE_EFFECTS;
      
      public static const NO_MORALE:uint = INCLUDE_ALL ^ INCLUDE_MORALE;
      
      public static const NO_INJURY:uint = INCLUDE_ALL ^ INCLUDE_INJURIES;
      
      public function AttributeOptions()
      {
         super();
         throw new Error("AttributeOptions cannot be directly instantiated.");
      }
   }
}

