package thelaststand.common.resources.formats
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import org.osflash.signals.DeluxeSignal;
   
   public class GenericHandler extends EventDispatcher implements IFormatHandler
   {
      
      protected var _loaded:Boolean;
      
      protected var _loading:Boolean;
      
      protected var _loader:URLLoader;
      
      private var _data:*;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      public function GenericHandler()
      {
         super();
         this._loader = new URLLoader();
         this._loader.addEventListener(Event.COMPLETE,this.onLoadComplete,false,0,true);
         this._loader.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress,false,0,true);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError,false,0,true);
         this._loadCompleted = new DeluxeSignal(this,IFormatHandler);
         this._loadFailed = new DeluxeSignal(this,IFormatHandler,Object);
         this._loadProgress = new DeluxeSignal(this,IFormatHandler,uint,uint);
      }
      
      public function dispose() : void
      {
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
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
         if(this._data == null)
         {
            this._data = this._loader.data;
         }
         return this._data;
      }
      
      public function getContentAsByteArray() : ByteArray
      {
         throw new Error("getContentAsByteArray is not supported for this resource type (" + this.id + ": " + this.extensions + ")");
      }
      
      public function load(param1:String, param2:* = null) : void
      {
         this._loaded = false;
         this._loading = true;
         this._loader.load(new URLRequest(param1));
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         var text:String = null;
         var byteArray:ByteArray = param1;
         var context:* = param2;
         try
         {
            text = byteArray.readUTFBytes(byteArray.bytesAvailable);
            this._data = text;
         }
         catch(e:Error)
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
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         this._loaded = true;
         this._loading = false;
         this._loadCompleted.dispatch(this);
      }
      
      private function onLoadIOError(param1:IOErrorEvent) : void
      {
         this._loadFailed.dispatch(this,param1);
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
         this._loadProgress.dispatch(this,param1.bytesLoaded,param1.bytesTotal);
      }
      
      public function get id() : String
      {
         return null;
      }
      
      public function get extensions() : Array
      {
         return null;
      }
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
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

