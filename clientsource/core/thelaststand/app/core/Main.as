package thelaststand.app.core
{
   import com.adobe.protocols.dict.events.ErrorEvent;
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import com.greensock.plugins.ColorMatrixFilterPlugin;
   import com.greensock.plugins.HexColorsPlugin;
   import com.greensock.plugins.ScalePlugin;
   import com.greensock.plugins.ShortRotationPlugin;
   import com.greensock.plugins.TransformAroundCenterPlugin;
   import com.greensock.plugins.TransformAroundPointPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.junkbyte.console.Cc;
   import flash.display.Bitmap;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageDisplayState;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.ThrottleEvent;
   import flash.events.ThrottleType;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.geom.ColorTransform;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.utils.clearInterval;
   import flash.utils.getTimer;
   import org.osflash.signals.events.GenericEvent;
   import playerio.PlayerIO;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerFlags;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.display.LoadingScreen;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.dialogues.CreateSurvivorDialogue;
   import thelaststand.app.game.gui.dialogues.ItemPurchasedDialogue;
   import thelaststand.app.game.gui.dialogues.PackagePurchasedDialogue;
   import thelaststand.app.game.gui.dialogues.PromoCodeClaimedDialogue;
   import thelaststand.app.game.gui.dialogues.UpgradeCarDialogue;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.ModalOverlay;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceLoaderProxy;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.preloader.display.ProgressBar;
   
   public class Main extends Sprite
   {
      
      private const CORE_LOAD_PERCENTAGE:Number = 0.3;
      
      private const RESOURCE_LOAD_PERCENTAGE:Number = 0.6;
      
      private const RESOURCE_UNPACK_PERCENTAGE:Number = 0.1;
      
      private var _resources:ResourceManager;
      
      private var _dialogues:DialogueManager;
      
      private var _network:Network;
      
      private var _settings:Settings;
      
      private var _lang:Language;
      
      private var _game:Game;
      
      private var _loadingGameInterval:Number = 0;
      
      private var _loadingInitAssets:Boolean;
      
      private var _resourceProxy:ResourceLoaderProxy;
      
      private var _secondaryAssetLoader:AssetLoader;
      
      private var bmp_background:Bitmap;
      
      private var mc_titleScreen:LoadingScreen;
      
      private var mc_loadProgress:ProgressBar;
      
      private var mc_modal:ModalOverlay;
      
      private var chromeClickBlocker:Sprite;
      
      public function Main()
      {
         super();
         if(stage)
         {
            this.init();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.init);
         }
      }
      
      private function init(param1:Event = null) : void
      {
         var e:Event = param1;
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.tabChildren = false;
         stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         stage.addEventListener(ThrottleEvent.THROTTLE,this.onThrottleStateChanged,false,0,true);
         stage.addEventListener(GameEvent.APP_INACTIVE,this.onAppInactive,false,0,true);
         stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.onStageRightMouseDown,false,0,true);
         this.initChromeScrollFix();
         Security.disableAVM1Loading = true;
         Global.stage = stage;
         Global.initConsole();
         Global.document = this;
         Global.parameters = stage.loaderInfo.parameters;
         Global.useSSL = stage.loaderInfo.parameters.useSSL == "1";
         PlayerIO.useSecureApiRequests = Global.useSSL;
         MouseCursors.init();
         MouseCursors.setCursor(MouseCursors.DEFAULT);
         UIItemInfo.stage = stage;
         TooltipManager.getInstance().stage = stage;
         TweenPlugin.activate([ShortRotationPlugin,HexColorsPlugin,ScalePlugin,TransformAroundCenterPlugin,TransformAroundPointPlugin,ColorMatrixFilterPlugin]);
         this._resources = ResourceManager.getInstance();
         this._dialogues = DialogueManager.getInstance();
         this._settings = Settings.getInstance();
         this._lang = Language.getInstance();
         this._resources.unpackStarted.add(this.onResourceUnpackStarted);
         this._resources.unpackProgress.add(this.onResourceUnpackProgress);
         this._resources.resourceLoadCompleted.add(this.onResourceLoadCompleted);
         this._resources.resourceLoadFailed.add(this.onResourceLoadFailed);
         this._resources.cacheFlushResponded.add(this.onResourceCacheFlushResponded);
         this._resources.unpackCompleted.addOnce(this.onInitComplete);
         this._dialogues.dialogueOpened.add(this.onDialogueOpened);
         this._dialogues.dialogueClosed.add(this.onDialogueClosed);
         Global.mouseInApp = true;
         if(ExternalInterface.available)
         {
            Security.allowDomain("*");
            stage.addEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave,false,0,true);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove,false,0,true);
         }
         if(stage.loaderInfo.parameters.kongregate_api_path != null)
         {
            Security.allowDomain(stage.loaderInfo.parameters.kongregate_api_path);
         }
         this.mc_modal = new ModalOverlay();
         this.bmp_background = new Bitmap(new BmpFullBackground());
         this.mc_titleScreen = new LoadingScreen(SharedResources.loadingBitmapInstance,stage.loaderInfo.parameters.service == "kong");
         addChildAt(this.mc_titleScreen,0);
         this.mc_loadProgress = new ProgressBar();
         this.mc_loadProgress.progress = 0.4;
         addChildAt(this.mc_loadProgress,1);
         this.mc_titleScreen.details = "";
         this.onStageResize(null);
         this._resources.baseURL = (stage.loaderInfo.parameters.path || "") + "data/";
         if(stage.loaderInfo.parameters.local != "1")
         {
            this._resources.uriProcessor = Global.processResourceURI;
         }
         this._loadingInitAssets = true;
         this._resourceProxy = new ResourceLoaderProxy(this._resources,this._settings.sharedObjectName);
         this._resourceProxy.fontLoaded.addOnce(function():void
         {
            mc_titleScreen.updateFont();
            mc_titleScreen.message = "LOADING ASSETS";
         });
         this._resourceProxy.loadAndUnpack("resources_main.xml");
      }
      
      private function connect() : void
      {
         Cc.logch("load","Starting connect");
         this._dialogues.closeDialogue("server-disconnected");
         this.mc_titleScreen.message = this._lang.getString("server_connect_msg");
         if(stage.loaderInfo.parameters.devServer != null)
         {
            Cc.logch("load","Using devServer: " + stage.loaderInfo.parameters.devServer);
            this._network.devServer = String(stage.loaderInfo.parameters.devServer);
         }
         else
         {
            Cc.logch("load","Using default PlayerIO server");
         }
         this._network.connect();
      }
      
      private function start() : void
      {
         var startHandler:Function;
         Cc.logch("load","Starting game");
         startHandler = function():void
         {
            Cc.logch("load","Executing startHandler");
            _dialogues.closeDialogue("create-survivor");
            if(bmp_background != null)
            {
               if(bmp_background.parent != null)
               {
                  bmp_background.parent.removeChild(bmp_background);
               }
               bmp_background.bitmapData.dispose();
               bmp_background.bitmapData = null;
               bmp_background = null;
            }
            _game = new Game(stage);
            Global.game = _game;
            addChild(_game.display);
            stage.transform.colorTransform = new ColorTransform();
         };
         this._dialogues.closeDialogue("asset-loading");
         Tutorial.getInstance().active = !this._network.playerData.flags.get(PlayerFlags.TutorialComplete);
         if(this.bmp_background.parent != null)
         {
            TweenMax.to(stage,0.5,{
               "tint":0,
               "onComplete":startHandler
            });
         }
         else
         {
            startHandler();
         }
      }
      
      public function kill() : void
      {
         this._game.dispose();
         this._game = null;
         this._resources.pauseQueue();
         this._resources.purge();
         this._network.disconnect();
         if(AllianceSystem.getInstance() != null)
         {
            AllianceSystem.getInstance().disconnect();
         }
         DialogueManager.getInstance().closeAll();
         stage.removeEventListener(ThrottleEvent.THROTTLE,this.onThrottleStateChanged);
      }
      
      private function flushCache() : void
      {
         var _loc1_:uint = uint(1024 * 1000 * 100);
         var _loc2_:Boolean = this._resources.flushCache(_loc1_);
         this._resources.purgeAllOfType("zip");
         if(_loc2_)
         {
            this._settings.setData("cacheEnabled",true);
            this.connect();
         }
      }
      
      private function onThrottleStateChanged(param1:ThrottleEvent) : void
      {
         if(param1.state == ThrottleType.PAUSE || param1.state == ThrottleType.THROTTLE)
         {
            if(this._game == null || this._game.location != NavigationLocation.MISSION)
            {
               Global.throttled = true;
               TweenMax.pauseAll();
            }
         }
         else
         {
            Global.throttled = false;
            TweenMax.resumeAll();
         }
      }
      
      private function onInitComplete() : void
      {
         Tracking.trackEvent("Player","AssetsLoadCompleted",null,int(getTimer() / 1000));
         this._resources.unpackStarted.remove(this.onResourceUnpackStarted);
         this._resources.unpackProgress.remove(this.onResourceUnpackProgress);
         this._resourceProxy.dispose();
         this._resourceProxy = null;
         Config.init();
         Audio.init();
         PaymentSystem.getInstance().transactionSuccess.add(this.onPaymentSuccessful);
         PaymentSystem.getInstance().transactionFailed.add(this.onPaymentFailed);
         this._network = Network.getInstance();
         this._network.connected.add(this.onNetworkConnected);
         this._network.connectOpened.add(this.onNetworkConnectOpened);
         this._network.connectError.add(this.onNetworkConnectError);
         this._network.connectProgress.add(this.onNetworkConnectProgress);
         this._network.serverInitProgress.add(this.onNetworkServerInitProgress);
         this._network.loadingProgress.add(this.onNetworkLoadingProgress);
         this._network.disconnected.add(this.onNetworkDisconnected);
         this._network.loginFailed.add(this.onNetworkLoginFailed);
         this._network.gameReady.add(this.onNetworkGameReady);
         this._network.outOfSync.add(this.onNetworkOutOfSync);
         this._network.locked.add(this.onNetworkLockStatusChanged);
         this._network.unlocked.add(this.onNetworkLockStatusChanged);
         this._network.gameDataReceived.add(this.onNetworkGameDataReceieved);
         loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onUncaughtError);
         this.mc_titleScreen.message = "";
         this.mc_titleScreen.details = "";
         this._loadingInitAssets = false;
         this.connect();
      }
      
      private function onResourceUnpackStarted() : void
      {
         this.mc_titleScreen.details = "Unpacking assets";
         this.mc_loadProgress.progress = this.CORE_LOAD_PERCENTAGE + this.RESOURCE_LOAD_PERCENTAGE;
      }
      
      private function onResourceUnpackProgress(param1:Resource, param2:int, param3:int) : void
      {
         var _loc4_:Number = param2 / param3;
         var _loc5_:Number = this.CORE_LOAD_PERCENTAGE + this.RESOURCE_LOAD_PERCENTAGE + _loc4_ * this.RESOURCE_UNPACK_PERCENTAGE;
         if(!isNaN(_loc5_) && _loc5_ > this.mc_loadProgress.progress)
         {
            this.mc_loadProgress.progress = _loc5_;
         }
      }
      
      private function onResourceLoadCompleted(param1:Resource) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         Cc.logch("assets","Loaded: " + param1.uri);
         if(param1.type == ResourceManager.TYPE_SOUND)
         {
            Audio.sound.addSound(param1.content,param1.uri);
         }
         if(this._loadingInitAssets)
         {
            _loc2_ = this._resources.resourcesLoaded / this._resources.resourcesTotal;
            _loc3_ = this.CORE_LOAD_PERCENTAGE + _loc2_ * this.RESOURCE_LOAD_PERCENTAGE;
            if(!isNaN(_loc3_) && _loc3_ > this.mc_loadProgress.progress)
            {
               this.mc_loadProgress.progress = _loc3_;
            }
         }
      }
      
      private function onResourceLoadFailed(param1:Resource, param2:Object) : void
      {
         Cc.warnch("assets","Failed: " + param1.uri);
         Cc.explode(param2);
      }
      
      private function onResourceCacheFlushResponded(param1:Boolean) : void
      {
         if(param1)
         {
            this._settings.setData("cacheEnabled",param1);
         }
         this.connect();
      }
      
      private function onDialogueOpened(param1:GenericEvent, param2:Dialogue) : void
      {
         if(param2.sprite.parent == null)
         {
            if(param2.modal)
            {
               stage.addChild(this.mc_modal);
            }
            stage.addChild(param2.sprite);
            param2.sprite.x = int((stage.stageWidth - param2.width) * 0.5) + param2.offset.x;
            param2.sprite.y = int((stage.stageHeight - 200 - param2.height) * 0.5) + param2.offset.y;
         }
      }
      
      private function positionModal() : void
      {
         if(this._dialogues.numDialoguesOpen == 0 && !this._network.isLocked)
         {
            if(this.mc_modal.parent != null)
            {
               this.mc_modal.parent.removeChild(this.mc_modal);
            }
         }
         else if(this._network.isLocked)
         {
            stage.addChild(this.mc_modal);
         }
         else if(this._dialogues.getActiveDialogue() != null)
         {
            if(this._dialogues.getActiveDialogue().sprite.parent == stage)
            {
               stage.addChildAt(this.mc_modal,stage.getChildIndex(this._dialogues.getActiveDialogue().sprite));
            }
            else if(this.mc_modal.parent != null)
            {
               this.mc_modal.parent.removeChild(this.mc_modal);
            }
         }
      }
      
      private function onDialogueClosed(param1:GenericEvent, param2:Dialogue) : void
      {
         if(param2.sprite.parent == stage)
         {
            param2.sprite.parent.removeChild(param2.sprite);
         }
         this.positionModal();
         stage.focus = stage;
      }
      
      private function onStageResize(param1:Event) : void
      {
         var _loc3_:Dialogue = null;
         var _loc2_:int = stage.stageHeight - 200;
         if(this.mc_titleScreen != null)
         {
            this.mc_titleScreen.width = stage.stageWidth;
            this.mc_titleScreen.height = _loc2_;
         }
         if(this.mc_loadProgress != null)
         {
            this.mc_loadProgress.x = int((stage.stageWidth - this.mc_loadProgress.width) * 0.5);
            this.mc_loadProgress.y = int(_loc2_ - this.mc_loadProgress.height * 2);
         }
         for each(_loc3_ in DialogueManager.getInstance().openDialogues)
         {
            if(_loc3_.priority > 0 || this._game == null)
            {
               _loc3_.sprite.x = int((stage.stageWidth - _loc3_.width) * 0.5) + _loc3_.offset.x;
               _loc3_.sprite.y = int((_loc2_ - _loc3_.height) * 0.5) + _loc3_.offset.y;
            }
         }
         Cc.width = stage.stageWidth;
         Cc.height = int(stage.stageHeight * 0.33);
      }
      
      private function onStageMouseLeave(param1:Event) : void
      {
         if(Global.mouseInApp && ExternalInterface.available)
         {
            Global.mouseInApp = false;
            ExternalInterface.call("setMouseWheelState",!Global.mouseInApp);
         }
      }
      
      private function onStageMouseMove(param1:MouseEvent) : void
      {
         if(!Global.mouseInApp && ExternalInterface.available)
         {
            Global.mouseInApp = true;
            ExternalInterface.call("setMouseWheelState",!Global.mouseInApp);
         }
      }
      
      private function onStageRightMouseDown(param1:MouseEvent) : void
      {
      }
      
      private function onAppInactive(param1:GameEvent) : void
      {
         this.kill();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("killGame");
         }
      }
      
      private function onNetworkConnected() : void
      {
         Cc.logch("load","Network connected");
         TweenMax.killTweensOf(this.mc_loadProgress);
         this.mc_titleScreen.message = this._lang.getString("load_game");
         this.mc_titleScreen.details = "";
         this.mc_loadProgress.progress = 0;
      }
      
      private function onNetworkGameReady() : void
      {
         var loader:AssetLoader;
         Cc.logch("load","Network game ready, loading player data assets");
         loader = new AssetLoader();
         loader.loadingCompleted.addOnce(function():void
         {
            Cc.logch("load","Player data assets loaded, proceeding to onReady");
            onReady();
            loader.dispose();
         });
         loader.loadingProgress.add(function():void
         {
            Cc.logch("load","Player data asset loading progress: " + loader.progress);
            TweenMax.to(mc_loadProgress,3,{
               "progress":loader.progress,
               "overwrite":true,
               "ease":Linear.easeNone
            });
         });
         loader.loadPlayerDataAssets();
      }
      
      private function onNetworkLoginFailed(param1:String) : void
      {
         Cc.logch("load","Network login failed: " + param1);
         var _loc2_:MessageBox = null;
         if(param1 == "underAttack")
         {
            _loc2_ = new MessageBox(this._lang.getString("server_underAttack_msg"));
            _loc2_.addTitle(this._lang.getString("server_underAttack_title"));
         }
         else if(param1 == "alreadyOnline")
         {
            _loc2_ = new MessageBox(this._lang.getString("server_alreadyOnline_msg"));
            _loc2_.addTitle(this._lang.getString("server_alreadyOnline_title"));
         }
         if(_loc2_ != null)
         {
            _loc2_.open();
         }
      }
      
      private function onNetworkDisconnected() : void
      {
         var msg:MessageBox = null;
         clearInterval(this._loadingGameInterval);
         if(AllianceSystem.getInstance() != null)
         {
            AllianceSystem.getInstance().disconnect();
         }
         this._network.chatSystem.disconnectAll();
         if(!this._network.joinedRoom)
         {
            return;
         }
         if(this._game != null)
         {
            this._resources.pauseQueue();
            this._game.dispose();
            this._game = null;
         }
         if(this._network.serverActive)
         {
            msg = new MessageBox(this._lang.getString("server_disconnected_msg"),"server-disconnected");
            msg.addTitle(this._lang.getString("server_disconnected_title"));
            if(ExternalInterface.available)
            {
               msg.addButton(this._lang.getString("server_outofsync_ok"),false).clicked.addOnce(function(param1:MouseEvent):void
               {
                  ExternalInterface.call("refresh");
               });
            }
         }
         else
         {
            msg = new MessageBox(this._lang.getString("server_join_disabled_msg"),"server-disconnected");
            msg.addTitle(this._lang.getString("server_join_disabled_title"));
         }
         msg.priority = int.MAX_VALUE;
         msg.open();
      }
      
      private function onNetworkGameDataReceieved() : void
      {
         Cc.logch("load","Received game data, loading secondary assets");
         var _loc1_:String = "resources_secondary.xml";
         var _loc2_:Array = [];
         var _loc3_:XML = XML(this._resources.getResource(_loc1_).content);
         for each(var _loc4_ in _loc3_.res)
         {
            Cc.logch("load","Adding asset to load: " + _loc4_.toString());
            _loc2_.push(_loc4_.toString());
         }
         for each(var _loc5_ in this._resources.getResource("xml/buildings.xml").content..snd.children())
         {
            Cc.logch("load","Adding sound asset: " + _loc5_.toString());
            _loc2_.push(_loc5_.toString());
         }
         this._secondaryAssetLoader = new AssetLoader();
         this._secondaryAssetLoader.loadAssets(_loc2_);
      }
      
      private function onReady() : void
      {
         Cc.logch("load","Game ready, transitioning to start");
         this._dialogues.closeDialogue("asset-loading");
         clearInterval(this._loadingGameInterval);
         TweenMax.to(this.mc_loadProgress,0.5,{"alpha":0});
         this._network.connected.remove(this.onNetworkConnected);
         this._network.connectOpened.remove(this.onNetworkConnectOpened);
         this._network.connectError.remove(this.onNetworkConnectError);
         this._network.loginFailed.remove(this.onNetworkLoginFailed);
         this._network.gameReady.remove(this.onNetworkGameReady);
         this._network.connectProgress.remove(this.onNetworkConnectProgress);
         this._network.serverInitProgress.remove(this.onNetworkServerInitProgress);
         this._network.loadingProgress.remove(this.onNetworkLoadingProgress);
         if(Network.getInstance().service == PlayerIOConnector.SERVICE_KONGREGATE)
         {
            try
            {
               Cc.logch("load","Submitting Kongregate stats");
               SharedResources.kongregateAPI.stats.submit("Initialized",1);
               SharedResources.kongregateAPI.stats.submit("Level",this._network.playerData.getPlayerSurvivor().level + 1);
            }
            catch(e:Error)
            {
               Cc.logch("load","Kongregate stats submission failed: " + e.message);
            }
         }
         this.mc_titleScreen.message = "";
         this.mc_titleScreen.transitionedOut.addOnce(function():void
         {
            var dlg:CreateSurvivorDialogue;
            Cc.logch("load","Title screen transitioned out");
            dlg = null;
            mc_titleScreen = null;
            mc_loadProgress.dispose();
            mc_loadProgress = null;
            if(_network.playerData.nickname == null)
            {
               Cc.logch("load","No nickname, showing CreateSurvivorDialogue");
               addChildAt(bmp_background,0);
               dlg = new CreateSurvivorDialogue(_network.playerData.getPlayerSurvivor(),_lang.getString("player_create_title"),_lang.getString("player_create_name_desc"));
               dlg.modal = false;
               dlg.playSounds = false;
               dlg.completed.addOnce(function():void
               {
                  Cc.logch("load","CreateSurvivorDialogue completed");
                  dlg.sprite.mouseChildren = false;
                  start();
               });
               dlg.open();
               TweenMax.from(stage,1,{"tint":0});
            }
            else
            {
               Cc.logch("load","Nickname exists, proceeding to start");
               start();
            }
         });
         this.mc_titleScreen.transitionOut();
      }
      
      private function onNetworkConnectOpened() : void
      {
         Cc.logch("load","Network connect opened");
         this.mc_titleScreen.message = this._lang.getString("server_connect_msg");
      }
      
      private function onNetworkConnectProgress(param1:Number) : void
      {
         Cc.logch("load","Network connect progress: " + param1 + ", status: " + this._network.currentStatus);
         this.mc_titleScreen.details = this._network.currentStatus;
         if(param1 < this.mc_loadProgress.progress)
         {
            this.mc_loadProgress.progress = param1;
         }
         TweenMax.to(this.mc_loadProgress,3,{
            "progress":param1,
            "overwrite":true,
            "ease":Linear.easeNone
         });
      }
      
      private function onNetworkServerInitProgress(param1:Number) : void
      {
         Cc.logch("load","Server init progress: " + param1 + ", status: " + this._network.currentStatus);
         this.mc_titleScreen.details = this._network.currentStatus;
         var _loc2_:Number = param1 * 0.75;
         if(_loc2_ < this.mc_loadProgress.progress)
         {
            this.mc_loadProgress.progress = _loc2_;
         }
         TweenMax.to(this.mc_loadProgress,3,{
            "progress":_loc2_,
            "overwrite":true,
            "ease":Linear.easeNone
         });
      }
      
      private function onNetworkLoadingProgress(param1:Number) : void
      {
         Cc.logch("load","Network loading progress: " + param1 + ", status: " + this._network.currentStatus);
         this.mc_titleScreen.details = this._network.currentStatus;
         var _loc2_:Number = 0.75 + param1 * 0.25;
         if(_loc2_ < this.mc_loadProgress.progress)
         {
            this.mc_loadProgress.progress = _loc2_;
         }
         TweenMax.to(this.mc_loadProgress,3,{
            "progress":_loc2_,
            "overwrite":true,
            "ease":Linear.easeNone
         });
      }
      
      private function onNetworkConnectError(param1:String) : void
      {
         var msg:MessageBox;
         Cc.logch("load","Network connect error: " + param1);
         this.mc_titleScreen.message = "";
         this.mc_titleScreen.details = "";
         clearInterval(this._loadingGameInterval);
         msg = null;
         if(errMsg == "facebookError")
         {
            msg = new MessageBox(this._lang.getString("server_fb_error_msg"),"server-connect",false,false);
            msg.addTitle(this._lang.getString("server_fb_error_title"));
         }
         else
         {
            msg = new MessageBox(this._lang.getString("server_connect_error_msg"),"server-connect",false,false);
            msg.addTitle(this._lang.getString("server_connect_error_title"));
         }
         msg.addButton(this._lang.getString("server_connect_error_tryagain")).clicked.addOnce(function(param1:MouseEvent):void
         {
            Cc.logch("load","Retrying connection");
            connect();
         });
         msg.open();
      }
      
      private function onNetworkOutOfSync() : void
      {
         var msg:MessageBox;
         if(this._game != null)
         {
            this._game.pause(true);
         }
         msg = new MessageBox(this._lang.getString("server_outofsync_msg"),"server-outofsync");
         msg.addTitle(this._lang.getString("server_outofsync_title"),BaseDialogue.TITLE_COLOR_RUST);
         if(ExternalInterface.available)
         {
            msg.addButton(this._lang.getString("server_outofsync_ok"),false).clicked.addOnce(function(param1:MouseEvent):void
            {
               ExternalInterface.call("refresh");
            });
         }
         Tracking.trackEvent("Player","SyncError",null,int(getTimer() / 1000));
         msg.priority = int.MAX_VALUE;
         msg.open();
      }
      
      private function onNetworkLockStatusChanged() : void
      {
         this.positionModal();
      }
      
      private function onPaymentSuccessful(param1:String, ... rest) : void
      {
         var msg:BaseDialogue = null;
         var amount:int = 0;
         var packageKey:String = null;
         var isFree:Boolean = false;
         var item:Item = null;
         var collectionKey:String = null;
         var resource:String = null;
         var resAmount:int = 0;
         var itemName:String = null;
         var collectionName:String = null;
         var strAmount:String = null;
         var transactionType:String = param1;
         var args:Array = rest;
         var lang:Language = Language.getInstance();
         switch(transactionType)
         {
            case "fuel":
               DialogueManager.getInstance().closeDialogue("buy-fuel");
               amount = PaymentSystem.getInstance().lastPurchaseAmount;
               if(amount > 0)
               {
                  msg = new ItemPurchasedDialogue(lang.getString("buy_fuel_complete_title"),lang.getString("buy_fuel_complete_msg",NumberFormatter.format(amount,0)),"images/ui/fuel-200x200.jpg");
               }
               break;
            case "codepackage":
               msg = new PromoCodeClaimedDialogue(args[0]);
               break;
            case "package":
               packageKey = args[0].key;
               isFree = args[0].PriceCoins === 0;
               msg = new PackagePurchasedDialogue(lang.getString("offers." + (isFree ? "claimed" : "bought") + "_title",lang.getString("offers." + packageKey)),lang.getString("offers." + (isFree ? "claimed" : "bought") + "_msg",lang.getString("offers." + packageKey)));
               break;
            case "item":
               item = args[0] as Item;
               if(item != null)
               {
                  itemName = item.getName();
                  if(item.quantity > 1)
                  {
                     itemName += " x " + NumberFormatter.format(item.quantity,0);
                  }
                  msg = new MessageBox(lang.getString("purchase_item_complete_msg",itemName));
                  msg.addTitle(lang.getString("purchase_item_complete_title"),BaseDialogue.TITLE_COLOR_BUY);
                  msg.addButton(lang.getString("purchase_item_complete_ok"));
                  MessageBox(msg).addImage(item.getImageURI());
               }
               break;
            case "itemcollection":
               collectionKey = args[0].key;
               if(collectionKey)
               {
                  collectionName = lang.getString("itemcollection." + collectionKey);
                  msg = new MessageBox(lang.getString("purchase_item_complete_msg",collectionName));
                  msg.addTitle(lang.getString("purchase_item_complete_title"),BaseDialogue.TITLE_COLOR_BUY);
                  msg.addButton(lang.getString("purchase_item_complete_ok"));
                  MessageBox(msg).addImage("images/ui/buy-collection.jpg");
               }
               break;
            case "resource":
               resource = String(args[0]);
               resAmount = int(args[1]);
               if(resource != null && resAmount > 0)
               {
                  strAmount = "<font color=\'" + Color.colorToHex(GameResources.RESOURCE_COLORS[resource]) + "\'><b>" + "+" + NumberFormatter.format(resAmount,0) + " " + lang.getString("items." + resource) + "</b></font>";
                  msg = new MessageBox(lang.getString("store_res_purchase_msg",strAmount));
                  msg.addTitle(lang.getString("store_res_purchase_title"),BaseDialogue.TITLE_COLOR_BUY);
                  msg.addButton(lang.getString("store_res_purchase_ok"));
                  MessageBox(msg).addImage(Config.xml.store_resources[resource].generic[0].@uri.toString());
               }
               break;
            case PlayerUpgrades.getName(PlayerUpgrades.DeathMobileUpgrade):
               msg = new ItemPurchasedDialogue(lang.getString("upgrade_car_complete_title"),lang.getString("upgrade_car_complete_msg"),"images/ui/car-200x200.jpg");
               if(UpgradeCarDialogue.upgradeRename != null)
               {
                  this._network.save({"name":UpgradeCarDialogue.upgradeRename},SaveDataMethod.DEATH_MOBILE_RENAME,function(param1:Object):void
                  {
                     var _loc2_:Building = _network.playerData.compound.buildings.getFirstBuildingOfType("car");
                     if(_loc2_ != null)
                     {
                        _loc2_.setName(UpgradeCarDialogue.upgradeRename);
                     }
                  });
               }
               break;
            case "inventoryUpgrade":
               msg = new MessageBox(lang.getString("inventory_upgrade_complete_msg",NumberFormatter.format(Network.getInstance().playerData.inventoryBaseSize,0)));
               msg.addTitle(lang.getString("inventory_upgrade_complete_title"),BaseDialogue.TITLE_COLOR_BUY);
               msg.addButton(lang.getString("inventory_upgrade_complete_ok"));
         }
         if(msg != null)
         {
            msg.open();
         }
      }
      
      private function onPaymentFailed() : void
      {
         DialogueManager.getInstance().closeDialogue("buy-fuel");
         DialogueManager.getInstance().closeDialogue("payment-failure");
         var _loc1_:MessageBox = new MessageBox(this._lang.getString("server_purchase_fail_msg"),"payment-failure");
         _loc1_.addTitle(this._lang.getString("server_purchase_fail_title"),BaseDialogue.TITLE_COLOR_RUST);
         _loc1_.addButton(this._lang.getString("server_purchase_fail_ok"));
         _loc1_.open();
      }
      
      private function onUncaughtError(param1:UncaughtErrorEvent) : void
      {
         var _loc3_:Error = null;
         var _loc4_:ErrorEvent = null;
         if(!Capabilities.isDebugger)
         {
            return;
         }
         var _loc2_:Object = Global.getCapabilityData({"player":this._network.playerData.id});
         if(param1.error is Error)
         {
            _loc3_ = param1.error as Error;
            if(_loc3_.errorID == 2122)
            {
               return;
            }
            if(this._network != null && this._network.client != null)
            {
               this._network.client.errorLog.writeError("Uncaught error",_loc3_.message,_loc3_.getStackTrace(),_loc2_);
            }
         }
         else if(param1.error is ErrorEvent)
         {
            _loc4_ = param1.error as ErrorEvent;
            if(this._network != null && this._network.client != null)
            {
               this._network.client.errorLog.writeError("Uncaught error",_loc3_.message,null,_loc2_);
            }
         }
      }
      
      private function initChromeScrollFix() : void
      {
         stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onStageMouseWheel,true,int.MAX_VALUE,true);
         this.chromeClickBlocker = new Sprite();
         var _loc1_:Graphics = this.chromeClickBlocker.graphics;
         _loc1_.beginFill(16711680,0);
         _loc1_.drawRect(0,0,100,100);
         _loc1_.endFill();
      }
      
      private function onStageMouseWheel(param1:MouseEvent) : void
      {
         if(stage.displayState == StageDisplayState.NORMAL)
         {
            return;
         }
         this.chromeClickBlocker.width = stage.stageWidth;
         this.chromeClickBlocker.height = stage.stageHeight;
         this.chromeClickBlocker.x = this.chromeClickBlocker.y = 0;
         stage.addChild(this.chromeClickBlocker);
         TweenMax.killDelayedCallsTo(this.removeClickBlocker);
         TweenMax.delayedCall(0.1,this.removeClickBlocker);
      }
      
      private function removeClickBlocker() : void
      {
         if(this.chromeClickBlocker.parent)
         {
            this.chromeClickBlocker.parent.removeChild(this.chromeClickBlocker);
         }
      }
   }
}

