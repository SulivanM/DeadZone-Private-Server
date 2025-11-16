package com.deadreckoned.threshold.navigation.rvo
{
   import com.deadreckoned.threshold.ns.threshold_navigation;
   import flash.geom.Vector3D;
   
   use namespace threshold_navigation;
   
   public class KdTree
   {
      
      private const MAX_LEAF_SIZE:int = 10;
      
      private var _agents:Vector.<RVOAgent>;
      
      private var _agentTree:Vector.<AgentTreeNode>;
      
      private var _numAgents:int;
      
      public function KdTree()
      {
         super();
         this._agentTree = new Vector.<AgentTreeNode>();
      }
      
      final public function buildAgentTree(param1:Vector.<RVOAgent>) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._agents == null || this._numAgents != param1.length)
         {
            _loc2_ = int(this._agentTree.length);
            this._agentTree.fixed = false;
            this._agentTree.length = 2 * param1.length;
            _loc3_ = _loc2_;
            _loc4_ = int(this._agentTree.length);
            while(_loc3_ < _loc4_)
            {
               this._agentTree[_loc3_] = new AgentTreeNode();
               _loc3_++;
            }
            this._agentTree.fixed = true;
         }
         this._agents = param1;
         this._numAgents = this._agents.length;
         if(this._numAgents != 0)
         {
            this.buildAgentTreeRecursive(0,this._numAgents,0);
         }
      }
      
      final public function queryAgentTree(param1:RVOAgent, param2:Number, param3:int = 0) : Number
      {
         var _loc6_:Vector.<AgentKeyValuePair> = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:RVOAgent = null;
         var _loc13_:Vector3D = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:AgentKeyValuePair = null;
         var _loc19_:int = 0;
         var _loc20_:AgentKeyValuePair = null;
         var _loc21_:AgentTreeNode = null;
         var _loc22_:AgentTreeNode = null;
         var _loc23_:Vector.<Number> = null;
         var _loc24_:Vector.<Number> = null;
         var _loc25_:Vector.<Number> = null;
         var _loc26_:Vector.<Number> = null;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc4_:AgentTreeNode = this._agentTree[param3];
         var _loc5_:Vector3D = param1.threshold_navigation::_position;
         if(_loc4_.end - _loc4_.begin <= this.MAX_LEAF_SIZE)
         {
            _loc6_ = param1.threshold_navigation::_neighbors;
            _loc7_ = param1.threshold_navigation::_maxNeighbors;
            _loc8_ = int(_loc6_.length);
            _loc9_ = _loc4_.begin;
            _loc10_ = _loc4_.end;
            _loc11_ = _loc9_;
            while(_loc11_ < _loc10_)
            {
               _loc12_ = this._agents[_loc11_];
               if(!(_loc12_ == param1 || _loc12_.threshold_navigation::_ignore))
               {
                  _loc13_ = _loc12_.position;
                  _loc14_ = _loc5_.x - _loc13_.x;
                  _loc15_ = _loc5_.y - _loc13_.y;
                  _loc16_ = _loc5_.z - _loc13_.z;
                  _loc17_ = _loc14_ * _loc14_ + _loc15_ * _loc15_ + _loc16_ * _loc16_;
                  if(_loc17_ < param2)
                  {
                     if(_loc8_ < _loc7_)
                     {
                        _loc18_ = new AgentKeyValuePair(_loc17_,_loc12_);
                        var _loc41_:*;
                        _loc6_[_loc41_ = _loc8_++] = _loc18_;
                     }
                     _loc19_ = _loc8_ - 1;
                     while(_loc19_ != 0 && _loc17_ < _loc6_[_loc19_ - 1].key)
                     {
                        _loc20_ = _loc6_[_loc19_ - 1];
                        _loc6_[_loc19_].key = _loc20_.key;
                        _loc6_[_loc19_].value = _loc20_.value;
                        _loc19_--;
                     }
                     _loc18_ = _loc6_[_loc19_];
                     _loc18_.key = _loc17_;
                     _loc18_.value = _loc12_;
                     if(_loc8_ == _loc7_)
                     {
                        param2 = _loc6_[_loc8_ - 1].key;
                     }
                  }
               }
               _loc11_++;
            }
         }
         else
         {
            _loc21_ = this._agentTree[_loc4_.left];
            _loc22_ = this._agentTree[_loc4_.right];
            _loc23_ = _loc21_.min;
            _loc24_ = _loc21_.max;
            _loc25_ = _loc22_.min;
            _loc26_ = _loc22_.max;
            _loc27_ = _loc23_[0] - _loc5_.x;
            if(_loc27_ < 0)
            {
               _loc27_ = 0;
            }
            _loc28_ = _loc5_.x - _loc24_[0];
            if(_loc28_ < 0)
            {
               _loc28_ = 0;
            }
            _loc29_ = _loc23_[1] - _loc5_.y;
            if(_loc29_ < 0)
            {
               _loc29_ = 0;
            }
            _loc30_ = _loc5_.y - _loc24_[1];
            if(_loc30_ < 0)
            {
               _loc30_ = 0;
            }
            _loc31_ = _loc23_[2] - _loc5_.z;
            if(_loc31_ < 0)
            {
               _loc31_ = 0;
            }
            _loc32_ = _loc5_.z - _loc24_[2];
            if(_loc32_ < 0)
            {
               _loc32_ = 0;
            }
            _loc33_ = _loc25_[0] - _loc5_.x;
            if(_loc33_ < 0)
            {
               _loc33_ = 0;
            }
            _loc34_ = _loc5_.x - _loc26_[0];
            if(_loc34_ < 0)
            {
               _loc34_ = 0;
            }
            _loc35_ = _loc25_[1] - _loc5_.y;
            if(_loc35_ < 0)
            {
               _loc35_ = 0;
            }
            _loc36_ = _loc5_.y - _loc26_[1];
            if(_loc36_ < 0)
            {
               _loc36_ = 0;
            }
            _loc37_ = _loc25_[2] - _loc5_.z;
            if(_loc37_ < 0)
            {
               _loc37_ = 0;
            }
            _loc38_ = _loc5_.z - _loc26_[2];
            if(_loc38_ < 0)
            {
               _loc38_ = 0;
            }
            _loc39_ = _loc27_ * _loc27_ + _loc28_ * _loc28_ + _loc29_ * _loc29_ + _loc30_ * _loc30_ + _loc31_ * _loc31_ + _loc32_ * _loc32_;
            _loc40_ = _loc33_ * _loc33_ + _loc34_ * _loc34_ + _loc35_ * _loc35_ + _loc36_ * _loc36_ + _loc37_ * _loc37_ + _loc38_ * _loc38_;
            if(_loc39_ < _loc40_)
            {
               if(_loc39_ < param2)
               {
                  param2 = this.queryAgentTree(param1,param2,_loc4_.left);
                  if(_loc40_ < param2)
                  {
                     param2 = this.queryAgentTree(param1,param2,_loc4_.right);
                  }
               }
            }
            else if(_loc40_ < param2)
            {
               param2 = this.queryAgentTree(param1,param2,_loc4_.right);
               if(_loc39_ < param2)
               {
                  param2 = this.queryAgentTree(param1,param2,_loc4_.left);
               }
            }
         }
         return param2;
      }
      
      final private function buildAgentTreeRecursive(param1:int, param2:int, param3:int) : void
      {
         var _loc10_:Vector3D = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc23_:RVOAgent = null;
         var _loc4_:RVOAgent = this._agents[param1];
         var _loc5_:AgentTreeNode = this._agentTree[param3];
         var _loc6_:Vector.<Number> = _loc5_.min;
         var _loc7_:Vector.<Number> = _loc5_.max;
         _loc5_.begin = param1;
         _loc5_.end = param2;
         _loc6_[0] = _loc7_[0] = _loc4_.position.x;
         _loc6_[1] = _loc7_[1] = _loc4_.position.y;
         _loc6_[2] = _loc7_[2] = _loc4_.position.z;
         var _loc8_:int = param1 + 1;
         while(_loc8_ < param2)
         {
            _loc10_ = this._agents[_loc8_].position;
            if(_loc7_[0] < _loc10_.x)
            {
               _loc7_[0] = _loc10_.x;
            }
            if(_loc6_[0] > _loc10_.x)
            {
               _loc6_[0] = _loc10_.x;
            }
            if(_loc7_[1] < _loc10_.y)
            {
               _loc7_[1] = _loc10_.y;
            }
            if(_loc6_[1] > _loc10_.y)
            {
               _loc6_[1] = _loc10_.y;
            }
            if(_loc7_[2] < _loc10_.z)
            {
               _loc7_[2] = _loc10_.z;
            }
            if(_loc6_[2] > _loc10_.z)
            {
               _loc6_[2] = _loc10_.z;
            }
            _loc8_++;
         }
         var _loc9_:int = param2 - param1;
         if(_loc9_ > this.MAX_LEAF_SIZE)
         {
            _loc13_ = _loc7_[0] - _loc6_[0];
            _loc14_ = _loc7_[1] - _loc6_[1];
            _loc15_ = _loc7_[2] - _loc6_[2];
            if(_loc13_ > _loc14_ && _loc14_ > _loc15_)
            {
               _loc11_ = 0;
            }
            else if(_loc14_ > _loc15_)
            {
               _loc11_ = 1;
            }
            else
            {
               _loc11_ = 2;
            }
            _loc16_ = 0.5 * (_loc7_[_loc11_] + _loc6_[_loc11_]);
            _loc17_ = param1;
            _loc18_ = param2;
            while(_loc17_ < _loc18_)
            {
               if(_loc11_ == 0)
               {
                  _loc22_ = this._agents[_loc17_].position.x;
               }
               else if(_loc11_ == 1)
               {
                  _loc22_ = this._agents[_loc17_].position.y;
               }
               else if(_loc11_ == 2)
               {
                  _loc22_ = this._agents[_loc17_].position.z;
               }
               while(_loc17_ < _loc18_ && _loc22_ < _loc16_)
               {
                  if(++_loc17_ < _loc18_)
                  {
                     if(_loc11_ == 0)
                     {
                        _loc22_ = this._agents[_loc17_].position.x;
                     }
                     else if(_loc11_ == 1)
                     {
                        _loc22_ = this._agents[_loc17_].position.y;
                     }
                     else if(_loc11_ == 2)
                     {
                        _loc22_ = this._agents[_loc17_].position.z;
                     }
                  }
               }
               if(_loc11_ == 0)
               {
                  _loc22_ = this._agents[_loc18_ - 1].position.x;
               }
               else if(_loc11_ == 1)
               {
                  _loc22_ = this._agents[_loc18_ - 1].position.y;
               }
               else if(_loc11_ == 2)
               {
                  _loc22_ = this._agents[_loc18_ - 1].position.z;
               }
               while(_loc18_ > _loc17_ && _loc22_ >= _loc16_)
               {
                  if(--_loc18_ > _loc17_)
                  {
                     if(_loc11_ == 0)
                     {
                        _loc22_ = this._agents[_loc18_ - 1].position.x;
                     }
                     else if(_loc11_ == 1)
                     {
                        _loc22_ = this._agents[_loc18_ - 1].position.y;
                     }
                     else if(_loc11_ == 2)
                     {
                        _loc22_ = this._agents[_loc18_ - 1].position.z;
                     }
                  }
               }
               if(_loc17_ < _loc18_)
               {
                  _loc23_ = this._agents[_loc17_];
                  this._agents[_loc17_] = this._agents[_loc18_ - 1];
                  this._agents[_loc18_ - 1] = _loc23_;
                  _loc17_++;
                  _loc18_--;
               }
            }
            _loc19_ = _loc17_ - param1;
            if(_loc19_ == 0)
            {
               _loc19_++;
               _loc17_++;
               _loc18_++;
            }
            _loc20_ = _loc5_.left = param3 + 1;
            _loc21_ = _loc5_.right = param3 + 1 + (2 * _loc19_ - 1);
            this.buildAgentTreeRecursive(param1,_loc17_,_loc20_);
            this.buildAgentTreeRecursive(_loc17_,param2,_loc21_);
         }
      }
   }
}

final class AgentTreeNode
{
   
   public var begin:int;
   
   public var end:int;
   
   public var left:int;
   
   public var right:int;
   
   public var min:Vector.<Number> = new Vector.<Number>(3,true);
   
   public var max:Vector.<Number> = new Vector.<Number>(3,true);
   
   public function AgentTreeNode()
   {
      super();
   }
}
