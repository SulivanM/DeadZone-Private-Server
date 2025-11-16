package com.exileetiquette.sound
{
   import com.exileetiquette.sound.effects.ISoundEffect;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.SampleDataEvent;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public dynamic class SoundData extends EventDispatcher
   {
      
      private var _callbackComplete:Function;
      
      private var _callbackCompleteParams:Array;
      
      private var _callbackStart:Function;
      
      private var _callbackStartParams:Array;
      
      private var _callbackTime:Array;
      
      private var _category:SoundCategory;
      
      private var _channel:SoundChannel;
      
      private var _delay:Number = 0;
      
      private var _delayTimer:Timer;
      
      private var _id:String;
      
      private var _loops:int;
      
      private var _paused:Boolean;
      
      private var _pausePos:Number = 0;
      
      private var _playing:Boolean;
      
      private var _effectLoop:Vector.<ISoundEffect>;
      
      private var _effectOutput:Sound;
      
      private var _sound:Sound;
      
      private var _soundTransform:SoundTransform;
      
      private var _startTime:int;
      
      private var _transform:SoundTransform;
      
      public var allowAutoTransformUpdates:Boolean = true;
      
      private var _effectPosition:Number = 0;
      
      private var _inputBytes:ByteArray;
      
      private var _inputSamples:Number = 0;
      
      private var _tempBytes:ByteArray = new ByteArray();
      
      public function SoundData(param1:String, param2:SoundCategory, param3:Sound)
      {
         super();
         if(!param3)
         {
            throw new Error("No Sound object supplied");
         }
         this._id = param1;
         this._sound = param3;
         this._category = param2;
         this._transform = new SoundTransform(1,0);
         this._soundTransform = new SoundTransform(this._transform.volume,this._transform.pan);
         this._effectLoop = new Vector.<ISoundEffect>();
      }
      
      public function pause() : void
      {
         if(!this._channel && !this._delayTimer)
         {
            return;
         }
         this._paused = true;
         this._playing = false;
         if(this._delayTimer)
         {
            this._delayTimer.stop();
         }
         if(this._channel)
         {
            this._pausePos = this._channel.position;
            this._channel.stop();
            this._channel = null;
         }
      }
      
      public function resume() : void
      {
         if(!this._paused)
         {
            return;
         }
         this._paused = false;
         if(this._delayTimer)
         {
            this._delayTimer.start();
         }
         else
         {
            this.playSound();
         }
      }
      
      public function stop() : void
      {
         this.killDelay();
         this._playing = false;
         this._paused = false;
         this._pausePos = 0;
         if(this._channel != null)
         {
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
            this._channel.stop();
            this._channel = null;
         }
         this._soundTransform = null;
         this._sound = null;
         if(this._category != null)
         {
            this._category.removeFromPlayingList(this);
            this._category = null;
         }
      }
      
      internal function checkTimeCallbacks() : void
      {
         var _loc1_:Object = null;
         if(!this._callbackTime || !this._channel)
         {
            return;
         }
         for each(_loc1_ in this._callbackTime)
         {
            if(!(!_loc1_.callback || _loc1_.called && !_loc1_.repeat))
            {
               if(_loc1_.lastTime < _loc1_.time && this._channel.position >= _loc1_.time)
               {
                  _loc1_.callback.apply(null,_loc1_.callbackParams);
                  _loc1_.called = true;
               }
               _loc1_.lastTime = this._channel.position;
            }
         }
      }
      
      private function playSound(param1:TimerEvent = null) : void
      {
         this.killDelay();
         var _loc2_:Sound = this._effectOutput ? this._effectOutput : this._sound;
         this._channel = _loc2_.play(this._pausePos > 0 ? this._pausePos : this._startTime,this._pausePos > 0 ? 0 : this._loops,this._soundTransform);
         if(!this._channel)
         {
            return;
         }
         if(this._callbackStart != null)
         {
            this._callbackStart.apply(null,this._callbackStartParams);
         }
         this._playing = true;
         this._channel.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete,false,0,true);
      }
      
      private function killDelay() : void
      {
         if(!this._delayTimer)
         {
            return;
         }
         this._delayTimer.stop();
         this._delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.playSound);
         this._delayTimer = null;
      }
      
      internal function play(param1:Object = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:Class = null;
         this.killDelay();
         this._paused = false;
         if(param1 is Number)
         {
            this._transform.volume = param1.Number(param1);
         }
         else if(param1)
         {
            if(param1.delay)
            {
               this._delay = param1.delay < 0 ? 0 : Number(param1.delay);
            }
            if(param1.loops)
            {
               this._loops = param1.loops < 0 ? int.MAX_VALUE : int(param1.loops);
            }
            if(param1.startTime)
            {
               this._startTime = param1.startTime;
            }
            if(param1.onStart)
            {
               this._callbackStart = param1.onStart;
            }
            if(param1.onComplete)
            {
               this._callbackComplete = param1.onComplete;
            }
            this._callbackStartParams = param1.onStartParams ? param1.onStartParams : [];
            this._callbackCompleteParams = param1.onCompleteParams ? param1.onCompleteParams : [];
            this._callbackTime = param1.onTime;
            if(param1.volume)
            {
               this._transform.volume = param1.volume;
            }
            if(param1.pan)
            {
               this._transform.pan = param1.pan;
            }
            if(param1.leftToLeft)
            {
               this._transform.leftToLeft = param1.leftToLeft;
            }
            if(param1.leftToRight)
            {
               this._transform.leftToRight = param1.leftToRight;
            }
            if(param1.rightToLeft)
            {
               this._transform.rightToLeft = param1.rightToLeft;
            }
            if(param1.rightToRight)
            {
               this._transform.rightToRight = param1.rightToRight;
            }
            for(_loc2_ in param1)
            {
               _loc3_ = SoundManager.effectHandlerByProperty[_loc2_];
               if(_loc3_)
               {
                  this.applyEffect(new _loc3_(),param1[_loc2_]);
               }
            }
         }
         this.updateSoundTransform();
         if(this._delay > 0)
         {
            this._delayTimer = new Timer(this._delay * 1000,1);
            this._delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.playSound,false,0,true);
            this._delayTimer.start();
         }
         else
         {
            this.playSound();
         }
      }
      
      private function onEffectOutputSampleData(param1:SampleDataEvent) : void
      {
         var _loc5_:ISoundEffect = null;
         var _loc2_:ByteArray = this._inputBytes;
         _loc2_.position = this._effectPosition;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._effectLoop.length);
         while(_loc3_ < _loc4_)
         {
            param1.data.position = 0;
            _loc5_ = this._effectLoop[_loc3_];
            _loc5_.process(_loc2_,param1.data,_loc2_.position);
            _loc2_ = this._tempBytes;
            _loc2_.position = 0;
            _loc2_.writeBytes(param1.data);
            _loc2_.position = 0;
            _loc3_++;
         }
         this._effectPosition += param1.data.length / 8;
         if(this._effectPosition > this._inputBytes.length / 8)
         {
            if(this._loops > 1)
            {
               --this._loops;
               this._effectPosition = 0;
               return;
            }
            this._channel.stop();
            this.onSoundComplete();
         }
      }
      
      public function applyEffect(param1:ISoundEffect, param2:Object) : SoundData
      {
         param1.settings = param2;
         this._effectLoop.push(param1);
         if(!this._effectOutput)
         {
            this._effectOutput = new Sound();
            this._effectOutput.addEventListener(SampleDataEvent.SAMPLE_DATA,this.onEffectOutputSampleData,false,0,true);
            this._inputBytes = new ByteArray();
            this._inputSamples = this._sound.extract(this._inputBytes,this._sound.bytesTotal * 8,0);
         }
         if(this._playing)
         {
            this.pause();
            this.playSound();
         }
         return this;
      }
      
      internal function updateSoundTransform() : void
      {
         if(!this.allowAutoTransformUpdates)
         {
            return;
         }
         var _loc1_:SoundTransform = this._category.transform;
         var _loc2_:SoundTransform = this._category.masterTransform;
         var _loc3_:Number = this._transform.leftToLeft + _loc1_.leftToLeft + _loc2_.leftToLeft;
         var _loc4_:Number = this._transform.leftToRight + _loc1_.leftToRight + _loc2_.leftToRight;
         var _loc5_:Number = this._transform.rightToLeft + _loc1_.rightToLeft + _loc2_.rightToLeft;
         var _loc6_:Number = this._transform.rightToRight + _loc1_.rightToRight + _loc2_.rightToRight;
         var _loc7_:Number = this._transform.pan + _loc1_.pan + _loc2_.pan;
         var _loc8_:Number = this._transform.volume * _loc1_.volume * _loc2_.volume;
         this._soundTransform.leftToLeft = _loc3_ < 0 ? 0 : (_loc3_ > 1 ? 1 : _loc3_);
         this._soundTransform.leftToRight = _loc4_ < 0 ? 0 : (_loc4_ > 1 ? 1 : _loc4_);
         this._soundTransform.rightToLeft = _loc5_ < 0 ? 0 : (_loc5_ > 1 ? 1 : _loc5_);
         this._soundTransform.rightToRight = _loc6_ < 0 ? 0 : (_loc6_ > 1 ? 1 : _loc6_);
         this._soundTransform.pan = _loc7_ < -1 ? -1 : (_loc7_ > 1 ? 1 : _loc7_);
         this._soundTransform.volume = _loc8_ < 0 ? 0 : (_loc8_ > 1 ? 1 : _loc8_);
         if(this._channel)
         {
            this._channel.soundTransform = this._soundTransform;
         }
      }
      
      private function onSoundComplete(param1:Event = null) : void
      {
         if(this._pausePos > 0 && this._loops > 0)
         {
            this._pausePos = 0;
            --this._loops;
            this.playSound(null);
            return;
         }
         if(this._callbackComplete != null)
         {
            this._callbackComplete.apply(null,this._callbackCompleteParams);
         }
         dispatchEvent(new Event(Event.SOUND_COMPLETE));
      }
      
      public function get channel() : SoundChannel
      {
         return this._channel;
      }
      
      internal function get delayed() : Boolean
      {
         return this._delayTimer != null;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get leftToLeft() : Number
      {
         return this._transform.leftToLeft;
      }
      
      public function set leftToLeft(param1:Number) : void
      {
         this._transform.leftToLeft = param1;
         if(this._playing)
         {
            this.updateSoundTransform();
         }
      }
      
      public function get leftToRight() : Number
      {
         return this._transform.leftToRight;
      }
      
      public function set leftToRight(param1:Number) : void
      {
         this._transform.leftToRight = param1;
         if(this._playing)
         {
            this.updateSoundTransform();
         }
      }
      
      public function get length() : Number
      {
         return this._sound.length;
      }
      
      public function get pan() : Number
      {
         return this._transform.pan;
      }
      
      public function set pan(param1:Number) : void
      {
         this._transform.pan = param1;
         if(this._playing)
         {
            this.updateSoundTransform();
         }
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function get rightToLeft() : Number
      {
         return this._transform.rightToLeft;
      }
      
      public function set rightToLeft(param1:Number) : void
      {
         this._transform.rightToLeft = param1;
         if(this._playing)
         {
            this.updateSoundTransform();
         }
      }
      
      public function get rightToRight() : Number
      {
         return this._transform.rightToRight;
      }
      
      public function set rightToRight(param1:Number) : void
      {
         this._transform.rightToRight = param1;
         if(this._playing)
         {
            this.updateSoundTransform();
         }
      }
      
      public function get sound() : Sound
      {
         return this._sound;
      }
      
      public function get volume() : Number
      {
         return this._transform.volume;
      }
      
      public function set volume(param1:Number) : void
      {
         this._transform.volume = param1;
         if(this._playing)
         {
            this.updateSoundTransform();
         }
      }
   }
}

