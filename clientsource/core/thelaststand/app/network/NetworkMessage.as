package thelaststand.app.network
{
   public class NetworkMessage
   {
      
      public static const INIT_COMPLETE:String = "ic";
      
      public static const ERROR:String = "err";
      
      public static const BANNED:String = "ban";
      
      public static const SEND_RESPONSE:String = "r";
      
      public static const SERVER_SHUTDOWN_UPDATE:String = "ssu";
      
      public static const SERVER_SHUTDOWN_MAINTENANCE:String = "ssm";
      
      public static const SERVER_ROOM_DISABLED:String = "srd";
      
      public static const SERVER_SETTINGS:String = "ssup";
      
      public static const SERVER_NEW_VERSION:String = "snv";
      
      public static const GAME_READY:String = "gr";
      
      public static const GAME_LOADING_PROGRESS:String = "gp";
      
      public static const SERVER_INIT_PROGRESS:String = "sip";
      
      public static const SIGN_IN_FAILED:String = "sf";
      
      public static const SCENE_READY:String = "sr";
      
      public static const SCENE_REQUEST:String = "srq";
      
      public static const SERVER_UPDATE:String = "su";
      
      public static const TIME_UPDATE:String = "tu";
      
      public static const OUT_OF_SYNC:String = "os";
      
      public static const PURCHASE_COINS:String = "p";
      
      public static const SAVE:String = "s";
      
      public static const SAVE_SUCCCESS:String = "ss";
      
      public static const MISSION_LOOT:String = "ml";
      
      public static const RESOURCE_UPDATE:String = "ru";
      
      public static const SURVIVOR_NEW:String = "sn";
      
      public static const PLAYER_VIEW_REQUEST:String = "pvr";
      
      public static const PLAYER_ATTACK_REQUEST:String = "par";
      
      public static const PLAYER_ATTACK_RESPONSE:String = "parp";
      
      public static const HELP_PLAYER:String = "hp";
      
      public static const NEW_NOTIFICATIONS:String = "nn";
      
      public static const UNDER_ATTACK:String = "ua";
      
      public static const ZOMBIE_ATTACK:String = "za";
      
      public static const GET_PLAYER_SURVIVOR:String = "ps";
      
      public static const GET_NEIGHBOR_STATES:String = "ns";
      
      public static const REQUEST_ZOMBIE_ATTACK:String = "rza";
      
      public static const REQUEST_SURVIVOR_CHECK:String = "rsc";
      
      public static const TASK_COMPLETE:String = "tc";
      
      public static const BUILDING_COMPLETE:String = "bc";
      
      public static const BUILDING_REPAIR_COMPLETE:String = "brpc";
      
      public static const MISSION_RETURN_COMPLETE:String = "mrc";
      
      public static const MISSION_LOCK_COMPLETE:String = "mlc";
      
      public static const SURVIVOR_INJURY_COMPLETE:String = "sic";
      
      public static const BATCH_RECYCLE_COMPLETE:String = "brc";
      
      public static const QUEST_PROGRESS:String = "qp";
      
      public static const QUEST_DAILY_FAILED:String = "qdf";
      
      public static const QUEST_ARMOR_GAMES_COMPLETE:String = "agq";
      
      public static const SURVIVOR_REASSIGNMENT_COMPLETE:String = "src";
      
      public static const EFFECT_COMPLETE:String = "ec";
      
      public static const EFFECT_LOCKOUT_COMPLETE:String = "elc";
      
      public static const COOLDOWN_COMPLETE:String = "cc";
      
      public static const FLAG_CHANGED:String = "fc";
      
      public static const UPGRADE_FLAG_CHANGED:String = "ufc";
      
      public static const MISSION_EVENT:String = "me";
      
      public static const PVP_LIST_UPDATE:String = "pvplist";
      
      public static const SCAV_STARTED:String = "scvstrt";
      
      public static const SCAV_ENDED:String = "scvend";
      
      public static const FUEL_UPDATE:String = "fuel";
      
      public static const TRADE_DISABLED:String = "td";
      
      public static const LINKED_ALLIANCES:String = "alink";
      
      public static const RESEARCH_COMPLETE:String = "rscmp";
      
      public static const GLOBAL_QUEST_CONTRIBUTE:String = "gqcon";
      
      public static const GLOBAL_QUEST_PROGRESS:String = "gqpr";
      
      public static const BOUNTY_COMPLETE:String = "bcmp";
      
      public static const BOUNTY_TASK_COMPLETE:String = "btcmp";
      
      public static const BOUNTY_TASK_CONDITION_COMPLETE:String = "btccmp";
      
      public static const BOUNTY_UPDATE:String = "bup";
      
      public static const RPC:String = "rpc";
      
      public static const RPC_RESPONSE:String = "rpcr";
      
      public function NetworkMessage()
      {
         super();
         throw new Error("NetworkMessage cannot be directly instantiated.");
      }
   }
}

