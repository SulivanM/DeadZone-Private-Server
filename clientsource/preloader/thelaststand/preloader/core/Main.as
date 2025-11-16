package thelaststand.preloader.core
{
   import com.adobe.images.PNGEncoder;
   import com.dynamicflash.util.Base64;
   import com.greensock.TweenNano;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.external.ExternalInterface;
   import flash.filters.BlurFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import playerio.PlayerIO;
   import thelaststand.app.core.SharedResources;
   import thelaststand.app.display.NoiseOverlay;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.preloader.display.ProgressBar;
   import thelaststand.preloader.display.StatusText;
   
   public class Main extends Sprite
   {
      
      private static var stage:Stage;
      
      private const CORE_LOAD_PERCENTAGE:Number = 0.3;
      
      private var _loader:Loader;
      
      private var _bgLoader:Loader;
      
      private var _connector:PlayerIOConnector;
      
      private var _startTime:Number = 0;
      
      private var _localAssets:Boolean;
      
      private var _rootPath:String;
      
      private var _coreFile:String;
      
      private var _useSSL:Boolean = false;
      
      private var bmp_background:Bitmap;
      
      private var bmp_logo:Bitmap;
      
      private var mc_progress:ProgressBar;
      
      private var mc_spinner:BusySpinnerGraphic;
      
      private var mc_noise:NoiseOverlay;
      
      private var txt_status:StatusText;
      
      public function Main()
      {
         super();
         stage.tabChildren = false;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.tabChildren = false;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      private function loadCore() : void
      {
         var _loc4_:Array = null;
         var _loc1_:String = this._localAssets ? this._coreFile : PlayerIO.gameFS("dev-the-last-stand-iret8ormbeshajyk6woewg").getUrl(this._rootPath + this._coreFile,this._useSSL);
         Security.allowDomain(_loc1_);
         var _loc2_:URLRequest = new URLRequest(_loc1_);
         this.txt_status.text = "LOADING ASSETS";
         this.txt_status.x = int(this.mc_spinner.x - this.mc_spinner.width * 0.5 - this.txt_status.width - 6);
         var _loc3_:SecurityDomain = Security.sandboxType == Security.REMOTE ? SecurityDomain.currentDomain : null;
         this._loader.load(_loc2_,new LoaderContext(false,ApplicationDomain.currentDomain,_loc3_));
         _loc4_ = PlayerIO.gameFS("dev-the-last-stand-iret8ormbeshajyk6woewg").getUrl(this._rootPath + "preloader.swf",this._useSSL).match(/(^.*\/\/)(.*?\/.*?)\//i);
         if(_loc4_.length == 0 || loaderInfo.url.indexOf(_loc4_[2]) == -1)
         {
            return;
         }
      }
      
      private function init() : void
      {
         Main.stage = stage;
         if(ExternalInterface.available)
         {
            Security.allowDomain("*");
            ExternalInterface.addCallback("getScreenshot",this.JS_getScreenshot);
         }
         this._connector = PlayerIOConnector.getInstance();
         this._connector.addEventListener(Event.COMPLETE,this.onPlayerIOConnected,false,0,true);
         this._connector.addEventListener(ErrorEvent.ERROR,this.onPlayerIOConnectError,false,0,true);
         PlayerIO.useSecureApiRequests = this._useSSL;
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onCoreLoadComplete,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onCoreLoadProgress,false,0,true);
         this._bgLoader = new Loader();
         this._bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBackgroundLoadComplete,false,0,true);
         this._bgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onBackgroundLoadFailed,false,0,true);
         var _loc1_:String = "data/images/loader/loaderbg.jpg";
         var _loc2_:String = this._localAssets ? _loc1_ : PlayerIO.gameFS("dev-the-last-stand-iret8ormbeshajyk6woewg").getUrl(this._rootPath + _loc1_,this._useSSL);
         this._bgLoader.load(new URLRequest(_loc2_),new LoaderContext(true));
      }
      
      private function initStage() : void
      {
         var backgroundBmd:BitmapData = null;
         stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         try
         {
            backgroundBmd = Bitmap(this._bgLoader.content).bitmapData;
         }
         catch(error:Error)
         {
            backgroundBmd = new BitmapData(960,600,false,0);
         }
         SharedResources.loadingBitmapInstance = backgroundBmd;
         this.bmp_background = new Bitmap(backgroundBmd);
         this.bmp_background.alpha = 0;
         addChild(this.bmp_background);
         if(stage.loaderInfo.parameters.service == "kong")
         {
            SharedResources.logoBitmapInstance = new BmpLogo();
            this.bmp_logo = new Bitmap(SharedResources.logoBitmapInstance);
            addChild(this.bmp_logo);
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("onPreloaderReady");
         }
         this.mc_noise = new NoiseOverlay(this.bmp_background.width,this.bmp_background.height,8,16);
         this.mc_noise.x = this.bmp_background.x;
         this.mc_noise.y = this.bmp_background.y;
         this.mc_noise.blendMode = "multiply";
         this.mc_noise.alpha = 0.2;
         addChild(this.mc_noise);
         this.mc_progress = new ProgressBar();
         addChild(this.mc_progress);
         this.mc_spinner = new BusySpinnerGraphic();
         this.mc_spinner.width = 20;
         this.mc_spinner.scaleY = this.mc_spinner.scaleX;
         addChild(this.mc_spinner);
         this.txt_status = new StatusText();
         this.txt_status.text = "CONNECTING";
         addChild(this.txt_status);
         addEventListener(Event.EXIT_FRAME,this.onEnterFrame,false,0,true);
         this.onStageResize(null);
         TweenNano.to(this.bmp_background,4,{"alpha":1});
         TweenNano.delayedCall(1,this._connector.connect,[stage]);
      }
      
      private function initCore() : void
      {
         var self:Main = null;
         var core:Sprite = Sprite(this._loader.content);
         stage.addChildAt(core,0);
         self = this;
         TweenNano.delayedCall(0.5,function():void
         {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onCoreLoadComplete);
            _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onCoreLoadProgress);
            _loader = null;
            mc_progress.dispose();
            mc_progress = null;
            txt_status.dispose();
            txt_status = null;
            bmp_background.bitmapData = null;
            bmp_background = null;
            mc_noise.dispose();
            mc_noise = null;
            stage.removeChild(self);
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._localAssets = loaderInfo.parameters.local == "1";
         this._rootPath = stage.loaderInfo.parameters.path || "";
         this._coreFile = stage.loaderInfo.parameters.core || "core.swf";
         this._useSSL = stage.loaderInfo.parameters.useSSL == "1";
         this.init();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(Event.RESIZE,this.onStageResize);
         stage.removeEventListener(Event.EXIT_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this.mc_spinner.rotation += 2;
      }
      
      private function onStageResize(param1:Event) : void
      {
         if(this.bmp_background == null)
         {
            return;
         }
         var _loc2_:int = stage.stageHeight - 200;
         this.bmp_background.x = int((stage.stageWidth - this.bmp_background.width) * 0.5);
         this.bmp_background.y = int((_loc2_ - this.bmp_background.height) * 0.5);
         if(this.bmp_logo != null)
         {
            this.bmp_logo.x = this.bmp_background.x;
            this.bmp_logo.y = this.bmp_background.y;
         }
         if(this.mc_noise != null)
         {
            this.mc_noise.x = this.bmp_background.x;
            this.mc_noise.y = this.bmp_background.y;
         }
         if(this.mc_progress != null)
         {
            this.mc_progress.x = int(this.bmp_background.x + (this.bmp_background.width - this.mc_progress.width) * 0.5);
            this.mc_progress.y = int(this.bmp_background.y + this.bmp_background.height - this.mc_progress.height * 2);
         }
         if(this.mc_spinner != null)
         {
            this.mc_spinner.x = int(Math.min(stage.stageWidth,int(this.bmp_background.x + this.bmp_background.width)) - 25);
            this.mc_spinner.y = int(Math.min(_loc2_,int(this.bmp_background.y + this.bmp_background.height)) - 60);
         }
         if(this.txt_status != null)
         {
            this.txt_status.x = int(this.mc_spinner.x - this.mc_spinner.width * 0.5 - this.txt_status.width - 6);
            this.txt_status.y = int(this.mc_spinner.y - this.txt_status.height * 0.5 + 2);
         }
      }
      
      private function onPlayerIOConnected(param1:Event) : void
      {
         this.loadCore();
      }
      
      private function onPlayerIOConnectError(param1:ErrorEvent) : void
      {
         this.txt_status.text = "CONNECT ERROR";
         this.txt_status.x = int(this.mc_spinner.x - this.mc_spinner.width * 0.5 - this.txt_status.width - 6);
      }
      
      private function onCoreLoadProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = param1.bytesLoaded / param1.bytesTotal;
         if(isNaN(_loc2_))
         {
            return;
         }
         this.mc_progress.progress = _loc2_ * this.CORE_LOAD_PERCENTAGE;
      }
      
      private function onCoreLoadComplete(param1:Event) : void
      {
         this.initCore();
      }
      
      private function onBackgroundLoadComplete(param1:Event) : void
      {
         this.initStage();
      }
      
      private function onBackgroundLoadFailed(param1:IOErrorEvent) : void
      {
         this.initStage();
      }
      
      private function JS_getScreenshot() : String
      {
         var _loc1_:Number = NaN;
         var _loc2_:Matrix = null;
         var _loc3_:BitmapData = null;
         try
         {
            _loc1_ = 0.25;
            _loc2_ = new Matrix();
            _loc2_.scale(_loc1_,_loc1_);
            _loc3_ = new BitmapData(Main.stage.stageWidth * _loc1_,Main.stage.stageHeight * _loc1_,false,0);
            _loc3_.draw(Main.stage,_loc2_);
            _loc3_.applyFilter(_loc3_,_loc3_.rect,new Point(),new BlurFilter(3,3,3));
            return Base64.encodeByteArray(PNGEncoder.encode(_loc3_));
         }
         catch(err:Error)
         {
         }
         return null;
      }
   }
}

