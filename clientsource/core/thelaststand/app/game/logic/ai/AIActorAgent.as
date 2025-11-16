package thelaststand.app.game.logic.ai
{
   import com.greensock.TweenMax;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.enemies.EnemyEliteType;
   import thelaststand.app.game.entities.LOSFlags;
   import thelaststand.app.game.entities.actors.Actor;
   import thelaststand.app.game.logic.ai.states.ActorGunAttackState;
   import thelaststand.app.game.logic.ai.states.ActorHurtState;
   import thelaststand.app.game.logic.ai.states.ActorKnockbackState;
   import thelaststand.app.game.logic.ai.states.ActorKnockdownState;
   import thelaststand.app.game.logic.ai.states.ActorMeleeAttackState;
   import thelaststand.app.game.logic.ai.states.ActorReloadState;
   import thelaststand.app.game.logic.ai.states.ActorSuppressedState;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.engine.objects.GameEntity;
   
   public class AIActorAgent extends AIAgent
   {
      
      protected static var _defaultFootstepSounds:Vector.<String> = Vector.<String>(["sound/foley/footstep-1.mp3","sound/foley/footstep-2.mp3","sound/foley/footstep-3.mp3","sound/foley/footstep-4.mp3"]);
      
      private var _actor:Actor;
      
      private var _navigator:NavigatorAgent;
      
      private var _idleTime:Number = 0;
      
      private var _suppressionCooldown:Number = 0;
      
      private var _suppressionCooldownLastTime:Number = 0;
      
      private var _suppressionPrev:Number = 0;
      
      private var _buildingThreats:Vector.<Building> = new Vector.<Building>();
      
      private var _enemyId:int = -1;
      
      private var _knockbackResistance:Number = 0;
      
      private var _delayedReloadInProgress:Boolean;
      
      protected var _eliteType:uint = 0;
      
      protected var _footstepSounds:Vector.<String> = _defaultFootstepSounds;
      
      public var xp_multiplier:Number = 1;
      
      public var hp_multiplier:Number = 1;
      
      public var averageSpeed:Number = 350;
      
      public var actorClicked:Signal;
      
      public var actorMouseOver:Signal;
      
      public var actorMouseOut:Signal;
      
      public var movementStarted:Signal;
      
      public var movementStopped:Signal;
      
      public function AIActorAgent()
      {
         super();
         this._navigator = new NavigatorAgent(this,_lineOfSight);
         this._navigator.movementStarted.add(this.onNavigatorMovementStarted);
         this._navigator.movementStopped.add(this.onNavigatorMovementStopped);
         suppressedStateChanged.add(this.onSuppressedStateChanged);
         this.movementStarted = new Signal(AIAgent);
         this.movementStopped = new Signal(AIAgent);
         this.actorClicked = new Signal(AIActorAgent);
         this.actorMouseOver = new Signal(AIActorAgent);
         this.actorMouseOut = new Signal(AIActorAgent);
         reloadCompleted.add(this.onReloadComplete);
      }
      
      override public function attack(param1:AIAgent) : void
      {
         if(_dead)
         {
            return;
         }
         agentData.idleTime = 0;
         if(_weaponData.isMelee)
         {
            _stateMachine.setState(new ActorMeleeAttackState(this,param1));
         }
         else
         {
            _stateMachine.setState(new ActorGunAttackState(this,param1));
         }
      }
      
      override public function dispose() : void
      {
         if(this._actor != null)
         {
            this._actor.addedToScene.remove(this.onActorAddedToScene);
            this._actor.removedFromScene.remove(this.onActorRemovedFromScene);
            this._actor.assetClicked.remove(this.onActorClicked);
            this._actor.assetMouseOver.remove(this.onActorMouseOver);
            this._actor.assetMouseOut.remove(this.onActorMouseOut);
            if(this._actor.animatedAsset != null)
            {
               this._actor.animatedAsset.animationNotified.remove(this.onAnimationNotified);
            }
            if(this._actor.scene != null)
            {
               if(agentData.currentNoiseSource != null)
               {
                  BaseScene(this._actor.scene).removeNoiseSource(agentData.currentNoiseSource);
               }
            }
            this._actor.dispose();
            this._actor = null;
         }
         super.dispose();
         TweenMax.killDelayedCallsTo(this.reloadWeapon);
         this._delayedReloadInProgress = false;
         this.movementStarted.removeAll();
         this.movementStopped.removeAll();
         this.actorClicked.removeAll();
         this.actorMouseOver.removeAll();
         this.actorMouseOut.removeAll();
         this._navigator.dispose();
         this._navigator = null;
      }
      
      override protected function onDie(param1:Object) : void
      {
         this.actor.setInteractionBoundBoxActiveState(false);
         this.actor.animatedAsset.animSpeedMultiplier = 1;
         super.onDie(param1);
      }
      
      override public function reset() : void
      {
         this.hp_multiplier = this.xp_multiplier = 1;
         super.reset();
      }
      
      public function checkLOSToAgent(param1:AIActorAgent) : Boolean
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         if(param1 == this || param1.health <= 0 || blackboard.scene == null)
         {
            blackboard.visibleAgents[param1] = false;
            return false;
         }
         var _loc2_:Vector3D = _entity.transform.position;
         _tmpVec1.x = _loc2_.x;
         _tmpVec1.y = _loc2_.y;
         _tmpVec1.z = _loc2_.z + _entity.getHeight();
         var _loc3_:Number = blackboard.scene.visibilityRating;
         var _loc4_:Number = agentData.visionFOVMaxCosine;
         var _loc5_:Vector3D = _entity.transform.forward;
         var _loc6_:Vector3D = param1.entity.transform.position;
         var _loc7_:Number = agentData.visionRange;
         var _loc8_:Number = agentData.visionRangeMin;
         if(_loc7_ != Number.POSITIVE_INFINITY)
         {
            _loc10_ = _loc6_.x - _loc2_.x;
            _loc11_ = _loc6_.y - _loc2_.y;
            _loc12_ = _loc10_ * _loc10_ + _loc11_ * _loc11_;
            _loc13_ = _loc7_ * _loc3_;
            if(_loc13_ < _loc8_)
            {
               _loc13_ = _loc8_;
            }
            _loc14_ = _loc13_ * _loc13_;
            if(_loc12_ > _loc14_)
            {
               blackboard.visibleAgents[param1] = false;
               return false;
            }
            if(!agentData.canSeeBehind || _loc12_ > _loc14_ * 0.5)
            {
               _loc12_ = 1 / Math.sqrt(_loc12_);
               _loc10_ *= _loc12_;
               _loc11_ *= _loc12_;
               _loc15_ = _loc10_ * -_loc5_.x + _loc11_ * -_loc5_.y;
               if(_loc15_ <= 0 || _loc4_ > _loc15_)
               {
                  blackboard.visibleAgents[param1] = false;
                  return false;
               }
            }
         }
         if(agentData.mustHaveLOSToTarget)
         {
            _tmpVec2.x = _loc6_.x;
            _tmpVec2.y = _loc6_.y;
            _tmpVec2.z = _loc6_.z + param1.entity.getHeight() + 80;
            if(!_lineOfSight.isPointVisible(_entity.scene,_entity.scene.container.localToGlobal(_tmpVec1,_tmpVec3),_entity.scene.container.localToGlobal(_tmpVec2,_tmpVec4)))
            {
               blackboard.visibleAgents[param1] = false;
               return false;
            }
         }
         param1.agentData.inLOS = true;
         param1.agentData.beenSeen = true;
         blackboard.visibleAgents[param1] = true;
         var _loc9_:Vector3D = blackboard.lastKnownAgentPos[param1];
         if(_loc9_ == null)
         {
            _loc9_ = new Vector3D();
            blackboard.lastKnownAgentPos[param1] = _loc9_;
         }
         _loc9_.copyFrom(param1.navigator.position);
         return true;
      }
      
      public function checkLOSIgnoringSmoke(param1:AIActorAgent) : Boolean
      {
         var _loc2_:Vector3D = _entity.transform.position;
         _tmpVec1.x = _loc2_.x;
         _tmpVec1.y = _loc2_.y;
         _tmpVec1.z = _loc2_.z + _entity.getHeight();
         var _loc3_:Vector3D = param1.entity.transform.position;
         _tmpVec2.x = _loc3_.x;
         _tmpVec2.y = _loc3_.y;
         _tmpVec2.z = _loc3_.z + param1.entity.getHeight() + 80;
         return _lineOfSight.isPointVisible(_entity.scene,_entity.scene.container.localToGlobal(_tmpVec1,_tmpVec3),_entity.scene.container.localToGlobal(_tmpVec2,_tmpVec4),LOSFlags.ALL ^ LOSFlags.SMOKE);
      }
      
      public function checkLOSToAgents(param1:Vector.<AIActorAgent>) : void
      {
         var _loc2_:AIActorAgent = null;
         for each(_loc2_ in param1)
         {
            this.checkLOSToAgent(_loc2_);
         }
      }
      
      public function evalThreats(param1:Vector.<AIActorAgent>, param2:Vector.<Building> = null) : ThreatData
      {
         return null;
      }
      
      public function getAnimation(param1:String) : String
      {
         return null;
      }
      
      public function getSound(param1:String) : String
      {
         return null;
      }
      
      public function hurt(param1:Number) : void
      {
         if(health <= 0)
         {
            return;
         }
         if(Boolean(flags & AIAgentFlags.BEING_HEALED) || Boolean(flags & AIAgentFlags.IS_HEALING_TARGET))
         {
            return;
         }
         if(this.isImmobilized())
         {
            return;
         }
         _stateMachine.setState(new ActorHurtState(this));
      }
      
      public function knockback(param1:Vector3D, param2:Number, param3:Number = 0, param4:uint = 0, param5:Object = null) : Boolean
      {
         if(health <= 0 || !agentData.canBeKnockedBack || agentData.coverRating > 0)
         {
            return false;
         }
         if(Boolean(flags & AIAgentFlags.BEING_HEALED) || Boolean(flags & AIAgentFlags.IS_HEALING_TARGET))
         {
            return false;
         }
         if(this._knockbackResistance > 0 && !isNaN(this._knockbackResistance))
         {
            if(this._knockbackResistance >= 1)
            {
               return false;
            }
            if(Math.random() < this._knockbackResistance)
            {
               return false;
            }
         }
         if(_stateMachine.state is ActorKnockdownState)
         {
            return false;
         }
         _stateMachine.setState(new ActorKnockbackState(this,param1,param2,param3,param4,param5));
         return true;
      }
      
      public function knockdown(param1:Vector3D, param2:Number) : Boolean
      {
         if(health <= 0)
         {
            return false;
         }
         if(Boolean(flags & AIAgentFlags.BEING_HEALED) || Boolean(flags & AIAgentFlags.IS_HEALING_TARGET))
         {
            return false;
         }
         if(_stateMachine.state is ActorKnockdownState)
         {
            return false;
         }
         _stateMachine.setState(new ActorKnockdownState(this,param1,param2));
         return true;
      }
      
      public function updateMaxSpeed() : void
      {
         throw new Error("This method should be overridden by subclasses.");
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         super.update(param1,param2);
         if(this._suppressionPrev >= agentData.suppressionRating)
         {
            _loc3_ = (param2 - this._suppressionCooldownLastTime) / 1000;
            this._suppressionCooldown += _loc3_;
            if(this._suppressionCooldown > Number(Config.constant.SUPPRESSION_COOLDOWN))
            {
               agentData.suppressionRating -= agentData.suppressionPoints * Config.constant.SUPPRESSION_DECAY * _loc3_;
            }
            this._suppressionCooldownLastTime = param2;
         }
         else
         {
            this._suppressionCooldown = 0;
         }
         this._suppressionPrev = agentData.suppressionRating;
         if(!_dead && this._navigator.isMoving)
         {
            _loc4_ = this._navigator.speedSq;
            if(_loc4_ > 0)
            {
               this.actor.targetForward = this._navigator.velocity;
               if(!agentData.attacking && !agentData.reloading && this.actor.animatedAsset != null)
               {
                  this.actor.animatedAsset.animSpeedMultiplier = Math.sqrt(_loc4_) / this._navigator.maxSpeed * (this._navigator.maxSpeed / this.averageSpeed);
               }
            }
            else
            {
               this.actor.targetForward = null;
            }
         }
         else
         {
            this._idleTime += param1;
         }
         this.actor.updateTransform(param1);
      }
      
      public function isImmobilized() : Boolean
      {
         return _stateMachine.state is ActorKnockdownState || _stateMachine.state is ActorKnockbackState || _stateMachine.state is ActorHurtState;
      }
      
      override public function reloadWeapon() : Boolean
      {
         TweenMax.killDelayedCallsTo(this.reloadWeapon);
         this._delayedReloadInProgress = false;
         if(!super.reloadWeapon())
         {
            return false;
         }
         if(this.isImmobilized())
         {
            return false;
         }
         stateMachine.setState(new ActorReloadState(this));
         return true;
      }
      
      protected function addActorListeners() : void
      {
         if(this.actor == null)
         {
            return;
         }
         this.actor.addedToScene.add(this.onActorAddedToScene);
         this.actor.removedFromScene.add(this.onActorRemovedFromScene);
         this.actor.assetClicked.add(this.onActorClicked);
         this.actor.assetMouseOver.add(this.onActorMouseOver);
         this.actor.assetMouseOut.add(this.onActorMouseOut);
         this.actor.animatedAsset.animationNotified.add(this.onAnimationNotified);
      }
      
      protected function getFootstepSoundUri() : String
      {
         if(this._footstepSounds == null || this._footstepSounds.length == 0)
         {
            return null;
         }
         var _loc1_:int = int(Math.random() * this._footstepSounds.length);
         return this._footstepSounds[_loc1_];
      }
      
      private function onActorAddedToScene(param1:Actor) : void
      {
         if(param1.scene != null)
         {
            param1.scene.addEntity(soundSource);
         }
      }
      
      private function onActorRemovedFromScene(param1:Actor) : void
      {
         if(soundSource.scene != null)
         {
            soundSource.scene.removeEntity(soundSource);
         }
      }
      
      private function onActorClicked(param1:Actor) : void
      {
         this.actorClicked.dispatch(this);
      }
      
      private function onActorMouseOver(param1:Actor) : void
      {
         this.actorMouseOver.dispatch(this);
      }
      
      private function onActorMouseOut(param1:Actor) : void
      {
         this.actorMouseOut.dispatch(this);
      }
      
      private function onReloadComplete(param1:AIActorAgent) : void
      {
         if(agentData.suppressed && !(flags & AIAgentFlags.IMMOVEABLE))
         {
            _stateMachine.setState(new ActorSuppressedState(this));
            return;
         }
         if(agentData.target == null || agentData.stance == AIAgentData.STANCE_CROUCH)
         {
            this.actor.animatedAsset.play(this.getAnimation("idle"),true,0.05,0.5);
         }
         else
         {
            this.actor.animatedAsset.play(weapon.animType + "-threat-" + agentData.stance,true,0.25);
         }
      }
      
      private function onNavigatorMovementStarted(param1:NavigatorAgent) : void
      {
         if(_health < 0)
         {
            return;
         }
         _flags &= ~AIAgentFlags.IS_HEALING_TARGET;
         _flags &= ~AIAgentFlags.BEING_HEALED;
         agentData.meleeSwinging = false;
         agentData.attacking = false;
         cancelReload();
         this._idleTime = 0;
         this.movementStarted.dispatch(this);
      }
      
      private function onNavigatorMovementStopped(param1:NavigatorAgent) : void
      {
         this.movementStopped.dispatch(this);
         if(_health < 0)
         {
            return;
         }
         if(agentData.suppressed && !(flags & AIAgentFlags.IMMOVEABLE))
         {
            _stateMachine.setState(new ActorSuppressedState(this));
         }
      }
      
      private function onSuppressedStateChanged(param1:AIActorAgent) : void
      {
         if(agentData.suppressed && !this._navigator.isMoving)
         {
            _stateMachine.setState(new ActorSuppressedState(this));
         }
      }
      
      protected function onAnimationNotified(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         switch(param2)
         {
            case "footL":
            case "footR":
               _loc3_ = this.getFootstepSoundUri();
               if(Boolean(_loc3_) && this.actor.scene != null)
               {
                  soundSource.play(_loc3_,{"volume":0.15});
               }
         }
      }
      
      public function get actor() : Actor
      {
         return this._actor;
      }
      
      override public function set entity(param1:GameEntity) : void
      {
         if(param1 != null && !(param1 is Actor))
         {
            throw new Error("Entity must be of type Actor for AIActorAgent.");
         }
         _entity = param1;
         this._actor = param1 as Actor;
         if(this._actor != null)
         {
            this._navigator.position = this._actor.transform.position;
            soundSource.position = this._actor.transform.position;
         }
      }
      
      public function get navigator() : NavigatorAgent
      {
         return this._navigator;
      }
      
      public function get idleTime() : Number
      {
         return this._idleTime;
      }
      
      public function get isElite() : Boolean
      {
         return this._eliteType != EnemyEliteType.NONE;
      }
      
      public function get eliteType() : uint
      {
         return this._eliteType;
      }
      
      public function get enemyId() : int
      {
         return this._enemyId;
      }
      
      public function set enemyId(param1:int) : void
      {
         this._enemyId = param1;
      }
      
      public function get knockbackResistance() : Number
      {
         return this._knockbackResistance;
      }
      
      public function set knockbackResistance(param1:Number) : void
      {
         this._knockbackResistance = param1;
      }
   }
}

