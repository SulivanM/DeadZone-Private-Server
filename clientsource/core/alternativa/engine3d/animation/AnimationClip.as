package alternativa.engine3d.animation
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.keys.Track;
   import alternativa.engine3d.core.Object3D;
   
   use namespace alternativa3d;
   
   public class AnimationClip extends AnimationNode
   {
      
      alternativa3d var _objects:Array;
      
      public var name:String;
      
      public var loop:Boolean = true;
      
      public var length:Number = 0;
      
      public var animated:Boolean = true;
      
      private var _time:Number = 0;
      
      private var _numTracks:int = 0;
      
      private var _tracks:Vector.<Track> = new Vector.<Track>();
      
      private var _notifiersList:AnimationNotify;
      
      public function AnimationClip(param1:String = null)
      {
         super();
         this.name = param1;
      }
      
      public function get objects() : Array
      {
         return this.alternativa3d::_objects == null ? null : [].concat(this.alternativa3d::_objects);
      }
      
      public function set objects(param1:Array) : void
      {
         this.updateObjects(this.alternativa3d::_objects,alternativa3d::controller,param1,alternativa3d::controller);
         this.alternativa3d::_objects = param1 == null ? null : [].concat(param1);
      }
      
      override alternativa3d function setController(param1:AnimationController) : void
      {
         this.updateObjects(this.alternativa3d::_objects,alternativa3d::controller,this.alternativa3d::_objects,param1);
         this.alternativa3d::controller = param1;
      }
      
      private function addObject(param1:Object) : void
      {
         if(this.alternativa3d::_objects == null)
         {
            this.alternativa3d::_objects = [param1];
         }
         else
         {
            this.alternativa3d::_objects.push(param1);
         }
         if(alternativa3d::controller != null)
         {
            alternativa3d::controller.alternativa3d::addObject(param1);
         }
      }
      
      private function updateObjects(param1:Array, param2:AnimationController, param3:Array, param4:AnimationController) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param2 != null && param1 != null)
         {
            _loc5_ = 0;
            _loc6_ = int(this.alternativa3d::_objects.length);
            while(_loc5_ < _loc6_)
            {
               param2.alternativa3d::removeObject(param1[_loc5_]);
               _loc5_++;
            }
         }
         if(param4 != null && param3 != null)
         {
            _loc5_ = 0;
            _loc6_ = int(param3.length);
            while(_loc5_ < _loc6_)
            {
               param4.alternativa3d::addObject(param3[_loc5_]);
               _loc5_++;
            }
         }
      }
      
      public function updateLength() : void
      {
         var _loc2_:Track = null;
         var _loc3_:Number = NaN;
         var _loc1_:int = 0;
         while(_loc1_ < this._numTracks)
         {
            _loc2_ = this._tracks[_loc1_];
            _loc3_ = _loc2_.length;
            if(_loc3_ > this.length)
            {
               this.length = _loc3_;
            }
            _loc1_++;
         }
      }
      
      public function addTrack(param1:Track) : Track
      {
         if(param1 == null)
         {
            throw new Error("Track can not be null");
         }
         this._tracks[this._numTracks++] = param1;
         if(param1.length > this.length)
         {
            this.length = param1.length;
         }
         return param1;
      }
      
      public function removeTrack(param1:Track) : Track
      {
         var _loc5_:Track = null;
         var _loc2_:int = int(this._tracks.indexOf(param1));
         if(_loc2_ < 0)
         {
            throw new ArgumentError("Track not found");
         }
         --this._numTracks;
         var _loc3_:int = _loc2_ + 1;
         while(_loc2_ < this._numTracks)
         {
            this._tracks[_loc2_] = this._tracks[_loc3_];
            _loc2_++;
            _loc3_++;
         }
         this._tracks.length = this._numTracks;
         this.length = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._numTracks)
         {
            _loc5_ = this._tracks[_loc4_];
            if(_loc5_.length > this.length)
            {
               this.length = _loc5_.length;
            }
            _loc4_++;
         }
         return param1;
      }
      
      public function getTrackAt(param1:int) : Track
      {
         return this._tracks[param1];
      }
      
      public function get numTracks() : int
      {
         return this._numTracks;
      }
      
      override alternativa3d function update(param1:Number, param2:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Track = null;
         var _loc6_:AnimationState = null;
         var _loc3_:Number = this._time;
         if(this.animated)
         {
            this._time += param1 * speed;
            if(this.loop)
            {
               if(this._time < 0)
               {
                  this._time = 0;
               }
               else if(this._time >= this.length)
               {
                  this.alternativa3d::collectNotifiers(_loc3_,this.length);
                  this._time = this.length <= 0 ? 0 : this._time % this.length;
                  this.alternativa3d::collectNotifiers(0,this._time < _loc3_ ? this._time : _loc3_);
               }
               else
               {
                  this.alternativa3d::collectNotifiers(_loc3_,this._time);
               }
            }
            else
            {
               if(this._time < 0)
               {
                  this._time = 0;
               }
               else if(this._time >= this.length)
               {
                  this._time = this.length;
               }
               this.alternativa3d::collectNotifiers(_loc3_,this._time);
            }
         }
         if(param2 > 0)
         {
            _loc4_ = 0;
            while(_loc4_ < this._numTracks)
            {
               _loc5_ = this._tracks[_loc4_];
               if(_loc5_.object != null)
               {
                  _loc6_ = alternativa3d::controller.alternativa3d::getState(_loc5_.object);
                  if(_loc6_ != null)
                  {
                     _loc5_.alternativa3d::blend(this._time,param2,_loc6_);
                  }
               }
               _loc4_++;
            }
         }
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function set time(param1:Number) : void
      {
         this._time = param1;
      }
      
      public function get normalizedTime() : Number
      {
         return this.length == 0 ? 0 : this._time / this.length;
      }
      
      public function set normalizedTime(param1:Number) : void
      {
         this._time = param1 * this.length;
      }
      
      private function getNumChildren(param1:Object) : int
      {
         if(param1 is Object3D)
         {
            return Object3D(param1).numChildren;
         }
         return 0;
      }
      
      private function getChildAt(param1:Object, param2:int) : Object
      {
         if(param1 is Object3D)
         {
            return Object3D(param1).getChildAt(param2);
         }
         return null;
      }
      
      private function addChildren(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:int = this.getNumChildren(param1);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this.getChildAt(param1,_loc2_);
            this.addObject(_loc4_);
            this.addChildren(_loc4_);
            _loc2_++;
         }
      }
      
      public function attach(param1:Object, param2:Boolean) : void
      {
         this.updateObjects(this.alternativa3d::_objects,alternativa3d::controller,null,alternativa3d::controller);
         this.alternativa3d::_objects = null;
         this.addObject(param1);
         if(param2)
         {
            this.addChildren(param1);
         }
      }
      
      alternativa3d function collectNotifiers(param1:Number, param2:Number) : void
      {
         var _loc3_:AnimationNotify = this._notifiersList;
         while(_loc3_ != null)
         {
            if(_loc3_.alternativa3d::_time > param1 && _loc3_.alternativa3d::_time <= param2)
            {
               _loc3_.alternativa3d::processNext = alternativa3d::controller.alternativa3d::nearestNotifyers;
               alternativa3d::controller.alternativa3d::nearestNotifyers = _loc3_;
            }
            _loc3_ = _loc3_.alternativa3d::next;
         }
      }
      
      public function addNotify(param1:Number, param2:String = null) : AnimationNotify
      {
         var _loc4_:AnimationNotify = null;
         param1 = param1 <= 0 ? 0 : (param1 >= this.length ? this.length : param1);
         var _loc3_:AnimationNotify = new AnimationNotify(param2);
         _loc3_.alternativa3d::_time = param1;
         if(this._notifiersList == null)
         {
            this._notifiersList = _loc3_;
            return _loc3_;
         }
         if(this._notifiersList.alternativa3d::_time > param1)
         {
            _loc3_.alternativa3d::next = this._notifiersList;
            this._notifiersList = _loc3_;
            return _loc3_;
         }
         _loc4_ = this._notifiersList;
         while(_loc4_.alternativa3d::next != null && _loc4_.alternativa3d::next.alternativa3d::_time <= param1)
         {
            _loc4_ = _loc4_.alternativa3d::next;
         }
         if(_loc4_.alternativa3d::next == null)
         {
            _loc4_.alternativa3d::next = _loc3_;
         }
         else
         {
            _loc3_.alternativa3d::next = _loc4_.alternativa3d::next;
            _loc4_.alternativa3d::next = _loc3_;
         }
         return _loc3_;
      }
      
      public function addNotifyAtEnd(param1:Number = 0, param2:String = null) : AnimationNotify
      {
         return this.addNotify(this.length - param1,param2);
      }
      
      public function removeNotify(param1:AnimationNotify) : AnimationNotify
      {
         var _loc2_:AnimationNotify = null;
         if(this._notifiersList != null)
         {
            if(this._notifiersList == param1)
            {
               this._notifiersList = this._notifiersList.alternativa3d::next;
               return param1;
            }
            _loc2_ = this._notifiersList;
            while(_loc2_.alternativa3d::next != null && _loc2_.alternativa3d::next != param1)
            {
               _loc2_ = _loc2_.alternativa3d::next;
            }
            if(_loc2_.alternativa3d::next == param1)
            {
               _loc2_.alternativa3d::next = param1.alternativa3d::next;
               return param1;
            }
         }
         throw new Error("Notify not found");
      }
      
      public function get notifiers() : Vector.<AnimationNotify>
      {
         var _loc1_:Vector.<AnimationNotify> = new Vector.<AnimationNotify>();
         var _loc2_:int = 0;
         var _loc3_:AnimationNotify = this._notifiersList;
         while(_loc3_ != null)
         {
            _loc1_[_loc2_] = _loc3_;
            _loc2_++;
            _loc3_ = _loc3_.alternativa3d::next;
         }
         return _loc1_;
      }
      
      public function slice(param1:Number, param2:Number = 1.7976931348623157e+308) : AnimationClip
      {
         var _loc3_:AnimationClip = new AnimationClip(this.name);
         _loc3_.animated = this.animated;
         _loc3_.loop = this.loop;
         _loc3_.alternativa3d::_objects = this.alternativa3d::_objects == null ? null : [].concat(this.alternativa3d::_objects);
         var _loc4_:int = 0;
         while(_loc4_ < this._numTracks)
         {
            _loc3_.addTrack(this._tracks[_loc4_].slice(param1,param2));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function clone() : AnimationClip
      {
         var _loc1_:AnimationClip = new AnimationClip(this.name);
         _loc1_.animated = this.animated;
         _loc1_.loop = this.loop;
         _loc1_.alternativa3d::_objects = this.alternativa3d::_objects == null ? null : [].concat(this.alternativa3d::_objects);
         var _loc2_:int = 0;
         while(_loc2_ < this._numTracks)
         {
            _loc1_.addTrack(this._tracks[_loc2_]);
            _loc2_++;
         }
         _loc1_.length = this.length;
         return _loc1_;
      }
   }
}

