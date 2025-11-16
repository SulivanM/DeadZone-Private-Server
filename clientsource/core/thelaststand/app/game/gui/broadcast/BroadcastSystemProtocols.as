package thelaststand.app.game.gui.broadcast
{
   public class BroadcastSystemProtocols
   {
      
      public static const STATIC:String = "static";
      
      public static const ADMIN:String = "admin";
      
      public static const WARNING:String = "warn";
      
      public static const SHUT_DOWN:String = "shtdn";
      
      public static const ITEM_UNBOXED:String = "itmbx";
      
      public static const ITEM_FOUND:String = "itmfd";
      
      public static const RAID_ATTACK:String = "raid";
      
      public static const RAID_DEFEND:String = "def";
      
      public static const ITEM_CRAFTED:String = "crft";
      
      public static const ACHIEVEMENT:String = "ach";
      
      public static const USER_LEVEL:String = "lvl";
      
      public static const SURVIVOR_COUNT:String = "srvcnt";
      
      public static const ZOMBIE_ATTACK_FAIL:String = "zfail";
      
      public static const ALL_INJURED:String = "injall";
      
      public static const PLAIN_TEXT:String = "plain";
      
      public static const BOUNTY_ADD:String = "badd";
      
      public static const BOUNTY_COLLECTED:String = "bcol";
      
      public static const ALLIANCE_RAID_SUCCESS:String = "ars";
      
      public static const ALLIANCE_RANK:String = "arank";
      
      public static const ARENA_LEADERBOARD:String = "arenalb";
      
      public static const RAIDMISSION_STARTED:String = "rmstart";
      
      public static const RAIDMISSION_COMPELTE:String = "rmcompl";
      
      public static const RAIDMISSION_FAILED:String = "rmfail";
      
      public static const HAZ_SUCCESS:String = "hazwin";
      
      public static const HAZ_FAIL:String = "hazlose";
      
      public function BroadcastSystemProtocols()
      {
         super();
         throw new Error("BroadcastSystemProtocols cannot be directly instantiated.");
      }
   }
}

