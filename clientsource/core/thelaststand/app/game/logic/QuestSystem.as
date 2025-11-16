package thelaststand.app.game.logic
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.Message;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.notification.INotification;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.resources.ResourceManager;
   
   public class QuestSystem
   {
      
      private static var _instance:QuestSystem;
      
      private var _quests:Vector.<Quest>;
      
      private var _achievements:Vector.<Quest>;
      
      private var _network:Network;
      
      private var _maxNumTrackedQuests:int;
      
      private var _questsById:Dictionary;
      
      private var _questsByType:Dictionary;
      
      private var _rootQuestsByLevel:Dictionary;
      
      private var _initialized:Boolean = false;
      
      private var _xml:XML;
      
      public var milestoneReached:Signal;
      
      public var questFailed:Signal;
      
      public var questCompleted:Signal;
      
      public var questStarted:Signal;
      
      public var questCollected:Signal;
      
      public var achievementReceived:Signal;
      
      public var questTracked:Signal;
      
      public var questUntracked:Signal;
      
      public var initializationCompleted:Signal;
      
      public function QuestSystem(param1:QuestSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("QuestSystem is a Singleton and cannot be directly instantiated. Use QuestSystem.getInstance().");
         }
         this._achievements = new Vector.<Quest>();
         this._quests = new Vector.<Quest>();
         this._questsById = new Dictionary();
         this._questsByType = new Dictionary();
         this.milestoneReached = new Signal(Quest,int);
         this.questStarted = new Signal(Quest);
         this.questCompleted = new Signal(Quest);
         this.questFailed = new Signal(Quest);
         this.questCollected = new Signal(Quest);
         this.achievementReceived = new Signal(Quest);
         this.questTracked = new Signal(Quest);
         this.questUntracked = new Signal(Quest);
         this.initializationCompleted = new Signal();
      }
      
      public static function getInstance() : QuestSystem
      {
         if(!_instance)
         {
            _instance = new QuestSystem(new QuestSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public function init() : void
      {
         var player:PlayerData;
         var questList:XMLList;
         var i:int;
         var playerLevel:int = 0;
         var topLevelList:Vector.<Quest> = null;
         var quest:Quest = null;
         var topLevelQuest:Quest = null;
         if(this._initialized)
         {
            return;
         }
         this._network = Network.getInstance();
         this._network.connection.addMessageHandler(NetworkMessage.QUEST_PROGRESS,this.onQuestProgressReceived);
         this._network.connection.addMessageHandler(NetworkMessage.QUEST_DAILY_FAILED,this.onDailyQuestFailed);
         this._maxNumTrackedQuests = int(Config.constant.MAX_QUEST_TRACKED);
         this._xml = ResourceManager.getInstance().getResource("xml/quests.xml").content;
         player = this._network.playerData;
         questList = this._xml.quests.quest + this._xml.achievements.ach;
         i = 0;
         while(i < questList.length())
         {
            quest = new Quest(questList[i]);
            this.addQuest(quest);
            i++;
         }
         if(player.dailyQuest != null)
         {
            if(player.dailyQuest.accepted)
            {
               this.addQuest(player.dailyQuest);
            }
         }
         this.buildQuestTree();
         playerLevel = int(player.getPlayerSurvivor().level);
         for each(topLevelList in this._rootQuestsByLevel)
         {
            for each(topLevelQuest in topLevelList)
            {
               this.traverseQuestTree(topLevelQuest,function(param1:Quest):Boolean
               {
                  if(param1.complete)
                  {
                     return true;
                  }
                  if(param1.level <= playerLevel && param1.prereqQuestsCompleted())
                  {
                     param1.started = true;
                  }
                  return false;
               });
            }
         }
         player.getPlayerSurvivor().levelIncreased.add(this.onPlayerLevelUp);
         this._network.send(NetworkMessage.QUEST_PROGRESS);
      }
      
      public function clearNewFlags() : void
      {
         var _loc1_:Quest = null;
         for each(_loc1_ in this._quests)
         {
            _loc1_.isNew = false;
         }
      }
      
      public function collect(param1:String, param2:Function = null) : void
      {
         var _loc3_:Quest = this._questsById[param1];
         if(_loc3_ == null || _loc3_.isAchievement)
         {
            return;
         }
         _loc3_.collect(param2);
      }
      
      public function addQuest(param1:Quest) : void
      {
         var _loc4_:int = 0;
         var _loc2_:PlayerData = this._network.playerData;
         if(param1 is DynamicQuest)
         {
            DynamicQuest(param1).accepted = true;
            this._quests.push(param1);
         }
         else
         {
            _loc4_ = int(param1.xml.childIndex());
            if(param1.isAchievement)
            {
               if(_loc4_ >= _loc2_.achievementsStatus.length)
               {
                  return;
               }
               param1.complete = _loc2_.achievementsStatus[_loc4_];
               this._achievements.push(param1);
            }
            else
            {
               if(_loc4_ >= _loc2_.questsCompletedStatus.length)
               {
                  return;
               }
               param1.complete = _loc2_.questsCompletedStatus[_loc4_];
               param1.collected = _loc2_.questsCollectedStatus[_loc4_];
               this._quests.push(param1);
               if(param1.complete)
               {
                  param1.started = true;
               }
            }
         }
         this._questsById[param1.id] = param1;
         var _loc3_:Vector.<Quest> = this._questsByType[param1.type];
         if(_loc3_ == null)
         {
            _loc3_ = this._questsByType[param1.type] = new Vector.<Quest>();
         }
         _loc3_.push(param1);
      }
      
      public function applyPenalties(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:PlayerData = Network.getInstance().playerData;
         if(param1.res != null)
         {
            for(_loc4_ in param1.res)
            {
               _loc3_ = int(param1.res[_loc4_]);
               _loc2_.compound.resources.addAmount(_loc4_,-_loc3_);
            }
         }
         if(param1.items != null)
         {
            _loc2_.inventory.updateQuantities(param1.items);
         }
      }
      
      public function giveRewards(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Item = null;
         var _loc2_:PlayerData = Network.getInstance().playerData;
         if(param1.xp is Number)
         {
            _loc2_.compound.addXP(int(param1.xp));
         }
         if(param1.res != null)
         {
            for(_loc3_ in param1.res)
            {
               _loc4_ = int(param1.res[_loc3_]);
               _loc2_.compound.resources.addAmount(_loc3_,_loc4_);
            }
         }
         if(param1.items is Array)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.items.length)
            {
               _loc6_ = param1.items[_loc5_];
               if(_loc6_ != null)
               {
                  _loc7_ = ItemFactory.createItemFromObject(_loc6_);
                  if(_loc7_ != null)
                  {
                     _loc2_.giveItem(_loc7_);
                  }
               }
               _loc5_++;
            }
         }
      }
      
      public function getTasks(param1:String = "all", param2:int = -1, param3:Boolean = false) : Vector.<Quest>
      {
         var _loc4_:Vector.<Quest> = null;
         var _loc7_:Quest = null;
         if(param1 == "all")
         {
            _loc4_ = this._quests;
         }
         else
         {
            _loc4_ = this._questsByType[param1];
         }
         if(_loc4_ == null)
         {
            return new Vector.<Quest>();
         }
         var _loc5_:Vector.<Quest> = new Vector.<Quest>();
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc7_.visible)
            {
               if(param2 < 0 || _loc7_.level <= param2)
               {
                  if(param3)
                  {
                     if(_loc7_.prereqQuestsCompleted())
                     {
                        _loc5_.push(_loc7_);
                     }
                  }
                  else
                  {
                     _loc5_.push(_loc7_);
                  }
               }
            }
            _loc6_++;
         }
         return _loc5_;
      }
      
      public function getQuestByIndex(param1:int) : Quest
      {
         if(param1 < 0 || param1 >= this._quests.length)
         {
            return null;
         }
         return this._quests[param1];
      }
      
      public function getAchievementByIndex(param1:int) : Quest
      {
         if(param1 < 0 || param1 >= this._achievements.length)
         {
            return null;
         }
         return this._achievements[param1];
      }
      
      public function getAchievements(param1:Boolean = false) : Vector.<Quest>
      {
         var _loc4_:Quest = null;
         var _loc2_:Vector.<Quest> = this._achievements;
         if(!param1)
         {
            return _loc2_.concat();
         }
         var _loc3_:Vector.<Quest> = new Vector.<Quest>();
         for each(_loc4_ in _loc2_)
         {
            if(_loc4_.visible)
            {
               if(param1)
               {
                  if(_loc4_.prereqQuestsCompleted())
                  {
                     _loc3_.push(_loc4_);
                  }
               }
               else
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         return _loc3_;
      }
      
      public function getQuestOrAchievementById(param1:String) : Quest
      {
         return this._questsById[param1];
      }
      
      public function toggleTracking(param1:Quest) : String
      {
         var _loc4_:int = 0;
         if(param1 == null || param1.isAchievement || param1 is DynamicQuest)
         {
            return null;
         }
         var _loc2_:PlayerData = Network.getInstance().playerData;
         var _loc3_:* = _loc2_.questsTracked.indexOf(param1.index) > -1;
         if(_loc3_)
         {
            this._network.save({"id":param1.id},SaveDataMethod.QUEST_UNTRACK);
            _loc4_ = int(_loc2_.questsTracked.indexOf(param1.index));
            if(_loc4_ > -1)
            {
               _loc2_.questsTracked.splice(_loc4_,1);
            }
            param1.untracked.dispatch(param1);
            this.questUntracked.dispatch(param1);
            return Quest.TRACKING_UNTRACKED;
         }
         if(_loc2_.questsTracked.length >= this._maxNumTrackedQuests)
         {
            return Quest.TRACKING_MAX_TRACKED;
         }
         this._network.save({"id":param1.id},SaveDataMethod.QUEST_TRACK);
         _loc2_.questsTracked.push(param1.index);
         param1.tracked.dispatch(param1);
         this.questTracked.dispatch(param1);
         return Quest.TRACKING_TRACKED;
      }
      
      public function isTracked(param1:Quest) : Boolean
      {
         if(param1.isAchievement)
         {
            return false;
         }
         var _loc2_:PlayerData = Network.getInstance().playerData;
         return _loc2_.questsTracked.indexOf(param1.index) > -1;
      }
      
      public function maxNumQuestsBeingTracked() : Boolean
      {
         var _loc1_:PlayerData = Network.getInstance().playerData;
         return _loc1_.questsTracked.length >= this._maxNumTrackedQuests;
      }
      
      private function traverseQuestTree(param1:Quest, param2:Function) : void
      {
         var _loc3_:Quest = null;
         if(param2(param1))
         {
            for each(_loc3_ in param1.children)
            {
               this.traverseQuestTree(_loc3_,param2);
            }
         }
      }
      
      private function onPlayerLevelUp(param1:Survivor, param2:int) : void
      {
         var topLevelQuest:Quest = null;
         var srv:Survivor = param1;
         var level:int = param2;
         var i:int = level;
         while(i >= 0)
         {
            for each(topLevelQuest in this._rootQuestsByLevel[i])
            {
               this.traverseQuestTree(topLevelQuest,function(param1:Quest):Boolean
               {
                  if(param1.level > level)
                  {
                     return false;
                  }
                  if(param1.complete)
                  {
                     return true;
                  }
                  if(!param1.visible)
                  {
                     return true;
                  }
                  if(!param1.started && !param1.isAchievement)
                  {
                     if(param1.prereqQuestsCompleted())
                     {
                        param1.started = true;
                        param1.isNew = true;
                        NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.QUEST_STARTED,param1));
                        questStarted.dispatch(param1);
                     }
                  }
                  return true;
               });
            }
            i--;
         }
      }
      
      private function onQuestProgressReceived(param1:Message) : void
      {
         var playerData:PlayerData;
         var i:String = null;
         var j:String = null;
         var quest:Quest = null;
         var data:Object = null;
         var completeNotifications:Vector.<INotification> = null;
         var note:INotification = null;
         var alreadyCompleted:Boolean = false;
         var trackIndex:int = 0;
         var statusList:Vector.<Boolean> = null;
         var childQuest:Quest = null;
         var milestones:Array = null;
         var m:Object = null;
         var index:int = 0;
         var msg:Message = param1;
         if(msg.length == 0)
         {
            if(!this._initialized)
            {
               this._initialized = true;
               this.initializationCompleted.dispatch();
            }
            return;
         }
         try
         {
            data = JSON.parse(msg.getString(0));
         }
         catch(err:Error)
         {
            if(!_initialized)
            {
               _initialized = true;
               initializationCompleted.dispatch();
            }
            return;
         }
         playerData = Network.getInstance().playerData;
         if(data.complete != null)
         {
            completeNotifications = new Vector.<INotification>();
            for(i in data.complete)
            {
               quest = this._questsById[i];
               if(quest != null)
               {
                  alreadyCompleted = quest.complete;
                  if(!alreadyCompleted)
                  {
                     quest.complete = true;
                     if(!(quest is DynamicQuest))
                     {
                        statusList = quest.isAchievement ? playerData.achievementsStatus : playerData.questsCompletedStatus;
                        statusList[quest.xml.childIndex()] = true;
                     }
                     if(data.complete[i] != null)
                     {
                        this.giveRewards(data.complete[i]);
                     }
                  }
                  if(!quest.isAchievement)
                  {
                     for each(childQuest in quest.children)
                     {
                        if(!(childQuest.started || childQuest.level > playerData.getPlayerSurvivor().level))
                        {
                           if(childQuest.prereqQuestsCompleted())
                           {
                              if(childQuest.visible)
                              {
                                 childQuest.started = true;
                                 childQuest.isNew = true;
                                 NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.QUEST_STARTED,childQuest));
                                 this.questStarted.dispatch(childQuest);
                              }
                           }
                        }
                     }
                  }
                  trackIndex = int(this._network.playerData.questsTracked.indexOf(quest.index));
                  if(trackIndex > -1)
                  {
                     this._network.playerData.questsTracked.splice(trackIndex,1);
                     this.questUntracked.dispatch(quest);
                  }
                  if(!alreadyCompleted)
                  {
                     if(quest.isAchievement)
                     {
                        this.achievementReceived.dispatch(quest);
                     }
                     else if(quest.visible)
                     {
                        completeNotifications.push(NotificationFactory.createNotification(NotificationType.QUEST_COMPLETE,quest));
                        this.questCompleted.dispatch(quest);
                     }
                  }
               }
            }
            for each(note in completeNotifications)
            {
               NotificationSystem.getInstance().addNotification(note);
            }
         }
         if(data.progress != null)
         {
            milestones = [];
            for(i in data.progress)
            {
               quest = this._questsById[i];
               if(quest != null)
               {
                  for(j in data.progress[i])
                  {
                     if(j.indexOf("milestone",0) > -1)
                     {
                        index = int(j.split("_")[1]);
                        milestones.push({
                           "quest":quest,
                           "conditionIndex":index
                        });
                     }
                     else
                     {
                        index = int(j);
                        quest.setProgress(index,int(data.progress[i][j]));
                     }
                  }
               }
            }
            for each(m in milestones)
            {
               this.milestoneReached.dispatch(m.quest,m.conditionIndex);
            }
         }
         if(!this._initialized)
         {
            this._initialized = true;
            this.initializationCompleted.dispatch();
         }
      }
      
      private function onDailyQuestFailed(param1:Message) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = param1.getString(_loc2_++);
         var _loc4_:Quest = this._questsById[_loc3_];
         if(_loc4_ != null)
         {
            _loc4_.failed = true;
            this.questFailed.dispatch(_loc4_);
         }
      }
      
      private function buildQuestTree() : void
      {
         var _loc3_:Quest = null;
         var _loc4_:XMLList = null;
         var _loc5_:Vector.<Quest> = null;
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc8_:Quest = null;
         this._rootQuestsByLevel = new Dictionary(true);
         var _loc1_:int = 0;
         var _loc2_:int = int(this._quests.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this._quests[_loc1_];
            if(!(_loc3_ is DynamicQuest))
            {
               _loc4_ = _loc3_.xml.prereq;
               if(_loc4_.length() == 0)
               {
                  _loc5_ = this._rootQuestsByLevel[_loc3_.level];
                  if(_loc5_ == null)
                  {
                     _loc5_ = new Vector.<Quest>();
                     this._rootQuestsByLevel[_loc3_.level] = _loc5_;
                  }
                  _loc5_.push(_loc3_);
               }
               else
               {
                  for each(_loc6_ in _loc4_)
                  {
                     for each(_loc7_ in _loc6_.quest)
                     {
                        _loc8_ = this._questsById[_loc7_.toString()];
                        if(_loc8_ != null)
                        {
                           if(_loc8_ == _loc3_)
                           {
                              throw new Error("A quest cannot have itself as a prerequisite");
                           }
                           _loc8_.children.push(_loc3_);
                        }
                     }
                  }
               }
            }
            _loc1_++;
         }
      }
      
      public function get numAchievements() : int
      {
         return this._achievements.length;
      }
      
      public function get numAchievementsCompleted() : int
      {
         var _loc2_:Boolean = false;
         var _loc1_:int = 0;
         for each(_loc2_ in Network.getInstance().playerData.achievementsStatus)
         {
            if(_loc2_)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get numUncollectedQuests() : int
      {
         var _loc5_:Quest = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._quests.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = this._quests[_loc3_];
            if(_loc5_.visible && _loc5_.prereqQuestsCompleted() && _loc5_.complete)
            {
               _loc1_++;
               if(_loc5_.collected)
               {
                  _loc2_++;
               }
            }
            _loc3_++;
         }
         return Math.max(_loc1_ - _loc2_,0);
      }
      
      public function get numActiveDynamicQuests() : int
      {
         var _loc2_:DynamicQuest = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.getTasks(Quest.TYPE_DYNAMIC))
         {
            if(!(_loc2_ == null || _loc2_.failed))
            {
               if(_loc2_.complete && !_loc2_.collected)
               {
                  _loc1_++;
               }
            }
         }
         return _loc1_;
      }
      
      public function get numTrackedQuests() : int
      {
         return Network.getInstance().playerData.questsTracked.length;
      }
      
      public function get maxNumTrackedQuests() : int
      {
         return this._maxNumTrackedQuests;
      }
   }
}

class QuestSystemSingletonEnforcer
{
   
   public function QuestSystemSingletonEnforcer()
   {
      super();
   }
}
