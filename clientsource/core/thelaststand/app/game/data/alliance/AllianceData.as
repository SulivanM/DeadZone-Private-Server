package thelaststand.app.game.data.alliance
{
   import com.dynamicflash.util.Base64;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class AllianceData extends AllianceDataSummary
   {
      
      private var _bannerEdits:int;
      
      private var _members:AllianceMemberList;
      
      private var _messages:AllianceMessageList;
      
      private var _enemies:AllianceList;
      
      private var _rankNames:Dictionary;
      
      private var _founderId:String;
      
      private var _founder:AllianceMember;
      
      private var _tokens:int;
      
      private var _effects:Vector.<Effect>;
      
      private var _tasks:Vector.<AllianceTask>;
      
      private var _numTasks:int;
      
      private var _numEffects:int;
      
      private var _numEffectSlots:int;
      
      private var _attackedTargets:Dictionary;
      
      private var _scoutedTargets:Dictionary;
      
      public var rankNameChanged:Signal = new Signal(uint);
      
      public var effectAdded:Signal = new Signal(int,Effect);
      
      public var effectRemoved:Signal = new Signal(int,Effect);
      
      public var tokensChanged:Signal = new Signal();
      
      public var pointsChanged:Signal = new Signal();
      
      public var taskCompleted:Signal = new Signal(AllianceTask);
      
      public function AllianceData(param1:String)
      {
         super(param1);
         this._members = new AllianceMemberList();
         this._members.memberRemoved.add(this.onMemberRemoved);
         this._members.memberRankChanged.add(this.onMemberRankChanged);
         this._messages = new AllianceMessageList();
         this._enemies = new AllianceList();
         this._numEffectSlots = int(Config.constant.ALLIANCE_EFFECT_BASE_COUNT) + 1;
         this._effects = new Vector.<Effect>(this._numEffectSlots,true);
         this._numTasks = int(Config.constant.ALLIANCE_TASK_COUNT);
         this._tasks = new Vector.<AllianceTask>(this._numTasks,true);
         this._attackedTargets = new Dictionary();
         this._scoutedTargets = new Dictionary();
      }
      
      public function get tokens() : int
      {
         return this._tokens;
      }
      
      public function get members() : AllianceMemberList
      {
         return this._members;
      }
      
      public function get messages() : AllianceMessageList
      {
         return this._messages;
      }
      
      public function get enemies() : AllianceList
      {
         return this._enemies;
      }
      
      public function get founder() : AllianceMember
      {
         return this._founder;
      }
      
      public function get numBannerEdits() : int
      {
         return this._bannerEdits;
      }
      
      public function get numEffectSlots() : int
      {
         return this._numEffectSlots;
      }
      
      public function get numTasks() : int
      {
         return this._numTasks;
      }
      
      override public function get memberCount() : int
      {
         return this._members.numMembers;
      }
      
      public function getEffect(param1:int) : Effect
      {
         if(param1 < 0 || param1 >= this._numEffectSlots)
         {
            return null;
         }
         return this._effects[param1];
      }
      
      public function getRankName(param1:uint) : String
      {
         var _loc2_:String = this._rankNames != null ? this._rankNames[param1] : null;
         return _loc2_ || Language.getInstance().getString("alliance.rank_" + param1);
      }
      
      public function getTask(param1:int) : AllianceTask
      {
         if(param1 < 0 || param1 >= this._numTasks)
         {
            return null;
         }
         return this._tasks[param1];
      }
      
      internal function getTaskIndex(param1:AllianceTask) : int
      {
         return this._tasks.indexOf(param1);
      }
      
      internal function setRankName(param1:uint, param2:String) : void
      {
         if(this._rankNames == null)
         {
            this._rankNames = new Dictionary(true);
         }
         var _loc3_:String = this._rankNames[param1];
         if(_loc3_ == param2)
         {
            return;
         }
         if(param2.length == 0)
         {
            delete this._rankNames[param1];
         }
         else
         {
            this._rankNames[param1] = param2;
         }
         this.rankNameChanged.dispatch(param1);
      }
      
      internal function setNumOfBannerEdits(param1:uint) : void
      {
         this._bannerEdits = param1;
      }
      
      internal function addEffect(param1:int, param2:ByteArray) : void
      {
         var effect:Effect = null;
         var index:int = param1;
         var bytes:ByteArray = param2;
         if(index < 0 || index >= this._numEffectSlots)
         {
            return;
         }
         try
         {
            effect = new Effect();
            effect.readObject(bytes);
         }
         catch(error:Error)
         {
            return;
         }
         this._effects[index] = effect;
         this.effectAdded.dispatch(index,effect);
      }
      
      internal function setTokens(param1:int) : void
      {
         if(param1 == this._tokens)
         {
            return;
         }
         this._tokens = param1;
         this.tokensChanged.dispatch();
      }
      
      internal function setTaskCompleted(param1:int) : void
      {
         var _loc2_:AllianceTask = this.getTask(param1);
         _loc2_.setValue(_loc2_.goal);
         this.taskCompleted.dispatch(_loc2_);
      }
      
      internal function setPoints(param1:int) : void
      {
         if(param1 == _points)
         {
            return;
         }
         _points = param1;
         this.pointsChanged.dispatch();
      }
      
      internal function setEffiency(param1:Number) : void
      {
         if(_efficiency == param1)
         {
            return;
         }
         _efficiency = param1;
      }
      
      internal function setTaskSet(param1:int) : void
      {
         var allianceXML:XML;
         var taskSetXML:XMLList;
         var i:int = 0;
         var id:String = null;
         var node:XML = null;
         var taskSet:int = param1;
         i = 0;
         while(i < this._numTasks)
         {
            this._tasks[i] = null;
            i++;
         }
         allianceXML = ResourceManager.getInstance().get("xml/alliances.xml");
         if(allianceXML == null)
         {
            return;
         }
         taskSetXML = allianceXML.taskSets.set[taskSet].task;
         i = 0;
         while(i < this._numTasks)
         {
            id = taskSetXML[i].toString();
            node = allianceXML.tasks.task.(@id == id)[0];
            this._tasks[i] = new AllianceTask(node);
            i++;
         }
      }
      
      internal function setEffectSet(param1:Object) : void
      {
         var i:String = null;
         var index:Number = NaN;
         var effect:Effect = null;
         var data:Object = param1;
         this._numEffects = 0;
         if(data == null)
         {
            return;
         }
         this.clearEffects();
         for(i in data)
         {
            index = parseInt(i);
            if(!isNaN(index))
            {
               try
               {
                  effect = new Effect();
                  effect.readObject(Base64.decodeToByteArray(data[i]));
                  this._effects[index] = effect;
                  ++this._numEffects;
               }
               catch(error:Error)
               {
               }
            }
         }
      }
      
      internal function clearEffects() : void
      {
         var _loc2_:Effect = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._numEffectSlots)
         {
            _loc2_ = this._effects[_loc1_];
            if(_loc2_ != null)
            {
               this.effectRemoved.dispatch(_loc1_,_loc2_);
               this._effects[_loc1_] = null;
            }
            _loc1_++;
         }
      }
      
      public function hasBannerProtection(param1:String) : Boolean
      {
         if(this._attackedTargets[param1] == null)
         {
            return false;
         }
         return Network.getInstance().serverTime - this._attackedTargets[param1].time < uint(Config.constant.ALLIANCE_TARGET_PROTECTION_TIME) * 1000;
      }
      
      public function getAttackedTargetData(param1:String) : Object
      {
         return this._attackedTargets[param1];
      }
      
      internal function parseAttackedTargets(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:* = undefined;
         var _loc5_:Date = null;
         this._attackedTargets = new Dictionary();
         for(_loc2_ in param1)
         {
            if(_loc2_ != "key")
            {
               if(!(param1[_loc2_] is String))
               {
                  _loc3_ = new Object();
                  _loc3_.user = param1[_loc2_].user;
                  _loc4_ = param1[_loc2_].time;
                  if(_loc4_ is String)
                  {
                     _loc5_ = new Date(_loc4_);
                     _loc5_.minutes -= _loc5_.timezoneOffset;
                     _loc3_.time = _loc5_.time;
                  }
                  else
                  {
                     _loc3_.time = Number(_loc4_);
                  }
                  this._attackedTargets[_loc2_] = _loc3_;
               }
            }
         }
      }
      
      internal function clearAttackedTargets() : void
      {
         this._attackedTargets = new Dictionary();
      }
      
      public function hasScoutingProtection(param1:String) : Boolean
      {
         if(this._scoutedTargets[param1] == null)
         {
            return false;
         }
         return Network.getInstance().serverTime - this._scoutedTargets[param1].time < uint(Config.constant.ALLIANCE_TARGET_SCOUT_PROTECTION_TIME) * 1000;
      }
      
      public function getScoutingData(param1:String) : Object
      {
         return this._scoutedTargets[param1];
      }
      
      internal function parseScoutedTargets(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:* = undefined;
         var _loc5_:Date = null;
         this._scoutedTargets = new Dictionary();
         for(_loc2_ in param1)
         {
            if(_loc2_ != "key")
            {
               if(!(param1[_loc2_] is String))
               {
                  _loc3_ = new Object();
                  _loc3_.user = param1[_loc2_].user;
                  _loc4_ = param1[_loc2_].time;
                  if(_loc4_ is String)
                  {
                     _loc5_ = new Date(_loc4_);
                     _loc5_.minutes -= _loc5_.timezoneOffset;
                     _loc3_.time = _loc5_.time;
                  }
                  else
                  {
                     _loc3_.time = Number(_loc4_);
                  }
                  this._scoutedTargets[_loc2_] = _loc3_;
               }
            }
         }
      }
      
      internal function clearScoutedTargets() : void
      {
         this._scoutedTargets = new Dictionary();
      }
      
      override public function deserialize(param1:Object) : void
      {
         super.deserialize(param1);
         if("members" in param1)
         {
            this._members.deserialize(param1.members);
            this._founder = this._members.getFounder();
            this._founderId = this._founder.id;
         }
         if("messages" in param1)
         {
            this._messages.deserialize(param1.messages);
         }
         if("enemies" in param1)
         {
            this._enemies.deserialize(param1.enemies);
         }
         if("ranks" in param1)
         {
            this.parseRanks(param1.ranks);
         }
         if("bannerEdits" in param1)
         {
            this._bannerEdits = int(param1.bannerEdits);
         }
         if("effects" in param1)
         {
            this.setEffectSet(param1.effects);
         }
         if("tokens" in param1)
         {
            this._tokens = int(param1.tokens);
         }
         if("taskSet" in param1)
         {
            this.setTaskSet(int(param1.taskSet));
         }
         if("tasks" in param1)
         {
            this.parseTaskProgress(param1.tasks);
         }
         if("attackedTargets" in param1)
         {
            this.parseAttackedTargets(param1.attackedTargets);
         }
         if("scoutedTargets" in param1)
         {
            this.parseScoutedTargets(param1.scoutedTargets);
         }
      }
      
      private function parseRanks(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         this._rankNames = new Dictionary(true);
         for(_loc2_ in param1)
         {
            _loc3_ = parseInt(_loc2_.substr(1));
            _loc4_ = param1[_loc2_];
            if(_loc4_ != null)
            {
               if(_loc4_.length > 0)
               {
                  this._rankNames[_loc3_] = _loc4_;
               }
            }
         }
      }
      
      private function parseTaskProgress(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         for(_loc2_ in param1)
         {
            if(!isNaN(Number(_loc2_)))
            {
               _loc3_ = int(_loc2_);
               this._tasks[_loc3_].setValue(int(param1[_loc2_]));
            }
         }
      }
      
      private function onMemberRemoved(param1:AllianceMember) : void
      {
         if(param1 == this._founder)
         {
            this._founder = null;
            this._founderId = null;
         }
      }
      
      private function onMemberRankChanged(param1:AllianceMember) : void
      {
         if(param1.rank == AllianceRank.FOUNDER)
         {
            this._founder = param1;
            this._founderId = param1.id;
         }
      }
   }
}

