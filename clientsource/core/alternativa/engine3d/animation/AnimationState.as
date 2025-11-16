package alternativa.engine3d.animation
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.keys.TransformKey;
   import alternativa.engine3d.core.Object3D;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class AnimationState
   {
      
      public var useCount:int = 0;
      
      public var transform:TransformKey = new TransformKey();
      
      public var transformWeightSum:Number = 0;
      
      public var numbers:Object = {};
      
      public var numberWeightSums:Object = {};
      
      public function AnimationState()
      {
         super();
      }
      
      public function reset() : void
      {
         var _loc1_:String = null;
         this.transformWeightSum = 0;
         for(_loc1_ in this.numbers)
         {
            delete this.numbers[_loc1_];
            delete this.numberWeightSums[_loc1_];
         }
      }
      
      public function addWeightedTransform(param1:TransformKey, param2:Number) : void
      {
         this.transformWeightSum += param2;
         this.transform.interpolate(this.transform,param1,param2 / this.transformWeightSum);
      }
      
      public function addWeightedNumber(param1:String, param2:Number, param3:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = Number(this.numberWeightSums[param1]);
         if(_loc4_ == _loc4_)
         {
            _loc4_ += param3;
            param3 /= _loc4_;
            _loc5_ = Number(this.numbers[param1]);
            this.numbers[param1] = (1 - param3) * _loc5_ + param3 * param2;
            this.numberWeightSums[param1] = _loc4_;
         }
         else
         {
            this.numbers[param1] = param2;
            this.numberWeightSums[param1] = param3;
         }
      }
      
      public function apply(param1:Object3D) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         if(this.transformWeightSum > 0)
         {
            param1.alternativa3d::_x = this.transform.alternativa3d::x;
            param1.alternativa3d::_y = this.transform.alternativa3d::y;
            param1.alternativa3d::_z = this.transform.alternativa3d::z;
            this.setEulerAngles(this.transform.alternativa3d::rotation,param1);
            param1.alternativa3d::_scaleX = this.transform.alternativa3d::scaleX;
            param1.alternativa3d::_scaleY = this.transform.alternativa3d::scaleY;
            param1.alternativa3d::_scaleZ = this.transform.alternativa3d::scaleZ;
            param1.alternativa3d::transformChanged = true;
         }
         for(_loc4_ in this.numbers)
         {
            switch(_loc4_)
            {
               case "x":
                  _loc2_ = Number(this.numberWeightSums["x"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.x = (1 - _loc3_) * param1.x + _loc3_ * this.numbers["x"];
                  break;
               case "y":
                  _loc2_ = Number(this.numberWeightSums["y"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.y = (1 - _loc3_) * param1.y + _loc3_ * this.numbers["y"];
                  break;
               case "z":
                  _loc2_ = Number(this.numberWeightSums["z"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.z = (1 - _loc3_) * param1.z + _loc3_ * this.numbers["z"];
                  break;
               case "rotationX":
                  _loc2_ = Number(this.numberWeightSums["rotationX"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.rotationX = (1 - _loc3_) * param1.rotationX + _loc3_ * this.numbers["rotationX"];
                  break;
               case "rotationY":
                  _loc2_ = Number(this.numberWeightSums["rotationY"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.rotationY = (1 - _loc3_) * param1.rotationY + _loc3_ * this.numbers["rotationY"];
                  break;
               case "rotationZ":
                  _loc2_ = Number(this.numberWeightSums["rotationZ"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.rotationZ = (1 - _loc3_) * param1.rotationZ + _loc3_ * this.numbers["rotationZ"];
                  break;
               case "scaleX":
                  _loc2_ = Number(this.numberWeightSums["scaleX"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.scaleX = (1 - _loc3_) * param1.scaleX + _loc3_ * this.numbers["scaleX"];
                  break;
               case "scaleY":
                  _loc2_ = Number(this.numberWeightSums["scaleY"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.scaleY = (1 - _loc3_) * param1.scaleY + _loc3_ * this.numbers["scaleY"];
                  break;
               case "scaleZ":
                  _loc2_ = Number(this.numberWeightSums["scaleZ"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.scaleZ = (1 - _loc3_) * param1.scaleZ + _loc3_ * this.numbers["scaleZ"];
                  break;
               default:
                  param1[_loc4_] = this.numbers[_loc4_];
            }
         }
      }
      
      public function applyObject(param1:Object) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         if(this.transformWeightSum > 0)
         {
            param1.x = this.transform.alternativa3d::x;
            param1.y = this.transform.alternativa3d::y;
            param1.z = this.transform.alternativa3d::z;
            this.setEulerAnglesObject(this.transform.alternativa3d::rotation,param1);
            param1.scaleX = this.transform.alternativa3d::scaleX;
            param1.scaleY = this.transform.alternativa3d::scaleY;
            param1.scaleZ = this.transform.alternativa3d::scaleZ;
         }
         for(_loc4_ in this.numbers)
         {
            switch(_loc4_)
            {
               case "x":
                  _loc2_ = Number(this.numberWeightSums["x"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.x = (1 - _loc3_) * param1.x + _loc3_ * this.numbers["x"];
                  break;
               case "y":
                  _loc2_ = Number(this.numberWeightSums["y"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.y = (1 - _loc3_) * param1.y + _loc3_ * this.numbers["y"];
                  break;
               case "z":
                  _loc2_ = Number(this.numberWeightSums["z"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.z = (1 - _loc3_) * param1.z + _loc3_ * this.numbers["z"];
                  break;
               case "rotationX":
                  _loc2_ = Number(this.numberWeightSums["rotationX"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.rotationX = (1 - _loc3_) * param1.rotationX + _loc3_ * this.numbers["rotationX"];
                  break;
               case "rotationY":
                  _loc2_ = Number(this.numberWeightSums["rotationY"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.rotationY = (1 - _loc3_) * param1.rotationY + _loc3_ * this.numbers["rotationY"];
                  break;
               case "rotationZ":
                  _loc2_ = Number(this.numberWeightSums["rotationZ"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.rotationZ = (1 - _loc3_) * param1.rotationZ + _loc3_ * this.numbers["rotationZ"];
                  break;
               case "scaleX":
                  _loc2_ = Number(this.numberWeightSums["scaleX"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.scaleX = (1 - _loc3_) * param1.scaleX + _loc3_ * this.numbers["scaleX"];
                  break;
               case "scaleY":
                  _loc2_ = Number(this.numberWeightSums["scaleY"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.scaleY = (1 - _loc3_) * param1.scaleY + _loc3_ * this.numbers["scaleY"];
                  break;
               case "scaleZ":
                  _loc2_ = Number(this.numberWeightSums["scaleZ"]);
                  _loc3_ = _loc2_ / (_loc2_ + this.transformWeightSum);
                  param1.scaleZ = (1 - _loc3_) * param1.scaleZ + _loc3_ * this.numbers["scaleZ"];
                  break;
               default:
                  param1[_loc4_] = this.numbers[_loc4_];
            }
         }
      }
      
      private function setEulerAngles(param1:Vector3D, param2:Object3D) : void
      {
         var _loc3_:Number = 2 * param1.x * param1.x;
         var _loc4_:Number = 2 * param1.y * param1.y;
         var _loc5_:Number = 2 * param1.z * param1.z;
         var _loc6_:Number = 2 * param1.x * param1.y;
         var _loc7_:Number = 2 * param1.y * param1.z;
         var _loc8_:Number = 2 * param1.z * param1.x;
         var _loc9_:Number = 2 * param1.w * param1.x;
         var _loc10_:Number = 2 * param1.w * param1.y;
         var _loc11_:Number = 2 * param1.w * param1.z;
         var _loc12_:Number = 1 - _loc4_ - _loc5_;
         var _loc13_:Number = _loc6_ - _loc11_;
         var _loc14_:Number = _loc6_ + _loc11_;
         var _loc15_:Number = 1 - _loc3_ - _loc5_;
         var _loc16_:Number = _loc8_ - _loc10_;
         var _loc17_:Number = _loc7_ + _loc9_;
         var _loc18_:Number = 1 - _loc3_ - _loc4_;
         if(-1 < _loc16_ && _loc16_ < 1)
         {
            param2.alternativa3d::_rotationX = Math.atan2(_loc17_,_loc18_);
            param2.alternativa3d::_rotationY = -Math.asin(_loc16_);
            param2.alternativa3d::_rotationZ = Math.atan2(_loc14_,_loc12_);
         }
         else
         {
            param2.alternativa3d::_rotationX = 0;
            param2.alternativa3d::_rotationY = _loc16_ <= -1 ? Math.PI : -Math.PI;
            param2.alternativa3d::_rotationY *= 0.5;
            param2.alternativa3d::_rotationZ = Math.atan2(-_loc13_,_loc15_);
         }
      }
      
      private function setEulerAnglesObject(param1:Vector3D, param2:Object) : void
      {
         var _loc3_:Number = 2 * param1.x * param1.x;
         var _loc4_:Number = 2 * param1.y * param1.y;
         var _loc5_:Number = 2 * param1.z * param1.z;
         var _loc6_:Number = 2 * param1.x * param1.y;
         var _loc7_:Number = 2 * param1.y * param1.z;
         var _loc8_:Number = 2 * param1.z * param1.x;
         var _loc9_:Number = 2 * param1.w * param1.x;
         var _loc10_:Number = 2 * param1.w * param1.y;
         var _loc11_:Number = 2 * param1.w * param1.z;
         var _loc12_:Number = 1 - _loc4_ - _loc5_;
         var _loc13_:Number = _loc6_ - _loc11_;
         var _loc14_:Number = _loc6_ + _loc11_;
         var _loc15_:Number = 1 - _loc3_ - _loc5_;
         var _loc16_:Number = _loc8_ - _loc10_;
         var _loc17_:Number = _loc7_ + _loc9_;
         var _loc18_:Number = 1 - _loc3_ - _loc4_;
         if(-1 < _loc16_ && _loc16_ < 1)
         {
            param2.rotationX = Math.atan2(_loc17_,_loc18_);
            param2.rotationY = -Math.asin(_loc16_);
            param2.rotationZ = Math.atan2(_loc14_,_loc12_);
         }
         else
         {
            param2.rotationX = 0;
            param2.rotationY = _loc16_ <= -1 ? Math.PI : -Math.PI;
            param2.rotationY *= 0.5;
            param2.rotationZ = Math.atan2(-_loc13_,_loc15_);
         }
      }
   }
}

