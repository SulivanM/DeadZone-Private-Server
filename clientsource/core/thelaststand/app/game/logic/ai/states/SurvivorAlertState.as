package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import flash.utils.getTimer;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.game.logic.ai.AIStateMachine;
   import thelaststand.app.game.logic.ai.ThreatData;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.Map;
   
   public class SurvivorAlertState implements IAIState
   {
      
      private var _agent:Survivor;
      
      private var _stateMachine:AIStateMachine;
      
      private var _returnToGuardWaitTime:Number = 0;
      
      private var _targetForward:Vector3D;
      
      private var _pursuingTarget:Boolean;
      
      private var _idleReloadTime:Number;
      
      private var _damageTarget:AIActorAgent;
      
      private var _threat:ThreatData;
      
      private var _detectTrapsRange:Number;
      
      private var _detectTrapsInvalid:Boolean;
      
      public function SurvivorAlertState(param1:Survivor)
      {
         super();
         this._agent = param1;
         this._stateMachine = this._agent.stateMachine;
         this._targetForward = new Vector3D();
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            this._agent.damageTaken.remove(this.onDamageTaken);
            this._agent.agentData.coverRatingChanged.remove(this.onCoverRatingChanged);
            this._agent.navigator.targetUnreachable.remove(this.onTargetUnreachable);
         }
         this._agent = null;
         this._stateMachine = null;
         this._damageTarget = null;
         if(this._threat != null)
         {
            this._threat.returnToPool();
            this._threat = null;
         }
      }
      
      public function enter(param1:Number) : void
      {
         this._agent.actor.targetForward = null;
         this._agent.movementStopped.add(this.onMovementStopped);
         this._agent.damageTaken.add(this.onDamageTaken);
         this._agent.agentData.coverRatingChanged.add(this.onCoverRatingChanged);
         this._agent.navigator.targetUnreachable.add(this.onTargetUnreachable);
         this._returnToGuardWaitTime = param1;
         this._idleReloadTime = param1;
         this._pursuingTarget = false;
         this._damageTarget = null;
         this._detectTrapsRange = this._agent.getTrapDetectRange();
         this._detectTrapsInvalid = true;
         if(!this._agent.navigator.isMoving)
         {
            if(this._agent.agentData.coverRating > 0)
            {
               this._agent.agentData.stance = AIAgentData.STANCE_CROUCH;
            }
            else
            {
               this._agent.agentData.stance = AIAgentData.STANCE_STAND;
            }
            this._agent.gotoIdleAnimation();
         }
         this._agent.navigator.mode = RVOAgentMode.GROUP_ONLY;
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.navigator.targetUnreachable.remove(this.onTargetUnreachable);
         this._agent.agentData.coverRatingChanged.remove(this.onCoverRatingChanged);
         this._agent.movementStopped.remove(this.onMovementStopped);
         this._agent.damageTaken.remove(this.onDamageTaken);
         this._damageTarget = null;
         if(this._threat != null)
         {
            this._threat.returnToPool();
            this._threat = null;
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Vector3D = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Boolean = false;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Boolean = false;
         var _loc22_:Survivor = null;
         var _loc23_:int = 0;
         var _loc24_:* = false;
         var _loc25_:Number = NaN;
         if(this._threat != null)
         {
            this._threat.returnToPool();
            this._threat = null;
         }
         if(this._agent == null || this._agent.health <= 0)
         {
            return;
         }
         if(this._agent.team == AIAgent.TEAM_ENEMY && this._agent.weapon == null)
         {
            return;
         }
         if(this._agent.navigator.isMoving)
         {
            this._agent.agentData.idleTime = 0;
         }
         var _loc3_:Boolean = this._agent.navigator.waitingForPath || this._agent.navigator.isMoving || this._agent.navigator.target != null || this._agent.navigator.path != null;
         if(_loc3_)
         {
            this._detectTrapsInvalid = true;
            return;
         }
         if(this._agent.team == AIAgent.TEAM_PLAYER && this._detectTrapsInvalid && this._agent.agentData.idleTime >= Config.constant.TRAP_DETECT_IDLE_TIME)
         {
            this.detectTraps();
         }
         if(this._agent.requiresReload() && !(this._agent.flags & AIAgentFlags.RELOAD_DISABLED))
         {
            if(this._agent.reloadWeapon())
            {
               return;
            }
         }
         if(this._agent.team != AIAgent.TEAM_PLAYER)
         {
            this._agent.agentData.clearForcedTarget();
         }
         this._agent.agentData.idleTime += param1;
         var _loc4_:AIAgent = null;
         var _loc5_:Boolean = false;
         if(this._agent.agentData.target == null || this._agent.agentData.target.health <= 0)
         {
            this._agent.agentData.target = null;
            this._agent.agentData.helpingFriend = false;
            this._agent.agentData.clearForcedTarget();
            this._pursuingTarget = false;
         }
         else if(this._agent.agentData.forcedTarget != null)
         {
            this._damageTarget = null;
            _loc4_ = this._agent.agentData.forcedTarget;
            if(_loc4_ is Building)
            {
               _loc5_ = this._agent.canSeeBuilding(Building(_loc4_));
            }
            else if(_loc4_ is AIActorAgent)
            {
               if(this._agent.weaponData.isMelee)
               {
                  _loc5_ = this._agent.canSeeAgent(_loc4_);
               }
               else
               {
                  _loc5_ = this._agent.agentData.mustHaveLOSToTarget ? this._agent.checkLOSIgnoringSmoke(AIActorAgent(_loc4_)) : true;
               }
            }
            else
            {
               _loc5_ = this._agent.canSeeAgent(_loc4_);
            }
            if(!this._agent.weaponData.isMelee && !_loc5_)
            {
               this._agent.agentData.clearForcedTarget();
               _loc4_ = null;
            }
            if(this._agent.team != AIAgent.TEAM_PLAYER && getTimer() - this._agent.agentData.forcedTargetTimestamp > 1000)
            {
               this._agent.agentData.clearForcedTarget();
               _loc4_ = null;
            }
         }
         if(_loc4_ == null)
         {
            this._threat = this._agent.allowEvalThreats ? this._agent.evalThreats(this._agent.blackboard.enemies) : null;
            if(this._threat != null && this._agent.canSeeAgent(this._threat.agent))
            {
               _loc4_ = this._threat.agent;
               _loc5_ = true;
               if(this._threat.helpingFriend)
               {
                  this._agent.agentData.forceTarget(this._threat.agent);
               }
            }
            if(_loc4_ != null && this._agent.agentData.target != _loc4_)
            {
               this._agent.agentData.target = this._threat.agent;
               this._pursuingTarget = false;
            }
         }
         var _loc6_:Number = this._agent.blackboard.scene.map.cellSize;
         var _loc7_:Vector3D = this._agent.actor.transform.position;
         var _loc8_:* = true;
         var _loc9_:Number = 0;
         if(this._agent.agentData.useGuardPoint)
         {
            _loc11_ = _loc7_.x - this._agent.agentData.guardPoint.x;
            _loc12_ = _loc7_.y - this._agent.agentData.guardPoint.y;
            _loc9_ = _loc11_ * _loc11_ + _loc12_ * _loc12_;
            _loc8_ = _loc9_ < _loc6_ * _loc6_ * 2;
         }
         var _loc10_:Boolean = false;
         if(!this._agent.navigator.isMoving && _loc8_ && this._agent.requiresReload(false))
         {
            if(this._agent.agentData.target != null)
            {
               _loc13_ = this._agent.agentData.target.entity.transform.position;
               _loc14_ = _loc13_.x - _loc7_.x;
               _loc15_ = _loc13_.y - _loc7_.y;
               _loc16_ = _loc14_ * _loc14_ + _loc15_ * _loc15_;
               if(_loc16_ > this._agent.weaponData.range * this._agent.weaponData.range)
               {
                  _loc10_ = true;
               }
            }
            else
            {
               _loc10_ = true;
            }
         }
         if(_loc10_)
         {
            if(param2 - this._idleReloadTime >= Config.constant.SURVIVOR_IDLE_RELOAD_TIME * 1000 && !(this._agent.flags & AIAgentFlags.RELOAD_DISABLED))
            {
               if(this._agent.reloadWeapon())
               {
                  return;
               }
            }
         }
         else
         {
            this._idleReloadTime = param2;
         }
         if(_loc4_ != null)
         {
            if(this._agent.team == AIAgent.TEAM_ENEMY && this._agent is Survivor)
            {
               _loc22_ = Survivor(this._agent);
               if(_loc22_.firstName == "SEV")
               {
                  _loc23_ = 1;
               }
            }
            _loc17_ = this._agent.agentData.forcedTarget != null || this._threat != null && this._threat.helpingFriend;
            this._returnToGuardWaitTime = param2;
            _loc18_ = this._agent.getDistanceToTargetSq();
            _loc19_ = this._agent.weaponData.range;
            _loc20_ = this._agent.weaponData.minRange;
            if(this._agent.weaponData.isMelee && this._agent.agentData.coverRating > 0 && !(_loc4_ is Building))
            {
               _loc19_ = Math.max(_loc19_,_loc6_ * 1.4 * 3);
            }
            _loc21_ = true;
            if(_loc18_ < _loc20_ * _loc20_)
            {
               _loc21_ = false;
            }
            else if(_loc18_ >= _loc19_ * _loc19_)
            {
               if(this._agent.isPlayerOwned)
               {
                  _loc21_ = !this._agent.weaponData.isMelee && _loc17_;
               }
               else if(!_loc17_)
               {
                  if(this._agent.weaponData.isMelee || this._agent.agentData.suppressionRating <= this._agent.agentData.suppressionPoints * Config.constant.SUPPRESSED_ATTACK_PERC)
                  {
                     _loc21_ = false;
                  }
               }
            }
            if(_loc21_)
            {
               if(_loc5_ && (_loc17_ || this._agent.team == AIAgent.TEAM_ENEMY || this._agent.agentData.coverRating > 0 || _loc4_.agentData.target != null || _loc4_.agentData.targetNoise != null))
               {
                  this._pursuingTarget = false;
                  if((this._agent.autoTarget || _loc17_) && !(this._agent.flags & AIAgentFlags.TARGETING_DISABLED))
                  {
                     this._agent.attack(_loc4_);
                  }
                  return;
               }
               if(!this._agent.navigator.isMoving)
               {
                  this._pursuingTarget = false;
               }
            }
            else if(_loc17_ || this._damageTarget != null)
            {
               if(!this._pursuingTarget)
               {
                  if(!_loc17_ && this._damageTarget != null)
                  {
                     _loc4_ = this._damageTarget;
                     this._damageTarget = null;
                  }
                  if(_loc4_ is Building)
                  {
                     this.moveNextToBuilding(Building(_loc4_));
                  }
                  else
                  {
                     this.pursueTarget(_loc4_.entity.transform.position,true);
                  }
               }
               return;
            }
            if(this._pursuingTarget)
            {
               return;
            }
            if(this._agent.autoTarget && this._agent.agentData.pursueTargets && this._agent.health > this._agent.maxHealth * 0.5 && !(this._agent.flags & AIAgentFlags.IS_HEALING_TARGET || this._agent.flags & AIAgentFlags.BEING_HEALED))
            {
               _loc24_ = this._agent.agentData.coverRating <= 0;
               _loc25_ = this._agent.agentData.pursuitRange;
               if(this._agent.team == AIAgent.TEAM_ENEMY && !this._agent.weaponData.isMelee)
               {
                  _loc24_ = false;
                  _loc25_ = 0;
               }
               if(_loc24_ && _loc18_ < _loc25_ * _loc25_)
               {
                  if(this._agent.agentData.useGuardPoint)
                  {
                     if(_loc8_ || _loc4_.agentData.target != null && _loc4_.agentData.attacking)
                     {
                        this.pursueTarget(_loc4_.entity.transform.position);
                     }
                     else if(this._agent.team != AIAgent.TEAM_PLAYER)
                     {
                        this.returnToGuardPoint();
                     }
                  }
                  else
                  {
                     this.pursueTarget(_loc4_.entity.transform.position);
                  }
                  return;
               }
            }
            this._pursuingTarget = false;
            if(this._agent.agentData.coverRating <= 0)
            {
               this._targetForward.x = _loc4_.entity.transform.position.x - _loc7_.x;
               this._targetForward.y = _loc4_.entity.transform.position.y - _loc7_.y;
               this._agent.actor.targetForward = this._targetForward;
            }
            return;
         }
         if(!this._agent.navigator.isMoving && !_loc8_ && !(this._agent.flags & AIAgentFlags.IS_HEALING_TARGET || this._agent.flags & AIAgentFlags.BEING_HEALED))
         {
            if(param2 - this._returnToGuardWaitTime >= Config.constant.SURVIVOR_GUARD_PT_RETURN_TIME * 1000)
            {
               this._returnToGuardWaitTime = param2;
               this.returnToGuardPoint();
               return;
            }
         }
      }
      
      private function returnToGuardPoint() : void
      {
         if(!this._agent.agentData.useGuardPoint || this._agent.agentData.guardPoint == null)
         {
            return;
         }
         var _loc1_:Map = this._agent.actor.scene.map;
         var _loc2_:Cell = _loc1_.getCellAtCoords(this._agent.agentData.guardPoint.x,this._agent.agentData.guardPoint.y);
         this._agent.navigator.moveToPoint(this._agent.agentData.guardPoint);
         this._pursuingTarget = true;
      }
      
      private function pursueTarget(param1:Vector3D, param2:Boolean = false) : void
      {
         this._agent.navigator.followTarget(param1,this._agent.weaponData.range);
         this._pursuingTarget = true;
      }
      
      private function moveNextToBuilding(param1:Building) : void
      {
         var _loc2_:Map = this._agent.blackboard.scene.map;
         var _loc3_:Cell = _loc2_.getPassableCellAroundEntityClosestToPoint(param1.entity,this._agent.navigator.position);
         if(_loc3_ == null)
         {
            return;
         }
         this._agent.navigator.moveToCell2(_loc3_);
         this._pursuingTarget = true;
      }
      
      private function detectTraps() : void
      {
         var _loc1_:Vector.<Building> = null;
         var _loc4_:Building = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc2_:Number = this._agent.actor.transform.position.x;
         var _loc3_:Number = this._agent.actor.transform.position.y;
         for each(_loc4_ in this._agent.blackboard.traps)
         {
            if(!(!_loc4_.isTrap || _loc4_.health <= 0 || _loc4_.flags & EntityFlags.TRAP_DETECTED || Boolean(_loc4_.flags & EntityFlags.TRAP_TRIGGERED)))
            {
               _loc5_ = _loc2_ - (_loc4_.entity.transform.position.x + _loc4_.buildingEntity.centerPoint.x);
               _loc6_ = _loc3_ - (_loc4_.entity.transform.position.y + _loc4_.buildingEntity.centerPoint.y);
               _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
               _loc8_ = this._detectTrapsRange - this._detectTrapsRange * _loc4_.detectRangeModifier;
               if(_loc7_ <= _loc8_ * _loc8_)
               {
                  _loc4_.flags |= EntityFlags.TRAP_DETECTED;
                  if(_loc1_ == null)
                  {
                     _loc1_ = new Vector.<Building>();
                  }
                  _loc1_.push(_loc4_);
               }
            }
         }
         if(_loc1_ != null)
         {
            this._agent.detectedTraps.dispatch(this._agent,_loc1_);
         }
         this._detectTrapsInvalid = false;
      }
      
      private function onCoverRatingChanged() : void
      {
         if(!this._agent.navigator.isMoving)
         {
            this._agent.agentData.stance = this._agent.agentData.coverRating > 0 ? AIAgentData.STANCE_CROUCH : AIAgentData.STANCE_STAND;
            this._agent.gotoIdleAnimation();
         }
      }
      
      private function onTargetUnreachable(param1:NavigatorAgent) : void
      {
         this._pursuingTarget = false;
      }
      
      private function onMovementStopped(param1:AIActorAgent) : void
      {
         this._pursuingTarget = false;
      }
      
      private function onDamageTaken(param1:AIAgent, param2:Number, param3:Object, param4:Boolean) : void
      {
      }
   }
}

