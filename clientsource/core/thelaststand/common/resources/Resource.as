package thelaststand.common.resources
{
   import flash.utils.ByteArray;
   import thelaststand.common.resources.formats.GZipHandler;
   import thelaststand.common.resources.formats.IFormatHandler;
   
   public class Resource
   {
      
      internal var cacheVersion:String;
      
      internal var fromByteArray:ByteArray;
      
      internal var onComplete:Function;
      
      internal var onCompleteParams:Array;
      
      internal var onError:Function;
      
      internal var onErrorParams:Array;
      
      internal var onProgress:Function;
      
      internal var onProgressParams:Array;
      
      internal var onStart:Function;
      
      internal var onStartParams:Array;
      
      internal var priority:int;
      
      private var _disposed:Boolean = false;
      
      private var _bytesLoaded:int;
      
      private var _bytesTotal:int;
      
      private var _handler:IFormatHandler;
      
      private var _loading:Boolean;
      
      private var _type:String;
      
      private var _uri:String;
      
      public var realURL:String;
      
      public var context:*;
      
      public var content:*;
      
      public var data:*;
      
      public function Resource(param1:String, param2:String, param3:IFormatHandler = null)
      {
         super();
         this._uri = param1;
         this._type = param2;
         this._handler = param3;
         if(this._handler)
         {
            this._handler.loadProgress.addWithPriority(this.onLoadProgress,int.MAX_VALUE);
            this._handler.loadCompleted.addOnceWithPriority(this.onLoadComplete,int.MAX_VALUE);
         }
      }
      
      public function toString() : String
      {
         return "(Resource uri=" + this._uri + ", type=" + this._type + ", priority=" + this.priority + ", bytesTotal=" + this._bytesTotal + ", bytesLoaded=" + this._bytesLoaded + ")";
      }
      
      public function getRawData() : ByteArray
      {
         return this._handler != null ? this._handler.getContentAsByteArray() : null;
      }
      
      internal function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         if(this._handler)
         {
            this._handler.loadProgress.remove(this.onLoadProgress);
            this._handler.loadCompleted.remove(this.onLoadComplete);
            this._handler.dispose();
         }
         this._handler = null;
         this._uri = this._type = null;
         this._bytesLoaded = this._bytesTotal = 0;
         this.content = null;
         this.context = null;
         this.data = null;
         this.onComplete = this.onError = this.onProgress = this.onStart = null;
         this.onCompleteParams = this.onErrorParams = this.onProgressParams = this.onStartParams = null;
         this.priority = 0;
      }
      
      private function onLoadComplete(param1:IFormatHandler) : void
      {
         this._handler.loadProgress.remove(this.onLoadProgress);
         this.content = this._handler.getContent();
         if(this._handler is GZipHandler)
         {
            this._type = GZipHandler(this._handler).type;
         }
         this.fromByteArray = null;
         this._loading = false;
      }
      
      private function onLoadProgress(param1:IFormatHandler, param2:uint, param3:uint) : void
      {
         this._bytesLoaded = param2;
         this._bytesTotal = param3;
      }
      
      public function get bytesLoaded() : int
      {
         return this._bytesLoaded;
      }
      
      public function get bytesTotal() : int
      {
         return this._bytesTotal;
      }
      
      internal function get handler() : IFormatHandler
      {
         return this._handler;
      }
      
      public function get loading() : Boolean
      {
         return this._handler ? this._handler.loading : false;
      }
      
      public function get loaded() : Boolean
      {
         return this._handler ? this._handler.loaded : true;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get uri() : String
      {
         return this._uri;
      }
      
      public function get disposed() : Boolean
      {
         return this._disposed;
      }
   }
}

