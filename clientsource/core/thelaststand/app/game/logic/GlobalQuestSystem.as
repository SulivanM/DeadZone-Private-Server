package thelaststand.app.game.logic
{
   import com.junkbyte.console.Cc;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.Message;
   import thelaststand.app.core.Settings;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.notification.INotification;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.common.resources.ResourceManager;
   
   public class GlobalQuestSystem
   {
      
      private static var _instance:GlobalQuestSystem;
      
      private static const ACTIVE:int = 1;
      
      private static const GRACE:int = 2;
      
      public var progressChange:Signal = new Signal();
      
      private var _initialized:Boolean;
      
      private var _network:Network;
      
      private var _xml:XML;
      
      private var _quests:Vector.<Quest> = new Vector.<Quest>();
      
      private var _questsStatusById:Dictionary = new Dictionary();
      
      private var _questsById:Dictionary = new Dictionary();
      
      public var questCollected:Signal;
      
      public var questCompleted:Signal;
      
      public var questMovedToGrace:Signal;
      
      public function GlobalQuestSystem(param1:GlobalQuestSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("GlobalQuestSystem is a Singleton and cannot be directly instantiated. Use GlobalQuestSystem.getInstance().");
         }
         Cc.logch("Global Quest Stytem created");
         this.questCollected = new Signal(Quest);
         this.questCompleted = new Signal(Quest);
         this.questMovedToGrace = new Signal(Quest);
      }
      
      public static function getInstance() : GlobalQuestSystem
      {
         if(!_instance)
         {
            _instance = new GlobalQuestSystem(new GlobalQuestSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public function init(param1:Object) : void
      {
         var _loc7_:XML = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Quest = null;
         var _loc11_:Array = null;
         if(Settings.getInstance().globalQuestsEnabled == false)
         {
            return;
         }
         if(this._initialized)
         {
            return;
         }
         this._network = Network.getInstance();
         this._network.connection.addMessageHandler(NetworkMessage.GLOBAL_QUEST_CONTRIBUTE,this.onGlobalQuestContribute);
         this._network.connection.addMessageHandler(NetworkMessage.GLOBAL_QUEST_PROGRESS,this.onGlobalQuestProgress);
         this._xml = ResourceManager.getInstance().getResource("xml/quests_global.xml").content;
         var _loc2_:Number = this._network.serverTime;
         var _loc3_:Number = int(this._xml.quests.@gracePeriod) * 24 * 60 * 60 * 1000;
         var _loc4_:PlayerData = this._network.playerData;
         var _loc5_:XMLList = this._xml.quests.quest;
         var _loc6_:int = 0;
         for(; _loc6_ < _loc5_.length(); _loc6_++)
         {
            _loc7_ = _loc5_[_loc6_];
            if(Boolean(_loc7_.hasOwnProperty("@service")) && _loc7_.@service != "")
            {
               _loc11_ = _loc7_.@service.toString().toLowerCase().split(",");
               if(_loc11_.indexOf(Network.getInstance().service.toLowerCase()) == -1)
               {
                  continue;
               }
            }
            if(_loc7_.hasOwnProperty("@start"))
            {
               _loc8_ = this.convertStringDateToTime(_loc7_.@start);
               if(_loc7_.hasOwnProperty("@end"))
               {
                  _loc9_ = this.convertStringDateToTime(_loc7_.@end);
                  if(!(_loc2_ < _loc8_ || _loc2_ > _loc9_ + _loc3_))
                  {
                     _loc10_ = new Quest(_loc7_);
                     _loc10_.isGlobalQuest = true;
                     this._quests.push(_loc10_);
                     this._questsStatusById[_loc10_.id] = ACTIVE;
                     this._questsById[_loc10_.id] = _loc10_;
                  }
               }
            }
         }
         this.parseActiveQuestProgress(param1);
      }
      
      public function collect(param1:String, param2:Function = null) : void
      {
         var _loc3_:Quest = this._questsById[param1];
         if(_loc3_ == null || _loc3_.isAchievement)
         {
            return;
         }
         if(this._questsStatusById[param1] != GRACE || this._questsStatusById[param1] == false)
         {
            return;
         }
         _loc3_.collectGlobal(param2);
      }
      
      public function getTasks() : Vector.<Quest>
      {
         return this._quests;
      }
      
      public function getQuestActive(param1:String) : Boolean
      {
         return Boolean(this._questsStatusById[param1] == ACTIVE);
      }
      
      public function getQuestById(param1:String) : Quest
      {
         return this._questsById[param1];
      }
      
      private function convertStringDateToTime(param1:String) : Number
      {
         var _loc2_:Array = param1.split("-");
         var _loc3_:Date = new Date(int(_loc2_[0]),int(_loc2_[1]) - 1,int(_loc2_[2]),0);
         return _loc3_.time;
      }
      
      private function onGlobalQuestContribute(param1:Message) : void
      {
         var _loc2_:String = param1.getString(0);
         var _loc3_:int = param1.getInt(1);
         Network.getInstance().playerData.globalQuests.readObject(param1.getByteArray(2));
         this._network.playerData.globalQuests.setContributed(_loc2_,_loc3_);
         this.progressChange.dispatch();
      }
      
      private function onGlobalQuestProgress(param1:Message) : void
      {
         Cc.logch("stats","onGlobalQuestProgress heard from server");
         var _loc2_:String = param1.getString(0);
         if(!_loc2_ || _loc2_ == "")
         {
            return;
         }
         if(param1.length > 1)
         {
            Network.getInstance().playerData.globalQuests.readObject(param1.getByteArray(1));
         }
         var _loc3_:Object = JSON.parse(_loc2_);
         this.parseActiveQuestProgress(_loc3_);
         this.progressChange.dispatch();
      }
      
      private function parseActiveQuestProgress(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:INotification = null;
         var _loc5_:Quest = null;
         var _loc6_:Object = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc2_:Vector.<INotification> = new Vector.<INotification>();
         if(!param1 || !param1["idList"])
         {
            return;
         }
         for each(_loc3_ in param1["idList"])
         {
            _loc5_ = this._questsById[_loc3_];
            if(_loc5_ != null)
            {
               _loc6_ = param1[_loc3_ + "_progress"];
               if(_loc6_)
               {
                  for(_loc8_ in _loc6_)
                  {
                     _loc5_.setProgress(int(_loc8_),int(_loc6_[_loc8_]));
                  }
               }
               _loc7_ = Boolean(param1[_loc3_ + "_expired"]);
               if(_loc7_)
               {
                  if(this._questsStatusById[_loc3_] == ACTIVE)
                  {
                     this._questsStatusById[_loc3_] = GRACE;
                     this.questMovedToGrace.dispatch(_loc5_);
                  }
                  if(this._network.playerData.globalQuests.getCollected(_loc5_.id))
                  {
                     _loc5_.collected = true;
                  }
                  _loc9_ = this._network.playerData.globalQuests.getContributed(_loc5_.id);
                  _loc10_ = Boolean(param1[_loc3_ + "_success"]) && _loc9_;
                  if(_loc10_ == true)
                  {
                     if(_loc5_.complete == false)
                     {
                        _loc5_.complete = true;
                        if(this._network.playerData.globalQuests.getContributed(_loc5_.id) == true && _loc5_.collected == false)
                        {
                           _loc2_.push(NotificationFactory.createNotification(NotificationType.QUEST_COMPLETE,"$global" + _loc5_.id));
                           this.questCompleted.dispatch(_loc5_);
                        }
                     }
                  }
                  else if(_loc5_.failed == false)
                  {
                     _loc5_.failed = true;
                     QuestSystem.getInstance().questFailed.dispatch(_loc5_);
                  }
               }
            }
         }
         for each(_loc4_ in _loc2_)
         {
            NotificationSystem.getInstance().addNotification(_loc4_);
         }
      }
      
      public function get numActiveQuests() : int
      {
         var _loc2_:Quest = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._quests)
         {
            if(this.getQuestActive(_loc2_.id) && this._network.serverTime < _loc2_.endTime.time)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get numUncollectedQuests() : int
      {
         var _loc2_:Quest = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._quests)
         {
            if(_loc2_.complete && this._network.playerData.globalQuests.getCollected(_loc2_.id) == false)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
   }
}

class GlobalQuestSystemSingletonEnforcer
{
   
   public function GlobalQuestSystemSingletonEnforcer()
   {
      super();
   }
}
