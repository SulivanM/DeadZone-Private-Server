package thelaststand.engine.map
{
   import com.deadreckoned.threshold.core.IDisposable;
   import com.deadreckoned.threshold.data.Graph;
   import com.deadreckoned.threshold.data.ObjectPool;
   import de.polygonal.ds.Iterator;
   import de.polygonal.ds.PriorityQueue;
   import flash.utils.Dictionary;
   
   public class Pathfinder implements IDisposable
   {
      
      public static const NONE:uint = 0;
      
      public static const CLOSEST_NODE:uint = 1;
      
      private var _defaultOptions:PathfinderOptions = new PathfinderOptions();
      
      private var _nodePool:ObjectPool;
      
      private var _jobPool:ObjectPool;
      
      private var _jobQueue:PriorityQueue;
      
      private var _open:PriorityQueue;
      
      private var _status:Dictionary;
      
      private var _costScale:int = 1000;
      
      public function Pathfinder(param1:int, param2:int = 40)
      {
         super();
         this._nodePool = new ObjectPool(PathNode,Math.min(param1,1000),10);
         this._jobPool = new ObjectPool(PathfinderJob,param2,1);
         this._jobQueue = new PriorityQueue(param2);
         this._open = new PriorityQueue(param1);
      }
      
      public function dispose() : void
      {
         this.clearJobQueue();
         this._nodePool.dispose();
         this._jobPool.dispose();
         this._open.clear();
         this._status = null;
      }
      
      public function clearJobQueue() : void
      {
         var _loc1_:Iterator = this._jobQueue.getIterator();
         var _loc2_:PathfinderJob = _loc1_.data;
         while(_loc2_ != null)
         {
            _loc2_.reset();
            _loc2_ = _loc1_.next();
         }
         this._jobQueue.clear();
      }
      
      public function executeJobQueue(param1:int) : void
      {
         var _loc3_:PathfinderJob = null;
         var _loc2_:int = 0;
         while(this._jobQueue.size > 0 && _loc2_ < param1)
         {
            _loc3_ = PathfinderJob(this._jobQueue.dequeue());
            if(!_loc3_._cancelled && !_loc3_._completed)
            {
               _loc3_.started.dispatch(_loc3_);
               if(!_loc3_._cancelled)
               {
                  _loc3_.path = this.findPath(_loc3_.graph,_loc3_.start,_loc3_.goal,_loc3_.options);
                  _loc3_._completed = true;
                  _loc3_.completed.dispatch(_loc3_);
               }
               _loc2_++;
            }
            this._jobPool.put(_loc3_);
         }
      }
      
      public function queueJob(param1:Graph, param2:Cell, param3:Cell, param4:int = 0, param5:PathfinderOptions = null) : PathfinderJob
      {
         var _loc6_:PathfinderJob = PathfinderJob(this._jobPool.get()).reset();
         _loc6_.priority = param4;
         _loc6_.graph = param1;
         _loc6_.start = param2;
         _loc6_.goal = param3;
         _loc6_.options = param5;
         this._jobQueue.enqueue(_loc6_);
         return _loc6_;
      }
      
      public function cancelJob(param1:PathfinderJob) : void
      {
         if(param1._cancelled || param1._completed)
         {
            return;
         }
         if(this._jobQueue.contains(param1))
         {
            param1._cancelled = true;
            param1.cancelled.dispatch(param1);
            param1.completed.removeAll();
            param1.started.removeAll();
         }
      }
      
      public function findPath(param1:Graph, param2:Cell, param3:Cell, param4:PathfinderOptions = null) : Path
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:PathNode = null;
         var _loc9_:PathNode = null;
         var _loc12_:PathNode = null;
         var _loc13_:NavEdge = null;
         var _loc14_:Cell = null;
         var _loc15_:Number = NaN;
         var _loc16_:PathNode = null;
         var _loc17_:int = 0;
         var _loc18_:Vector.<int> = null;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc10_:Path = new Path();
         if(param1 == null || param2 == null || param3 == null)
         {
            return _loc10_;
         }
         var _loc11_:int = param3.cost + param3.penaltyCost;
         if(_loc11_ == 0)
         {
            return _loc10_;
         }
         param4 ||= this._defaultOptions;
         this._status = new Dictionary(true);
         this._open.clear();
         _loc8_ = PathNode(this._nodePool.get()).reset();
         _loc8_.node = param2;
         this._status[param2] = _loc8_;
         this._open.enqueue(_loc8_);
         while(this._open.size > 0)
         {
            _loc8_ = PathNode(this._open.dequeue());
            _loc8_.closed = true;
            if(_loc8_.node == param3)
            {
               _loc10_.found = true;
               break;
            }
            _loc13_ = NavEdge(_loc8_.node.edgeList);
            for(; _loc13_ != null; _loc13_ = NavEdge(_loc13_.next))
            {
               _loc14_ = Cell(_loc13_.node);
               if(!(Boolean(_loc14_.flags & CellFlag.DISABLED) || Boolean(_loc13_.flags & NavEdgeFlag.DISABLED)))
               {
                  if((_loc14_.flags & ~param4.nodeFlagMask) == 0)
                  {
                     if((_loc13_.flags & ~param4.edgeFlagMask) == 0)
                     {
                        _loc11_ = _loc14_.cost + _loc14_.penaltyCost;
                        if(!(_loc11_ == 0 || _loc11_ > param4.maxCost))
                        {
                           if(!(param4.bounds != null && !param4.bounds.contains(_loc14_.x,_loc14_.y)))
                           {
                              _loc15_ = _loc8_.g + (_loc13_.length + _loc13_.cost) * _loc11_;
                              _loc16_ = this._status[_loc14_];
                              if(_loc16_ != null)
                              {
                                 if(_loc16_.closed || _loc15_ >= _loc16_.g)
                                 {
                                    continue;
                                 }
                              }
                              else
                              {
                                 _loc16_ = PathNode(this._nodePool.get()).reset();
                                 this._status[_loc14_] = _loc16_;
                                 _loc5_ = _loc14_.x - param3.x;
                                 _loc6_ = _loc14_.y - param3.y;
                                 _loc5_ = (_loc5_ ^ _loc5_ >> 31) - (_loc5_ >> 31);
                                 _loc6_ = (_loc6_ ^ _loc6_ >> 31) - (_loc6_ >> 31);
                                 _loc16_.h = _loc5_ + _loc6_;
                                 if(_loc12_ == null || _loc16_.h < _loc12_.h)
                                 {
                                    _loc12_ = _loc16_;
                                 }
                              }
                              _loc16_.closed = false;
                              _loc16_.parent = _loc8_;
                              _loc16_.node = _loc14_;
                              _loc16_.g = _loc15_;
                              _loc16_.priority = -(_loc16_.g + _loc16_.h) * this._costScale;
                              _loc16_.edge = _loc13_;
                              this._open.enqueue(_loc16_);
                           }
                        }
                     }
                  }
               }
            }
         }
         if(!_loc10_.found && param4.allowClosestNodeToGoal)
         {
            _loc8_ = _loc12_;
            _loc10_.found = true;
         }
         if(_loc10_.found)
         {
            _loc10_.goalFound = _loc8_ != null && _loc8_.node == param3;
            _loc17_ = 0;
            while(_loc8_ != null)
            {
               if(param4.trimToFirstTraversalArea && _loc8_.node.traversalAreaId > 0)
               {
                  _loc17_ = 0;
                  _loc10_.numNodes = 0;
                  _loc10_.numWaypoints = 0;
                  _loc10_.nodes.length = 0;
                  _loc10_.waypoints.length = 0;
               }
               if(_loc8_.edge != null)
               {
                  _loc10_.length += _loc8_.edge.length;
                  _loc18_ = _loc8_.edge.waypoints;
                  if(_loc18_ != null)
                  {
                     _loc19_ = int(_loc18_.length);
                     while(_loc19_ >= 3)
                     {
                        _loc20_ = _loc19_ == _loc18_.length ? int(_loc8_.node.traversalAreaId) : _loc18_[_loc19_ - 3];
                        _loc21_ = _loc18_[_loc19_ - 2];
                        _loc22_ = _loc18_[_loc19_ - 1];
                        if(_loc17_ >= 3 && _loc21_ == _loc10_.waypoints[_loc17_ - 1] && _loc22_ == _loc10_.waypoints[_loc17_ - 2])
                        {
                           _loc10_.waypoints[_loc17_ - 3] = _loc20_;
                        }
                        else
                        {
                           _loc10_.waypoints.push(_loc22_,_loc21_,_loc20_);
                           ++_loc10_.numWaypoints;
                           _loc17_ += 3;
                        }
                        _loc19_ -= 3;
                     }
                  }
               }
               _loc10_.nodes.push(_loc8_.node.y,_loc8_.node.x,_loc8_.node.traversalAreaId);
               ++_loc10_.numNodes;
               _loc8_ = _loc8_.parent;
            }
            _loc10_.nodes.reverse();
            _loc10_.waypoints.reverse();
         }
         this._nodePool.reset();
         return _loc10_;
      }
   }
}

import de.polygonal.ds.Prioritizable;

class PathNode extends Prioritizable
{
   
   public var g:Number = 0;
   
   public var h:Number = 0;
   
   public var node:Cell;
   
   public var closed:Boolean;
   
   public var parent:PathNode;
   
   public var edge:NavEdge;
   
   public function PathNode()
   {
      super();
   }
   
   public function reset() : PathNode
   {
      priority = this.g = this.h = 0;
      this.closed = false;
      this.parent = null;
      this.node = null;
      this.edge = null;
      return this;
   }
}
