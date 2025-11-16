package thelaststand.common.resources.formats
{
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.loaders.ParserCollada;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.clearTimeout;
   import org.osflash.signals.DeluxeSignal;
   
   public class ColladaA3DAnimHandler implements IFormatHandler
   {
      
      private var _anim:AnimationClip;
      
      private var _timeout:uint;
      
      private var _loaded:Boolean;
      
      private var _loading:Boolean;
      
      private var _loader:URLLoader;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      public function ColladaA3DAnimHandler()
      {
         super();
         this._loader = new URLLoader();
         this._loader.dataFormat = URLLoaderDataFormat.TEXT;
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
         this._anim = null;
      }
      
      public function getContent() : *
      {
         if(!this._loaded)
         {
            return null;
         }
         return this._anim;
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
         this._loader.load(new URLRequest(param1));
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         var _loc3_:ColladaA3DAnimHandler = this;
         clearTimeout(this._timeout);
         param1.position = 0;
         this.parseAndComplete.apply(_loc3_,[XML(param1.readUTFBytes(param1.bytesAvailable))]);
      }
      
      public function pauseLoad() : void
      {
         this._loading = false;
         clearTimeout(this._timeout);
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
      }
      
      private function parseAndComplete(param1:XML) : void
      {
         this._anim = ParserCollada.parseAnimation(param1);
         this._loaded = true;
         this._loading = false;
         this._loader.data = null;
         this._loadCompleted.dispatch(this);
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         clearTimeout(this._timeout);
         this.parseAndComplete(XML(param1.currentTarget.data));
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
         return "daeanim";
      }
      
      public function get extensions() : Array
      {
         return ["daeanim"];
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

