package com.deadreckoned.threshold.navigation.rvo
{
   import com.deadreckoned.threshold.ns.threshold_navigation;
   
   use namespace threshold_navigation;
   
   public class RVOSimulator
   {
      
      private var _time:Number;
      
      private var _agents:Vector.<RVOAgent>;
      
      private var _agentHead:RVOAgent;
      
      private var _agentTail:RVOAgent;
      
      private var _obstacles:Vector.<Obstacle>;
      
      private var _obstaclesDirty:Boolean;
      
      private var _kdTree:KdTree;
      
      private var _timeStep:Number;
      
      public function RVOSimulator()
      {
         super();
         this._agents = new Vector.<RVOAgent>();
         this._obstacles = new Vector.<Obstacle>();
         this._kdTree = new KdTree();
         this._time = 0;
      }
      
      public function get numAgents() : int
      {
         return this._agents.length;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function addAgent(param1:RVOAgent) : void
      {
         if(this._agents.indexOf(param1) > -1)
         {
            return;
         }
         param1.threshold_navigation::id = this._agents.length;
         if(this._agentHead == null)
         {
            this._agentHead = param1;
            this._agentTail = param1;
         }
         else
         {
            param1.threshold_navigation::prev = this._agentTail;
            this._agentTail.threshold_navigation::next = param1;
            this._agentTail = param1;
         }
         this._agents.push(param1);
      }
      
      public function addObstacle(param1:Obstacle) : void
      {
         throw new Error("Not implemented yet");
      }
      
      public function getAgent(param1:int) : RVOAgent
      {
         return this._agents[param1];
      }
      
      public function removeAgent(param1:RVOAgent) : void
      {
         var _loc2_:int = int(this._agents.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._agents.splice(_loc2_,1);
         if(this._agentHead == param1)
         {
            this._agentHead = param1.threshold_navigation::next;
         }
         if(this._agentTail == param1)
         {
            this._agentTail = param1.threshold_navigation::prev;
         }
         if(param1.threshold_navigation::prev != null)
         {
            param1.threshold_navigation::prev.threshold_navigation::next = param1.threshold_navigation::next;
         }
         if(param1.threshold_navigation::next != null)
         {
            param1.threshold_navigation::next.threshold_navigation::prev = param1.threshold_navigation::prev;
         }
         param1.threshold_navigation::next = null;
         param1.threshold_navigation::prev = null;
      }
      
      public function removeAllAgents() : void
      {
         this._agents.length = 0;
         this._agentHead = null;
         this._agentTail = null;
      }
      
      public function removeObstacle(param1:Obstacle) : void
      {
         this._obstaclesDirty = true;
      }
      
      public function clear() : void
      {
         this._agents.length = 0;
         this._obstacles.length = 0;
      }
      
      public function step(param1:Number) : void
      {
         var _loc3_:Vector.<AgentKeyValuePair> = null;
         var _loc4_:Number = NaN;
         this._kdTree.buildAgentTree(this._agents);
         var _loc2_:RVOAgent = this._agentHead;
         while(_loc2_ != null)
         {
            if(!(_loc2_.threshold_navigation::_mode & RVOAgentMode.STATIC))
            {
               _loc3_ = _loc2_.threshold_navigation::_neighbors;
               _loc3_.fixed = false;
               _loc3_.length = 0;
               if(_loc2_.threshold_navigation::_maxNeighbors > 0)
               {
                  _loc4_ = _loc2_.threshold_navigation::_neighborDist;
                  this._kdTree.queryAgentTree(_loc2_,_loc4_ * _loc4_);
               }
               _loc3_.fixed = true;
               _loc2_.update(param1);
            }
            _loc2_ = _loc2_.threshold_navigation::next;
         }
         this._time += param1;
      }
   }
}

