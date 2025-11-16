package alternativa.engine3d.animation.keys
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationState;
   
   use namespace alternativa3d;
   
   public class Track
   {
      
      public var object:String;
      
      alternativa3d var _length:Number = 0;
      
      public function Track()
      {
         super();
      }
      
      public function get length() : Number
      {
         return this.alternativa3d::_length;
      }
      
      alternativa3d function get keyFramesList() : Keyframe
      {
         return null;
      }
      
      alternativa3d function set keyFramesList(param1:Keyframe) : void
      {
      }
      
      alternativa3d function get lastKey() : Keyframe
      {
         return null;
      }
      
      alternativa3d function set lastKey(param1:Keyframe) : void
      {
      }
      
      alternativa3d function addKeyToList(param1:Keyframe) : void
      {
         var _loc3_:Keyframe = null;
         var _loc2_:Number = param1.alternativa3d::_time;
         if(this.alternativa3d::keyFramesList == null)
         {
            this.alternativa3d::keyFramesList = param1;
            this.alternativa3d::lastKey = param1;
            this.alternativa3d::_length = _loc2_ <= 0 ? 0 : _loc2_;
            return;
         }
         if(this.alternativa3d::keyFramesList.alternativa3d::_time > _loc2_)
         {
            param1.alternativa3d::nextKeyFrame = this.alternativa3d::keyFramesList;
            this.alternativa3d::keyFramesList = param1;
            return;
         }
         if(this.alternativa3d::lastKey.alternativa3d::_time < _loc2_)
         {
            this.alternativa3d::lastKey.alternativa3d::nextKeyFrame = param1;
            this.alternativa3d::lastKey = param1;
            this.alternativa3d::_length = _loc2_ <= 0 ? 0 : _loc2_;
         }
         else
         {
            _loc3_ = this.alternativa3d::keyFramesList;
            while(_loc3_.alternativa3d::nextKeyFrame != null && _loc3_.alternativa3d::nextKeyFrame.alternativa3d::_time <= _loc2_)
            {
               _loc3_ = _loc3_.alternativa3d::nextKeyFrame;
            }
            if(_loc3_.alternativa3d::nextKeyFrame == null)
            {
               _loc3_.alternativa3d::nextKeyFrame = param1;
               this.alternativa3d::_length = _loc2_ <= 0 ? 0 : _loc2_;
            }
            else
            {
               param1.alternativa3d::nextKeyFrame = _loc3_.alternativa3d::nextKeyFrame;
               _loc3_.alternativa3d::nextKeyFrame = param1;
            }
         }
      }
      
      public function removeKey(param1:Keyframe) : Keyframe
      {
         var _loc2_:Keyframe = null;
         if(this.alternativa3d::keyFramesList != null)
         {
            if(this.alternativa3d::keyFramesList == param1)
            {
               this.alternativa3d::keyFramesList = this.alternativa3d::keyFramesList.alternativa3d::nextKeyFrame;
               if(this.alternativa3d::keyFramesList == null)
               {
                  this.alternativa3d::lastKey = null;
                  this.alternativa3d::_length = 0;
               }
               return param1;
            }
            _loc2_ = this.alternativa3d::keyFramesList;
            while(_loc2_.alternativa3d::nextKeyFrame != null && _loc2_.alternativa3d::nextKeyFrame != param1)
            {
               _loc2_ = _loc2_.alternativa3d::nextKeyFrame;
            }
            if(_loc2_.alternativa3d::nextKeyFrame == param1)
            {
               if(param1.alternativa3d::nextKeyFrame == null)
               {
                  this.alternativa3d::lastKey = _loc2_;
                  this.alternativa3d::_length = _loc2_.alternativa3d::_time <= 0 ? 0 : _loc2_.alternativa3d::_time;
               }
               _loc2_.alternativa3d::nextKeyFrame = param1.alternativa3d::nextKeyFrame;
               return param1;
            }
         }
         throw new Error("Key not found");
      }
      
      public function get keys() : Vector.<Keyframe>
      {
         var _loc1_:Vector.<Keyframe> = new Vector.<Keyframe>();
         var _loc2_:int = 0;
         var _loc3_:Keyframe = this.alternativa3d::keyFramesList;
         while(_loc3_ != null)
         {
            _loc1_[_loc2_] = _loc3_;
            _loc2_++;
            _loc3_ = _loc3_.alternativa3d::nextKeyFrame;
         }
         return _loc1_;
      }
      
      alternativa3d function blend(param1:Number, param2:Number, param3:AnimationState) : void
      {
      }
      
      public function slice(param1:Number, param2:Number = 1.7976931348623157e+308) : Track
      {
         return null;
      }
      
      alternativa3d function createKeyFrame() : Keyframe
      {
         return null;
      }
      
      alternativa3d function interpolateKeyFrame(param1:Keyframe, param2:Keyframe, param3:Keyframe, param4:Number) : void
      {
      }
      
      alternativa3d function sliceImplementation(param1:Track, param2:Number, param3:Number) : void
      {
         var _loc5_:Keyframe = null;
         var _loc8_:Keyframe = null;
         var _loc4_:Number = param2 > 0 ? param2 : 0;
         var _loc6_:Keyframe = this.alternativa3d::keyFramesList;
         var _loc7_:Keyframe = this.alternativa3d::createKeyFrame();
         while(_loc6_ != null && _loc6_.alternativa3d::_time <= param2)
         {
            _loc5_ = _loc6_;
            _loc6_ = _loc6_.alternativa3d::nextKeyFrame;
         }
         if(_loc5_ != null)
         {
            if(_loc6_ != null)
            {
               this.alternativa3d::interpolateKeyFrame(_loc7_,_loc5_,_loc6_,(param2 - _loc5_.alternativa3d::_time) / (_loc6_.alternativa3d::_time - _loc5_.alternativa3d::_time));
               _loc7_.alternativa3d::_time = param2 - _loc4_;
            }
            else
            {
               this.alternativa3d::interpolateKeyFrame(_loc7_,_loc7_,_loc5_,1);
            }
         }
         else
         {
            if(_loc6_ == null)
            {
               return;
            }
            this.alternativa3d::interpolateKeyFrame(_loc7_,_loc7_,_loc6_,1);
            _loc7_.alternativa3d::_time = _loc6_.alternativa3d::_time - _loc4_;
            _loc5_ = _loc6_;
            _loc6_ = _loc6_.alternativa3d::nextKeyFrame;
         }
         param1.alternativa3d::keyFramesList = _loc7_;
         if(_loc6_ == null || param3 <= param2)
         {
            param1.alternativa3d::_length = _loc7_.alternativa3d::_time <= 0 ? 0 : _loc7_.alternativa3d::_time;
            return;
         }
         while(_loc6_ != null && _loc6_.alternativa3d::_time <= param3)
         {
            _loc8_ = this.alternativa3d::createKeyFrame();
            this.alternativa3d::interpolateKeyFrame(_loc8_,_loc8_,_loc6_,1);
            _loc8_.alternativa3d::_time = _loc6_.alternativa3d::_time - _loc4_;
            _loc7_.alternativa3d::nextKeyFrame = _loc8_;
            _loc7_ = _loc8_;
            _loc5_ = _loc6_;
            _loc6_ = _loc6_.alternativa3d::nextKeyFrame;
         }
         if(_loc6_ != null)
         {
            _loc8_ = this.alternativa3d::createKeyFrame();
            this.alternativa3d::interpolateKeyFrame(_loc8_,_loc5_,_loc6_,(param3 - _loc5_.alternativa3d::_time) / (_loc6_.alternativa3d::_time - _loc5_.alternativa3d::_time));
            _loc8_.alternativa3d::_time = param3 - _loc4_;
            _loc7_.alternativa3d::nextKeyFrame = _loc8_;
         }
         if(_loc8_ != null)
         {
            param1.alternativa3d::_length = _loc8_.alternativa3d::_time <= 0 ? 0 : _loc8_.alternativa3d::_time;
         }
      }
   }
}

