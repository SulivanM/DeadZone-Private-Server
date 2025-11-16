package thelaststand.app.game.data
{
   import com.dynamicflash.util.Base64;
   import com.exileetiquette.math.MathUtils;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.IOpponent;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.arena.ArenaSystem;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.raid.RaidSystem;
   import thelaststand.app.game.data.research.ResearchEffect;
   import thelaststand.app.game.logic.HumanEnemyFactory;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.states.ActorGunAttackState;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.io.ISerializable;
   import thelaststand.common.lang.Language;
   import thelaststand.engine.map.Cell;
   
   public class MissionData implements ISerializable
   {
      
      public static const DANGER_NORMAL:int = 0;
      
      public static const DANGER_LOW:int = 0;
      
      public static const DANGER_MODERATE:int = 1;
      
      public static const DANGER_DANGEROUS:int = 2;
      
      public static const DANGER_HIGH:int = 3;
      
      public static const DANGER_EXTREME:int = 4;
      
      private var _complete:Boolean;
      
      private var _id:String;
      
      private var _buildingsDestroyed:Vector.<Building>;
      
      private var _survivorsDowned:Vector.<Survivor>;
      
      private var _loot:Vector.<Item>;
      
      private var _returnTimer:TimerData;
      
      private var _lockTimer:TimerData;
      
      private var _survivorData:Dictionary;
      
      private var _playerSurvivorData:SurvivorData;
      
      private var _stats:MissionStats;
      
      private var _enemyResults:EnemyResults;
      
      private var _initZombieData:Array;
      
      private var _missionTime:int;
      
      public var assignmentId:String;
      
      public var assignmentType:String = "None";
      
      public var areaId:String;
      
      public var automated:Boolean;
      
      public var type:String;
      
      public var locationClass:String;
      
      public var suburb:String;
      
      public var opponent:IOpponent;
      
      public var survivors:Vector.<Survivor>;
      
      public var humanEnemies:Vector.<AIActorAgent>;
      
      public var humanEnemyGroup:int = 0;
      
      public var xpEarned:int;
      
      public var deployCells:Vector.<Cell>;
      
      public var sceneXML:XML;
      
      public var zombieKills:Array;
      
      public var humanKills:Array;
      
      public var survivorKills:Array;
      
      public var containersSearched:int;
      
      public var allContainersSearched:Boolean;
      
      public var useTraps:Boolean = true;
      
      public var lootGiven:Signal;
      
      public var sameIP:Boolean;
      
      public var fastestScavenge:Number = 180;
      
      public var triggerCounts:Object = {};
      
      public var xpBreakdown:Object = {};
      
      public var bounty:Number;
      
      public var bountyDate:Number;
      
      public var bountyCollect:Boolean;
      
      public var allianceMatch:Boolean;
      
      public var allianceError:Boolean;
      
      public var allianceRound:int;
      
      public var allianceRoundActive:Boolean;
      
      public var allianceScore:int;
      
      public var allianceIndiScore:int;
      
      public var allianceAttackerWinPoints:int;
      
      public var allianceDefenderWinPoints:int;
      
      public var allianceAttackerLosePoints:int;
      
      public var allianceDefenderLosePoints:int;
      
      public var allianceAttackerAllianceId:String;
      
      public var allianceDefenderAllianceId:String;
      
      public var allianceAttackerAllianceTag:String;
      
      public var allianceDefenderAllianceTag:String;
      
      public var allianceFlagCaptured:Boolean;
      
      public var allianceAttackerEnlisting:Boolean;
      
      public var allianceDefenderEnlisting:Boolean;
      
      public var allianceDefenderLocked:Boolean;
      
      public var allianceAttackerLockout:Boolean;
      
      public var highActivityIndex:int = -1;
      
      public var triggerActivated:Signal = new Signal(String,int);
      
      public function MissionData()
      {
         super();
         this._id = GUID.create();
         this._loot = new Vector.<Item>();
         this._survivorsDowned = new Vector.<Survivor>();
         this._buildingsDestroyed = new Vector.<Building>();
         this._survivorData = new Dictionary(true);
         this._playerSurvivorData = new SurvivorData();
         this._stats = new MissionStats();
         this.survivors = new Vector.<Survivor>();
         this.humanEnemies = new Vector.<AIActorAgent>();
      }
      
      public static function calculateReturnTime(param1:int, param2:Boolean = false, param3:Boolean = false) : uint
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:uint = 0;
         var _loc10_:int = 0;
         var _loc11_:PlayerData = null;
         var _loc12_:Number = Number(NaN);
         var _loc4_:uint = 0;
         var _loc5_:int = 300;
         var _loc6_:Number = param2 ? Number(Config.constant.AUTOMATED_MISSION_TIME_PENALTY) : 1;
         if(!param3 && Network.getInstance().playerData.upgrades.get(PlayerUpgrades.DeathMobileUpgrade))
         {
            _loc4_ = param2 ? uint(int(Config.constant.DMU1_AUTO_RETURN_TIME)) : uint(int(Config.constant.DMU1_RETURN_TIME));
            _loc7_ = Math.min(_loc4_,int(int(Config.constant.MAX_RETURN_TIME) * _loc6_));
            _loc8_ = Math.min(_loc4_,param2 ? int(Config.constant.MIN_AUTO_RETURN_TIME) : int(Config.constant.MIN_RETURN_TIME));
         }
         else
         {
            _loc9_ = uint(Config.constant.BASE_RETURN_TIME);
            _loc4_ = _loc9_ * _loc6_;
            _loc4_ = Math.ceil(_loc4_ / _loc5_) * _loc5_;
            _loc10_ = 1;
            while(_loc10_ < param1)
            {
               _loc4_ += _loc9_ * Math.ceil(3 + _loc10_ / 5) * _loc6_;
               _loc4_ = Math.ceil(_loc4_ / _loc5_) * _loc5_;
               _loc10_++;
            }
            _loc7_ = int(int(Config.constant.MAX_RETURN_TIME) * _loc6_);
            _loc8_ = param2 ? int(Config.constant.MIN_AUTO_RETURN_TIME) : int(Config.constant.MIN_RETURN_TIME);
         }
         if(param3)
         {
            _loc7_ = int(Config.constant.MAX_RETURN_TIME_PVP);
         }
         if(_loc4_ > _loc7_)
         {
            _loc4_ = uint(_loc7_);
         }
         if(!param2 && !param3)
         {
            _loc11_ = Network.getInstance().playerData;
            _loc12_ = _loc11_.compound.getEffectValue(EffectType.getTypeValue("ReturnTime")) / 100 + _loc11_.researchState.getEffectValue(ResearchEffect.MissionReturnTime);
            _loc4_ = uint(int(_loc4_ + _loc4_ * _loc12_));
         }
         if(_loc4_ < _loc8_)
         {
            _loc4_ = uint(_loc8_);
         }
         return _loc4_;
      }
      
      public static function calculateAmmoCost(param1:Vector.<Survivor>) : int
      {
         var _loc4_:Survivor = null;
         var _loc5_:Number = Number(NaN);
         var _loc2_:int = 0;
         var _loc3_:WeaponData = new WeaponData();
         for each(_loc4_ in param1)
         {
            _loc3_.populate(_loc4_,_loc4_.loadoutOffence.weapon.item as Weapon,_loc4_.loadoutOffence.type);
            _loc2_ += _loc3_.ammoCost;
         }
         _loc5_ = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("AmmoCost"));
         return int(_loc2_ + _loc2_ * (_loc5_ / 100));
      }
      
      public static function getSurvivorBaseScore(param1:Survivor) : Number
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         _loc2_ += param1.getAttribute(Attributes.COMBAT_MELEE) * param1.loadoutOffence.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,Attributes.COMBAT_MELEE) * 100;
         _loc2_ += param1.getAttribute(Attributes.COMBAT_PROJECTILE) * param1.loadoutOffence.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,Attributes.COMBAT_PROJECTILE) * 100;
         var _loc4_:Number = param1.getAttribute(Attributes.HEALING);
         if(_loc4_ > 0)
         {
            _loc3_ += _loc4_ * int(Config.constant.BASE_HEAL_SPEED) * 12;
         }
         return _loc2_ + _loc3_;
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
      }
      
      public function get canBeAutomated() : Boolean
      {
         return !this.isPvP && !this.isAssignment && !(this.opponent is RaiderOpponentData) && this.highActivityIndex < 0;
      }
      
      public function incrementTrigger(param1:String, param2:int = 1) : void
      {
         var _loc4_:String = null;
         if(param2 <= 0)
         {
            return;
         }
         var _loc3_:int = int(this.triggerCounts[param1]);
         this.triggerCounts[param1] = _loc3_ + param2;
         if(param1.indexOf("stat_") == 0)
         {
            _loc4_ = param1.substr(5);
            this._stats.addCustomStat(_loc4_);
         }
         Network.getInstance().save({
            "t":param1,
            "v":param2
         },SaveDataMethod.MISSION_TRIGGER);
         this.triggerActivated.dispatch(param1,this.triggerCounts[param1]);
      }
      
      public function addDestroyedPlayerBuilding(param1:Building) : void
      {
         this._buildingsDestroyed.push(param1);
         if(!param1.isTrap)
         {
            ++this._stats.buildingsLost;
         }
      }
      
      public function addDownedSurvivor(param1:Survivor, param2:String) : void
      {
         var _loc3_:AssignmentData = null;
         var _loc4_:String = null;
         if(this.survivors.indexOf(param1) == -1)
         {
            return;
         }
         param1.requestInjury("major",param2,true,false);
         this._survivorsDowned.push(param1);
         ++this._stats.survivorsDowned;
         if(this.assignmentId != null)
         {
            _loc3_ = Network.getInstance().playerData.assignments.getById(this.assignmentId);
            switch(_loc3_.type)
            {
               case AssignmentType.Raid:
                  _loc4_ = SaveDataMethod.RAID_DEATH;
                  break;
               case AssignmentType.Arena:
                  _loc4_ = SaveDataMethod.ARENA_DEATH;
            }
            Network.getInstance().save({"id":param1.id},_loc4_);
            if(_loc3_ != null)
            {
               try
               {
                  Tracking.trackEvent(_loc3_.type,"SurvivorDowned",_loc3_.name + "_" + _loc3_.currentStageIndex,_loc3_.currentStageIndex);
               }
               catch(error:Error)
               {
               }
            }
         }
      }
      
      public function addLootItem(param1:Item) : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Number = Number(NaN);
         if(param1 == null)
         {
            return;
         }
         this._loot.push(param1);
         switch(param1.category)
         {
            case "resource":
               for each(_loc3_ in param1.xml.res.res)
               {
                  _loc4_ = _loc3_.@id.toString();
                  _loc5_ = Math.floor(int(_loc3_.toString()) * param1.quantity);
                  this._stats[_loc4_ + "Found"] += _loc5_;
               }
               break;
            case "weapon":
               ++this._stats.weaponsFound;
               break;
            case "gear":
               ++this._stats.gearFound;
               break;
            case "junk":
               ++this._stats.junkFound;
               break;
            case "crafting":
               ++this._stats.craftingFound;
               break;
            case "research":
               ++this._stats.researchFound;
               break;
            case "research-note":
               ++this._stats.researchNoteFound;
               break;
            case "medical":
               ++this._stats.medicalFound;
               break;
            case "clothing":
               ++this._stats.clothingFound;
               break;
            case "crate":
               ++this._stats.cratesFound;
               break;
            case "schematic":
               ++this._stats.schematicsFound;
               break;
            case "effect":
               ++this._stats.effectFound;
         }
         var _loc2_:String = ItemQualityType.getName(param1.qualityType).toLowerCase();
         if(param1.category == "weapon")
         {
            ++this._stats[_loc2_ + "WeaponFound"];
         }
         else if(param1.category == "gear")
         {
            ++this._stats[_loc2_ + "GearFound"];
         }
      }
      
      public function getDangerLevel() : int
      {
         var _loc7_:Survivor = null;
         var _loc1_:SurvivorCollection = Network.getInstance().playerData.compound.survivors;
         var _loc2_:int = 0;
         var _loc3_:int = _loc1_.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc7_ = _loc1_.getSurvivor(_loc4_);
            _loc2_ += _loc7_.level;
            _loc4_++;
         }
         var _loc5_:Number = _loc2_ / _loc3_;
         var _loc6_:int = Math.round(_loc5_ - this.opponent.level);
         if(_loc6_ >= 2)
         {
            return DANGER_LOW;
         }
         if(_loc6_ >= 0)
         {
            return DANGER_NORMAL;
         }
         if(_loc6_ <= -4)
         {
            return DANGER_EXTREME;
         }
         if(_loc6_ == -3)
         {
            return DANGER_HIGH;
         }
         if(_loc6_ == -2)
         {
            return DANGER_DANGEROUS;
         }
         if(_loc6_ == -1)
         {
            return DANGER_MODERATE;
         }
         return 0;
      }
      
      public function getSuccessChance() : Object
      {
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc19_:Survivor = null;
         var _loc20_:Number = Number(NaN);
         var _loc21_:Number = Number(NaN);
         var _loc22_:Number = Number(NaN);
         var _loc23_:Number = Number(NaN);
         var _loc24_:Number = Number(NaN);
         var _loc25_:Number = Number(NaN);
         var _loc26_:Number = Number(NaN);
         var _loc27_:Number = Number(NaN);
         var _loc28_:Number = Number(NaN);
         var _loc29_:Number = Number(NaN);
         var _loc30_:Number = Number(NaN);
         var _loc31_:PlayerData = null;
         var _loc32_:Number = Number(NaN);
         var _loc33_:Weapon = null;
         var _loc1_:int = int(Config.constant.MISSION_TIME);
         var _loc2_:int = _loc1_ / 2;
         var _loc3_:int = _loc1_ / 30;
         var _loc4_:int = _loc2_ / Config.constant.WAVE_TIME_MAX;
         var _loc5_:int = Config.constant.BASE_WAVE_COUNT * _loc4_;
         var _loc6_:int = this.opponent.level + 1;
         var _loc7_:Number = Number(Config.constant.BASE_ZOMBIE_HEALTH_MULT);
         var _loc8_:Number = 0.23;
         var _loc9_:Number = Config.constant.BASE_ZOMBIE_HEALTH * _loc6_ * _loc6_ * _loc7_ * _loc8_;
         var _loc10_:Number = _loc9_ * _loc5_;
         var _loc11_:Number = 0;
         var _loc12_:Number = 0;
         var _loc13_:Number = 0;
         var _loc14_:Number = 0;
         var _loc18_:WeaponData = new WeaponData();
         for each(_loc19_ in this.survivors)
         {
            _loc12_ += _loc19_.getAttribute(Attributes.HEALTH,false,AttributeOptions.INCLUDE_NONE);
            _loc13_ += _loc19_.getHealableHealth();
            _loc14_ += _loc19_.getAttribute(Attributes.HEALING,_loc19_.loadoutOffence);
            _loc33_ = _loc19_.loadoutOffence.weapon.item as Weapon;
            if(_loc33_ != null)
            {
               _loc18_.populate(_loc19_,_loc33_,_loc19_.loadoutOffence.type);
               _loc11_ += _loc18_.getDPS();
               _loc15_++;
               if(_loc18_.isMelee)
               {
                  _loc16_++;
               }
               else
               {
                  _loc17_++;
               }
            }
         }
         _loc20_ = 6 - this.survivors.length;
         _loc21_ = _loc11_ * _loc2_ / _loc20_;
         _loc22_ = 20;
         _loc23_ = _loc13_ / this.survivors.length;
         _loc24_ = _loc12_ / this.survivors.length;
         _loc25_ = (_loc23_ - _loc24_) * 100 * _loc22_;
         _loc26_ = 10;
         _loc27_ = (100 - Math.abs(_loc16_ - _loc17_) * _loc26_) / 100;
         _loc28_ = _loc14_ / this.survivors.length * 100 * Config.constant.BASE_HEAL_AMOUNT_PER_SECOND * _loc3_;
         _loc29_ = (_loc21_ + _loc25_) * _loc27_ + _loc28_;
         _loc30_ = _loc29_ / _loc10_ * Number(Config.constant.MISSION_SUCCESS_MULT);
         _loc31_ = Network.getInstance().playerData;
         _loc32_ = _loc31_.compound.getEffectValue(EffectType.getTypeValue("AutoMissionSuccess")) / 100 + _loc31_.researchState.getEffectValue(ResearchEffect.MissionAutoSuccess);
         _loc30_ += _loc30_ * _loc32_;
         if(_loc30_ > 0.95)
         {
            _loc30_ = 0.95;
         }
         else if(_loc30_ < 0.01)
         {
            _loc30_ = 0.01;
         }
         return {
            "survivorScore":_loc29_,
            "enemyScore":_loc10_,
            "chance":_loc30_
         };
      }
      
      public function getSurvivorById(param1:String) : Survivor
      {
         var _loc2_:Survivor = null;
         param1 = param1.toUpperCase();
         for each(_loc2_ in this.survivors)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getSurvivorData(param1:Survivor) : SurvivorData
      {
         return this._survivorData[param1];
      }
      
      public function getPlayerSurvivorData() : SurvivorData
      {
         return this._playerSurvivorData;
      }
      
      public function getTotalAmmoCost() : int
      {
         if(this.type == "compound" && !this.opponent.isPlayer)
         {
            return 0;
         }
         if(this.isPvPPractice)
         {
            return 0;
         }
         return MissionData.calculateAmmoCost(this.survivors);
      }
      
      public function isCompoundAttack() : Boolean
      {
         return this.type == "compound" && !this.opponent.isPlayer;
      }
      
      public function startMission(param1:Function = null, param2:Boolean = true) : void
      {
         var i:int;
         var srv:Survivor = null;
         var playerSurvivor:Survivor = null;
         var state:Object = null;
         var self:MissionData = null;
         var data:SurvivorData = null;
         var isAuto:Boolean = false;
         var success:Object = null;
         var msg:BusyDialogue = null;
         var onComplete:Function = param1;
         var showMessage:Boolean = param2;
         log("Trying to startMission now...");
         if(Network.getInstance().isBusy)
         {
            Network.getInstance().asyncOpsCompleted.addOnce(function():void
            {
               startMission(onComplete,showMessage);
            });
            return;
         }
         log("Network is ready...");
         if(this._complete)
         {
            if(onComplete != null)
            {
               onComplete();
            }
            return;
         }
         log("This complete...");
         this._complete = false;
         this.zombieKills = [];
         this.humanKills = [];
         this.survivorKills = [];
         this.containersSearched = 0;
         log("Trying to read survivors...");
         log("The survivors are: " + this.survivors);
         for each(srv in this.survivors)
         {
            if(srv.task != null)
            {
               log("srv.task is not null...");
               srv.task.removeSurvivor(srv);
               srv.task = null;
            }
            log("Now creating SurvivorData..");
            data = new SurvivorData(srv.id);
            data.startXP = srv.XP;
            data.startLevel = srv.level;
            this._survivorData[srv] = data;
            log("Survivor data assigned for" + srv);
         }
         log("Survivors read...");
         log("getting player survivor");
         playerSurvivor = Network.getInstance().playerData.getPlayerSurvivor();
         log("player survivor:" + playerSurvivor);
         this._playerSurvivorData.id = playerSurvivor.id;
         this._playerSurvivorData.startXP = playerSurvivor.XP;
         this._playerSurvivorData.startLevel = playerSurvivor.level;
         state = {};
         state.id = this._id;
         state.ammo = this.getTotalAmmoCost();
         if(this.opponent.isPlayer)
         {
            state.playerId = this.opponent.id;
            state.playerLevel = this.opponent.level;
            this._enemyResults = new EnemyResults();
            this._enemyResults.attackerId = Network.getInstance().playerData.id;
            this._enemyResults.attackerNickname = Network.getInstance().playerData.nickname;
         }
         else if(this.type == "compound")
         {
            state.compound = true;
         }
         else if(this.assignmentId != null)
         {
            state.assignmentId = this.assignmentId;
         }
         else
         {
            log("normal mission matched");
            isAuto = this.canBeAutomated && this.automated;
            state.areaId = this.areaId;
            state.areaLevel = this.opponent.level;
            state.areaType = this.type;
            state.suburb = this.suburb;
            state.automated = isAuto;
            if(isAuto)
            {
               success = this.getSuccessChance();
               state.srvScore = success.survivorScore;
               state.enmScore = success.enemyScore;
            }
         }
         log("after opponent checking");
         state.survivors = [];
         state.loadout = [];
         i = 0;
         while(i < this.survivors.length)
         {
            srv = this.survivors[i];
            srv.missionIndex = i;
            state.survivors.push(SurvivorData(this._survivorData[srv]).writeObject());
            state.loadout.push(srv.loadoutOffence.toHashtable());
            i++;
         }
         state.player = this._playerSurvivorData.writeObject();
         state.highActivityIndex = this.highActivityIndex;
         if(showMessage)
         {
            msg = new BusyDialogue(Language.getInstance().getString("mission_saving_start"),"mission-starting");
            msg.open();
         }
         log("mission started show message");
         self = this;
         log("network start async op");
         Network.getInstance().startAsyncOp();
         log("network after async op");
         log("[MISSION_START] Calling Network.save with state:" + JSON.stringify(state));
         Network.getInstance().save(state,SaveDataMethod.MISSION_START,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            var _loc3_:XML = null;
            var _loc4_:Survivor = null;
            var _loc5_:RaidData = null;
            log("[MISSION_START] Response received:" + param1);
            Network.getInstance().completeAsyncOp();
            if(param1 == null)
            {
               log("[MISSION_START] ERROR: param1 is null or invalid");
               Network.getInstance().client.errorLog.writeError("MissionData: startMission: SaveDataMethod.MISSION_START: Null or invalid response object received","",{},{});
               Network.getInstance().throwSyncError();
               return;
            }
            if(msg != null)
            {
               msg.close();
            }
            if(param1.disabled === true)
            {
               log("[MISSION_START] Mission disabled by server");
               _loc2_ = new MessageBox(Language.getInstance().getString("missions_disabled_msg"));
               _loc2_.addTitle(Language.getInstance().getString("missions_disabled_title"));
               _loc2_.addButton(Language.getInstance().getString("missions_disabled_ok"));
               _loc2_.open();
               return;
            }
            log("[MISSION_START] Starting mission with ID:" + param1.id);
            _id = String(param1.id);
            _missionTime = int(param1.time);
            assignmentType = param1.assignmentType;
            locationClass = param1.areaClass;
            Network.getInstance().playerData.missionStarted.dispatch(self);
            if(param1.automated === true)
            {
               log("[MISSION_START] Automated mission, calling onMissionEndSaved");
               onMissionEndSaved(param1);
            }
            else if(param1.sceneXML != null)
            {
               log("[MISSION_START] Scene XML received");
               sceneXML = XML(param1.sceneXML);
               _initZombieData = param1.z as Array;
               for each(_loc3_ in sceneXML.human.spawn)
               {
                  _loc4_ = HumanEnemyFactory.create(_loc3_);
                  if(_loc4_ != null)
                  {
                     humanEnemies.push(_loc4_);
                  }
               }
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("setBeforeUnloadMessage",Language.getInstance().getString("leavemission_warning"));
               }
            }
            if(opponent.isPlayer && !isPvPPractice)
            {
               Network.getInstance().playerData.compound.globalEffects.removeEffectsWithType(EffectType.getTypeValue("DisablePvP"));
            }
            if(assignmentId != null)
            {
               _loc5_ = Network.getInstance().playerData.assignments.getById(assignmentId) as RaidData;
               if(_loc5_ != null)
               {
                  try
                  {
                     log("[MISSION_START] Tracking raid mission start:" + _loc5_.name);
                     Tracking.trackEvent("Raid","MissionStarted",_loc5_.name + "_" + _loc5_.currentStageIndex,_loc5_.currentStageIndex);
                  }
                  catch(error:Error)
                  {
                     log("[MISSION_START] Tracking error:" + error);
                  }
               }
            }
            if(!automated && !isPvP && type != "compound")
            {
               log("[MISSION_START] Checking alliance match details...");
               allianceAttackerEnlisting = param1.allianceAttackerEnlisting;
               allianceAttackerLockout = param1.allianceAttackerLockout;
               allianceAttackerAllianceId = param1.allianceAttackerAllianceId;
               allianceAttackerAllianceTag = param1.allianceAttackerAllianceTag;
               if(param1.allianceMatch)
               {
                  allianceMatch = param1.allianceMatch;
                  allianceRound = param1.allianceRound;
                  allianceRoundActive = param1.allianceRoundActive;
                  allianceError = param1.allianceError;
                  allianceScore = AllianceSystem.getInstance().alliance.points;
                  allianceIndiScore = AllianceSystem.getInstance().clientMember.points;
                  if(allianceRoundActive == true && allianceError == false)
                  {
                     allianceAttackerWinPoints = param1.allianceAttackerWinPoints;
                  }
               }
            }
            if(onComplete != null)
            {
               log("[MISSION_START] Calling onComplete callback");
               onComplete();
            }
         });
      }
      
      public function endMission(param1:Function = null, param2:Boolean = true) : void
      {
         var state:Object;
         var self:MissionData = null;
         var srv:Survivor = null;
         var allDown:Boolean = false;
         var bld:Building = null;
         var data:Object = null;
         var item:Item = null;
         var msg:BusyDialogue = null;
         var onComplete:Function = param1;
         var showMessage:Boolean = param2;
         if(Network.getInstance().isBusy)
         {
            Network.getInstance().asyncOpsCompleted.addOnce(function():void
            {
               endMission(onComplete,showMessage);
            });
            return;
         }
         if(this._complete)
         {
            if(onComplete != null)
            {
               onComplete();
            }
            return;
         }
         state = {};
         state.id = this._id;
         if(!this.isPvPPractice)
         {
            state.stats = this._stats.writeObject();
            state.srvDown = [];
            state.loot = [];
            state.hp = {};
            state.zKills = this.zombieKills;
            state.hKills = this.humanKills;
            state.sKills = this.survivorKills;
            state.cSearched = this.containersSearched;
            state.ammo = this.getTotalAmmoCost();
            this._stats.ammunitionUsed = state.ammo;
            state.fastestScavenge = this.fastestScavenge;
            if(this.opponent.isPlayer && this._enemyResults != null)
            {
               state.enemyResults = this._enemyResults.writeObject();
               if(this.bountyCollect)
               {
                  state.bountyCollect = this.bountyCollect;
               }
            }
            state.accTest = 0;
            for each(srv in this.survivors)
            {
               state.hp[srv.id] = MathUtils.clamp01(srv.health / srv.maxHealth);
               if(srv.health <= 0)
               {
                  state.srvDown.push({
                     "id":srv.id.toUpperCase(),
                     "c":srv.agentData.lastDamageCause,
                     "ap":this._survivorsDowned.indexOf(srv) > -1
                  });
               }
               if(srv.agentData.accuracyBonus > state.accTest)
               {
                  state.accTest = srv.agentData.accuracyBonus;
               }
            }
            allDown = state.srvDown.length == this.survivors.length;
            state.allianceFlagCaptured = allDown ? false : this.allianceFlagCaptured;
            if(!allDown)
            {
               for each(item in this._loot)
               {
                  item.isNew = true;
                  state.loot.push(this.opponent.isPlayer ? item.writeObject() : item.id.toUpperCase());
               }
            }
            state.destBld = [];
            for each(bld in this._buildingsDestroyed)
            {
               state.destBld.push(bld.id.toUpperCase());
            }
            state.gunstat = [];
            for each(data in ActorGunAttackState.GunTrackingData)
            {
               state.gunstat.push({
                  "type":data.type,
                  "lrs":data.longRangeShots,
                  "lrh":data.longRangeHits
               });
            }
         }
         ActorGunAttackState.GunTrackingData = new Dictionary();
         if(showMessage)
         {
            msg = new BusyDialogue(Language.getInstance().getString("mission_saving_end"));
            msg.open();
         }
         if(this.highActivityIndex > -1)
         {
            Network.getInstance().playerData.highActivityZones[this.highActivityIndex] = -1;
         }
         self = this;
         Network.getInstance().startAsyncOp();
         Network.getInstance().save(state,SaveDataMethod.MISSION_END,function(param1:Object):void
         {
            var _loc3_:AssignmentData = null;
            Network.getInstance().completeAsyncOp();
            if(msg != null)
            {
               msg.close();
            }
            if(ExternalInterface.available)
            {
               ExternalInterface.call("clearBeforeUnloadMessage");
            }
            if(!isPvPPractice)
            {
               if(param1 == null)
               {
                  Network.getInstance().client.errorLog.writeError("MissionData: startMission: SaveDataMethod.MISSION_END: Null or invalid response object received","","",{});
                  Network.getInstance().throwSyncError();
                  return;
               }
               bountyCollect = param1.bountyCollect === true;
               bounty = bountyCollect && Boolean(param1.hasOwnProperty("bounty")) ? Number(param1.bounty) : 0;
               allianceFlagCaptured = param1.hasOwnProperty("allianceFlagCaptured") ? Boolean(param1["allianceFlagCaptured"]) : false;
               if(param1.hasOwnProperty("bountyCap"))
               {
                  Network.getInstance().playerData.bountyCap = param1.bountyCap;
               }
               if(param1.hasOwnProperty("bountyCapTimestamp"))
               {
                  Network.getInstance().playerData.bountyCapTimestamp = param1.bountyCapTimestamp;
               }
            }
            var _loc2_:Object = param1.assignmentresult;
            if(_loc2_ != null)
            {
               _loc3_ = Network.getInstance().playerData.assignments.getById(_loc2_.id);
               if(_loc3_ != null)
               {
                  switch(_loc3_.type)
                  {
                     case AssignmentType.Raid:
                        RaidSystem.handleRaidMissionResult(_loc2_,self);
                        break;
                     case AssignmentType.Arena:
                        ArenaSystem.handleMissionResult(_loc2_,self);
                  }
               }
            }
            onMissionEndSaved(param1);
            if(onComplete != null)
            {
               onComplete();
            }
         });
      }
      
      public function speedUpReturn(param1:Object, param2:Function = null) : void
      {
         var speedUpCost:int;
         var cash:int;
         var network:Network = null;
         var option:Object = param1;
         var onComplete:Function = param2;
         if(this._returnTimer == null || this.isPvPPractice)
         {
            return;
         }
         network = Network.getInstance();
         speedUpCost = network.data.costTable.getCostForTime(option,this._returnTimer.getSecondsRemaining());
         cash = network.playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
         }
         else if(!this._returnTimer.hasEnded() && this._returnTimer.getSecondsRemaining() > 3)
         {
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "option":option.key
            },SaveDataMethod.MISSION_SPEED_UP,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null)
               {
                  return;
               }
               if(param1.error == PlayerIOError.NotEnoughCoins.errorID)
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen();
               }
               if(param1.success === false)
               {
                  return;
               }
               if(_returnTimer != null)
               {
                  _returnTimer.speedUpByPurchaseOption(option);
               }
               Tracking.trackEvent("SpeedUp",option.key,"mission_" + (opponent.isPlayer ? "pvp" : "pve"),int(param1.cost));
               if(onComplete != null)
               {
                  onComplete();
               }
            });
         }
      }
      
      public function sendStats() : void
      {
         if(this.isPvPPractice)
         {
            return;
         }
         Network.getInstance().save({"stats":this.stats.writeObject()},SaveDataMethod.STAT_DATA);
         this.trackStats();
         this._stats.clear();
      }
      
      public function sendStartFlag() : void
      {
         Network.getInstance().save({"id":this._id},SaveDataMethod.MISSION_START_FLAG);
      }
      
      public function sendFirstInteractionFlag() : void
      {
         Network.getInstance().save({"id":this._id},SaveDataMethod.MISSION_INTERACTION_FLAG);
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1 || {};
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:Survivor = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Building = null;
         var _loc6_:TimerData = null;
         var _loc7_:Item = null;
         this._id = String(param1.id);
         this._playerSurvivorData = new SurvivorData(param1.player);
         if(param1.hasOwnProperty("stats"))
         {
            this._stats.readObject(param1.stats);
         }
         this.xpEarned = int(param1.xpEarned);
         this.xpBreakdown = param1.xp != null ? param1.xp : {};
         this._complete = Boolean(param1.completed);
         this.assignmentId = param1.assignmentId;
         this.assignmentType = param1.assignmentType;
         if(param1.hasOwnProperty("playerId"))
         {
            this.opponent = RemotePlayerManager.getInstance().getPlayer(param1.playerId);
            if(this.opponent == null)
            {
               this.opponent = new RemotePlayerData(param1.playerId,{});
            }
            this.automated = false;
            this.areaId = this.type = this.suburb = null;
         }
         else if(param1.compound === true)
         {
            this.type = "compound";
            this.automated = false;
            this.opponent = new ZombieOpponentData(int(this._playerSurvivorData.startLevel));
         }
         else
         {
            this.opponent = new ZombieOpponentData(int(param1.areaLevel));
            this.areaId = String(param1.areaId);
            this.type = String(param1.areaType);
            this.suburb = String(param1.suburb);
            this.automated = Boolean(param1.automated);
         }
         this.survivors.length = 0;
         this._survivorData = new Dictionary(true);
         if(param1.survivors != null)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.survivors.length)
            {
               if(!(param1.survivors[_loc3_] == null || param1.survivors[_loc3_].id == null))
               {
                  _loc2_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(param1.survivors[_loc3_].id);
                  if(_loc2_ != null)
                  {
                     this.survivors.push(_loc2_);
                     this._survivorData[_loc2_] = new SurvivorData(param1.survivors[_loc3_]);
                  }
               }
               _loc3_++;
            }
         }
         this._survivorsDowned.length = 0;
         if(param1.srvDown != null)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.srvDown.length)
            {
               _loc4_ = param1.srvDown[_loc3_];
               _loc2_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc4_.srv);
               if(_loc2_ != null && (_loc4_.severity == null || _loc4_.severity == "major"))
               {
                  this._survivorsDowned.push(_loc2_);
               }
               _loc3_++;
            }
         }
         this._buildingsDestroyed.length = 0;
         if(param1.buildingsDestroyed != null)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.buildingsDestroyed.length)
            {
               _loc5_ = Network.getInstance().playerData.compound.buildings.getBuildingById(param1.buildingsDestroyed[_loc3_]);
               if(_loc5_ != null)
               {
                  this._buildingsDestroyed.push(_loc5_);
               }
               _loc3_++;
            }
         }
         if(param1.returnTimer != null)
         {
            _loc6_ = new TimerData(null,0,this);
            _loc6_.readObject(param1.returnTimer);
            _loc6_.data.type = "return";
            if(!_loc6_.hasEnded())
            {
               this._complete = this.automated ? false : true;
               this._returnTimer = _loc6_;
               this._returnTimer.completed.addOnce(this.onReturnTimerComplete);
               TimerManager.getInstance().addTimer(this._returnTimer);
            }
            else
            {
               _loc6_.dispose();
               this._complete = true;
            }
         }
         this._lockTimer = null;
         if(param1.lockTimer != null)
         {
            _loc6_ = new TimerData(null,0,this);
            _loc6_.readObject(param1.lockTimer);
            _loc6_.data.type = "lock";
            if(!_loc6_.hasEnded())
            {
               this._lockTimer = _loc6_;
               this._lockTimer.completed.addOnce(this.onLockTimerComplete);
               TimerManager.getInstance().addTimer(this._lockTimer);
            }
            else
            {
               _loc6_.dispose();
            }
         }
         if(param1.loot != null)
         {
            this._loot.length = 0;
            _loc3_ = 0;
            while(_loc3_ < param1.loot.length)
            {
               if(param1.loot[_loc3_] != null)
               {
                  _loc7_ = ItemFactory.createItemFromTypeId(param1.loot[_loc3_].type);
                  if(_loc7_ != null)
                  {
                     _loc7_.readObject(param1.loot[_loc3_]);
                     this.addLootItem(_loc7_);
                  }
               }
               _loc3_++;
            }
         }
         if(param1.highActivityIndex != null)
         {
            this.highActivityIndex = param1.highActivityIndex;
         }
      }
      
      private function applyInjuriesFromList(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Survivor = null;
         var _loc4_:Injury = null;
         for each(_loc2_ in param1)
         {
            if(!(_loc2_ == null || _loc2_.success === false || _loc2_.inj == null))
            {
               _loc3_ = this.getSurvivorById(_loc2_.srv);
               if(_loc3_ != null)
               {
                  _loc4_ = new Injury();
                  _loc4_.readObject(_loc2_.inj);
                  _loc3_.injuries.addInjury(_loc4_);
                  if(_loc4_.severityGroup == "major")
                  {
                     this._survivorsDowned.push(_loc3_);
                  }
               }
            }
         }
      }
      
      private function giveLoot(param1:Dialogue = null) : void
      {
         var d:Dialogue = param1;
         var addItems:Function = function(param1:Dialogue = null):void
         {
            var _loc3_:Item = null;
            var _loc2_:Network = Network.getInstance();
            for each(_loc3_ in _loot)
            {
               _loc2_.playerData.giveItem(_loc3_,true);
            }
         };
         var td:Dialogue = DialogueManager.getInstance().getDialogueById("TradingDialog");
         if(td)
         {
            td.closed.add(addItems);
         }
         else
         {
            addItems();
         }
      }
      
      private function trackStats() : void
      {
      }
      
      private function onMissionEndSaved(param1:Object) : void
      {
         var _loc2_:Survivor = null;
         var _loc3_:Object = null;
         var _loc4_:RemotePlayerData = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Item = null;
         var _loc9_:Inventory = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:SurvivorData = null;
         if(this.isPvPPractice)
         {
            this._complete = true;
            return;
         }
         this.automated = Boolean(param1.automated);
         this.xpEarned = int(param1.xpEarned);
         this.xpBreakdown = param1.xp;
         this._complete = this.automated ? false : true;
         if(param1.returnTimer != null)
         {
            this._returnTimer = new TimerData(null,0,this);
            this._returnTimer.readObject(param1.returnTimer);
            this._returnTimer.data.type = "return";
            this._returnTimer.completed.addOnce(this.onReturnTimerComplete);
            TimerManager.getInstance().addTimer(this._returnTimer);
         }
         if(param1.lockTimer != null)
         {
            this._lockTimer = new TimerData(null,0,this);
            this._lockTimer.readObject(param1.lockTimer);
            this._lockTimer.data.type = "lock";
            this._lockTimer.completed.addOnce(this.onLockTimerComplete);
            TimerManager.getInstance().addTimer(this._lockTimer);
         }
         if(param1.loot != null)
         {
            this._loot.length = 0;
            _loc6_ = 0;
            _loc7_ = int(param1.loot.length);
            while(_loc6_ < _loc7_)
            {
               _loc8_ = ItemFactory.createItemFromObject(param1.loot[_loc6_]);
               this.addLootItem(_loc8_);
               _loc6_++;
            }
         }
         if(param1.itmCounters != null)
         {
            _loc9_ = Network.getInstance().playerData.inventory;
            for(_loc10_ in param1.itmCounters)
            {
               _loc8_ = _loc9_.getItemById(_loc10_);
               if(_loc8_ != null)
               {
                  _loc11_ = int(param1.itmCounters[_loc10_]);
                  _loc8_.counterValue += _loc11_;
               }
            }
         }
         if(param1.injuries != null)
         {
            this._survivorsDowned.length = 0;
            this.applyInjuriesFromList(param1.injuries);
         }
         for each(_loc3_ in param1.survivors)
         {
            _loc2_ = this.getSurvivorById(String(_loc3_.id));
            if(_loc2_ != null)
            {
               if(this.assignmentId == null && this.type != "compound")
               {
                  _loc2_.missionId = this._id;
               }
               if(_loc3_.morale != null)
               {
                  _loc2_.morale.readObject(_loc3_.morale);
               }
               _loc12_ = this._survivorData[_loc2_];
               _loc12_.endXP = int(_loc3_.xp);
               _loc12_.endLevel = int(_loc3_.level);
               _loc2_.setLevelXP(_loc12_.endXP,_loc12_.endLevel);
            }
         }
         Network.getInstance().playerData.compound.applyMoraleEffects();
         _loc4_ = this.opponent as RemotePlayerData;
         if(_loc4_ != null)
         {
            _loc4_.incrementBattles();
         }
         this._playerSurvivorData.endXP = int(param1.player.xp);
         this._playerSurvivorData.endLevel = int(param1.player.level);
         var _loc5_:Survivor = Network.getInstance().playerData.getPlayerSurvivor();
         _loc5_.setLevelXP(this._playerSurvivorData.endXP,this._playerSurvivorData.endLevel);
         Network.getInstance().playerData.levelPoints = int(param1.levelPts);
         if(param1.cooldown != null)
         {
            Network.getInstance().playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
         }
         if(!this.automated || this.assignmentId != null)
         {
            this.giveLoot();
         }
         this.trackStats();
         Network.getInstance().playerData.missionEnded.dispatch(this);
      }
      
      private function onReturnTimerComplete(param1:TimerData) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:Item = null;
         this._complete = true;
         if(param1.data.injuries is Array)
         {
            this.applyInjuriesFromList(param1.data.injuries);
         }
         if(param1.data.items is Array)
         {
            this._loot.length = 0;
            _loc3_ = param1.data.items;
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               _loc4_ = ItemFactory.createItemFromObject(_loc3_[_loc2_]);
               if(_loc4_ != null)
               {
                  this._loot.push(_loc4_);
               }
               _loc2_++;
            }
         }
         _loc2_ = 0;
         while(_loc2_ < this.survivors.length)
         {
            this.survivors[_loc2_].missionId = null;
            _loc2_++;
         }
         if(this.automated)
         {
            this.giveLoot();
         }
      }
      
      private function onLockTimerComplete(param1:TimerData) : void
      {
         this._lockTimer = null;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function get returnTimer() : TimerData
      {
         return this._returnTimer;
      }
      
      public function get lockTimer() : TimerData
      {
         return this._lockTimer;
      }
      
      public function get loot() : Vector.<Item>
      {
         return this._loot;
      }
      
      public function get survivorsDowned() : Vector.<Survivor>
      {
         return this._survivorsDowned;
      }
      
      public function get buildingsDestroyed() : Vector.<Building>
      {
         return this._buildingsDestroyed;
      }
      
      public function get stats() : MissionStats
      {
         return this._stats;
      }
      
      public function get enemyResults() : EnemyResults
      {
         return this._enemyResults;
      }
      
      public function get initZombieData() : Array
      {
         return this._initZombieData;
      }
      
      public function get missionTime() : int
      {
         return this._missionTime;
      }
      
      public function get isPvP() : Boolean
      {
         return this.opponent != null ? this.opponent.isPlayer : false;
      }
      
      public function get isPvPPractice() : Boolean
      {
         return this.opponent != null ? this.opponent.isPlayer && this.opponent.id == Network.getInstance().playerData.id : false;
      }
      
      public function get isAssignment() : Boolean
      {
         return this.assignmentId != null;
      }
   }
}

import flash.utils.describeType;
import thelaststand.app.network.Network;
import thelaststand.common.io.ISerializable;

class SurvivorData implements ISerializable
{
   
   public var id:String;
   
   public var startXP:int;
   
   public var startLevel:int;
   
   public var endXP:int;
   
   public var endLevel:int;
   
   public function SurvivorData(param1:* = null)
   {
      super();
      if(param1 != null)
      {
         if(param1 is String)
         {
            this.id = String(param1);
         }
         else if(param1 is Object)
         {
            this.readObject(Object(param1));
         }
      }
   }
   
   public function writeObject(param1:Object = null) : Object
   {
      param1 ||= {};
      param1.id = this.id;
      param1.startLevel = this.startLevel;
      param1.startXP = this.startXP;
      param1.endLevel = this.endLevel;
      param1.endXP = this.endXP;
      return param1;
   }
   
   public function readObject(param1:Object) : void
   {
      this.id = param1.id;
      this.startLevel = param1.startLevel;
      this.startXP = param1.startXP;
      this.endLevel = param1.endLevel;
      this.endXP = param1.endXP;
   }
}

class MissionStats implements ISerializable
{
   
   public var zombieSpawned:int = 0;
   
   public var levelUps:int = 0;
   
   public var damageOutput:Number = 0;
   
   public var damageTaken:Number = 0;
   
   public var containersSearched:int = 0;
   
   public var survivorKills:int = 0;
   
   public var survivorsDowned:int = 0;
   
   public var survivorExplosiveKills:int = 0;
   
   public var humanKills:int = 0;
   
   public var humanExplosiveKills:int = 0;
   
   public var zombieKills:int = 0;
   
   public var zombieExplosiveKills:int = 0;
   
   public var hpHealed:int = 0;
   
   public var explosivesPlaced:int = 0;
   
   public var grenadesThrown:int = 0;
   
   public var grenadesSmokeThrown:int = 0;
   
   public var allianceFlagCaptured:int = 0;
   
   public var buildingsDestroyed:int = 0;
   
   public var buildingsLost:int = 0;
   
   public var buildingsExplosiveDestroyed:int = 0;
   
   public var trapsTriggered:int = 0;
   
   public var trapDisarmTriggered:int = 0;
   
   public var cashFound:int = 0;
   
   public var woodFound:int = 0;
   
   public var metalFound:int = 0;
   
   public var clothFound:int = 0;
   
   public var foodFound:int = 0;
   
   public var waterFound:int = 0;
   
   public var ammunitionFound:int = 0;
   
   public var ammunitionUsed:int = 0;
   
   public var weaponsFound:int = 0;
   
   public var gearFound:int = 0;
   
   public var junkFound:int = 0;
   
   public var medicalFound:int = 0;
   
   public var craftingFound:int = 0;
   
   public var researchFound:int = 0;
   
   public var researchNoteFound:int = 0;
   
   public var clothingFound:int = 0;
   
   public var cratesFound:int = 0;
   
   public var schematicsFound:int = 0;
   
   public var effectFound:int = 0;
   
   public var rareWeaponFound:int = 0;
   
   public var rareGearFound:int = 0;
   
   public var uniqueWeaponFound:int = 0;
   
   public var uniqueGearFound:int = 0;
   
   public var greyWeaponFound:int = 0;
   
   public var greyGearFound:int = 0;
   
   public var whiteWeaponFound:int = 0;
   
   public var whiteGearFound:int = 0;
   
   public var greenWeaponFound:int = 0;
   
   public var greenGearFound:int = 0;
   
   public var blueWeaponFound:int = 0;
   
   public var blueGearFound:int = 0;
   
   public var purpleWeaponFound:int = 0;
   
   public var purpleGearFound:int = 0;
   
   public var premiumWeaponFound:int = 0;
   
   public var premiumGearFound:int = 0;
   
   public var killData:Object = {};
   
   public var customData:Object = {};
   
   public function MissionStats()
   {
      super();
   }
   
   public function addWeaponKill(param1:Weapon, param2:String) : void
   {
      this.addKillData(param1.weaponClass + "Kills");
      this.addKillData(param2 + "-" + param1.weaponClass + "-kills");
      if(param1.weaponType & WeaponType.BLUNT)
      {
         this.addKillData("bluntKills");
         this.addKillData(param2 + "-blunt-kills");
      }
      if(param1.weaponType & WeaponType.BLADE)
      {
         this.addKillData("bladeKills");
         this.addKillData(param2 + "-blade-kills");
      }
      if(param1.weaponType & WeaponType.IMPROVISED)
      {
         this.addKillData("improvisedKills");
         this.addKillData(param2 + "-improvised-kills");
      }
      if(param1.weaponType & WeaponType.EXPLOSIVE)
      {
         this.addKillData("explosiveKills");
         this.addKillData(param2 + "-explosive-kills");
      }
   }
   
   public function addGearKill(param1:Gear, param2:String) : void
   {
      if(param1 == null)
      {
         return;
      }
      this.addKillData(param1.gearClass + "Kills");
      this.addKillData(param2 + "-" + param1.gearClass + "-kills");
      if(param1.gearType & GearType.IMPROVISED)
      {
         this.addKillData("improvisedKills");
         this.addKillData(param2 + "-improvised-kills");
      }
      if(param1.gearType & GearType.EXPLOSIVE)
      {
         this.addKillData("explosiveKills");
         this.addKillData(param2 + "-explosive-kills");
      }
   }
   
   public function addCustomStat(... rest) : void
   {
      if(rest.length == 0)
      {
         return;
      }
      var _loc2_:String = rest.join("-");
      if(_loc2_.length == 0)
      {
         return;
      }
      if(!this.customData.hasOwnProperty(_loc2_))
      {
         this.customData[_loc2_] = 1;
      }
      else
      {
         ++this.customData[_loc2_];
      }
   }
   
   public function clear() : void
   {
      var _loc1_:XML = null;
      var _loc2_:String = null;
      var _loc3_:String = null;
      for each(_loc1_ in describeType(this)..variable)
      {
         _loc3_ = _loc1_.@name.toString();
         if(this[_loc3_] is Number)
         {
            this[_loc3_] = 0;
         }
      }
      for(_loc2_ in this.killData)
      {
         this.killData[_loc2_] = 0;
      }
      for(_loc2_ in this.customData)
      {
         this.customData[_loc2_] = 0;
      }
   }
   
   public function writeObject(param1:Object = null) : Object
   {
      var _loc2_:String = null;
      var _loc3_:int = 0;
      param1 ||= {};
      if(this.containersSearched > 0)
      {
         param1.containersSearched = this.containersSearched;
      }
      if(this.survivorKills > 0)
      {
         param1.survivorKills = this.survivorKills;
      }
      if(this.survivorsDowned > 0)
      {
         param1.survivorsDowned = this.survivorsDowned;
      }
      if(this.zombieKills > 0)
      {
         param1.zombieKills = this.zombieKills;
      }
      if(this.humanKills > 0)
      {
         param1.humanKills = this.humanKills;
      }
      if(this.hpHealed > 0)
      {
         param1.hpHealed = this.hpHealed;
      }
      if(this.cashFound > 0)
      {
         param1.cashFound = this.cashFound;
      }
      if(this.woodFound > 0)
      {
         param1.woodFound = this.woodFound;
      }
      if(this.metalFound > 0)
      {
         param1.metalFound = this.metalFound;
      }
      if(this.clothFound > 0)
      {
         param1.clothFound = this.clothFound;
      }
      if(this.ammunitionFound > 0)
      {
         param1.ammunitionFound = this.ammunitionFound;
      }
      if(this.ammunitionUsed > 0)
      {
         param1.ammunitionUsed = this.ammunitionUsed;
      }
      if(this.foodFound > 0)
      {
         param1.foodFound = this.foodFound;
      }
      if(this.waterFound > 0)
      {
         param1.waterFound = this.waterFound;
      }
      if(this.weaponsFound > 0)
      {
         param1.weaponsFound = this.weaponsFound;
      }
      if(this.gearFound > 0)
      {
         param1.gearFound = this.gearFound;
      }
      if(this.junkFound > 0)
      {
         param1.junkFound = this.junkFound;
      }
      if(this.effectFound > 0)
      {
         param1.effectFound = this.effectFound;
      }
      if(this.cratesFound > 0)
      {
         param1.cratesFound = this.cratesFound;
      }
      if(this.craftingFound > 0)
      {
         param1.craftingFound = this.craftingFound;
      }
      if(this.researchFound > 0)
      {
         param1.researchFound = this.researchFound;
      }
      if(this.researchNoteFound > 0)
      {
         param1.researchNoteFound = this.researchNoteFound;
      }
      if(this.medicalFound > 0)
      {
         param1.medicalFound = this.medicalFound;
      }
      if(this.damageTaken > 0)
      {
         param1.damageTaken = int(this.damageTaken * 100);
      }
      if(this.buildingsLost > 0)
      {
         param1.buildingsLost = this.buildingsLost;
      }
      if(this.buildingsDestroyed > 0)
      {
         param1.buildingsDestroyed = this.buildingsDestroyed;
      }
      if(this.buildingsExplosiveDestroyed > 0)
      {
         param1.buildingsExplosiveDestroyed = this.buildingsExplosiveDestroyed;
      }
      if(this.survivorExplosiveKills > 0)
      {
         param1.survivorExplosiveKills = this.survivorExplosiveKills;
      }
      if(this.zombieExplosiveKills > 0)
      {
         param1.zombieExplosiveKills = this.zombieExplosiveKills;
      }
      if(this.humanExplosiveKills > 0)
      {
         param1.humanExplosiveKills = this.humanExplosiveKills;
      }
      if(this.explosivesPlaced > 0)
      {
         param1.explosivesPlaced = this.explosivesPlaced;
      }
      if(this.grenadesThrown > 0)
      {
         param1.grenadesThrown = this.grenadesThrown;
      }
      if(this.grenadesSmokeThrown > 0)
      {
         param1.grenadesSmokeThrown = this.grenadesSmokeThrown;
      }
      if(this.trapsTriggered > 0)
      {
         param1.trapsTriggered = this.trapsTriggered;
      }
      if(this.trapDisarmTriggered > 0)
      {
         param1.trapDisarmTriggered = this.trapDisarmTriggered;
      }
      for(_loc2_ in this.killData)
      {
         _loc3_ = int(this.killData[_loc2_]);
         if(_loc3_ > 0)
         {
            param1[_loc2_] = _loc3_;
         }
      }
      for(_loc2_ in this.customData)
      {
         _loc3_ = int(this.customData[_loc2_]);
         if(_loc3_ > 0)
         {
            param1[_loc2_] = _loc3_;
         }
      }
      return param1;
   }
   
   public function readObject(param1:Object) : void
   {
   }
   
   private function addKillData(param1:String) : void
   {
      if(!this.killData.hasOwnProperty(param1))
      {
         this.killData[param1] = 1;
      }
      else
      {
         ++this.killData[param1];
      }
   }
}

class EnemyResults implements ISerializable
{
   
   private var _survivorsDowned:Array = [];
   
   public var survivors:Vector.<Survivor> = new Vector.<Survivor>();
   
   public var buildingsDestroyed:Vector.<Building> = new Vector.<Building>();
   
   public var trapsTriggered:Vector.<Building> = new Vector.<Building>();
   
   public var trapsDisarmed:Vector.<Building> = new Vector.<Building>();
   
   public var prodBuildingsRaided:Vector.<Building> = new Vector.<Building>();
   
   public var loot:Vector.<Item> = new Vector.<Item>();
   
   public var attackerId:String;
   
   public var attackerNickname:String;
   
   public var totalBuildingsLooted:int = 0;
   
   public var totalSurvivorsDowned:int = 0;
   
   public function EnemyResults()
   {
      super();
   }
   
   public function get survivorsDowned() : Array
   {
      return this._survivorsDowned;
   }
   
   public function addDownedSurvivor(param1:Survivor, param2:String) : void
   {
      this._survivorsDowned.push({
         "srv":param1,
         "cause":param2
      });
   }
   
   public function writeObject(param1:Object = null) : Object
   {
      var _loc2_:Survivor = null;
      var _loc3_:Object = null;
      var _loc4_:Building = null;
      param1 ||= {};
      param1.attackerId = this.attackerId;
      param1.attackerNickname = this.attackerNickname;
      param1.survivors = [];
      for each(_loc2_ in this.survivors)
      {
         param1.survivors.push(_loc2_.id.toUpperCase());
      }
      param1.srvDown = [];
      for each(_loc3_ in this.survivorsDowned)
      {
         param1.srvDown.push({
            "id":_loc3_.srv.id,
            "c":_loc3_.cause
         });
      }
      param1.prodBuildingsRaided = [];
      for each(_loc4_ in this.prodBuildingsRaided)
      {
         param1.prodBuildingsRaided.push(_loc4_.id);
      }
      param1.buildingsDestroyed = [];
      for each(_loc4_ in this.buildingsDestroyed)
      {
         param1.buildingsDestroyed.push(_loc4_.id);
      }
      param1.trapsTriggered = [];
      for each(_loc4_ in this.trapsTriggered)
      {
         param1.trapsTriggered.push(_loc4_.id);
      }
      param1.trapsDisarmed = [];
      for each(_loc4_ in this.trapsDisarmed)
      {
         param1.trapsDisarmed.push(_loc4_.id);
      }
      param1.totalBuildingsLooted = this.totalBuildingsLooted;
      return param1;
   }
   
   public function readObject(param1:Object) : void
   {
      var _loc2_:int = 0;
      var _loc3_:Building = null;
      var _loc4_:Survivor = null;
      var _loc5_:Survivor = null;
      var _loc6_:Item = null;
      this.attackerId = param1.attackerId;
      this.attackerNickname = param1.attackerNickname;
      this.totalSurvivorsDowned = param1.hasOwnProperty("numSrvDown") ? int(param1.numSrvDown) : 0;
      this.survivors.length = 0;
      _loc2_ = 0;
      while(param1.survivors is Array && _loc2_ < param1.survivors.length)
      {
         if(param1.survivors[_loc2_] != null)
         {
            _loc4_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(param1.survivors[_loc2_].id);
            if(_loc4_ != null)
            {
               this.survivors.push(_loc4_);
            }
         }
         _loc2_++;
      }
      this._survivorsDowned.length = 0;
      _loc2_ = 0;
      while(param1.srvDown is Array && _loc2_ < param1.srvDown.length)
      {
         if(param1.srvDown[_loc2_] != null)
         {
            _loc5_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(param1.srvDown[_loc2_]);
            if(_loc5_ != null)
            {
               this._survivorsDowned.push({
                  "srv":_loc5_,
                  "c":"unknown"
               });
               if(!param1.hasOwnProperty("numSrvDown"))
               {
                  ++this.totalSurvivorsDowned;
               }
            }
         }
         _loc2_++;
      }
      this.loot.length = 0;
      _loc2_ = 0;
      while(param1.loot is Array && _loc2_ < param1.loot.length)
      {
         if(param1.loot[_loc2_] != null)
         {
            _loc6_ = ItemFactory.createItemFromObject(param1.loot[_loc2_]);
            this.loot.push(_loc6_);
         }
         _loc2_++;
      }
      this.prodBuildingsRaided.length = 0;
      _loc2_ = 0;
      while(param1.prodBuildingsRaided is Array && _loc2_ < param1.prodBuildingsRaided.length)
      {
         if(param1.prodBuildingsRaided[_loc2_] != null)
         {
            _loc3_ = Network.getInstance().playerData.compound.buildings.getBuildingById(param1.prodBuildingsRaided[_loc2_]);
            this.prodBuildingsRaided.push(_loc3_);
         }
         _loc2_++;
      }
      this.buildingsDestroyed.length = 0;
      _loc2_ = 0;
      while(param1.buildingsDestroyed is Array && _loc2_ < param1.buildingsDestroyed.length)
      {
         if(param1.buildingsDestroyed[_loc2_] != null)
         {
            _loc3_ = Network.getInstance().playerData.compound.buildings.getBuildingById(param1.buildingsDestroyed[_loc2_]);
            this.buildingsDestroyed.push(_loc3_);
         }
         _loc2_++;
      }
      this.trapsTriggered.length = 0;
      _loc2_ = 0;
      while(param1.trapsTriggered is Array && _loc2_ < param1.trapsTriggered.length)
      {
         if(param1.trapsTriggered[_loc2_] != null)
         {
            _loc3_ = Network.getInstance().playerData.compound.buildings.getBuildingById(param1.trapsTriggered[_loc2_]);
            this.trapsTriggered.push(_loc3_);
         }
         _loc2_++;
      }
      this.trapsDisarmed.length = 0;
      _loc2_ = 0;
      while(param1.trapsDisarmed is Array && _loc2_ < param1.trapsDisarmed.length)
      {
         if(param1.trapsDisarmed[_loc2_] != null)
         {
            _loc3_ = Network.getInstance().playerData.compound.buildings.getBuildingById(param1.trapsDisarmed[_loc2_]);
            this.trapsDisarmed.push(_loc3_);
         }
         _loc2_++;
      }
      if(param1.totalBuildingsLooted)
      {
         this.totalBuildingsLooted = int(param1.totalBuildingsLooted);
      }
   }
}
