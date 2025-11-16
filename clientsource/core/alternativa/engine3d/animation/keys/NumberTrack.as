package alternativa.engine3d.animation.keys
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationState;
   
   use namespace alternativa3d;
   
   public class NumberTrack extends Track
   {
      
      private static var temp:NumberKey = new NumberKey();
      
      alternativa3d var keyList:NumberKey;
      
      private var _lastKey:NumberKey;
      
      public var property:String;
      
      private var recentKey:NumberKey = null;
      
      public function NumberTrack(param1:String, param2:String)
      {
         super();
         this.property = param2;
         this.object = param1;
      }
      
      override alternativa3d function get keyFramesList() : Keyframe
      {
         return this.alternativa3d::keyList;
      }
      
      override alternativa3d function set keyFramesList(param1:Keyframe) : void
      {
         this.alternativa3d::keyList = NumberKey(param1);
      }
      
      override alternativa3d function get lastKey() : Keyframe
      {
         return this._lastKey;
      }
      
      override alternativa3d function set lastKey(param1:Keyframe) : void
      {
         this._lastKey = NumberKey(param1);
      }
      
      public function addKey(param1:Number, param2:Number = 0) : Keyframe
      {
         var _loc3_:NumberKey = new NumberKey();
         _loc3_.alternativa3d::_time = param1;
         _loc3_.value = param2;
         alternativa3d::addKeyToList(_loc3_);
         return _loc3_;
      }
      
      override alternativa3d function blend(param1:Number, param2:Number, param3:AnimationState) : void
      {
         var _loc4_:NumberKey = null;
         var _loc5_:NumberKey = null;
         if(this.property == null)
         {
            return;
         }
         if(this.recentKey != null && this.recentKey.time < param1)
         {
            _loc4_ = this.recentKey;
            _loc5_ = this.recentKey.alternativa3d::next;
         }
         else
         {
            _loc5_ = this.alternativa3d::keyList;
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
               param3.addWeightedNumber(this.property,temp.alternativa3d::_value,param2);
            }
            else
            {
               param3.addWeightedNumber(this.property,_loc4_.alternativa3d::_value,param2);
            }
            this.recentKey = _loc4_;
         }
         else if(_loc5_ != null)
         {
            param3.addWeightedNumber(this.property,_loc5_.alternativa3d::_value,param2);
         }
      }
      
      override alternativa3d function createKeyFrame() : Keyframe
      {
         return new NumberKey();
      }
      
      override alternativa3d function interpolateKeyFrame(param1:Keyframe, param2:Keyframe, param3:Keyframe, param4:Number) : void
      {
         NumberKey(param1).interpolate(NumberKey(param2),NumberKey(param3),param4);
      }
      
      override public function slice(param1:Number, param2:Number = 1.7976931348623157e+308) : Track
      {
         var _loc3_:NumberTrack = new NumberTrack(object,this.property);
         alternativa3d::sliceImplementation(_loc3_,param1,param2);
         return _loc3_;
      }
   }
}

