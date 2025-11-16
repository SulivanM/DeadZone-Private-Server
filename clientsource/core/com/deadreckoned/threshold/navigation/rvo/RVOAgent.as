package com.deadreckoned.threshold.navigation.rvo
{
   import com.deadreckoned.threshold.navigation.core.NavAgent;
   import com.deadreckoned.threshold.ns.threshold_navigation;
   import flash.geom.Vector3D;
   
   use namespace threshold_navigation;
   
   public class RVOAgent extends NavAgent
   {
      
      threshold_navigation var id:int;
      
      threshold_navigation var next:RVOAgent;
      
      threshold_navigation var prev:RVOAgent;
      
      threshold_navigation var _targetVelocity:Vector3D;
      
      threshold_navigation var _maxNeighbors:int = 0;
      
      threshold_navigation var _neighborDist:Number = 0;
      
      threshold_navigation var _neighbors:Vector.<AgentKeyValuePair>;
      
      threshold_navigation var _mode:uint = 0;
      
      threshold_navigation var _group:uint = 0;
      
      threshold_navigation var _groupMask:uint = 255;
      
      threshold_navigation var _ignore:Boolean = false;
      
      private var _orcaPlanes:Vector.<Plane>;
      
      private var _tempPlanes:Vector.<Plane>;
      
      private var _tempLine:Line = new Line();
      
      private var _tempVec:Vector3D;
      
      private var _newVelocity:Vector3;
      
      private var _timeHorizon:Number = 0;
      
      private var _invTimeHorizon:Number;
      
      private var _planeStore:Vector.<Plane>;
      
      public function RVOAgent()
      {
         super();
         this.threshold_navigation::_targetVelocity = new Vector3D();
         this.threshold_navigation::_maxNeighbors = 5;
         this.threshold_navigation::_neighborDist = 100;
         this._timeHorizon = 200;
         this._invTimeHorizon = 1 / this._timeHorizon;
         this.threshold_navigation::_neighbors = new Vector.<AgentKeyValuePair>();
         this._newVelocity = new Vector3();
         this._orcaPlanes = new Vector.<Plane>();
         this._planeStore = new Vector.<Plane>();
         this._tempPlanes = new Vector.<Plane>();
         this._tempVec = new Vector3D();
         this.fillPlanestore();
      }
      
      public function get targetVelocity() : Vector3D
      {
         return this.threshold_navigation::_targetVelocity;
      }
      
      public function get timeHorizon() : Number
      {
         return this._timeHorizon;
      }
      
      public function set timeHorizon(param1:Number) : void
      {
         this._timeHorizon = param1;
         this._invTimeHorizon = 1 / this._timeHorizon;
      }
      
      public function get maxNeighbors() : int
      {
         return this.threshold_navigation::_maxNeighbors;
      }
      
      public function set maxNeighbors(param1:int) : void
      {
         this.threshold_navigation::_maxNeighbors = param1;
         this.fillPlanestore();
      }
      
      public function get neighborDistance() : Number
      {
         return this.threshold_navigation::_neighborDist;
      }
      
      public function set neighborDistance(param1:Number) : void
      {
         this.threshold_navigation::_neighborDist = param1;
      }
      
      public function get mode() : uint
      {
         return this.threshold_navigation::_mode;
      }
      
      public function set mode(param1:uint) : void
      {
         this.threshold_navigation::_mode = param1;
      }
      
      public function get group() : uint
      {
         return this.threshold_navigation::_group;
      }
      
      public function set group(param1:uint) : void
      {
         this.threshold_navigation::_group = param1;
      }
      
      public function get groupMask() : uint
      {
         return this.threshold_navigation::_groupMask;
      }
      
      public function set groupMask(param1:uint) : void
      {
         this.threshold_navigation::_groupMask = param1;
      }
      
      public function get ignore() : Boolean
      {
         return this.threshold_navigation::_ignore;
      }
      
      public function set ignore(param1:Boolean) : void
      {
         this.threshold_navigation::_ignore = param1;
      }
      
      override public function update(param1:Number) : void
      {
         var _loc7_:RVOAgent = null;
         var _loc8_:Vector3D = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Vector3D = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Plane = null;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
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
         var _loc41_:Number = NaN;
         var _loc42_:Number = NaN;
         this._orcaPlanes.length = 0;
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = int(this.threshold_navigation::_neighbors.length);
         while(_loc3_ < _loc5_)
         {
            _loc7_ = this.threshold_navigation::_neighbors[_loc3_].value;
            if(!(Boolean(this.threshold_navigation::_mode & RVOAgentMode.GROUP_ONLY) && !(this.threshold_navigation::_group & _loc7_.threshold_navigation::_group)))
            {
               if((_loc7_.threshold_navigation::_group & this.threshold_navigation::_groupMask) != 0)
               {
                  _loc8_ = _loc7_.position;
                  _loc9_ = _loc8_.x - threshold_navigation::_position.x;
                  _loc10_ = _loc8_.y - threshold_navigation::_position.y;
                  _loc11_ = _loc8_.z - threshold_navigation::_position.z;
                  _loc12_ = _loc9_ * _loc9_ + _loc10_ * _loc10_ + _loc11_ * _loc11_;
                  _loc13_ = _loc7_.threshold_navigation::_velocity;
                  _loc14_ = threshold_navigation::_velocity.x - _loc13_.x;
                  _loc15_ = threshold_navigation::_velocity.y - _loc13_.y;
                  _loc16_ = threshold_navigation::_velocity.z - _loc13_.z;
                  _loc17_ = threshold_navigation::_radius + _loc7_.threshold_navigation::_radius;
                  _loc18_ = _loc17_ * _loc17_;
                  _loc22_ = this._planeStore[_loc3_];
                  if(_loc12_ > _loc18_)
                  {
                     _loc26_ = _loc14_ - this._invTimeHorizon * _loc9_;
                     _loc27_ = _loc15_ - this._invTimeHorizon * _loc10_;
                     _loc28_ = _loc16_ - this._invTimeHorizon * _loc11_;
                     _loc30_ = _loc26_ * _loc26_ + _loc27_ * _loc27_ + _loc28_ * _loc28_;
                     _loc31_ = _loc26_ * _loc9_ + _loc27_ * _loc10_ + _loc28_ * _loc11_;
                     _loc32_ = _loc31_ * _loc31_;
                     _loc33_ = _loc18_ * _loc30_;
                     if(_loc31_ < 0 && _loc32_ > _loc33_)
                     {
                        _loc29_ = Math.sqrt(_loc30_);
                        _loc23_ = _loc26_ / _loc29_;
                        _loc24_ = _loc27_ / _loc29_;
                        _loc25_ = _loc28_ / _loc29_;
                        _loc22_.normal_x = _loc23_;
                        _loc22_.normal_y = _loc24_;
                        _loc22_.normal_z = _loc25_;
                        _loc19_ = (_loc17_ * this._invTimeHorizon - _loc29_) * _loc23_;
                        _loc20_ = (_loc17_ * this._invTimeHorizon - _loc29_) * _loc24_;
                        _loc21_ = (_loc17_ * this._invTimeHorizon - _loc29_) * _loc25_;
                     }
                     else
                     {
                        _loc34_ = _loc10_ * _loc16_ - _loc11_ * _loc15_;
                        _loc35_ = _loc11_ * _loc14_ - _loc9_ * _loc16_;
                        _loc36_ = _loc9_ * _loc15_ - _loc10_ * _loc14_;
                        _loc37_ = _loc34_ * _loc34_ + _loc35_ * _loc35_ + _loc36_ * _loc36_;
                        _loc38_ = _loc14_ * _loc14_ + _loc15_ * _loc15_ + _loc16_ * _loc16_;
                        _loc39_ = _loc12_;
                        _loc40_ = _loc9_ * _loc14_ + _loc10_ * _loc15_ + _loc11_ * _loc16_;
                        _loc41_ = _loc38_ - _loc37_ / (_loc12_ - _loc18_);
                        _loc42_ = (_loc40_ + Math.sqrt(_loc40_ * _loc40_ - _loc39_ * _loc41_)) / _loc39_;
                        _loc26_ = _loc14_ - _loc42_ * _loc9_;
                        _loc27_ = _loc15_ - _loc42_ * _loc10_;
                        _loc28_ = _loc16_ - _loc42_ * _loc11_;
                        _loc29_ = Math.sqrt(_loc26_ * _loc26_ + _loc27_ * _loc27_ + _loc28_ * _loc28_);
                        _loc23_ = _loc26_ / _loc29_;
                        _loc24_ = _loc27_ / _loc29_;
                        _loc25_ = _loc28_ / _loc29_;
                        _loc22_.normal_x = _loc23_;
                        _loc22_.normal_y = _loc24_;
                        _loc22_.normal_z = _loc25_;
                        _loc19_ = (_loc17_ * _loc42_ - _loc29_) * _loc23_;
                        _loc20_ = (_loc17_ * _loc42_ - _loc29_) * _loc24_;
                        _loc21_ = (_loc17_ * _loc42_ - _loc29_) * _loc25_;
                     }
                  }
                  else
                  {
                     if(_loc2_ == 0)
                     {
                        _loc2_ = 1 / param1;
                     }
                     _loc26_ = _loc14_ - _loc2_ * _loc9_;
                     _loc27_ = _loc15_ - _loc2_ * _loc10_;
                     _loc28_ = _loc16_ - _loc2_ * _loc11_;
                     _loc29_ = Math.sqrt(_loc26_ * _loc26_ + _loc27_ * _loc27_ + _loc28_ * _loc28_);
                     _loc23_ = _loc26_ / _loc29_;
                     _loc24_ = _loc27_ / _loc29_;
                     _loc25_ = _loc28_ / _loc29_;
                     _loc22_.normal_x = _loc23_;
                     _loc22_.normal_y = _loc24_;
                     _loc22_.normal_z = _loc25_;
                     _loc19_ = (_loc17_ * _loc2_ - _loc29_) * _loc23_;
                     _loc20_ = (_loc17_ * _loc2_ - _loc29_) * _loc24_;
                     _loc21_ = (_loc17_ * _loc2_ - _loc29_) * _loc25_;
                  }
                  _loc22_.origin_x = threshold_navigation::_velocity.x + 0.5 * _loc19_;
                  _loc22_.origin_y = threshold_navigation::_velocity.y + 0.5 * _loc20_;
                  _loc22_.origin_z = threshold_navigation::_velocity.z + 0.5 * _loc21_;
                  var _loc43_:*;
                  this._orcaPlanes[_loc43_ = _loc4_++] = _loc22_;
               }
            }
            _loc3_++;
         }
         var _loc6_:int = this.linearProgram3(this._orcaPlanes,maxSpeed,this.threshold_navigation::_targetVelocity,false,this._newVelocity);
         if(_loc6_ < this._orcaPlanes.length)
         {
            this.linearProgram4(this._orcaPlanes,_loc6_,maxSpeed,this._newVelocity);
         }
         threshold_navigation::_velocity.x = this._newVelocity.x;
         threshold_navigation::_velocity.y = this._newVelocity.y;
         threshold_navigation::_velocity.z = 0;
         super.update(param1);
      }
      
      private function fillPlanestore() : void
      {
         this._planeStore.fixed = false;
         this._planeStore.length = this.threshold_navigation::_maxNeighbors;
         var _loc1_:int = 0;
         while(_loc1_ < this.threshold_navigation::_maxNeighbors)
         {
            this._planeStore[_loc1_] = this._planeStore[_loc1_] || new Plane();
            _loc1_++;
         }
         this._planeStore.fixed = true;
      }
      
      final private function linearProgram1(param1:Vector.<Plane>, param2:int, param3:Line, param4:Number, param5:Vector3D, param6:Boolean, param7:Vector3) : Boolean
      {
         var _loc13_:Number = NaN;
         var _loc15_:Plane = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc8_:Number = param3.origin_x * param3.direction_x + param3.origin_y * param3.direction_y + param3.origin_z * param3.direction_z;
         var _loc9_:Number = _loc8_ * _loc8_ + param4 * param4 - (param3.origin_x * param3.origin_x + param3.origin_y * param3.origin_y + param3.origin_z * param3.origin_z);
         if(_loc9_ < 0)
         {
            return false;
         }
         var _loc10_:Number = Math.sqrt(_loc9_);
         var _loc11_:Number = -_loc8_ - _loc10_;
         var _loc12_:Number = -_loc8_ + _loc10_;
         var _loc14_:int = 0;
         while(_loc14_ < param2)
         {
            _loc15_ = param1[_loc14_];
            _loc16_ = _loc15_.origin_x - param3.origin_x;
            _loc17_ = _loc15_.origin_y - param3.origin_y;
            _loc18_ = _loc15_.origin_z - param3.origin_z;
            _loc19_ = _loc16_ * _loc15_.normal_x + _loc17_ * _loc15_.normal_y + _loc18_ * _loc15_.normal_z;
            _loc20_ = param3.direction_x * _loc15_.normal_x + param3.direction_y * _loc15_.normal_y + param3.direction_z * _loc15_.normal_z;
            _loc21_ = _loc20_ * _loc20_;
            if(_loc21_ <= 0.00001)
            {
               if(_loc19_ > 0)
               {
                  return false;
               }
            }
            else
            {
               _loc13_ = _loc19_ / _loc20_;
               if(_loc20_ >= 0)
               {
                  if(_loc13_ > _loc11_)
                  {
                     _loc11_ = _loc13_;
                  }
               }
               else if(_loc13_ < _loc12_)
               {
                  _loc12_ = _loc13_;
               }
               if(_loc11_ > _loc12_)
               {
                  return false;
               }
            }
            _loc14_++;
         }
         if(param6)
         {
            _loc22_ = param5.x * param3.direction_x + param5.y * param3.direction_y + param5.z * param3.direction_z;
            if(_loc22_ > 0)
            {
               param7.x = param3.origin_x + _loc12_ * param3.direction_x;
               param7.y = param3.origin_y + _loc12_ * param3.direction_y;
               param7.z = param3.origin_z + _loc12_ * param3.direction_z;
            }
            else
            {
               param7.x = param3.origin_x + _loc11_ * param3.direction_x;
               param7.y = param3.origin_y + _loc11_ * param3.direction_y;
               param7.z = param3.origin_z + _loc11_ * param3.direction_z;
            }
         }
         else
         {
            _loc23_ = param5.x - param3.origin_x;
            _loc24_ = param5.y - param3.origin_y;
            _loc25_ = param5.z - param3.origin_z;
            _loc13_ = param3.direction_x * _loc23_ + param3.direction_y * _loc24_ + param3.direction_z * _loc25_;
            if(_loc13_ < _loc11_)
            {
               param7.x = param3.origin_x + _loc11_ * param3.direction_x;
               param7.y = param3.origin_y + _loc11_ * param3.direction_y;
               param7.z = param3.origin_z + _loc11_ * param3.direction_z;
            }
            else if(_loc13_ > _loc12_)
            {
               param7.x = param3.origin_x + _loc12_ * param3.direction_x;
               param7.y = param3.origin_y + _loc12_ * param3.direction_y;
               param7.z = param3.origin_z + _loc12_ * param3.direction_z;
            }
            else
            {
               param7.x = param3.origin_x + _loc13_ * param3.direction_x;
               param7.y = param3.origin_y + _loc13_ * param3.direction_y;
               param7.z = param3.origin_z + _loc13_ * param3.direction_z;
            }
         }
         return true;
      }
      
      final private function linearProgram2(param1:Vector.<Plane>, param2:int, param3:Number, param4:Vector3D, param5:Boolean, param6:Vector3) : Boolean
      {
         var _loc15_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Plane = null;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc7_:Plane = param1[param2];
         var _loc8_:Number = _loc7_.origin_x * _loc7_.normal_x + _loc7_.origin_y * _loc7_.normal_y + _loc7_.origin_z * _loc7_.normal_z;
         var _loc9_:Number = _loc8_ * _loc8_;
         var _loc10_:Number = param3 * param3;
         if(_loc9_ > _loc10_)
         {
            return false;
         }
         var _loc11_:Number = _loc10_ - _loc9_;
         var _loc12_:Number = _loc7_.normal_x * _loc8_;
         var _loc13_:Number = _loc7_.normal_y * _loc8_;
         var _loc14_:Number = _loc7_.normal_z * _loc8_;
         if(param5)
         {
            _loc17_ = param4.x * _loc7_.normal_x + param4.y * _loc7_.normal_y + param4.z * _loc7_.normal_z;
            _loc18_ = param4.x - _loc17_ * _loc7_.normal_x;
            _loc19_ = param4.y - _loc17_ * _loc7_.normal_y;
            _loc20_ = param4.z - _loc17_ * _loc7_.normal_z;
            _loc21_ = _loc18_ * _loc18_ + _loc19_ * _loc19_ + _loc20_ * _loc20_;
            if(_loc21_ <= 0.00001)
            {
               param6.x = _loc12_;
               param6.y = _loc13_;
               param6.z = _loc14_;
            }
            else
            {
               _loc15_ = Math.sqrt(_loc11_ / _loc21_);
               param6.x = _loc12_ + _loc15_ * _loc18_;
               param6.y = _loc13_ + _loc15_ * _loc19_;
               param6.z = _loc14_ + _loc15_ * _loc20_;
            }
         }
         else
         {
            _loc22_ = _loc7_.origin_x - param4.x;
            _loc23_ = _loc7_.origin_y - param4.y;
            _loc24_ = _loc7_.origin_z - param4.z;
            _loc15_ = _loc22_ * _loc7_.normal_x + _loc23_ * _loc7_.normal_y + _loc24_ * _loc7_.normal_z;
            param6.x = param4.x + _loc15_ * _loc7_.normal_x;
            param6.y = param4.y + _loc15_ * _loc7_.normal_y;
            param6.z = param4.z + _loc15_ * _loc7_.normal_z;
            _loc25_ = param6.x * param6.x + param6.y * param6.y + param6.z * param6.z;
            if(_loc25_ > _loc10_)
            {
               _loc22_ = param6.x - _loc12_;
               _loc23_ = param6.y - _loc13_;
               _loc24_ = param6.z - _loc14_;
               _loc26_ = _loc22_ * _loc22_ + _loc23_ * _loc23_ + _loc24_ * _loc24_;
               _loc15_ = Math.sqrt(_loc11_ / _loc26_);
               param6.x = _loc12_ + _loc15_ * _loc22_;
               param6.y = _loc13_ + _loc15_ * _loc23_;
               param6.z = _loc14_ + _loc15_ * _loc24_;
            }
         }
         var _loc16_:int = 0;
         while(_loc16_ < param2)
         {
            _loc27_ = param1[_loc16_];
            _loc12_ = _loc27_.origin_x - param6.x;
            _loc13_ = _loc27_.origin_y - param6.y;
            _loc14_ = _loc27_.origin_z - param6.z;
            _loc28_ = _loc27_.normal_x * _loc12_ + _loc27_.normal_y * _loc13_ + _loc27_.normal_z * _loc14_;
            if(_loc28_ > 0)
            {
               _loc29_ = _loc27_.normal_y * _loc7_.normal_z - _loc27_.normal_z * _loc7_.normal_y;
               _loc30_ = _loc27_.normal_z * _loc7_.normal_x - _loc27_.normal_x * _loc7_.normal_z;
               _loc31_ = _loc27_.normal_x * _loc7_.normal_y - _loc27_.normal_y * _loc7_.normal_x;
               _loc32_ = _loc29_ * _loc29_ + _loc30_ * _loc30_ + _loc31_ * _loc31_;
               if(_loc32_ <= 0.00001)
               {
                  return false;
               }
               _loc33_ = 1 / Math.sqrt(_loc32_);
               this._tempLine.direction_x = _loc29_ * _loc33_;
               this._tempLine.direction_y = _loc30_ * _loc33_;
               this._tempLine.direction_z = _loc31_ * _loc33_;
               _loc12_ = _loc27_.origin_x - _loc7_.origin_x;
               _loc13_ = _loc27_.origin_y - _loc7_.origin_y;
               _loc14_ = _loc27_.origin_z - _loc7_.origin_z;
               _loc34_ = _loc12_ * _loc27_.normal_x + _loc13_ * _loc27_.normal_y + _loc14_ * _loc27_.normal_z;
               _loc29_ = this._tempLine.direction_y * _loc7_.normal_z - this._tempLine.direction_z * _loc7_.normal_y;
               _loc30_ = this._tempLine.direction_z * _loc7_.normal_x - this._tempLine.direction_x * _loc7_.normal_z;
               _loc31_ = this._tempLine.direction_x * _loc7_.normal_y - this._tempLine.direction_y * _loc7_.normal_x;
               _loc35_ = _loc29_ * _loc27_.normal_x + _loc30_ * _loc27_.normal_y + _loc31_ * _loc27_.normal_z;
               this._tempLine.origin_x = _loc7_.origin_x + _loc34_ / _loc35_ * _loc29_;
               this._tempLine.origin_y = _loc7_.origin_y + _loc34_ / _loc35_ * _loc30_;
               this._tempLine.origin_z = _loc7_.origin_z + _loc34_ / _loc35_ * _loc31_;
               if(!this.linearProgram1(param1,_loc16_,this._tempLine,param3,param4,param5,param6))
               {
                  return false;
               }
            }
            _loc16_++;
         }
         return true;
      }
      
      final private function linearProgram3(param1:Vector.<Plane>, param2:Number, param3:Vector3D, param4:Boolean, param5:Vector3) : int
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Plane = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         if(param4)
         {
            param5.x = param3.x * param2;
            param5.y = param3.y * param2;
            param5.z = param3.z * param2;
         }
         else
         {
            _loc8_ = param3.x * param3.x + param3.y * param3.y + param3.z * param3.z;
            if(_loc8_ > param2 * param2)
            {
               _loc9_ = 1 / Math.sqrt(_loc8_);
               param5.x = param3.x * _loc9_ * param2;
               param5.y = param3.y * _loc9_ * param2;
               param5.z = param3.z * _loc9_ * param2;
            }
            else
            {
               param5.x = param3.x;
               param5.y = param3.y;
               param5.z = param3.z;
            }
         }
         var _loc6_:int = 0;
         var _loc7_:int = int(param1.length);
         while(_loc6_ < _loc7_)
         {
            _loc10_ = param1[_loc6_];
            _loc11_ = _loc10_.origin_x - param5.x;
            _loc12_ = _loc10_.origin_y - param5.y;
            _loc13_ = _loc10_.origin_z - param5.z;
            _loc14_ = _loc10_.normal_x * _loc11_ + _loc10_.normal_y * _loc12_ + _loc10_.normal_z * _loc13_;
            if(_loc14_ > 0)
            {
               _loc15_ = param5.x;
               _loc16_ = param5.y;
               _loc17_ = param5.z;
               if(!this.linearProgram2(param1,_loc6_,param2,param3,param4,param5))
               {
                  param5.x = _loc15_;
                  param5.y = _loc16_;
                  param5.z = _loc17_;
                  return _loc6_;
               }
            }
            _loc6_++;
         }
         return _loc7_;
      }
      
      final private function linearProgram4(param1:Vector.<Plane>, param2:int, param3:Number, param4:Vector3) : void
      {
         var _loc8_:Plane = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Plane = null;
         var _loc19_:Plane = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc5_:Number = 0;
         var _loc6_:int = param2;
         var _loc7_:int = int(param1.length);
         while(_loc6_ < _loc7_)
         {
            _loc8_ = param1[_loc6_];
            _loc9_ = _loc8_.origin_x - param4.x;
            _loc10_ = _loc8_.origin_y - param4.y;
            _loc11_ = _loc8_.origin_z - param4.z;
            _loc12_ = _loc8_.normal_x * _loc9_ + _loc8_.normal_y * _loc10_ + _loc8_.normal_z * _loc11_;
            if(_loc12_ > _loc5_)
            {
               _loc13_ = 0;
               this._tempPlanes.length = 0;
               _loc14_ = 0;
               for(; _loc14_ < _loc6_; _loc14_++)
               {
                  _loc18_ = param1[_loc14_];
                  _loc19_ = new Plane();
                  _loc20_ = _loc18_.normal_y * _loc8_.normal_z - _loc18_.normal_z * _loc8_.normal_y;
                  _loc21_ = _loc18_.normal_z * _loc8_.normal_x - _loc18_.normal_x * _loc8_.normal_z;
                  _loc22_ = _loc18_.normal_x * _loc8_.normal_y - _loc18_.normal_y * _loc8_.normal_x;
                  _loc23_ = _loc20_ * _loc20_ + _loc21_ * _loc21_ + _loc22_ * _loc22_;
                  if(_loc23_ <= 0.00001)
                  {
                     _loc12_ = _loc8_.normal_x * _loc18_.normal_x + _loc8_.normal_y * _loc18_.normal_y + _loc8_.normal_z * _loc18_.normal_z;
                     if(_loc12_ > 0)
                     {
                        continue;
                     }
                     _loc19_.origin_x = 0.5 * (_loc8_.origin_x + _loc18_.origin_x);
                     _loc19_.origin_y = 0.5 * (_loc8_.origin_y + _loc18_.origin_y);
                     _loc19_.origin_z = 0.5 * (_loc8_.origin_z + _loc18_.origin_z);
                  }
                  else
                  {
                     _loc25_ = _loc21_ * _loc8_.normal_z - _loc22_ * _loc8_.normal_y;
                     _loc26_ = _loc22_ * _loc8_.normal_x - _loc20_ * _loc8_.normal_z;
                     _loc27_ = _loc20_ * _loc8_.normal_y - _loc21_ * _loc8_.normal_x;
                     _loc28_ = _loc25_ * _loc18_.normal_x + _loc26_ * _loc18_.normal_y + _loc27_ * _loc18_.normal_z;
                     _loc9_ = _loc18_.origin_x - _loc8_.origin_x;
                     _loc10_ = _loc18_.origin_y - _loc8_.origin_y;
                     _loc11_ = _loc18_.origin_z - _loc8_.origin_z;
                     _loc29_ = _loc9_ * _loc18_.normal_x + _loc10_ * _loc18_.normal_y + _loc11_ * _loc18_.normal_z;
                     _loc19_.origin_x = _loc8_.origin_x + _loc29_ / _loc28_ * _loc25_;
                     _loc19_.origin_y = _loc8_.origin_y + _loc29_ / _loc28_ * _loc26_;
                     _loc19_.origin_z = _loc8_.origin_z + _loc29_ / _loc28_ * _loc27_;
                  }
                  _loc19_.normal_x = _loc18_.normal_x - _loc8_.normal_x;
                  _loc19_.normal_y = _loc18_.normal_y - _loc8_.normal_y;
                  _loc19_.normal_z = _loc18_.normal_z - _loc8_.normal_z;
                  _loc24_ = 1 / Math.sqrt(_loc19_.normal_x * _loc19_.normal_x + _loc19_.normal_y * _loc19_.normal_y + _loc19_.normal_z * _loc19_.normal_z);
                  _loc19_.normal_x *= _loc24_;
                  _loc19_.normal_y *= _loc24_;
                  _loc19_.normal_z *= _loc24_;
                  var _loc30_:*;
                  this._tempPlanes[_loc30_ = _loc13_++] = _loc19_;
               }
               _loc15_ = param4.x;
               _loc16_ = param4.y;
               _loc17_ = param4.z;
               this._tempVec.x = _loc8_.normal_x;
               this._tempVec.y = _loc8_.normal_y;
               this._tempVec.z = _loc8_.normal_z;
               if(this.linearProgram3(this._tempPlanes,param3,this._tempVec,true,param4) < _loc13_)
               {
                  param4.x = _loc15_;
                  param4.y = _loc16_;
                  param4.z = _loc17_;
               }
               _loc5_ = _loc8_.normal_x * (_loc8_.origin_x - param4.x) + _loc8_.normal_y * (_loc8_.origin_y - param4.y) + _loc8_.normal_z * (_loc8_.origin_z - param4.z);
            }
            _loc6_++;
         }
      }
   }
}

final class Line
{
   
   public var origin_x:Number;
   
   public var origin_y:Number;
   
   public var origin_z:Number;
   
   public var direction_x:Number;
   
   public var direction_y:Number;
   
   public var direction_z:Number;
   
   public function Line()
   {
      super();
   }
}

final class Plane
{
   
   public var origin_x:Number;
   
   public var origin_y:Number;
   
   public var origin_z:Number;
   
   public var normal_x:Number;
   
   public var normal_y:Number;
   
   public var normal_z:Number;
   
   public function Plane()
   {
      super();
   }
}

final class Vector3
{
   
   public var x:Number = 0;
   
   public var y:Number = 0;
   
   public var z:Number = 0;
   
   public function Vector3()
   {
      super();
   }
}
