package thelaststand.app.game.logic.navigation
{
   import com.deadreckoned.threshold.core.IDisposable;
   import com.deadreckoned.threshold.navigation.rvo.RVOAgent;
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import com.deadreckoned.threshold.ns.threshold_navigation;
   import flash.geom.Vector3D;
   import flash.system.ApplicationDomain;
   import flash.utils.getQualifiedClassName;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.engine.logic.LineOfSight;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.Map;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.map.PathfinderJob;
   import thelaststand.engine.map.PathfinderOptions;
   import thelaststand.engine.objects.GameEntity;
   
   use namespace threshold_navigation;
   
   public class NavigatorAgent extends RVOAgent implements IDisposable
   {
      
      private var _los:LineOfSight;
      
      private var _aiAgent:AIAgent;
      
      private var _moving:Boolean;
      
      private var _ignoreMap:Boolean = false;
      
      private var _map:Map;
      
      private var _losUpdateCounter:int = 0;
      
      private var _stuckTime:Number;
      
      private var _prevDistToTargetSq:Number = 0;
      
      private var _lastValidPosition:Vector3D;
      
      private var _timeOnInvalidCell:Number = 0;
      
      private var _invalidResetTime:Number = 5;
      
      private var _pathOptions:PathfinderOptions = new PathfinderOptions();
      
      private var _pathJob:PathfinderJob;
      
      private var _pathGoal:Vector3D;
      
      private var _path:Path;
      
      private var _waypointIndex:int = -1;
      
      private var _target:Vector3D;
      
      private var _targetPrevPos:Vector3D = new Vector3D();
      
      private var _targetDist:Number = 10;
      
      private var _atTarget:Boolean = false;
      
      private var _tmpVector:Vector3D = new Vector3D();
      
      private var _tmpStartCell:Cell = new Cell(-1,-1);
      
      private var _tmpGoalCell:Cell = new Cell(-1,-1);
      
      public var pathFound:Signal = new Signal(NavigatorAgent,Path);
      
      public var pathCompleted:Signal = new Signal(NavigatorAgent,Path);
      
      public var pathRevaluationFailed:Signal = new Signal(NavigatorAgent);
      
      public var targetReached:Signal = new Signal(NavigatorAgent);
      
      public var targetUnreachable:Signal = new Signal(NavigatorAgent);
      
      public var traversalAreaReached:Signal = new Signal(NavigatorAgent);
      
      public var movementStarted:Signal = new Signal(NavigatorAgent);
      
      public var movementStopped:Signal = new Signal(NavigatorAgent);
      
      public function NavigatorAgent(param1:AIAgent, param2:LineOfSight = null)
      {
         super();
         this._aiAgent = param1;
         threshold_navigation::_updatePosition = false;
         this._los = param2 || new LineOfSight();
         mass = 1;
         maxSpeed = 200;
         maxNeighbors = 6;
         neighborDistance = 200;
         timeHorizon = 0.5;
         radius = 20;
      }
      
      public function get map() : Map
      {
         return this._map;
      }
      
      public function set map(param1:Map) : void
      {
         if(this._map == param1)
         {
            return;
         }
         this.cancelAndStop();
         if(this._map != null)
         {
            this._map.changed.remove(this.onMapChanged);
         }
         this._map = param1;
         this._lastValidPosition = null;
         this._stuckTime = 0;
         if(this._map != null)
         {
            this._map.changed.add(this.onMapChanged);
         }
      }
      
      public function get path() : Path
      {
         return this._path;
      }
      
      public function get target() : Vector3D
      {
         return this._target;
      }
      
      public function get isAtTarget() : Boolean
      {
         return this._atTarget;
      }
      
      public function get hasPathOrTarget() : Boolean
      {
         return this._target != null || this._path != null;
      }
      
      public function get isMoving() : Boolean
      {
         return this._moving;
      }
      
      public function get lineOfSight() : LineOfSight
      {
         return this._los;
      }
      
      public function get aiAgent() : AIAgent
      {
         return this._aiAgent;
      }
      
      public function get ignoreMap() : Boolean
      {
         return this._ignoreMap;
      }
      
      public function set ignoreMap(param1:Boolean) : void
      {
         this._ignoreMap = param1;
      }
      
      public function get waitingForPath() : Boolean
      {
         return this._pathJob != null;
      }
      
      public function get pathOptions() : PathfinderOptions
      {
         return this._pathOptions;
      }
      
      public function dispose() : void
      {
         this.pathFound.removeAll();
         this.pathCompleted.removeAll();
         this.pathRevaluationFailed.removeAll();
         this.targetReached.removeAll();
         this.targetUnreachable.removeAll();
         this.movementStarted.removeAll();
         this.movementStopped.removeAll();
         if(this._map != null)
         {
            if(this._pathJob != null)
            {
               this._map.pathfinder.cancelJob(this._pathJob);
            }
            this._map.changed.remove(this.onMapChanged);
            this._map = null;
         }
         this._aiAgent = null;
         this._los = null;
         this._target = null;
         this._targetPrevPos = null;
         this._path = null;
         this._pathJob = null;
         this._pathGoal = null;
      }
      
      public function followPath(param1:Path) : void
      {
         this.clearTarget();
         this.clearPath();
         this.cancelPathJob();
         this._path = param1;
         if(this._path == null || this._path.numWaypoints == 0)
         {
            this.stop();
         }
         else
         {
            this._waypointIndex = 0;
            mode = RVOAgentMode.FREE;
         }
      }
      
      public function followTarget(param1:Vector3D, param2:Number = 10) : void
      {
         this.clearTarget();
         this.clearPath();
         this.cancelPathJob();
         this._target = param1;
         this._targetPrevPos.copyFrom(this._target);
         this._targetDist = param2;
         mode = RVOAgentMode.FREE;
         if(!this._ignoreMap && this._map.isReachableWorld(position,this._target,int.MAX_VALUE,param2))
         {
            this.requestPath(this._target);
         }
      }
      
      public function moveToPoint(param1:Vector3D, param2:int = 0) : void
      {
         this.clearTarget();
         this.clearPath();
         this.requestPath(param1,param2);
      }
      
      public function moveToCell(param1:int, param2:int, param3:int = 0) : void
      {
         this.clearTarget();
         this.clearPath();
         this.requestPath(this._map.getCellCoords(param1,param2,this._tmpVector));
      }
      
      public function moveToCell2(param1:Cell, param2:int = 0) : void
      {
         this.clearTarget();
         this.clearPath();
         this.requestPath(this._map.getCellCoords(param1.x,param1.y,this._tmpVector));
      }
      
      public function moveToEntity(param1:GameEntity, param2:Number = 0) : void
      {
         var _loc4_:Cell = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         this.clearTarget();
         this.clearPath();
         this.cancelPathJob();
         var _loc3_:Cell = this._map.getCellAtCoords(threshold_navigation::_position.x,threshold_navigation::_position.y);
         var _loc5_:Vector.<Cell> = this._map.getAccessibleCellsAroundEntity(param1,new <GameEntity>[this._aiAgent.entity],new <Class>[ApplicationDomain.currentDomain.getDefinition(getQualifiedClassName(this._aiAgent.entity)) as Class]);
         if(_loc5_.indexOf(_loc3_) == -1)
         {
            _loc4_ = this._map.getClosestCellFromListToPoint(_loc5_,threshold_navigation::_position);
         }
         else
         {
            _loc4_ = _loc3_;
         }
         if(_loc4_ == null)
         {
            return;
         }
         var _loc6_:Vector3D = this._map.getCellCoords(_loc4_.x,_loc4_.y);
         if(param2 > 0)
         {
            _loc7_ = threshold_navigation::_position.x - _loc6_.x;
            _loc8_ = threshold_navigation::_position.y - _loc6_.y;
            _loc9_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
            _loc6_.x += _loc7_ / _loc9_ * param2;
            _loc6_.y += _loc8_ / _loc9_ * param2;
         }
         this.requestPath(_loc6_);
      }
      
      public function setPositionToCell(param1:int, param2:int) : void
      {
         this.cancelAndStop();
         var _loc3_:Vector3D = this._map.getCellCoords(param1,param2);
         threshold_navigation::_position.x = _loc3_.x;
         threshold_navigation::_position.y = _loc3_.y;
      }
      
      public function clearPath() : void
      {
         this.pathCompleted.removeAll();
         this._path = null;
         this._waypointIndex = -1;
         this._prevDistToTargetSq = 0;
      }
      
      public function clearTarget() : void
      {
         this.targetReached.removeAll();
         this._target = null;
         this._targetDist = 0;
         this._prevDistToTargetSq = 0;
         this._atTarget = false;
      }
      
      public function cancelAndStop() : void
      {
         this.clearTarget();
         this.clearPath();
         this.cancelPathJob();
         this.stop();
      }
      
      public function stop() : void
      {
         threshold_navigation::_targetVelocity.setTo(0,0,0);
         threshold_navigation::_velocity.setTo(0,0,0);
         mode = RVOAgentMode.GROUP_ONLY;
         if(this._moving)
         {
            this._moving = false;
            this.movementStopped.dispatch(this);
         }
      }
      
      public function resume() : void
      {
         mode = RVOAgentMode.FREE;
      }
      
      override public function update(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:int = 0;
         var _loc14_:Path = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Cell = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:int = 0;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc6_:Cell = this._map.getCellAtCoords(position.x,position.y);
         if(this._path != null && this._path.numWaypoints > 0)
         {
            _loc11_ = this._losUpdateCounter == 0 && this._path.getWaypointTraversalAreaId(this._waypointIndex) == 0;
            _loc12_ = false;
            if(this._target != null)
            {
               if(_loc11_ && !this._ignoreMap && this._map.isPassableCell(_loc6_))
               {
                  if(this._map.isReachableWorld(position,this.target))
                  {
                     _loc12_ = true;
                  }
               }
            }
            if(_loc12_)
            {
               this.clearPath();
            }
            else
            {
               if(_loc11_ && this._waypointIndex < this._path.numWaypoints - 1)
               {
                  if(!this._ignoreMap && this._map.isPassableCell(_loc6_))
                  {
                     this._path.getWaypoint(this._waypointIndex + 1,this._tmpVector);
                     this._map.getCellCoords(this._tmpVector.x,this._tmpVector.y,this._tmpVector);
                     if(this._map.isReachableWorld(position,this._tmpVector,1))
                     {
                        ++this._waypointIndex;
                     }
                  }
               }
               this._path.getWaypoint(this._waypointIndex,this._tmpVector);
               this._map.getCellCoords(this._tmpVector.x,this._tmpVector.y,this._tmpVector);
               _loc2_ = this._tmpVector.x - position.x;
               _loc3_ = this._tmpVector.y - position.y;
               _loc5_ = _loc2_ * _loc2_ + _loc3_ * _loc3_;
               if(_loc5_ < 40 * 40)
               {
                  _loc13_ = this._path.getWaypointTraversalAreaId(this._waypointIndex);
                  if(_loc13_ > 0)
                  {
                     this.traversalAreaReached.dispatch(this,_loc13_);
                  }
                  if(this._path != null && ++this._waypointIndex >= this._path.numWaypoints)
                  {
                     _loc14_ = this._path;
                     if(this._target == null)
                     {
                        this.stop();
                        if(this._pathJob == null)
                        {
                           this.pathCompleted.dispatch(this,this._path);
                        }
                     }
                     if(_loc14_ == this._path)
                     {
                        this.clearPath();
                     }
                  }
               }
               else if(_loc5_ > 0)
               {
                  _loc4_ = 1 / Math.sqrt(_loc5_);
                  threshold_navigation::_targetVelocity.x += (_loc2_ * _loc4_ * maxSpeed - threshold_navigation::_targetVelocity.x) / 3;
                  threshold_navigation::_targetVelocity.y += (_loc3_ * _loc4_ * maxSpeed - threshold_navigation::_targetVelocity.y) / 3;
               }
            }
         }
         if(this._target != null)
         {
            _loc2_ = this._target.x - position.x;
            _loc3_ = this._target.y - position.y;
            _loc5_ = _loc2_ * _loc2_ + _loc3_ * _loc3_;
            if(_loc5_ < this._targetDist * this._targetDist)
            {
               if(!this._atTarget)
               {
                  this.stop();
                  this._atTarget = true;
                  this.targetReached.dispatch(this);
                  this.cancelAndStop();
               }
            }
            else if(_loc5_ > 0)
            {
               this._atTarget = false;
               _loc15_ = this._target.x - this._targetPrevPos.x;
               _loc16_ = this._target.y - this._targetPrevPos.y;
               _loc17_ = _loc15_ * _loc15_ + _loc16_ * _loc16_;
               if(this._pathJob == null && (this._path == null || _loc17_ > this._map.cellSize * this._map.cellSize))
               {
                  if(!this._ignoreMap && !this._map.isReachableWorld(position,this._target,int.MAX_VALUE,speed * 10))
                  {
                     this.requestPath(this._target);
                  }
                  else
                  {
                     _loc4_ = 1 / Math.sqrt(_loc5_);
                     threshold_navigation::_targetVelocity.x += (_loc2_ * _loc4_ * maxSpeed - threshold_navigation::_targetVelocity.x) / 3;
                     threshold_navigation::_targetVelocity.y += (_loc3_ * _loc4_ * maxSpeed - threshold_navigation::_targetVelocity.y) / 3;
                  }
               }
               this._targetPrevPos.copyFrom(this._target);
            }
         }
         if(!this._ignoreMap && (this._target != null || this._path != null) && _loc5_ > 0)
         {
            _loc18_ = _loc5_ - this._prevDistToTargetSq;
            if(_loc18_ < 0)
            {
               _loc18_ = -_loc18_;
            }
            if(_loc18_ < this._map.cellSize * this._map.cellSize * 0.5)
            {
               this._stuckTime += param1;
               if(this._stuckTime > 5)
               {
                  threshold_navigation::_targetVelocity.setTo(0,0,0);
                  threshold_navigation::_velocity.setTo(0,0,0);
                  this.targetUnreachable.dispatch(this);
                  this.cancelAndStop();
               }
            }
            else
            {
               this._stuckTime = 0;
            }
            this._prevDistToTargetSq = _loc5_;
         }
         else
         {
            this._stuckTime = 0;
            this._prevDistToTargetSq = 0;
         }
         super.update(param1);
         var _loc7_:Number = threshold_navigation::_velocity.x * threshold_navigation::_velocity.x + threshold_navigation::_velocity.y * threshold_navigation::_velocity.y;
         var _loc8_:Number = threshold_navigation::_velocity.x * param1;
         var _loc9_:Number = threshold_navigation::_velocity.y * param1;
         var _loc10_:Number = threshold_navigation::_velocity.z * param1;
         if(!this._ignoreMap)
         {
            if(_loc5_ > 0 && _loc7_ * param1 * param1 > _loc5_)
            {
               threshold_navigation::_velocity.x = _loc2_;
               threshold_navigation::_velocity.y = _loc3_;
               threshold_navigation::_velocity.z = 0;
               _loc7_ = threshold_navigation::_velocity.x * threshold_navigation::_velocity.x + threshold_navigation::_velocity.y * threshold_navigation::_velocity.y;
               _loc8_ = _loc2_;
               _loc9_ = _loc3_;
               _loc10_ = 0;
            }
            _loc19_ = position.x + _loc8_;
            _loc20_ = position.y + _loc9_;
            _loc21_ = this._map.getCellAtCoords(_loc19_,_loc20_);
            _loc22_ = 1;
            _loc23_ = 0;
            if(this._path == null)
            {
               _loc24_ = Math.PI * 0.125;
               _loc25_ = 0;
               while(!this._map.isPassableCell(_loc21_) && _loc24_ <= Math.PI * 0.5)
               {
                  _loc22_ = Math.cos(_loc24_);
                  _loc23_ = Math.sin(_loc24_);
                  _loc19_ = position.x + (_loc22_ * _loc8_ - _loc23_ * _loc9_);
                  _loc20_ = position.y + (_loc23_ * _loc8_ + _loc22_ * _loc9_);
                  _loc21_ = this._map.getCellAtCoords(_loc19_,_loc20_);
                  _loc24_ = -_loc24_;
                  if(++_loc25_ == 2)
                  {
                     _loc25_ = 0;
                     _loc24_ += Math.PI * 0.125;
                  }
               }
            }
            if(this._map.isPassableCell(_loc21_))
            {
               if(this._lastValidPosition == null)
               {
                  this._lastValidPosition = new Vector3D();
               }
               this._lastValidPosition.copyFrom(threshold_navigation::_position);
               if(this._path == null)
               {
                  _loc26_ = _loc22_ * _loc8_ - _loc23_ * _loc9_;
                  _loc27_ = _loc23_ * _loc8_ + _loc22_ * _loc9_;
                  _loc8_ = _loc26_;
                  _loc9_ = _loc27_;
               }
            }
            else if(this._path == null && this._lastValidPosition != null)
            {
               threshold_navigation::_position.copyFrom(this._lastValidPosition);
               threshold_navigation::_targetVelocity.setTo(0,0,0);
               threshold_navigation::_velocity.setTo(0,0,0);
               _loc8_ = _loc9_ = _loc10_ = 0;
            }
         }
         threshold_navigation::_position.x += _loc8_;
         threshold_navigation::_position.y += _loc9_;
         threshold_navigation::_position.z += _loc10_;
         if(_loc7_ > 2 * 2)
         {
            if(!this._moving)
            {
               this._moving = true;
               mode = RVOAgentMode.FREE;
               this.movementStarted.dispatch(this);
            }
         }
         else if(this._moving)
         {
            this._moving = false;
            mode = RVOAgentMode.GROUP_ONLY;
            this.movementStopped.dispatch(this);
         }
         if(++this._losUpdateCounter > 5)
         {
            this._losUpdateCounter = 0;
         }
      }
      
      private function requestPath(param1:Vector3D, param2:int = 0) : PathfinderJob
      {
         this.cancelPathJob();
         if(param1 == null)
         {
            return null;
         }
         this._pathGoal = param1;
         this._pathJob = this._map.findPathQueued2(param2,this._pathOptions);
         this._pathJob.started.addOnceWithPriority(this.onPathfinderJobStarted);
         this._pathJob.completed.addOnceWithPriority(this.onPathfinderJobCompleted,-1);
         this._pathJob.data = PathfinderJobType.REGULAR;
         return this._pathJob;
      }
      
      private function cancelPathJob() : void
      {
         if(this._pathJob != null)
         {
            this._map.pathfinder.cancelJob(this._pathJob);
            this._pathJob = null;
         }
      }
      
      private function onPathfinderJobStarted(param1:PathfinderJob) : void
      {
         var _loc2_:Cell = this._map.getCellAtCoords(position.x,position.y);
         if(_loc2_ == null)
         {
            this.cancelPathJob();
            return;
         }
         var _loc3_:Cell = this._map.getCellAtCoords(this._pathGoal.x,this._pathGoal.y);
         if(_loc3_ == null)
         {
            this.cancelPathJob();
            return;
         }
         this._tmpStartCell.x = _loc2_.x;
         this._tmpStartCell.y = _loc2_.y;
         this._tmpGoalCell.x = _loc3_.x;
         this._tmpGoalCell.y = _loc3_.y;
         param1.start = this._tmpStartCell;
         param1.goal = this._tmpGoalCell;
      }
      
      private function onPathfinderJobCompleted(param1:PathfinderJob) : void
      {
         if(!param1.path.found)
         {
            this.cancelPathJob();
            this.clearPath();
            this.stop();
            if(param1.data & PathfinderJobType.REEVALUATION)
            {
               this.pathRevaluationFailed.dispatch(this);
            }
            else
            {
               this.targetUnreachable.dispatch(this);
            }
         }
         else
         {
            this._path = param1.path;
            this._pathJob = null;
            this._waypointIndex = 0;
            this._prevDistToTargetSq = 0;
            this.pathFound.dispatch(this,param1.path);
            if(param1.path.numWaypoints == 0)
            {
               this.pathCompleted.dispatch(this,param1.path);
               if(param1.path == this._path)
               {
                  this.clearPath();
               }
            }
         }
      }
      
      private function onMapChanged() : void
      {
         if(this._ignoreMap || this._path == null || this._path.numWaypoints == 0 || this._pathJob != null)
         {
            return;
         }
         var _loc1_:PathfinderJob = this.requestPath(this._pathGoal);
         if(_loc1_ != null)
         {
            _loc1_.data |= PathfinderJobType.REEVALUATION;
         }
      }
   }
}

class PathfinderJobType
{
   
   public static const REGULAR:uint = 0;
   
   public static const REEVALUATION:uint = 1;
   
   public function PathfinderJobType()
   {
      super();
   }
}
