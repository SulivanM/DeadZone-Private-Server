package thelaststand.app.game.logic.ai.states
{
   import thelaststand.app.game.data.Building;
   
   public class BuildingStateFactory
   {
      
      public function BuildingStateFactory()
      {
         super();
         throw new Error("BuildingStateFactory cannot be directly instantiated.");
      }
      
      public static function getState(param1:Building) : IAIState
      {
         if(param1.isDecoyTrap)
         {
            return new TrapDecoyState(param1);
         }
         switch(param1.xml.@state.toString())
         {
            case "slowTrap":
               return new TrapSlowMovementState(param1);
            case "claymore":
               return new TrapClaymoreState(param1);
            case "dingDong":
               return new TrapDingDongState(param1);
            case "gunBarrel":
               return new TrapGunBarrelState(param1);
            default:
               return null;
         }
      }
   }
}

