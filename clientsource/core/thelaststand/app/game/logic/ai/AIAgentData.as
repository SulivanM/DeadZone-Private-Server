package thelaststand.app.game.logic.ai
{
   import flash.geom.Vector3D;
   import flash.utils.getTimer;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.engine.map.Cell;
   
   public class AIAgentData
   {
      
      public static const STANCE_STAND:String = "standing";
      
      public static const STANCE_CROUCH:String = "crouching";
      
      private var _coverRating:int = 0;
      
      private var _target:AIAgent;
      
      private var _targetBuildingTiles:Vector.<Cell>;
      
      private var _forcedTarget:AIAgent;
      
      private var _forcedTargetTimestamp:int = 0;
      
      private var _helpTarget:AIAgent;
      
      private var _visionFOVMin:Number = 0;
      
      private var _visionFOVMinCosine:Number;
      
      private var _visionFOVMax:Number = 0;
      
      private var _visionFOVMaxCosine:Number;
      
      private var _suppressed:Boolean = false;
      
      private var _suppressionRating:Number = 0;
      
      public var guardPoint:Vector3D;
      
      public var radius:Number;
      
      public var visionRangeMin:Number;
      
      public var visionRange:Number;
      
      public var pursuitRange:Number;
      
      public var pursueTargets:Boolean;
      
      public var useGuardPoint:Boolean;
      
      public var mustHaveLOSToTarget:Boolean;
      
      public var coverEntities:Vector.<CoverEntity>;
      
      public var isZombie:Boolean = false;
      
      public var canSeeBehind:Boolean = false;
      
      public var canBeKnockedBack:Boolean = true;
      
      public var canBeSuppressed:Boolean = false;
      
      public var stance:String;
      
      public var inLOS:Boolean = true;
      
      public var currentNoiseSource:NoiseSource;
      
      public var suppressionPoints:Number = 100;
      
      public var beenSeen:Boolean = false;
      
      public var lastDamageCause:String = null;
      
      public var helpingFriend:Boolean = false;
      
      public var lastHurtTime:Number = 0;
      
      public var idleTime:Number = 0;
      
      public var talkIdleTime:Number = 0;
      
      public var threatMultiplier:Number = 1;
      
      public var lastDmgFloaterTime:Number = 0;
      
      public var lastAttackTime:Number = 0;
      
      public var accuracyBonus:Number = 0;
      
      public var attacking:Boolean;
      
      public var targetNoise:NoiseSource;
      
      public var canCauseCriticals:Boolean = true;
      
      public var canCauseBackCriticals:Boolean = true;
      
      public var waitInCover:Boolean = false;
      
      public var burstShotCount:int;
      
      public var burstShotMax:int;
      
      public var burstWaitTime:Number = 0;
      
      public var lastBurstTime:Number = 0;
      
      public var meleeSwinging:Boolean;
      
      public var lastDodgeTime:Number = 0;
      
      public var reloading:Boolean;
      
      public var reloadProgress:Number = 0;
      
      public var lastManualReload:int = 0;
      
      public var targetChanged:Signal;
      
      public var attackModeChanged:Signal;
      
      public var coverRatingChanged:Signal;
      
      public var suppressedStateChanged:Signal;
      
      public function AIAgentData()
      {
         super();
         this.guardPoint = new Vector3D();
         this.targetChanged = new Signal();
         this.attackModeChanged = new Signal();
         this.coverRatingChanged = new Signal();
         this.suppressedStateChanged = new Signal();
         this.suppressionPoints = Config.constant.SUPPRESSION_PTS;
         this.reset();
      }
      
      public function dispose() : void
      {
         this.targetChanged.removeAll();
         this.attackModeChanged.removeAll();
         this.coverEntities = null;
         this.guardPoint = null;
         this.targetNoise = null;
         this._target = this._forcedTarget = this._helpTarget = null;
         this._targetBuildingTiles = null;
         if(this.currentNoiseSource != null)
         {
            this.currentNoiseSource.dispose();
            this.currentNoiseSource = null;
         }
      }
      
      public function clearState() : void
      {
         this.guardPoint.setTo(0,0,0);
         this.inLOS = false;
         this.attacking = false;
         this.stance = STANCE_STAND;
         this.burstShotCount = 0;
         this.burstWaitTime = 0;
         this.burstShotMax = 0;
         this.idleTime = 0;
         this.talkIdleTime = 0;
         this.lastAttackTime = 0;
         this.lastHurtTime = 0;
         this.lastDmgFloaterTime = 0;
         this.lastBurstTime = 0;
         this.coverRating = 0;
         this.lastDodgeTime = 0;
         this.meleeSwinging = false;
         this.reloading = false;
         this.reloadProgress = 0;
         this.coverEntities = null;
         this.beenSeen = false;
         this.lastDamageCause = null;
         this.helpingFriend = false;
         this.suppressionRating = 0;
         this.isZombie = false;
         this.threatMultiplier = 1;
         this._target = null;
         this._forcedTarget = null;
         this._helpTarget = null;
         this._targetBuildingTiles = null;
         this.targetNoise = null;
         if(this.currentNoiseSource != null)
         {
            this.currentNoiseSource.dispose();
            this.currentNoiseSource = null;
         }
      }
      
      public function reset() : void
      {
         this.clearState();
         this.targetChanged.removeAll();
         this.attackModeChanged.removeAll();
         this.coverRatingChanged.removeAll();
         this.pursueTargets = true;
         this.useGuardPoint = false;
         this.mustHaveLOSToTarget = true;
         this.canBeKnockedBack = true;
         this.canBeSuppressed = false;
         this.canCauseCriticals = true;
         this.stance = STANCE_STAND;
         this.radius = 150;
         this.visionFOVMin = this.visionFOVMax = Math.PI * 0.9;
         this.visionRange = 2000;
         this.pursuitRange = 2000;
         this.visionRangeMin = 2000;
         this.waitInCover = false;
         this.threatMultiplier = 1;
      }
      
      public function clearForcedTarget() : void
      {
         if(this._forcedTarget != null)
         {
            this._forcedTarget.died.remove(this.onForcedTargetDead);
         }
         this._forcedTarget = null;
      }
      
      public function get currentForcedTarget() : AIAgent
      {
         return this._forcedTarget;
      }
      
      public function forceTarget(param1:AIAgent) : void
      {
         if(param1 == null || param1.health <= 0)
         {
            if(this._forcedTarget != null)
            {
               this._forcedTarget.died.remove(this.onForcedTargetDead);
            }
            this._forcedTarget = null;
         }
         else if(param1 != this._forcedTarget)
         {
            if(this._forcedTarget != null)
            {
               this._forcedTarget.died.remove(this.onForcedTargetDead);
            }
            this._forcedTarget = param1;
            this._forcedTarget.died.addOnce(this.onForcedTargetDead);
         }
         if(this._forcedTarget is Building && this._forcedTarget.entity.scene != null)
         {
            this._targetBuildingTiles = this._forcedTarget.entity.scene.map.getCellsEntityIsOccupying(this._forcedTarget.entity);
         }
         else
         {
            this._targetBuildingTiles = null;
         }
         if(this._target != this._forcedTarget)
         {
            this._forcedTargetTimestamp = getTimer();
            this._target = param1;
            this.targetChanged.dispatch();
         }
      }
      
      private function onForcedTargetDead(param1:AIAgent, param2:Object) : void
      {
         if(this._forcedTarget == param1)
         {
            this._forcedTarget = null;
            this._target = null;
         }
      }
      
      public function get coverRating() : int
      {
         return this._coverRating;
      }
      
      public function set coverRating(param1:int) : void
      {
         if(param1 == this._coverRating)
         {
            return;
         }
         this._coverRating = param1;
         this.coverRatingChanged.dispatch();
      }
      
      public function get forcedTarget() : AIAgent
      {
         return this._forcedTarget;
      }
      
      public function get forcedTargetTimestamp() : int
      {
         return this._forcedTargetTimestamp;
      }
      
      public function get visionFOVMin() : Number
      {
         return this._visionFOVMin;
      }
      
      public function set visionFOVMin(param1:Number) : void
      {
         this._visionFOVMin = param1;
         this._visionFOVMinCosine = Math.cos(this._visionFOVMin);
      }
      
      public function get visionFOVMax() : Number
      {
         return this._visionFOVMax;
      }
      
      public function set visionFOVMax(param1:Number) : void
      {
         this._visionFOVMax = param1;
         this._visionFOVMaxCosine = Math.cos(this._visionFOVMax);
      }
      
      public function get visionFOVMinCosine() : Number
      {
         return this._visionFOVMinCosine;
      }
      
      public function get visionFOVMaxCosine() : Number
      {
         return this._visionFOVMaxCosine;
      }
      
      public function get suppressed() : Boolean
      {
         return this._suppressed;
      }
      
      public function get suppressionRating() : Number
      {
         return this._suppressionRating;
      }
      
      public function set suppressionRating(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > this.suppressionPoints)
         {
            param1 = this.suppressionPoints;
         }
         this._suppressionRating = param1;
         var _loc2_:Boolean = this._suppressed;
         if(this._suppressionRating >= this.suppressionPoints)
         {
            this._suppressed = true;
         }
         else if(this._suppressionRating <= 0)
         {
            this._suppressed = false;
         }
         if(this._suppressed != _loc2_)
         {
            this.suppressedStateChanged.dispatch();
         }
      }
      
      public function get target() : AIAgent
      {
         return this._forcedTarget == null ? this._target : this._forcedTarget;
      }
      
      public function set target(param1:AIAgent) : void
      {
         if(param1 == this._target)
         {
            return;
         }
         if(this._forcedTarget != null && this._forcedTarget.health > 0)
         {
            return;
         }
         var _loc2_:* = param1 != this._target;
         this._target = param1;
         this._forcedTarget = null;
         if(this._target is Building && this._target.entity.scene != null)
         {
            this._targetBuildingTiles = this._target.entity.scene.map.getCellsEntityIsOccupying(this._target.entity);
         }
         else
         {
            this._targetBuildingTiles = null;
         }
         if(_loc2_)
         {
            this.targetChanged.dispatch();
         }
      }
      
      public function get targetBuildingTiles() : Vector.<Cell>
      {
         return this._targetBuildingTiles;
      }
   }
}

