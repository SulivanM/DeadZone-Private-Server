package com.deadreckoned.threshold.geom
{
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   public class Quaternion
   {
      
      private static const EPSILON:Number = 0.00001;
      
      private static var _tmpQA:Quaternion = new Quaternion();
      
      private static var _tmpQB:Quaternion = new Quaternion();
      
      private static var _tmpMat:Matrix3D = new Matrix3D();
      
      private static var _tmpMatRaw:Vector.<Number> = new Vector.<Number>(16,true);
      
      private static var _tmpX:Vector3D = new Vector3D();
      
      private static var _tmpY:Vector3D = new Vector3D();
      
      private static var _tmpZ:Vector3D = new Vector3D();
      
      public var x:Number = 0;
      
      public var y:Number = 0;
      
      public var z:Number = 0;
      
      public var w:Number = 1;
      
      public function Quaternion(... rest)
      {
         super();
         if(rest.length == 0)
         {
            return;
         }
         if(rest[0] is Number)
         {
            if(rest.length < 4)
            {
               throw new ArgumentError("Incorrect number of parameters supplied. Must be 4 number values, got " + rest.length);
            }
            this.x = Number(rest[0]);
            this.y = Number(rest[1]);
            this.z = Number(rest[2]);
            this.w = Number(rest[3]);
            return;
         }
         if(rest[0] is Vector3D)
         {
            if(rest.length == 1 || rest[1] == null)
            {
               this.setFromVector(Vector3D(rest[0]));
            }
            else if(rest[1] is Number)
            {
               this.setFromAxisAngle(Vector3D(rest[0]),Number(rest[1]));
            }
            else
            {
               if(!(rest[1] is Vector3D))
               {
                  throw new ArgumentError("Unsupported Vector3D parameter combination supplied.");
               }
               this.setFromDirection(Vector3D(rest[0]),Vector3D(rest[1]));
            }
            return;
         }
         if(rest[0] is Matrix3D)
         {
            this.setFromMatrix(Matrix3D(rest[0]));
            return;
         }
         throw new ArgumentError("Unsupported parameter combination supplied.");
      }
      
      public static function slerp(param1:Quaternion, param2:Quaternion, param3:Number) : Quaternion
      {
         return new Quaternion().slerp(param1,param2,param3);
      }
      
      public function add(param1:Quaternion) : Quaternion
      {
         this.x += param1.x;
         this.y += param1.y;
         this.z += param1.z;
         this.w += param1.w;
         return this;
      }
      
      public function clone() : Quaternion
      {
         var _loc1_:Quaternion = new Quaternion();
         _loc1_.x = this.x;
         _loc1_.y = this.y;
         _loc1_.z = this.z;
         _loc1_.w = this.w;
         return _loc1_;
      }
      
      public function conjugate() : Quaternion
      {
         this.x = -this.x;
         this.y = -this.y;
         this.z = -this.z;
         return this;
      }
      
      public function copyFrom(param1:Quaternion) : Quaternion
      {
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
         this.w = param1.w;
         return this;
      }
      
      public function copyTo(param1:Quaternion) : Quaternion
      {
         param1.x = this.x;
         param1.y = this.y;
         param1.z = this.z;
         param1.w = this.w;
         return this;
      }
      
      public function dotProduct(param1:Quaternion) : Number
      {
         return this.x * param1.x + this.y * param1.y + this.z * param1.z + this.w * param1.w;
      }
      
      public function equals(param1:Quaternion) : Boolean
      {
         return Boolean(this.x == param1.x && this.y == param1.y && this.z == param1.z && this.w == param1.w);
      }
      
      public function fuzzyEquals(param1:Quaternion, param2:Number = 0) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param2 > 0)
         {
            _loc3_ = param1.x - this.x;
            if(_loc3_ < 0)
            {
               _loc3_ = -_loc3_;
            }
            _loc4_ = param1.y - this.y;
            if(_loc4_ < 0)
            {
               _loc4_ = -_loc4_;
            }
            _loc5_ = param1.z - this.z;
            if(_loc5_ < 0)
            {
               _loc5_ = -_loc5_;
            }
            _loc6_ = param1.w - this.w;
            if(_loc6_ < 0)
            {
               _loc6_ = -_loc6_;
            }
            if(_loc3_ > param2)
            {
               return false;
            }
            if(_loc4_ > param2)
            {
               return false;
            }
            if(_loc5_ > param2)
            {
               return false;
            }
            if(_loc6_ > param2)
            {
               return false;
            }
            return true;
         }
         return Boolean(this.x == param1.x && this.y == param1.y && this.z == param1.z && this.w == param1.w);
      }
      
      public function identity() : Quaternion
      {
         this.x = 0;
         this.y = 0;
         this.z = 0;
         this.w = 1;
         return this;
      }
      
      public function invert() : Quaternion
      {
         var _loc1_:Number = this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w;
         if(_loc1_ > 0)
         {
            _loc1_ = 1 / _loc1_;
            this.x *= _loc1_;
            this.y *= _loc1_;
            this.z *= _loc1_;
            this.w *= _loc1_;
         }
         this.x = -this.x;
         this.y = -this.y;
         this.z = -this.z;
         return this;
      }
      
      public function isIdentity() : Boolean
      {
         return this.x == 0 && this.y == 0 && this.z == 0 && this.w == 1;
      }
      
      public function lookAt(param1:Vector3D, param2:Vector3D) : Quaternion
      {
         var _loc6_:Number = NaN;
         var _loc3_:Vector3D = _tmpZ;
         _loc3_.x = param1.x;
         _loc3_.y = param1.y;
         _loc3_.z = param1.z;
         if(_loc3_.x == 0)
         {
            _loc3_.x = EPSILON;
         }
         if(_loc3_.y == 0)
         {
            _loc3_.y = EPSILON;
         }
         if(_loc3_.z == 0)
         {
            _loc3_.z = EPSILON;
         }
         _loc3_.normalize();
         var _loc4_:Vector3D = _tmpX;
         _loc4_.x = param2.y * _loc3_.z - param2.z * _loc3_.y;
         _loc4_.y = param2.z * _loc3_.x - param2.x * _loc3_.z;
         _loc4_.z = param2.x * _loc3_.y - param2.y * _loc3_.x;
         _loc4_.normalize();
         var _loc5_:Vector3D = _tmpY;
         _loc5_.x = param1.y * _loc4_.z - param1.z * _loc4_.y;
         _loc5_.y = param1.z * _loc4_.x - param1.x * _loc4_.z;
         _loc5_.z = param1.x * _loc4_.y - param1.y * _loc4_.x;
         _loc5_.normalize();
         var _loc7_:Number = _loc4_.x + _loc5_.y + _loc3_.z;
         if(_loc7_ >= 0)
         {
            _loc6_ = Math.sqrt(_loc7_ + 1);
            this.w = 0.5 * _loc6_;
            _loc6_ = 0.5 / _loc6_;
            this.x = (_loc5_.z - _loc3_.y) * _loc6_;
            this.y = (_loc3_.x - _loc4_.z) * _loc6_;
            this.z = (_loc4_.y - _loc5_.x) * _loc6_;
         }
         else if(_loc4_.x > _loc5_.y && _loc4_.x > _loc3_.z)
         {
            _loc6_ = Math.sqrt(1 + _loc4_.x - _loc5_.y - _loc3_.z);
            this.x = 0.5 * _loc6_;
            _loc6_ = 0.5 / _loc6_;
            this.y = (_loc5_.x + _loc4_.y) * _loc6_;
            this.z = (_loc3_.x + _loc4_.z) * _loc6_;
            this.w = (_loc5_.z - _loc3_.y) * _loc6_;
         }
         else if(_loc5_.y > _loc3_.z)
         {
            _loc6_ = Math.sqrt(1 + _loc5_.y - _loc4_.x - _loc3_.z);
            this.y = 0.5 * _loc6_;
            _loc6_ = 0.5 / _loc6_;
            this.x = (_loc4_.y + _loc5_.x) * _loc6_;
            this.z = (_loc5_.z + _loc3_.y) * _loc6_;
            this.w = (_loc3_.x - _loc4_.z) * _loc6_;
         }
         else
         {
            _loc6_ = Math.sqrt(1 + _loc3_.z - _loc4_.x - _loc5_.y);
            this.z = 0.5 * _loc6_;
            _loc6_ = 0.5 / _loc6_;
            this.x = (_loc3_.x + _loc4_.z) * _loc6_;
            this.y = (_loc3_.y + _loc5_.z) * _loc6_;
            this.w = (_loc4_.y - _loc5_.x) * _loc6_;
         }
         this.normalize();
         return this;
      }
      
      public function length() : Number
      {
         var _loc1_:Number = this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w;
         if(_loc1_ > 0)
         {
            return Math.sqrt(_loc1_);
         }
         return 0;
      }
      
      public function multiply(param1:Quaternion) : Quaternion
      {
         var _loc2_:Number = this.w * param1.x + this.x * param1.w + this.y * param1.z - this.z * param1.y;
         var _loc3_:Number = this.w * param1.y + this.y * param1.w + this.z * param1.x - this.x * param1.z;
         var _loc4_:Number = this.w * param1.z + this.z * param1.w + this.x * param1.y - this.y * param1.x;
         var _loc5_:Number = this.w * param1.w - this.x * param1.x - this.y * param1.y - this.z * param1.z;
         this.x = _loc2_;
         this.y = _loc3_;
         this.z = _loc4_;
         this.w = _loc5_;
         return this;
      }
      
      public function norm() : Number
      {
         return this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w;
      }
      
      public function normalize(param1:Number = 0) : Quaternion
      {
         var _loc2_:Number = this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w;
         if(_loc2_ > 0)
         {
            if(param1 <= 0 || _loc2_ > 1 + param1 || _loc2_ < 1 - param1)
            {
               _loc2_ = 1 / Math.sqrt(_loc2_);
               this.x *= _loc2_;
               this.y *= _loc2_;
               this.z *= _loc2_;
               this.w *= _loc2_;
            }
         }
         else
         {
            this.x = this.y = this.z = 0;
            this.w = 1;
         }
         return this;
      }
      
      public function transformVector(param1:Vector3D, param2:Vector3D = null) : Vector3D
      {
         param2 ||= new Vector3D();
         var _loc3_:Quaternion = _tmpQA;
         _loc3_.x = param1.x;
         _loc3_.y = param1.y;
         _loc3_.z = param1.z;
         _loc3_.w = 0;
         var _loc4_:Quaternion = _tmpQB;
         _loc4_.x = this.x;
         _loc4_.y = this.y;
         _loc4_.z = this.z;
         _loc4_.w = this.w;
         _loc4_.invert();
         _loc4_.multiply(_loc3_);
         _loc4_.multiply(this);
         param2.x = _loc4_.x;
         param2.y = _loc4_.y;
         param2.z = _loc4_.z;
         return param2;
      }
      
      public function scale(param1:Number) : Quaternion
      {
         this.x *= param1;
         this.y *= param1;
         this.z *= param1;
         this.w *= param1;
         return this;
      }
      
      public function setFromAxes(param1:Vector3D, param2:Vector3D, param3:Vector3D) : Quaternion
      {
         _tmpMat.copyRawDataFrom(Vector.<Number>([param1.x,param2.x,param3.x,0,param1.y,param2.y,param3.y,0,param1.z,param2.z,param3.z,0,0,0,0,1]));
         return this.setFromMatrix(_tmpMat);
      }
      
      public function setFromAxisAngle(param1:Vector3D, param2:Number) : Quaternion
      {
         var _loc3_:Number = Math.sin(param2 * 0.5);
         var _loc4_:Number = Math.cos(param2 * 0.5);
         this.x = param1.x * _loc3_;
         this.y = param1.y * _loc3_;
         this.z = param1.z * _loc3_;
         this.w = _loc4_;
         this.normalize();
         return this;
      }
      
      public function setFromDirection(param1:Vector3D, param2:Vector3D) : Quaternion
      {
         this.x = param1.x * param2.x;
         this.y = param1.y * param2.y;
         this.z = param1.z * param2.z;
         this.w = param1.x * param2.x + param1.y * param2.y + param1.z * param2.z;
         this.normalize();
         this.w += 1;
         if(this.w <= EPSILON)
         {
            if(param1.z * param1.z > param1.x * param1.x)
            {
               this.x = 0;
               this.y = param1.z;
               this.z = -param1.y;
            }
            else
            {
               this.x = param1.y;
               this.y = -param1.x;
               this.z = 0;
            }
         }
         this.normalize();
         return this;
      }
      
      public function setFromEulerAngles(param1:Number, param2:Number, param3:Number, param4:Boolean = false) : Quaternion
      {
         if(param4)
         {
            param1 *= Math.PI / 180;
            param2 *= Math.PI / 180;
            param3 *= Math.PI / 180;
         }
         param1 *= 0.5;
         param2 *= 0.5;
         param3 *= 0.5;
         var _loc5_:Number = Math.cos(param1);
         var _loc6_:Number = Math.cos(param2);
         var _loc7_:Number = Math.cos(param3);
         var _loc8_:Number = Math.sin(param2);
         var _loc9_:Number = Math.sin(param1);
         var _loc10_:Number = Math.sin(param3);
         this.w = _loc7_ * _loc6_ * _loc5_ + _loc10_ * _loc8_ * _loc9_;
         this.x = _loc7_ * _loc6_ * _loc9_ - _loc10_ * _loc8_ * _loc5_;
         this.y = _loc7_ * _loc8_ * _loc5_ + _loc10_ * _loc6_ * _loc9_;
         this.z = _loc10_ * _loc6_ * _loc5_ - _loc7_ * _loc8_ * _loc9_;
         return this;
      }
      
      public function setFromMatrix(param1:Matrix3D) : Quaternion
      {
         var _loc3_:Number = NaN;
         param1.copyRawDataTo(_tmpMatRaw);
         var _loc2_:Vector.<Number> = _tmpMatRaw;
         var _loc4_:Number = _loc2_[0] + _loc2_[5] + _loc2_[10];
         if(_loc4_ >= 0)
         {
            _loc3_ = Math.sqrt(_loc4_ + 1);
            this.w = 0.5 * _loc3_;
            _loc3_ = 0.5 / _loc3_;
            this.x = (_loc2_[9] - _loc2_[6]) * _loc3_;
            this.y = (_loc2_[2] - _loc2_[8]) * _loc3_;
            this.z = (_loc2_[4] - _loc2_[1]) * _loc3_;
         }
         else if(_loc2_[0] > _loc2_[5] && _loc2_[0] > _loc2_[10])
         {
            _loc3_ = Math.sqrt(1 + _loc2_[0] - _loc2_[5] - _loc2_[10]);
            this.x = 0.5 * _loc3_;
            _loc3_ = 0.5 / _loc3_;
            this.y = (_loc2_[1] + _loc2_[4]) * _loc3_;
            this.z = (_loc2_[2] + _loc2_[8]) * _loc3_;
            this.w = (_loc2_[9] - _loc2_[6]) * _loc3_;
         }
         else if(_loc2_[5] > _loc2_[10])
         {
            _loc3_ = Math.sqrt(1 + _loc2_[5] - _loc2_[0] - _loc2_[10]);
            this.y = 0.5 * _loc3_;
            _loc3_ = 0.5 / _loc3_;
            this.x = (_loc2_[4] + _loc2_[1]) * _loc3_;
            this.z = (_loc2_[9] + _loc2_[6]) * _loc3_;
            this.w = (_loc2_[2] - _loc2_[8]) * _loc3_;
         }
         else
         {
            _loc3_ = Math.sqrt(1 + _loc2_[10] - _loc2_[0] - _loc2_[5]);
            this.z = 0.5 * _loc3_;
            _loc3_ = 0.5 / _loc3_;
            this.x = (_loc2_[2] + _loc2_[8]) * _loc3_;
            this.y = (_loc2_[6] + _loc2_[9]) * _loc3_;
            this.w = (_loc2_[4] - _loc2_[1]) * _loc3_;
         }
         this.normalize();
         return this;
      }
      
      public function setFromVector(param1:Vector3D) : Quaternion
      {
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
         this.w = param1.w;
         return this;
      }
      
      public function lerp(param1:Quaternion, param2:Quaternion, param3:Number) : Quaternion
      {
         var _loc4_:Number = 1 - param3;
         this.x = param1.x * _loc4_ + param2.x * param3;
         this.y = param1.y * _loc4_ + param2.y * param3;
         this.z = param1.z * _loc4_ + param2.z * param3;
         this.w = param1.w * _loc4_ + param2.w * param3;
         this.normalize();
         return this;
      }
      
      public function slerp(param1:Quaternion, param2:Quaternion, param3:Number) : Quaternion
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc4_:Number = param1.x * param2.x + param1.y * param2.y + param1.z * param2.z + param1.w * param2.w;
         if(_loc4_ < 0)
         {
            _loc4_ = -_loc4_;
            this.x = -param2.x;
            this.y = -param2.y;
            this.z = -param2.z;
            this.w = -param2.w;
         }
         else
         {
            this.x = param2.x;
            this.y = param2.y;
            this.z = param2.z;
            this.w = param2.w;
         }
         if(_loc4_ < 0.95)
         {
            _loc5_ = Math.acos(_loc4_);
            _loc6_ = Math.sin(_loc5_ * (1 - param3));
            _loc7_ = Math.sin(_loc5_ * param3);
            _loc8_ = Math.sin(_loc5_);
            this.x = (param1.x * _loc6_ + this.x * _loc7_) / _loc8_;
            this.y = (param1.y * _loc6_ + this.y * _loc7_) / _loc8_;
            this.z = (param1.z * _loc6_ + this.z * _loc7_) / _loc8_;
            this.w = (param1.w * _loc6_ + this.w * _loc7_) / _loc8_;
            return this;
         }
         return this.lerp(param1,this,param3);
      }
      
      public function squad(param1:Quaternion, param2:Quaternion, param3:Quaternion, param4:Quaternion, param5:Number) : Quaternion
      {
         var _loc6_:Quaternion = new Quaternion().slerpNoInvert(param1,param2,param5);
         var _loc7_:Quaternion = new Quaternion().slerpNoInvert(param3,param4,param5);
         return this.slerpNoInvert(_loc6_,_loc7_,2 * param5 * (1 - param5));
      }
      
      public function subtract(param1:Quaternion) : Quaternion
      {
         this.x -= param1.x;
         this.y -= param1.y;
         this.z -= param1.z;
         this.w -= param1.w;
         return this;
      }
      
      public function toAxisAngle(param1:Vector3D) : Number
      {
         var _loc2_:Number = Math.sqrt(1 - this.w * this.w);
         var _loc3_:Number = _loc2_ < 0 ? -_loc2_ : _loc2_;
         if(_loc3_ < 0.0005)
         {
            _loc3_ = 1;
         }
         param1.x = this.x / _loc2_;
         param1.y = this.y / _loc2_;
         param1.z = this.z / _loc2_;
         return Math.acos(this.w) * 2;
      }
      
      public function toEulerAngles(param1:Vector3D = null) : Vector3D
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(param1 == null)
         {
            param1 = new Vector3D();
         }
         var _loc2_:Number = this.w * this.w;
         var _loc3_:Number = this.x * this.x;
         var _loc4_:Number = this.y * this.y;
         var _loc5_:Number = this.z * this.z;
         var _loc6_:Number = _loc3_ + _loc4_ + _loc5_ + _loc2_;
         var _loc7_:Number = this.x * this.w - this.y * this.z;
         if(_loc7_ > 0.4999999 * _loc6_)
         {
            param1.x = Math.PI * 0.5;
            param1.y = 2 * Math.atan2(this.y,this.w);
            param1.z = 0;
         }
         else if(_loc7_ < -0.4999999 * _loc6_)
         {
            param1.x = -Math.PI * 0.5;
            param1.y = 2 * Math.atan2(this.y,this.w);
            param1.z = 0;
         }
         else
         {
            _loc8_ = 2 * (this.x * this.z + this.y * this.w);
            _loc9_ = 1 - 2 * (_loc4_ + _loc3_);
            _loc10_ = 2 * (this.x * this.y + this.z * this.w);
            _loc11_ = 1 - 2 * (_loc3_ + _loc5_);
            param1.x = Math.asin(2 * _loc7_);
            param1.y = Math.atan2(_loc8_,_loc9_);
            param1.z = Math.atan2(_loc10_,_loc11_);
         }
         return param1;
      }
      
      public function toMatrixRaw(param1:Vector.<Number>) : Vector.<Number>
      {
         param1 ||= new Vector.<Number>(16,true);
         param1[0] = 1 - 2 * (this.y * this.y + this.z * this.z);
         param1[1] = 2 * (this.x * this.y + this.z * this.w);
         param1[2] = 2 * (this.x * this.z - this.y * this.w);
         param1[4] = 2 * (this.x * this.y - this.z * this.w);
         param1[5] = 1 - 2 * (this.x * this.x + this.z * this.z);
         param1[6] = 2 * (this.y * this.z + this.x * this.w);
         param1[8] = 2 * (this.x * this.z + this.y * this.w);
         param1[9] = 2 * (this.y * this.z - this.x * this.w);
         param1[10] = 1 - 2 * (this.x * this.x + this.y * this.y);
         param1[3] = 0;
         param1[7] = 0;
         param1[11] = 0;
         param1[12] = 0;
         param1[13] = 0;
         param1[14] = 0;
         param1[15] = 1;
         return param1;
      }
      
      public function toMatrix(param1:Matrix3D = null) : Matrix3D
      {
         param1 ||= new Matrix3D();
         param1.copyRawDataTo(_tmpMatRaw);
         var _loc2_:Vector.<Number> = _tmpMatRaw;
         _loc2_[0] = 1 - 2 * (this.y * this.y + this.z * this.z);
         _loc2_[1] = 2 * (this.x * this.y + this.z * this.w);
         _loc2_[2] = 2 * (this.x * this.z - this.y * this.w);
         _loc2_[4] = 2 * (this.x * this.y - this.z * this.w);
         _loc2_[5] = 1 - 2 * (this.x * this.x + this.z * this.z);
         _loc2_[6] = 2 * (this.y * this.z + this.x * this.w);
         _loc2_[8] = 2 * (this.x * this.z + this.y * this.w);
         _loc2_[9] = 2 * (this.y * this.z - this.x * this.w);
         _loc2_[10] = 1 - 2 * (this.x * this.x + this.y * this.y);
         _loc2_[3] = 0;
         _loc2_[7] = 0;
         _loc2_[11] = 0;
         _loc2_[12] = 0;
         _loc2_[13] = 0;
         _loc2_[14] = 0;
         _loc2_[15] = 1;
         param1.copyRawDataFrom(_loc2_);
         return param1;
      }
      
      public function toString() : String
      {
         return "Quaternion(x=" + this.x + ", y=" + this.y + ", z=" + this.z + ", w=" + this.w + ")";
      }
      
      public function toVector3D() : Vector3D
      {
         return new Vector3D(this.x,this.y,this.z,this.w);
      }
      
      private function slerpNoInvert(param1:Quaternion, param2:Quaternion, param3:Number) : Quaternion
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc4_:Number = param1.x * param2.x + param1.y * param2.y + param1.z * param2.z + param1.w * param2.w;
         if(_loc4_ > -0.95 && _loc4_ < 0.95)
         {
            _loc5_ = Math.acos(_loc4_);
            _loc6_ = Math.sin(_loc5_ * (1 - param3));
            _loc7_ = Math.sin(_loc5_ * param3);
            _loc8_ = Math.sin(_loc5_);
            this.x = (param1.x * _loc6_ + param2.x * _loc7_) / _loc8_;
            this.y = (param1.y * _loc6_ + param2.y * _loc7_) / _loc8_;
            this.z = (param1.z * _loc6_ + param2.z * _loc7_) / _loc8_;
            this.w = (param1.w * _loc6_ + param2.w * _loc7_) / _loc8_;
            return this;
         }
         return this.lerp(param1,this,param3);
      }
   }
}

