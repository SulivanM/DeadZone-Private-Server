package thelaststand.engine.audio
{
   import com.exileetiquette.sound.SoundData;
   
   public class SoundOutput
   {
      
      internal var muted:Boolean;
      
      public var soundData:SoundData;
      
      public var minDistance:Number = 0;
      
      public var maxDistance:Number = 2000;
      
      public var volume:Number = 1;
      
      public var pan:Number = 0;
      
      public function SoundOutput()
      {
         super();
      }
      
      public function mute() : void
      {
         this.muted = true;
         if(this.soundData != null && this.soundData.channel != null)
         {
            this.soundData.channel.soundTransform.volume = 0;
            this.soundData.channel.soundTransform = this.soundData.channel.soundTransform;
         }
      }
      
      public function unmute() : void
      {
         this.muted = false;
      }
   }
}

