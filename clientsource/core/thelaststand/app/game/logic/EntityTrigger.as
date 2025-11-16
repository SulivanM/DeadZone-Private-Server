package thelaststand.app.game.logic
{
   public class EntityTrigger
   {
      
      public static const None:uint = 0;
      
      public static const Death:uint = 1;
      
      public static const ScavengeStarted:uint = 2;
      
      public static const ScavengeCompleted:uint = 3;
      
      public static const TrapDisarmed:uint = 4;
      
      public static const TrapTriggered:uint = 5;
      
      public function EntityTrigger()
      {
         super();
         throw new Error("EntityTrigger cannot be directly instantiated.");
      }
      
      public static function getNames() : Vector.<String>
      {
         return new <String>["None","Death","ScavengeStarted","ScavengeCompleted","TrapDisarmed","TrapTriggered"];
      }
   }
}

