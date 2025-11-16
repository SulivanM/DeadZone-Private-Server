package thelaststand.engine.geom
{
   import com.deadreckoned.threshold.geom.Quaternion;
   import com.deadreckoned.threshold.ns.threshold;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace threshold;
   
   public class Transform
   {
      
      private static var _tmpMat:Matrix3D = new Matrix3D();
      
      private static var _tmpMatA:Vector.<Number> = new Vector.<Number>(16,true);
      
      private static var _tmpMatB:Vector.<Number> = new Vector.<Number>(16,true);
      
      private static var _tmpVec:Vector3D = new Vector3D();
      
      public static const VECTOR_ZERO:Vector3D = new Vector3D(0,0,0);
      
      public static const VECTOR_ONE:Vector3D = new Vector3D(1,1,1);
      
      public static var up:Vector3D = new Vector3D(0,0,1);
      
      public static var side:Vector3D = new Vector3D(1,0,0);
      
      public static var forward:Vector3D = new Vector3D(0,1,0);
      
      private var _forward:Vector3D;
      
      private var _side:Vector3D;
      
      private var _up:Vector3D;
      
      threshold var _rotation:Matrix3D;
      
      threshold var _position:Vector3D;
      
      threshold var _scale:Vector3D;
      
      threshold var _matrix:Matrix3D;
      
      public function Transform(param1:Vector3D = null, param2:Matrix3D = null, param3:Vector3D = null)
      {
         super();
         this.threshold::_matrix = new Matrix3D();
         this.threshold::_rotation = param2 || new Matrix3D();
         this.threshold::_position = param1 || new Vector3D();
         this.threshold::_scale = param3 || new Vector3D(1,1,1);
         if(param2 == null)
         {
            this._forward = Transform.forward.clone();
            this._side = Transform.side.clone();
            this._up = Transform.up.clone();
            this.threshold::_rotation.copyColumnFrom(0,this._side);
            this.threshold::_rotation.copyColumnFrom(1,this._forward);
            this.threshold::_rotation.copyColumnFrom(2,this._up);
         }
         else
         {
            this._forward = new Vector3D();
            this._side = new Vector3D();
            this._up = new Vector3D();
         }
      }
      
      public static function defaultToLHS() : void
      {
         forward.setTo(0,0,1);
         side.setTo(1,0,0);
         up.setTo(0,1,0);
      }
      
      public static function defaultToRHS() : void
      {
         forward.setTo(0,0,-1);
         side.setTo(1,0,0);
         up.setTo(0,1,0);
      }
      
      public static function buildForwardRotationMatrix(param1:Vector3D, param2:Vector3D = null, param3:Boolean = false, param4:Matrix3D = null) : Matrix3D
      {
         param4 ||= new Matrix3D();
         var _loc5_:Vector3D = _tmpVec;
         _loc5_.copyFrom(param1);
         _loc5_.normalize();
         if(param3)
         {
            _loc5_.negate();
         }
         param4.copyColumnFrom(1,_loc5_);
         var _loc6_:Vector3D = _loc5_.crossProduct(param2 || Transform.up);
         _loc6_.normalize();
         param4.copyColumnFrom(0,_loc6_);
         var _loc7_:Vector3D = _loc6_.crossProduct(_loc5_);
         _loc7_.normalize();
         param4.copyColumnFrom(2,_loc7_);
         return param4;
      }
      
      public function get forward() : Vector3D
      {
         this.threshold::_rotation.copyColumnTo(1,this._forward);
         return this._forward;
      }
      
      public function get side() : Vector3D
      {
         this.threshold::_rotation.copyColumnTo(0,this._side);
         return this._side;
      }
      
      public function get up() : Vector3D
      {
         this.threshold::_rotation.copyColumnTo(2,this._up);
         return this._up;
      }
      
      public function get matrix() : Matrix3D
      {
         this.threshold::_position.w = 1;
         this.threshold::_matrix.copyFrom(this.threshold::_rotation);
         this.threshold::_matrix.copyColumnFrom(3,this.threshold::_position);
         this.threshold::_matrix.prependScale(this.threshold::_scale.x,this.threshold::_scale.y,this.threshold::_scale.z);
         return this.threshold::_matrix;
      }
      
      public function get rotation() : Matrix3D
      {
         return this.threshold::_rotation;
      }
      
      public function get position() : Vector3D
      {
         return this.threshold::_position;
      }
      
      public function get scale() : Vector3D
      {
         return this.threshold::_scale;
      }
      
      public function clone() : Transform
      {
         var _loc1_:Transform = new Transform();
         _loc1_.threshold::_position.copyFrom(this.threshold::_position);
         _loc1_.threshold::_rotation.copyFrom(this.threshold::_rotation);
         _loc1_.threshold::_scale.copyFrom(this.threshold::_scale);
         return _loc1_;
      }
      
      public function copyFrom(param1:Transform) : Transform
      {
         this.threshold::_position.copyFrom(param1.threshold::_position);
         this.threshold::_rotation.copyFrom(param1.threshold::_rotation);
         this.threshold::_scale.copyFrom(param1.threshold::_scale);
         return this;
      }
      
      public function copyTo(param1:Transform) : Transform
      {
         param1.threshold::_position.copyFrom(this.threshold::_position);
         param1.threshold::_rotation.copyFrom(this.threshold::_rotation);
         param1.threshold::_scale.copyFrom(this.threshold::_scale);
         return this;
      }
      
      public function equals(param1:Transform, param2:Number = 0) : Boolean
      {
         return this.threshold::_position.nearEquals(param1.threshold::_position,param2) && this.threshold::_scale.nearEquals(param1.threshold::_scale,param2) && this.rotationEquals(param1.threshold::_rotation,param2);
      }
      
      public function identity() : Transform
      {
         this.threshold::_position.x = this.threshold::_position.y = this.threshold::_position.z = 0;
         this.threshold::_scale.x = this.threshold::_scale.y = this.threshold::_scale.z = 1;
         this._forward.copyFrom(Transform.forward);
         this._side.copyFrom(Transform.side);
         this._up.copyFrom(Transform.up);
         this.threshold::_rotation.identity();
         this.threshold::_rotation.copyColumnFrom(0,this._side);
         this.threshold::_rotation.copyColumnFrom(1,this._forward);
         this.threshold::_rotation.copyColumnFrom(2,this._up);
         return this;
      }
      
      public function lookAt(param1:Vector3D, param2:Vector3D = null, param3:Vector3D = null) : Transform
      {
         _tmpVec.x = param1.x - this.threshold::_position.x;
         _tmpVec.y = param1.y - this.threshold::_position.y;
         _tmpVec.z = param1.z - this.threshold::_position.z;
         this.threshold::_rotation.pointAt(_tmpVec,param2 || Transform.forward,param3 || Transform.up);
         return this;
      }
      
      public function rotate(param1:Number, param2:Number, param3:Number, param4:Boolean = false) : Transform
      {
         if(param4)
         {
            param1 *= Math.PI / 180;
            param2 *= Math.PI / 180;
            param3 *= Math.PI / 180;
         }
         var _loc5_:Vector3D = this.threshold::_rotation.decompose()[1];
         _loc5_.x += param1;
         _loc5_.y += param2;
         _loc5_.z += param3;
         this.threshold::_rotation.identity();
         this.threshold::_rotation.recompose(Vector.<Vector3D>([VECTOR_ZERO,_loc5_,VECTOR_ONE]));
         return this;
      }
      
      public function rotateAround(param1:Vector3D, param2:Number, param3:Boolean = false) : Transform
      {
         this.threshold::_rotation.appendRotation(param3 ? param2 : param2 * 180 / Math.PI,param1);
         return this;
      }
      
      public function rotateByQuaternion(param1:Quaternion) : Transform
      {
         this.threshold::_rotation.append(param1.toMatrix(_tmpMat));
         return this;
      }
      
      public function rotationEquals(param1:Matrix3D, param2:Number = 0) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         this.threshold::_rotation.copyRawDataTo(_tmpMatA);
         param1.copyRawDataTo(_tmpMatB);
         var _loc3_:int = 0;
         while(_loc3_ < 16)
         {
            _loc4_ = _tmpMatA[_loc3_];
            _loc5_ = _tmpMatB[_loc3_];
            if(_loc4_ < _loc5_ - param2 || _loc4_ > _loc5_ + param2)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function scaleBy(param1:Number, param2:Number, param3:Number) : Transform
      {
         this.threshold::_scale.x += param1;
         this.threshold::_scale.y += param2;
         this.threshold::_scale.z += param3;
         return this;
      }
      
      public function scaleByUniform(param1:Number) : Transform
      {
         this.threshold::_scale.x += param1;
         this.threshold::_scale.y += param1;
         this.threshold::_scale.z += param1;
         return this;
      }
      
      public function translate(param1:Number, param2:Number, param3:Number) : Transform
      {
         this.threshold::_position.x += param1;
         this.threshold::_position.y += param2;
         this.threshold::_position.z += param3;
         return this;
      }
      
      public function translateAlong(param1:Vector3D, param2:Number) : Transform
      {
         this.threshold::_position.x += param1.x * param2;
         this.threshold::_position.y += param1.y * param2;
         this.threshold::_position.z += param1.z * param2;
         return this;
      }
      
      public function setRotation(param1:Matrix3D) : Transform
      {
         this.threshold::_rotation.copyFrom(param1);
         return this;
      }
      
      public function setRotationAxes(param1:Vector3D, param2:Vector3D, param3:Vector3D, param4:Number = 1) : Transform
      {
         if(param4 == 1)
         {
            this.threshold::_rotation.copyColumnFrom(0,param1);
            this.threshold::_rotation.copyColumnFrom(1,param2);
            this.threshold::_rotation.copyColumnFrom(2,param3);
         }
         else
         {
            this.threshold::_rotation.copyColumnTo(0,_tmpVec);
            _tmpVec.x += (param1.x - _tmpVec.x) * param4;
            _tmpVec.y += (param1.y - _tmpVec.y) * param4;
            _tmpVec.z += (param1.z - _tmpVec.z) * param4;
            this.threshold::_rotation.copyColumnFrom(0,_tmpVec);
            this.threshold::_rotation.copyColumnTo(1,_tmpVec);
            _tmpVec.x += (param2.x - _tmpVec.x) * param4;
            _tmpVec.y += (param2.y - _tmpVec.y) * param4;
            _tmpVec.z += (param2.z - _tmpVec.z) * param4;
            this.threshold::_rotation.copyColumnFrom(1,_tmpVec);
            this.threshold::_rotation.copyColumnTo(2,_tmpVec);
            _tmpVec.x += (param3.x - _tmpVec.x) * param4;
            _tmpVec.y += (param3.y - _tmpVec.y) * param4;
            _tmpVec.z += (param3.z - _tmpVec.z) * param4;
            this.threshold::_rotation.copyColumnFrom(2,_tmpVec);
         }
         return this;
      }
      
      public function setRotationEuler(param1:Number, param2:Number, param3:Number, param4:Boolean = false) : Transform
      {
         if(param4)
         {
            param1 *= Math.PI / 180;
            param2 *= Math.PI / 180;
            param3 *= Math.PI / 180;
         }
         this.threshold::_rotation.identity();
         this.threshold::_rotation.recompose(Vector.<Vector3D>([VECTOR_ZERO,new Vector3D(param1,param2,param3),VECTOR_ONE]));
         return this;
      }
      
      public function setPosition(param1:Number, param2:Number, param3:Number) : Transform
      {
         this.threshold::_position.x = param1;
         this.threshold::_position.y = param2;
         this.threshold::_position.z = param3;
         return this;
      }
      
      public function setScale(param1:Number, param2:Number, param3:Number) : Transform
      {
         this.threshold::_scale.x = param1;
         this.threshold::_scale.y = param2;
         this.threshold::_scale.z = param3;
         return this;
      }
      
      public function setScaleUniform(param1:Number) : Transform
      {
         this.threshold::_scale.x = this.threshold::_scale.y = this.threshold::_scale.z = param1;
         return this;
      }
      
      public function toMatrix(param1:Matrix3D = null) : Matrix3D
      {
         var _loc2_:Number = this.threshold::_scale.x;
         var _loc3_:Number = this.threshold::_scale.y;
         var _loc4_:Number = this.threshold::_scale.z;
         if(_loc2_ == 0)
         {
            _loc2_ = 0.000001;
         }
         if(_loc3_ == 0)
         {
            _loc3_ = 0.000001;
         }
         if(_loc4_ == 0)
         {
            _loc4_ = 0.000001;
         }
         this.threshold::_position.w = 1;
         param1 ||= new Matrix3D();
         param1.copyFrom(this.threshold::_rotation);
         param1.copyColumnFrom(3,this.threshold::_position);
         param1.prependScale(_loc2_,_loc3_,_loc4_);
         return param1;
      }
      
      public function toRawData(param1:Boolean = false, param2:Vector.<Number> = null) : Vector.<Number>
      {
         var _loc3_:Number = this.threshold::_scale.x;
         var _loc4_:Number = this.threshold::_scale.y;
         var _loc5_:Number = this.threshold::_scale.z;
         if(_loc3_ == 0)
         {
            _loc3_ = 0.000001;
         }
         if(_loc4_ == 0)
         {
            _loc4_ = 0.000001;
         }
         if(_loc5_ == 0)
         {
            _loc5_ = 0.000001;
         }
         param2 ||= new Vector.<Number>(16);
         this.threshold::_position.w = 1;
         this.threshold::_matrix.copyFrom(this.threshold::_rotation);
         this.threshold::_matrix.copyColumnFrom(3,this.threshold::_position);
         this.threshold::_matrix.prependScale(_loc3_,_loc4_,_loc5_);
         this.threshold::_matrix.copyRawDataTo(param2,0,param1);
         return param2;
      }
      
      public function fromMatrix(param1:Matrix3D) : Transform
      {
         var _loc2_:Vector.<Vector3D> = param1.decompose();
         this.threshold::_position.copyFrom(_loc2_[0]);
         this.threshold::_scale.copyFrom(_loc2_[2]);
         this.threshold::_rotation.identity();
         this.threshold::_rotation.recompose(Vector.<Vector3D>([VECTOR_ZERO,_loc2_[1],VECTOR_ONE]));
         return this;
      }
   }
}

