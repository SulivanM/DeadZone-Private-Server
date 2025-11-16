package thelaststand.common.resources
{
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import org.as3commons.zip.Zip;
   import org.as3commons.zip.ZipFile;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.network.Network;
   import thelaststand.common.resources.formats.ColladaA3DHandler;
   import thelaststand.common.resources.formats.IFormatHandler;
   import thelaststand.common.resources.formats.ZIPHandler;
   import thelaststand.engine.animation.AnimationTable;
   
   public class AssetLoader
   {
      
      private var _bytesLoaded:int;
      
      private var _network:Network;
      
      private var _resources:ResourceManager;
      
      private var _resourcesToLoad:Array;
      
      private var _resourcesLoaded:Array;
      
      private var _disposableResources:Array;
      
      public var loadingStarted:Signal;
      
      public var loadingCompleted:Signal;
      
      public var loadingProgress:Signal;
      
      public function AssetLoader()
      {
         super();
         this._resources = ResourceManager.getInstance();
         this._network = Network.getInstance();
         this._resourcesToLoad = [];
         this._resourcesLoaded = [];
         this._disposableResources = [];
         this.loadingStarted = new Signal();
         this.loadingCompleted = new Signal();
         this.loadingProgress = new Signal();
      }
      
      public function clear(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         this._resources.resourceLoadCompleted.remove(this.onResourceLoadCompleted);
         this._resources.resourceLoadFailed.remove(this.onResourceLoadFailed);
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < this._resourcesToLoad.length)
            {
               _loc3_ = this._resourcesToLoad[_loc2_];
               if(_loc3_ != null)
               {
                  if(this._resources.isInQueue(_loc3_))
                  {
                     this._resources.purge(_loc3_);
                  }
               }
               _loc2_++;
            }
         }
         this._bytesLoaded = 0;
         this._resourcesLoaded = [];
         this._resourcesToLoad = [];
         this._disposableResources = [];
      }
      
      public function dispose(param1:Boolean = false) : void
      {
         this.clear(param1);
         this.loadingCompleted.removeAll();
         this.loadingStarted.removeAll();
         this.loadingProgress.removeAll();
         this._network = null;
         this._resources = null;
         this._resourcesLoaded = null;
         this._resourcesToLoad = null;
      }
      
      public function loadPlayerDataAssets() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:PlayerData = this._network.playerData;
         var _loc5_:Array = [];
         _loc1_ = 0;
         _loc2_ = _loc4_.compound.survivors.length;
         while(_loc1_ < _loc2_)
         {
            _loc5_ = _loc5_.concat(_loc4_.compound.survivors.getSurvivor(_loc1_).getResourceURIs());
            _loc1_++;
         }
         this.loadAssets(_loc5_);
      }
      
      public function loadAsset(param1:String) : Boolean
      {
         var _loc3_:Resource = null;
         param1 = param1.toLowerCase();
         var _loc2_:Boolean = this._resources.exists(param1);
         if(!_loc2_ || this._resources.isInQueue(param1))
         {
            if(this._resourcesToLoad.indexOf(param1) == -1)
            {
               this._resourcesToLoad.push(param1);
            }
            if(!_loc2_)
            {
               this.addResourceToQueue(param1);
            }
         }
         else
         {
            _loc3_ = this._resources.getResource(param1);
            this.loadSubResources(_loc3_);
         }
         if(this._resourcesToLoad.length == 0)
         {
            this.loadingCompleted.dispatch();
            return false;
         }
         this._resources.resourceLoadCompleted.add(this.onResourceLoadCompleted);
         this._resources.resourceLoadFailed.add(this.onResourceLoadFailed);
         this.loadingStarted.dispatch();
         return true;
      }
      
      public function loadAssets(param1:Array) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Resource = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = String(param1[_loc2_]).toLowerCase();
            _loc4_ = this._resources.exists(_loc3_);
            if(!_loc4_ || this._resources.isInQueue(_loc3_))
            {
               if(this._resourcesToLoad.indexOf(_loc3_) == -1)
               {
                  this._resourcesToLoad.push(_loc3_);
                  this.addResourceToQueue(_loc3_);
               }
            }
            else
            {
               _loc5_ = this._resources.getResource(_loc3_);
               if(_loc5_ != null)
               {
                  this.loadSubResources(_loc5_);
               }
            }
            _loc2_++;
         }
         if(this._resourcesToLoad.length == 0)
         {
            this.loadingCompleted.dispatch();
            return false;
         }
         this._resources.resourceLoadCompleted.add(this.onResourceLoadCompleted);
         this._resources.resourceLoadFailed.add(this.onResourceLoadFailed);
         this.loadingStarted.dispatch();
         return true;
      }
      
      public function purgeLoadedAssets() : void
      {
         var _loc2_:String = null;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this._disposableResources.length)
         {
            _loc2_ = this._disposableResources[_loc1_];
            if(_loc2_ != null)
            {
               Audio.sound.removeSound(_loc2_);
               this._resources.materials.purge(_loc2_);
               this._resources.animations.purge(_loc2_);
               this._resources.purge(_loc2_);
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._resourcesToLoad.length)
         {
            _loc2_ = this._resourcesToLoad[_loc1_];
            if(_loc2_ != null)
            {
               if(this._resources.isInQueue(_loc2_))
               {
                  this._resources.purge(_loc2_);
               }
            }
            _loc1_++;
         }
         this._disposableResources = [];
         this._resourcesLoaded = [];
         this._resourcesToLoad = [];
         this._bytesLoaded = 0;
      }
      
      private function loadSubResources(param1:Resource) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.type == ColladaA3DHandler.TYPE)
         {
            this.loadTexturesFromParser(ParserCollada(param1.content));
            return;
         }
         if(param1.type == ZIPHandler.TYPE)
         {
            this.unpack(Zip(param1.content));
            this._resources.purge(param1.uri);
            return;
         }
         if(param1.uri.substr(param1.uri.lastIndexOf(".") + 1) == "anim")
         {
            this.loadAnimationsFromAnimTable(param1.content as String);
            return;
         }
      }
      
      private function unpack(param1:Zip) : void
      {
         var len:int = 0;
         var i:int = 0;
         var file:ZipFile = null;
         var handler:IFormatHandler = null;
         var res:Resource = null;
         var zip:Zip = param1;
         try
         {
            len = int(zip.getFileCount());
            i = 0;
            while(i < len)
            {
               file = zip.getFileAt(i);
               if(!this._resources.exists(file.filename))
               {
                  handler = ResourceManager.getResourceHandlerFromURI(file.filename);
                  handler.loadFromByteArray(file.content);
                  res = new Resource(file.filename,handler.id,handler);
                  res.content = handler.getContent();
                  this._resources.addResource(res,file.filename,handler.id);
                  this._resourcesLoaded.push(file.filename);
                  this._disposableResources.push(file.filename);
               }
               i++;
            }
         }
         catch(error:Error)
         {
         }
      }
      
      private function loadTexturesFromParser(param1:ParserCollada) : void
      {
         var _loc2_:ParserMaterial = null;
         var _loc3_:Object = null;
         var _loc4_:ExternalTextureResource = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         if(param1 == null)
         {
            return;
         }
         for each(_loc2_ in param1.materials)
         {
            for each(_loc3_ in _loc2_.textures)
            {
               _loc4_ = _loc3_ as ExternalTextureResource;
               if(_loc4_ != null)
               {
                  _loc5_ = MaterialLibrary.formatColladaURL(_loc4_.url).toLowerCase();
                  _loc6_ = this._resources.exists(_loc5_);
                  if(!_loc6_ || this._resources.isInQueue(_loc5_))
                  {
                     if(this._resourcesToLoad.indexOf(_loc5_) == -1)
                     {
                        this._resourcesToLoad.push(_loc5_);
                     }
                     if(!_loc6_)
                     {
                        this.addResourceToQueue(_loc5_);
                     }
                  }
               }
            }
         }
      }
      
      private function loadAnimationsFromAnimTable(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Array = AnimationTable.getAnimURIsFromTable(param1);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_].toLowerCase();
            _loc5_ = this._resources.exists(_loc4_);
            if(!_loc5_ || this._resources.isInQueue(_loc4_))
            {
               if(this._resourcesToLoad.indexOf(_loc4_) == -1)
               {
                  this._resourcesToLoad.push(_loc4_);
               }
               if(!_loc5_)
               {
                  this.addResourceToQueue(_loc4_);
               }
            }
            _loc3_++;
         }
      }
      
      private function addResourceToQueue(param1:String) : void
      {
         var _loc2_:String = null;
         _loc2_ = param1.substr(param1.lastIndexOf(".") + 1);
         if(_loc2_ == "dae" || _loc2_ == "daeanim" || _loc2_ == "xml")
         {
            this._resources.load(param1,{"type":ResourceManager.TYPE_GZIP});
         }
         else
         {
            this._resources.load(param1,{"overwrite":false});
         }
         this._disposableResources.push(param1);
      }
      
      private function onResourcesLoadComplete() : void
      {
         this._resources.resourceLoadCompleted.remove(this.onResourceLoadCompleted);
         this._resources.resourceLoadFailed.remove(this.onResourceLoadFailed);
         this.loadingCompleted.dispatch();
      }
      
      private function onResourceLoadFailed(param1:Resource, param2:Object) : void
      {
         var _loc3_:int = int(this._resourcesToLoad.indexOf(param1.uri.toLowerCase()));
         if(_loc3_ > -1)
         {
            this._resourcesToLoad.splice(_loc3_,1);
            if(this._resourcesToLoad.length == 0)
            {
               this.onResourcesLoadComplete();
            }
         }
      }
      
      private function onResourceLoadCompleted(param1:Resource) : void
      {
         if(param1 == null || param1.disposed)
         {
            return;
         }
         var _loc2_:int = int(this._resourcesToLoad.indexOf(param1.uri.toLowerCase()));
         if(_loc2_ == -1)
         {
            return;
         }
         this._bytesLoaded += param1.bytesTotal;
         this._resourcesToLoad.splice(_loc2_,1);
         this._resourcesLoaded.push(param1.uri);
         this.loadSubResources(param1);
         this.loadingProgress.dispatch();
         if(this._resourcesToLoad.length == 0)
         {
            this.onResourcesLoadComplete();
         }
      }
      
      public function get resourcesLoaded() : Array
      {
         return this._resourcesLoaded;
      }
      
      public function get progress() : Number
      {
         return this._resourcesLoaded.length / this._resourcesToLoad.length;
      }
   }
}

