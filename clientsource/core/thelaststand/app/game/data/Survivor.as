package thelaststand.app.game.data
{
   import flash.external.*;
   import flash.utils.getTimer;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.data.injury.InjuryList;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.research.ResearchEffect;
   import thelaststand.app.game.entities.actors.SurvivorActor;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.game.logic.ai.AISurvivorAgent;
   import thelaststand.app.game.logic.ai.states.ActorDeathState;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.SurvivorPortrait;
   import thelaststand.common.io.ISerializable;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.engine.objects.GameEntity;
   
   public class Survivor extends AISurvivorAgent implements ISerializable
   {
      
      private static var _staticDeathAnims:Array = ["death","death-back","death-forward"];
      
      private static var _movingDeathAnims:Array = ["death-clothesline","death-faceslide"];
      
      public static const SAVE_OPTION_APPEARANCE:uint = 1;
      
      public static const SAVE_OPTION_GENDER:uint = 2;
      
      public static const SAVE_OPTION_VOICE:uint = 4;
      
      private static var speedReported:Boolean = false;
      
      private const HIT_AREA_HEIGHT:int = 180;
      
      private var _statId:String;
      
      private var _enemyHumanId:String;
      
      private var _assetLoader:AssetLoader = new AssetLoader();
      
      private var _appearance:SurvivorAppearance;
      
      private var _accessories:Vector.<ClothingAccessory>;
      
      private var _activeLoadout:SurvivorLoadout;
      
      private var _dispatchLevelUp:Boolean = false;
      
      private var _actor:SurvivorActor;
      
      private var _attributes:Attributes;
      
      private var _classId:String = "unassigned";
      
      private var _class:SurvivorClass;
      
      private var _firstName:String;
      
      private var _lastName:String;
      
      private var _gender:String;
      
      private var _id:String;
      
      private var _level:uint;
      
      private var _levelMax:uint;
      
      private var _morale:Morale;
      
      private var _title:String;
      
      private var _missionId:String;
      
      private var _assignmentId:String;
      
      private var _state:uint = 0;
      
      private var _moveState:String = "run";
      
      private var _moveAnim:String = "run";
      
      private var _reassignTimer:TimerData;
      
      private var _XP:int;
      
      private var _XPForNextLevel:int;
      
      private var _loadoutOffence:SurvivorLoadout;
      
      private var _loadoutDefence:SurvivorLoadout;
      
      private var _portraitURI:String;
      
      private var _task:Task;
      
      private var _rallyAssignment:Building;
      
      private var _healthModifier:Number = 1;
      
      private var _isPlayerOwned:Boolean;
      
      private var _mountedBuilding:Building;
      
      private var _voicePack:String;
      
      private var _missionIndex:int;
      
      private var _researchEffects:Object;
      
      private var _injuryList:InjuryList;
      
      private var _lastInjuryRollTime:Number = 0;
      
      private var _injuryWaiting:Boolean;
      
      public var classChanged:Signal;
      
      public var taskChanged:Signal;
      
      public var levelIncreased:Signal;
      
      public var xpIncreased:Signal;
      
      public var rallyAssignmentChanged:Signal;
      
      public var nameChanged:Signal;
      
      public var portraitChanged:Signal;
      
      public var detectedTraps:Signal;
      
      public var reassignmentStarted:Signal;
      
      public var mountedBuildingChanged:Signal;
      
      public var activeLoadoutChanged:Signal;
      
      public var accessoriesChanged:Signal;
      
      public function Survivor()
      {
         super();
         this.classChanged = new Signal(Survivor);
         this.taskChanged = new Signal(Survivor);
         this.levelIncreased = new Signal(Survivor,int);
         this.xpIncreased = new Signal(Survivor,int);
         this.rallyAssignmentChanged = new Signal(Survivor);
         this.nameChanged = new Signal(Survivor);
         this.portraitChanged = new Signal(Survivor);
         this.detectedTraps = new Signal(Survivor,Vector.<Building>);
         this.reassignmentStarted = new Signal(Survivor);
         this.mountedBuildingChanged = new Signal(Survivor,Building);
         this.activeLoadoutChanged = new Signal(Survivor);
         this.accessoriesChanged = new Signal(Survivor);
         this._attributes = new Attributes();
         this._attributes.injuryChance = Number(Config.constant.INJURY_BASE_CHANCE);
         this._injuryList = new InjuryList(this);
         this._morale = new Morale();
         this._levelMax = int(Config.constant.MAX_SURVIVOR_LEVEL);
         this._activeLoadout = null;
         this._loadoutOffence = new SurvivorLoadout(this,SurvivorLoadout.TYPE_OFFENCE);
         this._loadoutDefence = new SurvivorLoadout(this,SurvivorLoadout.TYPE_DEFENCE);
         this._accessories = new Vector.<ClothingAccessory>(Config.constant.SURVIVOR_ACCESSORY_SLOTS,true);
         this._appearance = new SurvivorAppearance(this);
         this._appearance.changed.add(this.onAppearanceChanged);
         this._actor = new SurvivorActor();
         this._actor.name = "survivor" + this._id;
         this._actor.setHitAreaSize(90,this.HIT_AREA_HEIGHT);
         entity = this._actor;
         agentData.mustHaveLOSToTarget = true;
         agentData.pursueTargets = true;
         agentData.useGuardPoint = true;
         agentData.visionRange = 4000;
         agentData.visionFOVMin = agentData.visionFOVMax = Math.PI * 1.5;
         agentData.canCauseCriticals = true;
         agentData.canSeeBehind = true;
         agentData.canBeSuppressed = true;
         navigator.mass = 5;
         damageTaken.add(this.onDamageTaken);
         movementStarted.add(this.onMovementStarted);
         movementStopped.add(this.onMovementStopped);
         addActorListeners();
         actor.addedToScene.add(this.onActorAddedToScene);
         actor.removedFromScene.add(this.onActorRemovedFromScene);
      }
      
      public static function getReassignTime(param1:Survivor) : int
      {
         var _loc2_:Vector.<Building> = Network.getInstance().playerData.compound.buildings.getBuildingsOfType("trainingCenter",false);
         if(_loc2_.length <= 0)
         {
            return 0;
         }
         var _loc3_:Building = _loc2_[0];
         var _loc4_:Number = int(Config.constant.SURVIVOR_REASSIGN_TIME_PER_LEVEL);
         var _loc5_:Number = Number(_loc3_.getLevelXML().reassign.toString());
         return int(Math.floor(param1.level * _loc4_ * _loc5_));
      }
      
      public static function getReassignCost(param1:Survivor) : int
      {
         var _loc2_:int = getReassignTime(param1);
         if(_loc2_ == 0)
         {
            return 0;
         }
         var _loc3_:Object = Network.getInstance().data.costTable.getItemByKey("SurvivorReassign");
         return Network.getInstance().data.costTable.getCostForTime(_loc3_,_loc2_);
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
         else
         {
            trace(msg);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         damageTaken.remove(this.onDamageTaken);
         movementStarted.remove(this.onMovementStarted);
         movementStopped.remove(this.onMovementStopped);
         this._classId = null;
         this._class = null;
         this._actor = null;
         this._mountedBuilding = null;
         this._activeLoadout = null;
         this._assetLoader.dispose();
         this._assetLoader = null;
         this._loadoutOffence.dispose();
         this._loadoutOffence = null;
         this._loadoutDefence.dispose();
         this._loadoutDefence = null;
         this._appearance.changed.removeAll();
         this._appearance.clear();
         this._appearance = null;
         this._attributes = null;
         this._morale = null;
         if(this._reassignTimer != null)
         {
            TimerManager.getInstance().removeTimer(this._reassignTimer);
            this._reassignTimer.dispose();
         }
         this.detectedTraps.removeAll();
         this.rallyAssignmentChanged.removeAll();
         this.classChanged.removeAll();
         this.taskChanged.removeAll();
         this.levelIncreased.removeAll();
         this.xpIncreased.removeAll();
         this.reassignmentStarted.removeAll();
         this.nameChanged.removeAll();
         this.portraitChanged.removeAll();
         this.mountedBuildingChanged.removeAll();
         this.activeLoadoutChanged.removeAll();
         this.accessoriesChanged.removeAll();
      }
      
      override public function getAnimation(param1:String) : String
      {
         switch(param1)
         {
            case "idle":
               return weapon != null ? weapon.animType + "-idle-" + agentData.stance : "idle";
            case "move":
               return weapon != null ? weapon.animType + "-" + this._moveAnim : this._moveAnim;
            case "suppressed":
               return "idle-suppressed-crouching";
            case "knock":
               if(weapon == null)
               {
                  break;
               }
               switch(weapon.weaponClass)
               {
                  case WeaponClass.PISTOL:
                  case WeaponClass.MELEE:
                     return "knockback-pistol";
                  default:
                     return "knockback-rifle";
               }
               break;
            case "hurt":
               if(weapon == null)
               {
                  break;
               }
               switch(weapon.weaponClass)
               {
                  case WeaponClass.PISTOL:
                  case WeaponClass.MELEE:
                     return "hurt-pistol";
                  default:
                     return "hurt-rifle";
               }
               break;
            case "getup":
               if(Math.random() < 0.5)
               {
                  return "knockdown-rise-back";
               }
               return "knockdown-rise-side";
         }
         return null;
      }
      
      override public function getSound(param1:String) : String
      {
         switch(param1)
         {
            case "death":
               return "sound/voices/human-death-" + this._gender + "-" + (Math.random() < 0.5 ? "1" : "2") + ".mp3";
            case "hurt":
               return "sound/voices/human-hurt-" + this._gender + "-" + (Math.random() < 0.5 ? "1" : "2") + ".mp3";
            case "exert":
               return "sound/voices/human-exert-" + this._gender + "-" + (Math.random() < 0.5 ? "1" : "2") + ".mp3";
            default:
               return null;
         }
      }
      
      public function getRawAttribute(param1:String) : Number
      {
         return this._attributes[param1] + this._level * this._class.levelAttributes[param1] * this._attributes[param1];
      }
      
      public function getAttributeWithBase(param1:String, param2:Number, param3:* = true, param4:uint = 255) : Number
      {
         var _loc11_:Number = Number(NaN);
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         var _loc9_:Number = 0;
         if(param3 === true || param3 === null)
         {
            param3 = this._activeLoadout;
         }
         _loc5_ = param3 is SurvivorLoadout ? Number(param3.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,param1)) : 0;
         if(param4 & AttributeOptions.INCLUDE_AI_EFFECTS)
         {
            _loc8_ += _effectEngine.getMultiplierForAttribute(param1);
         }
         if(Boolean(param4 & AttributeOptions.INCLUDE_EFFECTS) && this._isPlayerOwned)
         {
            _loc6_ += Network.getInstance().playerData.compound.effects.attributes.getModValue(ItemAttributes.GROUP_SURVIVOR,param1);
         }
         if(!(param4 & AttributeOptions.INCLUDE_RESEARCH))
         {
         }
         if(param1 != Attributes.HEALTH && param1 != Attributes.INJURY_CHANCE)
         {
            if(param4 & AttributeOptions.INCLUDE_MORALE)
            {
               _loc7_ = this.getMoraleValue();
            }
            if(param4 & AttributeOptions.INCLUDE_INJURIES)
            {
               _loc9_ = this._injuryList.getTotalAttributeModifier(param1);
               if(_loc9_ < Config.constant.INJURY_MIN_STAT_PERC)
               {
                  _loc9_ = Number(Config.constant.INJURY_MIN_STAT_PERC);
               }
            }
         }
         var _loc10_:Number = param2 * (1 + _loc6_) * (1 + _loc8_) * (1 + _loc9_) * (1 + _loc7_) * (1 + _loc5_);
         if(param1 == Attributes.HEALTH)
         {
            _loc10_ *= this._healthModifier;
         }
         if(param2 > 0)
         {
            _loc11_ = Number(Config.constant.SURVIVOR_ATTRIBUTE_MIN);
            if(_loc10_ < _loc11_)
            {
               _loc10_ = _loc11_;
            }
         }
         if(_loc10_ < 0)
         {
            _loc10_ = 0;
         }
         return _loc10_;
      }
      
      public function getAttribute(param1:String, param2:* = true, param3:uint = 255) : Number
      {
         return this.getAttributeWithBase(param1,this.getRawAttribute(param1),param2,param3);
      }
      
      public function getHealableHealth() : Number
      {
         return this.getAttribute(Attributes.HEALTH) - this.getInjuryDamage();
      }
      
      public function getInjuryDamage() : Number
      {
         var _loc1_:Number = this.getAttribute(Attributes.HEALTH,false,AttributeOptions.INCLUDE_NONE);
         var _loc2_:Number = this.getAttribute(Attributes.HEALTH) / _loc1_;
         var _loc3_:Number = this._injuryList.getTotalDamage();
         var _loc4_:Number = _loc1_ - _loc1_ * Config.constant.INJURY_MIN_HEALTH_PERC;
         if(_loc3_ > _loc4_)
         {
            _loc3_ = _loc4_;
         }
         return _loc3_ * _loc2_;
      }
      
      public function getWeaponPref(param1:Weapon) : Number
      {
         return this._classId == SurvivorClass.PLAYER || this._class.isSpecialisedWithWeapon(param1) ? Number(Config.constant.WEAPON_SPEC) - 1 : 0;
      }
      
      public function getXPForNextLevel() : int
      {
         var _loc1_:int = this._level + 1;
         if(_loc1_ > this._levelMax)
         {
            _loc1_ = int(this._levelMax);
         }
         return this.getXPForLevel(_loc1_);
      }
      
      public function getXPForLevel(param1:int) : int
      {
         var _loc2_:Number = Number(Config.constant.BASE_XP_MULTIPLIER);
         var _loc3_:Number = Number(Config.constant.LEVEL_XP_MULTIPLIER);
         return _loc3_ * param1 * param1 * _loc2_;
      }
      
      public function getMoraleValue() : Number
      {
         var _loc2_:Number = Number(NaN);
         var _loc1_:Number = this._morale.getClampedTotal();
         if(team == AIAgent.TEAM_PLAYER)
         {
            if(_loc1_ < 0)
            {
               _loc1_ += Math.abs(_loc1_) * Network.getInstance().playerData.researchState.getEffectValue(ResearchEffect.MoralePenalty);
            }
            _loc2_ = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("MoraleEffects")) / 100;
            _loc1_ += _loc1_ * _loc2_;
         }
         return _loc1_ / 100;
      }
      
      public function getTrapDisarmChance(param1:Building) : Number
      {
         if(this._attributes[Attributes.TRAP_DISARMING] <= 0)
         {
            return 0;
         }
         var _loc2_:Number = param1.disarmChance * this.getAttribute(Attributes.TRAP_DISARMING);
         return Math.min(_loc2_,Config.constant.MAX_TRAP_DISARM_CHANCE);
      }
      
      public function getTrapDisarmTime(param1:Building) : Number
      {
         if(this._attributes[Attributes.TRAP_DISARMING] <= 0)
         {
            return 0;
         }
         return Math.max(param1.disarmTime / this.getAttribute(Attributes.TRAP_DISARMING),Config.constant.MIN_TRAP_DISARM_TIME);
      }
      
      public function getTrapDetectRange() : Number
      {
         if(this._attributes[Attributes.TRAP_SPOTTING] <= 0)
         {
            return 0;
         }
         return Math.min(Config.constant.BASE_TRAP_DETECT_RANGE * this.getAttribute(Attributes.TRAP_SPOTTING),Config.constant.MAX_TRAP_DETECT_RANGE) * 100;
      }
      
      public function getResourceURIs() : Array
      {
         return this._appearance.getResourceURIs();
      }
      
      public function gotoIdleAnimation(param1:Boolean = false) : void
      {
         if(_dead)
         {
            return;
         }
         var _loc2_:String = this._actor.animatedAsset.currentAnimation;
         var _loc3_:String = this.getAnimation("idle");
         if(_loc2_ != null && _loc2_ == _loc3_)
         {
            return;
         }
         if(!param1)
         {
            param1 = _loc2_ != null && (_loc2_.indexOf("idle") > -1 || _loc2_.indexOf("run") > -1 || _loc2_.indexOf("walk") > -1 || _loc2_.indexOf("searching") > -1);
         }
         if(param1)
         {
            this._actor.animatedAsset.gotoAndPlay(_loc3_,0,true,0.05,0.2);
         }
         else
         {
            this._actor.animatedAsset.playWithDelay(_loc3_,0.5 + Math.random() * 2,true,0.05,0.3 + Math.random() * 0.3);
         }
      }
      
      override protected function onDie(param1:Object) : void
      {
         super.onDie(param1);
         stateMachine.setState(new ActorDeathState(this,_staticDeathAnims,_movingDeathAnims));
         if(soundSource != null && this._actor.scene != null)
         {
            soundSource.play(this.getSound("death"));
         }
      }
      
      public function saveAppearance(param1:uint) : void
      {
         var _loc2_:Object = {"id":this._id};
         if((param1 & SAVE_OPTION_APPEARANCE) != 0)
         {
            _loc2_.ap = this._appearance.serialize();
         }
         if((param1 & SAVE_OPTION_GENDER) != 0)
         {
            _loc2_.g = this._gender;
         }
         if((param1 & SAVE_OPTION_VOICE) != 0)
         {
            _loc2_.v = this._voicePack;
         }
         Network.getInstance().save(_loc2_,SaveDataMethod.SURVIVOR_EDIT);
      }
      
      public function speedUpReassignment(param1:Object, param2:Function = null) : void
      {
         var speedUpCost:int;
         var cash:int;
         var network:Network = null;
         var option:Object = param1;
         var onComplete:Function = param2;
         if(this._reassignTimer == null)
         {
            return;
         }
         network = Network.getInstance();
         speedUpCost = network.data.costTable.getCostForTime(option,this._reassignTimer.getSecondsRemaining());
         cash = network.playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
         }
         else if(!this._reassignTimer.hasEnded() && this._reassignTimer.getSecondsRemaining() > 3)
         {
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "option":option.key
            },SaveDataMethod.SURVIVOR_REASSIGN_SPEED_UP,function(param1:Object):void
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
               if(_reassignTimer != null)
               {
                  _reassignTimer.speedUpByPurchaseOption(option);
               }
               Tracking.trackEvent("SpeedUp",option.key,"reassign",int(param1.cost));
               if(onComplete != null)
               {
                  onComplete();
               }
            });
         }
      }
      
      public function switchToRun() : void
      {
         this._moveState = "run";
         this._moveAnim = "run";
         this.updateMaxSpeed();
      }
      
      public function setActiveLoadout(param1:String) : void
      {
         var _loc3_:SurvivorLoadout = null;
         var _loc2_:SurvivorLoadout = this._activeLoadout;
         switch(param1)
         {
            case SurvivorLoadout.TYPE_DEFENCE:
               _loc3_ = this._loadoutDefence;
               break;
            case SurvivorLoadout.TYPE_OFFENCE:
               _loc3_ = this._loadoutOffence;
               break;
            default:
               _loc3_ = null;
         }
         if(_loc2_ == _loc3_)
         {
            return;
         }
         if(_loc2_ != null)
         {
            _loc2_.changed.remove(this.onActiveLoadoutItemChanged);
         }
         this._activeLoadout = _loc3_;
         if(this._activeLoadout != null)
         {
            _weapon = this._activeLoadout.weapon.item as Weapon;
            _weaponData.populate(this,_weapon,this._activeLoadout.type);
            agentData.pursuitRange = weaponData.isMelee ? 750 : weaponData.range * 1.25;
            this._activeLoadout.changed.add(this.onActiveLoadoutItemChanged);
         }
         else
         {
            _weapon = null;
         }
         this.activeLoadoutChanged.dispatch(this);
      }
      
      override public function updateMaxSpeed() : void
      {
         var _loc1_:Number = Number(Config.constant.BASE_MOVEMENT_SPEED) * 100;
         var _loc2_:Number = _loc1_ * this.getAttribute(Attributes.MOVEMENT_SPEED);
         averageSpeed = _loc1_;
         navigator.maxSpeed = Math.min(_loc2_,Number(Config.constant.MAX_MOVEMENT_SPEED) * 100);
         if(_loc1_ > 500 && !speedReported)
         {
            Network.getInstance().save({
               "id":"bs",
               "val":_loc1_
            },SaveDataMethod.AH_EVENT);
            speedReported = true;
         }
      }
      
      public function switchToWalk() : void
      {
         this._moveState = "walk";
         this._moveAnim = "walking" + (this._gender == Gender.FEMALE ? "-female" : "");
         averageSpeed = 130;
         navigator.maxSpeed = averageSpeed * 1.5;
      }
      
      public function setName(param1:String) : void
      {
         this._firstName = param1;
         this._lastName = "";
         this.nameChanged.dispatch(this);
      }
      
      public function reassignClass(param1:String, param2:Boolean = false) : void
      {
         var network:Network = null;
         var busy:BusyDialogue = null;
         var self:Survivor = null;
         var newClassId:String = param1;
         var buy:Boolean = param2;
         network = Network.getInstance();
         if(network.playerData.getPlayerSurvivor() == this)
         {
            return;
         }
         if(newClassId == this._classId || newClassId == SurvivorClass.UNASSIGNED || newClassId == SurvivorClass.PLAYER || this._classId == SurvivorClass.UNASSIGNED || this._classId == SurvivorClass.PLAYER)
         {
            return;
         }
         if(network.playerData.compound.buildings.getNumBuildingsOfType("trainingCenter",false) <= 0)
         {
            return;
         }
         busy = new BusyDialogue(Language.getInstance().getString("survivor_reassigning",this.fullName));
         busy.open();
         self = this;
         network.startAsyncOp();
         network.save({
            "id":this._id,
            "buy":buy,
            "classId":newClassId
         },SaveDataMethod.SURVIVOR_REASSIGN,function(param1:Object):void
         {
            var _loc5_:TimerData = null;
            network.completeAsyncOp();
            busy.close();
            if(param1 == null)
            {
               return;
            }
            var _loc6_:*;
            switch(_loc6_)
            {
               case param1.success:
                  var _loc2_:String = param1["id"];
                  var _loc3_:String = param1["classId"];
                  if(_loc2_.toLowerCase() != _id.toLowerCase() || _loc3_.toLowerCase() != newClassId.toLowerCase())
                  {
                     return;
                  }
                  if(param1.timer != null)
                  {
                     _loc5_ = new TimerData(null,0,self);
                     _loc5_.readObject(param1["timer"]);
                     reassignTimer = _loc5_;
                  }
                  _level = int(param1["level"]);
                  _XP = int(param1["xp"]);
                  _XPForNextLevel = getXPForNextLevel();
                  var _loc4_:int = 0;
                  while(_loc4_ < _accessories.length)
                  {
                     _accessories[_loc4_] = null;
                     _loc4_++;
                  }
                  _loadoutOffence.clearItems();
                  _loadoutDefence.clearItems();
                  sClass = network.data.getSurvivorClass(_loc3_);
                  updatePortrait();
                  return;
                  break;
               case _loc6_ = param1.error,PlayerIOError.NotEnoughCoins.errorID:
                  §§push(0);
                  break;
               default:
                  §§push(1);
            }
            switch(§§pop())
            {
               case 0:
                  PaymentSystem.getInstance().openBuyCoinsScreen(true);
            }
         });
      }
      
      internal function setAccessory(param1:int, param2:ClothingAccessory) : void
      {
         if(param1 < 0 || param1 >= this._accessories.length)
         {
            return;
         }
         if(this._accessories[param1] == param2)
         {
            return;
         }
         this._accessories[param1] = param2;
         this.accessoriesChanged.dispatch(this);
      }
      
      internal function removeAccessory(param1:ClothingAccessory) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._accessories.length)
         {
            if(this._accessories[_loc2_] == param1)
            {
               this._accessories[_loc2_] = null;
               this.accessoriesChanged.dispatch(this);
               break;
            }
            _loc2_++;
         }
      }
      
      public function getAccessory(param1:int) : ClothingAccessory
      {
         if(param1 < 0 || param1 >= this._accessories.length)
         {
            return null;
         }
         return this._accessories[param1];
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         if(!param1)
         {
            param1 = {};
         }
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:TimerData = null;
         this._id = String(param1.id).toUpperCase();
         this._title = String(param1.title);
         this._firstName = param1.hasOwnProperty("firstName") ? String(param1.firstName) : "";
         this._lastName = param1.hasOwnProperty("lastName") ? String(param1.lastName) : "";
         this._gender = String(param1.gender);
         this._portraitURI = param1.portrait != null ? String(param1.portrait) : null;
         this._classId = String(param1.classId);
         this._class = Network.getInstance().data.getSurvivorClass(this._classId);
         this._attributes.readObject(this._class.baseAttributes);
         if(param1.morale)
         {
            this._morale.readObject(param1.morale);
         }
         if(param1.injuries)
         {
            this._injuryList.readObject(param1.injuries);
         }
         this._level = int(param1.level);
         this._XP = int(param1.xp);
         this._XPForNextLevel = this.getXPForNextLevel();
         if(param1.missionId != null)
         {
            this._missionId = String(param1.missionId).toUpperCase();
            this._state |= SurvivorState.ON_MISSION;
         }
         if(param1.assignmentId != null)
         {
            this._assignmentId = String(param1.assignmentId).toUpperCase();
            this._state |= SurvivorState.ON_ASSIGNMENT;
         }
         this._reassignTimer = null;
         log("param1 is: " + JSON.stringify(param1));
         if(param1.hasOwnProperty("reassignTimer"))
         {
            _loc3_ = new TimerData(null,0,this);
            _loc3_.readObject(param1.reassignTimer);
            if(!_loc3_.hasEnded())
            {
               _loc3_.data.type = "reassign";
               this.reassignTimer = _loc3_;
            }
            else
            {
               _loc3_.dispose();
            }
         }
         log("param1 after reassigntimer");
         if(param1.appearance is HumanAppearance)
         {
            this._appearance.copyFrom(HumanAppearance(param1.appearance));
         }
         else if(param1.appearance != null)
         {
            this._appearance.deserialize(this._gender,param1.appearance);
         }
         log("param1 after appearance");
         if(this._classId != SurvivorClass.UNASSIGNED && this._classId != SurvivorClass.PLAYER)
         {
            this.setApperanceToCurrentClass();
         }
         this._actor.name = "survivor" + this._id;
         this._actor.defaultScale = param1.hasOwnProperty("scale") ? Number(param1.scale) : (this._gender == Gender.FEMALE ? 1.22 : 1.25);
         this._actor.setAppearance(this._appearance);
         this._voicePack = param1.voice;
      }
      
      public function updatePortrait() : void
      {
         var self:Survivor = null;
         self = this;
         SurvivorPortrait.savePortrait(this,function():void
         {
            portraitChanged.dispatch(self);
         });
      }
      
      public function toString() : String
      {
         return "(Survivor classId=" + this._classId + ", id=" + this._id + ", firstName=" + this._firstName + ", lastName=" + this._lastName + ", gender=" + this._gender + ")";
      }
      
      public function setLevelXP(param1:int, param2:int) : void
      {
         var _loc3_:int = this._XP;
         var _loc4_:int = int(this._level);
         this._level = param2;
         this._XP = param1;
         this._XPForNextLevel = this.getXPForNextLevel();
         if(this._level > _loc4_)
         {
            this.levelIncreased.dispatch(this,this._level);
         }
         if(_loc3_ != this._XP)
         {
            this.xpIncreased.dispatch(this,this._XP);
         }
      }
      
      public function removeMissionAssets() : void
      {
         if(this._actor == null)
         {
            return;
         }
         this._actor.setRightHandItem(null);
         this._actor.animatedAsset.stop();
         this._actor.removeAnimation("models/anim/human-knockback.anim");
         this._actor.removeAnimation("models/anim/death.anim");
         if(this._activeLoadout != null)
         {
            if(this._activeLoadout.weapon.item is Weapon)
            {
               this._actor.removeAnimation("models/anim/human-weapons-" + Weapon(this._activeLoadout.weapon.item).animType + ".anim");
            }
            if(this._activeLoadout.gearActive.item is Gear)
            {
               this._actor.removeAnimation("models/anim/human-weapons-" + Gear(this._activeLoadout.gearActive.item).animType + ".anim");
            }
         }
         this._actor.refreshAnimations();
         if(this._actor.scene != null)
         {
            this._actor.assetInvalidated.dispatch(this._actor);
         }
      }
      
      public function addMissionAssets() : void
      {
         var _loc1_:Weapon = null;
         var _loc2_:Gear = null;
         if(this._actor == null)
         {
            return;
         }
         this._actor.addAnimation("models/anim/human-knockback.anim");
         this._actor.addAnimation("models/anim/death.anim");
         if(this._activeLoadout.weapon.item is Weapon)
         {
            _loc1_ = Weapon(this._activeLoadout.weapon.item);
            this._actor.setRightHandItem(_loc1_.xml.mdl.@uri.toString(),_loc1_.attachments);
            this._actor.addAnimation("models/anim/human-weapons-" + _loc1_.animType + ".anim");
         }
         if(this._activeLoadout.gearActive.item is Gear)
         {
            _loc2_ = Gear(this._activeLoadout.gearActive.item);
            this._actor.addAnimation("models/anim/human-weapons-" + _loc2_.animType + ".anim");
         }
         this._actor.refreshAnimations();
         if(this._actor.scene != null)
         {
            this._actor.assetInvalidated.dispatch(this._actor);
         }
      }
      
      internal function requestInjury(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false) : void
      {
         var method:String;
         var severityGroup:String = param1;
         var cause:String = param2;
         var force:Boolean = param3;
         var isCritical:Boolean = param4;
         this._injuryWaiting = true;
         method = team == TEAM_PLAYER ? SaveDataMethod.SURVIVOR_INJURE : SaveDataMethod.SURVIVOR_ENEMY_INJURE;
         Network.getInstance().startAsyncOp();
         Network.getInstance().save({
            "id":this._id,
            "s":severityGroup,
            "c":agentData.lastDamageCause,
            "f":force,
            "cr":isCritical
         },method,function(param1:Object):void
         {
            var injData:Object;
            var injury:Injury = null;
            var assignment:AssignmentData = null;
            var raidData:RaidData = null;
            var arenaSession:ArenaSession = null;
            var response:Object = param1;
            Network.getInstance().completeAsyncOp();
            _lastInjuryRollTime = getTimer();
            _injuryWaiting = false;
            if(response == null || response.success == false || response.srv != _id)
            {
               return;
            }
            injData = response.inj;
            if(injData == null)
            {
               return;
            }
            try
            {
               injury = new Injury();
               injury.readObject(injData);
            }
            catch(error:Error)
            {
               return;
            }
            _injuryList.addInjury(injury);
            if(_assignmentId != null && team == TEAM_PLAYER)
            {
               assignment = Network.getInstance().playerData.assignments.getById(_assignmentId);
               if(assignment != null)
               {
                  raidData = assignment as RaidData;
                  if(raidData != null)
                  {
                     try
                     {
                        Tracking.trackEvent("Raid","SurvivorInjured",assignment.name + "_" + raidData.currentStageIndex,raidData.currentStageIndex);
                     }
                     catch(error:Error)
                     {
                     }
                  }
                  arenaSession = assignment as ArenaSession;
                  if(arenaSession != null)
                  {
                     try
                     {
                        Tracking.trackEvent("Arena","SurvivorInjured",assignment.name + "_" + arenaSession.currentStageIndex,arenaSession.currentStageIndex);
                     }
                     catch(error:Error)
                     {
                     }
                  }
               }
            }
         });
      }
      
      public function rollForInjury(param1:Boolean = false) : void
      {
         if(this._injuryWaiting || agentData.lastDamageCause == null)
         {
            return;
         }
         var _loc2_:Number = getTimer();
         if(!param1 && _loc2_ - this._lastInjuryRollTime < Config.constant.INJURY_COOLDOWN * 1000)
         {
            return;
         }
         if(health > this.getAttribute(Attributes.HEALTH) * 0.5)
         {
            return;
         }
         this._lastInjuryRollTime = _loc2_;
         var _loc3_:Number = this.getAttribute(Attributes.INJURY_CHANCE) * (param1 ? Config.constant.INJURY_CRIT_CHANCE_MOD : 1);
         if(team != TEAM_PLAYER)
         {
            _loc3_ *= Number(Config.constant.INJURY_PVP_MINOR_CHANCE_MOD);
         }
         if(Math.random() > _loc3_)
         {
            return;
         }
         this.requestInjury("minor",agentData.lastDamageCause,false,param1);
      }
      
      override public function applySuppression(param1:Number, param2:Number = 0) : void
      {
         super.applySuppression(this.applySuppressionResistance(param1),param2);
      }
      
      public function applySuppressionResistance(param1:Number) : Number
      {
         var _loc2_:Number = Number(NaN);
         if(this._activeLoadout != null)
         {
            _loc2_ = 0;
            _loc2_ += this._activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"sup_res");
            _loc2_ += Network.getInstance().playerData.compound.effects.attributes.getModValue(ItemAttributes.GROUP_SURVIVOR,"sup_res");
            _loc2_ = ItemAttributes.cap("sup_res",_loc2_);
            param1 -= param1 * _loc2_;
         }
         return param1;
      }
      
      override public function applyDamageResistance(param1:Number, param2:uint) : Number
      {
         var _loc3_:String = null;
         var _loc4_:Number = Number(NaN);
         if(this._activeLoadout != null)
         {
            switch(param2)
            {
               case DamageType.EXPLOSIVE:
                  _loc3_ = "dmg_res_exp";
                  break;
               case DamageType.MELEE:
                  _loc3_ = "dmg_res_melee";
                  break;
               case DamageType.PROJECTILE:
                  _loc3_ = "dmg_res_proj";
                  break;
               case DamageType.UNKNOWN:
            }
            if(_loc3_ != null)
            {
               _loc4_ = 0;
               _loc4_ += this._activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,_loc3_);
               _loc4_ += Network.getInstance().playerData.compound.effects.attributes.getModValue(ItemAttributes.GROUP_SURVIVOR,_loc3_);
               _loc4_ = ItemAttributes.cap(_loc3_,_loc4_);
               param1 -= param1 * _loc4_;
            }
         }
         return super.applyDamageResistance(param1,param2);
      }
      
      private function setApperanceToCurrentClass() : void
      {
         if(this._classId == SurvivorClass.UNASSIGNED || this._classId == SurvivorClass.PLAYER)
         {
            return;
         }
         this._appearance.setToCurrentClass(this._gender);
      }
      
      private function addXP(param1:int) : void
      {
         var _loc2_:int = this._XP + param1;
         if(_loc2_ >= this._XPForNextLevel && this._level < this._levelMax)
         {
            ++this._level;
            _loc2_ -= this._XPForNextLevel;
            if(this._level >= this._levelMax)
            {
               this._level = this._levelMax;
               this._XP = 0;
               _loc2_ = 0;
            }
            else
            {
               this._XPForNextLevel = this.getXPForNextLevel();
               this._XP = 0;
            }
            if(_loc2_ > 0)
            {
               this._dispatchLevelUp = true;
               this.addXP(_loc2_);
               return;
            }
            this._dispatchLevelUp = false;
            this.xpIncreased.dispatch(this,this._XP);
            this.levelIncreased.dispatch(this,this._level);
         }
         else
         {
            this._XP = _loc2_;
            this.xpIncreased.dispatch(this,this._XP);
            if(this._dispatchLevelUp)
            {
               this._dispatchLevelUp = false;
               this.levelIncreased.dispatch(this,this._level);
            }
         }
      }
      
      private function onMovementStarted(param1:Survivor) : void
      {
         agentData.stance = AIAgentData.STANCE_STAND;
         agentData.coverRating = 0;
         this._actor.animatedAsset.play(this.getAnimation("move"),true);
         this._actor.setHitAreaSize(120,this.HIT_AREA_HEIGHT);
      }
      
      private function onMovementStopped(param1:Survivor) : void
      {
         this._actor.setHitAreaSize(90,this.HIT_AREA_HEIGHT);
         if(agentData.coverRating > 0)
         {
            agentData.stance = AIAgentData.STANCE_CROUCH;
         }
         this.gotoIdleAnimation();
      }
      
      private function onDamageTaken(param1:Survivor, param2:Number, param3:Object, param4:Boolean) : void
      {
         this.rollForInjury(param4);
         if(soundSource != null && this._actor.scene != null)
         {
            if(Math.random() < 0.3)
            {
               soundSource.play(this.getSound("hurt"),{"volume":0.3});
            }
         }
      }
      
      private function onActorAddedToScene(param1:GameEntity) : void
      {
         var _loc2_:String = null;
         if(weapon != null)
         {
            _loc2_ = weapon.getSound("idle");
            if(_loc2_ != null)
            {
               soundSource.play(_loc2_,{"loops":-1});
            }
         }
         if(Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickGreenSkin")) != 0)
         {
            this._appearance.skin.tint = 7320386;
         }
         this._actor.applyAppearance();
         this._actor.animatedAsset.gotoAndPlay(this.getAnimation("idle"),0,true,0.05,0);
         this.updateFootstepSoundsFromLoadout();
      }
      
      private function onActorRemovedFromScene(param1:GameEntity) : void
      {
         if(this._actor != null && this._actor.animatedAsset != null)
         {
            this._actor.animatedAsset.stop();
         }
         soundSource.stopAll();
      }
      
      private function onReassignTimerComplete(param1:TimerData) : void
      {
         this._reassignTimer = null;
         this._state &= ~SurvivorState.REASSIGNING;
      }
      
      private function onAppearanceChanged() : void
      {
         var self:Survivor = this;
         this._assetLoader.clear();
         this._assetLoader.loadingCompleted.removeAll();
         this._assetLoader.loadingCompleted.addOnce(function():void
         {
            _actor.setAppearance(_appearance);
            if(_actor.scene != null)
            {
               _actor.applyAppearance();
            }
         });
         this._assetLoader.loadAssets(this._appearance.getResourceURIs());
      }
      
      private function updateFootstepSoundsFromLoadout() : void
      {
         var _loc1_:Vector.<String> = null;
         var _loc2_:Item = null;
         var _loc3_:Item = null;
         var _loc4_:Item = null;
         var _loc5_:Vector.<String> = null;
         var _loc6_:Vector.<String> = null;
         var _loc7_:Vector.<String> = null;
         if(this._activeLoadout != null)
         {
            _loc1_ = new Vector.<String>();
            _loc2_ = this._activeLoadout.gearActive.item;
            if(_loc2_ != null)
            {
               _loc5_ = _loc2_.getSounds("footstep");
               if(_loc5_ != null)
               {
                  _loc1_ = _loc1_.concat(_loc5_);
               }
            }
            _loc3_ = this._activeLoadout.gearPassive.item;
            if(_loc3_ != null)
            {
               _loc6_ = _loc3_.getSounds("footstep");
               if(_loc6_ != null)
               {
                  _loc1_ = _loc1_.concat(_loc6_);
               }
            }
            _loc4_ = this._activeLoadout.weapon.item;
            if(_loc4_ != null)
            {
               _loc7_ = _loc4_.getSounds("footstep");
               if(_loc7_ != null)
               {
                  _loc1_ = _loc1_.concat(_loc7_);
               }
            }
            if(_loc1_.length == 0)
            {
               _footstepSounds = _defaultFootstepSounds;
            }
            else
            {
               _footstepSounds = _loc1_;
            }
         }
         else
         {
            _footstepSounds = _defaultFootstepSounds;
         }
      }
      
      private function onActiveLoadoutItemChanged() : void
      {
      }
      
      public function get statId() : String
      {
         return this._statId;
      }
      
      public function set statId(param1:String) : void
      {
         this._statId = param1;
      }
      
      public function get enemyHumanId() : String
      {
         return this._enemyHumanId;
      }
      
      public function set enemyHumanId(param1:String) : void
      {
         this._enemyHumanId = param1;
      }
      
      public function get attributes() : Attributes
      {
         return this._attributes;
      }
      
      public function get classId() : String
      {
         return this._classId;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get gender() : String
      {
         return this._gender;
      }
      
      public function set gender(param1:String) : void
      {
         this._gender = param1;
      }
      
      public function get firstName() : String
      {
         return this._firstName;
      }
      
      public function setFirstName(param1:String) : void
      {
         this._firstName = param1;
      }
      
      public function get lastName() : String
      {
         return this._lastName;
      }
      
      public function get fullName() : String
      {
         return this._firstName + (this._lastName.length ? " " + this._lastName : "");
      }
      
      public function get fullTitle() : String
      {
         return this._title + " " + this._firstName + (this._lastName.length ? " " + this._lastName : "");
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function get level() : uint
      {
         return this._level;
      }
      
      public function get levelMax() : uint
      {
         return this._levelMax;
      }
      
      public function get canHeal() : Boolean
      {
         return _health > 0 && this._attributes.healing > 0 && !(flags & AIAgentFlags.BEING_HEALED || flags & AIAgentFlags.IS_HEALING_TARGET);
      }
      
      public function get canDetectTraps() : Boolean
      {
         return _health > 0 && this._attributes.trapSpotting > 0;
      }
      
      public function get canDisarmTraps() : Boolean
      {
         return _health > 0 && this._attributes.trapDisarming > 0;
      }
      
      public function get XP() : int
      {
         return this._XP;
      }
      
      public function set XP(param1:int) : void
      {
         if(param1 < this._XP)
         {
            return;
         }
         this.addXP(param1 - this._XP);
      }
      
      override public function set health(param1:Number) : void
      {
         var _loc2_:Number = this.getHealableHealth();
         if(param1 > _loc2_)
         {
            param1 = _loc2_;
         }
         super.health = param1;
      }
      
      public function get sClass() : SurvivorClass
      {
         return this._class;
      }
      
      public function set sClass(param1:SurvivorClass) : void
      {
         if(param1 == this._class)
         {
            return;
         }
         this._class = param1;
         this._classId = this._class.id;
         this._portraitURI = null;
         this._attributes.readObject(this._class.baseAttributes);
         this.setApperanceToCurrentClass();
         this.updatePortrait();
         this.classChanged.dispatch(this);
      }
      
      public function get morale() : Morale
      {
         return this._morale;
      }
      
      public function get loadoutOffence() : SurvivorLoadout
      {
         return this._loadoutOffence;
      }
      
      public function get loadoutDefence() : SurvivorLoadout
      {
         return this._loadoutDefence;
      }
      
      public function get activeLoadout() : SurvivorLoadout
      {
         return this._activeLoadout;
      }
      
      public function get missionId() : String
      {
         return this._missionId;
      }
      
      public function set missionId(param1:String) : void
      {
         this._missionId = param1;
         if(this._missionId == null)
         {
            this._state &= ~SurvivorState.ON_MISSION;
         }
         else
         {
            this._state |= SurvivorState.ON_MISSION;
            this.task = null;
         }
      }
      
      public function get reassignTimer() : TimerData
      {
         return this._reassignTimer;
      }
      
      public function set reassignTimer(param1:TimerData) : void
      {
         if(this._reassignTimer != null)
         {
            this._reassignTimer.completed.remove(this.onReassignTimerComplete);
         }
         this._reassignTimer = param1;
         if(this._reassignTimer != null && !this._reassignTimer.hasEnded())
         {
            this._state |= SurvivorState.REASSIGNING;
            this._reassignTimer.data.type = "reassign";
            this._reassignTimer.completed.addOnce(this.onReassignTimerComplete);
            TimerManager.getInstance().addTimer(this._reassignTimer);
            this.task = null;
         }
      }
      
      public function get state() : uint
      {
         return this._state;
      }
      
      public function get assignmentId() : String
      {
         return this._assignmentId;
      }
      
      public function set assignmentId(param1:String) : void
      {
         this._assignmentId = param1;
         if(this._assignmentId == null)
         {
            this._state &= ~SurvivorState.ON_ASSIGNMENT;
         }
         else
         {
            this._state |= SurvivorState.ON_ASSIGNMENT;
            this.task = null;
         }
      }
      
      public function get task() : Task
      {
         return this._task;
      }
      
      public function set task(param1:Task) : void
      {
         var _loc2_:* = param1 != this._task;
         this._task = param1;
         if(this._task != null)
         {
            this._state |= SurvivorState.ON_TASK;
         }
         else
         {
            this._state &= ~SurvivorState.ON_TASK;
         }
         if(_loc2_)
         {
            this.taskChanged.dispatch(this);
         }
      }
      
      public function get portraitURI() : String
      {
         return this._portraitURI;
      }
      
      public function set portraitURI(param1:String) : void
      {
         this._portraitURI = param1;
      }
      
      public function get rallyAssignment() : Building
      {
         return this._rallyAssignment;
      }
      
      public function set rallyAssignment(param1:Building) : void
      {
         if(param1 == this._rallyAssignment)
         {
            return;
         }
         this._rallyAssignment = param1;
         this.rallyAssignmentChanged.dispatch(this);
      }
      
      override public function get maxHealth() : Number
      {
         return this.getAttribute(Attributes.HEALTH);
      }
      
      public function get healthModifier() : Number
      {
         return this._healthModifier;
      }
      
      public function set healthModifier(param1:Number) : void
      {
         this._healthModifier = param1;
      }
      
      public function get isPlayerOwned() : Boolean
      {
         return this._isPlayerOwned;
      }
      
      public function set isPlayerOwned(param1:Boolean) : void
      {
         this._isPlayerOwned = param1;
      }
      
      public function get mountedBuilding() : Building
      {
         return this._mountedBuilding;
      }
      
      public function set mountedBuilding(param1:Building) : void
      {
         this._mountedBuilding = param1;
         if(this._mountedBuilding != null)
         {
            _flags |= AIAgentFlags.MOUNTED;
            navigator.ignoreMap = true;
         }
         else
         {
            _flags &= ~AIAgentFlags.MOUNTED;
            navigator.ignoreMap = false;
         }
         this.mountedBuildingChanged.dispatch(this,this._mountedBuilding);
      }
      
      public function get appearance() : SurvivorAppearance
      {
         return this._appearance;
      }
      
      public function get maxClothingAccessories() : int
      {
         return this._accessories.length;
      }
      
      internal function get accessories() : Vector.<ClothingAccessory>
      {
         return this._accessories;
      }
      
      public function get injuries() : InjuryList
      {
         return this._injuryList;
      }
      
      public function get voicePack() : String
      {
         return this._voicePack;
      }
      
      public function set voicePack(param1:String) : void
      {
         this._voicePack = param1;
      }
      
      public function get missionIndex() : int
      {
         return this._missionIndex;
      }
      
      public function set missionIndex(param1:int) : void
      {
         this._missionIndex = param1;
      }
      
      public function get researchEffects() : Object
      {
         return this._researchEffects;
      }
      
      public function set researchEffects(param1:Object) : void
      {
         this._researchEffects = param1;
      }
   }
}

