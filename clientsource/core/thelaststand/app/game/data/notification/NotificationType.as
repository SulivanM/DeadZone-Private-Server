package thelaststand.app.game.data.notification
{
   public class NotificationType
   {
      
      public static const MISSION_RETURN:String = "mission_return";
      
      public static const BUILDING_COMPLETE:String = "building_complete";
      
      public static const SURVIVOR_HEALED:String = "survivor_healed";
      
      public static const SURVIVOR_ARRIVED:String = "survivor_arrived";
      
      public static const SURVIVOR_REASSIGNED:String = "survivor_reassigned";
      
      public static const TASK_COMPLETE:String = "task_complete";
      
      public static const BATCH_RECYCLE_COMPLETE:String = "batch_recycle_complete";
      
      public static const HELPED:String = "help";
      
      public static const ATTACKED:String = "attacked";
      
      public static const QUEST_COMPLETE:String = "quest_complete";
      
      public static const QUEST_STARTED:String = "quest_started";
      
      public static const SCHEMATIC_UNLOCKED:String = "schematic_unlocked";
      
      public static const CRAFTING_AVAILABLE:String = "crafting_available";
      
      public static const BOUNTY_ACTIVATED:String = "bounty_activated";
      
      public static const BOUNTY_ADDED:String = "bounty_added";
      
      public static const BOUNTY_COMPLETE:String = "bounty_complete";
      
      public static const RESEARCH_COMPLETED:String = "research_complete";
      
      public static const ALLIANCE_ACTIVATED:String = "alliance_available";
      
      public static const ALLIANCE_MEMBERSHIP_REVOKED:String = "alliance_membership_revoked";
      
      public static const ALLIANCE_RANK_CHANGE:String = "alliance_rank_change";
      
      public static const ALLIANCE_DISBANDED:String = "alliance_disbanded";
      
      public static const ALLIANCE_WINNINGS:String = "alliance-winnings";
      
      public static const ALLIANCE_INDI_REWARD:String = "alliance_individualReward";
      
      public function NotificationType()
      {
         super();
         throw new Error("NotificationType cannot be directly instantiated.");
      }
   }
}

