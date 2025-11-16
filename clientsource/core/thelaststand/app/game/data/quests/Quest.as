package thelaststand.app.game.data.quests
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.BitmapData;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.logic.GlobalQuestSystem;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class Quest
   {
      
      public static const SECRET_NONE:uint = 0;
      
      public static const SECRET_TITLE_ONLY:uint = 1;
      
      public static const SECRET_HIDDEN:uint = 2;
      
      public static const TYPE_ACHIEVEMENT:String = "achievement";
      
      public static const TYPE_GENERAL:String = "general";
      
      public static const TYPE_COMBAT:String = "combat";
      
      public static const TYPE_SCAVENGE:String = "scavenge";
      
      public static const TYPE_CONSTRUCTION:String = "construct";
      
      public static const TYPE_COMMUNITY:String = "community";
      
      public static const TYPE_WORLD:String = "world";
      
      public static const TYPE_DYNAMIC:String = "dynamic";
      
      public static const TRACKING_TRACKED:String = "tracked";
      
      public static const TRACKING_UNTRACKED:String = "untracked";
      
      public static const TRACKING_MAX_TRACKED:String = "maxTracked";
      
      protected var _id:String;
      
      protected var _started:Boolean;
      
      protected var _complete:Boolean;
      
      protected var _conditionProgress:Vector.<int>;
      
      protected var _collected:Boolean;
      
      protected var _index:int;
      
      protected var _important:Boolean;
      
      protected var _startImageURI:String;
      
      protected var _completeImageURI:String;
      
      protected var _isAchievement:Boolean;
      
      protected var _level:int;
      
      protected var _secretLevel:uint = 0;
      
      protected var _type:String;
      
      protected var _xml:XML;
      
      protected var _new:Boolean;
      
      protected var _children:Vector.<Quest>;
      
      protected var _startTime:Date;
      
      protected var _endTime:Date;
      
      protected var _failed:Boolean;
      
      protected var _timeBased:Boolean;
      
      protected var _visible:Boolean = true;
      
      public var progressChanged:Signal;
      
      public var rewardCollected:Signal;
      
      public var completed:Signal;
      
      public var tracked:Signal;
      
      public var untracked:Signal;
      
      public var isGlobalQuest:Boolean = false;
      
      public function Quest(param1:XML)
      {
         super();
         this._children = new Vector.<Quest>();
         this._conditionProgress = new Vector.<int>();
         if(param1 != null)
         {
            this.parse(param1);
         }
         this.progressChanged = new Signal(Quest,int,int);
         this.rewardCollected = new Signal(Quest);
         this.completed = new Signal(Quest);
         this.tracked = new Signal(Quest);
         this.untracked = new Signal(Quest);
      }
      
      public static function getIcon(param1:String) : BitmapData
      {
         switch(param1)
         {
            case "dynamic":
               return new BmpIconClass_all();
            case "achievement":
               return new BmpIconAchievement();
            case "general":
               return new BmpIconQuest();
            case "combat":
               return new BmpIconClass_fighter();
            case "scavenge":
               return new BmpIconClass_scavenger();
            case "construct":
               return new BmpIconClass_engineer();
            case "world":
               return new BmpIconQuestWorld();
            default:
               return null;
         }
      }
      
      public static function getColor(param1:String) : uint
      {
         switch(param1)
         {
            case "dynamic":
               return 1416887;
            case "achievement":
               return 8305705;
            case "general":
               return 681107;
            case "combat":
               return 9582602;
            case "scavenge":
               return 4598128;
            case "construct":
               return 10979109;
            case "world":
               return 3421493;
            default:
               return 0;
         }
      }
      
      public function dispose() : void
      {
         this._xml = null;
      }
      
      public function collect(param1:Function = null) : void
      {
         var player:PlayerData = null;
         var lang:Language = null;
         var msgBusy:BusyDialogue = null;
         var self:Quest = null;
         var onComplete:Function = param1;
         player = Network.getInstance().playerData;
         if(player == null || this._isAchievement)
         {
            return;
         }
         if(!this._complete)
         {
            return;
         }
         if(this._collected)
         {
            return;
         }
         lang = Language.getInstance();
         msgBusy = new BusyDialogue(lang.getString("quests_collecting"),"quest-collecting");
         msgBusy.open();
         self = this;
         Network.getInstance().save({"id":this._id},SaveDataMethod.QUEST_COLLECT,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            msgBusy.close();
            if(param1 == null || param1.success === false)
            {
               Network.getInstance().client.errorLog.writeError("QuestsTasks: onCollectClicked: QUEST_COLLECT: Invalid or null response object returned","","",{});
               Network.getInstance().throwSyncError();
               return;
            }
            if(param1.penaltyFail === true)
            {
               _loc2_ = new MessageBox(lang.getString("quest_penalty_fail_msg"));
               _loc2_.addTitle(lang.getString("quest_penalty_fail_title"));
               _loc2_.addButton(lang.getString("quest_penalty_fail_ok"));
               _loc2_.open();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            if(_index >= 0)
            {
               player.questsCollectedStatus[_index] = true;
            }
            _collected = true;
            if(param1.penalties != null)
            {
               QuestSystem.getInstance().applyPenalties(param1.penalties);
            }
            if("levelPts" in param1)
            {
               player.levelPoints = int(param1.levelPts);
            }
            QuestSystem.getInstance().giveRewards(param1);
            Audio.sound.play("sound/interface/int-buy-collect.mp3");
            rewardCollected.dispatch(self);
            QuestSystem.getInstance().questCollected.dispatch(self);
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      public function collectGlobal(param1:Function = null) : void
      {
         var lang:Language;
         var msgBusy:BusyDialogue = null;
         var self:Quest = null;
         var onComplete:Function = param1;
         var player:PlayerData = Network.getInstance().playerData;
         if(player == null || this._isAchievement)
         {
            return;
         }
         if(!player.globalQuests.getContributed(this.id))
         {
            return;
         }
         if(player.globalQuests.getCollected(this.id))
         {
            return;
         }
         lang = Language.getInstance();
         msgBusy = new BusyDialogue(lang.getString("quests_collecting"),"quest-collecting");
         msgBusy.open();
         self = this;
         Network.getInstance().save({"id":this._id},SaveDataMethod.GLOBAL_QUEST_COLLECT,function(param1:Object):void
         {
            msgBusy.close();
            if(param1 == null || param1.success === false)
            {
               Network.getInstance().client.errorLog.writeError("GlobalQuestsTasks: onCollectClicked: GLOBALQUEST_COLLECT: Invalid or null response object returned","","",{});
               Network.getInstance().throwSyncError();
               return;
            }
            GlobalQuestSystem.getInstance().collect(this.id);
            _collected = true;
            QuestSystem.getInstance().giveRewards(param1);
            Audio.sound.play("sound/interface/int-buy-collect.mp3");
            rewardCollected.dispatch(self);
            GlobalQuestSystem.getInstance().questCollected.dispatch(self);
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      public function getItemResourceGoals() : Array
      {
         var req:XMLList = null;
         var itemsXML:XML = null;
         var lang:Language = null;
         var output:Array = null;
         var node:XML = null;
         var id:String = null;
         var itemName:String = null;
         var imageURI:String = null;
         var itemNode:XML = null;
         var prog:int = 0;
         var total:int = 0;
         req = this._xml.goal.res + this._xml.goal.itm.(hasOwnProperty("@id"));
         if(req.length() == 0)
         {
            return [];
         }
         itemsXML = ResourceManager.getInstance().getResource("xml/items.xml").content;
         lang = Language.getInstance();
         output = [];
         for each(node in req)
         {
            id = node.@id.toString();
            itemName = lang.getString("items." + id);
            itemNode = itemsXML.item.(@id == id)[0];
            if(itemNode != null)
            {
               imageURI = itemNode.img.@uri.toString();
            }
            if(node.hasOwnProperty("val"))
            {
               total = int(node.val);
               prog = this._conditionProgress[node.childIndex()];
            }
            output.push({
               "id":id,
               "name":itemName,
               "image":imageURI,
               "prog":prog,
               "total":total
            });
         }
         return output;
      }
      
      public function getNonItemResourceGoals() : Array
      {
         var req:XMLList = null;
         var lang:Language = null;
         var output:Array = null;
         var index:int = 0;
         var node:XML = null;
         var strDesc:String = null;
         var prog:int = 0;
         var total:int = 0;
         var reqCont:int = 0;
         var userCont:int = 0;
         var strGoal:String = null;
         var player:PlayerData = null;
         var contNode:XML = null;
         var multiplier:Number = NaN;
         var userLevel:int = 0;
         var workingTotal:Number = NaN;
         var i:int = 0;
         req = this._xml.goal.children().(localName() != "res" && (localName() != "itm" || localName() == "itm" && !hasOwnProperty("@id")));
         if(req.length() == 0)
         {
            return [];
         }
         lang = Language.getInstance();
         output = [];
         index = 0;
         for each(node in req)
         {
            if(node.hasOwnProperty("@desc"))
            {
               strDesc = lang.getString("quests_goal." + node.@desc.toString());
            }
            else
            {
               strGoal = "";
               if(node.localName() == "srv" && !node.hasOwnProperty("@id"))
               {
                  strDesc = lang.getString("quests_goal.srv_all");
               }
               else
               {
                  switch(node.localName())
                  {
                     case "lvl":
                        strGoal = String(int(node.val) + 1).toString();
                        break;
                     case "itm":
                        strGoal = lang.getString("itm_types." + node.@type.toString());
                        break;
                     case "bld":
                        if(node.hasOwnProperty("@lvl"))
                        {
                           strGoal = lang.getString("lvl",String(int(node.@lvl.toString()) + 1)) + " ";
                        }
                        strGoal += lang.getString("blds." + node.@id.toString());
                        break;
                     case "srv":
                        if(node.hasOwnProperty("@lvl"))
                        {
                           strGoal = lang.getString("lvl",String(int(node.@lvl.toString()) + 1)) + " ";
                        }
                        strGoal += lang.getString("survivor_classes." + node.@id.toString());
                        break;
                     case "task":
                        strGoal = lang.getString("tasks." + node.@id.toString());
                        break;
                     case "stat":
                     case "statInc":
                        strGoal = lang.getString("stat." + node.@id.toString());
                        break;
                     case "globalStat":
                        strGoal = lang.getString("stat." + node.@id.toString());
                  }
                  strDesc = lang.getString("quests_goal." + node.localName(),strGoal);
               }
            }
            if(node.localName() != "lvl" && node.localName() != "tut" && Boolean(node.hasOwnProperty("val")))
            {
               total = int(node.val);
               prog = this._conditionProgress[node.childIndex()];
            }
            reqCont = 0;
            userCont = 0;
            if(node.cont.length() > 0)
            {
               player = Network.getInstance().playerData;
               contNode = node.cont[0];
               multiplier = contNode.hasOwnProperty("@mult") ? Number(contNode.@mult) : 1;
               userLevel = int(player.getPlayerSurvivor().level);
               if(this.isGlobalQuest)
               {
                  userCont = player.globalQuests.getTotal(this.id,index);
                  if(player.globalQuests.getContributed(this.id))
                  {
                     userLevel = player.globalQuests.getContributedLevel(this.id);
                  }
               }
               workingTotal = Number(contNode.toString());
               i = 0;
               while(i < userLevel)
               {
                  workingTotal *= multiplier;
                  i++;
               }
               if(workingTotal > 5)
               {
                  workingTotal = Math.floor(workingTotal / 5) * 5;
               }
               reqCont = Math.floor(workingTotal);
            }
            output.push({
               "name":strDesc,
               "prog":prog,
               "total":total,
               "userCont":userCont,
               "reqCont":reqCont
            });
            index++;
         }
         return output;
      }
      
      public function getRewards() : Array
      {
         var _loc6_:XML = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Item = null;
         var _loc10_:Item = null;
         var _loc1_:PlayerData = Network.getInstance().playerData;
         var _loc2_:int = -1;
         if(this.isGlobalQuest && _loc1_.globalQuests.getContributed(this.id))
         {
            _loc2_ = _loc1_.globalQuests.getContributedLevel(this.id);
         }
         if(_loc2_ < 0)
         {
            _loc2_ = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         }
         var _loc3_:XMLList = this._xml.reward.children();
         if(_loc3_.length() == 0)
         {
            return [];
         }
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         for each(_loc6_ in _loc3_)
         {
            _loc7_ = _loc6_.hasOwnProperty("@minlvl") ? int(_loc6_.@minlvl) : int.MIN_VALUE;
            _loc8_ = _loc6_.hasOwnProperty("@maxlvl") ? int(_loc6_.@maxlvl) : int.MAX_VALUE;
            if(_loc2_ < _loc7_ || _loc2_ > _loc8_)
            {
               continue;
            }
            switch(_loc6_.localName())
            {
               case "itm":
                  _loc9_ = ItemFactory.createItemFromXML(_loc6_);
                  _loc4_.push(_loc9_);
                  break;
               case "res":
                  _loc10_ = ItemFactory.createItemFromTypeId(_loc6_.@id.toString());
                  _loc10_.quantity = int(_loc6_.toString());
                  _loc4_.push(_loc10_);
                  break;
               case "xp":
                  _loc5_ += int(_loc6_.toString());
                  break;
               case "xpPerc":
                  _loc5_ += this.calculateXPPerc(_loc6_);
            }
         }
         if(_loc5_ > 0)
         {
            _loc4_.push({
               "type":"xp",
               "value":_loc5_
            });
         }
         return _loc4_;
      }
      
      public function getName() : String
      {
         if(this._isAchievement)
         {
            if(!this._complete && this._secretLevel >= SECRET_HIDDEN)
            {
               return Language.getInstance().getString("achievements.secret_name");
            }
            return Language.getInstance().getString("achievements." + this._id + "_name");
         }
         var _loc1_:String = this.isGlobalQuest ? "globalQuests.g" + this._id : "quests." + this._id;
         return Language.getInstance().getString(_loc1_ + "_name");
      }
      
      public function getDescription() : String
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         if(this._isAchievement)
         {
            if(!this._complete && this._secretLevel > SECRET_NONE)
            {
               return Language.getInstance().getString("achievements.secret_desc");
            }
            _loc3_ = this._xml.goal.children()[0];
            if(_loc3_ != null)
            {
               _loc2_ = NumberFormatter.format(int(_loc3_.val.toString()),0);
            }
            return Language.getInstance().getString("achievements." + this._id + "_desc",_loc2_);
         }
         var _loc1_:String = this.isGlobalQuest ? "globalQuests.g" + this._id : "quests." + this._id;
         return Language.getInstance().getString(_loc1_ + "_desc");
      }
      
      public function getShortDescription() : String
      {
         var _loc1_:String = this._isAchievement ? "achievements" : "quests";
         var _loc2_:String = this.isGlobalQuest ? "globalQuests.g" + this._id : _loc1_ + "." + this._id;
         return Language.getInstance().getString(_loc2_ + "_stub");
      }
      
      public function setProgress(param1:int, param2:int) : void
      {
         var _loc3_:int = this._conditionProgress[param1];
         if(_loc3_ != param2)
         {
            this._conditionProgress[param1] = Math.min(param2,this.getGoalTotal(param1));
            this.progressChanged.dispatch(this,param1,param2);
         }
      }
      
      public function getProgress(param1:int) : int
      {
         if(param1 < 0 || param1 >= this._conditionProgress.length)
         {
            return 0;
         }
         return this._conditionProgress[param1];
      }
      
      public function getTotalProgress() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._conditionProgress.length)
         {
            _loc1_ += this._conditionProgress[_loc2_];
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getGoalTotal(param1:int) : int
      {
         var _loc2_:XML = this._xml.goal.children()[param1];
         return int(_loc2_.val.toString());
      }
      
      public function getAllGoalsTotal() : int
      {
         var _loc2_:XML = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._xml.goal.children())
         {
            _loc1_ += int(_loc2_.val.toString());
         }
         return _loc1_;
      }
      
      public function getGoalXMLNode(param1:int) : XML
      {
         return this._xml.goal.children()[param1];
      }
      
      public function getXPReward() : int
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._xml.reward.xp)
         {
            _loc1_ += int(_loc2_.toString());
         }
         for each(_loc3_ in this._xml.reward.xpPerc)
         {
            _loc1_ += int(this.calculateXPPerc(_loc3_));
         }
         return _loc1_;
      }
      
      public function prereqQuestsCompleted() : Boolean
      {
         var _loc2_:XML = null;
         var _loc3_:Boolean = false;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:Quest = null;
         if(this._xml == null)
         {
            return true;
         }
         var _loc1_:XMLList = this._xml.prereq;
         if(_loc1_.length() > 0)
         {
            for each(_loc2_ in _loc1_)
            {
               _loc3_ = false;
               for each(_loc4_ in _loc2_.quest)
               {
                  _loc5_ = _loc4_.toString();
                  _loc6_ = QuestSystem.getInstance().getQuestOrAchievementById(_loc5_);
                  if(_loc6_ != null && _loc6_.complete)
                  {
                     _loc3_ = true;
                     break;
                  }
               }
               if(!_loc3_)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      private function parse(param1:XML) : void
      {
         this._xml = param1;
         this._id = this._xml.@id.toString();
         this._index = param1.childIndex();
         this._conditionProgress.length = this._xml.goal.children().length();
         this._visible = Boolean(param1.@visible != "0") && Boolean(param1.@silent != "1");
         if(this._xml.localName() == "ach")
         {
            this._isAchievement = true;
            this._important = false;
            this._type = TYPE_ACHIEVEMENT;
            this._level = 0;
            this._secretLevel = this._xml.hasOwnProperty("@secret") ? uint(this._xml.@secret) : SECRET_NONE;
            this._timeBased = this._xml.@time == "1";
         }
         else
         {
            this._secretLevel = SECRET_NONE;
            this._isAchievement = false;
            this._type = this._xml.@type.toString();
            this._level = int(this._xml.@level.toString());
            this._important = this._xml.@important == "1";
            this._timeBased = false;
         }
         if(this._xml.hasOwnProperty("@start"))
         {
            this._startTime = DateTimeUtils.convertToUTCDate(this._xml.@start);
         }
         if(this._xml.hasOwnProperty("@end"))
         {
            this._endTime = DateTimeUtils.convertToUTCDate(this._xml.@end);
         }
         this._startImageURI = this._xml.hasOwnProperty("img_start") ? this._xml.img_start.@uri.toString() : "images/quests/" + this._type + "-start.jpg";
         this._completeImageURI = this._xml.hasOwnProperty("img_comp") ? this._xml.img_comp.@uri.toString() : "images/quests/" + this._type + "-complete.jpg";
      }
      
      protected function completeConditions() : void
      {
         var _loc1_:XML = null;
         var _loc2_:int = 0;
         for each(_loc1_ in this._xml.goal.children())
         {
            _loc2_ = int(_loc1_.val.toString());
            this._conditionProgress[_loc1_.childIndex()] = _loc2_;
         }
      }
      
      private function calculateXPPerc(param1:XML) : Number
      {
         var _loc2_:Survivor = Network.getInstance().playerData.getPlayerSurvivor();
         var _loc3_:int = int(_loc2_.level - 1);
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         var _loc4_:Number = int(_loc2_.getXPForLevel(_loc3_) * Number(param1.toString()));
         _loc4_ = Math.floor(_loc4_ / 10) * 10;
         if(_loc4_ < 10)
         {
            _loc4_ = 10;
         }
         return _loc4_;
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function set complete(param1:Boolean) : void
      {
         this._complete = param1;
         if(this._complete)
         {
            this._new = false;
            this._started = true;
            this.completeConditions();
         }
         this.completed.dispatch(this);
      }
      
      public function get collected() : Boolean
      {
         return this._collected;
      }
      
      public function set collected(param1:Boolean) : void
      {
         this._collected = param1;
         if(this._collected)
         {
            this._new = false;
         }
      }
      
      public function get started() : Boolean
      {
         return this._started;
      }
      
      public function set started(param1:Boolean) : void
      {
         this._started = param1;
      }
      
      public function get isNew() : Boolean
      {
         return this._new;
      }
      
      public function set isNew(param1:Boolean) : void
      {
         this._new = param1;
      }
      
      public function get children() : Vector.<Quest>
      {
         return this._children;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get isAchievement() : Boolean
      {
         return this._isAchievement;
      }
      
      public function get important() : Boolean
      {
         return this._important;
      }
      
      public function get imageStartURI() : String
      {
         return this._startImageURI;
      }
      
      public function get imageCompleteURI() : String
      {
         return this._completeImageURI;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get secretLevel() : uint
      {
         return this._secretLevel;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get xml() : XML
      {
         return this._xml;
      }
      
      public function get isTimeBased() : Boolean
      {
         return this._timeBased;
      }
      
      public function get startTime() : Date
      {
         return this._startTime;
      }
      
      public function get endTime() : Date
      {
         return this._endTime;
      }
      
      public function get failed() : Boolean
      {
         return this._failed;
      }
      
      public function set failed(param1:Boolean) : void
      {
         this._failed = param1;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
   }
}

