package alternativa.engine3d.animation.keys
{
   import alternativa.engine3d.alternativa3d;
   import flash.geom.Matrix3D;
   import flash.geom.Orientation3D;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class TransformKey extends Keyframe
   {
      
      alternativa3d var x:Number = 0;
      
      alternativa3d var y:Number = 0;
      
      alternativa3d var z:Number = 0;
      
      alternativa3d var rotation:Vector3D = new Vector3D(0,0,0,1);
      
      alternativa3d var scaleX:Number = 1;
      
      alternativa3d var scaleY:Number = 1;
      
      alternativa3d var scaleZ:Number = 1;
      
      alternativa3d var next:TransformKey;
      
      public function TransformKey()
      {
         super();
      }
      
      override public function get value() : Object
      {
         var _loc1_:Matrix3D = new Matrix3D();
         _loc1_.recompose(Vector.<Vector3D>([new Vector3D(this.alternativa3d::x,this.alternativa3d::y,this.alternativa3d::z),this.alternativa3d::rotation,new Vector3D(this.alternativa3d::scaleX,this.alternativa3d::scaleY,this.alternativa3d::scaleZ)]),Orientation3D.QUATERNION);
         return _loc1_;
      }
      
      override public function set value(param1:Object) : void
      {
         var _loc2_:Matrix3D = Matrix3D(param1);
         var _loc3_:Vector.<Vector3D> = _loc2_.decompose(Orientation3D.QUATERNION);
         this.alternativa3d::x = _loc3_[0].x;
         this.alternativa3d::y = _loc3_[0].y;
         this.alternativa3d::z = _loc3_[0].z;
         this.alternativa3d::rotation = _loc3_[1];
         this.alternativa3d::scaleX = _loc3_[2].x;
         this.alternativa3d::scaleY = _loc3_[2].y;
         this.alternativa3d::scaleZ = _loc3_[2].z;
      }
      
      public function interpolate(param1:TransformKey, param2:TransformKey, param3:Number) : void
      {
         var _loc4_:Number = 1 - param3;
         this.alternativa3d::x = _loc4_ * param1.alternativa3d::x + param3 * param2.alternativa3d::x;
         this.alternativa3d::y = _loc4_ * param1.alternativa3d::y + param3 * param2.alternativa3d::y;
         this.alternativa3d::z = _loc4_ * param1.alternativa3d::z + param3 * param2.alternativa3d::z;
         this.slerp(param1.alternativa3d::rotation,param2.alternativa3d::rotation,param3,this.alternativa3d::rotation);
         this.alternativa3d::scaleX = _loc4_ * param1.alternativa3d::scaleX + param3 * param2.alternativa3d::scaleX;
         this.alternativa3d::scaleY = _loc4_ * param1.alternativa3d::scaleY + param3 * param2.alternativa3d::scaleY;
         this.alternativa3d::scaleZ = _loc4_ * param1.alternativa3d::scaleZ + param3 * param2.alternativa3d::scaleZ;
      }
      
      private function slerp(param1:Vector3D, param2:Vector3D, param3:Number, param4:Vector3D) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:Number = 1;
         var _loc6_:Number = param1.w * param2.w + param1.x * param2.x + param1.y * param2.y + param1.z * param2.z;
         if(_loc6_ < 0)
         {
            _loc6_ = -_loc6_;
            _loc5_ = -1;
         }
         if(1 - _loc6_ < 0.001)
         {
            _loc7_ = 1 - param3;
            _loc8_ = param3 * _loc5_;
            param4.w = param1.w * _loc7_ + param2.w * _loc8_;
            param4.x = param1.x * _loc7_ + param2.x * _loc8_;
            param4.y = param1.y * _loc7_ + param2.y * _loc8_;
            param4.z = param1.z * _loc7_ + param2.z * _loc8_;
            _loc9_ = param4.w * param4.w + param4.x * param4.x + param4.y * param4.y + param4.z * param4.z;
            if(_loc9_ == 0)
            {
               param4.w = 1;
            }
            else
            {
               param4.scaleBy(1 / Math.sqrt(_loc9_));
            }
         }
         else
         {
            _loc10_ = Math.acos(_loc6_);
            _loc11_ = Math.sin(_loc10_);
            _loc12_ = Math.sin((1 - param3) * _loc10_) / _loc11_;
            _loc13_ = Math.sin(param3 * _loc10_) / _loc11_ * _loc5_;
            param4.w = param1.w * _loc12_ + param2.w * _loc13_;
            param4.x = param1.x * _loc12_ + param2.x * _loc13_;
            param4.y = param1.y * _loc12_ + param2.y * _loc13_;
            param4.z = param1.z * _loc12_ + param2.z * _loc13_;
         }
      }
      
      override alternativa3d function get nextKeyFrame() : Keyframe
      {
         return this.alternativa3d::next;
      }
      
      override alternativa3d function set nextKeyFrame(param1:Keyframe) : void
      {
         this.alternativa3d::next = TransformKey(param1);
      }
   }
}

