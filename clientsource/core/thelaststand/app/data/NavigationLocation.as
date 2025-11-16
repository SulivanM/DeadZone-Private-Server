package thelaststand.app.data
{
   public class NavigationLocation
   {
      
      public static const PLAYER_COMPOUND:String = "playerCompound";
      
      public static const NEIGHBOR_COMPOUND:String = "neighborCompound";
      
      public static const MISSION:String = "mission";
      
      public static const MISSION_PLANNING:String = "missionPlanning";
      
      public static const WORLD_MAP:String = "worldmap";
      
      public function NavigationLocation()
      {
         super();
         throw new Error("NavigationLocation cannot be directly instantiated.");
      }
   }
}

