package thelaststand.common.resources.formats
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.clearTimeout;
   import org.as3commons.zip.Zip;
   import org.osflash.signals.DeluxeSignal;
   
   public class ZIPHandler implements IFormatHandler
   {
      
      public static const TYPE:String = "zip";
      
      private var _zip:Zip;
      
      private var _timeout:uint;
      
      private var _loaded:Boolean;
      
      private var _loading:Boolean;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      public function ZIPHandler()
      {
         super();
         this._zip = new Zip();
         this._zip.addEventListener(Event.COMPLETE,this.onLoadComplete,false,0,true);
         this._zip.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress,false,0,true);
         this._zip.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError,false,0,true);
         this._loadCompleted = new DeluxeSignal(this,IFormatHandler);
         this._loadFailed = new DeluxeSignal(this,IFormatHandler,Object);
         this._loadProgress = new DeluxeSignal(this,IFormatHandler,uint,uint);
      }
      
      public function dispose() : void
      {
         try
         {
            this._zip.close();
         }
         catch(e:Error)
         {
         }
         this._zip = null;
         this._loaded = false;
         this._loadCompleted.removeAll();
         this._loadFailed.removeAll();
         this._loadProgress.removeAll();
         clearTimeout(this._timeout);
      }
      
      public function getContent() : *
      {
         if(!this._loaded)
         {
            return null;
         }
         return this._zip;
      }
      
      public function getContentAsByteArray() : ByteArray
      {
         if(!this._loaded)
         {
            return null;
         }
         return null;
      }
      
      public function load(param1:String, param2:* = null) : void
      {
         this._loaded = false;
         this._loading = true;
         this._zip.load(new URLRequest(param1));
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         try
         {
            this._zip.close();
         }
         catch(e:Error)
         {
         }
         this._zip.loadBytes(param1);
      }
      
      public function pauseLoad() : void
      {
         this._loading = false;
         clearTimeout(this._timeout);
         try
         {
            this._zip.close();
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
         return "zip";
      }
      
      public function get extensions() : Array
      {
         return ["zip"];
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

