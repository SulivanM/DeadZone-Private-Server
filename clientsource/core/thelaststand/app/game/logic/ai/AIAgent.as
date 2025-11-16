package thelaststand.app.game.logic.ai
{
   import alternativa.engine3d.core.Object3D;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.data.injury.InjuryCause;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.logic.ai.states.ActorReloadState;
   import thelaststand.app.game.logic.ai.states.TrapGunBarrelState;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.engine.audio.SoundSource3D;
   import thelaststand.engine.logic.LineOfSight;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.objects.GameEntity;
   
   public class AIAgent
   {
      
      private static var _instanceCount:int = 0;
      
      public static const TEAM_PLAYER:String = "player";
      
      public static const TEAM_ENEMY:String = "enemy";
      
      private var _isDisposed:Boolean;
      
      protected var _tmpVec1:Vector3D = new Vector3D();
      
      protected var _tmpVec2:Vector3D = new Vector3D();
      
      protected var _tmpVec3:Vector3D = new Vector3D();
      
      protected var _tmpVec4:Vector3D = new Vector3D();
      
      protected var _entity:GameEntity;
      
      protected var _stateMachine:AIStateMachine;
      
      protected var _effectEngine:AIEffectEngine;
      
      protected var _lineOfSight:LineOfSight;
      
      protected var _dead:Boolean;
      
      protected var _markedForDeath:Boolean;
      
      protected var _deathSource:Object;
      
      protected var _flags:uint = 0;
      
      protected var _noiseIdCount:int;
      
      protected var _timeElapsed:Number = 0;
      
      protected var _deltaTime:Number = 0;
      
      protected var _weapon:Weapon;
      
      protected var _weaponData:WeaponData;
      
      protected var _health:Number = 1;
      
      protected var _maxHealth:Number = 1;
      
      public var team:String;
      
      public var allowEvalThreats:Boolean = true;
      
      public var autoTarget:Boolean = true;
      
      public var blackboard:Blackboard;
      
      public var agentData:AIAgentData;
      
      public var soundSource:SoundSource3D;
      
      public var noiseGenerated:Signal;
      
      public var died:Signal;
      
      public var damageTaken:Signal;
      
      public var healthChanged:Signal;
      
      public var healingStarted:Signal;
      
      public var healingCompleted:Signal;
      
      public var reloadStarted:Signal;
      
      public var reloadCompleted:Signal;
      
      public var reloadInterrupted:Signal;
      
      public var suppressedStateChanged:Signal;
      
      public var dodgedAttack:Signal;
      
      public var missedAttack:Signal;
      
      public var killedEnemy:Signal;
      
      public function AIAgent()
      {
         super();
         this.agentData = new AIAgentData();
         this.blackboard = new Blackboard();
         this.soundSource = new SoundSource3D();
         this._stateMachine = new AIStateMachine();
         this._effectEngine = new AIEffectEngine();
         this._lineOfSight = new LineOfSight();
         this._weaponData = new WeaponData();
         this.noiseGenerated = new Signal(AIAgent,NoiseSource);
         this.healthChanged = new Signal(AIAgent);
         this.damageTaken = new Signal(AIAgent,Number,Object,Boolean);
         this.died = new Signal(AIAgent,Object);
         this.reloadStarted = new Signal(AIAgent);
         this.reloadCompleted = new Signal(AIAgent);
         this.reloadInterrupted = new Signal(AIAgent);
         this.healingStarted = new Signal(AIAgent);
         this.healingCompleted = new Signal(AIAgent);
         this.suppressedStateChanged = new Signal(AIAgent);
         this.dodgedAttack = new Signal(AIAgent);
         this.missedAttack = new Signal(AIAgent);
         this.killedEnemy = new Signal(AIAgent,AIAgent);
         this.agentData.suppressedStateChanged.add(this.onSupressionStateChanged);
      }
      
      public function attack(param1:AIAgent) : void
      {
      }
      
      public function canAttack() : Boolean
      {
         if(this.agentData.suppressed)
         {
            return false;
         }
         if(this._weapon == null || this.agentData.meleeSwinging || this.agentData.reloading || Boolean(this._flags & AIAgentFlags.HEALING))
         {
            return false;
         }
         if(this._timeElapsed - this.agentData.lastAttackTime < this._weaponData.fireRate)
         {
            return false;
         }
         if(this._weapon.isBurstFire && this._timeElapsed - this.agentData.lastBurstTime < this.agentData.burstWaitTime)
         {
            return false;
         }
         if(!this._weaponData.isMelee)
         {
            if(this._weaponData.capacity > 0 && this.weaponData.roundsInMagazine <= 0)
            {
               this.reloadWeapon();
               return false;
            }
         }
         return true;
      }
      
      public function reset() : void
      {
         this._stateMachine.clear();
         this._effectEngine.clear();
         this.blackboard.erase();
         this._weapon = null;
         this._health = 1;
         this._dead = false;
         this._flags = AIAgentFlags.NONE;
         this.team = null;
         this.allowEvalThreats = true;
      }
      
      public function die(param1:Object) : Boolean
      {
         if(this._dead || this._markedForDeath)
         {
            return false;
         }
         this._markedForDeath = true;
         this._deathSource = param1;
         this._health = 0;
         this._dead = true;
         return true;
      }
      
      protected function handleMarkedForDeath() : void
      {
         if(!this._markedForDeath)
         {
            return;
         }
         this._dead = true;
         this._markedForDeath = false;
         this._health = 0;
         this._effectEngine.clear();
         this.onDie(this._deathSource);
         this.died.dispatch(this,this._deathSource);
         this._deathSource = null;
      }
      
      protected function onDie(param1:Object) : void
      {
      }
      
      public function dispose() : void
      {
         if(this._isDisposed)
         {
            return;
         }
         this._isDisposed = true;
         this._markedForDeath = false;
         this._deathSource = null;
         this.damageTaken.removeAll();
         this.healthChanged.removeAll();
         this.died.removeAll();
         this.reloadStarted.removeAll();
         this.reloadCompleted.removeAll();
         this.reloadInterrupted.removeAll();
         this.healingStarted.removeAll();
         this.healingCompleted.removeAll();
         this.suppressedStateChanged.removeAll();
         this.dodgedAttack.removeAll();
         this.missedAttack.removeAll();
         this.killedEnemy.removeAll();
         this._stateMachine.clear();
         this._stateMachine = null;
         this._effectEngine.clear();
         this._effectEngine = null;
         this._weaponData = null;
         this._tmpVec1 = this._tmpVec2 = null;
         this._tmpVec3 = this._tmpVec4 = null;
         this._entity = null;
         this.soundSource.dispose();
         this.soundSource = null;
         this.agentData.suppressedStateChanged.remove(this.onSupressionStateChanged);
         this.agentData = null;
         this.blackboard.erase();
      }
      
      public function canSeeAgent(param1:AIAgent) : Boolean
      {
         return this.agentData.mustHaveLOSToTarget ? Boolean(this.blackboard.visibleAgents[param1]) : true;
      }
      
      public function canSeeBuilding(param1:Building) : Boolean
      {
         var _loc2_:Vector3D = this._entity.transform.position;
         this._tmpVec1.setTo(_loc2_.x,_loc2_.y,_loc2_.z + this._entity.getHeight());
         this._tmpVec2.setTo(param1.entity.transform.position.x + param1.buildingEntity.centerPoint.x,param1.entity.transform.position.y + param1.buildingEntity.centerPoint.y,param1.entity.transform.position.z + param1.buildingEntity.centerPoint.z);
         var _loc3_:Object3D = this._lineOfSight.rayCastHit(this._entity.scene,this._entity.scene.container.localToGlobal(this._tmpVec1,this._tmpVec3),this._entity.scene.container.localToGlobal(this._tmpVec2,this._tmpVec4));
         return _loc3_ == null || (_loc3_ == param1.entity.asset || param1.entity.asset.contains(_loc3_));
      }
      
      public function generateNoise(param1:Number, param2:Number = 1) : void
      {
         var _loc3_:NoiseSource = this.agentData.currentNoiseSource;
         if(_loc3_ == null || _loc3_.isDisposed || !_loc3_.position.nearEquals(this._entity.transform.position,20))
         {
            _loc3_ = new NoiseSource();
            _loc3_.id = "aiAgent_" + this._noiseIdCount++;
            this.agentData.currentNoiseSource = _loc3_;
         }
         _loc3_.time = this._timeElapsed;
         _loc3_.volume = param1;
         _loc3_.decayRateModifier = param2;
         _loc3_.position.copyFrom(this._entity.transform.position);
         BaseScene(this._entity.scene).addNoiseSource(_loc3_);
         this.noiseGenerated.dispatch(this,_loc3_);
      }
      
      public function getTargetPosition(param1:Vector3D = null) : Vector3D
      {
         var _loc3_:Vector3D = null;
         var _loc2_:Vector3D = this.agentData.target.entity.transform.position;
         if(this.agentData.target is Building)
         {
            _loc3_ = Building(this.agentData.target).buildingEntity.centerPoint;
            param1 ||= new Vector3D();
            param1.x = _loc3_.x + _loc2_.x;
            param1.y = _loc3_.y + _loc2_.z;
            param1.z = 0;
         }
         if(param1 != null)
         {
            param1.copyFrom(_loc2_);
         }
         return _loc2_;
      }
      
      public function getDistanceToTargetSq() : Number
      {
         var _loc6_:Building = null;
         var _loc7_:Vector.<Cell> = null;
         var _loc8_:Cell = null;
         if(this.agentData.target == null)
         {
            return Number.POSITIVE_INFINITY;
         }
         var _loc1_:Vector3D = null;
         var _loc2_:Vector3D = this._entity.transform.position;
         if(this._entity.scene != null && this.agentData.target is Building)
         {
            _loc6_ = Building(this.agentData.target);
            _loc7_ = this.agentData.targetBuildingTiles;
            if(_loc7_ == null)
            {
               return Number.POSITIVE_INFINITY;
            }
            _loc8_ = this._entity.scene.map.getClosestCellFromListToPoint(_loc7_,_loc2_);
            if(_loc8_ == null)
            {
               return Number.POSITIVE_INFINITY;
            }
            _loc1_ = this._entity.scene.map.getCellCoords(_loc8_.x,_loc8_.y,this._tmpVec1);
         }
         else
         {
            _loc1_ = this.agentData.target.entity.transform.position;
         }
         if(_loc1_ == null)
         {
            return Number.POSITIVE_INFINITY;
         }
         var _loc3_:Number = _loc1_.x - _loc2_.x;
         var _loc4_:Number = _loc1_.y - _loc2_.y;
         var _loc5_:Number = _loc1_.z - _loc2_.z;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_ + _loc5_ * _loc5_;
      }
      
      public function reloadWeapon() : Boolean
      {
         if(this._dead || this._health <= 0)
         {
            return false;
         }
         if(this.agentData.reloading)
         {
            return false;
         }
         if(this._weaponData.capacity == 0 || this._flags & AIAgentFlags.BEING_HEALED || Boolean(this._flags & AIAgentFlags.HEALING))
         {
            this.agentData.reloading = false;
            return false;
         }
         this.cancelBurst();
         this.agentData.attacking = false;
         return true;
      }
      
      public function requiresReload(param1:Boolean = true) : Boolean
      {
         if(this._weapon == null || this._weaponData == null || this._weaponData.isMelee)
         {
            return false;
         }
         if(this._weaponData.capacity == 0)
         {
            return false;
         }
         return param1 ? this._weaponData.roundsInMagazine <= 0 : this._weaponData.roundsInMagazine < int(this._weaponData.capacity * 0.5);
      }
      
      public function applySuppression(param1:Number, param2:Number = 0) : void
      {
         var _loc3_:Number = NaN;
         if(this._dead || this._health <= 0)
         {
            return;
         }
         if(this.agentData.reloading)
         {
            return;
         }
         if(this.agentData.coverRating > 0)
         {
            _loc3_ = param2 != 0 ? param2 : this.agentData.coverRating;
            this.agentData.suppressionRating += param1 * (1 - Math.min(1,_loc3_ / 100 * Config.constant.COVER_RATING_MULT));
         }
         else
         {
            this.agentData.suppressionRating += param1 * Config.constant.SUPPRESSION_MULT_NO_COVER;
         }
      }
      
      public function applyDamageResistance(param1:Number, param2:uint) : Number
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         return param1;
      }
      
      public function receiveDamage(param1:Number, param2:uint, param3:Object = null, param4:Boolean = false) : Number
      {
         var _loc5_:Weapon = null;
         if(param1 <= 0 || this._health <= 0)
         {
            return 0;
         }
         param1 = this.applyDamageResistance(param1,param2);
         if(param1 <= 0)
         {
            return 0;
         }
         this._health -= param1;
         this.healthChanged.dispatch(this);
         if(!this._dead)
         {
            if(param1 > 0)
            {
               if(param3 is Explosion)
               {
                  this.agentData.lastDamageCause = InjuryCause.HEAT;
               }
               else if(param3 is AIAgent)
               {
                  _loc5_ = AIAgent(param3).weapon;
                  if(_loc5_ != null)
                  {
                     this.agentData.lastDamageCause = AIAgent(param3).weapon.getInjuryCause();
                  }
                  else if(AIAgent(param3).stateMachine.state is TrapGunBarrelState)
                  {
                     this.agentData.lastDamageCause = InjuryCause.BULLET;
                  }
                  else
                  {
                     this.agentData.lastDamageCause = InjuryCause.UNKNOWN;
                  }
               }
               else
               {
                  this.agentData.lastDamageCause = InjuryCause.UNKNOWN;
               }
               this.damageTaken.dispatch(this,param1,param3,param4);
            }
            if(this._health <= 0)
            {
               this.die(param3);
            }
         }
         return param1;
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._timeElapsed = param2;
         this._deltaTime = param1;
         if(this._markedForDeath)
         {
            this.handleMarkedForDeath();
         }
         if(!this._dead)
         {
            this._effectEngine.update(param1,param2);
         }
         this._stateMachine.update(param1,param2);
         if(!this._dead)
         {
            if(this.agentData.reloading && Boolean(this._flags & AIAgentFlags.BEING_HEALED))
            {
               this.cancelReload();
            }
         }
      }
      
      public function cancelReload() : void
      {
         if(this.agentData.reloading && this.stateMachine.state is ActorReloadState)
         {
            this.stateMachine.setState(null);
         }
      }
      
      protected function cancelBurst() : void
      {
         this.agentData.burstShotCount = 0;
         this.agentData.burstShotMax = 0;
         this.agentData.burstWaitTime = 0;
      }
      
      private function onSupressionStateChanged() : void
      {
         if(this._dead || this._health <= 0)
         {
            return;
         }
         this.suppressedStateChanged.dispatch(this);
      }
      
      public function get health() : Number
      {
         return this._health;
      }
      
      public function set health(param1:Number) : void
      {
         this._health = param1 < 0 ? 0 : param1;
         if(this._health > 0)
         {
            this._dead = false;
            this._markedForDeath = false;
         }
         else if(this._health <= 0)
         {
            if(!this._dead)
            {
               this.die(null);
            }
         }
         this.healthChanged.dispatch(this);
      }
      
      public function get maxHealth() : Number
      {
         return this._maxHealth;
      }
      
      public function get stateMachine() : AIStateMachine
      {
         return this._stateMachine;
      }
      
      public function get effectEngine() : AIEffectEngine
      {
         return this._effectEngine;
      }
      
      public function get weapon() : Weapon
      {
         return this._weapon;
      }
      
      public function get flags() : uint
      {
         return this._flags;
      }
      
      public function set flags(param1:uint) : void
      {
         this._flags = param1;
      }
      
      public function get weaponData() : WeaponData
      {
         return this._weaponData;
      }
      
      public function get timeElapsed() : Number
      {
         return this._timeElapsed;
      }
      
      public function get entity() : GameEntity
      {
         return this._entity;
      }
      
      public function set entity(param1:GameEntity) : void
      {
         this._entity = param1;
      }
      
      public function get lineOfSite() : LineOfSight
      {
         return this._lineOfSight;
      }
      
      public function get isDisposed() : Boolean
      {
         return this._isDisposed;
      }
   }
}

