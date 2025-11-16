package thelaststand.app.game.logic.ai.states
{
   import flash.geom.Vector3D;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.entities.buildings.DoorBuildingEntity;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.ThreatData;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.map.TraversalArea;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.scenes.Scene;
   
   public class ZombieHuntState implements IAIState
   {
      
      private static var ahsaved:Boolean = false;
      
      private var _agent:Zombie;
      
      private var _targetPt:Vector3D;
      
      private var _atLastKnownPos:Boolean = false;
      
      private var _idleThinkTime:int = 0;
      
      private var _idleThinkStart:Number = 0;
      
      private var _lastEvalTime:Number = 0;
      
      private var _evalTime:Number = 0;
      
      private var _followingNoise:Boolean;
      
      private var _target:AIAgent;
      
      private var _secondaryCheckCounter:int = 0;
      
      private var _tmpVector:Vector3D = new Vector3D();
      
      public function ZombieHuntState(param1:Zombie)
      {
         super();
         this._agent = param1;
         this._targetPt = new Vector3D();
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            if(this._agent.navigator != null)
            {
               this._agent.navigator.targetUnreachable.remove(this.onTargetUnreachable);
               this._agent.navigator.traversalAreaReached.remove(this.onTraversalAreaReached);
               this._agent.navigator.pathRevaluationFailed.remove(this.onPathReevalationFailed);
            }
         }
         this._agent = null;
         this._targetPt = null;
         this._target = null;
      }
      
      public function enter(param1:Number) : void
      {
         this._idleThinkStart = param1;
         this._idleThinkTime = 0;
         this._lastEvalTime = param1;
         this._evalTime = 0;
         if(this._agent.agentData.target is AIActorAgent)
         {
            this._target = this._agent.agentData.target;
            this._agent.agentData.targetNoise = null;
            this._agent.getTargetPosition(this._targetPt);
            this._followingNoise = false;
         }
         else if(this._agent.agentData.targetNoise != null)
         {
            if(!this._agent.agentData.targetNoise.isDisposed)
            {
               this._agent.agentData.target = null;
               this._targetPt.copyFrom(this._agent.agentData.targetNoise.position);
               this._followingNoise = true;
            }
         }
         this._agent.navigator.pathCompleted.removeAll();
         this._agent.navigator.pathRevaluationFailed.add(this.onPathReevalationFailed);
         this._agent.navigator.targetUnreachable.add(this.onTargetUnreachable);
         this._agent.navigator.traversalAreaReached.add(this.onTraversalAreaReached);
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.navigator.pathRevaluationFailed.remove(this.onPathReevalationFailed);
         this._agent.navigator.traversalAreaReached.remove(this.onTraversalAreaReached);
         this._agent.navigator.targetUnreachable.remove(this.onTargetUnreachable);
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this._agent.health <= 0 || this._agent.agentData.target != null && this._agent.agentData.target.health <= 0)
         {
            this.endHunt();
            return;
         }
         var _loc3_:ThreatData = null;
         var _loc4_:Boolean = false;
         if(param2 - this._lastEvalTime > this._evalTime)
         {
            _loc3_ = this._agent.evalThreats(this._agent.blackboard.enemies,this._agent.blackboard.buildings);
            this._lastEvalTime = param2;
            this._evalTime = 500 + Math.random() * 2000;
            if(_loc3_ != null)
            {
               if(_loc3_.agent != null)
               {
                  if(_loc3_.agent != this._target)
                  {
                     this._target = _loc3_.agent;
                     this._agent.agentData.target = _loc3_.agent;
                     this._agent.agentData.targetNoise = null;
                     this._agent.getTargetPosition(this._targetPt);
                     this._followingNoise = false;
                     _loc4_ = true;
                  }
               }
               else if(_loc3_.noise != null)
               {
                  if(_loc3_.noise != this._agent.agentData.targetNoise)
                  {
                     this._agent.agentData.target = null;
                     this._agent.agentData.targetNoise = _loc3_.noise;
                     this._targetPt.copyFrom(_loc3_.noise.position);
                     this._followingNoise = true;
                     _loc4_ = true;
                  }
               }
               _loc3_.returnToPool();
            }
         }
         if(_loc4_)
         {
            this._atLastKnownPos = false;
            this._agent.switchToChase();
            if(this._target is Building)
            {
               this.moveToEntity(this._target.entity);
            }
            else
            {
               this._agent.navigator.followTarget(this._targetPt,this._agent.weaponData.range);
            }
            if(this._agent.navigator.waitingForPath)
            {
               return;
            }
         }
         if(this._agent.agentData.target != null)
         {
            if(this._agent.agentData.target is Building)
            {
               if(this._agent.navigator.path == null)
               {
                  if(this.tryAttack())
                  {
                     return;
                  }
                  this.secondaryCheck(true);
               }
            }
            else
            {
               if(!this._atLastKnownPos && !this._agent.canSeeAgent(this._target))
               {
                  _loc5_ = this._targetPt.x - this._agent.navigator.position.x;
                  _loc6_ = this._targetPt.y - this._agent.navigator.position.y;
                  _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
                  _loc8_ = this._agent.agentData.radius * 2;
                  if(_loc7_ < _loc8_ * _loc8_)
                  {
                     this._atLastKnownPos = true;
                     this._agent.actor.targetForward = new Vector3D(_loc5_,_loc6_,0);
                     this._agent.navigator.cancelAndStop();
                     this._agent.agentData.target = null;
                     this._agent.agentData.targetNoise = null;
                     this._target = null;
                     this._evalTime = 0;
                     return;
                  }
               }
               if(this.tryAttack())
               {
                  return;
               }
               this.secondaryCheck(true);
               this._agent.getTargetPosition(this._targetPt);
               if(!this._agent.navigator.isMoving)
               {
                  this._agent.switchToChase();
                  this._agent.navigator.followTarget(this._targetPt,this._agent.weaponData.range);
               }
            }
         }
         else if(this._agent.agentData.targetNoise != null)
         {
            this._agent.alertRating = this._agent.agentData.targetNoise.volume;
            _loc9_ = this._agent.agentData.visionRangeMin + this._agent.alertRating * 0.25;
            if(_loc9_ < this._agent.agentData.visionRangeMin)
            {
               _loc9_ = this._agent.agentData.visionRangeMin;
            }
            this._agent.agentData.visionRange = _loc9_;
            if(this._agent.agentData.targetNoise.volume <= 0)
            {
               this._followingNoise = false;
               this._agent.agentData.target = null;
               this._agent.agentData.targetNoise = null;
               this._target = null;
            }
            else if(!this._agent.navigator.isMoving && this._agent.navigator.target == null && this._agent.navigator.path == null)
            {
               this._agent.switchToChase();
               this._agent.navigator.followTarget(this._targetPt,this._agent.weaponData.range);
            }
         }
         else
         {
            this.wander(param2);
         }
      }
      
      private function wander(param1:Number) : void
      {
         var _loc2_:Cell = null;
         var _loc3_:Cell = null;
         if(param1 - this._idleThinkStart <= this._idleThinkTime)
         {
            return;
         }
         this._agent.switchToWander();
         this._idleThinkStart = param1;
         if(param1 - this._agent.spawnTime < 10000 || Math.random() < 0.5)
         {
            _loc2_ = this._agent.blackboard.scene.map.getCellAtCoords(this._agent.actor.transform.position.x,this._agent.actor.transform.position.y);
            _loc3_ = this._agent.blackboard.scene.map.getRandomPassableCellAround(_loc2_.x,_loc2_.y,10);
            if(_loc3_ != null && _loc3_ != _loc2_)
            {
               this._agent.navigator.moveToCell(_loc3_.x,_loc3_.y);
               this._agent.navigator.pathCompleted.addOnce(this.onWanderPathCompleted);
            }
            else
            {
               this._agent.navigator.cancelAndStop();
            }
            this._idleThinkTime = 5000 + Math.random() * 5000;
         }
         else
         {
            this._agent.navigator.cancelAndStop();
            this._idleThinkTime = 2000 + Math.random() * 4000;
         }
      }
      
      private function onWanderPathCompleted(param1:NavigatorAgent, param2:Path) : void
      {
         this._idleThinkTime = 0;
         this._idleThinkStart = 0;
      }
      
      private function endHunt() : void
      {
         this._agent.alertRating = 0;
         this._agent.agentData.target = null;
         this._agent.agentData.targetNoise = null;
         this._agent.stateMachine.setState(null);
      }
      
      private function tryAttack() : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:Scene = null;
         if(this._agent.agentData.target == null)
         {
            return false;
         }
         var _loc1_:* = this._agent.agentData.target is Building;
         var _loc2_:Number = this._agent.getDistanceToTargetSq();
         var _loc3_:Number = this._agent.weaponData.range;
         if(this._agent.weaponData.isMelee && _loc1_)
         {
            _loc3_ = Math.max(_loc3_,this._agent.blackboard.scene.map.cellSize * 2);
         }
         if(_loc2_ < _loc3_ * _loc3_)
         {
            _loc4_ = true;
            if(!_loc1_ && !this._agent.agentData.mustHaveLOSToTarget)
            {
               _loc5_ = this._agent.blackboard.scene;
               if(!this._agent.navigator.lineOfSight.isPointVisible(_loc5_,_loc5_.container.localToGlobal(this._agent.navigator.position),_loc5_.container.localToGlobal(this._agent.agentData.target.entity.transform.position)))
               {
                  _loc4_ = false;
               }
            }
            if(_loc4_)
            {
               this._agent.attack(this._agent.agentData.target);
               return true;
            }
         }
         return false;
      }
      
      private function secondaryCheck(param1:Boolean) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc6_:Scene = null;
         if(this._secondaryCheckCounter++ < 10 || ahsaved)
         {
            return false;
         }
         this._secondaryCheckCounter = 0;
         if(this._agent.agentData.target == null)
         {
            return false;
         }
         var _loc2_:* = this._agent.agentData.target is Building;
         var _loc3_:Number = this._agent.getDistanceToTargetSq();
         var _loc4_:Number = this._agent.weaponData.range;
         if(this._agent.weaponData.isMelee && _loc2_)
         {
            _loc4_ = Math.max(_loc4_,this._agent.blackboard.scene.map.cellSize * 2);
         }
         if(_loc3_ < _loc4_ * _loc4_)
         {
            _loc5_ = true;
            if(!_loc2_ && !this._agent.agentData.mustHaveLOSToTarget)
            {
               _loc6_ = this._agent.blackboard.scene;
               if(!this._agent.navigator.lineOfSight.isPointVisible(_loc6_,_loc6_.container.localToGlobal(this._agent.navigator.position),_loc6_.container.localToGlobal(this._agent.agentData.target.entity.transform.position)))
               {
                  _loc5_ = false;
               }
            }
            if(_loc5_)
            {
               Network.getInstance().save({"id":"passive"},SaveDataMethod.AH_EVENT);
               ahsaved = true;
               return true;
            }
         }
         return false;
      }
      
      private function moveToEntity(param1:GameEntity) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Cell = this._agent.blackboard.scene.map.getPassableCellAroundEntityClosestToPoint(param1,this._agent.navigator.position);
         if(_loc2_ == this._agent.blackboard.scene.map.getCellAtCoords2(this._agent.navigator.position))
         {
            return;
         }
         if(_loc2_ == null)
         {
            this.onTargetUnreachable(this._agent.navigator);
            return;
         }
         this._agent.navigator.moveToCell2(_loc2_);
      }
      
      private function onTraversalAreaReached(param1:NavigatorAgent, param2:int) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Cell = null;
         var _loc3_:TraversalArea = this._agent.actor.scene.map.getTraversalArea(param2);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Building = _loc3_.data;
         if(_loc4_ == null || _loc4_.dead)
         {
            return;
         }
         if(_loc4_.isDoor)
         {
            if(DoorBuildingEntity(_loc4_.buildingEntity).isOpen)
            {
               return;
            }
         }
         this._agent.navigator.cancelAndStop();
         this._evalTime = 300 + Math.random() * 2000;
         this._agent.agentData.target = _loc4_;
         var _loc5_:Vector.<Cell> = this._agent.actor.scene.map.getPassableCellsAroundEntity(_loc4_.buildingEntity,1,int.MAX_VALUE);
         while(_loc5_.length > 0)
         {
            _loc6_ = int(_loc5_.length * Math.random());
            _loc7_ = _loc5_[_loc6_];
            if(this._agent.actor.scene.map.isReachableWorld(this._agent.navigator.position,this._agent.actor.scene.map.getCellCoords(_loc7_.x,_loc7_.y,this._tmpVector)))
            {
               this._agent.navigator.moveToCell2(_loc7_);
               break;
            }
            _loc5_.splice(_loc6_,1);
         }
      }
      
      private function onTargetUnreachable(param1:NavigatorAgent) : void
      {
         this._agent.navigator.cancelAndStop();
         this._target = null;
         this._agent.agentData.target = null;
         this._agent.agentData.targetNoise = null;
         this._followingNoise = false;
         this._evalTime = 0;
         this._lastEvalTime = 0;
      }
      
      private function onPathReevalationFailed(param1:NavigatorAgent) : void
      {
         this._target = null;
         this._agent.agentData.target = null;
         this._agent.agentData.targetNoise = null;
         this._followingNoise = false;
         this._evalTime = 0;
         this._lastEvalTime = 0;
      }
   }
}

