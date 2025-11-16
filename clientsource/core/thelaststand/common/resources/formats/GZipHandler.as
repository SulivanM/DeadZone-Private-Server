package thelaststand.common.resources.formats
{
   import com.probertson.utils.GZIPBytesEncoder;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import org.osflash.signals.DeluxeSignal;
   import thelaststand.common.error.CustomError;
   
   public class GZipHandler implements IFormatHandler
   {
      
      public static const ERROR_HANDLER_PARSE:uint = 99;
      
      private static var _gzip:GZIPBytesEncoder = new GZIPBytesEncoder();
      
      private static var _uriRegExp:RegExp = /(\._v[0-9]+)*\.gz$/ig;
      
      protected var _loaded:Boolean;
      
      protected var _loading:Boolean;
      
      protected var _loader:URLLoader;
      
      private var _loadRetryCount:int = 0;
      
      private var _loadMaxRetry:int = 5;
      
      private var _uri:String;
      
      private var _handler:IFormatHandler;
      
      private var _type:String;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      public function GZipHandler()
      {
         super();
         this._loader = new URLLoader();
         this._loader.dataFormat = URLLoaderDataFormat.BINARY;
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
         this._loader.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         this._loader.removeEventListener(ProgressEvent.PROGRESS,this.onLoadProgress);
         this._loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError);
         this._loader.data = null;
         this._loader = null;
         this._loaded = false;
         this._loadRetryCount = 0;
         this._loadCompleted.removeAll();
         this._loadFailed.removeAll();
         this._loadProgress.removeAll();
         if(this._handler != null)
         {
            this._handler.dispose();
            this._handler = null;
         }
      }
      
      public function getContent() : *
      {
         if(!this._loaded)
         {
            return null;
         }
         return this._handler != null ? this._handler.getContent() : null;
      }
      
      public function getContentAsByteArray() : ByteArray
      {
         return this._handler != null ? this._handler.getContentAsByteArray() : null;
      }
      
      public function load(param1:String, param2:* = null) : void
      {
         this._loadRetryCount = 0;
         this._uri = param1;
         this._loaded = false;
         this._loading = true;
         this._loader.load(new URLRequest(param1));
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         throw new Error("loadFromByteArray is not supported for this resource type (" + this.id + ": " + this.extensions + ")");
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
      
      private function getServerErrorReport() : String
      {
         var _loc1_:ByteArray = null;
         var _loc2_:String = null;
         if(this._loader.data == null)
         {
            return "";
         }
         try
         {
            _loc1_ = ByteArray(this._loader.data);
            _loc2_ = _loc1_.readUTFBytes(_loc1_.bytesAvailable);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         catch(e:Error)
         {
         }
         return "";
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var compressedData:ByteArray;
         var dataURI:String;
         var ext:String;
         var decompressedData:ByteArray = null;
         var e:Event = param1;
         this._loaded = true;
         this._loading = false;
         compressedData = this._loader.data as ByteArray;
         if(compressedData == null)
         {
            this._loadFailed.dispatch(this,new CustomError("No data to parse",this._loader.data,GZipHandler.ERROR_HANDLER_PARSE));
            return;
         }
         try
         {
            compressedData.position = 0;
            decompressedData = _gzip.uncompressToByteArray(compressedData);
         }
         catch(error:Error)
         {
            _loadFailed.dispatch(this,new CustomError("Data is not a gzip formatted",{
               "response":getServerErrorReport(),
               "error":error.message
            },GZipHandler.ERROR_HANDLER_PARSE));
            return;
         }
         dataURI = this._uri.replace(_uriRegExp,"");
         ext = dataURI.substr(dataURI.lastIndexOf(".") + 1);
         switch(ext)
         {
            case "xml":
               this._handler = new XMLHandler();
               break;
            case "dae":
               this._handler = new ColladaA3DHandler();
               break;
            case "daeanim":
               this._handler = new ColladaA3DAnimHandler();
         }
         if(this._handler != null)
         {
            try
            {
               this._type = this._handler.id;
               this._handler.loadCompleted.addOnce(this.onHandlerLoaded);
               this._handler.loadFromByteArray(decompressedData);
            }
            catch(error:Error)
            {
               _type = id;
               _handler.loadCompleted.remove(onHandlerLoaded);
               _handler.dispose();
               _handler = null;
               if(++_loadRetryCount < _loadMaxRetry)
               {
                  _loaded = false;
                  _loading = true;
                  _loader.load(new URLRequest(_uri));
                  return;
               }
               _loadFailed.dispatch(this,new CustomError("Handler failed to parse decompressed data",{
                  "response":getServerErrorReport(),
                  "error":error.message
               },GZipHandler.ERROR_HANDLER_PARSE));
            }
         }
         else
         {
            this._loadFailed.dispatch(this,new Error("No handler found for GZip type \'" + ext + "\'"));
         }
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
         this._loader.data = null;
      }
      
      private function onHandlerLoaded(param1:IFormatHandler) : void
      {
         this.loadCompleted.dispatch(this);
      }
      
      private function onLoadIOError(param1:IOErrorEvent) : void
      {
         var _loc2_:String = this.getServerErrorReport();
         if(_loc2_)
         {
            param1.text += "<br/>" + _loc2_;
         }
         this._loadFailed.dispatch(this,param1);
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
         this._loadProgress.dispatch(this,param1.bytesLoaded,param1.bytesTotal);
      }
      
      public function get id() : String
      {
         return "gz";
      }
      
      public function get extensions() : Array
      {
         return ["gz","gzip"];
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
      
      public function get type() : String
      {
         return this._type;
      }
   }
}

