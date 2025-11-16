package thelaststand.engine.audio
{
   import com.exileetiquette.sound.SoundData;
   import flash.events.Event;
   import flash.geom.Vector3D;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Settings;
   import thelaststand.engine.objects.GameEntity;
   
   public class SoundSource3D extends GameEntity
   {
      
      private static var _nextSoundId:int = 0;
      
      public static var volume:Number = 1;
      
      private var _disposed:Boolean;
      
      private var _soundsPlaying:Vector.<SoundOutput>;
      
      private var _playingSoundsBySoundData:Dictionary;
      
      private var _positionGlobal:Vector3D;
      
      public var position:Vector3D;
      
      public var volume:Number = 1;
      
      public var pan:Number = 0;
      
      public function SoundSource3D(param1:Vector3D = null, param2:String = null)
      {
         super();
         this.position = param1;
         this.name = param2 == null ? "sound" + _nextSoundId++ : param2;
         this._soundsPlaying = new Vector.<SoundOutput>();
         this._playingSoundsBySoundData = new Dictionary(true);
         this._positionGlobal = new Vector3D();
      }
      
      override public function dispose() : void
      {
         this.stopAll();
         if(this._disposed)
         {
            return;
         }
         this._soundsPlaying = null;
         this._playingSoundsBySoundData = null;
         this._disposed = true;
         this.position = null;
         super.dispose();
      }
      
      public function stopAll() : void
      {
         var _loc1_:SoundOutput = null;
         var _loc2_:int = 0;
         for each(_loc1_ in this._soundsPlaying)
         {
            if(_loc1_.soundData != null)
            {
               _loc1_.soundData.stop();
            }
            _loc2_ = int(this._soundsPlaying.indexOf(_loc1_));
            if(_loc2_ > -1)
            {
               this._soundsPlaying.splice(_loc2_,1);
            }
            this._playingSoundsBySoundData[_loc1_.soundData] = null;
            delete this._playingSoundsBySoundData[_loc1_.soundData];
         }
      }
      
      public function stop(param1:SoundOutput) : void
      {
         if(param1.soundData != null)
         {
            param1.soundData.stop();
         }
         var _loc2_:int = int(this._soundsPlaying.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._soundsPlaying.splice(_loc2_,1);
         }
         this._playingSoundsBySoundData[param1.soundData] = null;
         delete this._playingSoundsBySoundData[param1.soundData];
      }
      
      public function play(param1:String, param2:Object = null) : SoundOutput
      {
         var _loc3_:SoundOutput = null;
         if(param1 == null || param1.length == 0)
         {
            return null;
         }
         param2 ||= {};
         var _loc4_:SoundData = Audio.sound.play(param1,param2);
         if(_loc4_ != null)
         {
            _loc4_.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete,false,0,true);
            _loc4_.allowAutoTransformUpdates = false;
            _loc3_ = new SoundOutput();
            _loc3_.soundData = _loc4_;
            _loc3_.volume = param2.hasOwnProperty("volume") ? Number(param2.volume) : 1;
            _loc3_.pan = param2.hasOwnProperty("pan") ? Number(param2.pan) : 0;
            if(param2.hasOwnProperty("maxDistance"))
            {
               _loc3_.maxDistance = Number(param2.maxDistance);
            }
            if(param2.hasOwnProperty("minDistance"))
            {
               _loc3_.minDistance = Number(param2.minDistance);
            }
            if(_loc4_.channel != null)
            {
               _loc4_.channel.soundTransform.volume = scene == null || _loc3_.muted ? 0 : _loc3_.volume;
               _loc4_.channel.soundTransform = _loc4_.channel.soundTransform;
               this._soundsPlaying.push(_loc3_);
               this._playingSoundsBySoundData[_loc4_] = _loc3_;
               this.update();
            }
         }
         return _loc3_;
      }
      
      override public function update(param1:Number = 1) : void
      {
         var _loc2_:SoundOutput = null;
         var _loc3_:SoundTransform = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         if(scene == null || this._soundsPlaying.length == 0 || this.position == null)
         {
            return;
         }
         if(!Settings.getInstance().sound3D)
         {
            for each(_loc2_ in this._soundsPlaying)
            {
               if(!(_loc2_.soundData == null || _loc2_.soundData.channel == null))
               {
                  _loc3_ = _loc2_.soundData.channel.soundTransform;
                  _loc3_.volume = this.volume * _loc2_.volume * SoundSource3D.volume;
                  _loc3_.pan = 0;
                  _loc2_.soundData.channel.soundTransform = _loc3_;
               }
            }
            return;
         }
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:Number = scene.getCurrentZoom();
         var _loc7_:Number = scene.camera.view.width * 2;
         var _loc8_:Vector3D = scene.container.localToGlobal(this.position,this._positionGlobal);
         var _loc9_:Number = _loc8_.x < 0 ? -_loc8_.x : _loc8_.x;
         var _loc10_:Number = _loc8_.y < 0 ? -_loc8_.y : _loc8_.y;
         for each(_loc2_ in this._soundsPlaying)
         {
            if(!(_loc2_.soundData == null || _loc2_.soundData.channel == null))
            {
               _loc3_ = _loc2_.soundData.channel.soundTransform;
               if(_loc2_.muted)
               {
                  _loc4_ = 0;
               }
               else
               {
                  if(_loc9_ <= _loc2_.minDistance)
                  {
                     _loc11_ = 1;
                  }
                  else
                  {
                     _loc11_ = 1 - (_loc8_.x - _loc2_.minDistance) / (_loc2_.maxDistance - _loc2_.minDistance);
                  }
                  if(_loc10_ <= _loc2_.minDistance)
                  {
                     _loc12_ = 1;
                  }
                  else
                  {
                     _loc12_ = 1 - (_loc8_.y - _loc2_.minDistance) / (_loc2_.maxDistance - _loc2_.minDistance);
                  }
                  if(_loc11_ < 0)
                  {
                     _loc11_ = 0;
                  }
                  if(_loc11_ > 1)
                  {
                     _loc11_ = 1;
                  }
                  if(_loc12_ < 0)
                  {
                     _loc12_ = 0;
                  }
                  if(_loc12_ > 1)
                  {
                     _loc12_ = 1;
                  }
                  _loc4_ = this.volume * _loc2_.volume * _loc11_ * (_loc12_ * 2) * _loc6_;
                  if(_loc4_ > 1)
                  {
                     _loc4_ = 1;
                  }
                  else if(_loc4_ < 0)
                  {
                     _loc4_ = 0;
                  }
                  _loc13_ = _loc8_.x / _loc7_;
                  if(_loc13_ < -1)
                  {
                     _loc13_ = -1;
                  }
                  else if(_loc13_ > 1)
                  {
                     _loc13_ = 1;
                  }
                  _loc5_ = this.pan + _loc2_.pan + _loc13_;
                  if(_loc5_ < -1)
                  {
                     _loc5_ = -1;
                  }
                  else if(_loc5_ > 1)
                  {
                     _loc5_ = 1;
                  }
               }
               _loc3_.volume = _loc4_ * SoundSource3D.volume;
               _loc3_.pan = _loc5_;
               _loc2_.soundData.channel.soundTransform = _loc3_;
            }
         }
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         var _loc3_:int = 0;
         if(this._disposed)
         {
            return;
         }
         var _loc2_:SoundOutput = this._playingSoundsBySoundData[param1.currentTarget as SoundData];
         if(_loc2_ != null)
         {
            _loc3_ = int(this._soundsPlaying.indexOf(_loc2_));
            if(_loc3_ > -1)
            {
               this._soundsPlaying.splice(_loc3_,1);
            }
            this._playingSoundsBySoundData[_loc2_.soundData] = null;
            delete this._playingSoundsBySoundData[_loc2_.soundData];
         }
      }
   }
}

