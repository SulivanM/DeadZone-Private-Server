package thelaststand.app.game.entities
{
   public class EntityFlags
   {
      
      public static const BEING_SCAVENGED:uint = 1 << 15;
      
      public static const BEING_REMOVED:uint = 1 << 16;
      
      public static const REMOVABLE_JUNK:uint = 1 << 17;
      
      public static const BEING_MOVED:uint = 1 << 18;
      
      public static const EMPTY_CONTAINER:uint = 1 << 19;
      
      public static const SCAVENGED:uint = 1 << 20;
      
      public static const DESTROYED:uint = 1 << 21;
      
      public static const TRAP_DETECTED:uint = 1 << 22;
      
      public static const TRAP_BEING_DISARMED:uint = 1 << 23;
      
      public static const TRAP_DISARMED:uint = 1 << 24;
      
      public static const DISARMING_TRAP:uint = 1 << 25;
      
      public static const TRAP_TRIGGERED:uint = 1 << 26;
      
      public static const MULTI_SCAVENGE:uint = 1 << 27;
      
      public function EntityFlags()
      {
         super();
         throw new Error("EntityFlags cannot be directly instantiated.");
      }
   }
}

