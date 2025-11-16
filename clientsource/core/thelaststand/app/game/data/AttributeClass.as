package thelaststand.app.game.data
{
   public class AttributeClass
   {
      
      public static const FIGHTING:Array = ["combatProjectile","combatMelee"];
      
      public static const SCAVENGING:Array = ["scavenge"];
      
      public static const ENGINEERING:Array = ["combatImprovised","trapDisarming"];
      
      public static const MEDIC:Array = ["healing"];
      
      public static const RECON:Array = ["movement","trapSpotting"];
      
      public function AttributeClass()
      {
         super();
         throw new Error("AttributeClass cannot be directly instantiated.");
      }
      
      public static function getAttributeClasses() : Array
      {
         return ["FIGHTING","SCAVENGING","ENGINEERING","MEDIC","RECON"];
      }
   }
}

