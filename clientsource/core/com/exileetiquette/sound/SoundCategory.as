package com.exileetiquette.sound
{
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class SoundCategory
   {
      
      private var _soundsById:Dictionary;
      
      private var _soundObjectsById:Dictionary;
      
      private var _soundsPlaying:Vector.<SoundData>;
      
      private var _timeCallbackTimer:Timer;
      
      internal var masterTransform:SoundTransform;
      
      internal var transform:SoundTransform;
      
      public function SoundCategory(param1:SoundTransform)
      {
         super();
         this._soundsById = new Dictionary(true);
         this._soundsPlaying = new Vector.<SoundData>();
         this._soundObjectsById = new Dictionary(true);
         this._timeCallbackTimer = new Timer(3);
         this._timeCallbackTimer.addEventListener(TimerEvent.TIMER,this.onTimeCallbackTimerTick,false,0,true);
         this.masterTransform = param1;
         this.transform = new SoundTransform();
      }
      
      public function destroy() : void
      {
         var _loc1_:String = null;
         this.stopAll();
         for(_loc1_ in this._soundsById)
         {
            this._soundsById[_loc1_] = null;
            delete this._soundsById[_loc1_];
         }
         for(_loc1_ in this._soundObjectsById)
         {
            this._soundObjectsById[_loc1_] = null;
            delete this._soundObjectsById[_loc1_];
         }
         this._soundObjectsById = null;
         this._soundsPlaying = null;
         this._soundsById = null;
         this._timeCallbackTimer.stop();
         this._timeCallbackTimer.removeEventListener(TimerEvent.TIMER,this.onTimeCallbackTimerTick);
         this._timeCallbackTimer = null;
      }
      
      public function addSound(param1:String, param2:*) : void
      {
         if(param2 is Class)
         {
            this._soundsById[param1] = param2 as Class;
         }
         else
         {
            if(!(param2 is Sound))
            {
               throw new Error("Must supply a Class reference or instance of a Sound object.");
            }
            this._soundObjectsById[param1] = param2 as Sound;
         }
      }
      
      public function getLength(param1:String) : Number
      {
         var _loc3_:Class = null;
         var _loc2_:Sound = this._soundObjectsById[param1];
         if(!_loc2_)
         {
            _loc3_ = this._soundsById[param1];
            if(!_loc3_)
            {
               return 0;
            }
            _loc2_ = new _loc3_();
         }
         return _loc2_.length;
      }
      
      public function getNumPlaying(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:SoundData = null;
         for each(_loc3_ in this._soundsPlaying)
         {
            if(_loc3_.id == param1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function getSound(param1:String) : Sound
      {
         if(this._soundObjectsById[param1])
         {
            return this._soundObjectsById[param1];
         }
         var _loc2_:Class = this._soundsById[param1];
         if(!_loc2_)
         {
            return null;
         }
         return new _loc2_();
      }
      
      public function isPlaying(param1:String = null) : Boolean
      {
         var _loc2_:SoundData = null;
         for each(_loc2_ in this._soundsPlaying)
         {
            if(!param1 || _loc2_.id == param1)
            {
               if(!_loc2_.paused && !_loc2_.delayed)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function play(param1:String, param2:Object = null) : SoundData
      {
         var _loc5_:Class = null;
         if(this._soundObjectsById[param1] == null)
         {
            _loc5_ = this._soundsById[param1];
            if(!_loc5_)
            {
               return null;
            }
            this._soundObjectsById[param1] = new _loc5_();
         }
         var _loc3_:Sound = Sound(this._soundObjectsById[param1]);
         var _loc4_:SoundData = new SoundData(param1,this,_loc3_);
         _loc4_.play(param2 is String ? null : param2);
         if(_loc4_.channel)
         {
            _loc4_.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete,false,-int.MAX_VALUE,true);
            if(!(param2 is String) && param2 && Boolean(param2.onTime))
            {
               this._timeCallbackTimer.reset();
               this._timeCallbackTimer.start();
            }
         }
         this._soundsPlaying.push(_loc4_);
         return _loc4_;
      }
      
      public function removeSound(param1:String) : void
      {
         if(param1 in this._soundsById)
         {
            this.stop(param1);
            delete this._soundsById[param1];
         }
      }
      
      public function stop(param1:String) : void
      {
         var _loc3_:SoundData = null;
         var _loc2_:int = int(this._soundsPlaying.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._soundsPlaying[_loc2_];
            if(_loc3_.id == param1)
            {
               _loc3_.stop();
            }
            _loc2_--;
         }
      }
      
      public function stopAll() : void
      {
         var _loc1_:SoundData = null;
         for each(_loc1_ in this._soundsPlaying)
         {
            _loc1_.stop();
         }
         this._soundsPlaying.splice(0,this._soundsPlaying.length);
      }
      
      public function stopAllDelayed() : void
      {
         var _loc2_:SoundData = null;
         var _loc1_:int = int(this._soundsPlaying.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this._soundsPlaying[_loc1_];
            if(_loc2_.delayed)
            {
               _loc2_.stop();
            }
            _loc1_--;
         }
      }
      
      internal function updatePlayingSounds() : void
      {
         var _loc1_:SoundData = null;
         for each(_loc1_ in this._soundsPlaying)
         {
            _loc1_.updateSoundTransform();
         }
      }
      
      internal function removeFromPlayingList(param1:SoundData) : void
      {
         var _loc2_:int = int(this._soundsPlaying.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._soundsPlaying.splice(_loc2_,1);
         }
         if(this._soundsPlaying.length == 0)
         {
            this._timeCallbackTimer.stop();
         }
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         var _loc2_:SoundData = SoundData(param1.target);
         var _loc3_:Sound = _loc2_.sound;
         _loc2_.stop();
      }
      
      private function onTimeCallbackTimerTick(param1:TimerEvent) : void
      {
         var _loc2_:SoundData = null;
         for each(_loc2_ in this._soundsPlaying)
         {
            _loc2_.checkTimeCallbacks();
         }
      }
      
      public function get leftToLeft() : Number
      {
         return this.transform.leftToLeft;
      }
      
      public function set leftToLeft(param1:Number) : void
      {
         this.transform.leftToLeft = param1;
         this.updatePlayingSounds();
      }
      
      public function get leftToRight() : Number
      {
         return this.transform.leftToRight;
      }
      
      public function set leftToRight(param1:Number) : void
      {
         this.transform.leftToRight = param1;
         this.updatePlayingSounds();
      }
      
      public function get numPlaying() : int
      {
         return this._soundsPlaying.length;
      }
      
      public function get pan() : Number
      {
         return this.transform.pan;
      }
      
      public function set pan(param1:Number) : void
      {
         this.transform.pan = param1;
         this.updatePlayingSounds();
      }
      
      public function get rightToLeft() : Number
      {
         return this.transform.rightToLeft;
      }
      
      public function set rightToLeft(param1:Number) : void
      {
         this.transform.rightToLeft = param1;
         this.updatePlayingSounds();
      }
      
      public function get rightToRight() : Number
      {
         return this.transform.rightToRight;
      }
      
      public function set rightToRight(param1:Number) : void
      {
         this.transform.rightToRight = param1;
         this.updatePlayingSounds();
      }
      
      public function get volume() : Number
      {
         return this.transform.volume;
      }
      
      public function set volume(param1:Number) : void
      {
         this.transform.volume = param1;
         this.updatePlayingSounds();
      }
   }
}

