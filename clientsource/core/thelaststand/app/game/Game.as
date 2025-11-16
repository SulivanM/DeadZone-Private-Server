package thelaststand.app.game
{
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.core.View;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.objects.Decal;
   import com.deadreckoned.threshold.navigation.rvo.RVOSimulator;
   import com.greensock.TweenMax;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DRenderMode;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import org.osflash.signals.events.GenericEvent;
   import playerio.Message;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.data.PlayerFlags;
   import thelaststand.app.display.LoadingScreen;
   import thelaststand.app.display.Vignette;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.CameraControlType;
   import thelaststand.app.game.data.CompoundData;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.data.ZombieOpponentData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.notification.INotification;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.research.ResearchEffect;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.events.GUIControlEvent;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.app.game.gui.DialogueGUILayer;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.UILevelUpAnim;
   import thelaststand.app.game.gui.arena.ArenaEndedDialogue;
   import thelaststand.app.game.gui.dialogues.CompoundReportDialogue;
   import thelaststand.app.game.gui.dialogues.CrateTutorialDialogue;
   import thelaststand.app.game.gui.dialogues.CrateUnlockDialogue;
   import thelaststand.app.game.gui.dialogues.CreateSurvivorDialogue;
   import thelaststand.app.game.gui.dialogues.DailyQuestDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryDialogue;
   import thelaststand.app.game.gui.dialogues.LongSessionValidationDialogue;
   import thelaststand.app.game.gui.dialogues.MissionReportDialogue;
   import thelaststand.app.game.gui.dialogues.NewsDialogue;
   import thelaststand.app.game.gui.dialogues.PromoDialogue;
   import thelaststand.app.game.gui.map.WorldMapGUILayer;
   import thelaststand.app.game.gui.raid.RaidEndedDialogue;
   import thelaststand.app.game.logic.CompoundDirector;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.game.logic.ISceneDirector;
   import thelaststand.app.game.logic.MiniTaskSystem;
   import thelaststand.app.game.logic.MissionDirector;
   import thelaststand.app.game.logic.MissionPlanningDirector;
   import thelaststand.app.game.logic.MissionPvPDirector;
   import thelaststand.app.game.logic.MissionPvZDirector;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.game.logic.PlayerCompoundDirector;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.app.game.scenes.CompoundScene;
   import thelaststand.app.game.scenes.MissionLoader;
   import thelaststand.app.game.scenes.SceneFactory;
   import thelaststand.app.game.scenes.SceneLoader;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.SceneRandomizer;
   import thelaststand.app.utils.SurvivorPortrait;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class Game
   {
      
      private const CLICK_MOVE_THRESHOLD:int = 6;
      
      private var INACTIVE_TIME:int = 0;
      
      private var _container:Sprite;
      
      private var _mouseDown:Boolean;
      
      private var _mouseDragPt:Point;
      
      private var _mouseLastPt:Point;
      
      private var _paused:Boolean;
      
      private var _stage:Stage;
      
      private var _stage3D:Stage3D;
      
      private var _scene:BaseScene;
      
      private var _gui:GameGUI;
      
      private var _guiDialogue:DialogueGUILayer;
      
      private var _missionLoader:MissionLoader;
      
      private var _view:View;
      
      private var _director:ISceneDirector;
      
      private var _location:String;
      
      private var _firstVisit:Boolean;
      
      private var _worldMap:WorldMapGUILayer;
      
      private var _network:Network;
      
      private var _fading:Boolean;
      
      private var _started:Boolean;
      
      private var _keys:uint = 0;
      
      private var _rvoSimulator:RVOSimulator;
      
      private var _uploadedResources:Vector.<Resource>;
      
      private var _expirationTimer:Timer;
      
      private var _longSessionTimer:Timer;
      
      private var _shutdownLockdown:Boolean;
      
      private var _zombieAttackCompleted:Boolean;
      
      private var _zombieAttackMission:MissionData;
      
      private var _zombieAttackLoaderA:MissionLoader;
      
      private var _zombieAttackLoaderB:MissionLoader;
      
      private var _zombieAttackPreparing:Boolean;
      
      private var _zombieAttackPrepareTimer:Timer;
      
      private var _deltaTime:Number = 0;
      
      private var _timeElapsed:Number = 0;
      
      private var _timeLast:Number = 0;
      
      private var _timeScale:Number = 1;
      
      private var _timeAccumulator:Number = 0;
      
      private var _FPSRenderTime:Number = 0.03333333333333333;
      
      private var _FPSMaxFrameSkip:int = 5;
      
      private var _FPSDropThreshold:int = 20;
      
      private var _FPSDropMaxTime:Number = 3;
      
      private var _FPSDropTime:Number = 0;
      
      private var _inactiveTimer:Number = 0;
      
      private var bmp_vignette:Vignette;
      
      private var mc_fader:Shape;
      
      private var mc_levelUp:UILevelUpAnim;
      
      private var mc_loadingScreen:LoadingScreen;
      
      private var _zombieAttackImminent:Boolean;
      
      private var _showLongSessionDialogue:Boolean;
      
      private var _ahTimer:Timer;
      
      private var _ahLastTimer:int = 0;
      
      private var _ahLastSystem:Number = 0;
      
      private var _ahCount:int = 0;
      
      public function Game(param1:Stage)
      {
         super();
         this._stage = param1;
         this._firstVisit = true;
         this._mouseDragPt = new Point();
         this._mouseLastPt = new Point();
         this._uploadedResources = new Vector.<Resource>();
         this._view = new View(this._stage.stageWidth,this._stage.stageHeight);
         this._view.antiAlias = this.getAntiAliasValue();
         this._view.rightClick3DEnabled = true;
         this._view.hideLogo();
         this._zombieAttackPrepareTimer = new Timer(1000,int(Config.constant.ATTACK_PREPARE_TIME));
         this._zombieAttackPrepareTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onAttackPrepareTimerCompleted,false,0,true);
         this._zombieAttackLoaderA = new MissionLoader();
         this._zombieAttackLoaderB = new MissionLoader();
         this._missionLoader = new MissionLoader();
         this._rvoSimulator = new RVOSimulator();
         this._expirationTimer = new Timer(60000);
         this._expirationTimer.addEventListener(TimerEvent.TIMER,this.onExpirationTimerTick,false,0,true);
         this._expirationTimer.start();
         this.INACTIVE_TIME = int(Config.constant.INACTIVE_TIME);
         this._gui = new GameGUI(this);
         this._gui.mouseEnabled = false;
         this._guiDialogue = new DialogueGUILayer();
         this.bmp_vignette = new Vignette();
         this.bmp_vignette.width = this._stage.stageWidth;
         this.bmp_vignette.height = this._stage.stageHeight;
         this.mc_fader = new Shape();
         this.mc_fader.graphics.beginFill(0);
         this.mc_fader.graphics.drawRect(0,0,10,10);
         this.mc_fader.graphics.endFill();
         this.mc_fader.width = this._stage.stageWidth;
         this.mc_fader.height = this._stage.stageHeight;
         this.mc_levelUp = new UILevelUpAnim();
         Settings.getInstance().settingChanged.add(this.onSettingChanged);
         Decal.zBufferPrecision = 18;
         this._stage3D = this._stage.stage3Ds[0];
         this._stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreate);
         this._network = Network.getInstance();
         this._network.playerData.flags.changed.add(this.onPlayerFlagChanged);
         this._network.playerData.inventory.schematicAdded.add(this.onSchematicUnlocked);
         this._network.playerData.getPlayerSurvivor().levelIncreased.add(this.onPlayerLevelUp);
         this._network.playerData.researchState.researchCompleted.add(this.onResearchCompleted);
         this._network.playerData.researchState.effectsChanged.add(this.onResearchEffectsChanged);
         this._network.connection.addMessageHandler(NetworkMessage.BUILDING_COMPLETE,this.onBuildingCompleteMessage);
         this._network.connection.addMessageHandler(NetworkMessage.RESEARCH_COMPLETE,this.onResearchCompleteMessage);
         this._network.connection.addMessageHandler(NetworkMessage.SURVIVOR_NEW,this.onNewSurvivorArrivedMessage);
         this._network.connection.addMessageHandler(NetworkMessage.ZOMBIE_ATTACK,this.onZombieAttackMessage);
         this._network.chatSystem.init(this,this._network.playerData.nickname,this._network.playerData.id);
         TimerManager.getInstance().timerCompleted.add(this.onTimerCompleted);
         NotificationSystem.getInstance().notificationAdded.add(this.onNotificationAdded);
         this._ahTimer = new Timer(60000,0);
         this._ahTimer.addEventListener(TimerEvent.TIMER,this.onAHTimer);
         this._ahTimer.start();
         this._container = new Sprite();
         this._container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this._container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         this._container.addEventListener(GUIControlEvent.CAMERA_CONTROL,this.onCameraControlled,false,0,true);
         ResearchSystem.getInstance().init();
         MiniTaskSystem.getInstance().init();
         this._longSessionTimer = new Timer(3 * 60 * 60 * 1000);
         this._longSessionTimer.addEventListener(TimerEvent.TIMER,this.onLongSessionTimerTick,false,0,true);
         this._longSessionTimer.start();
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
      }
      
      public function dispose() : void
      {
         this.setUserInputEnabled(false);
         TweenMax.killChildTweensOf(this._container);
         Settings.getInstance().settingChanged.remove(this.onSettingChanged);
         TimerManager.getInstance().timerCompleted.remove(this.onTimerCompleted);
         if(this._network.connection != null)
         {
            this._network.connection.removeMessageHandler(NetworkMessage.BUILDING_COMPLETE,this.onBuildingCompleteMessage);
            this._network.connection.removeMessageHandler(NetworkMessage.RESEARCH_COMPLETE,this.onResearchCompleteMessage);
            this._network.connection.removeMessageHandler(NetworkMessage.SURVIVOR_NEW,this.onNewSurvivorArrivedMessage);
            this._network.connection.removeMessageHandler(NetworkMessage.ZOMBIE_ATTACK,this.onZombieAttackMessage);
         }
         this._network.playerData.researchState.effectsChanged.remove(this.onResearchEffectsChanged);
         this._network.playerData.researchState.researchCompleted.remove(this.onResearchCompleted);
         this._network.playerData.getPlayerSurvivor().levelIncreased.remove(this.onPlayerLevelUp);
         this._network = null;
         this._expirationTimer.stop();
         this._longSessionTimer.stop();
         this._container.removeEventListener(GUIControlEvent.CAMERA_CONTROL,this.onCameraControlled);
         this.killDirector();
         if(this._scene != null)
         {
            this._scene.dispose();
            this._scene = null;
         }
         if(this._worldMap != null)
         {
            this._worldMap.dispose();
            this._worldMap = null;
         }
         if(this.mc_loadingScreen != null)
         {
            this.mc_loadingScreen.dispose();
            this.mc_loadingScreen = null;
         }
         this._zombieAttackPrepareTimer.stop();
         this._zombieAttackPrepareTimer = null;
         this._zombieAttackMission = null;
         this._zombieAttackLoaderA.dispose();
         this._zombieAttackLoaderA = null;
         this._zombieAttackLoaderB.dispose();
         this._zombieAttackLoaderB = null;
         this.mc_levelUp.dispose();
         this.bmp_vignette.dispose();
         this.bmp_vignette = null;
         this._guiDialogue.dispose();
         this._guiDialogue = null;
         this._gui.dispose();
         this._gui = null;
         this._view = null;
         if(this._container.parent != null)
         {
            this._container.parent.removeChild(this._container);
         }
         if(this._stage3D != null)
         {
            this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextRevived);
            this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreate);
            if(this._stage3D.context3D != null)
            {
               this._stage3D.context3D.dispose();
            }
            this._stage3D = null;
         }
         if(this._stage != null)
         {
            this._stage.removeEventListener(Event.RESIZE,this.onStageResize);
            this._stage = null;
         }
      }
      
      public function pause(param1:Boolean) : void
      {
         this._paused = param1;
         this.setUserInputEnabled(!this._paused);
      }
      
      private function getAntiAliasValue() : int
      {
         switch(Settings.getInstance().antiAlias)
         {
            case Settings.ANTIALIAS_X8:
               return 8;
            case Settings.ANTIALIAS_X4:
               return 4;
            case Settings.ANTIALIAS_X2:
               return 1;
            default:
               return 0;
         }
      }
      
      public function getSceneSnapshot() : BitmapData
      {
         if(this._scene == null || this._stage3D == null)
         {
            return null;
         }
         var _loc1_:BitmapData = new BitmapData(this._view.width,this._view.height,false,0);
         this._view.renderToBitmap = true;
         this._scene.camera.render(this._stage3D);
         _loc1_.draw(this._view);
         this._view.renderToBitmap = false;
         return _loc1_;
      }
      
      private function gotoCompound(param1:RemotePlayerData = null, param2:Boolean = true) : void
      {
         var lang:Language;
         var loadMessage:String;
         var xml:XML;
         var sceneLoader:SceneLoader;
         var neighbor:RemotePlayerData;
         var useLoadScreen:Boolean;
         var resource:*;
         log("[gotoCompound] called with param1 = " + param1 + ", param2 = " + param2);
         xml = null;
         sceneLoader = null;
         neighbor = param1;
         useLoadScreen = param2;
         resource = ResourceManager.getInstance().getResource("xml/scenes/compound.xml");
         log("[gotoCompound] resource = " + resource);
         if(resource == null)
         {
            log("[gotoCompound] ERROR: compound.xml resource not found!");
         }
         else
         {
            log("[gotoCompound] resource.content = " + resource.content);
            try
            {
               xml = SceneRandomizer.generateRandomSceneXML(resource.content);
               log("[gotoCompound] generated XML = " + xml);
            }
            catch(e:Error)
            {
               log("[gotoCompound] ERROR during XML generation: " + e.getStackTrace());
            }
         }
         sceneLoader = new SceneLoader();
         log("[gotoCompound] sceneLoader created. xml = " + xml);
         if(!useLoadScreen || neighbor == null && this._scene is CompoundScene)
         {
            log("[gotoCompound] skipping load screen");
            sceneLoader.loadCompleted.addOnce(this.onPlayerCompoundSceneLoaded);
            sceneLoader.load(xml);
            return;
         }
         log("[gotoCompound] preparing to show loading screen");
         lang = Language.getInstance();
         loadMessage = neighbor == null ? lang.getString("load_playercompound") : lang.getString("load_neighborcompound",neighbor.nickname);
         log("[gotoCompound] loadMessage: " + loadMessage);
         this.gotoLoadingScreen(loadMessage,function():void
         {
            log("[gotoCompound -> lambda] in loading screen callback");
            if(neighbor != null)
            {
               log("[gotoCompound -> lambda] neighbor is not null, requesting view for id: " + neighbor.id);
               _network.send(NetworkMessage.PLAYER_VIEW_REQUEST,{"id":neighbor.id},function(param1:Object):void
               {
                  var resourceURIs:Array = null;
                  var response:Object = param1;
                  log("[gotoCompound -> send callback] got response: " + response);
                  if(_location != NavigationLocation.NEIGHBOR_COMPOUND)
                  {
                     log("[gotoCompound -> send callback] not in neighbor compound location");
                     return;
                  }
                  if(response == null)
                  {
                     log("[gotoCompound -> send callback] response is null");
                     mc_loadingScreen.transitionedOut.addOnce(function():void
                     {
                        log("[gotoCompound -> send callback] loading screen transitioned out (null response)");
                        onPlayerCompoundSceneLoaded(sceneLoader);
                     });
                     sceneLoader.data = null;
                  }
                  else
                  {
                     log("[gotoCompound -> send callback] response is valid, creating compound data...");
                     neighbor.compound = new CompoundData();
                     neighbor.compound.buildings.readObject(response.buildings);
                     log("[gotoCompound -> send callback] buildings loaded");
                     mc_loadingScreen.transitionedOut.addOnce(function():void
                     {
                        log("[gotoCompound -> send callback] loading screen transitioned out (valid response)");
                        onNeighborCompoundSceneLoaded(sceneLoader);
                     });
                     sceneLoader.data = neighbor;
                  }
                  log("[gotoCompound -> send callback] calling sceneLoader.load");
                  sceneLoader.loadCompleted.addOnce(mc_loadingScreen.transitionOut);
                  sceneLoader.load(xml,resourceURIs);
               });
            }
            else
            {
               log("[gotoCompound -> lambda] neighbor is null, loading player compound");
               mc_loadingScreen.transitionedOut.addOnce(function():void
               {
                  log("[gotoCompound -> lambda] loading screen transitioned out (player)");
                  onPlayerCompoundSceneLoaded(sceneLoader);
               });
               sceneLoader.loadCompleted.addOnce(mc_loadingScreen.transitionOut);
               sceneLoader.load(xml);
            }
         });
      }
      
      private function setupPracticeSurvivors(param1:SurvivorCollection) : void
      {
         var _loc4_:Survivor = null;
         var _loc2_:Object = {
            "hairColor":"darkBrown",
            "skinColor":"light1",
            "hair":"hair3",
            "facialHair":null,
            "clothing_upper":"hoodie",
            "clothing_lower":"pants"
         };
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.getSurvivor(_loc3_);
            _loc4_.appearance.deserialize(Gender.MALE,_loc2_);
            _loc4_.effectEngine.clear();
            _loc4_.injuries.clear();
            _loc4_.morale.clear();
            _loc3_++;
         }
      }
      
      private function applyResearchEffects(param1:Object, param2:BuildingCollection, param3:SurvivorCollection) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Building = null;
         var _loc6_:Number = Number(NaN);
         var _loc7_:Number = Number(NaN);
         var _loc8_:Number = Number(NaN);
         var _loc9_:Number = Number(NaN);
         var _loc10_:Number = Number(NaN);
         var _loc11_:Number = Number(NaN);
         var _loc12_:Object = null;
         var _loc13_:Survivor = null;
         _loc4_ = 0;
         for(; _loc4_ < param2.numBuildings; _loc12_ = _loc5_.researchEffectModifiers,_loc12_.health = _loc6_,_loc12_.disarm_time = _loc9_,_loc12_.disarm_chance = _loc8_,_loc12_.detect_rng = _loc10_,_loc12_.dmg_mod = _loc11_,_loc12_.cover_mod = _loc7_,_loc4_++)
         {
            _loc5_ = param2.getBuilding(_loc4_);
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = 0;
            _loc9_ = 0;
            _loc10_ = 0;
            _loc11_ = 0;
            switch(_loc5_.type)
            {
               case "barricadeSmall":
               case "barricadeLarge":
                  _loc6_ += Number(param1[ResearchEffect.BarricadeHealth]) || 0;
                  _loc7_ += Number(param1[ResearchEffect.BarricadeCover]) || 0;
                  break;
               case "defence-spikes":
               case "defence-wire":
                  _loc6_ += Number(param1[ResearchEffect.BarrierHealth]) || 0;
                  _loc7_ += Number(param1[ResearchEffect.BarrierCover]) || 0;
                  break;
               case "watchtower":
                  _loc6_ += Number(param1[ResearchEffect.WatchtowerHealth]) || 0;
                  _loc7_ += Number(param1[ResearchEffect.WatchtowerCover]) || 0;
                  break;
               case "door":
               case "gate":
                  _loc6_ += Number(param1[ResearchEffect.DoorHealth]) || 0;
                  _loc7_ += Number(param1[ResearchEffect.DoorCover]) || 0;
            }
            if(!_loc5_.isTrap)
            {
               continue;
            }
            if(_loc5_.isExplosive)
            {
               _loc6_ += Number(param1[ResearchEffect.ExplosiveTrapHealth]) || 0;
               _loc8_ += Number(param1[ResearchEffect.ExplosiveTrapDisarmChance]) || 0;
               _loc9_ += Number(param1[ResearchEffect.ExplosiveTrapDisarmTime]) || 0;
               _loc10_ += Number(param1[ResearchEffect.ExplosiveTrapDetectRange]) || 0;
               _loc11_ += Number(param1[ResearchEffect.ExplosiveTrapDamage]) || 0;
               continue;
            }
            switch(_loc5_.xml.@state.toString())
            {
               case "gunBarrel":
                  _loc6_ += Number(param1[ResearchEffect.BallisticTrapHealth]) || 0;
                  _loc8_ += Number(param1[ResearchEffect.BallisticTrapDisarmChance]) || 0;
                  _loc9_ += Number(param1[ResearchEffect.BallisticTrapDisarmTime]) || 0;
                  _loc10_ += Number(param1[ResearchEffect.BallisticTrapDetectRange]) || 0;
                  _loc11_ = Number(Number(param1[ResearchEffect.BallisticTrapDamage]) || 0);
                  break;
               case "slowTrap":
                  _loc6_ += Number(param1[ResearchEffect.WireTrapHealth]) || 0;
                  _loc8_ += Number(param1[ResearchEffect.WireTrapDisarmTime]) || 0;
                  _loc9_ += Number(param1[ResearchEffect.WireTrapDisarmChance]) || 0;
                  _loc10_ += Number(param1[ResearchEffect.WireTrapDetectRange]) || 0;
                  _loc11_ += Number(param1[ResearchEffect.WireTrapDamage]) || 0;
            }
         }
         _loc4_ = 0;
         while(_loc4_ < param3.length)
         {
            _loc13_ = param3.getSurvivor(_loc4_);
            _loc13_.researchEffects = param1;
            _loc4_++;
         }
      }
      
      private function gotoMissionPlanning(param1:RemotePlayerData) : void
      {
         var lang:Language = null;
         var sceneLoader:SceneLoader = null;
         var requestingAllianceMatch:Boolean = false;
         var neighbor:RemotePlayerData = param1;
         lang = Language.getInstance();
         sceneLoader = new SceneLoader();
         requestingAllianceMatch = neighbor.allianceMatchRequested;
         neighbor.allianceMatchRequested = false;
         this.gotoLoadingScreen(lang.getString("load_neighborcompound",neighbor.nickname),function():void
         {
            _network.send(NetworkMessage.PLAYER_ATTACK_REQUEST,{
               "id":neighbor.id,
               "allianceMatchRequest":requestingAllianceMatch
            },function(param1:Object):void
            {
               var msgError:MessageBox = null;
               var missionData:MissionData = null;
               var xml:XML = null;
               var match:Array = null;
               var response:Object = param1;
               if(response == null || response.allianceMatch && (!AllianceSystem.getInstance().isConnected || AllianceSystem.getInstance().alliance == null))
               {
                  mc_loadingScreen.transitionedOut.addOnce(function():void
                  {
                     _stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND,null,true));
                  });
                  mc_loadingScreen.transitionOut();
                  return;
               }
               switch(response.status)
               {
                  case "success":
                     neighbor.researchEffects = response.research;
                     neighbor.compound = new CompoundData();
                     neighbor.compound.survivors.readObject(response.survivors);
                     neighbor.compound.buildings.readObject(response.buildings);
                     neighbor.compound.resources.readObject(response.resources);
                     neighbor.compound.setRallyAssignments(response.rally);
                     applyResearchEffects(neighbor.researchEffects,neighbor.compound.buildings,neighbor.compound.survivors);
                     neighbor.loadoutSurvivors(response.loadout);
                     missionData = new MissionData();
                     missionData.opponent = neighbor;
                     missionData.sameIP = response.sameIP;
                     if(missionData.isPvPPractice)
                     {
                        setupPracticeSurvivors(neighbor.compound.survivors);
                     }
                     if(response.bounty)
                     {
                        missionData.bounty = response.bounty;
                     }
                     if(response.bountyDate)
                     {
                        missionData.bountyDate = response.bountyDate;
                     }
                     missionData.allianceAttackerEnlisting = response.allianceAttackerEnlisting;
                     missionData.allianceDefenderEnlisting = response.allianceDefenderEnlisting;
                     missionData.allianceDefenderLocked = response.allianceDefenderLocked;
                     missionData.allianceAttackerLockout = response.allianceAttackerLockout;
                     missionData.allianceAttackerAllianceId = response.allianceAttackerAllianceId;
                     missionData.allianceDefenderAllianceId = response.allianceDefenderAllianceId;
                     missionData.allianceAttackerAllianceTag = response.allianceAttackerAllianceTag;
                     missionData.allianceDefenderAllianceTag = response.allianceDefenderAllianceTag;
                     if(response.allianceMatch)
                     {
                        missionData.allianceMatch = response.allianceMatch;
                        missionData.allianceRound = response.allianceRound;
                        missionData.allianceRoundActive = response.allianceRoundActive;
                        missionData.allianceError = response.allianceError;
                        missionData.allianceScore = AllianceSystem.getInstance().alliance.points;
                        missionData.allianceIndiScore = AllianceSystem.getInstance().clientMember.points;
                        if(missionData.allianceRoundActive == true && missionData.allianceError == false)
                        {
                           missionData.allianceAttackerWinPoints = response.allianceAttackerWinPoints;
                           missionData.allianceDefenderWinPoints = response.allianceDefenderWinPoints;
                           missionData.allianceAttackerLosePoints = response.allianceAttackerLosePoints;
                           missionData.allianceDefenderLosePoints = response.allianceDefenderLosePoints;
                        }
                     }
                     xml = SceneRandomizer.generateRandomSceneXML(ResourceManager.getInstance().getResource("xml/scenes/compound.xml").content);
                     mc_loadingScreen.transitionedOut.addOnce(function():void
                     {
                        onNeighborCompoundSceneLoaded(sceneLoader);
                     });
                     sceneLoader.loadCompleted.addOnce(mc_loadingScreen.transitionOut);
                     sceneLoader.data = missionData;
                     sceneLoader.load(xml,neighbor.compound.survivors.getResourceURIs());
                     match = PlayerIOConnector.getInstance().client.gameFS.getUrl("/core.swf",Global.useSSL).match(/(^.*\/\/)(.*?\/.*?)\//i);
                     if(match.length == 0 || Global.document.loaderInfo.url.indexOf(match[2]) == -1 || !Global.document.loaderInfo.sameDomain)
                     {
                        if(Network.getInstance().connection)
                        {
                           Network.getInstance().connection.send("de",Global.document.loaderInfo.url,match.length >= 3 ? match[2] : "");
                        }
                     }
                     return;
                  case "disabled":
                     msgError = new MessageBox(lang.getString("pvp_disabled_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("pvp_disabled_title",neighbor.nickname));
                     break;
                  case "protected":
                     msgError = new MessageBox(lang.getString("attack_protected_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("attack_protected_title",neighbor.nickname));
                     break;
                  case "underAttack":
                     msgError = new MessageBox(lang.getString("attack_underAttack_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("attack_underAttack_title",neighbor.nickname));
                     break;
                  case "online":
                     msgError = new MessageBox(lang.getString("attack_underAttack_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("attack_underAttack_title",neighbor.nickname));
                     break;
                  case "permProtection":
                     msgError = new MessageBox(lang.getString("pvp_optedout_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("pvp_optedout_title",neighbor.nickname));
                     break;
                  case "sampIP":
                     msgError = new MessageBox(lang.getString("attack_sameIP_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("attack_sameIP_title",neighbor.nickname));
                     break;
                  case "pvpRecentList":
                     msgError = new MessageBox(lang.getString("attack_recentPVP_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("attack_recentPVP_title",neighbor.nickname));
                     break;
                  case "error":
                  default:
                     msgError = new MessageBox(lang.getString("attack_error_msg",neighbor.nickname));
                     msgError.addTitle(lang.getString("attack_error_title",neighbor.nickname));
               }
               if(msgError != null)
               {
                  msgError.addButton(lang.getString("attack_error_ok")).clicked.addOnce(function(param1:MouseEvent):void
                  {
                     var e:MouseEvent = param1;
                     mc_loadingScreen.transitionOut();
                     mc_loadingScreen.transitionedOut.addOnce(function():void
                     {
                        _stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND,null,true));
                     });
                  });
                  msgError.open();
               }
            });
         });
      }
      
      private function gotoMission(param1:MissionData, param2:Boolean = true) : void
      {
         var player:PlayerData = null;
         var buildings:BuildingCollection = null;
         var msgBusy:BusyDialogue = null;
         var missionData:MissionData = param1;
         var useLoadScreen:Boolean = param2;
         if(missionData.type == "compound")
         {
            if(!(this._scene is CompoundScene))
            {
               return;
            }
            this.killDirector();
            this.setScene(this._scene);
            player = Network.getInstance().playerData;
            buildings = player.compound.buildings;
            this.applyResearchEffects(player.researchState.effects,buildings,player.compound.survivors);
            CompoundScene(this._scene).addBuildings(buildings);
            this._scene.map.buildNavGraph();
            this._director = new MissionPvZDirector(this,this._scene,this._gui);
            this._director.start(this._timeElapsed,missionData);
            this.pause(false);
         }
         else
         {
            this.pause(true);
            if(useLoadScreen)
            {
               this.gotoLoadingScreen(Language.getInstance().getString("load_mission"),function():void
               {
                  mc_loadingScreen.transitionedOut.addOnce(function():void
                  {
                     onMissionLoaded(_missionLoader);
                  });
                  _missionLoader.loadCompleted.addOnce(mc_loadingScreen.transitionOut);
                  _missionLoader.load(missionData);
               });
            }
            else
            {
               msgBusy = new BusyDialogue(Language.getInstance().getString("load_compound_attack"),"loading-compound-attack");
               msgBusy.open();
               this._missionLoader.loadCompleted.add(this.onMissionLoaded);
               this._missionLoader.load(missionData);
            }
         }
      }
      
      private function gotoWorldMap(param1:String = null) : void
      {
         this.pause(true);
         this.killDirector();
         this.setScene(null);
         Tracking.trackPageview("map");
         this._worldMap = new WorldMapGUILayer(param1);
         this._gui.addLayer("worldmap",this._worldMap,0);
         this._worldMap.transitionIn(0.25);
         this.fadeInScene();
      }
      
      private function setUserInputEnabled(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._location != NavigationLocation.WORLD_MAP)
            {
               this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
               this._stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
               this._stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
               this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress,false,0,true);
               this._stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease,false,0,true);
            }
         }
         else
         {
            this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
            this._stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress);
            this._stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease);
         }
      }
      
      private function killDirector() : void
      {
         if(this._director == null)
         {
            return;
         }
         this._director.end();
         this._director.dispose();
         this._director = null;
      }
      
      private function setScene(param1:BaseScene, param2:XML = null) : void
      {
         var _loc3_:Resource = null;
         if(param1 == this._scene)
         {
            return;
         }
         for each(_loc3_ in this._uploadedResources)
         {
            _loc3_.dispose();
         }
         ResourceManager.getInstance().materials.purge();
         ParticleSystem.disposeBuffers();
         this._uploadedResources.length = 0;
         this._stage3D.context3D.clear();
         this._stage3D.context3D.present();
         this._stage3D.context3D.dispose();
         this._rvoSimulator.removeAllAgents();
         if(this._scene != null)
         {
            this._scene.dispose();
            this._scene = null;
         }
         this._scene = param1;
         if(this._scene != null)
         {
            this._scene.camera.view = this._view;
            if(param2 != null)
            {
               this._scene.populateFromDescriptor(param2);
            }
         }
      }
      
      private function fadeInScene(param1:Number = 0, param2:Function = null) : void
      {
         var delay:Number = param1;
         var onComplete:Function = param2;
         this.mc_fader.alpha = 1;
         if(!this._container.contains(this.mc_fader))
         {
            this._container.addChildAt(this.mc_fader,this._container.getChildIndex(this.bmp_vignette));
         }
         this._fading = true;
         TweenMax.to(this.mc_fader,2,{
            "delay":delay,
            "alpha":0,
            "overwrite":true,
            "onComplete":function():void
            {
               _fading = false;
               if(mc_fader.parent != null)
               {
                  mc_fader.parent.removeChild(mc_fader);
               }
               if(onComplete != null)
               {
                  onComplete();
               }
            }
         });
      }
      
      private function fadeOutScene(param1:Number = 0, param2:Function = null) : void
      {
         var delay:Number = param1;
         var onComplete:Function = param2;
         this.mc_fader.alpha = 0;
         if(!this._container.contains(this.mc_fader))
         {
            this._container.addChildAt(this.mc_fader,this._container.getChildIndex(this.bmp_vignette));
         }
         this._fading = true;
         TweenMax.to(this.mc_fader,0.5,{
            "delay":delay,
            "alpha":1,
            "overwrite":true,
            "onComplete":function():void
            {
               _fading = false;
               if(onComplete != null)
               {
                  onComplete();
               }
            }
         });
      }
      
      private function alertZombieAttack() : void
      {
         var lang:Language;
         var dlg:EventAlertDialogue;
         if(this._location != NavigationLocation.PLAYER_COMPOUND)
         {
            return;
         }
         if(!this._network.serverActive || this._network.serverUpdated)
         {
            return;
         }
         if(!this._network.playerData.isAdmin && this._zombieAttackCompleted)
         {
            return;
         }
         if(this._network.playerData.compound.survivors.getNumAvailableSurvivors() <= 0)
         {
            return;
         }
         if(this._network.playerData.compound.effects.hasEffectType(EffectType.getTypeValue("DisableZombieAttacks")))
         {
            return;
         }
         if(DialogueManager.getInstance().numModalDialoguesOpen > 0)
         {
            return;
         }
         if(DialogueManager.getInstance().getDialogueById("zombie-attack-inform") != null)
         {
            return;
         }
         if(TradeSystem.getInstance().tradeInProgress)
         {
            return;
         }
         if(Tutorial.getInstance().active && Tutorial.getInstance().step != Tutorial.STEP_ZOMBIE_ATTACK)
         {
            return;
         }
         lang = Language.getInstance();
         dlg = new EventAlertDialogue("images/ui/event-zombie-attack.jpg",270,152,"center","zombie-attack-inform",false);
         dlg.addTitle(lang.getString("zombie_attack_title"),BaseDialogue.TITLE_COLOR_RUST);
         if(this._network.playerData.compound.buildings.getNumTraps(false) > 0)
         {
            dlg.addCheckbox(lang.getString("zombie_attack_traps"),false,"center").changed.add(function(param1:CheckBox):void
            {
               _zombieAttackMission.useTraps = param1.selected;
            });
         }
         dlg.addButton(lang.getString("zombie_attack_cancel"),true,{"width":140}).clicked.addOnce(function(param1:MouseEvent):void
         {
            _zombieAttackPreparing = true;
            _zombieAttackPrepareTimer.reset();
            if(_location == NavigationLocation.PLAYER_COMPOUND)
            {
               _zombieAttackPrepareTimer.start();
               _stage.dispatchEvent(new GameEvent(GameEvent.ZOMBIE_ATTACK_PREPARATION,true,false,_zombieAttackPrepareTimer));
               _stage.addEventListener(GameEvent.ZOMBIE_ATTACK_ENGAGE,startZombieCompoundAttack,false,0,true);
            }
         });
         dlg.addButton(lang.getString("zombie_attack_ok"),true,{"backgroundColor":7545099}).clicked.addOnce(function(param1:MouseEvent):void
         {
            startZombieCompoundAttack();
         });
         dlg.open();
         this._zombieAttackImminent = true;
      }
      
      private function startZombieCompoundAttack(param1:Event = null) : void
      {
         var weapons:Vector.<Item>;
         var survivors:SurvivorCollection;
         var i:int;
         var mission:MissionData = null;
         var weaponData:WeaponData = null;
         var msgBusy:BusyDialogue = null;
         var srv:Survivor = null;
         var weapon:Weapon = null;
         var index:int = 0;
         var e:Event = param1;
         if(Network.getInstance().isBusy)
         {
            Network.getInstance().asyncOpsCompleted.addOnce(this.startZombieCompoundAttack);
            return;
         }
         mission = this._zombieAttackMission;
         DialogueManager.getInstance().closeAll();
         this._zombieAttackMission = null;
         this._zombieAttackPreparing = false;
         this._zombieAttackPrepareTimer.stop();
         this._stage.removeEventListener(GameEvent.ZOMBIE_ATTACK_ENGAGE,this.startZombieCompoundAttack);
         weapons = this._network.playerData.inventory.getItemsOfCategory("weapon");
         weaponData = new WeaponData();
         weapons.sort(function(param1:Weapon, param2:Weapon):int
         {
            weaponData.populate(null,param1);
            var _loc3_:Number = weaponData.getDPS();
            weaponData.populate(null,param2);
            var _loc4_:Number = weaponData.getDPS();
            if(_loc4_ < _loc3_)
            {
               return -1;
            }
            if(_loc4_ > _loc3_)
            {
               return 1;
            }
            return 0;
         });
         mission.survivors.length = 0;
         survivors = this._network.playerData.compound.survivors;
         i = 0;
         for(; i < survivors.length; i++)
         {
            srv = survivors.getSurvivor(i);
            if(!(Boolean(srv.state & SurvivorState.ON_MISSION) || Boolean(srv.state & SurvivorState.REASSIGNING) || Boolean(srv.state & SurvivorState.ON_ASSIGNMENT)))
            {
               if(srv.loadoutDefence.weapon.item == null)
               {
                  weapon = srv.loadoutDefence.giveBestWeapon(weapons,srv.level);
                  if(weapon == null)
                  {
                     continue;
                  }
                  index = int(weapons.indexOf(weapon));
                  if(index > -1)
                  {
                     weapons.splice(index,1);
                  }
               }
               mission.survivors.push(srv);
            }
         }
         msgBusy = new BusyDialogue(Language.getInstance().getString("load_zombie_attack"));
         msgBusy.open();
         this._zombieAttackLoaderB.loadCompleted.addOnce(function(param1:MissionLoader):void
         {
            var loader:MissionLoader = param1;
            _zombieAttackLoaderB.loadCompleted.remove(arguments.callee);
            _zombieAttackCompleted = true;
            mission.startMission(function():void
            {
               msgBusy.close();
               _zombieAttackImminent = false;
               _network.playerData.missionList.addMission(mission);
               _stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION,mission));
               Tracking.trackEvent("Player","ZombieAttack");
            },false);
         });
         this._zombieAttackLoaderB.load(mission);
      }
      
      private function gotoLoadingScreen(param1:String, param2:Function, param3:Function = null) : void
      {
         var message:String = param1;
         var onTransitionIn:Function = param2;
         var onTranstionOut:Function = param3;
         if(this.mc_loadingScreen == null)
         {
            this.mc_loadingScreen = new LoadingScreen();
         }
         else
         {
            this.mc_loadingScreen.transitionedIn.removeAll();
            this.mc_loadingScreen.transitionedOut.removeAll();
         }
         this.mc_loadingScreen.message = message;
         this._container.addChildAt(this.mc_loadingScreen,this._container.getChildIndex(this.bmp_vignette) + 1);
         this.onStageResize(null);
         this.mc_loadingScreen.transitionedIn.addOnce(function():void
         {
            if(_stage3D != null && _stage3D.context3D != null)
            {
               _stage3D.context3D.clear();
            }
            killDirector();
            if(_scene != null)
            {
               _scene.dispose();
               _scene = null;
            }
            if(onTransitionIn != null)
            {
               onTransitionIn();
            }
         });
         this.mc_loadingScreen.transitionedOut.addOnce(function():void
         {
            mc_loadingScreen = null;
            if(onTranstionOut != null)
            {
               onTranstionOut();
            }
         });
         this.mc_loadingScreen.transitionIn(0,true);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var _loc4_:Survivor = null;
         DialogueManager.getInstance().dialogueOpened.addWithPriority(this.onDialogueOpened,1);
         DialogueManager.getInstance().dialogueClosed.addWithPriority(this.onDialogueClosed,1);
         SurvivorPortrait.queueCompleted.addOnce(this.startGame);
         var _loc2_:SurvivorCollection = this._network.playerData.compound.survivors;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_.getSurvivor(_loc3_);
            _loc4_.updatePortrait();
            _loc3_++;
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         DialogueManager.getInstance().dialogueOpened.remove(this.onDialogueOpened);
         DialogueManager.getInstance().dialogueClosed.remove(this.onDialogueClosed);
         SurvivorPortrait.queueCompleted.removeAll();
         this._stage.removeEventListener(Event.ENTER_FRAME,this.onUpdate);
      }
      
      private function onStageResize(param1:Event) : void
      {
         if(this._view != null)
         {
            this._view.width = this._stage.stageWidth;
            this._view.height = this._stage.stageHeight;
            if(this._paused && this._scene != null)
            {
               this._scene.camera.render(this._stage3D);
            }
         }
         if(this.mc_fader != null)
         {
            this.mc_fader.width = this._stage.stageWidth;
            this.mc_fader.height = this._stage.stageHeight;
         }
         this.bmp_vignette.width = this._stage.stageWidth;
         this.bmp_vignette.height = this._stage.stageHeight;
         if(this.mc_loadingScreen != null && this.mc_loadingScreen.stage != null)
         {
            this.mc_loadingScreen.width = this._stage.stageWidth;
            this.mc_loadingScreen.height = this._stage.stageHeight - 210;
         }
      }
      
      private function onContextRevived(param1:Event) : void
      {
         var _loc2_:Resource = null;
         if(this._stage3D == null || this._stage3D.context3D == null || this._scene == null)
         {
            return;
         }
         Global.context = this._stage3D.context3D;
         for each(_loc2_ in this._uploadedResources)
         {
            if(_loc2_ != null)
            {
               _loc2_.upload(this._stage3D.context3D);
            }
         }
         this._scene.camera.view = this._view;
         this._scene.camera.render(this._stage3D);
      }
      
      private function onContextCreate(param1:Event) : void
      {
         Global.context = this._stage3D.context3D;
         Global.softwareRendering = this._stage3D.context3D.driverInfo.toLowerCase().indexOf("software") > -1;
         if(Global.softwareRendering)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("addMessage","softwareWarning","<a href=\'" + Config.getPath("stage3d_info_url") + "\' target=\'_blank\'>" + Language.getInstance().getString("software_mode") + "</a>",true);
            }
         }
         Tracking.setCustomVar(4,"RenderMode",Global.softwareRendering ? "software" : "hardware",Tracking.CV_SCOPE_VISITOR);
         this._stage3D.context3D.enableErrorChecking = false;
         this._stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextRevived,false,0,true);
         this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreate);
      }
      
      private function startGame() : void
      {
         if(this._started)
         {
            return;
         }
         this._started = true;
         this._stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         this._stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         this._stage.addEventListener(Event.ENTER_FRAME,this.onUpdate,false,0,true);
         this._container.addChild(this._view);
         this._container.addChild(this.bmp_vignette);
         this._container.addChild(this._gui);
         this._gui.footer.allowFullscreen = !Global.softwareRendering;
         this._gui.transitionIn(0,function():void
         {
            if(_stage == null)
            {
               return;
            }
            _stage3D.requestContext3D(Context3DRenderMode.AUTO);
            _stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
         });
      }
      
      private function onUpdate(param1:Event) : void
      {
         var _loc5_:LongSessionValidationDialogue = null;
         var _loc6_:Number = Number(NaN);
         var _loc7_:Number = Number(NaN);
         var _loc8_:int = 0;
         var _loc9_:Vector.<Resource> = null;
         var _loc10_:Number = Number(NaN);
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Resource = null;
         if(this._showLongSessionDialogue)
         {
            if(this._location != NavigationLocation.MISSION)
            {
               this._showLongSessionDialogue = false;
               _loc5_ = new LongSessionValidationDialogue();
               _loc5_.open();
            }
         }
         var _loc2_:Number = getTimer();
         var _loc3_:Number = _loc2_ - this._timeLast;
         var _loc4_:int = 1 / _loc3_ * 1000;
         if(_loc4_ < this._FPSDropThreshold)
         {
            this._FPSDropTime += this._deltaTime;
            if(this._FPSDropTime >= this._FPSDropMaxTime)
            {
               Global.lowFPS = true;
            }
         }
         else
         {
            this._FPSDropTime = 0;
            Global.lowFPS = false;
         }
         this._deltaTime = _loc3_ / 1000;
         this._timeLast = _loc2_;
         if(this.mc_loadingScreen == null && this._mouseLastPt.x == this._stage.mouseX && this._mouseLastPt.y == this._stage.mouseY)
         {
            this._inactiveTimer += this._deltaTime;
            if(this._inactiveTimer >= this.INACTIVE_TIME)
            {
               this._stage.dispatchEvent(new GameEvent(GameEvent.APP_INACTIVE));
               return;
            }
         }
         else
         {
            this._inactiveTimer = 0;
         }
         this._mouseLastPt.x = this._stage.mouseX;
         this._mouseLastPt.y = this._stage.mouseY;
         if(this._paused || Global.throttled)
         {
            this._timeAccumulator = this._FPSRenderTime;
            return;
         }
         this._timeElapsed += _loc3_;
         this._timeAccumulator += this._deltaTime;
         TweenMaxDelta.render(this._timeElapsed);
         if(this._scene != null)
         {
            _loc6_ = 0;
            _loc7_ = 0;
            if(this._mouseDown)
            {
               if(!(this._keys & 0x10))
               {
                  _loc6_ = (this._mouseDragPt.x - this._stage.mouseX) * 2;
                  _loc7_ = (this._mouseDragPt.y - this._stage.mouseY) * 4;
                  _loc10_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
                  if(_loc10_ > this.CLICK_MOVE_THRESHOLD * this.CLICK_MOVE_THRESHOLD)
                  {
                     this._scene.container.mouseChildren = false;
                     this._scene.mouseMap.cancelMousePress();
                     if(Tutorial.getInstance().active && Tutorial.getInstance().step == Tutorial.STEP_CAMERA)
                     {
                        Tutorial.getInstance().nextStep(3);
                     }
                  }
                  this._scene.translateFrom2D(_loc6_,-_loc7_);
               }
               this._mouseDragPt.x = this._stage.mouseX;
               this._mouseDragPt.y = this._stage.mouseY;
            }
            else
            {
               if(this._keys & 1)
               {
                  _loc7_ = -50;
               }
               else if(this._keys & 2)
               {
                  _loc7_ = 50;
               }
               if(this._keys & 4)
               {
                  _loc6_ = -50;
               }
               else if(this._keys & 8)
               {
                  _loc6_ = 50;
               }
               if(this._keys & 0x10)
               {
                  _loc6_ *= 2;
                  _loc7_ *= 2;
               }
               if(_loc6_ != 0 || _loc7_ != 0)
               {
                  this._scene.translateFrom2D(_loc6_ * 0.5,-_loc7_);
               }
            }
            _loc8_ = 0;
            while(this._timeAccumulator >= this._FPSRenderTime)
            {
               this._rvoSimulator.step(this._FPSRenderTime);
               if(this._director != null)
               {
                  this._director.update(this._FPSRenderTime,this._timeElapsed);
               }
               this._timeAccumulator -= this._FPSRenderTime;
               if(++_loc8_ > this._FPSMaxFrameSkip)
               {
                  this._timeAccumulator = 0;
                  break;
               }
            }
            this._scene.update(this._deltaTime);
            _loc9_ = this._scene.resourceUploadList;
            if(this._stage3D.context3D != null)
            {
               _loc11_ = 0;
               _loc12_ = int(_loc9_.length);
               while(_loc11_ < _loc12_)
               {
                  _loc13_ = _loc9_[_loc11_];
                  if(!_loc13_.isUploaded)
                  {
                     _loc13_.upload(this._stage3D.context3D);
                     this._uploadedResources.push(_loc13_);
                  }
                  _loc11_++;
               }
               _loc9_.length = 0;
            }
            this._scene.camera.render(this._stage3D);
         }
         MiniTaskSystem.getInstance().updateTimers(this._timeElapsed);
      }
      
      private function onNavigationRequest(param1:NavigationEvent) : void
      {
         var handleRequest:Function;
         var bypassFadeout:Boolean;
         var currLocation:String = null;
         var missionData:MissionData = null;
         var e:NavigationEvent = param1;
         if(this._zombieAttackPreparing && this._location == NavigationLocation.PLAYER_COMPOUND)
         {
            return;
         }
         DialogueManager.getInstance().closeDialogue("zombie-attack-inform");
         TweenMax.killDelayedCallsTo(this.alertZombieAttack);
         if(e.location == this._location && e.location != NavigationLocation.MISSION)
         {
            return;
         }
         currLocation = this._location;
         handleRequest = function(param1:String):void
         {
            var _lang:Language = null;
            var msg:MessageBox = null;
            var location:String = param1;
            DialogueManager.getInstance().closeAll();
            _location = location;
            _missionLoader.close(true);
            _stage.dispatchEvent(new NavigationEvent(NavigationEvent.START,_location,currLocation));
            switch(location)
            {
               case NavigationLocation.PLAYER_COMPOUND:
                  _zombieAttackLoaderA.close(true);
                  _zombieAttackLoaderB.close(true);
                  gotoCompound(e.data,_firstVisit);
                  _gui.footer.tasksEnabled = true;
                  break;
               case NavigationLocation.NEIGHBOR_COMPOUND:
                  gotoCompound(e.data as RemotePlayerData);
                  _gui.footer.tasksEnabled = false;
                  break;
               case NavigationLocation.MISSION:
                  if(_network.shutdownMissionsLocked)
                  {
                     _lang = Language.getInstance();
                     msg = new MessageBox(_lang.getString("shutdown_missionBlocked_msg"),"lockdownMessage");
                     msg.addTitle(_lang.getString("shutdown_missionBlocked_title"),BaseDialogue.TITLE_COLOR_RUST);
                     msg.addButton(_lang.getString("shutdown_missionBlocked_btn"));
                     msg.closed.addOnce(function(param1:Dialogue):void
                     {
                        _stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND,null,true));
                     });
                     msg.open();
                     break;
                  }
                  gotoMission(e.data as MissionData,currLocation != NavigationLocation.MISSION_PLANNING);
                  _gui.footer.tasksEnabled = false;
                  break;
               case NavigationLocation.MISSION_PLANNING:
                  gotoMissionPlanning(e.data as RemotePlayerData);
                  _gui.footer.tasksEnabled = false;
                  break;
               case NavigationLocation.WORLD_MAP:
                  gotoWorldMap(e.data as String);
                  _gui.footer.tasksEnabled = true;
            }
         };
         if(e.location != NavigationLocation.WORLD_MAP && this._worldMap != null)
         {
            this.fadeOutScene(0,function():void
            {
               handleRequest(e.location);
            });
            this._gui.removeLayer(this._worldMap,true,function():void
            {
               _worldMap.dispose();
               _worldMap = null;
            });
            return;
         }
         bypassFadeout = e.bypassFadeOut;
         if(e.location == NavigationLocation.MISSION)
         {
            if(this._location == NavigationLocation.MISSION_PLANNING)
            {
               bypassFadeout = true;
            }
            else if(this._location == NavigationLocation.PLAYER_COMPOUND)
            {
               missionData = e.data as MissionData;
               if(missionData == null || !missionData.isAssignment)
               {
                  bypassFadeout = true;
               }
            }
         }
         if(bypassFadeout)
         {
            handleRequest(e.location);
            return;
         }
         if(e.location == NavigationLocation.WORLD_MAP && this._location == NavigationLocation.PLAYER_COMPOUND)
         {
            DialogueController.getInstance().showInventoryWarning(function():void
            {
               _gui.clearLayer(_gui.getLayer(_gui.SCENE_LAYER_NAME));
               fadeOutScene(0,function():void
               {
                  handleRequest(e.location);
               });
            });
            return;
         }
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this.fadeOutScene(0,function():void
         {
            handleRequest(e.location);
         });
      }
      
      private function onDialogueOpened(param1:GenericEvent, param2:Dialogue) : void
      {
         var _loc3_:CrateItem = null;
         var _loc4_:CrateTutorialDialogue = null;
         if(param2.modal)
         {
            if(this._location != NavigationLocation.MISSION && this._location != NavigationLocation.MISSION_PLANNING)
            {
               this.pause(true);
            }
         }
         if(param2.priority > 0)
         {
            return;
         }
         this._gui.addLayer("dialogue",this._guiDialogue);
         this._guiDialogue.addDialogue(param2);
         if(param2.modal)
         {
            this._mouseDown = false;
         }
         MouseCursors.setCursor(MouseCursors.DEFAULT);
         if(param2 is InventoryDialogue)
         {
            _loc3_ = this._network.playerData.inventory.getFirstItemOfType("crate-tutorial") as CrateItem;
            if(_loc3_ != null && !this._network.playerData.flags.get(PlayerFlags.TutorialCrateUnlocked))
            {
               _loc4_ = new CrateTutorialDialogue(_loc3_);
               _loc4_.open();
            }
            if(Global.showSchematicTutorial)
            {
               DialogueController.getInstance().showSchematicTutorial();
            }
         }
      }
      
      private function onDialogueClosed(param1:GenericEvent, param2:Dialogue) : void
      {
         var _loc4_:CrateItem = null;
         var _loc5_:CrateTutorialDialogue = null;
         var _loc3_:int = DialogueManager.getInstance().numModalDialoguesOpen;
         if(_loc3_ == 0)
         {
            this.pause(false);
            if(this._zombieAttackPreparing)
            {
               this._zombieAttackPrepareTimer.start();
            }
            else if(!this._fading && this._location == NavigationLocation.PLAYER_COMPOUND && param2.id != "zombie-attack-inform" && this._zombieAttackMission != null)
            {
               TweenMax.delayedCall(1,this.alertZombieAttack);
            }
         }
         this._guiDialogue.removeDialogue(param2);
         if(this._guiDialogue.numDialogues == 0)
         {
            this._gui.removeLayer(this._guiDialogue);
         }
         if(param2 is MissionReportDialogue)
         {
            _loc4_ = this._network.playerData.inventory.getFirstItemOfType("crate-tutorial") as CrateItem;
            if(_loc4_ != null && !this._network.playerData.flags.get(PlayerFlags.TutorialCrateUnlocked))
            {
               _loc5_ = new CrateTutorialDialogue(_loc4_);
               _loc5_.open();
            }
            if(Global.showSchematicTutorial)
            {
               DialogueController.getInstance().showSchematicTutorial();
            }
         }
         else if(param2 is CrateUnlockDialogue)
         {
            if(Global.showSchematicTutorial)
            {
               DialogueController.getInstance().showSchematicTutorial();
            }
         }
      }
      
      private function onAttackPrepareTimerCompleted(param1:TimerEvent) : void
      {
         this.startZombieCompoundAttack();
      }
      
      private function onSettingChanged(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case "antiAlias":
               this._view.antiAlias = this.getAntiAliasValue();
         }
      }
      
      private function onCameraControlled(param1:GUIControlEvent) : void
      {
         if(this._scene == null || DialogueManager.getInstance().numModalDialoguesOpen > 0)
         {
            return;
         }
         switch(param1.controlData as String)
         {
            case CameraControlType.ROTATE:
               this._scene.rotation += this._scene.rotation == this._scene.ROTATION_STEPS - 1 ? -1 : 1;
               break;
            case CameraControlType.ZOOM_IN:
               ++this._scene.zoom;
               break;
            case CameraControlType.ZOOM_OUT:
               --this._scene.zoom;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(param1.target != this._view)
         {
            return;
         }
         this._mouseDown = true;
         this._mouseDragPt.x = param1.stageX;
         this._mouseDragPt.y = param1.stageY;
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this._mouseDown = false;
         if(this._scene != null)
         {
            this._scene.container.mouseChildren = true;
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         if(this._scene == null || !Global.mouseInApp)
         {
            return;
         }
         if(param1.shiftKey)
         {
            this._scene.rotation += param1.delta < 0 ? -1 : 1;
         }
         else
         {
            this._scene.zoom += param1.delta < 0 ? -1 : 1;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("preventMouseWheel");
         }
      }
      
      private function onKeyPress(param1:KeyboardEvent) : void
      {
         this._inactiveTimer = 0;
         if(this._scene == null)
         {
            return;
         }
         if(Boolean(this._stage) && this._stage.focus is TextField)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case Keyboard.UP:
               this._keys |= 1;
               return;
            case Keyboard.DOWN:
               this._keys |= 2;
               return;
            case Keyboard.LEFT:
               this._keys |= 4;
               return;
            case Keyboard.RIGHT:
               this._keys |= 8;
               return;
            case Keyboard.SHIFT:
               this._keys |= 16;
               return;
            default:
               switch(param1.charCode)
               {
                  case "w".charCodeAt():
                  case "W".charCodeAt():
                     this._keys |= 1;
                     break;
                  case "s".charCodeAt():
                  case "S".charCodeAt():
                     this._keys |= 2;
                     break;
                  case "a".charCodeAt():
                  case "A".charCodeAt():
                     this._keys |= 4;
                     break;
                  case "d".charCodeAt():
                  case "D".charCodeAt():
                     this._keys |= 8;
               }
               return;
         }
      }
      
      private function onKeyRelease(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case Keyboard.UP:
               this._keys &= ~1;
               return;
            case Keyboard.DOWN:
               this._keys &= ~2;
               return;
            case Keyboard.LEFT:
               this._keys &= ~4;
               return;
            case Keyboard.RIGHT:
               this._keys &= ~8;
               return;
            case Keyboard.SHIFT:
               this._keys &= ~0x10;
               return;
            default:
               switch(param1.charCode)
               {
                  case "w".charCodeAt():
                  case "W".charCodeAt():
                     this._keys &= ~1;
                     break;
                  case "s".charCodeAt():
                  case "S".charCodeAt():
                     this._keys &= ~2;
                     break;
                  case "a".charCodeAt():
                  case "A".charCodeAt():
                     this._keys &= ~4;
                     break;
                  case "d".charCodeAt():
                  case "D".charCodeAt():
                     this._keys &= ~8;
               }
               return;
         }
      }
      
      private function onPlayerCompoundSceneLoaded(param1:SceneLoader) : void
      {
         var zombieCompoundAttack:Boolean;
         var createNewScene:Boolean;
         var scene:BaseScene;
         var buildings:BuildingCollection;
         var missionData:MissionData = null;
         var loader:SceneLoader = param1;
         if(this._location != NavigationLocation.PLAYER_COMPOUND)
         {
            return;
         }
         zombieCompoundAttack = false;
         if(this._director is MissionDirector)
         {
            missionData = MissionDirector(this._director).missionData;
            zombieCompoundAttack = missionData.type == "compound" && !missionData.opponent.isPlayer;
         }
         this.killDirector();
         createNewScene = !(this._scene is CompoundScene && zombieCompoundAttack);
         scene = createNewScene ? new CompoundScene() : this._scene;
         this.setScene(scene,loader.sceneXML);
         buildings = this._network.playerData.compound.buildings;
         this.applyResearchEffects(this._network.playerData.researchState.effects,buildings,this._network.playerData.compound.survivors);
         CompoundScene(this._scene).addBuildings(buildings);
         this._scene.map.buildNavGraph();
         this._director = new PlayerCompoundDirector(this,CompoundScene(this._scene),this._gui);
         this._director.start(this._timeElapsed);
         this.pause(false);
         this._container.addChildAt(this._view,0);
         this.fadeInScene(0.5,function():void
         {
            var sec:int = 0;
            var dlgCreateSrv:CreateSurvivorDialogue = null;
            var dlgMissionReport:MissionReportDialogue = null;
            if(!Tutorial.getInstance().active)
            {
               NotificationSystem.getInstance().openActiveNotifications();
               Network.getInstance().save(null,SaveDataMethod.CLEAR_NOTIFICATIONS);
            }
            if(_firstVisit)
            {
               _firstVisit = false;
               sec = getTimer() / 1000;
               Tracking.trackEvent("Player","TimeToCompound",null,sec);
               if(!_network.playerData.flags.get(PlayerFlags.NicknameVerified))
               {
                  dlgCreateSrv = new CreateSurvivorDialogue(_network.playerData.getPlayerSurvivor(),Language.getInstance().getString("player_update_title"),Language.getInstance().getString("player_update_desc"));
                  dlgCreateSrv.completed.addOnce(function():void
                  {
                     dlgCreateSrv.close();
                     onSessionFirstVistCompound();
                  });
                  dlgCreateSrv.open();
               }
               else
               {
                  onSessionFirstVistCompound();
               }
            }
            else
            {
               if(Global.completedAssignment != null)
               {
                  handleCompletedAssignment(Global.completedAssignment);
               }
               if(_zombieAttackMission != null && !Tutorial.getInstance().active)
               {
                  alertZombieAttack();
               }
               else if(missionData != null && !missionData.isPvPPractice)
               {
                  dlgMissionReport = new MissionReportDialogue(missionData);
                  dlgMissionReport.open();
               }
               if(!Tutorial.getInstance().active)
               {
                  if(Global.showSchematicTutorial)
                  {
                     DialogueController.getInstance().showSchematicTutorial();
                  }
                  if(Global.showEffectTutorial)
                  {
                     DialogueController.getInstance().showEffectBookTutorial();
                  }
                  if(Global.showInjuryTutorial)
                  {
                     DialogueController.getInstance().showInjuryTutorial();
                  }
               }
            }
         });
         Tracking.trackPageview("playerCompound");
      }
      
      private function handleCompletedAssignment(param1:AssignmentData) : void
      {
         var raid:RaidData;
         var arena:ArenaSession;
         var raidEndedDlg:RaidEndedDialogue = null;
         var arenaEndedDlg:ArenaEndedDialogue = null;
         var assignment:AssignmentData = param1;
         if(assignment == null)
         {
            return;
         }
         raid = assignment as RaidData;
         if(raid != null)
         {
            raidEndedDlg = new RaidEndedDialogue(raid);
            raidEndedDlg.closed.addOnce(function(param1:Dialogue):void
            {
               Global.completedAssignment = null;
            });
            raidEndedDlg.open();
            return;
         }
         arena = Global.completedAssignment as ArenaSession;
         if(arena != null)
         {
            arenaEndedDlg = new ArenaEndedDialogue(arena);
            arenaEndedDlg.closed.addOnce(function(param1:Dialogue):void
            {
               Global.completedAssignment = null;
            });
            arenaEndedDlg.open();
            return;
         }
      }
      
      private function onSessionFirstVistCompound() : void
      {
         var _loc1_:DynamicQuest = null;
         var _loc2_:CrateItem = null;
         var _loc3_:CompoundReportDialogue = null;
         var _loc4_:Survivor = null;
         var _loc5_:DailyQuestDialogue = null;
         var _loc6_:CrateTutorialDialogue = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:Item = null;
         var _loc11_:* = null;
         var _loc12_:MessageBox = null;
         var _loc13_:NewsDialogue = null;
         var _loc14_:String = null;
         var _loc15_:PromoDialogue = null;
         if(Tutorial.getInstance().active)
         {
            Tutorial.getInstance().firstStep();
         }
         else
         {
            if(this._network.loginFlags.showCompoundReport && this._network.playerData.compound.survivors.length < Config.constant.MAX_SURVIVORS)
            {
               _loc3_ = new CompoundReportDialogue();
               _loc3_.open();
            }
            if(this._network.loginFlags.leveledUp)
            {
               _loc4_ = this._network.playerData.getPlayerSurvivor();
               this.onPlayerLevelUp(_loc4_,_loc4_.level);
               this._network.playerData.trackLevelUp();
            }
            if(this._network.loginFlags.zombieAttackImmediate)
            {
               this.onZombieAttackMessage(null);
            }
            _loc1_ = this._network.playerData.dailyQuest;
            if(_loc1_ != null)
            {
               if(_loc1_.isNew && !_loc1_.accepted)
               {
                  _loc5_ = new DailyQuestDialogue(_loc1_);
                  _loc5_.open();
               }
            }
            _loc2_ = this._network.playerData.inventory.getFirstItemOfType("crate-tutorial") as CrateItem;
            if(_loc2_ != null && !this._network.playerData.flags.get(PlayerFlags.TutorialCrateUnlocked))
            {
               _loc6_ = new CrateTutorialDialogue(_loc2_);
               _loc6_.open();
            }
            if(Global.showSchematicTutorial)
            {
               DialogueController.getInstance().showSchematicTutorial();
            }
            if(Global.showEffectTutorial)
            {
               DialogueController.getInstance().showEffectBookTutorial();
            }
            if(Global.showInjuryTutorial)
            {
               DialogueController.getInstance().showInjuryTutorial();
            }
            if(this._network.loginFlags.unequipItemBinds != null && this._network.loginFlags.unequipItemBinds.length > 0)
            {
               _loc7_ = [];
               _loc8_ = 0;
               while(_loc8_ < this._network.loginFlags.unequipItemBinds.length)
               {
                  _loc9_ = this._network.loginFlags.unequipItemBinds[_loc8_];
                  _loc10_ = this._network.playerData.inventory.getItemById(_loc9_);
                  if(_loc10_ != null)
                  {
                     _loc7_.push(_loc10_.getName());
                  }
                  _loc8_++;
               }
               if(_loc7_.length > 0)
               {
                  _loc11_ = Language.getInstance().getString("bindchange_msg") + "<br/><br/><b>" + _loc7_.join("<br/>") + "</b>";
                  _loc12_ = new MessageBox(_loc11_,null,true);
                  _loc12_.addTitle(Language.getInstance().getString("bindchange_title"),BaseDialogue.TITLE_COLOR_RUST);
                  _loc12_.addButton(Language.getInstance().getString("bindchange_ok"));
                  _loc12_.open();
               }
            }
            if(this._network.data.news.length > 0)
            {
               _loc13_ = new NewsDialogue();
               _loc13_.open();
            }
         }
         if(this._network.loginFlags.promos.length > 0)
         {
            for each(_loc14_ in this._network.loginFlags.promos)
            {
               _loc15_ = new PromoDialogue(_loc14_);
               _loc15_.open();
            }
         }
         if(this._network.loginFlags.longSessionValidation)
         {
            this._showLongSessionDialogue = true;
         }
      }
      
      private function onNeighborCompoundSceneLoaded(param1:SceneLoader) : void
      {
         var compoundScene:CompoundScene;
         var buildings:BuildingCollection;
         var missionData:MissionData = null;
         var neighbor:RemotePlayerData = null;
         var loader:SceneLoader = param1;
         if(this._location != NavigationLocation.NEIGHBOR_COMPOUND && this._location != NavigationLocation.MISSION_PLANNING)
         {
            return;
         }
         missionData = loader.data as MissionData;
         neighbor = missionData != null ? missionData.opponent as RemotePlayerData : loader.data as RemotePlayerData;
         compoundScene = new CompoundScene();
         this.killDirector();
         this.setScene(compoundScene,loader.sceneXML);
         buildings = neighbor.compound.buildings;
         compoundScene.addBuildings(buildings);
         this._scene.map.buildNavGraph();
         this._director = missionData != null ? new MissionPlanningDirector(this,compoundScene,this._gui) : new CompoundDirector(this,compoundScene,this._gui);
         this._director.start(this._timeElapsed,loader.data);
         this.pause(false);
         this._container.addChildAt(this._view,0);
         this.fadeInScene(0.5,function():void
         {
            var _loc1_:Language = null;
            var _loc2_:* = false;
            var _loc3_:MessageBox = null;
            if(missionData == null && AllianceDialogState.getInstance().viewingFromWars == false)
            {
               _loc1_ = Language.getInstance();
               _loc2_ = neighbor.compound.buildings.getBuildingsBeingUpgraded().length > 0;
               _loc3_ = new MessageBox(_loc1_.getString(_loc2_ ? "help_canhelp_msg_yes" : "help_canhelp_msg_no",neighbor.nickname));
               _loc3_.addTitle(_loc1_.getString("help_canhelp_title",neighbor.nickname));
               _loc3_.addImage(neighbor.getPortraitURI());
               _loc3_.addButton(_loc1_.getString("help_canhelp_ok"));
               _loc3_.open();
            }
            AllianceDialogState.getInstance().viewingFromWars = false;
         });
         Tracking.trackPageview("neighborCompound/" + (missionData == null ? "view" : "attack"));
      }
      
      private function onMissionLoaded(param1:MissionLoader) : void
      {
         var _loc3_:XML = null;
         DialogueManager.getInstance().closeDialogue("loading-compound-attack");
         this.killDirector();
         var _loc2_:MissionData = param1.missionData;
         if(_loc2_.opponent.isPlayer)
         {
            this.setScene(this._scene);
            this._director = new MissionPvPDirector(this,CompoundScene(this._scene),this._gui);
         }
         else
         {
            _loc3_ = param1.sceneXML;
            this.setScene(SceneFactory.getScene(_loc3_.type.toString()),_loc3_);
            this._director = new MissionPvZDirector(this,this._scene,this._gui);
            this._container.addChildAt(this._view,0);
            this.fadeInScene(0.5);
         }
         this._scene.map.buildNavGraph();
         this._director.start(this._timeElapsed,_loc2_);
         this.pause(false);
         if(_loc2_.opponent.isPlayer)
         {
            Tracking.trackPageview("mission/pvp/level" + _loc2_.opponent.level + "/" + (RemotePlayerData(_loc2_.opponent).isFriend ? "friend" : "unknown"));
         }
         else
         {
            Tracking.trackPageview("mission/pvp/" + _loc2_.type + "/level" + _loc2_.opponent.level);
         }
      }
      
      private function onNewSurvivorArrivedMessage(param1:Message) : void
      {
         var loader:AssetLoader;
         var srv:Survivor = null;
         var msg:Message = param1;
         srv = new Survivor();
         srv.readObject(JSON.parse(msg.getString(0)));
         loader = new AssetLoader();
         loader.loadingCompleted.addOnce(function():void
         {
            SurvivorPortrait.queueCompleted.addOnce(function():void
            {
               _network.playerData.compound.survivors.addSurvivor(srv);
               var _loc1_:String = _location != NavigationLocation.PLAYER_COMPOUND || _zombieAttackPrepareTimer.running ? "passive" : "default";
               NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.SURVIVOR_ARRIVED,srv.id,_loc1_));
            });
            SurvivorPortrait.savePortrait(srv);
         });
         loader.loadAssets(srv.getResourceURIs());
      }
      
      public function onZombieAttackMessage(param1:Message) : void
      {
         var missionData:MissionData = null;
         var survivors:SurvivorCollection = null;
         var i:int = 0;
         var srv:Survivor = null;
         var msg:Message = param1;
         try
         {
            missionData = new MissionData();
            missionData.type = "compound";
            missionData.opponent = new ZombieOpponentData(Math.min(this._network.playerData.compound.survivors.getHighestLevel(),Config.constant.MAX_COMPOUND_ZOMBIE_LEVEL));
            survivors = this._network.playerData.compound.survivors;
            i = 0;
            while(i < survivors.length)
            {
               srv = survivors.getSurvivor(i);
               if(!(srv.state & SurvivorState.ON_MISSION) && !(srv.state & SurvivorState.REASSIGNING) && !(srv.state & SurvivorState.ON_ASSIGNMENT))
               {
                  missionData.survivors.push(srv);
               }
               i++;
            }
            this._zombieAttackLoaderA.loadCompleted.addOnce(function(param1:MissionLoader):void
            {
               _zombieAttackLoaderA.loadCompleted.remove(arguments.callee);
               _zombieAttackMission = missionData;
               _zombieAttackMission.useTraps = false;
               if(Tutorial.getInstance().active)
               {
                  Tutorial.getInstance().setState(Tutorial.STATE_ZOMBIE_ATTACK_READY,true);
               }
               if(_location == NavigationLocation.PLAYER_COMPOUND && DialogueManager.getInstance().numModalDialoguesOpen == 0)
               {
                  alertZombieAttack();
               }
            });
            this._zombieAttackLoaderA.load(missionData);
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               _network.client.errorLog.writeError("Zombie attack",error.message,error.getStackTrace(),{"player":_network.playerData.id});
               throw error;
            }
         }
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:INotification = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:MissionData = param1.target as MissionData;
         if(_loc2_ != null)
         {
            if(param1.data.type != "return" || _loc2_.returnTimer == null)
            {
               return;
            }
            if(!Tutorial.getInstance().active && this._network.playerData.missionList.containsMission(_loc2_))
            {
               _loc5_ = "mission-report-dialogue-" + _loc2_.id.toUpperCase();
               if(DialogueManager.getInstance().getDialogueById(_loc5_) != null)
               {
                  return;
               }
               _loc6_ = this._location != NavigationLocation.PLAYER_COMPOUND ? "passive" : (_loc2_.automated && DialogueManager.getInstance().numModalDialoguesOpen == 0 ? "active" : "passive");
               _loc7_ = NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.MISSION_RETURN,_loc2_.id,_loc6_));
            }
            return;
         }
         var _loc3_:Building = param1.target as Building;
         if(_loc3_ != null)
         {
            if(param1.data.type != "upgrade")
            {
               return;
            }
            if(this._network.playerData.compound.buildings.containsBuilding(_loc3_))
            {
               if(!Tutorial.getInstance().active && Building.getBuildingXP(_loc3_.type,_loc3_.level) > 0)
               {
                  NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.BUILDING_COMPLETE,_loc3_.id));
               }
               if(_loc3_.craftingCategories.length > 0 && this._network.playerData.compound.buildings.getNumCraftingBuildings() == 1)
               {
                  if(_loc3_.level == 0)
                  {
                     NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.CRAFTING_AVAILABLE));
                  }
               }
            }
            return;
         }
         var _loc4_:Survivor = param1.target as Survivor;
         if(_loc4_ != null)
         {
            if(this._network.playerData.compound.survivors.containsSurvivor(_loc4_))
            {
               if(param1.data.type == "reassign")
               {
                  NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.SURVIVOR_REASSIGNED,_loc4_.id));
               }
               else
               {
                  NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.SURVIVOR_HEALED,_loc4_.id));
               }
            }
            return;
         }
      }
      
      private function onSchematicUnlocked(param1:Schematic) : void
      {
         var _loc2_:Boolean = this._location == NavigationLocation.PLAYER_COMPOUND && DialogueManager.getInstance().getDialogueById("inventory-dialogue") != null;
         NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.SCHEMATIC_UNLOCKED,param1.id,_loc2_ ? "active" : "passive"));
      }
      
      private function onNotificationAdded(param1:INotification) : void
      {
         if(this._location == NavigationLocation.PLAYER_COMPOUND && param1 != null && param1.active)
         {
            NotificationSystem.getInstance().openActiveNotifications();
         }
      }
      
      private function onPlayerLevelUp(param1:Survivor, param2:int) : void
      {
         if(this._container.stage != null)
         {
            this.mc_levelUp.x = int(this._container.stage.stageWidth * 0.5);
            this.mc_levelUp.y = 96;
            this.mc_levelUp.play(int(param2 + 1));
            this._container.addChild(this.mc_levelUp);
            Audio.sound.play("sound/interface/level-up.mp3");
         }
         var _loc3_:* = this._location == NavigationLocation.PLAYER_COMPOUND;
         if(param2 == int(Config.constant.BOUNTY_MIN_LEVEL))
         {
            NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.BOUNTY_ACTIVATED,{"allowOpen":!this._zombieAttackImminent},_loc3_ ? "active" : "passive"));
         }
         if(param2 == int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL))
         {
            NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.ALLIANCE_ACTIVATED,{"allowOpen":!this._zombieAttackImminent},_loc3_ ? "active" : "passive"));
         }
      }
      
      private function onPlayerFlagChanged(param1:uint, param2:Boolean) : void
      {
      }
      
      private function onExpirationTimerTick(param1:TimerEvent) : void
      {
         if(this._location != NavigationLocation.PLAYER_COMPOUND && this._location != NavigationLocation.WORLD_MAP)
         {
            return;
         }
         try
         {
            this._network.playerData.inventory.updateLimitedSchematics();
         }
         catch(error:Error)
         {
         }
      }
      
      private function onLongSessionTimerTick(param1:TimerEvent) : void
      {
         this._showLongSessionDialogue = true;
      }
      
      private function onBuildingCompleteMessage(param1:Message) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = param1.getString(_loc2_++);
         var _loc4_:int = param1.getInt(_loc2_++);
         var _loc5_:int = param1.getInt(_loc2_++);
         this._network.playerData.levelPoints = _loc5_;
      }
      
      private function onResearchCompleteMessage(param1:Message) : void
      {
         var _loc2_:String = param1.getString(0);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = JSON.parse(_loc2_);
         ResearchSystem.getInstance().completeResearchTasks(_loc3_);
      }
      
      private function onResearchEffectsChanged() : void
      {
         var _loc1_:PlayerData = Network.getInstance().playerData;
         this.applyResearchEffects(_loc1_.researchState.effects,_loc1_.compound.buildings,_loc1_.compound.survivors);
      }
      
      private function onResearchCompleted(param1:ResearchTask) : void
      {
         var _loc2_:Object = {
            "category":param1.category,
            "group":param1.group,
            "level":param1.level
         };
         NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.RESEARCH_COMPLETED,_loc2_));
      }
      
      public function get display() : Sprite
      {
         return this._container;
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function get stage() : Stage
      {
         return this._stage;
      }
      
      public function get context() : Context3D
      {
         return this._stage3D.context3D;
      }
      
      public function get location() : String
      {
         return this._location;
      }
      
      public function get rvoSimulator() : RVOSimulator
      {
         return this._rvoSimulator;
      }
      
      public function get timeElapsed() : Number
      {
         return this._timeElapsed;
      }
      
      public function get zombieAttackImminent() : Boolean
      {
         return this._zombieAttackImminent;
      }
      
      private function onAHTimer(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = Number(NaN);
         if(this._ahLastTimer != 0)
         {
            _loc2_ = getTimer() - this._ahLastTimer;
            _loc3_ = new Date().time - this._ahLastSystem;
            if(_loc2_ <= this._ahTimer.delay * 0.6 || _loc3_ <= this._ahTimer.delay * 0.6)
            {
               ++this._ahCount;
               if(this._ahCount >= 3)
               {
                  Network.getInstance().save({
                     "id":"sphk",
                     "td":_loc2_,
                     "sd":_loc3_,
                     "rate":this._ahTimer.delay
                  },SaveDataMethod.AH_EVENT);
                  this._ahTimer.stop();
               }
            }
         }
         this._ahLastTimer = getTimer();
         this._ahLastSystem = new Date().time;
      }
   }
}

