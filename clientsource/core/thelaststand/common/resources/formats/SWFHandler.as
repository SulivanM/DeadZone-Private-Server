package thelaststand.common.resources.formats
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import org.osflash.signals.DeluxeSignal;
   
   public class SWFHandler extends EventDispatcher implements IFormatHandler
   {
      
      private var _loaded:Boolean;
      
      private var _loading:Boolean;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      protected var _loader:Loader;
      
      public function SWFHandler()
      {
         super();
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete,false,0,false);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadSecurityError,false,0,true);
         this._loadCompleted = new DeluxeSignal(this,IFormatHandler);
         this._loadFailed = new DeluxeSignal(this,IFormatHandler,Object);
         this._loadProgress = new DeluxeSignal(this,IFormatHandler,uint,uint);
      }
      
      public function dispose() : void
      {
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onLoadProgress);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError);
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
         if(this.getPlayerMajorVersion() >= 10)
         {
            try
            {
               this._loader["unloadAndStop"]();
            }
            catch(e:Error)
            {
            }
         }
         else
         {
            try
            {
               this._loader.unload();
            }
            catch(e:Error)
            {
            }
         }
         this._loader = null;
         this._loaded = false;
         this._loadCompleted.removeAll();
         this._loadFailed.removeAll();
         this._loadProgress.removeAll();
      }
      
      public function getContent() : *
      {
         if(!this._loaded)
         {
            return null;
         }
         return this._loader.content;
      }
      
      public function getContentAsByteArray() : ByteArray
      {
         throw new Error("getContentAsByteArray is not supported for this resource type (" + this.id + ": " + this.extensions + ")");
      }
      
      public function load(param1:String, param2:* = null) : void
      {
         this._loaded = false;
         this._loading = true;
         this._loader.load(new URLRequest(param1),param2 as LoaderContext);
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         this._loaded = false;
         this._loading = true;
         this._loader.loadBytes(param1,param2 as LoaderContext);
      }
      
      public function pauseLoad() : void
      {
         this._loading = false;
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
      }
      
      private function getPlayerMajorVersion() : int
      {
         return int(Capabilities.version.match(/(\d+),/)[1]);
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
      
      private function onLoadSecurityError(param1:SecurityErrorEvent) : void
      {
         this._loading = false;
         this._loadFailed.dispatch(this,param1);
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
         this._loadProgress.dispatch(this,param1.bytesTotal,param1.bytesLoaded);
      }
      
      public function get id() : String
      {
         return "swf";
      }
      
      public function get extensions() : Array
      {
         return ["swf"];
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

