package thelaststand.common.resources
{
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.formats.ColladaA3DAnimHandler;
   import thelaststand.common.resources.formats.ColladaA3DHandler;
   import thelaststand.common.resources.formats.GenericHandler;
   import thelaststand.common.resources.formats.ZIPHandler;
   
   public class ResourceLoaderProxy
   {
      
      private var _bytesLoaded:int;
      
      private var _manager:ResourceManager;
      
      private var _settings:Settings;
      
      public var fontLoaded:Signal;
      
      public function ResourceLoaderProxy(param1:ResourceManager, param2:String = "settings-data")
      {
         super();
         ResourceManager.registerFileFormat(ZIPHandler);
         ResourceManager.registerFileFormat(ColladaA3DHandler);
         ResourceManager.registerFileFormat(ColladaA3DAnimHandler);
         ResourceManager.registerFileFormat(GenericHandler,["anim"],"anim");
         this._settings = Settings.getInstance();
         this._settings.sharedObjectName = param2;
         var _loc3_:ApplicationDomain = ApplicationDomain.currentDomain;
         var _loc4_:SecurityDomain = Security.sandboxType == Security.REMOTE ? SecurityDomain.currentDomain : null;
         this._manager = param1;
         this._manager.defaultLoaderContext = new LoaderContext(false,_loc3_,_loc4_);
         this._manager.pauseQueue();
         this._manager.resourceLoadCompleted.add(this.onResourceLoadComplete);
         this._manager.queueLoadCompleted.addOnce(this.onResourceQueueComplete);
         this.fontLoaded = new Signal();
         this._manager.loadSequentially = false;
      }
      
      public function dispose() : void
      {
         this._manager.resourceLoadCompleted.remove(this.onResourceLoadComplete);
         this._manager.queueLoadCompleted.remove(this.onResourceQueueComplete);
         this._manager = null;
         this._settings = null;
      }
      
      public function loadAndUnpack(param1:String) : void
      {
         var resourceFile:String = param1;
         this._manager.load("lang/fonts/en.swf",{
            "priority":1,
            "onComplete":function():void
            {
               fontLoaded.dispatch();
            }
         });
         this._manager.loadQueueFromXML(resourceFile);
         this._manager.xmlListAddedToQueue.addOnce(function(param1:XML):void
         {
            _manager.load("languages.xml",{"priority":1});
            _manager.load("lang/" + _settings.language + ".xml",{
               "type":ResourceManager.TYPE_GZIP,
               "priority":1
            });
            _manager.load("lang/fonts/" + _settings.language + ".swf",{"priority":1});
            _manager.loadQueue();
         });
      }
      
      private function onResourceQueueComplete() : void
      {
         Language.getInstance().init();
         Language.getInstance().setLanguage(this._settings.language);
         this._manager.queueLoadCompleted.remove(this.onResourceQueueComplete);
         this._manager.unpack(this._manager.getResourcesOfType("zip"));
      }
      
      private function onResourceLoadComplete(param1:Resource) : void
      {
         var _loc2_:ParserCollada = null;
         var _loc3_:ParserMaterial = null;
         var _loc4_:Object = null;
         var _loc5_:ExternalTextureResource = null;
         var _loc6_:String = null;
         this._bytesLoaded += param1.bytesTotal;
         switch(param1.type)
         {
            case ColladaA3DHandler.TYPE:
               _loc2_ = param1.content as ParserCollada;
               for each(_loc3_ in _loc2_.materials)
               {
                  for each(_loc4_ in _loc3_.textures)
                  {
                     _loc5_ = _loc4_ as ExternalTextureResource;
                     if(_loc5_ != null)
                     {
                        _loc6_ = MaterialLibrary.formatColladaURL(_loc5_.url);
                        if(!this._manager.exists(_loc6_))
                        {
                           this._manager.load(_loc6_);
                        }
                     }
                  }
               }
               return;
            default:
               return;
         }
      }
   }
}

