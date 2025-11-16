package alternativa.engine3d.animation.keys
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationState;
   import flash.geom.Matrix3D;
   import flash.geom.Orientation3D;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class TransformTrack extends Track
   {
      
      private static var tempQuat:Vector3D = new Vector3D();
      
      private static var temp:TransformKey = new TransformKey();
      
      private var keyList:TransformKey;
      
      private var _lastKey:TransformKey;
      
      private var recentKey:TransformKey = null;
      
      public function TransformTrack(param1:String)
      {
         super();
         this.object = param1;
      }
      
      override alternativa3d function get keyFramesList() : Keyframe
      {
         return this.keyList;
      }
      
      override alternativa3d function set keyFramesList(param1:Keyframe) : void
      {
         this.keyList = TransformKey(param1);
      }
      
      override alternativa3d function get lastKey() : Keyframe
      {
         return this._lastKey;
      }
      
      override alternativa3d function set lastKey(param1:Keyframe) : void
      {
         this._lastKey = TransformKey(param1);
      }
      
      public function addKey(param1:Number, param2:Matrix3D) : TransformKey
      {
         var _loc3_:TransformKey = null;
         _loc3_ = new TransformKey();
         _loc3_.alternativa3d::_time = param1;
         var _loc4_:Vector.<Vector3D> = param2.decompose(Orientation3D.QUATERNION);
         _loc3_.alternativa3d::x = _loc4_[0].x;
         _loc3_.alternativa3d::y = _loc4_[0].y;
         _loc3_.alternativa3d::z = _loc4_[0].z;
         _loc3_.alternativa3d::rotation = _loc4_[1];
         _loc3_.alternativa3d::scaleX = _loc4_[2].x;
         _loc3_.alternativa3d::scaleY = _loc4_[2].y;
         _loc3_.alternativa3d::scaleZ = _loc4_[2].z;
         alternativa3d::addKeyToList(_loc3_);
         return _loc3_;
      }
      
      public function addKeyComponents(param1:Number, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 1, param9:Number = 1, param10:Number = 1) : TransformKey
      {
         var _loc11_:TransformKey = new TransformKey();
         _loc11_.alternativa3d::_time = param1;
         _loc11_.alternativa3d::x = param2;
         _loc11_.alternativa3d::y = param3;
         _loc11_.alternativa3d::z = param4;
         _loc11_.alternativa3d::rotation = this.createQuatFromEuler(param5,param6,param7);
         _loc11_.alternativa3d::scaleX = param8;
         _loc11_.alternativa3d::scaleY = param9;
         _loc11_.alternativa3d::scaleZ = param10;
         alternativa3d::addKeyToList(_loc11_);
         return _loc11_;
      }
      
      private function appendQuat(param1:Vector3D, param2:Vector3D) : void
      {
         var _loc3_:Number = param2.w * param1.w - param2.x * param1.x - param2.y * param1.y - param2.z * param1.z;
         var _loc4_:Number = param2.w * param1.x + param2.x * param1.w + param2.y * param1.z - param2.z * param1.y;
         var _loc5_:Number = param2.w * param1.y + param2.y * param1.w + param2.z * param1.x - param2.x * param1.z;
         var _loc6_:Number = param2.w * param1.z + param2.z * param1.w + param2.x * param1.y - param2.y * param1.x;
         param1.w = _loc3_;
         param1.x = _loc4_;
         param1.y = _loc5_;
         param1.z = _loc6_;
      }
      
      private function normalizeQuat(param1:Vector3D) : void
      {
         var _loc2_:Number = param1.w * param1.w + param1.x * param1.x + param1.y * param1.y + param1.z * param1.z;
         if(_loc2_ == 0)
         {
            param1.w = 1;
         }
         else
         {
            _loc2_ = 1 / Math.sqrt(_loc2_);
            param1.w *= _loc2_;
            param1.x *= _loc2_;
            param1.y *= _loc2_;
            param1.z *= _loc2_;
         }
      }
      
      private function setQuatFromAxisAngle(param1:Vector3D, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         param1.w = Math.cos(0.5 * param5);
         var _loc6_:Number = Math.sin(0.5 * param5) / Math.sqrt(param2 * param2 + param3 * param3 + param4 * param4);
         param1.x = param2 * _loc6_;
         param1.y = param3 * _loc6_;
         param1.z = param4 * _loc6_;
      }
      
      private function createQuatFromEuler(param1:Number, param2:Number, param3:Number) : Vector3D
      {
         var _loc4_:Vector3D = new Vector3D();
         this.setQuatFromAxisAngle(_loc4_,1,0,0,param1);
         this.setQuatFromAxisAngle(tempQuat,0,1,0,param2);
         this.appendQuat(_loc4_,tempQuat);
         this.normalizeQuat(_loc4_);
         this.setQuatFromAxisAngle(tempQuat,0,0,1,param3);
         this.appendQuat(_loc4_,tempQuat);
         this.normalizeQuat(_loc4_);
         return _loc4_;
      }
      
      override alternativa3d function blend(param1:Number, param2:Number, param3:AnimationState) : void
      {
         var _loc4_:TransformKey = null;
         var _loc5_:TransformKey = null;
         if(this.recentKey != null && this.recentKey.time < param1)
         {
            _loc4_ = this.recentKey;
            _loc5_ = this.recentKey.alternativa3d::next;
         }
         else
         {
            _loc5_ = this.keyList;
         }
         while(_loc5_ != null && _loc5_.alternativa3d::_time < param1)
         {
            _loc4_ = _loc5_;
            _loc5_ = _loc5_.alternativa3d::next;
         }
         if(_loc4_ != null)
         {
            if(_loc5_ != null)
            {
               temp.interpolate(_loc4_,_loc5_,(param1 - _loc4_.alternativa3d::_time) / (_loc5_.alternativa3d::_time - _loc4_.alternativa3d::_time));
               param3.addWeightedTransform(temp,param2);
            }
            else
            {
               param3.addWeightedTransform(_loc4_,param2);
            }
            this.recentKey = _loc4_;
         }
         else if(_loc5_ != null)
         {
            param3.addWeightedTransform(_loc5_,param2);
         }
      }
      
      override alternativa3d function createKeyFrame() : Keyframe
      {
         return new TransformKey();
      }
      
      override alternativa3d function interpolateKeyFrame(param1:Keyframe, param2:Keyframe, param3:Keyframe, param4:Number) : void
      {
         TransformKey(param1).interpolate(TransformKey(param2),TransformKey(param3),param4);
      }
      
      override public function slice(param1:Number, param2:Number = 1.7976931348623157e+308) : Track
      {
         var _loc3_:TransformTrack = new TransformTrack(object);
         alternativa3d::sliceImplementation(_loc3_,param1,param2);
         return _loc3_;
      }
   }
}

