package thelaststand.common.resources.formats
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.lights.AmbientLight;
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.objects.Mesh;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import org.osflash.signals.DeluxeSignal;
   
   public class ColladaA3DHandler implements IFormatHandler
   {
      
      public static const TYPE:String = "dae";
      
      private var _parser:ParserCollada;
      
      private var _rawData:XML;
      
      private var _loaded:Boolean;
      
      private var _loading:Boolean;
      
      private var _loader:URLLoader;
      
      private var _loadCompleted:DeluxeSignal;
      
      private var _loadFailed:DeluxeSignal;
      
      private var _loadProgress:DeluxeSignal;
      
      public function ColladaA3DHandler()
      {
         super();
         this._loader = new URLLoader();
         this._loader.dataFormat = URLLoaderDataFormat.TEXT;
         this._loader.addEventListener(Event.COMPLETE,this.onLoadComplete,false,0,true);
         this._loader.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress,false,0,true);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadIOError,false,0,true);
         this._parser = new ParserCollada();
         this._loadCompleted = new DeluxeSignal(this,IFormatHandler);
         this._loadFailed = new DeluxeSignal(this,IFormatHandler,Object);
         this._loadProgress = new DeluxeSignal(this,IFormatHandler,uint,uint);
      }
      
      public function dispose() : void
      {
         var _loc1_:Resource = null;
         var _loc2_:Object3D = null;
         var _loc3_:ParserMaterial = null;
         var _loc4_:Mesh = null;
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
         this._loadCompleted.removeAll();
         this._loadFailed.removeAll();
         this._loadProgress.removeAll();
         if(this._parser != null)
         {
            for each(_loc2_ in this._parser.objects)
            {
               for each(_loc1_ in _loc2_.getResources(true))
               {
                  _loc1_.dispose();
               }
               _loc4_ = _loc2_ as Mesh;
               if(_loc4_ != null)
               {
                  _loc4_.geometry = null;
               }
            }
            for each(_loc3_ in this._parser.materials)
            {
               for each(_loc1_ in _loc3_.getResources())
               {
                  _loc1_.dispose();
               }
            }
            this._parser.clean();
            this._parser = null;
         }
      }
      
      public function getContent() : *
      {
         if(!this._loaded)
         {
            return null;
         }
         return this._parser;
      }
      
      public function getContentAsByteArray() : ByteArray
      {
         if(!this._loaded)
         {
            return null;
         }
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeUTFBytes(this._rawData);
         _loc1_.position = 0;
         return _loc1_;
      }
      
      public function load(param1:String, param2:* = null) : void
      {
         this._loaded = false;
         this._loading = true;
         this._loader.load(new URLRequest(param1));
      }
      
      public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         param1.position = 0;
         this.parseAndComplete(XML(param1.readUTFBytes(param1.bytesAvailable)));
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
      
      private function parseAndComplete(param1:XML) : void
      {
         var _loc2_:Light3D = null;
         var _loc3_:int = 0;
         this._parser.parse(param1);
         this._parser.animations.length = 0;
         this._parser.alternativa3d::layers.length = 0;
         this._parser.alternativa3d::layersMap = null;
         for each(_loc2_ in this._parser.lights)
         {
            if(_loc2_ is AmbientLight || _loc2_.name == "EnvironmentAmbientLight")
            {
               _loc3_ = int(this._parser.lights.indexOf(_loc2_));
               if(_loc3_ > -1)
               {
                  this._parser.lights.splice(_loc3_,1);
               }
               _loc3_ = int(this._parser.objects.indexOf(_loc2_));
               if(_loc3_ > -1)
               {
                  this._parser.objects.splice(_loc3_,1);
               }
               _loc3_ = int(this._parser.hierarchy.indexOf(_loc2_));
               if(_loc3_ > -1)
               {
                  this._parser.hierarchy.splice(_loc3_,1);
               }
            }
         }
         this._loaded = true;
         this._loading = false;
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
         this._loader.data = null;
         this._rawData = param1;
         this._loadCompleted.dispatch(this);
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.currentTarget.data);
         this.parseAndComplete(_loc2_);
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
         return TYPE;
      }
      
      public function get extensions() : Array
      {
         return ["dae","DAE"];
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

