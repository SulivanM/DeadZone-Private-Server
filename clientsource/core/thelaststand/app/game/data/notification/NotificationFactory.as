package thelaststand.app.game.data.notification
{
   public class NotificationFactory
   {
      
      public function NotificationFactory()
      {
         super();
         throw new Error("NotificationFactory cannot be directly instantiated.");
      }
      
      public static function createNotification(param1:String, param2:* = null, param3:String = "default") : INotification
      {
         var _loc4_:INotification = null;
         switch(param1)
         {
            case NotificationType.MISSION_RETURN:
               _loc4_ = new MissionReturnNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.BUILDING_COMPLETE:
               _loc4_ = new BuildingCompleteNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.SURVIVOR_ARRIVED:
               _loc4_ = new SurvivorArrivalNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.SURVIVOR_HEALED:
               _loc4_ = new SurvivorHealedNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.SURVIVOR_REASSIGNED:
               _loc4_ = new SurvivorRetrainedNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.TASK_COMPLETE:
               _loc4_ = new TaskCompleteNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.BATCH_RECYCLE_COMPLETE:
               _loc4_ = new RecycleCompleteNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.HELPED:
               _loc4_ = new HelpedNotification(param2);
               break;
            case NotificationType.ATTACKED:
               _loc4_ = new AttackedNotification(param2);
               break;
            case NotificationType.QUEST_COMPLETE:
               _loc4_ = new QuestCompleteNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.QUEST_STARTED:
               _loc4_ = new QuestStartedNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.SCHEMATIC_UNLOCKED:
               _loc4_ = new SchematicUnlockedNotification(param2 is String ? param2 : String(param2.id));
               break;
            case NotificationType.CRAFTING_AVAILABLE:
               _loc4_ = new CraftingAvailableNotification();
               break;
            case NotificationType.BOUNTY_COMPLETE:
               _loc4_ = new BountyCompleteNotification(param2);
               break;
            case NotificationType.BOUNTY_ACTIVATED:
               _loc4_ = new BountyActivatedNotification(param2);
               break;
            case NotificationType.BOUNTY_ADDED:
               _loc4_ = new BountyAddedNotification();
               break;
            case NotificationType.RESEARCH_COMPLETED:
               _loc4_ = new ResearchCompletedNotification(param2);
               break;
            case NotificationType.ALLIANCE_ACTIVATED:
               _loc4_ = new AllianceActivatedNotification(param2);
               break;
            case NotificationType.ALLIANCE_MEMBERSHIP_REVOKED:
               _loc4_ = new AllianceMembershipRevokedNotification(param2);
               break;
            case NotificationType.ALLIANCE_RANK_CHANGE:
               _loc4_ = new AllianceRankChangeNotification(param2);
               break;
            case NotificationType.ALLIANCE_DISBANDED:
               _loc4_ = new AllianceDisbandedNotification(param2);
               break;
            case NotificationType.ALLIANCE_WINNINGS:
               _loc4_ = new AllianceRoundWinnerNotification(param2);
               break;
            case NotificationType.ALLIANCE_INDI_REWARD:
               _loc4_ = new AllianceIndiRewardNotification(param2);
         }
         if(_loc4_ != null && param3 != "default")
         {
            _loc4_.active = param3 == "active" ? true : false;
         }
         return _loc4_;
      }
   }
}

