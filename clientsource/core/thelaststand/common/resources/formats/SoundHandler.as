package thelaststand.common.resources.formats
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import org.osflash.signals.DeluxeSignal;
   
   public class SoundHandler extends EventDispatcher implements IFormatHandler
   {
      
      private var _disposed:Boolean;
      
      private var _loaded:Boolean;
      
      private var _loading:Boolean;
      
      private var _sound:Sound;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      public function SoundHandler()
      {
         super();
         this._loadCompleted = new DeluxeSignal(this,IFormatHandler);
         this._loadFailed = new DeluxeSignal(this,IFormatHandler,Object);
         this._loadProgress = new DeluxeSignal(this,IFormatHandler,uint,uint);
      }
      
      public function dispose() : void
      {
         this._disposed = true;
         if(this._sound != null)
         {
            try
            {
               this._sound.close();
            }
            catch(e:Error)
            {
            }
            this._sound = null;
         }
         this._loaded = false;
         this._loadCompleted.removeAll();
         this._loadFailed.removeAll();
         this._loadProgress.removeAll();
      }
      
      public function getContent() : *
      {
         return this._loaded ? this._sound : null;
      }
      
      public function getContentAsByteArray() : ByteArray
      {
         var _loc1_:ByteArray = null;
         if(this._sound != null)
         {
            _loc1_ = new ByteArray();
            this._sound.extract(_loc1_,this._sound.bytesTotal);
            return _loc1_;
         }
         return null;
      }
      
      public function load(param1:String, param2:* = null) : void
      {
         var url:String = param1;
         var context:* = param2;
         if(this._disposed)
         {
            return;
         }
         this._loaded = false;
         this._loading = true;
         try
         {
            this.createSound();
            this._sound.load(new URLRequest(url),context as SoundLoaderContext);
         }
         catch(error:Error)
         {
            _loading = false;
            _loadFailed.dispatch(this,error);
         }
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         var byteArray:ByteArray = param1;
         var context:* = param2;
         try
         {
            this.createSound();
            this._sound.loadCompressedDataFromByteArray(byteArray,byteArray.bytesAvailable);
         }
         catch(error:Error)
         {
            throw new Error("loadFromByteArray is not supported for this resource type (" + id + ": " + extensions + ")");
         }
         this._loaded = true;
         this._loading = false;
         this._loadCompleted.dispatch(this);
      }
      
      public function pauseLoad() : void
      {
         this._loading = false;
         if(this._sound != null)
         {
            try
            {
               this._sound.close();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      private function createSound() : void
      {
         this._sound = new Sound();
         this._sound.addEventListener(Event.COMPLETE,this.onLoadComplete,false,0,true);
         this._sound.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress,false,0,true);
         this._sound.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError,false,0,true);
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         this._loaded = true;
         this._loading = false;
         this._loadCompleted.dispatch(this);
      }
      
      private function onLoadIOError(param1:IOErrorEvent) : void
      {
         this._loading = false;
         this._loadFailed.dispatch(this,param1);
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
         this._loadProgress.dispatch(this,param1.bytesLoaded,param1.bytesTotal);
      }
      
      public function get id() : String
      {
         return "snd";
      }
      
      public function get extensions() : Array
      {
         return ["mp3"];
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
      }
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      public function get loadCompleted() : DeluxeSignal
      {
         return this._loadCompleted;
      }
      
      public function get loadFailed() : DeluxeSignal
      {
         return this._loadFailed;
      }
      
      public function get loadProgress() : DeluxeSignal
      {
         return this._loadProgress;
      }
   }
}

