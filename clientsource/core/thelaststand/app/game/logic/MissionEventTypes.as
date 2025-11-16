package thelaststand.app.game.logic
{
   public class MissionEventTypes
   {
      
      public static const LOG_START:String = "logStart";
      
      public static const LOG_END:String = "logEnd";
      
      public static const PROTECTION_ADDED:String = "prot";
      
      public static const TIMER_EXPIRED:String = "timerExpired";
      
      public static const ATTACKERS_LEFT:String = "attackersLeft";
      
      public static const FAILED_MISSION:String = "missionFailed";
      
      public static const BUILDING_SCAVENGED:String = "bldScav";
      
      public static const BUILDING_DESTROYED:String = "bldDestroyed";
      
      public static const TRAP_DISARMED:String = "trapDisarm";
      
      public static const TRAP_TRIGGERED:String = "trapTrig";
      
      public static const ATTACKER_DIE_WEAPON:String = "attDieWeap";
      
      public static const ATTACKER_DIE_EXPLOSIVE:String = "attDieExpl";
      
      public static const ATTACKER_DIE_TRAP:String = "attDieTrap";
      
      public static const DEFENDER_DIE_WEAPON:String = "defDieWeap";
      
      public static const DEFENDER_DIE_EXPLOSIVE:String = "defDieExpl";
      
      public static const ALLIANCE_FLAG_STOLEN:String = "flagStolen";
      
      public static const EXPLOSIVE_PLACED:String = "explPlaced";
      
      public static const GRENADE_THROWN:String = "grenThrown";
      
      public static const TIME_CHECK:String = "timeCheck";
      
      public function MissionEventTypes()
      {
         super();
      }
   }
}

