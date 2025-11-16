package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class BoundBox
   {
      
      public var minX:Number = 1e+22;
      
      public var minY:Number = 1e+22;
      
      public var minZ:Number = 1e+22;
      
      public var maxX:Number = -1e+22;
      
      public var maxY:Number = -1e+22;
      
      public var maxZ:Number = -1e+22;
      
      public function BoundBox()
      {
         super();
      }
      
      public function reset() : void
      {
         this.minX = 1e+22;
         this.minY = 1e+22;
         this.minZ = 1e+22;
         this.maxX = -1e+22;
         this.maxY = -1e+22;
         this.maxZ = -1e+22;
      }
      
      alternativa3d function checkFrustumCulling(param1:CullingPlane, param2:int) : int
      {
         var _loc3_:* = 1;
         var _loc4_:CullingPlane = param1;
         while(_loc4_ != null)
         {
            if(param2 & _loc3_)
            {
               if(_loc4_.x >= 0)
               {
                  if(_loc4_.y >= 0)
                  {
                     if(_loc4_.z >= 0)
                     {
                        if(this.maxX * _loc4_.x + this.maxY * _loc4_.y + this.maxZ * _loc4_.z <= _loc4_.offset)
                        {
                           return -1;
                        }
                        if(this.minX * _loc4_.x + this.minY * _loc4_.y + this.minZ * _loc4_.z > _loc4_.offset)
                        {
                           param2 &= 0x3F & ~_loc3_;
                        }
                     }
                     else
                     {
                        if(this.maxX * _loc4_.x + this.maxY * _loc4_.y + this.minZ * _loc4_.z <= _loc4_.offset)
                        {
                           return -1;
                        }
                        if(this.minX * _loc4_.x + this.minY * _loc4_.y + this.maxZ * _loc4_.z > _loc4_.offset)
                        {
                           param2 &= 0x3F & ~_loc3_;
                        }
                     }
                  }
                  else if(_loc4_.z >= 0)
                  {
                     if(this.maxX * _loc4_.x + this.minY * _loc4_.y + this.maxZ * _loc4_.z <= _loc4_.offset)
                     {
                        return -1;
                     }
                     if(this.minX * _loc4_.x + this.maxY * _loc4_.y + this.minZ * _loc4_.z > _loc4_.offset)
                     {
                        param2 &= 0x3F & ~_loc3_;
                     }
                  }
                  else
                  {
                     if(this.maxX * _loc4_.x + this.minY * _loc4_.y + this.minZ * _loc4_.z <= _loc4_.offset)
                     {
                        return -1;
                     }
                     if(this.minX * _loc4_.x + this.maxY * _loc4_.y + this.maxZ * _loc4_.z > _loc4_.offset)
                     {
                        param2 &= 0x3F & ~_loc3_;
                     }
                  }
               }
               else if(_loc4_.y >= 0)
               {
                  if(_loc4_.z >= 0)
                  {
                     if(this.minX * _loc4_.x + this.maxY * _loc4_.y + this.maxZ * _loc4_.z <= _loc4_.offset)
                     {
                        return -1;
                     }
                     if(this.maxX * _loc4_.x + this.minY * _loc4_.y + this.minZ * _loc4_.z > _loc4_.offset)
                     {
                        param2 &= 0x3F & ~_loc3_;
                     }
                  }
                  else
                  {
                     if(this.minX * _loc4_.x + this.maxY * _loc4_.y + this.minZ * _loc4_.z <= _loc4_.offset)
                     {
                        return -1;
                     }
                     if(this.maxX * _loc4_.x + this.minY * _loc4_.y + this.maxZ * _loc4_.z > _loc4_.offset)
                     {
                        param2 &= 0x3F & ~_loc3_;
                     }
                  }
               }
               else if(_loc4_.z >= 0)
               {
                  if(this.minX * _loc4_.x + this.minY * _loc4_.y + this.maxZ * _loc4_.z <= _loc4_.offset)
                  {
                     return -1;
                  }
                  if(this.maxX * _loc4_.x + this.maxY * _loc4_.y + this.minZ * _loc4_.z > _loc4_.offset)
                  {
                     param2 &= 0x3F & ~_loc3_;
                  }
               }
               else
               {
                  if(this.minX * _loc4_.x + this.minY * _loc4_.y + this.minZ * _loc4_.z <= _loc4_.offset)
                  {
                     return -1;
                  }
                  if(this.maxX * _loc4_.x + this.maxY * _loc4_.y + this.maxZ * _loc4_.z > _loc4_.offset)
                  {
                     param2 &= 0x3F & ~_loc3_;
                  }
               }
            }
            _loc3_ <<= 1;
            _loc4_ = _loc4_.next;
         }
         return param2;
      }
      
      alternativa3d function checkOcclusion(param1:Vector.<Occluder>, param2:int, param3:Transform3D) : Boolean
      {
         var _loc29_:Occluder = null;
         var _loc30_:CullingPlane = null;
         var _loc4_:Number = param3.a * this.minX + param3.b * this.minY + param3.c * this.minZ + param3.d;
         var _loc5_:Number = param3.e * this.minX + param3.f * this.minY + param3.g * this.minZ + param3.h;
         var _loc6_:Number = param3.i * this.minX + param3.j * this.minY + param3.k * this.minZ + param3.l;
         var _loc7_:Number = param3.a * this.maxX + param3.b * this.minY + param3.c * this.minZ + param3.d;
         var _loc8_:Number = param3.e * this.maxX + param3.f * this.minY + param3.g * this.minZ + param3.h;
         var _loc9_:Number = param3.i * this.maxX + param3.j * this.minY + param3.k * this.minZ + param3.l;
         var _loc10_:Number = param3.a * this.minX + param3.b * this.maxY + param3.c * this.minZ + param3.d;
         var _loc11_:Number = param3.e * this.minX + param3.f * this.maxY + param3.g * this.minZ + param3.h;
         var _loc12_:Number = param3.i * this.minX + param3.j * this.maxY + param3.k * this.minZ + param3.l;
         var _loc13_:Number = param3.a * this.maxX + param3.b * this.maxY + param3.c * this.minZ + param3.d;
         var _loc14_:Number = param3.e * this.maxX + param3.f * this.maxY + param3.g * this.minZ + param3.h;
         var _loc15_:Number = param3.i * this.maxX + param3.j * this.maxY + param3.k * this.minZ + param3.l;
         var _loc16_:Number = param3.a * this.minX + param3.b * this.minY + param3.c * this.maxZ + param3.d;
         var _loc17_:Number = param3.e * this.minX + param3.f * this.minY + param3.g * this.maxZ + param3.h;
         var _loc18_:Number = param3.i * this.minX + param3.j * this.minY + param3.k * this.maxZ + param3.l;
         var _loc19_:Number = param3.a * this.maxX + param3.b * this.minY + param3.c * this.maxZ + param3.d;
         var _loc20_:Number = param3.e * this.maxX + param3.f * this.minY + param3.g * this.maxZ + param3.h;
         var _loc21_:Number = param3.i * this.maxX + param3.j * this.minY + param3.k * this.maxZ + param3.l;
         var _loc22_:Number = param3.a * this.minX + param3.b * this.maxY + param3.c * this.maxZ + param3.d;
         var _loc23_:Number = param3.e * this.minX + param3.f * this.maxY + param3.g * this.maxZ + param3.h;
         var _loc24_:Number = param3.i * this.minX + param3.j * this.maxY + param3.k * this.maxZ + param3.l;
         var _loc25_:Number = param3.a * this.maxX + param3.b * this.maxY + param3.c * this.maxZ + param3.d;
         var _loc26_:Number = param3.e * this.maxX + param3.f * this.maxY + param3.g * this.maxZ + param3.h;
         var _loc27_:Number = param3.i * this.maxX + param3.j * this.maxY + param3.k * this.maxZ + param3.l;
         var _loc28_:int = 0;
         while(_loc28_ < param2)
         {
            _loc29_ = param1[_loc28_];
            _loc30_ = _loc29_.alternativa3d::planeList;
            while(_loc30_ != null)
            {
               if(_loc30_.x * _loc4_ + _loc30_.y * _loc5_ + _loc30_.z * _loc6_ > _loc30_.offset || _loc30_.x * _loc7_ + _loc30_.y * _loc8_ + _loc30_.z * _loc9_ > _loc30_.offset || _loc30_.x * _loc10_ + _loc30_.y * _loc11_ + _loc30_.z * _loc12_ > _loc30_.offset || _loc30_.x * _loc13_ + _loc30_.y * _loc14_ + _loc30_.z * _loc15_ > _loc30_.offset || _loc30_.x * _loc16_ + _loc30_.y * _loc17_ + _loc30_.z * _loc18_ > _loc30_.offset || _loc30_.x * _loc19_ + _loc30_.y * _loc20_ + _loc30_.z * _loc21_ > _loc30_.offset || _loc30_.x * _loc22_ + _loc30_.y * _loc23_ + _loc30_.z * _loc24_ > _loc30_.offset || _loc30_.x * _loc25_ + _loc30_.y * _loc26_ + _loc30_.z * _loc27_ > _loc30_.offset)
               {
                  break;
               }
               _loc30_ = _loc30_.next;
            }
            if(_loc30_ == null)
            {
               return true;
            }
            _loc28_++;
         }
         return false;
      }
      
      alternativa3d function checkRays(param1:Vector.<Vector3D>, param2:Vector.<Vector3D>, param3:int) : Boolean
      {
         var _loc5_:Vector3D = null;
         var _loc6_:Vector3D = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc4_:int = 0;
         while(_loc4_ < param3)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = param2[_loc4_];
            if(_loc5_.x >= this.minX && _loc5_.x <= this.maxX && _loc5_.y >= this.minY && _loc5_.y <= this.maxY && _loc5_.z >= this.minZ && _loc5_.z <= this.maxZ)
            {
               return true;
            }
            if(!(_loc5_.x < this.minX && _loc6_.x <= 0 || _loc5_.x > this.maxX && _loc6_.x >= 0 || _loc5_.y < this.minY && _loc6_.y <= 0 || _loc5_.y > this.maxY && _loc6_.y >= 0 || _loc5_.z < this.minZ && _loc6_.z <= 0 || _loc5_.z > this.maxZ && _loc6_.z >= 0))
            {
               _loc11_ = 0.000001;
               if(_loc6_.x > _loc11_)
               {
                  _loc7_ = (this.minX - _loc5_.x) / _loc6_.x;
                  _loc8_ = (this.maxX - _loc5_.x) / _loc6_.x;
               }
               else if(_loc6_.x < -_loc11_)
               {
                  _loc7_ = (this.maxX - _loc5_.x) / _loc6_.x;
                  _loc8_ = (this.minX - _loc5_.x) / _loc6_.x;
               }
               else
               {
                  _loc7_ = 0;
                  _loc8_ = 1e+22;
               }
               if(_loc6_.y > _loc11_)
               {
                  _loc9_ = (this.minY - _loc5_.y) / _loc6_.y;
                  _loc10_ = (this.maxY - _loc5_.y) / _loc6_.y;
               }
               else if(_loc6_.y < -_loc11_)
               {
                  _loc9_ = (this.maxY - _loc5_.y) / _loc6_.y;
                  _loc10_ = (this.minY - _loc5_.y) / _loc6_.y;
               }
               else
               {
                  _loc9_ = 0;
                  _loc10_ = 1e+22;
               }
               if(!(_loc9_ >= _loc8_ || _loc10_ <= _loc7_))
               {
                  if(_loc9_ < _loc7_)
                  {
                     if(_loc10_ < _loc8_)
                     {
                        _loc8_ = _loc10_;
                     }
                  }
                  else
                  {
                     _loc7_ = _loc9_;
                     if(_loc10_ < _loc8_)
                     {
                        _loc8_ = _loc10_;
                     }
                  }
                  if(_loc6_.z > _loc11_)
                  {
                     _loc9_ = (this.minZ - _loc5_.z) / _loc6_.z;
                     _loc10_ = (this.maxZ - _loc5_.z) / _loc6_.z;
                  }
                  else if(_loc6_.z < -_loc11_)
                  {
                     _loc9_ = (this.maxZ - _loc5_.z) / _loc6_.z;
                     _loc10_ = (this.minZ - _loc5_.z) / _loc6_.z;
                  }
                  else
                  {
                     _loc9_ = 0;
                     _loc10_ = 1e+22;
                  }
                  if(!(_loc9_ >= _loc8_ || _loc10_ <= _loc7_))
                  {
                     return true;
                  }
               }
            }
            _loc4_++;
         }
         return false;
      }
      
      alternativa3d function checkSphere(param1:Vector3D) : Boolean
      {
         return param1.x + param1.w > this.minX && param1.x - param1.w < this.maxX && param1.y + param1.w > this.minY && param1.y - param1.w < this.maxY && param1.z + param1.w > this.minZ && param1.z - param1.w < this.maxZ;
      }
      
      public function intersectRay(param1:Vector3D, param2:Vector3D) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param1.x >= this.minX && param1.x <= this.maxX && param1.y >= this.minY && param1.y <= this.maxY && param1.z >= this.minZ && param1.z <= this.maxZ)
         {
            return true;
         }
         if(param1.x < this.minX && param2.x <= 0)
         {
            return false;
         }
         if(param1.x > this.maxX && param2.x >= 0)
         {
            return false;
         }
         if(param1.y < this.minY && param2.y <= 0)
         {
            return false;
         }
         if(param1.y > this.maxY && param2.y >= 0)
         {
            return false;
         }
         if(param1.z < this.minZ && param2.z <= 0)
         {
            return false;
         }
         if(param1.z > this.maxZ && param2.z >= 0)
         {
            return false;
         }
         var _loc7_:Number = 0.000001;
         if(param2.x > _loc7_)
         {
            _loc3_ = (this.minX - param1.x) / param2.x;
            _loc4_ = (this.maxX - param1.x) / param2.x;
         }
         else if(param2.x < -_loc7_)
         {
            _loc3_ = (this.maxX - param1.x) / param2.x;
            _loc4_ = (this.minX - param1.x) / param2.x;
         }
         else
         {
            _loc3_ = -1e+22;
            _loc4_ = 1e+22;
         }
         if(param2.y > _loc7_)
         {
            _loc5_ = (this.minY - param1.y) / param2.y;
            _loc6_ = (this.maxY - param1.y) / param2.y;
         }
         else if(param2.y < -_loc7_)
         {
            _loc5_ = (this.maxY - param1.y) / param2.y;
            _loc6_ = (this.minY - param1.y) / param2.y;
         }
         else
         {
            _loc5_ = -1e+22;
            _loc6_ = 1e+22;
         }
         if(_loc5_ >= _loc4_ || _loc6_ <= _loc3_)
         {
            return false;
         }
         if(_loc5_ < _loc3_)
         {
            if(_loc6_ < _loc4_)
            {
               _loc4_ = _loc6_;
            }
         }
         else
         {
            _loc3_ = _loc5_;
            if(_loc6_ < _loc4_)
            {
               _loc4_ = _loc6_;
            }
         }
         if(param2.z > _loc7_)
         {
            _loc5_ = (this.minZ - param1.z) / param2.z;
            _loc6_ = (this.maxZ - param1.z) / param2.z;
         }
         else if(param2.z < -_loc7_)
         {
            _loc5_ = (this.maxZ - param1.z) / param2.z;
            _loc6_ = (this.minZ - param1.z) / param2.z;
         }
         else
         {
            _loc5_ = -1e+22;
            _loc6_ = 1e+22;
         }
         if(_loc5_ >= _loc4_ || _loc6_ <= _loc3_)
         {
            return false;
         }
         return true;
      }
      
      public function clone() : BoundBox
      {
         var _loc1_:BoundBox = new BoundBox();
         _loc1_.minX = this.minX;
         _loc1_.minY = this.minY;
         _loc1_.minZ = this.minZ;
         _loc1_.maxX = this.maxX;
         _loc1_.maxY = this.maxY;
         _loc1_.maxZ = this.maxZ;
         return _loc1_;
      }
      
      public function toString() : String
      {
         return "[BoundBox " + "X:[" + this.minX.toFixed(2) + ", " + this.maxX.toFixed(2) + "] Y:[" + this.minY.toFixed(2) + ", " + this.maxY.toFixed(2) + "] Z:[" + this.minZ.toFixed(2) + ", " + this.maxZ.toFixed(2) + "]]";
      }
   }
}

