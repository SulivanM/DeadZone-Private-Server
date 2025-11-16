package thelaststand.common.resources
{
   import com.dynamicflash.util.Base64;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.formats.*;
   
   public class ResourceManager
   {
      
      private static var _global:ResourceManager;
      
      private static const GLOBAL_ID:String = "$_global";
      
      private static var _formats:Dictionary = new Dictionary(true);
      
      private static var _formatExtensions:Dictionary = new Dictionary(true);
      
      private static var _local:Dictionary = new Dictionary(true);
      
      private static var _managerQueue:Array = [];
      
      public static const TYPE_BINARY:String = "bin";
      
      public static const TYPE_IMAGE:String = "img";
      
      public static const TYPE_SOUND:String = "snd";
      
      public static const TYPE_SWF:String = "swf";
      
      public static const TYPE_TEXT:String = "txt";
      
      public static const TYPE_XML:String = "xml";
      
      public static const TYPE_ZIP:String = "zip";
      
      public static const TYPE_GZIP:String = "gz";
      
      registerFileFormat(BinaryHandler);
      registerFileFormat(GenericHandler,["txt"]);
      registerFileFormat(ImageHandler);
      registerFileFormat(SoundHandler);
      registerFileFormat(SWFHandler);
      registerFileFormat(XMLHandler);
      registerFileFormat(ZIPHandler);
      registerFileFormat(GZipHandler);
      
      private var _baseURL:String = "";
      
      private var _cacheName:String;
      
      private var _cacheObject:SharedObject;
      
      private var _cacheQueue:Array;
      
      private var _defaultLoaderContext:LoaderContext;
      
      private var _id:String;
      
      private var _loading:Boolean = true;
      
      private var _loadingResource:Resource;
      
      private var _loadingXML:Boolean;
      
      private var _loadSequentially:Boolean = true;
      
      private var _animations:AnimationLibrary;
      
      private var _materials:MaterialLibrary;
      
      private var _queue:Array;
      
      private var _resources:Array;
      
      private var _resourcesByURI:Dictionary;
      
      private var _unpacker:ResourceUnpacker;
      
      public var cacheEnabled:Boolean;
      
      public var queryString:String;
      
      public var uriProcessor:Function;
      
      public var cacheFlushResponded:Signal;
      
      public var resourceLoadCompleted:Signal;
      
      public var resourceLoadFailed:Signal;
      
      public var resourceLoadProgress:Signal;
      
      public var resourceLoadStarted:Signal;
      
      public var queueLoadCompleted:Signal;
      
      public var queueLoadStarted:Signal;
      
      public var queueLoadStopped:Signal;
      
      public var unpackCompleted:Signal;
      
      public var unpackProgress:Signal;
      
      public var unpackStarted:Signal;
      
      public var xmlListLoadCompleted:Signal;
      
      public var xmlListLoadFailed:Signal;
      
      public var xmlListAddedToQueue:Signal;
      
      private var _packageFiles:Dictionary = new Dictionary();
      
      public function ResourceManager(param1:ResourceManagerSingletonEnforcer, param2:String)
      {
         super();
         if(!param1)
         {
            throw new Error("ResourceManager is a Multiton and cannot be directly instantiated. Use ResourceManager.getInstance().");
         }
         this._id = param2;
         this._queue = [];
         this._resources = [];
         this._resourcesByURI = new Dictionary(true);
         this._cacheQueue = [];
         this._animations = new AnimationLibrary();
         this._materials = new MaterialLibrary();
         this.cacheFlushResponded = new Signal(Boolean);
         this.resourceLoadCompleted = new Signal(Resource);
         this.resourceLoadFailed = new Signal(Resource,Object);
         this.resourceLoadProgress = new Signal(Resource);
         this.resourceLoadStarted = new Signal(Resource);
         this.queueLoadCompleted = new Signal();
         this.queueLoadStarted = new Signal();
         this.queueLoadStopped = new Signal();
         this.unpackStarted = new Signal();
         this.unpackCompleted = new Signal();
         this.unpackProgress = new Signal(Resource,uint,uint);
         this.xmlListLoadCompleted = new Signal(XML);
         this.xmlListLoadFailed = new Signal();
         this.xmlListAddedToQueue = new Signal(XML);
      }
      
      public static function getInstance(param1:String = null) : ResourceManager
      {
         if(!_global)
         {
            _global = new ResourceManager(new ResourceManagerSingletonEnforcer(),GLOBAL_ID);
            _managerQueue[0] = _global;
         }
         if(!param1 || param1 == GLOBAL_ID)
         {
            return _global;
         }
         var _loc2_:ResourceManager = _local[param1];
         if(!_loc2_)
         {
            _loc2_ = new ResourceManager(new ResourceManagerSingletonEnforcer(),param1);
            _local[param1] = _loc2_;
            _managerQueue.push(_loc2_);
         }
         return _loc2_;
      }
      
      public static function getResourceHandlerFromURI(param1:String) : IFormatHandler
      {
         var _loc2_:String = param1.substr(param1.lastIndexOf(".") + 1);
         var _loc3_:String = _formatExtensions[_loc2_];
         var _loc4_:Class = _formats[_loc3_];
         if(!_loc4_)
         {
            throw new Error("No format handler with the type \'" + _loc3_ + "\' has been registered. Use ResourceManager.registerFileFormat() to register new file formats.");
         }
         return new _loc4_();
      }
      
      public static function registerFileFormat(param1:Class, param2:Array = null, param3:String = null) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:IFormatHandler = new param1();
         param3 = param3 ? param3 : _loc4_.id;
         param2 = param2 ? param2 : _loc4_.extensions;
         _formats[param3] = param1;
         if(param2)
         {
            _loc5_ = 0;
            _loc6_ = int(param2.length);
            while(_loc5_ < _loc6_)
            {
               _formatExtensions[param2[_loc5_]] = param3;
               _loc5_++;
            }
         }
         _loc4_.dispose();
      }
      
      public static function listRegisteredFileFormats() : void
      {
         var _loc2_:String = null;
         var _loc1_:String = "ResourceManager registered file formats: ";
         for(_loc2_ in _formats)
         {
            _loc1_ += "\r\t" + _loc2_ + " (handler: " + _formats[_loc2_] + ")";
         }
      }
      
      private static function loadNextQueueInProgress() : void
      {
         var _loc1_:int = int(_managerQueue.length - 1);
         while(_loc1_ >= 0)
         {
            if(ResourceManager(_managerQueue[_loc1_]).resourcesQueued > 0 && Boolean(ResourceManager(_managerQueue[_loc1_])._loading))
            {
               ResourceManager(_managerQueue[_loc1_]).loadQueue();
               return;
            }
            _loc1_--;
         }
      }
      
      private static function setActiveQueue(param1:ResourceManager) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_managerQueue.length);
         while(_loc2_ < _loc3_)
         {
            if(_managerQueue[_loc2_] != param1)
            {
               ResourceManager(_managerQueue[_loc2_]).pauseQueueSilently();
            }
            _loc2_++;
         }
      }
      
      public function addResource(param1:*, param2:String, param3:String = null, param4:* = null) : Resource
      {
         var _loc5_:Resource = null;
         param2 = param2.toLowerCase();
         if(this._resourcesByURI[param2] != null && this._resourcesByURI[param2] != param1)
         {
            this.destroyResource(this._resourcesByURI[param2],true);
         }
         if(param1 is Resource)
         {
            _loc5_ = Resource(param1);
         }
         else
         {
            _loc5_ = new Resource(param2,param3);
            _loc5_.content = param1;
            _loc5_.data = param4;
         }
         this._resourcesByURI[param2] = _loc5_;
         if(this._resources.indexOf(_loc5_) == -1)
         {
            this._resources.push(_loc5_);
         }
         this.resourceLoadCompleted.dispatch(_loc5_);
         return _loc5_;
      }
      
      public function clearCache() : void
      {
         if(!this._cacheObject)
         {
            return;
         }
         this._cacheObject.clear();
      }
      
      public function dispose() : void
      {
         this.cacheFlushResponded.removeAll();
         this.resourceLoadCompleted.removeAll();
         this.resourceLoadFailed.removeAll();
         this.resourceLoadProgress.removeAll();
         this.resourceLoadStarted.removeAll();
         this.queueLoadCompleted.removeAll();
         this.queueLoadStarted.removeAll();
         this.queueLoadStopped.removeAll();
         this.unpackStarted.removeAll();
         this.unpackCompleted.removeAll();
         this.unpackProgress.removeAll();
         this.xmlListLoadCompleted.removeAll();
         this.xmlListLoadFailed.removeAll();
         this.xmlListAddedToQueue.removeAll();
         this.purge();
         _local[this._id] = null;
         loadNextQueueInProgress();
      }
      
      public function exists(param1:String) : Boolean
      {
         return this._resourcesByURI[param1.toLowerCase()] != null;
      }
      
      public function flushCache(param1:uint = 0) : Boolean
      {
         var _loc2_:Resource = null;
         var _loc3_:String = null;
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc6_:ByteArray = null;
         if(!this.cacheEnabled)
         {
            return false;
         }
         if(!this._cacheObject)
         {
            return false;
         }
         for each(_loc2_ in this._cacheQueue)
         {
            _loc4_ = _loc2_.uri + "::version";
            _loc5_ = this._cacheObject.data[_loc4_];
            if(_loc5_ != _loc2_.cacheVersion)
            {
               try
               {
                  _loc6_ = _loc2_.handler.getContentAsByteArray();
               }
               catch(e:Error)
               {
               }
               if(_loc6_)
               {
                  this._cacheObject.data[_loc2_.uri] = Base64.encodeByteArray(_loc6_);
                  this._cacheObject.data[_loc4_] = _loc2_.cacheVersion;
               }
            }
         }
         _loc3_ = this._cacheObject.flush(param1);
         return _loc3_ == "flushed" ? true : false;
      }
      
      public function getResource(param1:String) : Resource
      {
         return this._resourcesByURI[param1.toLowerCase()] as Resource;
      }
      
      public function get(param1:String) : *
      {
         var _loc2_:Resource = this._resourcesByURI[param1.toLowerCase()] as Resource;
         if(_loc2_ == null)
         {
            return _loc2_;
         }
         return _loc2_.content;
      }
      
      public function getResourcesOfType(param1:String) : Array
      {
         var _loc3_:Resource = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this._resources)
         {
            if(_loc3_.type == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getQueueList() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:int = int(this._queue.length);
         while(_loc2_ < _loc3_)
         {
            _loc1_.push(Resource(this._queue[_loc2_]).uri);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function load(param1:String, param2:Object = null) : Resource
      {
         var _loc5_:Resource = null;
         var _loc6_:int = 0;
         param1 = param1.toLowerCase();
         if(param1.indexOf("/data/g") != -1)
         {
         }
         if(!param2)
         {
            param2 = {};
         }
         if(!param2.uri)
         {
            param2.uri = param1;
         }
         if(this._resourcesByURI[param2.uri])
         {
            if(!(Boolean(param2) && param2.overwrite == true))
            {
               return null;
            }
            this.destroyResource(this._resourcesByURI[param2.uri],true);
         }
         if(!param2.type)
         {
            param2.type = this.getResourceHandlerFromURI(param1);
         }
         if(!param2.priority)
         {
            param2.priority = 0;
         }
         var _loc3_:Class = _formats[param2.type];
         if(!_loc3_)
         {
            throw new Error("No format handler with the type \'" + param2.type + "\' has been registered. Use ResourceManager.registerFileFormat() to register new file formats.");
         }
         var _loc4_:Resource = new Resource(param1,param2.type,new _loc3_());
         this._resourcesByURI[param2.uri] = _loc4_;
         _loc4_.cacheVersion = param2.cacheVersion;
         _loc4_.priority = param2.priority;
         _loc4_.context = param2.context || this._defaultLoaderContext;
         _loc4_.data = param2.data;
         _loc4_.onStart = param2.onStart;
         _loc4_.onStartParams = param2.onStartParams;
         _loc4_.onProgress = param2.onProgress;
         _loc4_.onProgressParams = param2.onProgressParams;
         _loc4_.onComplete = param2.onComplete;
         _loc4_.onCompleteParams = param2.onCompleteParams;
         _loc4_.onError = param2.onError;
         _loc4_.onErrorParams = param2.onErrorParams;
         if(this.cacheEnabled && _loc4_.cacheVersion != null && this.isCached(param2.id,_loc4_.cacheVersion))
         {
            _loc4_.fromByteArray = this.getCachedResource(param2.id,_loc4_.cacheVersion,true);
         }
         if(this._queue.length > 0)
         {
            _loc5_ = Resource(this._queue[0]);
            if(param2.priority > _loc5_.priority)
            {
               if(this._loadSequentially)
               {
                  this.pauseResource(_loc5_);
               }
               this._queue.unshift(_loc4_);
               if(this._loading && this._loadSequentially)
               {
                  this.loadResource(this._queue[0]);
               }
               return _loc4_;
            }
            while(_loc5_.priority >= param2.priority)
            {
               if(++_loc6_ == this._queue.length)
               {
                  break;
               }
               _loc5_ = Resource(this._queue[_loc6_]);
            }
            this._queue.splice(_loc6_,0,_loc4_);
         }
         else
         {
            this._queue.push(_loc4_);
         }
         if(this._loading)
         {
            if(this._queue.length == 1)
            {
               this.queueLoadStarted.dispatch();
               this.loadQueue();
            }
            else if(!this._loadSequentially)
            {
               this.loadResource(_loc4_);
            }
         }
         return _loc4_;
      }
      
      public function loadFromXML(param1:XML) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc2_:uint = uint(param1.res.length());
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.res[_loc3_];
            _loc5_ = _loc4_.toString();
            _loc6_ = {
               "uri":_loc5_,
               "data":_loc4_
            };
            if(_loc4_.hasOwnProperty("@context"))
            {
               switch(_loc4_.@context.toString())
               {
                  case "new":
                     _loc6_.context = new LoaderContext(false,new ApplicationDomain());
                     break;
                  case "this":
                     _loc6_.context = new LoaderContext(false,ApplicationDomain.currentDomain);
                     break;
                  case "parent":
                     _loc6_.context = new LoaderContext(false,ApplicationDomain.currentDomain.parentDomain);
               }
            }
            _loc6_.cacheVersion = _loc4_.hasOwnProperty("@cacheVersion") ? _loc4_.@cacheVersion.toString() : null;
            _loc6_.priority = _loc4_.hasOwnProperty("@priority") ? int(_loc4_.@priority.toString()) : 0;
            _loc6_.type = _loc4_.hasOwnProperty("@type") ? _loc4_.@type.toString() : null;
            if(Boolean(_loc4_.hasOwnProperty("@gz")) && _loc4_.@gz.toString() == "1")
            {
               _loc6_.type = TYPE_GZIP;
            }
            this.load(_loc5_,_loc6_);
            _loc3_++;
         }
         this.xmlListAddedToQueue.dispatch(param1);
      }
      
      public function isInQueue(param1:String) : Boolean
      {
         var _loc2_:Resource = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._queue.length);
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this._queue[_loc3_];
            if(_loc2_.uri == param1.toLowerCase())
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function loadQueue() : void
      {
         var _loc2_:Resource = null;
         if(this._loadingXML)
         {
            return;
         }
         var _loc1_:int = int(this._queue.length);
         if(!this._loading)
         {
            this._loading = true;
            if(_loc1_ > 0)
            {
               this.queueLoadStarted.dispatch();
            }
         }
         if(_loc1_ == 0)
         {
            loadNextQueueInProgress();
            return;
         }
         setActiveQueue(this);
         if(this._loadSequentially)
         {
            this.loadResource(this._queue[0]);
         }
         else
         {
            for each(_loc2_ in this._queue)
            {
               this.loadResource(_loc2_);
            }
         }
      }
      
      public function loadQueueFromXML(param1:String) : void
      {
         if(this._loading)
         {
            this.stopLoadingResourcesInQueue();
         }
         this._loadingXML = true;
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.addEventListener(Event.COMPLETE,this.onXMLComplete,false,0,true);
         _loc2_.addEventListener(IOErrorEvent.IO_ERROR,this.onXMLError,false,0,true);
         _loc2_.load(new URLRequest(this.processURI(param1)));
      }
      
      public function pauseQueue() : void
      {
         this._loading = false;
         this.stopLoadingResourcesInQueue();
         this.queueLoadStopped.dispatch();
         loadNextQueueInProgress();
      }
      
      public function prioritize(param1:String, param2:Number = NaN, param3:Boolean = true) : void
      {
         var _loc4_:Resource = this.getResourceInQueue(param1);
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:int = int(this._queue.indexOf(_loc4_));
         var _loc6_:int = 0;
         if(isNaN(param2))
         {
            if(_loc5_ == 0)
            {
               return;
            }
            param2 = Resource(this._queue[0]).priority + 1;
         }
         if(_loc4_.priority == param2)
         {
            return;
         }
         var _loc7_:Resource = this._queue[0];
         while(_loc7_.priority > param2)
         {
            if(++_loc6_ == this._queue.length)
            {
               break;
            }
            _loc7_ = Resource(this._queue[_loc6_]);
         }
         _loc4_.priority = param2;
         if(_loc5_ == _loc6_)
         {
            return;
         }
         if(this._loadSequentially)
         {
            if(param3)
            {
               this.stopLoadingResourcesInQueue();
               this._queue.splice(_loc5_,1);
               this._queue.splice(_loc6_,0,_loc4_);
               if(this._loading)
               {
                  this.loadQueue();
               }
            }
            else if(_loc6_ == 0)
            {
               this._queue.splice(1,0,_loc4_);
            }
            else
            {
               this._queue.splice(_loc6_,0,_loc4_);
            }
         }
      }
      
      public function purge(param1:String = null) : void
      {
         var _loc2_:Resource = null;
         var _loc3_:Boolean = false;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1 != null)
         {
            param1 = param1.toLowerCase();
            _loc2_ = this._resourcesByURI[param1];
            if(_loc2_ == null)
            {
               return;
            }
            this.destroyResource(_loc2_);
         }
         else
         {
            _loc3_ = this._loading;
            this._loading = false;
            _loc4_ = this._resources.concat(this._queue);
            _loc5_ = 0;
            _loc6_ = int(_loc4_.length);
            while(_loc5_ < _loc6_)
            {
               _loc2_ = _loc4_[_loc5_];
               this.destroyResource(_loc2_,false);
               _loc5_++;
            }
            this._queue = [];
            this._resources = [];
            this._resourcesByURI = new Dictionary(true);
            this._loading = _loc3_;
            loadNextQueueInProgress();
         }
      }
      
      public function purgeAllOfType(param1:String) : void
      {
         var _loc3_:Resource = null;
         var _loc2_:Array = this._resources.concat(this._queue);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.type == param1)
            {
               this.destroyResource(_loc3_,true);
            }
         }
      }
      
      public function purgeQueue() : void
      {
         var _loc1_:int = int(this._queue.length - 1);
         while(_loc1_ >= 0)
         {
            this.removeFromQueue(Resource(this._queue[_loc1_]).uri);
            _loc1_--;
         }
      }
      
      public function removeFromQueue(param1:String) : void
      {
         var _loc2_:Resource = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._queue.length);
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this._queue[_loc3_];
            if(_loc2_.uri == param1)
            {
               this.destroyResource(_loc2_);
               break;
            }
            _loc3_++;
         }
         if(Boolean(this._loadingResource) && this._loadingResource.uri == param1)
         {
            this._loadingResource = null;
         }
         if(_loc3_ == 0 && this._loading)
         {
            this.loadQueue();
         }
      }
      
      public function traceQueue() : void
      {
         var _loc1_:String = "";
         var _loc2_:int = 0;
         var _loc3_:int = int(this._queue.length);
         while(_loc2_ < _loc3_)
         {
            _loc1_ += Resource(this._queue[_loc2_]) + (_loc2_ < _loc3_ - 1 ? "\r" : "");
            _loc2_++;
         }
      }
      
      public function purgePackageFiles(param1:String) : void
      {
         var _loc3_:String = null;
         param1 = param1.toLowerCase();
         var _loc2_:Vector.<String> = this._packageFiles[param1];
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_ != null)
            {
               this.purge(_loc3_);
            }
            delete this._packageFiles[param1];
         }
      }
      
      public function unpack(param1:Array, param2:Boolean = false) : Dictionary
      {
         var _loc6_:String = null;
         this._unpacker = new ResourceUnpacker();
         this._unpacker.unpackCompleted.addOnce(this.onunpackCompleted);
         this._unpacker.unpackProgress.add(this.onUnpackProgress);
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            this._unpacker.addPackage(param1[_loc3_]);
            _loc3_++;
         }
         this.unpackStarted.dispatch();
         var _loc5_:Dictionary = this._unpacker.unpack(this,param2);
         for(_loc6_ in _loc5_)
         {
            this._packageFiles[_loc6_] = _loc5_[_loc6_];
         }
         return _loc5_;
      }
      
      private function destroyResource(param1:Resource, param2:Boolean = true) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         if(this._loadingResource == param1)
         {
            this.pauseQueueSilently();
         }
         if(param2)
         {
            _loc3_ = param1.uri.toLowerCase();
            this._resourcesByURI[_loc3_] = null;
            delete this._resourcesByURI[_loc3_];
            _loc4_ = int(this._resources.indexOf(param1));
            if(_loc4_ > -1)
            {
               this._resources.splice(_loc4_,1);
            }
            _loc4_ = int(this._queue.indexOf(param1));
            if(_loc4_ > -1)
            {
               this._queue.splice(_loc4_,1);
            }
         }
         if(this._loading && this._loadSequentially && this._queue.length > 0)
         {
            this.loadResource(this._queue[0]);
         }
         param1.dispose();
      }
      
      private function getCachedResource(param1:String, param2:String, param3:Boolean = false) : ByteArray
      {
         if(!this._cacheObject)
         {
            return null;
         }
         var _loc4_:* = param1 + "::version";
         var _loc5_:String = this._cacheObject.data[_loc4_];
         if(_loc5_ != param2)
         {
            if(param3)
            {
               this._cacheObject.data[param1] = null;
               this._cacheObject.data[_loc4_] = null;
               delete this._cacheObject.data[param1];
               delete this._cacheObject.data[_loc4_];
            }
         }
         var _loc6_:String = this._cacheObject.data[param1];
         if(!_loc6_)
         {
            return null;
         }
         return Base64.decodeToByteArray(_loc6_);
      }
      
      private function getResourceInQueue(param1:String) : Resource
      {
         var _loc2_:Resource = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._queue.length);
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this._queue[_loc3_];
            if(_loc2_.uri == param1)
            {
               return _loc2_;
            }
            _loc3_++;
         }
         return null;
      }
      
      private function getResourceInQueueByHandler(param1:IFormatHandler) : Resource
      {
         var _loc2_:Resource = null;
         for each(_loc2_ in this._queue)
         {
            if(_loc2_.handler === param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function getResourceHandlerFromURI(param1:String) : String
      {
         var _loc2_:String = param1.substr(param1.lastIndexOf(".") + 1);
         var _loc3_:String = _formatExtensions[_loc2_];
         return _loc3_ ? _loc3_ : "bin";
      }
      
      private function isCached(param1:String, param2:String) : Boolean
      {
         if(!this._cacheObject)
         {
            return false;
         }
         var _loc3_:String = this._cacheObject.data[param1 + "::version"];
         if(_loc3_ != param2)
         {
            return false;
         }
         var _loc4_:String = this._cacheObject.data[param1];
         if(_loc4_ == null)
         {
            return false;
         }
         return true;
      }
      
      private function loadResource(param1:Resource) : void
      {
         var _loc2_:String = null;
         if(param1.loading)
         {
            return;
         }
         param1.handler.loadCompleted.addOnce(this.onResourceLoadCompleted);
         param1.handler.loadFailed.addOnce(this.onResourceLoadFailed);
         param1.handler.loadProgress.add(this.onResourceLoadProgress);
         this._loadingResource = param1;
         this.resourceLoadStarted.dispatch(param1);
         if(param1.onStart != null)
         {
            param1.onStart.apply(null,param1.onStartParams);
         }
         if(param1.fromByteArray)
         {
            param1.handler.loadFromByteArray(param1.fromByteArray,param1.context);
         }
         else
         {
            _loc2_ = this.processURI(param1.uri,param1.type == TYPE_GZIP);
            param1.realURL = _loc2_;
            param1.handler.load(_loc2_,param1.context);
         }
      }
      
      private function pauseResource(param1:Resource) : void
      {
         if(this._loadingResource == param1)
         {
            this._loadingResource = null;
         }
         if(!param1.handler)
         {
            return;
         }
         param1.handler.loadCompleted.remove(this.onResourceLoadCompleted);
         param1.handler.loadFailed.remove(this.onResourceLoadFailed);
         param1.handler.loadProgress.remove(this.onResourceLoadProgress);
         param1.handler.pauseLoad();
      }
      
      private function pauseQueueSilently() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this._queue)
         {
            this.pauseResource(_loc1_);
         }
      }
      
      private function processURI(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:String = "";
         if(this.queryString)
         {
            if(this.queryString.substr(0,1) == "?")
            {
               _loc3_ = this.queryString.substr(1);
            }
            else
            {
               _loc3_ = this.queryString;
            }
            _loc3_ = (param1.indexOf("?") > -1 ? "&" : "?") + _loc3_;
         }
         if(param1.substr(0,1) == "/")
         {
            return param1 + _loc3_;
         }
         if(param1.indexOf("http://") == 0)
         {
            return param1 + _loc3_;
         }
         if(param1.indexOf("https://") == 0)
         {
            return param1 + _loc3_;
         }
         param1 = (this._baseURL ? this._baseURL : "") + param1 + _loc3_;
         if(param2)
         {
            param1 += ".gz";
         }
         if(this.uriProcessor != null)
         {
            param1 = this.uriProcessor(param1);
         }
         return param1;
      }
      
      private function stopLoadingResourcesInQueue() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this._queue)
         {
            this.pauseResource(_loc1_);
         }
      }
      
      private function onResourceLoadCompleted(param1:IFormatHandler) : void
      {
         var _loc2_:Resource = this.getResourceInQueueByHandler(param1);
         var _loc3_:int = int(this._queue.indexOf(_loc2_));
         this._queue.splice(_loc3_,1);
         this._resources.push(_loc2_);
         this._resourcesByURI[_loc2_.uri.toLowerCase()] = _loc2_;
         if(this._loadingResource == _loc2_)
         {
            this._loadingResource = null;
         }
         if(_loc2_.cacheVersion != null && this._cacheQueue.indexOf(_loc2_) == -1 && !this.isCached(_loc2_.uri,_loc2_.cacheVersion))
         {
            this._cacheQueue.push(_loc2_);
         }
         _loc2_.handler.loadCompleted.remove(this.onResourceLoadCompleted);
         _loc2_.handler.loadFailed.remove(this.onResourceLoadFailed);
         _loc2_.handler.loadProgress.remove(this.onResourceLoadProgress);
         this.resourceLoadCompleted.dispatch(_loc2_);
         if(_loc2_.onComplete != null)
         {
            _loc2_.onComplete.apply(null,_loc2_.onCompleteParams);
         }
         if(this._queue.length == 0)
         {
            loadNextQueueInProgress();
            this.queueLoadCompleted.dispatch();
         }
         else if(this._loading && this._loadSequentially)
         {
            this.loadResource(this._queue[0]);
         }
      }
      
      private function onResourceLoadFailed(param1:IFormatHandler, param2:Object) : void
      {
         var _loc7_:Resource = null;
         var _loc3_:Resource = this.getResourceInQueueByHandler(param1);
         var _loc4_:Boolean = this._loading;
         var _loc5_:Function = _loc3_.onError;
         var _loc6_:Array = _loc3_.onErrorParams;
         this.resourceLoadFailed.dispatch(_loc3_,param2);
         if(_loc5_ != null)
         {
            _loc5_.apply(null,_loc6_);
         }
         this._loading = false;
         this.removeFromQueue(_loc3_.uri);
         this._loading = _loc4_;
         if(this._queue.length > 0 && this._loading)
         {
            if(this._loadSequentially)
            {
               this.loadResource(this._queue[0]);
            }
            else
            {
               for each(_loc7_ in this._queue)
               {
                  this.loadResource(_loc7_);
               }
            }
         }
      }
      
      private function onResourceLoadProgress(param1:IFormatHandler, param2:int, param3:int) : void
      {
         var _loc4_:Resource = this.getResourceInQueueByHandler(param1);
         if(!_loc4_)
         {
            return;
         }
         if(_loc4_.bytesTotal > 0)
         {
            this.resourceLoadProgress.dispatch(_loc4_);
         }
         if(_loc4_.onProgress != null)
         {
            _loc4_.onProgress.apply(null,_loc4_.onProgressParams);
         }
      }
      
      private function onSharedObjectFlushStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "SharedObject.Flush.Success":
               this.cacheEnabled = true;
               break;
            case "SharedObject.Flush.Failed":
               this.cacheEnabled = false;
         }
         this.cacheFlushResponded.dispatch(this.cacheEnabled);
      }
      
      private function onUnpackProgress(param1:Resource, param2:uint, param3:uint) : void
      {
         this.unpackProgress.dispatch(param1,param2,param3);
      }
      
      private function onunpackCompleted() : void
      {
         this._unpacker.unpackProgress.remove(this.onUnpackProgress);
         this._unpacker.dispose();
         this.unpackCompleted.dispatch();
      }
      
      private function onXMLComplete(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.target.data);
         this._loadingXML = false;
         this.loadFromXML(_loc2_);
         this.xmlListLoadCompleted.dispatch(_loc2_);
         if(this._loading)
         {
            this.loadQueue();
         }
      }
      
      private function onXMLError(param1:IOErrorEvent) : void
      {
         this._loadingXML = false;
         this.xmlListLoadFailed.dispatch();
      }
      
      public function get baseURL() : String
      {
         return this._baseURL;
      }
      
      public function set baseURL(param1:String) : void
      {
         this._baseURL = param1;
         if(Boolean(this._baseURL) && this._baseURL.substr(this._baseURL.length - 1) != "/")
         {
            this._baseURL += "/";
         }
      }
      
      public function get cacheName() : String
      {
         return this._cacheName;
      }
      
      public function set cacheName(param1:String) : void
      {
         if(param1 == this._cacheName)
         {
            return;
         }
         if(this._cacheObject)
         {
            this._cacheObject.removeEventListener(NetStatusEvent.NET_STATUS,this.onSharedObjectFlushStatus);
         }
         this._cacheName = param1;
         this._cacheObject = SharedObject.getLocal(this._cacheName);
         this._cacheObject.addEventListener(NetStatusEvent.NET_STATUS,this.onSharedObjectFlushStatus,false,0,true);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get currentLoadingResource() : Resource
      {
         return this._loadSequentially ? this._loadingResource : null;
      }
      
      public function get resourcesTotal() : uint
      {
         return this._queue.length + this._resources.length;
      }
      
      public function get resourcesLoaded() : uint
      {
         return this._resources.length;
      }
      
      public function get resourcesQueued() : uint
      {
         return this._queue.length;
      }
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      public function get loadSequentially() : Boolean
      {
         return this._loadSequentially;
      }
      
      public function set loadSequentially(param1:Boolean) : void
      {
         var _loc2_:Resource = null;
         this._loadSequentially = param1;
         if(!this._loadSequentially)
         {
            for each(_loc2_ in this._queue)
            {
               this.loadResource(_loc2_);
            }
         }
         else
         {
            for each(_loc2_ in this._queue)
            {
               this.pauseResource(_loc2_);
            }
            this.loadQueue();
         }
      }
      
      public function get materials() : MaterialLibrary
      {
         return this._materials;
      }
      
      public function get animations() : AnimationLibrary
      {
         return this._animations;
      }
      
      public function get defaultLoaderContext() : LoaderContext
      {
         return this._defaultLoaderContext;
      }
      
      public function set defaultLoaderContext(param1:LoaderContext) : void
      {
         this._defaultLoaderContext = param1;
      }
   }
}

class ResourceManagerSingletonEnforcer
{
   
   public function ResourceManagerSingletonEnforcer()
   {
      super();
   }
}
