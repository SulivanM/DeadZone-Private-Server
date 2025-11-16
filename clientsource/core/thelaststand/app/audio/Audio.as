package thelaststand.app.audio
{
   import com.exileetiquette.sound.SoundManager;
   import com.greensock.TweenMax;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import flash.utils.getDefinitionByName;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.resources.ResourceManager;
   
   public class Audio
   {
      
      private static var _soundMuted:Boolean;
      
      private static var _musicMuted:Boolean;
      
      private static var _musicSound:Sound;
      
      private static var _saveTimeout:uint;
      
      private static const MUSIC_BUFFER_TIME:int = 30;
      
      private static var _musicEnabled:Boolean = true;
      
      private static var _soundMuteVolume:Number = 1;
      
      private static var _musicMuteVolume:Number = 1;
      
      public static var sound:SoundManager = new SoundManager();
      
      public static var music:SoundManager = new SoundManager();
      
      public function Audio()
      {
         super();
         throw new Error("Audio cannot be directly instantiated.");
      }
      
      public static function init() : void
      {
         sound.volume = Settings.getInstance().getData("soundVolume",1);
         music.volume = Settings.getInstance().getData("musicVolume",0.5);
         _soundMuted = sound.volume <= 0;
         _musicMuted = music.volume <= 0;
         set3DSoundVolume(sound.volume);
         var _loc1_:String = ResourceManager.getInstance().baseURL + Config.getPath("music");
         _musicSound = new Sound();
         _musicSound.addEventListener(IOErrorEvent.IO_ERROR,onMusicIOError,false,0,true);
         if(_loc1_.substr(0,1) != "/")
         {
            _loc1_ = "/" + _loc1_;
         }
         _musicSound.load(new URLRequest(PlayerIOConnector.getInstance().client.gameFS.getUrl(_loc1_,Global.useSSL)),new SoundLoaderContext(MUSIC_BUFFER_TIME * 1000));
         music.addSound(_musicSound,"music");
         music.play("ambience",{"loops":-1});
         music.play("music",{"loops":-1});
      }
      
      public static function setSoundVolume(param1:Number) : void
      {
         if(param1 <= 0)
         {
            soundMuted = true;
            _soundMuteVolume = 1;
         }
         else
         {
            Audio.sound.volume = param1;
         }
         set3DSoundVolume(param1);
         TweenMax.killDelayedCallsTo(saveSettings);
         TweenMax.delayedCall(250,saveSettings);
      }
      
      public static function setMusicVolume(param1:Number) : void
      {
         if(param1 <= 0)
         {
            musicMuted = true;
            _musicMuteVolume = 1;
         }
         else
         {
            Audio.music.volume = param1;
         }
         TweenMax.killDelayedCallsTo(saveSettings);
         TweenMax.delayedCall(250,saveSettings);
      }
      
      private static function set3DSoundVolume(param1:Number) : void
      {
         var _loc2_:Class = null;
         try
         {
            _loc2_ = getDefinitionByName("thelaststand.engine.audio.SoundSource3D") as Class;
            _loc2_["volume"] = param1;
         }
         catch(e:Error)
         {
         }
      }
      
      private static function saveSettings() : void
      {
         TweenMax.killDelayedCallsTo(saveSettings);
         Settings.getInstance().setData("soundVolume",Audio.sound.volume,false);
         Settings.getInstance().setData("musicVolume",Audio.music.volume,false);
         Settings.getInstance().flush();
      }
      
      private static function onMusicIOError(param1:IOErrorEvent) : void
      {
      }
      
      public static function get soundMuted() : Boolean
      {
         return _soundMuted;
      }
      
      public static function set soundMuted(param1:Boolean) : void
      {
         _soundMuted = param1;
         if(_soundMuted)
         {
            _soundMuteVolume = sound.volume > 0 ? sound.volume : 1;
            sound.volume = 0;
         }
         else
         {
            sound.volume = _soundMuteVolume;
         }
         set3DSoundVolume(sound.volume);
         saveSettings();
      }
      
      public static function get musicMuted() : Boolean
      {
         return _musicMuted;
      }
      
      public static function set musicMuted(param1:Boolean) : void
      {
         _musicMuted = param1;
         if(_musicMuted)
         {
            _musicMuteVolume = music.volume > 0 ? music.volume : 1;
            music.volume = 0;
         }
         else
         {
            music.volume = _musicMuteVolume;
         }
         saveSettings();
      }
   }
}

