package thelaststand.app.game.logic
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.core.View;
   import com.deadreckoned.threshold.display.Color;
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import com.junkbyte.console.Cc;
   import flash.display.Bitmap;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import playerio.Connection;
   import playerio.Message;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.KeyFlags;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.display.Effects;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.CoverData;
   import thelaststand.app.game.data.DeploymentZone;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.GearClass;
   import thelaststand.app.game.data.GearType;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorLoadoutData;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.arena.ArenaSystem;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.enemies.EnemyEliteType;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.data.quests.MiniTask;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.ExplosiveChargeEntity;
   import thelaststand.app.game.entities.actors.Actor;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.buildings.StadiumButtonEntity;
   import thelaststand.app.game.entities.effects.DustClouds;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.entities.gui.UIMovementTarget;
   import thelaststand.app.game.entities.gui.UIRangeIndicator;
   import thelaststand.app.game.entities.gui.UISelectedIndicator;
   import thelaststand.app.game.entities.gui.UIThrowCursor;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.UIEntityRollover;
   import thelaststand.app.game.gui.UIFloatingMessage;
   import thelaststand.app.game.gui.UISpeechBubble;
   import thelaststand.app.game.gui.arena.ArenaMissionEndDialogue;
   import thelaststand.app.game.gui.compound.UIBuildingIcon;
   import thelaststand.app.game.gui.dialogues.AllianceMissionSummaryDialogue;
   import thelaststand.app.game.gui.dialogues.BountyCollectDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.game.gui.mission.MissionGUILayer;
   import thelaststand.app.game.gui.mission.UIBuildingIndicator;
   import thelaststand.app.game.gui.mission.UIDisarmProgress;
   import thelaststand.app.game.gui.mission.UIEliteEnemyIndicator;
   import thelaststand.app.game.gui.mission.UISearchProgress;
   import thelaststand.app.game.gui.mission.UISuppressedIndicator;
   import thelaststand.app.game.gui.mission.UISurvivorIndicator;
   import thelaststand.app.game.gui.mission.UISurvivorLocation;
   import thelaststand.app.game.gui.raid.RaidMissionEndDialogue;
   import thelaststand.app.game.gui.raid.RaidMissionStartDialogue;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.game.logic.ai.NoiseSource;
   import thelaststand.app.game.logic.ai.effects.AbstractAIEffect;
   import thelaststand.app.game.logic.ai.effects.GenericEffect;
   import thelaststand.app.game.logic.ai.effects.IAIEffect;
   import thelaststand.app.game.logic.ai.states.ActorScavengeState;
   import thelaststand.app.game.logic.ai.states.ActorSuppressedState;
   import thelaststand.app.game.logic.ai.states.SurvivorAlertState;
   import thelaststand.app.game.logic.ai.states.SurvivorDisarmTrapState;
   import thelaststand.app.game.logic.ai.states.SurvivorHealingState;
   import thelaststand.app.game.logic.ai.states.SurvivorPlaceItemState;
   import thelaststand.app.game.logic.ai.states.SurvivorThrowState;
   import thelaststand.app.game.logic.data.ActiveGearMode;
   import thelaststand.app.game.logic.data.ThrowTrajectoryData;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.game.scenes.BaseMissionScene;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.engine.logic.LineOfSight;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.CellFlag;
   import thelaststand.engine.map.NavEdgeFlag;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.light.OmniLightEntity;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class MissionDirector implements ISceneDirector
   {
      
      private static const NAVIGATION_GROUP_PLAYER:uint = 1;
      
      private static const NAVIGATION_GROUP_ENEMY:uint = 2;
      
      private static const NAVIGATION_GROUP_ALL:uint = 255;
      
      private static var _scavIndex:int = 0;
      
      private var _ui_eliteIndicatorsByEnemy:Dictionary;
      
      private var _ui_survivorIndicatorsBySurvivor:Dictionary;
      
      private var _ui_survivorLocationsBySurvivor:Dictionary;
      
      private var _ui_rangeIndicatorsBySurvivor:Dictionary;
      
      private var _ui_healIndicatorsBySurvivor:Dictionary;
      
      private var _ui_scavengeIndicatorsBySurvivor:Dictionary;
      
      private var _ui_selectedIndicatorsBySurvivor:Dictionary;
      
      private var _ui_buildingHealthByBuilding:Dictionary;
      
      private var _ui_suppressionIndicatorsByAgent:Dictionary;
      
      private var _ui_trapDetectedByBuilding:Dictionary;
      
      private var _ui_trapDisarmBySurvivor:Dictionary;
      
      private var _ui_speechBySurvivor:Dictionary;
      
      private var _network:Network;
      
      private var _lang:Language;
      
      private var _playerSurvivor:Survivor;
      
      private var _failureSnapshot:Bitmap;
      
      private var _mouseOverAgent:AIAgent;
      
      private var _missionScene:BaseMissionScene;
      
      private var _endTimer:Timer;
      
      private var _tutorial:Tutorial;
      
      private var _statTimer:Timer;
      
      private var _allSurvivorsDead:Boolean;
      
      private var _keysDown:uint = 0;
      
      private var _isPvP:Boolean = false;
      
      private var _activeGearMode:uint = 0;
      
      private var _throwTrajectory:ThrowTrajectoryData;
      
      private var _mousePosition:Vector3D = new Vector3D();
      
      private var _agentsEnabled:Boolean = true;
      
      private var _scavengingEnabled:Boolean = true;
      
      private var _lineOfSight:LineOfSight;
      
      private var _bountyCollectDlg:BountyCollectDialogue;
      
      private var _allianceMissionSummaryDlg:AllianceMissionSummaryDialogue;
      
      private var _dmgFloaterCooldown:int = 500;
      
      private var _lowTimeTaskDone:Boolean = false;
      
      private var _tmpVector:Vector3D = new Vector3D();
      
      private var _idleSurvivorToTalk:Survivor = null;
      
      private var _lastIdleTalkTime:Number = 0;
      
      private var _lastSurvivorTalkTime:Number = 0;
      
      private var _startTime:Number = 0;
      
      private var _runningTime:Number = 0;
      
      private var _time:Number = 0;
      
      private var _playerLevel:int;
      
      private var _eliteVignetteTimeout:uint;
      
      private var _assignmentUpdateTimer:Timer;
      
      private var _scavengeCooldown:Dictionary = new Dictionary(true);
      
      private var _arenaController:ArenaMissionController;
      
      protected var _trackingTrapsTriggered:int = 0;
      
      protected var _timeStart:Number = 0;
      
      protected var _isCompoundAttack:Boolean;
      
      protected var _missionActive:Boolean;
      
      protected var _actionMode:Boolean;
      
      protected var _scene:BaseScene;
      
      protected var _game:Game;
      
      protected var _gui:GameGUI;
      
      protected var _guiMission:MissionGUILayer;
      
      protected var _missionData:MissionData;
      
      protected var _assignmentData:AssignmentData;
      
      protected var _raidData:RaidData;
      
      protected var _arenaData:ArenaSession;
      
      protected var _allAgents:Vector.<AIAgent>;
      
      protected var _selectedSurvivor:Survivor;
      
      protected var _survivors:Vector.<AIActorAgent>;
      
      protected var _enemies:Vector.<AIActorAgent>;
      
      protected var _buildingAgents:Vector.<Building>;
      
      protected var _interactiveBuildings:Vector.<Building>;
      
      protected var _trapAgents:Vector.<Building>;
      
      protected var _deploymentZones:Vector.<DeploymentZone>;
      
      protected var _useDeployZones:Boolean;
      
      protected var _useTimer:Boolean = true;
      
      protected var _hideUnseenEnemies:Boolean = true;
      
      protected var _hudIndicatorsVisible:Boolean = true;
      
      protected var _timeMission:Number = 0;
      
      protected var _timeRemaining:Number = 0;
      
      protected var _xpBonus:Number = 1;
      
      protected var _totalSurvivorsInjured:int = 0;
      
      protected var _scavedCount:int = 0;
      
      protected var ui_entityRollover:UIEntityRollover;
      
      protected var ui_throwCursor:UIThrowCursor;
      
      private var _failedMission:Boolean = false;
      
      private var _scavSrvDict:Dictionary = new Dictionary();
      
      private var _containerSearchCount:int = 0;
      
      private var keyDownDict:Dictionary = new Dictionary();
      
      private var _firstInteractionFlag:Boolean = false;
      
      private var _sharedEnemySurvivorTargetInfo:Dictionary;
      
      public var enemySpawned:Signal = new Signal(AIActorAgent);
      
      public var enemyDied:Signal = new Signal(AIActorAgent,Object);
      
      public var playerSurvivorDied:Signal = new Signal(Survivor,Object);
      
      public var allPlayerSurvivorsDied:Signal = new Signal();
      
      public var timerExhausted:Signal = new Signal();
      
      public var scavengedCompleted:Signal = new Signal(Survivor,GameEntity);
      
      public function MissionDirector(param1:Game, param2:BaseScene, param3:GameGUI)
      {
         super();
         this._game = param1;
         this._scene = param2;
         this._missionScene = this._scene as BaseMissionScene;
         this._gui = param3;
         this._guiMission = new MissionGUILayer();
         this._lineOfSight = new LineOfSight();
         this._network = Network.getInstance();
         this._lang = Language.getInstance();
         this._allAgents = new Vector.<AIAgent>();
         this._survivors = new Vector.<AIActorAgent>();
         this._enemies = new Vector.<AIActorAgent>();
         this._buildingAgents = new Vector.<Building>();
         this._trapAgents = new Vector.<Building>();
         this._interactiveBuildings = new Vector.<Building>();
         this._playerSurvivor = this._network.playerData.getPlayerSurvivor();
         this._deploymentZones = new Vector.<DeploymentZone>();
         this._tutorial = Tutorial.getInstance();
         this._endTimer = new Timer(2000,1);
         this._endTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onMissionEndTimerCompleted,false,0,true);
         this._statTimer = new Timer(5000);
         this._statTimer.addEventListener(TimerEvent.TIMER,this.onStatTimerTick,false,0,true);
         this._assignmentUpdateTimer = new Timer(2000);
         this._assignmentUpdateTimer.addEventListener(TimerEvent.TIMER,this.onAssignmentUpdateTimer,false,0,true);
         this.ui_entityRollover = new UIEntityRollover();
         this.ui_entityRollover.showBuildingAssignments = false;
         this.ui_throwCursor = new UIThrowCursor();
         this._ui_eliteIndicatorsByEnemy = new Dictionary(true);
         this._ui_survivorIndicatorsBySurvivor = new Dictionary(true);
         this._ui_survivorLocationsBySurvivor = new Dictionary(true);
         this._ui_selectedIndicatorsBySurvivor = new Dictionary(true);
         this._ui_rangeIndicatorsBySurvivor = new Dictionary(true);
         this._ui_healIndicatorsBySurvivor = new Dictionary(true);
         this._ui_scavengeIndicatorsBySurvivor = new Dictionary(true);
         this._ui_buildingHealthByBuilding = new Dictionary(true);
         this._ui_suppressionIndicatorsByAgent = new Dictionary(true);
         this._ui_trapDetectedByBuilding = new Dictionary(true);
         this._ui_trapDisarmBySurvivor = new Dictionary(true);
         this._ui_speechBySurvivor = new Dictionary(true);
      }
      
      public function get guiLayer() : MissionGUILayer
      {
         return this._guiMission;
      }
      
      public function get startTime() : Number
      {
         return this._startTime;
      }
      
      public function dispose() : void
      {
         var _loc1_:UIRangeIndicator = null;
         var _loc2_:UISelectedIndicator = null;
         var _loc3_:UISearchProgress = null;
         var _loc4_:UIBuildingIndicator = null;
         var _loc5_:UISuppressedIndicator = null;
         var _loc6_:UIBuildingIcon = null;
         var _loc7_:UIDisarmProgress = null;
         var _loc8_:UISpeechBubble = null;
         this.timerExhausted.removeAll();
         this.enemyDied.removeAll();
         this.enemySpawned.removeAll();
         this.playerSurvivorDied.removeAll();
         this.allPlayerSurvivorsDied.removeAll();
         this.scavengedCompleted.removeAll();
         if(this._arenaController != null)
         {
            this._arenaController.dispose();
            this._arenaController = null;
         }
         for each(_loc1_ in this._ui_rangeIndicatorsBySurvivor)
         {
            _loc1_.dispose();
         }
         for each(_loc2_ in this._ui_selectedIndicatorsBySurvivor)
         {
            _loc2_.dispose();
         }
         for each(_loc3_ in this._ui_scavengeIndicatorsBySurvivor)
         {
            _loc3_.dispose();
         }
         for each(_loc4_ in this._ui_buildingHealthByBuilding)
         {
            _loc4_.dispose();
         }
         for each(_loc5_ in this._ui_suppressionIndicatorsByAgent)
         {
            _loc5_.dispose();
         }
         for each(_loc6_ in this._ui_trapDetectedByBuilding)
         {
            _loc6_.dispose();
         }
         for each(_loc7_ in this._ui_trapDisarmBySurvivor)
         {
            _loc7_.dispose();
         }
         for each(_loc8_ in this._ui_speechBySurvivor)
         {
            _loc8_.dispose();
         }
         this.ui_throwCursor.dispose();
         this.ui_entityRollover.dispose();
         this.ui_entityRollover = null;
         this._game = null;
         this._scene = null;
         this._missionScene = null;
         this._gui = null;
         this._network = null;
         this._lang = null;
         this._allAgents = null;
         this._survivors = this._enemies = null;
         this._buildingAgents = null;
         this._interactiveBuildings = null;
         this._trapAgents = null;
         this._mouseOverAgent = null;
         this._playerSurvivor = null;
         this._deploymentZones = null;
         this._tutorial = null;
         this._idleSurvivorToTalk = null;
         this._endTimer.stop();
         this._endTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onMissionEndTimerCompleted);
         this._endTimer = null;
         this._statTimer.stop();
         this._statTimer.removeEventListener(TimerEvent.TIMER,this.onStatTimerTick);
         this._statTimer = null;
         this._assignmentUpdateTimer.stop();
         this._assignmentUpdateTimer.removeEventListener(TimerEvent.TIMER,this.onAssignmentUpdateTimer);
         this._assignmentUpdateTimer = null;
         this._ui_eliteIndicatorsByEnemy = null;
         this._ui_survivorIndicatorsBySurvivor = null;
         this._ui_survivorLocationsBySurvivor = null;
         this._ui_selectedIndicatorsBySurvivor = null;
         this._ui_rangeIndicatorsBySurvivor = null;
         this._ui_scavengeIndicatorsBySurvivor = null;
         this._ui_trapDisarmBySurvivor = null;
         this._ui_speechBySurvivor = null;
         this._ui_buildingHealthByBuilding = null;
         this._ui_suppressionIndicatorsByAgent = null;
         this._ui_trapDetectedByBuilding = null;
         if(this._bountyCollectDlg)
         {
            this._bountyCollectDlg.close();
            this._bountyCollectDlg = null;
         }
         if(this._allianceMissionSummaryDlg)
         {
            this._allianceMissionSummaryDlg.close();
            this._allianceMissionSummaryDlg = null;
         }
         this._sharedEnemySurvivorTargetInfo = null;
      }
      
      public function end() : void
      {
         var _loc1_:GameEntity = null;
         var _loc2_:Survivor = null;
         var _loc3_:AIActorAgent = null;
         var _loc4_:DeploymentZone = null;
         clearTimeout(this._eliteVignetteTimeout);
         TweenMax.killDelayedCallsTo(this.failMission);
         MouseCursors.setCursor(MouseCursors.DEFAULT);
         MiniTaskSystem.getInstance().resetMissionAchievements();
         Cc.addSlashCommand("leave",null);
         if(this._arenaController != null)
         {
            this._arenaController.end();
         }
         this._game.stage.removeEventListener(Event.RESIZE,this.onStageResize);
         this._game.stage.removeEventListener(MouseEvent.RIGHT_CLICK,this.onStageRightClicked);
         this._game.stage.removeEventListener(MouseEvent.CLICK,this.onStageClicked);
         this._scene.mouseMap.tileClicked.remove(this.onTileClicked);
         this._scene.mouseMap.tileMouseOver.remove(this.onTileMouseOver);
         this._scene.mouseMap.tileMouseOut.remove(this.onTileMouseOut);
         this._scene.mouseMap.enabled = false;
         this.selectSurvivor(null);
         this._guiMission.ui_survivorBar.survivorSelected.remove(this.onGUISurvivorSelected);
         this._guiMission.leaveMissionRequsted.remove(this.onLeaveRequested);
         this._guiMission.leaveMissionConfirmed.remove(this.leaveMission);
         this._guiMission.leaveMissionOpened.remove(this.onLeaveOpened);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.keyPressed.remove(this.onKeyPressed);
         this._gui.keyReleased.remove(this.onKeyReleased);
         if(this._gui.getLayerIndex(this._guiMission) > -1)
         {
            this._gui.removeLayer(this._guiMission,true,this._guiMission.dispose);
         }
         else
         {
            this._guiMission.dispose();
         }
         if(this._failureSnapshot != null)
         {
            if(this._failureSnapshot.parent != null)
            {
               this._failureSnapshot.parent.removeChild(this._failureSnapshot);
            }
            this._failureSnapshot.bitmapData.dispose();
            this._failureSnapshot = null;
         }
         for each(_loc1_ in this._scene.searchableEntities)
         {
            _loc1_.assetMouseOver.remove(this.onSearchableEntityMouseOver);
            _loc1_.assetMouseOut.remove(this.onSearchableEntityMouseOut);
            _loc1_.assetClicked.remove(this.onSearchableEntityClicked);
         }
         for each(_loc2_ in this._survivors)
         {
            this._scene.removeEntity(_loc2_.actor);
            _loc2_.actor.asset.visible = true;
            _loc2_.actor.transform.position.z = 0;
            _loc2_.removeMissionAssets();
            _loc2_.setActiveLoadout(null);
            this.cleanSurvivor(_loc2_);
            _loc2_.agentData.clearState();
         }
         for each(_loc3_ in this._enemies)
         {
            this._game.rvoSimulator.removeAgent(_loc3_.navigator);
            _loc3_.navigator.map = null;
            _loc3_.dodgedAttack.remove(this.onAgentDodgedAttack);
            _loc3_.damageTaken.remove(this.onAgentDamageTaken);
            _loc3_.died.remove(this.onEnemyDie);
            _loc3_.actorClicked.remove(this.onEnemyClicked);
            _loc3_.actorMouseOver.remove(this.onEnemyMouseOver);
            _loc3_.actorMouseOut.remove(this.onEnemyMouseOut);
            _loc3_.movementStopped.remove(this.onEnemySurvivorMovementStopped);
            _loc3_.killedEnemy.remove(this.onAgentKilledEnemy);
            _loc3_.navigator.targetUnreachable.remove(this.onSurvivorTargetUnreachable);
            _loc3_.suppressedStateChanged.remove(this.onAgentSuppressedStateChanged);
            _loc3_.dispose();
         }
         for each(_loc4_ in this._deploymentZones)
         {
            this._scene.container.removeChild(_loc4_.decal);
            _loc4_.dispose();
         }
         this._deploymentZones.length = 0;
         this._survivors.length = 0;
         this._enemies.length = 0;
         this._allAgents.length = 0;
         this._interactiveBuildings.length = 0;
         this._trapAgents.length = 0;
         this._mouseOverAgent = null;
         this._missionData = null;
         this._missionActive = false;
         this._selectedSurvivor = null;
         this._idleSurvivorToTalk = null;
         this._endTimer.stop();
         this._statTimer.stop();
         this._assignmentUpdateTimer.stop();
      }
      
      public function start(param1:Number, ... rest) : void
      {
         var noiseEffect:Number;
         var ent:GameEntity = null;
         var warning:String = null;
         var t:Number = param1;
         var args:Array = rest;
         this._missionActive = true;
         this._missionData = args[0] as MissionData;
         this._assignmentData = this._missionData.isAssignment ? Network.getInstance().playerData.assignments.getById(this._missionData.assignmentId) : null;
         this._raidData = this._assignmentData as RaidData;
         this._arenaData = this._assignmentData as ArenaSession;
         this._isCompoundAttack = this._missionData.isCompoundAttack();
         this._isPvP = this._missionData.opponent.isPlayer;
         this._time = t;
         this._startTime = t;
         this._runningTime = 0;
         this._playerLevel = Network.getInstance().playerData.getPlayerSurvivor().level;
         if(this._useTimer)
         {
            this._timeMission = this._missionData.missionTime;
            this._timeRemaining = this._timeMission;
            this._timeStart = getTimer();
            this.updateTimeRemaining();
         }
         this._guiMission.isPvP = this._isPvP;
         this._guiMission.ui_timer.visible = this._useTimer;
         this._guiMission.ui_survivorBar.survivorSelected.add(this.onGUISurvivorSelected);
         this._guiMission.ui_survivorBar.activeGearSelected.add(this.onGUIActiveGearSelected);
         this._guiMission.leaveMissionRequsted.add(this.onLeaveRequested);
         this._guiMission.leaveMissionConfirmed.add(this.leaveMission);
         this._guiMission.leaveMissionOpened.add(this.onLeaveOpened);
         this._gui.addLayer("mission",this._guiMission);
         this._gui.keyPressed.add(this.onKeyPressed);
         this._gui.keyReleased.add(this.onKeyReleased);
         if(this._missionData.assignmentType == AssignmentType.Arena)
         {
            warning = Language.getInstance().getString("arena." + this._arenaData.name + ".mission_time_warning");
            if(warning != "?")
            {
               this._guiMission.ui_timer.warningMessage = warning;
            }
         }
         if(this._useDeployZones)
         {
            this.addDeploymentZones();
         }
         this._scene.buildCoverTable();
         noiseEffect = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("NoiseEffects"));
         this._scene.noiseVolumeMultiplier += this._scene.noiseVolumeMultiplier / 100;
         for each(ent in this._scene.searchableEntities)
         {
            ent.asset.mouseEnabled = true;
            ent.assetMouseOver.add(this.onSearchableEntityMouseOver);
            ent.assetMouseOut.add(this.onSearchableEntityMouseOut);
            ent.assetClicked.add(this.onSearchableEntityClicked);
         }
         if(this._tutorial.active && this._tutorial.stepNum < this._tutorial.getStepNum(Tutorial.STEP_MOVEMENT))
         {
            this._tutorial.gotoStepId(Tutorial.STEP_MOVEMENT);
         }
         if(Network.getInstance().playerData.isAdmin)
         {
            Cc.addSlashCommand("leave",this.leaveMission,"Leaves the current mission",false);
            Cc.addSlashCommand("endmission",this.endMission,"Ends the current mission with a success state",false);
            Cc.addSlashCommand("trigger",function(param1:String = ""):void
            {
               var _loc2_:Array = param1.split(/\s+/);
               if(_loc2_ == null || _loc2_.length == 0)
               {
                  return;
               }
               var _loc3_:String = String(_loc2_[0]);
               var _loc4_:int = 1;
               if(_loc2_.length > 1)
               {
                  _loc4_ = int(_loc2_[1]);
               }
               _missionData.incrementTrigger(_loc3_,_loc4_);
            },"Activates a trigger. Usage: triggerName [count=1]",false);
         }
         this._statTimer.start();
         this._missionData.sendStartFlag();
         if(this._assignmentData != null)
         {
            this._assignmentUpdateTimer.start();
         }
         this._game.stage.addEventListener(MouseEvent.RIGHT_CLICK,this.onStageRightClicked,false,0,true);
         this._game.stage.addEventListener(MouseEvent.CLICK,this.onStageClicked,false,0,true);
         MiniTaskSystem.getInstance().resetMissionAchievements();
         if(this._assignmentData != null)
         {
            switch(this._assignmentData.type)
            {
               case AssignmentType.Raid:
                  this.onRaidStart();
                  break;
               case AssignmentType.Arena:
                  this.onArenaStart();
            }
         }
      }
      
      private function onRaidStart() : void
      {
         var raidObjDlg:RaidMissionStartDialogue = new RaidMissionStartDialogue(this._raidData);
         raidObjDlg.opened.addOnce(function(param1:Dialogue):void
         {
            _game.pause(true);
         });
         raidObjDlg.closed.addOnce(function(param1:Dialogue):void
         {
            _game.pause(false);
         });
         raidObjDlg.open();
      }
      
      private function onArenaStart() : void
      {
         this._arenaController = new ArenaMissionController(this);
         this._arenaController.start();
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc8_:Object = null;
         var _loc9_:Survivor = null;
         var _loc10_:UISelectedIndicator = null;
         var _loc11_:UISurvivorLocation = null;
         var _loc12_:Point = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Building = null;
         var _loc16_:GameEntity = null;
         var _loc17_:Object = null;
         var _loc18_:Number = NaN;
         var _loc19_:AIActorAgent = null;
         var _loc20_:Boolean = false;
         if(!this._missionActive)
         {
            return;
         }
         this._time = param2;
         this._runningTime = this._startTime - this._time;
         var _loc3_:int = this._scene.camera.view.width;
         var _loc4_:int = this._gui.footer.y - 44;
         var _loc5_:Boolean = true;
         var _loc6_:int = 0;
         var _loc7_:int = int(this._survivors.length);
         while(_loc6_ < _loc7_)
         {
            _loc9_ = this._survivors[_loc6_] as Survivor;
            if(_loc9_.health > 0)
            {
               if(_loc9_.stateMachine.state == null)
               {
                  if(_loc9_.agentData.suppressed)
                  {
                     _loc9_.stateMachine.setState(new ActorSuppressedState(_loc9_));
                  }
                  else
                  {
                     _loc9_.stateMachine.setState(new SurvivorAlertState(_loc9_));
                  }
               }
               _loc9_.checkLOSToAgents(this._enemies);
               if(_loc9_.weaponData.idleNoise > 0)
               {
                  _loc9_.generateNoise(_loc9_.weaponData.idleNoise);
               }
               if(!this._isCompoundAttack && !this._isPvP)
               {
                  if(_loc9_.navigator.isMoving || !(_loc9_.stateMachine.state is SurvivorAlertState))
                  {
                     _loc9_.agentData.talkIdleTime = 0;
                  }
                  else
                  {
                     _loc9_.agentData.talkIdleTime += param1;
                     if(param2 - this._lastIdleTalkTime >= Config.constant.SURVIVOR_TALK_IDLE_TIME * 1000 && _loc9_.agentData.talkIdleTime >= Config.constant.SURVIVOR_TALK_IDLE_TIME)
                     {
                        _loc9_.agentData.talkIdleTime = 0;
                        if(this._idleSurvivorToTalk == null || Math.random() < 0.5)
                        {
                           this._idleSurvivorToTalk = _loc9_;
                        }
                     }
                  }
               }
            }
            _loc9_.update(param1,param2);
            if(_loc9_.health > 0)
            {
               _loc10_ = this._ui_selectedIndicatorsBySurvivor[_loc9_];
               if(_loc10_.asset.visible && _loc10_.asset.parent != null)
               {
                  _loc10_.transform.position.x = _loc9_.actor.transform.position.x;
                  _loc10_.transform.position.y = _loc9_.actor.transform.position.y;
                  _loc10_.transform.position.z = _loc9_.actor.transform.position.z + 5;
                  _loc10_.updateTransform();
               }
               _loc11_ = this._ui_survivorLocationsBySurvivor[_loc9_];
               _loc12_ = this._scene.getScreenPosition(_loc9_.actor.transform.position.x,_loc9_.actor.transform.position.y,_loc9_.actor.transform.position.z + _loc9_.actor.getHeight() * 0.5);
               if(_loc12_.x < -10 || _loc12_.x > _loc3_ + 10 || _loc12_.y < 10 || _loc12_.y > _loc4_)
               {
                  _loc13_ = _loc12_.x - _loc3_ * 0.5;
                  _loc14_ = _loc12_.y - _loc4_ * 0.5;
                  if(_loc13_ < 0 && _loc12_.y > 0 && _loc12_.y < _loc4_)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_LEFT);
                  }
                  else if(_loc13_ > 0 && _loc12_.y > 0 && _loc12_.y < _loc4_)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_RIGHT);
                  }
                  else if(_loc14_ < 0 && _loc12_.x > 0 && _loc12_.x < _loc3_)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_TOP);
                  }
                  else if(_loc14_ > 0 && _loc12_.x > 0 && _loc12_.x < _loc3_)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_BOTTOM);
                  }
                  else if(_loc13_ < 0 && _loc14_ < 0)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_TOP_LEFT);
                  }
                  else if(_loc13_ > 0 && _loc14_ < 0)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_TOP_RIGHT);
                  }
                  else if(_loc13_ < 0 && _loc14_ > 0)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_BOTTOM_LEFT);
                  }
                  else if(_loc13_ > 0 && _loc14_ > 0)
                  {
                     _loc11_.setDirection(UISurvivorLocation.DIR_BOTTOM_RIGHT);
                  }
                  if(_loc12_.x > 0 && _loc12_.x < _loc3_)
                  {
                     _loc11_.x = _loc12_.x + _loc11_.targetPoint.x;
                  }
                  else
                  {
                     _loc11_.x = (_loc13_ < 0 ? 0 : _loc3_) + _loc11_.targetPoint.x;
                  }
                  if(_loc12_.y > 0 && _loc12_.y < _loc4_)
                  {
                     _loc11_.y = _loc12_.y + _loc11_.targetPoint.y;
                  }
                  else
                  {
                     _loc11_.y = (_loc14_ < 0 ? 0 : _loc4_) + _loc11_.targetPoint.y;
                  }
                  if(_loc11_.x < _loc11_.width * 0.5)
                  {
                     _loc11_.x = int(_loc11_.width * 0.5);
                  }
                  if(_loc11_.x > _loc3_ - _loc11_.width * 0.5)
                  {
                     _loc11_.x = int(_loc3_ - _loc11_.width * 0.5);
                  }
                  if(_loc11_.y < _loc11_.height * 0.5)
                  {
                     _loc11_.y = int(_loc11_.height * 0.5);
                  }
                  if(_loc11_.y > _loc4_ - _loc11_.height * 0.5)
                  {
                     _loc11_.y = int(_loc4_ - _loc11_.height * 0.5);
                  }
                  _loc11_.visible = this._hudIndicatorsVisible;
               }
               else
               {
                  _loc11_.visible = false;
               }
            }
            _loc6_++;
         }
         _loc6_ = int(this._buildingAgents.length - 1);
         while(_loc6_ >= 0)
         {
            _loc15_ = this._buildingAgents[_loc6_];
            if(_loc15_.stateMachine.state != null)
            {
               _loc15_.stateMachine.update(param1,param2);
            }
            _loc6_--;
         }
         for(_loc8_ in this._scavengeCooldown)
         {
            _loc16_ = _loc8_ as GameEntity;
            _loc17_ = this._scavengeCooldown[_loc8_];
            if(_loc17_ != null)
            {
               _loc18_ = this._time - _loc17_.start;
               if(_loc18_ >= _loc17_.duration)
               {
                  _loc16_.asset.mouseEnabled = _loc16_.asset.mouseChildren = true;
                  _loc16_.assetClicked.add(this.onSearchableEntityClicked);
                  _loc16_.assetMouseOver.add(this.onSearchableEntityMouseOver);
                  _loc16_.assetMouseOut.add(this.onSearchableEntityMouseOut);
                  this._scavengeCooldown[_loc16_] = null;
                  if(_loc16_ is BuildingEntity)
                  {
                     BuildingEntity(_loc16_).onScavengedCooldownReset.dispatch();
                  }
               }
            }
         }
         if(this._hideUnseenEnemies)
         {
            _loc6_ = 0;
            _loc7_ = int(this._enemies.length);
            while(_loc6_ < _loc7_)
            {
               _loc19_ = this._enemies[_loc6_];
               _loc20_ = _loc19_.actor.asset.visible && this._allSurvivorsDead || _loc19_.health <= 0 || _loc19_.agentData.inLOS;
               _loc19_.actor.fade(_loc20_ ? 1 : 0,0.25);
               _loc19_.actor.mouseEnabled = this._agentsEnabled && !this._actionMode && _loc19_.health > 0 && _loc19_.agentData.inLOS;
               _loc6_++;
            }
         }
         if(this._missionScene != null)
         {
            this._missionScene.updateWallOpacity(this._allAgents);
         }
         if(this._activeGearMode == ActiveGearMode.THROW && this._selectedSurvivor != null)
         {
            this._mousePosition.setTo(this._scene.mouseMap.mousePt.x,this._scene.mouseMap.mousePt.y,0);
            this.ui_throwCursor.transform.position.setTo(this._mousePosition.x,this._mousePosition.y,0);
            this.updateThrowTrajectory(this._throwTrajectory,this._selectedSurvivor,this._mousePosition);
         }
         if(this._useTimer)
         {
            this.updateTimeRemaining(param2);
         }
         if(this._guiMission.leaveConfirmOpened)
         {
            this._guiMission.ui_survivorBar.survivorsNotInExitZones = this.getSurvivorsNotInExitZones();
            this._guiMission.ui_confirm.allSurvivorsInZones = this._guiMission.ui_survivorBar.survivorsNotInExitZones.length == 0;
         }
         if(this._idleSurvivorToTalk != null)
         {
            if(this._idleSurvivorToTalk.health > 0)
            {
               this.startSurvivorSpeech(this._idleSurvivorToTalk,"idle");
            }
            this._lastIdleTalkTime = param2;
            this._idleSurvivorToTalk.agentData.talkIdleTime = 0;
            this._idleSurvivorToTalk = null;
         }
         if(this._arenaController != null)
         {
            this._arenaController.update(param1,param2);
         }
      }
      
      protected function addPlayerSurvivor(param1:Survivor, param2:Number = 1) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         param1.setActiveLoadout(this._isCompoundAttack ? SurvivorLoadout.TYPE_DEFENCE : SurvivorLoadout.TYPE_OFFENCE);
         if(param1.activeLoadout.weapon.item == null)
         {
            return false;
         }
         param1.addMissionAssets();
         this._survivors.push(param1);
         this._allAgents.push(param1);
         param1.blackboard.erase();
         param1.blackboard.allAgents = this._allAgents;
         param1.blackboard.friends = this._survivors;
         param1.blackboard.enemies = this._enemies;
         param1.blackboard.buildings = this._buildingAgents;
         param1.blackboard.traps = this._trapAgents;
         param1.blackboard.scene = this._scene;
         param1.weaponData.roundsInMagazine = param1.weaponData.capacity;
         param1.team = AIAgent.TEAM_PLAYER;
         param1.flags = AIAgentFlags.NONE;
         var _loc3_:Number = 1;
         if(this._arenaData != null)
         {
            if(this._arenaData.state != null && this._arenaData.state.hp != null)
            {
               if(this._arenaData.state.hp.hasOwnProperty(param1.id))
               {
                  _loc3_ = Number(this._arenaData.state.hp[param1.id]);
               }
            }
         }
         param1.healthModifier = param2;
         param1.health = param1.maxHealth * _loc3_;
         param1.autoTarget = true;
         param1.agentData.inLOS = true;
         param1.agentData.pursueTargets = false;
         param1.agentData.beenSeen = false;
         this.clearCoverRating(param1);
         param1.switchToRun();
         var _loc4_:UISurvivorIndicator = new UISurvivorIndicator(param1);
         _loc4_.showHealth = _loc4_.showName = _loc4_.showAmmo = false;
         this._ui_survivorIndicatorsBySurvivor[param1] = _loc4_;
         if(this._hudIndicatorsVisible)
         {
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
         }
         var _loc5_:UISelectedIndicator = new UISelectedIndicator();
         _loc5_.transform.position.x = param1.actor.transform.position.x;
         _loc5_.transform.position.y = param1.actor.transform.position.y;
         _loc5_.transform.position.z = param1.actor.transform.position.z + 5;
         _loc5_.updateTransform();
         this._ui_selectedIndicatorsBySurvivor[param1] = _loc5_;
         var _loc6_:UISurvivorLocation = new UISurvivorLocation(param1);
         _loc6_.clicked.add(this.onUISurvivorLocationClicked);
         _loc6_.visible = false;
         this._ui_survivorLocationsBySurvivor[param1] = _loc6_;
         this._guiMission.addChild(_loc6_);
         var _loc7_:UIRangeIndicator = new UIRangeIndicator(param1.weaponData.range);
         _loc7_.name = "_ui_range" + param1.id;
         _loc7_.entity = param1.actor;
         this._ui_rangeIndicatorsBySurvivor[param1] = _loc7_;
         param1.actor.animatedAsset.gotoAndPlay(param1.getAnimation("idle"),0,true,0.05,0);
         param1.stateMachine.setState(new SurvivorAlertState(param1));
         this._scene.addEntity(param1.actor);
         param1.navigator.group = NAVIGATION_GROUP_PLAYER;
         param1.navigator.groupMask = NAVIGATION_GROUP_ALL ^ NAVIGATION_GROUP_PLAYER;
         param1.navigator.map = this._scene.map;
         param1.navigator.pathOptions.allowClosestNodeToGoal = true;
         param1.navigator.pathOptions.edgeFlagMask = NavEdgeFlag.ALL_NOT_DISABLED ^ NavEdgeFlag.TRAVERSAL_AREA;
         param1.navigator.pathOptions.nodeFlagMask = CellFlag.ALL_NOT_DISABLED ^ CellFlag.TRAVERSAL_AREA;
         param1.navigator.cancelAndStop();
         this._game.rvoSimulator.addAgent(param1.navigator);
         param1.actor.mouseEnabled = true;
         param1.damageTaken.add(this.onAgentDamageTaken);
         param1.died.addOnce(this.onPlayerSurvivorDie);
         param1.reloadStarted.add(this.onSurvivorReload);
         param1.actorClicked.add(this.onSurvivorClicked);
         param1.actorMouseOver.add(this.onSurvivorMouseOver);
         param1.actorMouseOut.add(this.onSurvivorMouseOut);
         param1.levelIncreased.add(this.onSurvivorLevelIncreased);
         param1.movementStarted.add(this.onSurvivorMovementStarted);
         param1.movementStopped.add(this.onSurvivorMovementStopped);
         param1.noiseGenerated.add(this.onSurvivorNoiseGenerated);
         param1.detectedTraps.add(this.onSurvivorTrapDetected);
         param1.mountedBuildingChanged.add(this.onSurvivorMountedBuildingChanged);
         param1.dodgedAttack.add(this.onAgentDodgedAttack);
         param1.missedAttack.add(this.onAgentMissedAttack);
         param1.killedEnemy.add(this.onAgentKilledEnemy);
         param1.navigator.targetUnreachable.add(this.onSurvivorTargetUnreachable);
         param1.injuries.added.add(this.onSurvivorInjuryAdded);
         param1.suppressedStateChanged.add(this.onAgentSuppressedStateChanged);
         return true;
      }
      
      protected function addEnemy(param1:AIActorAgent, param2:Number = 1) : void
      {
         var _loc3_:Survivor = null;
         var _loc4_:UIEliteEnemyIndicator = null;
         this._enemies.push(param1);
         this._allAgents.push(param1);
         this._scene.addEntity(param1.actor);
         param1.blackboard.allAgents = this._allAgents;
         param1.blackboard.friends = this._enemies;
         param1.blackboard.enemies = this._survivors;
         param1.blackboard.buildings = this._buildingAgents;
         param1.blackboard.traps = this._trapAgents;
         param1.blackboard.scene = this._scene;
         param1.navigator.group = NAVIGATION_GROUP_ENEMY;
         param1.navigator.groupMask = NAVIGATION_GROUP_ALL;
         param1.navigator.map = this._scene.map;
         this._game.rvoSimulator.addAgent(param1.navigator);
         param1.team = AIAgent.TEAM_ENEMY;
         param1.agentData.beenSeen = false;
         param1.navigator.pathOptions.allowClosestNodeToGoal = true;
         if(param1 is Survivor)
         {
            _loc3_ = param1 as Survivor;
            if(this._sharedEnemySurvivorTargetInfo == null)
            {
               this._sharedEnemySurvivorTargetInfo = new Dictionary(true);
            }
            _loc3_.sharedTargetInfo = this._sharedEnemySurvivorTargetInfo;
            _loc3_.healthModifier = param2;
            _loc3_.health = _loc3_.maxHealth;
            _loc3_.navigator.pathOptions.edgeFlagMask = NavEdgeFlag.ALL_NOT_DISABLED ^ NavEdgeFlag.TRAVERSAL_AREA;
            _loc3_.navigator.pathOptions.nodeFlagMask = CellFlag.ALL_NOT_DISABLED ^ CellFlag.TRAVERSAL_AREA;
            _loc3_.setActiveLoadout(SurvivorLoadout.TYPE_DEFENCE);
            if(_loc3_.weapon != null)
            {
               _loc3_.weaponData.roundsInMagazine = _loc3_.weaponData.capacity;
               if(_loc3_.mountedBuilding != null)
               {
                  this.onSurvivorMountedBuildingChanged(_loc3_,_loc3_.mountedBuilding);
               }
            }
            else
            {
               _loc3_.flags |= AIAgentFlags.IMMOVEABLE | AIAgentFlags.LOCKED;
            }
            _loc3_.addMissionAssets();
            _loc3_.stateMachine.setState(new SurvivorAlertState(_loc3_));
            _loc3_.switchToRun();
            _loc3_.movementStopped.add(this.onEnemySurvivorMovementStopped);
            _loc3_.killedEnemy.add(this.onAgentKilledEnemy);
            _loc3_.navigator.targetUnreachable.add(this.onSurvivorTargetUnreachable);
            _loc3_.suppressedStateChanged.add(this.onAgentSuppressedStateChanged);
         }
         param1.actor.animatedAsset.gotoAndPlay(param1.getAnimation("idle"),0,true,0.05,0);
         param1.actor.mouseEnabled = this._agentsEnabled;
         if(param1.isElite)
         {
            _loc4_ = new UIEliteEnemyIndicator(param1);
            this._ui_eliteIndicatorsByEnemy[param1] = _loc4_;
            if(this._hudIndicatorsVisible)
            {
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
            }
            this.onEliteEnemySpawned(param1);
         }
         param1.dodgedAttack.add(this.onAgentDodgedAttack);
         param1.damageTaken.add(this.onAgentDamageTaken);
         param1.died.addOnce(this.onEnemyDie);
         param1.actorClicked.add(this.onEnemyClicked);
         param1.actorMouseOver.add(this.onEnemyMouseOver);
         param1.actorMouseOut.add(this.onEnemyMouseOut);
         param1.navigator.cancelAndStop();
         this.enemySpawned.dispatch(param1);
      }
      
      protected function addDeploymentZones() : void
      {
         var _loc1_:XML = null;
         var _loc2_:DeploymentZone = null;
         var _loc3_:Resource = null;
         for each(_loc1_ in this._scene.xmlDescriptor.deploy.rect)
         {
            _loc2_ = new DeploymentZone(this._scene,int(_loc1_.@x),int(_loc1_.@y),int(_loc1_.@width),int(_loc1_.@height));
            this._scene.container.addChild(_loc2_.decal);
            this._deploymentZones.push(_loc2_);
            for each(_loc3_ in _loc2_.decal.getResources(true))
            {
               this._scene.resourceUploadList.push(_loc3_);
            }
         }
      }
      
      protected function awardXP(param1:int) : int
      {
         var _loc4_:Survivor = null;
         if(this._missionData.isPvPPractice)
         {
            return 0;
         }
         param1 = Math.ceil(param1 * this._xpBonus);
         this._missionData.xpEarned += param1;
         param1 = this._network.playerData.appyRestedXPBonus(param1);
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         for each(_loc4_ in this._survivors)
         {
            if(this._missionData.isPvP || this._missionData.opponent.level > _loc4_.level - Config.constant.LEVEL_XP_RANGE)
            {
               _loc4_.XP += param1;
               _loc2_ = true;
               if(_loc4_ == this._playerSurvivor)
               {
                  _loc3_ = true;
               }
            }
         }
         if(!_loc3_)
         {
            if(this._missionData.isPvP || this._missionData.opponent.level > this._playerSurvivor.level - Config.constant.LEVEL_XP_RANGE)
            {
               this._playerSurvivor.XP += param1;
               _loc3_ = true;
               _loc2_ = true;
            }
         }
         return _loc2_ ? param1 : 0;
      }
      
      protected function awardKillXP(param1:Number, param2:AIActorAgent, param3:int = 0) : int
      {
         var _loc4_:int = Math.floor(((this._missionData.opponent.level + 1) * param1 + param1) * param2.xp_multiplier) + param3;
         _loc4_ = this.awardXP(_loc4_);
         this.addXPFloater(_loc4_,param2);
         return _loc4_;
      }
      
      protected function addXPFloater(param1:int, param2:AIActorAgent) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:UIFloatingMessage = null;
         var _loc7_:uint = 0;
         if(this._missionData.isPvPPractice)
         {
            return;
         }
         if(this._hudIndicatorsVisible)
         {
            _loc3_ = param2.actor.transform.position.x;
            _loc4_ = param2.actor.transform.position.y;
            _loc5_ = param2.actor.transform.position.z + param2.actor.getHeight() + 20;
            _loc6_ = UIFloatingMessage.pool.get() as UIFloatingMessage;
            _loc7_ = param1 > 0 ? 16363264 : 12040119;
            _loc6_.init(this._lang.getString("msg_xp_awarded",param1),_loc7_,this._scene,_loc3_,_loc4_,_loc5_,100);
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc6_);
         }
      }
      
      private function failMission() : void
      {
         TweenMax.killDelayedCallsTo(this.failMission);
         this._failedMission = true;
         this._game.pause(true);
         this._gui.removeLayer(this._guiMission,true);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.messageArea.setMessage("");
         this._failureSnapshot = new Bitmap(this._game.getSceneSnapshot());
         this._game.display.addChildAt(this._failureSnapshot,1);
         this._game.stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         TweenMax.to(this._failureSnapshot,0.5,{
            "colorTransform":{"exposure":1.75},
            "ease":Cubic.easeOut
         });
         TweenMax.to(this._failureSnapshot,1,{
            "colorMatrixFilter":{
               "colorize":16711680,
               "brightness":0.75
            },
            "colorTransform":{"exposure":1},
            "ease":Cubic.easeInOut
         });
         TweenMax.delayedCall(1.5,function():void
         {
            var dlg:EventAlertDialogue = new EventAlertDialogue("images/ui/mission-death.jpg",270,152,"center","event-mission-death",false);
            dlg.modal = false;
            dlg.addTitle(_lang.getString("mission_dead_title"),BaseDialogue.TITLE_COLOR_RUST);
            dlg.addButton(_lang.getString("mission_dead_ok"),true,{"width":200});
            dlg.closed.addOnce(function(param1:Dialogue):void
            {
               _game.stage.removeEventListener(Event.RESIZE,onStageResize);
               leaveMission();
            });
            dlg.open();
         });
      }
      
      protected function isTileInDeploymentZone(param1:int, param2:int) : Boolean
      {
         var _loc3_:DeploymentZone = null;
         for each(_loc3_ in this._deploymentZones)
         {
            if(_loc3_.rect.contains(param1,param2))
            {
               return true;
            }
         }
         return false;
      }
      
      private function endMission() : void
      {
         var _loc1_:Survivor = null;
         if(!Network.getInstance().playerData.isAdmin)
         {
            return;
         }
         if(!this._missionActive)
         {
            return;
         }
         this._missionActive = false;
         this._game.pause(true);
         this._gui.removeLayer(this._guiMission,true);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.messageArea.setMessage("");
         this._endTimer.stop();
         this._statTimer.stop();
         if(AllianceSystem.getInstance() != null)
         {
            AllianceSystem.getInstance().clearIndividualTargetCacheTime();
         }
         this.doEndMission();
      }
      
      private function leaveMission() : void
      {
         var srv:Survivor = null;
         var success:Boolean = false;
         var injInfo:Object = null;
         if(!this._missionActive)
         {
            return;
         }
         this._missionActive = false;
         this._game.pause(true);
         this._gui.removeLayer(this._guiMission,true);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.messageArea.setMessage("");
         if(this._failedMission)
         {
            this.SendMissionEvent(MissionEventTypes.FAILED_MISSION);
         }
         else
         {
            this.SendMissionEvent(MissionEventTypes.ATTACKERS_LEFT);
         }
         if(this._useDeployZones)
         {
            for each(srv in this.getSurvivorsNotInExitZones())
            {
               srv.damageTaken.remove(this.onAgentDamageTaken);
               srv.died.remove(this.onPlayerSurvivorDie);
               srv.health = 0;
            }
         }
         this._endTimer.stop();
         this._statTimer.stop();
         if(this._isPvP && this._missionData.bounty > 0)
         {
            success = false;
            for each(injInfo in this._missionData.enemyResults.survivorsDowned)
            {
               if(injInfo == null || injInfo.srv == null)
               {
                  return;
               }
               if(injInfo.srv.classId == "player")
               {
                  success = true;
                  break;
               }
            }
            this._bountyCollectDlg = new BountyCollectDialogue(success,this._missionData.opponent.nickname,this._missionData.bounty,this._missionData.bountyDate);
            this._bountyCollectDlg.onSelection.add(function(param1:Boolean):void
            {
               _missionData.bountyCollect = param1;
               if(!param1)
               {
                  _bountyCollectDlg.close();
                  _bountyCollectDlg = null;
               }
               _game.pause(true);
               doEndMission();
            });
            this._bountyCollectDlg.open();
         }
         else
         {
            this.doEndMission();
         }
      }
      
      private function doEndMission() : void
      {
         this._game.pause(true);
         this._missionData.endMission(function():void
         {
            if(_tutorial.active)
            {
               _tutorial.setState(Tutorial.STATE_MISSION_COMPLETE,_missionData);
            }
            if(_bountyCollectDlg)
            {
               _bountyCollectDlg.updateCollectionStatus(_missionData.bountyCollect,Math.floor(_missionData.bounty));
               _bountyCollectDlg.closed.addOnce(function(param1:Dialogue):void
               {
                  displayMatchSummaryOnClose();
               });
            }
            else
            {
               displayMatchSummaryOnClose();
            }
         });
      }
      
      private function displayMatchSummaryOnClose() : void
      {
         var raidObjDlg:RaidMissionEndDialogue = null;
         var arenaObjDlg:ArenaMissionEndDialogue = null;
         this._game.pause(true);
         if(this._assignmentData != null && this._assignmentData.type == AssignmentType.Raid)
         {
            raidObjDlg = new RaidMissionEndDialogue(this._raidData);
            raidObjDlg.closed.addOnce(function(param1:Dialogue):void
            {
               _gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
            });
            raidObjDlg.open();
         }
         else if(this._assignmentData != null && this._assignmentData.type == AssignmentType.Arena)
         {
            if(this._allSurvivorsDead)
            {
               this._gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
            }
            else
            {
               arenaObjDlg = new ArenaMissionEndDialogue(this._arenaData,this._missionData);
               arenaObjDlg.closed.addOnce(function(param1:Dialogue):void
               {
                  if(!_arenaData.bailOut && _arenaData.completedStageIndex < _arenaData.stageCount - 1)
                  {
                     ArenaSystem.launchSession(_arenaData,null);
                  }
                  else
                  {
                     _gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
                  }
               });
               arenaObjDlg.open();
            }
         }
         else if(this._missionData.allianceMatch == true && this._missionData.allianceRoundActive && this._missionData.allianceError == false)
         {
            this._allianceMissionSummaryDlg = new AllianceMissionSummaryDialogue(this._missionData);
            this._allianceMissionSummaryDlg.closed.addOnce(function(param1:Dialogue):void
            {
               _gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
            });
            this._allianceMissionSummaryDlg.open();
            AllianceSystem.getInstance().invalidateLifetimeStats();
         }
         else
         {
            this._gui.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
         }
      }
      
      private function healSurvivor(param1:Survivor, param2:Survivor) : void
      {
         var _loc3_:SurvivorHealingState = null;
         if(!param1.canHeal || param2.health <= 0 || param2.health >= param2.getHealableHealth() || param2.flags & AIAgentFlags.BEING_HEALED || Boolean(param2.flags & AIAgentFlags.IS_HEALING_TARGET))
         {
            return;
         }
         if(this._assignmentData != null && this._assignmentData.type == AssignmentType.Arena)
         {
            return;
         }
         _loc3_ = new SurvivorHealingState(param1,param2);
         _loc3_.started.addOnce(this.onSurvivorHealStarted);
         _loc3_.cancelled.addOnce(this.onSurvivorHealCancelled);
         _loc3_.completed.addOnce(this.onSurvivorHealCompleted);
         param1.stateMachine.setState(_loc3_);
         if(param1 != param2 && Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_HEALSTART)
         {
            this.startSurvivorSpeech(param1,"healstart");
         }
      }
      
      private function disarmTrap(param1:Survivor, param2:Building) : void
      {
         if(param1 == null || !param1.canDisarmTraps || param2 == null || !param2.isTrap)
         {
            return;
         }
         if((param2.flags & EntityFlags.TRAP_DETECTED) == 0 || Boolean(param2.flags & (EntityFlags.TRAP_BEING_DISARMED | EntityFlags.TRAP_DISARMED)))
         {
            return;
         }
         var _loc3_:SurvivorDisarmTrapState = new SurvivorDisarmTrapState(param1,param2);
         _loc3_.started.addOnce(this.onTrapDisarmStarted);
         _loc3_.cancelled.addOnce(this.onTrapDisarmComplete);
         _loc3_.completed.addOnce(this.onTrapDisarmComplete);
         _loc3_.triggered.addOnce(this.onTrapDisarmTriggered);
         param1.stateMachine.setState(_loc3_);
      }
      
      protected function selectSurvivor(param1:Survivor, param2:Boolean = true) : void
      {
         var _loc3_:UISurvivorIndicator = null;
         var _loc4_:UISelectedIndicator = null;
         var _loc5_:UIRangeIndicator = null;
         var _loc6_:Vector3D = null;
         if(this._scene == null || this._scene.map == null)
         {
            return;
         }
         if(this._actionMode)
         {
            if(param1 != null && this._selectedSurvivor != null && this._selectedSurvivor.canHeal)
            {
               if(this._assignmentData == null || this._assignmentData.type != AssignmentType.Arena)
               {
                  this.healSurvivor(this._selectedSurvivor,param1);
                  return;
               }
            }
         }
         this.setActiveGearMode(ActiveGearMode.NONE);
         if(param1 != null)
         {
            if(this._selectedSurvivor == param1)
            {
               if(this._selectedSurvivor.actor != null && param2)
               {
                  _loc6_ = this._selectedSurvivor.actor.transform.position;
                  this._scene.panTo(_loc6_.x,_loc6_.y,_loc6_.z);
               }
               return;
            }
            if(param1.health <= 0 || Boolean(param1.flags & AIAgentFlags.LOCKED))
            {
               return;
            }
         }
         if(this._selectedSurvivor != null)
         {
            _loc3_ = this._ui_survivorIndicatorsBySurvivor[this._selectedSurvivor];
            if(_loc3_ != null)
            {
               _loc3_.showName = false;
               _loc3_.showAmmo = false;
               _loc3_.showHealth = this._selectedSurvivor.injuries.length > 0 || this._selectedSurvivor.health < this._selectedSurvivor.maxHealth;
            }
            _loc4_ = this._ui_selectedIndicatorsBySurvivor[this._selectedSurvivor];
            if(_loc4_ != null)
            {
               this._scene.removeEntity(_loc4_);
            }
            _loc5_ = this._ui_rangeIndicatorsBySurvivor[this._selectedSurvivor];
            if(_loc5_ != null)
            {
               this._scene.removeEntity(_loc5_);
            }
         }
         this._selectedSurvivor = param1;
         if(this._guiMission != null && this._guiMission.ui_survivorBar != null)
         {
            this._guiMission.ui_survivorBar.selectSurvivor(this._selectedSurvivor);
         }
         if(this._selectedSurvivor == null)
         {
            this._scene.mouseMap.tileClicked.remove(this.onTileClicked);
            this._scene.mouseMap.tileMouseOver.remove(this.onTileMouseOver);
            this._scene.mouseMap.tileMouseOut.remove(this.onTileMouseOut);
            this._scene.mouseMap.enabled = false;
            this.updateMouseCursor();
            return;
         }
         _loc3_ = this._ui_survivorIndicatorsBySurvivor[this._selectedSurvivor];
         if(_loc3_ != null)
         {
            _loc3_.showName = true;
            _loc3_.showAmmo = true;
            _loc3_.showHealth = true;
            if(_loc3_.parent != null)
            {
               _loc3_.parent.setChildIndex(_loc3_,_loc3_.parent.numChildren - 1);
            }
         }
         _loc4_ = this._ui_selectedIndicatorsBySurvivor[this._selectedSurvivor];
         if(_loc4_ != null)
         {
            _loc4_.transitionIn();
            this._scene.addEntity(_loc4_);
         }
         if(this._selectedSurvivor.weaponData != null && !this._selectedSurvivor.weaponData.isMelee && !(this._selectedSurvivor.stateMachine.state is ActorScavengeState))
         {
            this.showRangeIndicator();
         }
         this._scene.mouseMap.tileClicked.add(this.onTileClicked);
         this._scene.mouseMap.tileMouseOver.add(this.onTileMouseOver);
         this._scene.mouseMap.tileMouseOut.add(this.onTileMouseOut);
         this._scene.mouseMap.enabled = true;
         if(this._gui != null && Boolean(this._gui.messageArea))
         {
            if(this._selectedSurvivor.canHeal && this._runningTime > 4)
            {
               this._gui.messageArea.setMessage(this._lang.getString("msg_space_heal"),6,Effects.COLOR_GOOD);
            }
            else
            {
               this._gui.messageArea.setMessage("");
            }
         }
      }
      
      private function selectNextSurvivor() : void
      {
         if(this._allSurvivorsDead)
         {
            this._selectedSurvivor = null;
            return;
         }
         var _loc1_:int = this._survivors.indexOf(this._selectedSurvivor) + 1;
         if(_loc1_ >= this._survivors.length)
         {
            _loc1_ = 0;
         }
         var _loc2_:Survivor = this._survivors[_loc1_] as Survivor;
         if(_loc2_.health <= 0)
         {
            this._selectedSurvivor = _loc2_;
            this.selectNextSurvivor();
         }
         else
         {
            this.selectSurvivor(_loc2_);
         }
      }
      
      protected function scavengeEntity(param1:Survivor, param2:GameEntity) : void
      {
         if(!this._missionActive || param1 == null || param1.health <= 0 || Boolean(param1.flags & (AIAgentFlags.LOCKED | AIAgentFlags.MOUNTED | AIAgentFlags.IMMOVEABLE)))
         {
            return;
         }
         if(this._missionData.isPvPPractice)
         {
            return;
         }
         if(Boolean(param2.flags & EntityFlags.BEING_SCAVENGED) || Boolean(param2.flags & EntityFlags.SCAVENGED))
         {
            return;
         }
         var _loc3_:ActorScavengeState = new ActorScavengeState(param1,param2);
         _loc3_.started.addOnce(this.onScavengeStarted);
         _loc3_.cancelled.addOnce(this.onScavengeCancelled);
         _loc3_.completed.addOnce(this.onScavengeComplete);
         param1.stateMachine.setState(_loc3_);
         if(!(param2 is StadiumButtonEntity))
         {
            if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_SCAVENGESTART)
            {
               this.startSurvivorSpeech(param1,"scavengestart");
            }
         }
      }
      
      private function getSurvivorsNotInExitZones() : Vector.<Survivor>
      {
         var _loc2_:Survivor = null;
         var _loc3_:Cell = null;
         var _loc1_:Vector.<Survivor> = new Vector.<Survivor>();
         for each(_loc2_ in this._survivors)
         {
            if(_loc2_.health > 0)
            {
               _loc3_ = this._scene.map.getCellAtCoords(_loc2_.actor.transform.position.x,_loc2_.actor.transform.position.y);
               if(_loc3_ != null)
               {
                  if(!this.isTileInDeploymentZone(_loc3_.x,_loc3_.y))
                  {
                     _loc1_.push(_loc2_);
                  }
               }
            }
         }
         return _loc1_;
      }
      
      private function cleanSurvivor(param1:Survivor) : void
      {
         TweenMaxDelta.killTweensOf(param1.actor.asset);
         if(param1.agentData.currentNoiseSource != null)
         {
            this._scene.removeNoiseSource(param1.agentData.currentNoiseSource);
            param1.agentData.currentNoiseSource.dispose();
            param1.agentData.currentNoiseSource = null;
         }
         param1.flags = AIAgentFlags.NONE;
         param1.stateMachine.clear();
         param1.blackboard.erase();
         param1.mountedBuilding = null;
         param1.agentData.clearForcedTarget();
         param1.agentData.target = null;
         this.clearCoverRating(param1);
         this._game.rvoSimulator.removeAgent(param1.navigator);
         param1.navigator.cancelAndStop();
         param1.navigator.map = null;
         param1.navigator.targetUnreachable.remove(this.onSurvivorTargetUnreachable);
         param1.damageTaken.remove(this.onAgentDamageTaken);
         param1.died.remove(this.onPlayerSurvivorDie);
         param1.reloadStarted.remove(this.onSurvivorReload);
         param1.actorClicked.remove(this.onSurvivorClicked);
         param1.actorMouseOver.remove(this.onSurvivorMouseOver);
         param1.actorMouseOut.remove(this.onSurvivorMouseOut);
         param1.levelIncreased.remove(this.onSurvivorLevelIncreased);
         param1.movementStarted.remove(this.onSurvivorMovementStarted);
         param1.movementStopped.remove(this.onSurvivorMovementStopped);
         param1.noiseGenerated.remove(this.onSurvivorNoiseGenerated);
         param1.detectedTraps.remove(this.onSurvivorTrapDetected);
         param1.mountedBuildingChanged.remove(this.onSurvivorMountedBuildingChanged);
         param1.suppressedStateChanged.remove(this.onAgentSuppressedStateChanged);
         param1.dodgedAttack.remove(this.onAgentDodgedAttack);
         param1.missedAttack.remove(this.onAgentMissedAttack);
         param1.killedEnemy.remove(this.onAgentKilledEnemy);
         param1.injuries.added.remove(this.onSurvivorInjuryAdded);
      }
      
      private function updateTimeRemaining(param1:Number = 0) : void
      {
         var _loc2_:MiniTask = null;
         if(!this._missionActive)
         {
            return;
         }
         this._timeRemaining = this._timeMission - (getTimer() - this._timeStart) / 1000;
         this._guiMission.ui_timer.time = this._timeRemaining;
         if(!this._isCompoundAttack && !this._lowTimeTaskDone && !this._arenaData)
         {
            _loc2_ = MiniTaskSystem.getInstance().getAchievement("lowtime");
            if(this._timeRemaining < _loc2_.minValue)
            {
               _loc2_.increment(_loc2_.minValue);
               this._lowTimeTaskDone = true;
            }
         }
         if(this._timeRemaining <= 0)
         {
            this.onTimeExpired();
         }
      }
      
      protected function fireTriggers(param1:uint, param2:GameEntity) : void
      {
         var _loc5_:String = null;
         var _loc3_:Vector.<String> = param2.getTriggers(param1);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            this._missionData.incrementTrigger(_loc5_);
            _loc4_++;
         }
      }
      
      protected function clearCoverRating(param1:AIActorAgent) : void
      {
         var _loc2_:CoverEntity = null;
         if(param1.agentData.coverEntities != null)
         {
            for each(_loc2_ in param1.agentData.coverEntities)
            {
               _loc2_.removeAgentFromCover(param1);
            }
         }
         param1.agentData.coverRating = 0;
         param1.agentData.coverEntities = null;
      }
      
      protected function updateCoverRating(param1:AIActorAgent) : void
      {
         var _loc4_:CoverEntity = null;
         this.clearCoverRating(param1);
         var _loc2_:Cell = this._scene.map.getCellAtCoords(param1.navigator.position.x,param1.navigator.position.y);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:CoverData = this._scene.getCoverData(_loc2_);
         if(_loc3_ == null)
         {
            return;
         }
         param1.agentData.coverRating = _loc3_.rating;
         param1.agentData.coverEntities = _loc3_.entities.concat();
         for each(_loc4_ in param1.agentData.coverEntities)
         {
            _loc4_.addAgentToCover(param1);
         }
      }
      
      protected function updateCoverRatingsForAgents(param1:Vector.<AIActorAgent>) : void
      {
         var _loc2_:AIActorAgent = null;
         if(param1 == null)
         {
            return;
         }
         for each(_loc2_ in param1)
         {
            if(!(_loc2_ is Zombie))
            {
               this.updateCoverRating(_loc2_);
            }
         }
      }
      
      protected function setSuppressionIndicatorState(param1:AIActorAgent, param2:Boolean) : void
      {
         var _loc3_:UISuppressedIndicator = this._ui_suppressionIndicatorsByAgent[param1];
         if(_loc3_ == null)
         {
            _loc3_ = new UISuppressedIndicator(param1);
            this._ui_suppressionIndicatorsByAgent[param1] = _loc3_;
         }
         if(param2)
         {
            if(_loc3_.parent == null)
            {
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc3_);
            }
         }
         else if(_loc3_.parent != null)
         {
            _loc3_.parent.removeChild(_loc3_);
         }
      }
      
      protected function setActionModeState(param1:Boolean) : void
      {
         if(param1 == this._actionMode)
         {
            return;
         }
         if(param1 && this._selectedSurvivor == null)
         {
            return;
         }
         if(this._activeGearMode != ActiveGearMode.NONE)
         {
            return;
         }
         this._actionMode = param1;
         this._scene.mouseMap.enabled = this._selectedSurvivor != null;
         this.updateMouseCursor();
      }
      
      private function updateMouseCursor() : void
      {
         if(this._actionMode)
         {
            MouseCursors.setCursor(MouseCursors.ACTION_MODE);
            if(this._mouseOverAgent != null)
            {
               if(this._survivors.indexOf(this._mouseOverAgent) > -1)
               {
                  this.onSurvivorMouseOver(this._mouseOverAgent as Survivor);
               }
               else
               {
                  this.onEnemyMouseOver(this._mouseOverAgent);
               }
            }
         }
         else
         {
            MouseCursors.setCursor(MouseCursors.DEFAULT);
         }
      }
      
      private function showRangeIndicator() : void
      {
         if(this._selectedSurvivor == null || this._selectedSurvivor.navigator.isMoving || this._selectedSurvivor.weaponData.isMelee || !this._hudIndicatorsVisible)
         {
            return;
         }
         var _loc1_:UIRangeIndicator = this._ui_rangeIndicatorsBySurvivor[this._selectedSurvivor];
         if(_loc1_ != null)
         {
            _loc1_.range = this._selectedSurvivor.weaponData.range;
            _loc1_.minRange = this._selectedSurvivor.weaponData.minRange;
            _loc1_.minEffectiveRange = this._selectedSurvivor.weaponData.minEffectiveRange;
            _loc1_.yellow = this._selectedSurvivor.agentData.suppressed;
            if(_loc1_.scene == null)
            {
               _loc1_.entity = this._selectedSurvivor.entity;
               if(!_loc1_.asset.visible)
               {
                  _loc1_.transitionIn();
               }
               this._scene.addEntity(_loc1_);
            }
            _loc1_.asset.visible = true;
         }
      }
      
      protected function startSurvivorSpeech(param1:Survivor, param2:String, param3:Boolean = false) : void
      {
         var bubble:UISpeechBubble;
         var options:XMLList = null;
         var speechNode:XML = null;
         var audioURI:String = null;
         var ui_survivor:UISurvivorIndicator = null;
         var srv:Survivor = param1;
         var category:String = param2;
         var force:Boolean = param3;
         if(srv == null || srv.health <= 0 || this._survivors.length <= 1)
         {
            return;
         }
         if(!force && this._time - this._lastSurvivorTalkTime < Config.constant.SURVIVOR_TALK_COOLDOWN * 1000)
         {
            return;
         }
         bubble = this._ui_speechBySurvivor[srv];
         if(bubble != null)
         {
            bubble.dispose();
            delete this._ui_speechBySurvivor[srv];
         }
         options = this._lang.xml.data.speech.children().(localName() == srv.voicePack)[category].s;
         if(options == null)
         {
            return;
         }
         speechNode = options[int(Math.random() * options.length())];
         if(speechNode == null)
         {
            return;
         }
         if(Settings.getInstance().voices)
         {
            audioURI = "sound/voices/" + srv.voicePack + "-" + category + (speechNode.childIndex() + 1) + ".mp3";
            srv.soundSource.play(audioURI.toLowerCase(),{
               "volume":Config.constant.SURVIVOR_TALK_VOLUME,
               "minDistance":Config.constant.SURVIVOR_TALK_MIN_DISTANCE,
               "maxDistance":Config.constant.SURVIVOR_TALK_MAX_DISTANCE
            });
         }
         else
         {
            bubble = new UISpeechBubble(srv,speechNode.toString(),1,2.5);
            bubble.transitionIn();
            bubble.timerCompleted.addOnce(function():void
            {
               delete _ui_speechBySurvivor[srv];
               if(_ui_survivorIndicatorsBySurvivor[srv] != null)
               {
                  _ui_survivorIndicatorsBySurvivor[srv].visible = _hudIndicatorsVisible;
               }
            });
            this._ui_speechBySurvivor[srv] = bubble;
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(bubble);
            ui_survivor = this._ui_survivorIndicatorsBySurvivor[srv];
            if(ui_survivor != null)
            {
               ui_survivor.visible = false;
            }
         }
         this._lastSurvivorTalkTime = this._time;
      }
      
      private function cancelSurvivorSpeech(param1:Survivor) : void
      {
         var _loc2_:UISpeechBubble = this._ui_speechBySurvivor[param1];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.dispose();
         delete this._ui_speechBySurvivor[param1];
         var _loc3_:UISurvivorIndicator = this._ui_survivorIndicatorsBySurvivor[param1];
         if(_loc3_ != null)
         {
            _loc3_.visible = true;
         }
      }
      
      private function toggleActiveGearMode() : void
      {
         if(this._activeGearMode != ActiveGearMode.NONE)
         {
            this.setActiveGearMode(ActiveGearMode.NONE);
            return;
         }
         if(this._selectedSurvivor == null || this._selectedSurvivor.health <= 0)
         {
            return;
         }
         var _loc1_:Gear = this._selectedSurvivor.activeLoadout.gearActive.item as Gear;
         if(_loc1_ == null || _loc1_.quantity <= 0 || this._selectedSurvivor.activeLoadout.gearActive.quantity <= 0)
         {
            return;
         }
         switch(_loc1_.gearClass)
         {
            case GearClass.GRENADE:
               this.setActiveGearMode(ActiveGearMode.THROW);
               break;
            case GearClass.EXPLOSIVE_CHARGE:
               this.setActiveGearMode(ActiveGearMode.PLACE);
               break;
            case GearClass.STIM:
               this.setActiveGearMode(ActiveGearMode.SELF);
         }
      }
      
      private function setActiveGearMode(param1:uint) : void
      {
         var _loc2_:Gear = null;
         var _loc3_:AIActorAgent = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:UIRangeIndicator = null;
         var _loc7_:Number = NaN;
         if(param1 == this._activeGearMode)
         {
            return;
         }
         if(param1 == ActiveGearMode.NONE)
         {
            this._throwTrajectory = null;
            if(this.ui_throwCursor.scene != null)
            {
               this._scene.removeEntity(this.ui_throwCursor);
            }
            this.setAgentsEnabled(true);
            this.setScavengingEnabled(true);
            this._selectedSurvivor.flags &= ~(AIAgentFlags.TARGETING_DISABLED | AIAgentFlags.RELOAD_DISABLED);
            this._activeGearMode = param1;
            if(!this._selectedSurvivor.weaponData.isMelee)
            {
               this.showRangeIndicator();
            }
            else
            {
               _loc6_ = this._ui_rangeIndicatorsBySurvivor[this._selectedSurvivor];
               if(_loc6_ != null)
               {
                  _loc6_.asset.visible = false;
               }
            }
            return;
         }
         if(this._actionMode || !this._missionActive || this._selectedSurvivor == null || this._selectedSurvivor.health <= 0 || this._selectedSurvivor.agentData.reloading || Boolean(this._selectedSurvivor.flags & (AIAgentFlags.LOCKED | AIAgentFlags.MOUNTED | AIAgentFlags.IMMOVEABLE)))
         {
            return;
         }
         _loc2_ = this._selectedSurvivor.activeLoadout.gearActive.item as Gear;
         if(_loc2_ == null || _loc2_.quantity <= 0 || this._selectedSurvivor.activeLoadout.gearActive.quantity <= 0)
         {
            return;
         }
         this._activeGearMode = param1;
         switch(this._activeGearMode)
         {
            case ActiveGearMode.PLACE:
            case ActiveGearMode.SELF:
               this.useActiveGear(this._selectedSurvivor);
               break;
            case ActiveGearMode.THROW:
               this._throwTrajectory = new ThrowTrajectoryData();
               _loc4_ = _loc2_.attributes.getValue(ItemAttributes.GROUP_GEAR,"throwrngmin") * 100;
               _loc5_ = _loc2_.attributes.getValue(ItemAttributes.GROUP_GEAR,"throwrngmax") * 100;
               if(this._selectedSurvivor.agentData.suppressed)
               {
                  _loc7_ = _loc4_ + 100;
                  _loc5_ = _loc7_ + (_loc5_ - _loc7_) * Config.constant.SUPPRESSION_THROW_PENALTY;
               }
               this._throwTrajectory.maxThrowRange = _loc5_;
               this._throwTrajectory.minThrowRange = _loc4_;
               this.setAgentsEnabled(false);
               this.setScavengingEnabled(false);
               this._scene.addEntity(this.ui_throwCursor);
               this.ui_throwCursor.range = _loc2_.attributes.getValue(ItemAttributes.GROUP_GEAR,"rng") * 100;
               this.ui_throwCursor.transform.position.setTo(this._scene.mouseMap.mousePt.x,this._scene.mouseMap.mousePt.y,0);
               this.ui_throwCursor.transitionIn();
               _loc6_ = this._ui_rangeIndicatorsBySurvivor[this._selectedSurvivor];
               if(_loc6_ != null && this._hudIndicatorsVisible)
               {
                  _loc6_.range = this._throwTrajectory.maxThrowRange;
                  _loc6_.minRange = this._throwTrajectory.minThrowRange;
                  _loc6_.minEffectiveRange = 0;
                  _loc6_.yellow = this._selectedSurvivor.agentData.suppressed;
                  if(!_loc6_.asset.visible)
                  {
                     _loc6_.transitionIn();
                  }
                  _loc6_.asset.visible = true;
                  this._scene.addEntity(_loc6_);
               }
               this._selectedSurvivor.cancelReload();
               this._selectedSurvivor.navigator.cancelAndStop();
               this._selectedSurvivor.stateMachine.setState(null);
               this._selectedSurvivor.flags |= AIAgentFlags.TARGETING_DISABLED | AIAgentFlags.RELOAD_DISABLED;
         }
      }
      
      private function useActiveGear(param1:Survivor, ... rest) : void
      {
         var qty:int = 0;
         var gear:Gear = null;
         var healAmount:Number = NaN;
         var placeState:SurvivorPlaceItemState = null;
         var throwState:SurvivorThrowState = null;
         var healable:Number = NaN;
         var effect:IAIEffect = null;
         var survivor:Survivor = param1;
         var args:Array = rest;
         if(survivor == null || survivor.health <= 0)
         {
            return;
         }
         gear = survivor.activeLoadout.gearActive.item as Gear;
         if(gear == null || gear.quantity == 0)
         {
            return;
         }
         switch(gear.gearClass)
         {
            case GearClass.STIM:
               healAmount = Math.min(survivor.maxHealth * gear.attributes.getValue(ItemAttributes.GROUP_GEAR,"heal"),Number(Config.constant.MAX_STIM_HEAL));
               if(healAmount > 0)
               {
                  healable = survivor.getHealableHealth();
                  healAmount = Math.min(healAmount,healable);
                  survivor.health += healAmount;
               }
               if(gear.activeAttributes != null)
               {
                  effect = new GenericEffect(survivor,gear.activeAttributes,gear.attributes.getValue(ItemAttributes.GROUP_GEAR,"dur"));
                  survivor.effectEngine.addEffect(effect);
                  survivor.updateMaxSpeed();
               }
               this.useEquippedConsumeableItem(survivor,gear,1);
               Audio.sound.play(gear.getSound("use"));
               break;
            case GearClass.EXPLOSIVE_CHARGE:
               placeState = new SurvivorPlaceItemState(survivor,gear);
               placeState.placed.addOnce(function(param1:ExplosiveChargeEntity):void
               {
                  placeState.placed.remove(arguments.callee);
                  useEquippedConsumeableItem(survivor,gear,1);
                  _gui.getLayerAsSprite(_gui.SCENE_LAYER_NAME).addChild(param1.ui_timer);
               });
               survivor.stateMachine.setState(placeState);
               this.SendMissionEvent(MissionEventTypes.EXPLOSIVE_PLACED,gear.type,survivor.id);
               break;
            case GearClass.GRENADE:
               if(this._throwTrajectory == null)
               {
                  return;
               }
               if(!this._throwTrajectory.valid)
               {
                  if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_NOTHROW)
                  {
                     this.startSurvivorSpeech(this._selectedSurvivor,"nothrow");
                  }
                  Audio.sound.play("sound/interface/int-error.mp3");
                  return;
               }
               throwState = new SurvivorThrowState(survivor,gear,this._throwTrajectory);
               throwState.thrown.addOnce(function():void
               {
                  throwState.thrown.remove(arguments.callee);
                  useEquippedConsumeableItem(survivor,gear,1);
                  SendMissionEvent(MissionEventTypes.GRENADE_THROWN,gear.type,survivor.id);
               });
               survivor.stateMachine.setState(throwState);
         }
         this.setActiveGearMode(ActiveGearMode.NONE);
      }
      
      private function useEquippedConsumeableItem(param1:Survivor, param2:Item, param3:int = 1) : void
      {
         var _loc5_:Gear = null;
         var _loc4_:SurvivorLoadoutData = param1.activeLoadout.getDataForItem(param2);
         if(_loc4_ == null || param2 == null)
         {
            return;
         }
         --_loc4_.quantity;
         if(!this._missionData.isPvPPractice)
         {
            Network.getInstance().save({
               "srv":param1.id,
               "loadout":param1.activeLoadout.type,
               "item":param2.id,
               "qty":param3
            },SaveDataMethod.MISSION_ITEM_USE);
            if(--param2.quantity <= 0)
            {
               Network.getInstance().playerData.inventory.removeItem(param2);
            }
            _loc5_ = param2 as Gear;
            if(_loc5_ != null && _loc5_.xml != null)
            {
               switch(_loc5_.gearClass)
               {
                  case GearClass.EXPLOSIVE_CHARGE:
                     Tracking.trackEvent("Mission","ExplosiveChargePlaced",_loc5_.type,1);
                     if(this._raidData != null)
                     {
                        Tracking.trackEvent("Raid","ExplosiveChargePlaced",this._raidData.name + "_" + this._raidData.currentStageIndex);
                     }
                     if(_loc5_.gearType & GearType.EXPLOSIVE)
                     {
                        ++this._missionData.stats.explosivesPlaced;
                     }
                     break;
                  case GearClass.GRENADE:
                     Tracking.trackEvent("Mission","GrenadeThrown",_loc5_.type,1);
                     ++this._missionData.stats.grenadesThrown;
                     if(this._raidData != null)
                     {
                        Tracking.trackEvent("Raid","GrenadeThrown",this._raidData.name + "_" + this._raidData.currentStageIndex);
                     }
                     if(_loc5_.xml.gear.exp.toString() == "smoke")
                     {
                        ++this._missionData.stats.grenadesSmokeThrown;
                        Tracking.trackEvent("Mission","SmokeGrenadeThrown",_loc5_.type,1);
                        if(this._raidData != null)
                        {
                           Tracking.trackEvent("Raid","SmokeGrenadeThrown",this._raidData.name + "_" + this._raidData.currentStageIndex);
                        }
                     }
               }
            }
         }
      }
      
      private function setScavengingEnabled(param1:Boolean) : void
      {
         var _loc2_:GameEntity = null;
         this._scavengingEnabled = param1;
         for each(_loc2_ in this._scene.searchableEntities)
         {
            _loc2_.asset.mouseEnabled = this._scavengingEnabled && (_loc2_.flags & EntityFlags.SCAVENGED) == 0;
         }
      }
      
      private function setAgentsEnabled(param1:Boolean) : void
      {
         var _loc2_:AIAgent = null;
         this._agentsEnabled = param1;
         for each(_loc2_ in this._allAgents)
         {
            if(_loc2_ is AIActorAgent)
            {
               AIActorAgent(_loc2_).actor.mouseEnabled = this._agentsEnabled && !this._actionMode && _loc2_.health > 0 && _loc2_.agentData.inLOS;
            }
         }
      }
      
      private function updateThrowTrajectory(param1:ThrowTrajectoryData, param2:Survivor, param3:Vector3D) : void
      {
         var _loc15_:Object3D = null;
         var _loc16_:BoundBox = null;
         var _loc17_:Number = NaN;
         param1.obstructed = false;
         param1.target.copyFrom(param3);
         var _loc4_:Cell = this._scene.map.getCellAtCoords(param3.x,param3.y);
         if(_loc4_ == null || !this._scene.map.isPassableCell(_loc4_))
         {
            param1.obstructed = true;
            param1.valid = this.ui_throwCursor.valid = false;
            return;
         }
         param1.origin.copyFrom(param2.actor.transform.position);
         param1.origin.z += 10;
         var _loc5_:Number = param3.x - param1.origin.x;
         var _loc6_:Number = param3.y - param1.origin.y;
         var _loc7_:Number = _loc5_ * _loc5_ + _loc6_ * _loc6_;
         var _loc8_:Number = param1.maxThrowRange * param1.maxThrowRange;
         if(_loc7_ > _loc8_)
         {
            param1.valid = this.ui_throwCursor.valid = false;
            return;
         }
         var _loc9_:Number = param1.minThrowRange * param1.minThrowRange;
         if(_loc7_ <= _loc9_)
         {
            param1.valid = this.ui_throwCursor.valid = false;
            return;
         }
         this._scene.container.localToGlobal(param1.origin,param1.globalOrigin);
         this._scene.container.localToGlobal(param1.target,param1.globalTarget);
         if(!this._lineOfSight.isPointVisible2(this._scene,param1.globalOrigin,param1.globalTarget,250))
         {
            param1.valid = this.ui_throwCursor.valid = false;
            return;
         }
         var _loc10_:Number = Math.sqrt(_loc7_);
         var _loc11_:Number = _loc5_ / _loc10_;
         var _loc12_:Number = _loc6_ / _loc10_;
         var _loc13_:Boolean = true;
         var _loc14_:GameEntity = this._scene.entityListHead;
         while(_loc14_ != null)
         {
            if(!(_loc14_ is Actor || !_loc14_.losVisible && !_loc14_ is BuildingEntity || _loc14_.asset == null || _loc14_.asset is Light3D || _loc14_ is OmniLightEntity))
            {
               _loc15_ = _loc14_.asset;
               _loc16_ = _loc14_.asset.boundBox;
               _loc17_ = _loc16_.maxZ - _loc16_.minZ;
               if(_loc17_ > 10)
               {
                  _loc14_.asset.globalToLocal(param1.globalOrigin,param1.localOrigin);
                  _loc14_.asset.globalToLocal(param1.globalTarget,param1.localTarget);
                  param1.direction.setTo(param1.localTarget.x - param1.localOrigin.x,param1.localTarget.y - param1.localOrigin.y,param1.localTarget.z - param1.localOrigin.z);
                  param1.direction.normalize();
                  if(_loc14_.asset.boundBox.intersectRay(param1.localOrigin,param1.direction))
                  {
                     param1.obstructed = true;
                     if(_loc14_.losVisible)
                     {
                        if(_loc17_ >= 300)
                        {
                           _loc13_ = false;
                           break;
                        }
                        _loc5_ = _loc14_.transform.position.x + _loc11_ * _loc17_ - param1.origin.x;
                        _loc6_ = _loc14_.transform.position.y + _loc12_ * _loc17_ - param1.origin.y;
                        if(_loc7_ <= _loc5_ * _loc5_ + _loc6_ * _loc6_)
                        {
                           _loc13_ = false;
                           break;
                        }
                     }
                  }
               }
            }
            _loc14_ = _loc14_.next;
         }
         this.ui_throwCursor.valid = param1.valid = _loc13_;
      }
      
      protected function getRandomLivingSurvivor() : Survivor
      {
         var _loc2_:Survivor = null;
         if(this._allSurvivorsDead)
         {
            return null;
         }
         var _loc1_:Survivor = null;
         while(_loc1_ == null)
         {
            _loc2_ = Survivor(this._survivors[int(Math.random() * this._survivors.length)]);
            if(_loc2_.health > 0)
            {
               _loc1_ = _loc2_;
            }
         }
         return _loc1_;
      }
      
      protected function SendMissionEvent(param1:String, ... rest) : void
      {
         var _loc5_:* = undefined;
         if(!this._isPvP)
         {
            return;
         }
         var _loc3_:Connection = Network.getInstance().connection;
         var _loc4_:Message = _loc3_.createMessage(NetworkMessage.MISSION_EVENT,param1);
         for each(_loc5_ in rest)
         {
            _loc4_.add(_loc5_);
         }
         _loc3_.sendMessage(_loc4_);
      }
      
      protected function flagFirstInteraction() : void
      {
         if(this._firstInteractionFlag)
         {
            return;
         }
         this._firstInteractionFlag = true;
         this._missionData.sendFirstInteractionFlag();
      }
      
      private function onGUISurvivorSelected(param1:Survivor) : void
      {
         var _loc2_:Survivor = this._selectedSurvivor;
         this.flagFirstInteraction();
         this.selectSurvivor(param1);
         if(this._actionMode && _loc2_ != this._selectedSurvivor)
         {
            this.setActionModeState(false);
         }
      }
      
      private function onGUIActiveGearSelected(param1:Survivor) : void
      {
         if(param1 == this._selectedSurvivor)
         {
            this.toggleActiveGearMode();
         }
      }
      
      private function onLeaveRequested() : void
      {
         this._guiMission.showLeaveConfirm(this.getSurvivorsNotInExitZones().length == 0);
      }
      
      private function onLeaveOpened() : void
      {
         this._guiMission.ui_survivorBar.survivorsNotInExitZones = this.getSurvivorsNotInExitZones();
      }
      
      protected function onSearchableEntityClicked(param1:GameEntity) : void
      {
         if(this._selectedSurvivor == null)
         {
            return;
         }
         this.scavengeEntity(this._selectedSurvivor,param1);
      }
      
      protected function onSearchableEntityMouseOver(param1:GameEntity) : void
      {
         if(this._selectedSurvivor == null || Boolean(param1.flags & EntityFlags.BEING_SCAVENGED))
         {
            return;
         }
         this.ui_entityRollover.entity = param1;
         this.ui_entityRollover.label = null;
         this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(this.ui_entityRollover);
         MouseCursors.setCursor(MouseCursors.INTERACT);
         this._gui.messageArea.setMessage(this._lang.getString("msg_click_search"),3);
      }
      
      protected function onSearchableEntityMouseOut(param1:GameEntity) : void
      {
         this.ui_entityRollover.entity = null;
         this.ui_entityRollover.label = null;
         if(this.ui_entityRollover.parent != null)
         {
            this.ui_entityRollover.parent.removeChild(this.ui_entityRollover);
         }
         this.updateMouseCursor();
      }
      
      protected function onTrapMouseOver(param1:Building) : void
      {
         if(this._selectedSurvivor == null)
         {
            return;
         }
         this.ui_entityRollover.entity = param1.buildingEntity;
         if(!this._gui.contains(this.ui_entityRollover))
         {
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(this.ui_entityRollover);
         }
         MouseCursors.setCursor(MouseCursors.INTERACT);
         var _loc2_:Number = this._selectedSurvivor.getTrapDisarmChance(param1);
         var _loc3_:Number = _loc2_;
         if(_loc3_ < 0.3)
         {
            _loc3_ = 0.3;
         }
         if(_loc3_ > 0.8)
         {
            _loc3_ = 0.8;
         }
         var _loc4_:uint = Color.interpolate(9685861,14483456,1 - _loc3_);
         this._gui.messageArea.setMessage(this._lang.getString("msg_click_disarm","<font color=\'" + Color.colorToHex(_loc4_) + "\'>" + Math.floor(_loc2_ * 100) + "%</font>"),3);
      }
      
      protected function onTrapMouseOut(param1:Building) : void
      {
         this.ui_entityRollover.entity = null;
         if(this.ui_entityRollover.parent != null)
         {
            this.ui_entityRollover.parent.removeChild(this.ui_entityRollover);
         }
         this.updateMouseCursor();
      }
      
      protected function onTrapClicked(param1:Building) : void
      {
         this.disarmTrap(this._selectedSurvivor,param1);
      }
      
      protected function onTrapDisarmStarted(param1:Survivor, param2:Building) : void
      {
         var _loc5_:UIDisarmProgress = null;
         var _loc3_:UIRangeIndicator = this._ui_rangeIndicatorsBySurvivor[param1];
         if(_loc3_.scene != null)
         {
            this._scene.removeEntity(_loc3_);
         }
         var _loc4_:UIBuildingIcon = this._ui_trapDetectedByBuilding[param2];
         if(_loc4_ != null)
         {
            if(_loc4_.parent != null)
            {
               _loc4_.parent.removeChild(_loc4_);
            }
         }
         if(this._hudIndicatorsVisible)
         {
            _loc5_ = this._ui_trapDisarmBySurvivor[param1];
            if(_loc5_ == null)
            {
               _loc5_ = new UIDisarmProgress(param1,param2.entity);
               this._ui_trapDisarmBySurvivor[param1] = _loc5_;
            }
            _loc5_.entity = param2.entity;
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc5_);
         }
      }
      
      protected function onTrapDisarmComplete(param1:Survivor, param2:Building) : void
      {
         var _loc4_:UIBuildingIcon = null;
         var _loc5_:int = 0;
         if(this._hudIndicatorsVisible)
         {
            _loc4_ = this._ui_trapDetectedByBuilding[param2];
            if(_loc4_ != null)
            {
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
            }
         }
         var _loc3_:UIDisarmProgress = this._ui_trapDisarmBySurvivor[param1];
         if(_loc3_ != null)
         {
            _loc3_.entity = null;
            if(_loc3_.parent != null)
            {
               _loc3_.parent.removeChild(_loc3_);
            }
         }
         if(this.ui_entityRollover.entity == param2.entity)
         {
            this.ui_entityRollover.entity = null;
            if(this.ui_entityRollover.parent != null)
            {
               this.ui_entityRollover.parent.removeChild(this.ui_entityRollover);
            }
            this.updateMouseCursor();
         }
         if(param2.flags & EntityFlags.TRAP_DISARMED)
         {
            if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_TRAPDISARMED)
            {
               this.startSurvivorSpeech(param1,"trapdisarmed");
            }
            _loc5_ = int(this._interactiveBuildings.indexOf(param2));
            if(_loc5_ > -1)
            {
               this._interactiveBuildings.splice(_loc5_,1);
            }
            _loc5_ = int(this._buildingAgents.indexOf(param2));
            if(_loc5_ > -1)
            {
               this._buildingAgents.splice(_loc5_,1);
            }
            _loc5_ = int(this._trapAgents.indexOf(param2));
            if(_loc5_ > -1)
            {
               this._trapAgents.splice(_loc5_,1);
            }
            if(this._missionData.enemyResults != null)
            {
               this._missionData.enemyResults.trapsDisarmed.push(param2);
            }
            this.SendMissionEvent(MissionEventTypes.TRAP_DISARMED,param2.type);
         }
         if(this._isPvP && !this._missionData.isPvPPractice)
         {
            Tracking.trackEvent("PvP","trap_disarmed_" + param2.type,String(param2.level),0);
         }
         this.fireTriggers(EntityTrigger.TrapDisarmed,param2.buildingEntity);
         this.showRangeIndicator();
      }
      
      protected function onTrapDisarmTriggered(param1:Survivor, param2:Building) : void
      {
         var ui_disarm:UIDisarmProgress;
         var srv:Survivor = param1;
         var trap:Building = param2;
         ++this._missionData.stats.trapDisarmTriggered;
         ui_disarm = this._ui_trapDisarmBySurvivor[srv];
         if(ui_disarm != null)
         {
            ui_disarm.playTriggeredAnimation(function():void
            {
               onTrapDisarmComplete(srv,trap);
            });
         }
         this.fireTriggers(EntityTrigger.TrapTriggered,trap.buildingEntity);
      }
      
      protected function onTrapTriggered(param1:Building) : void
      {
         if(this._missionData.enemyResults != null)
         {
            this._missionData.enemyResults.trapsTriggered.push(param1);
         }
         if(!(param1.flags & EntityFlags.TRAP_BEING_DISARMED))
         {
            ++this._missionData.stats.trapsTriggered;
         }
         var _loc2_:int = int(this._trapAgents.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._trapAgents.splice(_loc2_,1);
         }
         ++this._trackingTrapsTriggered;
         this.fireTriggers(EntityTrigger.TrapTriggered,param1.buildingEntity);
         if(!this._missionData.isPvPPractice)
         {
            Tracking.trackEvent("PvP","trap_triggered_" + param1.getName(),String(param1.level),0);
         }
         this.SendMissionEvent(MissionEventTypes.TRAP_TRIGGERED,param1.type);
      }
      
      private function onTileMouseOver(param1:int, param2:int, param3:int, param4:int) : void
      {
         if(this._actionMode || this._selectedSurvivor == null || this._selectedSurvivor.health <= 0)
         {
            return;
         }
         var _loc5_:Cell = this._scene.map.cellMap.getCell(param1,param2);
         var _loc6_:CoverData = this._scene.getCover(_loc5_);
         if(_loc6_ == null && !this._scene.map.isPassableCell(_loc5_))
         {
            _loc6_ = this._scene.getClosestCover(_loc5_);
         }
         if(_loc6_ == null)
         {
            if(Mouse.cursor == MouseCursors.COVER_GREEN || Mouse.cursor == MouseCursors.COVER_YELLOW || Mouse.cursor == MouseCursors.COVER_RED)
            {
               MouseCursors.setCursor(MouseCursors.DEFAULT);
            }
            return;
         }
         var _loc7_:String = CoverData.getCoverLevel(_loc6_.rating);
         switch(_loc7_)
         {
            case CoverData.NONE:
               MouseCursors.setCursor(MouseCursors.DEFAULT);
               return;
            case CoverData.HIGH:
               MouseCursors.setCursor(MouseCursors.COVER_GREEN);
               break;
            case CoverData.MODERATE:
               MouseCursors.setCursor(MouseCursors.COVER_YELLOW);
               break;
            case CoverData.LOW:
               MouseCursors.setCursor(MouseCursors.COVER_RED);
         }
      }
      
      private function onTileMouseOut(param1:int, param2:int, param3:int, param4:int) : void
      {
         if(Mouse.cursor == MouseCursors.COVER_GREEN || Mouse.cursor == MouseCursors.COVER_YELLOW || Mouse.cursor == MouseCursors.COVER_RED)
         {
            MouseCursors.setCursor(MouseCursors.DEFAULT);
         }
      }
      
      private function onTileClicked(param1:int, param2:int) : void
      {
         var _loc10_:Gear = null;
         var _loc11_:CoverData = null;
         var _loc12_:AIAgent = null;
         var _loc13_:Cell = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         if(Boolean(this._keysDown & KeyFlags.SHIFT) && this._activeGearMode == ActiveGearMode.NONE)
         {
            return;
         }
         if(!this._missionActive || this._selectedSurvivor == null || this._selectedSurvivor.health <= 0 || Boolean(this._selectedSurvivor.flags & (AIAgentFlags.LOCKED | AIAgentFlags.MOUNTED | AIAgentFlags.IMMOVEABLE)))
         {
            return;
         }
         if(this._activeGearMode == ActiveGearMode.THROW)
         {
            _loc10_ = this._selectedSurvivor.activeLoadout.gearActive.item as Gear;
            if(_loc10_ == null || _loc10_.quantity == 0)
            {
               return;
            }
            this.useActiveGear(this._selectedSurvivor);
            return;
         }
         var _loc3_:Vector3D = this._selectedSurvivor.actor.transform.position;
         var _loc4_:Cell = this._scene.map.getCellAtCoords(_loc3_.x,_loc3_.y);
         var _loc5_:Cell = this._scene.map.cellMap.getCell(param1,param2);
         if(_loc5_ == null || _loc4_ == null || _loc5_ == _loc4_)
         {
            return;
         }
         var _loc6_:Boolean = true;
         var _loc7_:Vector3D = new Vector3D(this._scene.mouseMap.mousePt.x,this._scene.mouseMap.mousePt.y,0);
         if(!this._scene.map.isPassableCell(_loc5_))
         {
            _loc11_ = this._scene.getClosestCover(_loc5_);
            if(_loc11_ != null && this._scene.map.isPassableCell(_loc11_.cell))
            {
               _loc5_ = _loc11_.cell;
            }
            else
            {
               _loc5_ = this._scene.map.getPassableCellAroundCellClosestToPoint(_loc5_.x,_loc5_.y,_loc3_,10,1);
            }
            if(_loc5_ != null)
            {
               _loc7_ = this._scene.map.getCellCoords(_loc5_.x,_loc5_.y);
            }
            else
            {
               _loc6_ = false;
            }
         }
         var _loc8_:Vector3D = _loc7_;
         if(_loc6_)
         {
            for each(_loc12_ in this._allAgents)
            {
               if(_loc12_ != this._selectedSurvivor)
               {
                  _loc14_ = _loc12_.entity.transform.position.x - _loc7_.x;
                  _loc15_ = _loc12_.entity.transform.position.y - _loc7_.y;
                  _loc16_ = _loc14_ * _loc14_ + _loc15_ * _loc15_;
                  if(_loc16_ < _loc12_.agentData.radius * _loc12_.agentData.radius)
                  {
                     _loc17_ = Math.atan2(_loc15_,_loc14_);
                     _loc18_ = _loc12_.agentData.radius - Math.sqrt(_loc16_);
                     _loc8_ = new Vector3D();
                     _loc8_.x = _loc7_.x - Math.cos(_loc17_) * _loc18_;
                     _loc8_.y = _loc7_.y - Math.sin(_loc17_) * _loc18_;
                  }
               }
            }
            _loc13_ = this._scene.map.getCellAtCoords2(_loc8_);
            if(_loc13_ != this._scene.map.getCellAtCoords2(this._selectedSurvivor.actor.transform.position))
            {
               if(!(this._selectedSurvivor.stateMachine.state is SurvivorAlertState))
               {
                  this._selectedSurvivor.stateMachine.setState(new SurvivorAlertState(this._selectedSurvivor));
               }
               this._selectedSurvivor.navigator.moveToPoint(_loc8_,10);
               this._selectedSurvivor.navigator.resume();
               this._selectedSurvivor.navigator.pathFound.addOnce(this.onSurvivorMoveCommandPathFound);
               this._selectedSurvivor.agentData.clearForcedTarget();
               this._selectedSurvivor.agentData.target = null;
               if(this._tutorial.active && this._tutorial.step == Tutorial.STEP_MOVEMENT)
               {
                  this._tutorial.setState(Tutorial.STATE_MOVEMENT_COUNT,int(this._tutorial.getState(Tutorial.STATE_MOVEMENT_COUNT)) + 1);
               }
               Audio.sound.play("sound/interface/int-click-move.mp3");
               if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_MOVESTART)
               {
                  this.startSurvivorSpeech(this._selectedSurvivor,"movestart");
               }
            }
         }
         else
         {
            Audio.sound.play("sound/interface/int-click-move-fail.mp3");
            if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_MOVEFAIL)
            {
               this.startSurvivorSpeech(this._selectedSurvivor,"movefail");
            }
         }
         var _loc9_:UIMovementTarget = new UIMovementTarget(_loc6_ ? UIMovementTarget.STATE_LEGAL : UIMovementTarget.STATE_ILLEGAL);
         _loc9_.name = "_ui" + getTimer();
         _loc9_.transform.position.x = _loc8_.x;
         _loc9_.transform.position.y = _loc8_.y;
         _loc9_.transform.position.z = 5;
         _loc9_.pulse();
         this._scene.addEntity(_loc9_);
      }
      
      protected function onKeyPressed(param1:KeyboardEvent) : void
      {
         var _loc4_:Survivor = null;
         if(Boolean(this._game.stage) && this._game.stage.focus is TextField)
         {
            return;
         }
         if(this.keyDownDict[param1.keyCode] == true)
         {
            return;
         }
         this.keyDownDict[param1.keyCode] = true;
         var _loc2_:Boolean = Boolean(this.keyDownDict[Keyboard.SPACE]);
         switch(param1.keyCode)
         {
            case Keyboard.ESCAPE:
               if(this._game.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
               {
                  if(!_loc2_)
                  {
                     this.setActionModeState(false);
                  }
                  this.selectSurvivor(null);
               }
               return;
            case Keyboard.E:
               if(!_loc2_)
               {
                  this.setActionModeState(!this._actionMode);
               }
               break;
            case Keyboard.SPACE:
               this.setActionModeState(true);
               return;
            case Keyboard.SHIFT:
               this._keysDown |= KeyFlags.SHIFT;
               return;
            case Keyboard.CONTROL:
               this._keysDown |= KeyFlags.CONTROL;
               return;
            case Keyboard.TAB:
               if(!_loc2_)
               {
                  this.setActionModeState(false);
               }
               this.selectNextSurvivor();
               return;
            case Keyboard.R:
               if(this._selectedSurvivor != null)
               {
                  if(this._selectedSurvivor.weaponData.capacity <= 1)
                  {
                     return;
                  }
                  if(this._isPvP)
                  {
                     return;
                  }
                  if(!this._selectedSurvivor.agentData.reloading && this._selectedSurvivor.weaponData.roundsInMagazine < this._selectedSurvivor.weaponData.capacity)
                  {
                     Tracking.trackEvent("PlayerAction","Reload_Key",this._isPvP ? "PvP" : (this._isCompoundAttack ? "Compound" : "PvE"));
                     this.setActiveGearMode(ActiveGearMode.NONE);
                     this._selectedSurvivor.reloadWeapon();
                     this._selectedSurvivor.agentData.lastManualReload = getTimer();
                  }
               }
         }
         var _loc3_:Number = parseInt(String.fromCharCode(param1.charCode));
         if(!isNaN(_loc3_))
         {
            if(_loc3_ <= 0)
            {
               _loc3_ = 10;
            }
            if(this._survivors.length > _loc3_ - 1)
            {
               _loc4_ = this._selectedSurvivor;
               this.selectSurvivor(this._survivors[_loc3_ - 1] as Survivor);
               if(!_loc2_ && _loc4_ != this._selectedSurvivor)
               {
                  this.setActionModeState(false);
               }
            }
         }
      }
      
      protected function onKeyReleased(param1:KeyboardEvent) : void
      {
         this.keyDownDict[param1.keyCode] = false;
         switch(param1.keyCode)
         {
            case Keyboard.SPACE:
               this.setActionModeState(false);
               break;
            case Keyboard.SHIFT:
               this._keysDown &= ~KeyFlags.SHIFT;
               return;
            case Keyboard.CONTROL:
               this._keysDown &= ~KeyFlags.CONTROL;
               return;
         }
      }
      
      private function onAgentDamageTaken(param1:AIAgent, param2:Number, param3:Object, param4:Boolean) : void
      {
         var _loc6_:Vector3D = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:String = null;
         var _loc11_:UIFloatingMessage = null;
         var _loc12_:UISurvivorIndicator = null;
         var _loc13_:UISurvivorLocation = null;
         var _loc5_:int = Math.round(param2 * 100);
         if(this._hudIndicatorsVisible)
         {
            if(_loc5_ > 0 && (param4 || this._game.timeElapsed - param1.agentData.lastDmgFloaterTime > this._dmgFloaterCooldown))
            {
               _loc6_ = param1.entity.transform.position;
               _loc7_ = _loc6_.x + int((Math.random() * 2 - 1) * 10);
               _loc8_ = _loc6_.y + int((Math.random() * 2 - 1) * 10);
               _loc9_ = _loc6_.z + param1.entity.getHeight() + (param1 is Survivor ? 80 : 20) + int(Math.random() * 20);
               _loc10_ = (param4 ? Language.getInstance().getString("crit") + "\r" : "") + "-" + _loc5_;
               _loc11_ = UIFloatingMessage.pool.get() as UIFloatingMessage;
               _loc11_.init(_loc10_,15597568,this._scene,_loc7_,_loc8_,_loc9_);
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc11_);
               param1.agentData.lastDmgFloaterTime = this._game.timeElapsed;
            }
         }
         if(param1.team == AIAgent.TEAM_PLAYER)
         {
            this._missionData.stats.damageTaken += param2;
            _loc12_ = this._ui_survivorIndicatorsBySurvivor[param1];
            if(_loc12_ != null)
            {
               _loc12_.showHealth = Survivor(param1).injuries.length > 0 || param1.health < Survivor(param1).maxHealth;
            }
            _loc13_ = this._ui_survivorLocationsBySurvivor[param1];
            if(_loc13_ != null)
            {
               _loc13_.alert(13369344);
            }
         }
         else
         {
            this._missionData.stats.damageOutput += param2;
         }
         this.flagFirstInteraction();
      }
      
      private function onPlayerSurvivorDie(param1:Survivor, param2:Object) : void
      {
         var _loc9_:Explosion = null;
         var _loc10_:* = undefined;
         var _loc11_:AbstractAIEffect = null;
         this.cancelSurvivorSpeech(param1);
         this._missionData.addDownedSurvivor(param1,param1.agentData.lastDamageCause);
         ++this._totalSurvivorsInjured;
         if(this._isPvP)
         {
            this.trackSurvivorDeathCover(param1,"attack");
         }
         param1.navigator.clearPath();
         param1.navigator.clearTarget();
         this._game.rvoSimulator.removeAgent(param1.navigator);
         var _loc3_:int = int(this._allAgents.indexOf(param1));
         this._allAgents.splice(_loc3_,1);
         if(this._selectedSurvivor == param1)
         {
            this.selectSurvivor(null);
         }
         param1.actor.mouseEnabled = false;
         this.cleanSurvivor(param1);
         param1.flags |= AIAgentFlags.LOCKED;
         param1.flags &= ~(AIAgentFlags.MOUNTED | AIAgentFlags.IMMOVEABLE);
         var _loc4_:UISurvivorLocation = this._ui_survivorLocationsBySurvivor[param1];
         _loc4_.dispose();
         this._ui_survivorLocationsBySurvivor[param1] = null;
         delete this._ui_survivorLocationsBySurvivor[param1];
         var _loc5_:UISurvivorIndicator = this._ui_survivorIndicatorsBySurvivor[param1];
         _loc5_.dispose();
         this._ui_survivorIndicatorsBySurvivor[param1] = null;
         delete this._ui_survivorIndicatorsBySurvivor[param1];
         var _loc6_:UISelectedIndicator = this._ui_selectedIndicatorsBySurvivor[param1];
         _loc6_.dispose();
         this._ui_selectedIndicatorsBySurvivor[param1] = null;
         delete this._ui_selectedIndicatorsBySurvivor[param1];
         var _loc7_:String = this._lang.getString("msg_survivor_down",param1.fullName.toUpperCase());
         this._gui.messageArea.addNotification(_loc7_,15597568,2,true);
         if(this._isPvP && !this._missionData.isPvPPractice)
         {
            if(param2 is Explosion)
            {
               _loc9_ = Explosion(param2);
               if(_loc9_.owner is Survivor)
               {
                  this.SendMissionEvent(MissionEventTypes.ATTACKER_DIE_EXPLOSIVE,param1.id,(_loc9_.owner as Survivor).id,_loc9_.ownerItem.type);
               }
               else if(_loc9_.owner is Building)
               {
                  this.SendMissionEvent(MissionEventTypes.ATTACKER_DIE_TRAP,param1.id,(_loc9_.owner as Building).type);
               }
            }
            else
            {
               _loc10_ = param2;
               if(param2 is AbstractAIEffect)
               {
                  _loc11_ = AbstractAIEffect(param2);
                  if(_loc11_.owner is Building)
                  {
                     _loc10_ = Building(_loc11_.owner);
                  }
               }
               if(_loc10_ is Building)
               {
                  this.SendMissionEvent(MissionEventTypes.ATTACKER_DIE_TRAP,param1.id,(_loc10_ as Building).type);
               }
               else
               {
                  this.SendMissionEvent(MissionEventTypes.ATTACKER_DIE_WEAPON,param1.id,(_loc10_ as Survivor).id);
               }
            }
         }
         this.playerSurvivorDied.dispatch(param1,param2);
         var _loc8_:Boolean = true;
         for each(param1 in this._survivors)
         {
            if(param1.health > 0)
            {
               _loc8_ = false;
               break;
            }
         }
         this._allSurvivorsDead = _loc8_;
         if(this._allSurvivorsDead)
         {
            this.allPlayerSurvivorsDied.dispatch();
            this._guiMission.mouseChildren = false;
            TweenMax.delayedCall(1.5,this.failMission);
         }
         this.flagFirstInteraction();
      }
      
      private function trackSurvivorDeathCover(param1:Survivor, param2:String) : void
      {
         var _loc4_:BuildingEntity = null;
         var _loc5_:CoverEntity = null;
         var _loc3_:String = "NoCover";
         for each(_loc5_ in param1.agentData.coverEntities)
         {
            if(_loc5_ is BuildingEntity)
            {
               if(_loc4_ == null || _loc4_.coverRating < _loc5_.coverRating)
               {
                  _loc4_ = BuildingEntity(_loc5_);
               }
            }
         }
         if(_loc4_)
         {
            _loc3_ = _loc4_.buildingData.type + "-" + _loc4_.coverRating;
         }
         if(!this._missionData.isPvPPractice)
         {
            Tracking.trackEvent("PvP","casualty_" + param2,_loc3_,0);
         }
      }
      
      private function onSurvivorReload(param1:Survivor) : void
      {
         if(param1.weapon.xml.weapon.noreloaddmsg == null)
         {
            this.cancelSurvivorSpeech(param1);
            if(Settings.getInstance().voices && Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_RELOADING)
            {
               this.startSurvivorSpeech(param1,"reloading");
            }
         }
         this.flagFirstInteraction();
      }
      
      private function onSurvivorMovementStarted(param1:Survivor) : void
      {
         var _loc2_:UIRangeIndicator = null;
         if(param1 != this._selectedSurvivor)
         {
            return;
         }
         this.clearCoverRating(param1);
         param1.allowEvalThreats = false;
         if(param1.agentData.target == null)
         {
            _loc2_ = this._ui_rangeIndicatorsBySurvivor[param1];
            _loc2_.asset.visible = false;
         }
         this.flagFirstInteraction();
      }
      
      protected function onSurvivorMovementStopped(param1:Survivor) : void
      {
         var _loc2_:Cell = null;
         if(param1 == this._selectedSurvivor && !param1.weaponData.isMelee)
         {
            this.showRangeIndicator();
         }
         this.updateCoverRating(param1);
         param1.allowEvalThreats = true;
         if(param1.weaponData.isMelee)
         {
            if(this._useDeployZones)
            {
               _loc2_ = this._scene.map.getCellAtCoords(param1.navigator.position.x,param1.navigator.position.y);
               param1.agentData.pursueTargets = _loc2_ != null && !this.isTileInDeploymentZone(_loc2_.x,_loc2_.y);
            }
            else
            {
               param1.agentData.pursueTargets = true;
            }
         }
         if(!param1.agentData.useGuardPoint)
         {
            param1.agentData.useGuardPoint = true;
            param1.agentData.guardPoint.setTo(param1.actor.transform.position.x,param1.actor.transform.position.y,0);
         }
      }
      
      private function onAgentDodgedAttack(param1:AIActorAgent) : void
      {
         var _loc2_:Vector3D = null;
         var _loc3_:Number = NaN;
         var _loc4_:UIFloatingMessage = null;
         if(this._hudIndicatorsVisible)
         {
            _loc2_ = param1.actor.transform.position;
            _loc3_ = _loc2_.z + param1.actor.getHeight() + 20;
            _loc4_ = UIFloatingMessage.pool.get() as UIFloatingMessage;
            _loc4_.init(this._lang.getString("dodged"),15724785,this._scene,_loc2_.x,_loc2_.y,_loc3_,60);
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
         }
      }
      
      private function onAgentMissedAttack(param1:AIActorAgent) : void
      {
         var _loc2_:Vector3D = null;
         var _loc3_:Number = NaN;
         var _loc4_:UIFloatingMessage = null;
         if(this._hudIndicatorsVisible)
         {
            _loc2_ = param1.actor.transform.position;
            _loc3_ = _loc2_.z + param1.actor.getHeight() + 20;
            _loc4_ = UIFloatingMessage.pool.get() as UIFloatingMessage;
            _loc4_.init(this._lang.getString("missed"),15724785,this._scene,_loc2_.x,_loc2_.y,_loc3_,60);
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
         }
      }
      
      private function onAgentSuppressedStateChanged(param1:AIActorAgent) : void
      {
         var _loc2_:UIRangeIndicator = null;
         if(param1.health <= 0)
         {
            return;
         }
         if(param1.team != AIAgent.TEAM_PLAYER)
         {
            this.setSuppressionIndicatorState(param1,param1.agentData.suppressed);
         }
         if(param1 == this._selectedSurvivor)
         {
            _loc2_ = this._ui_rangeIndicatorsBySurvivor[this._selectedSurvivor];
            if(_loc2_ != null)
            {
               _loc2_.yellow = this._selectedSurvivor.agentData.suppressed;
            }
            this.setActiveGearMode(ActiveGearMode.NONE);
         }
      }
      
      private function onEnemySurvivorMovementStopped(param1:Survivor) : void
      {
         this.updateCoverRating(param1);
      }
      
      protected function onEnemyDie(param1:AIActorAgent, param2:Object) : void
      {
         var _loc5_:UIEliteEnemyIndicator = null;
         var _loc3_:int = int(this._enemies.indexOf(param1));
         if(_loc3_ > -1)
         {
            this._enemies.splice(_loc3_,1);
         }
         _loc3_ = int(this._allAgents.indexOf(param1));
         if(_loc3_ > -1)
         {
            this._allAgents.splice(_loc3_,1);
         }
         param1.stateMachine.clear();
         param1.blackboard.erase();
         param1.navigator.clearTarget();
         param1.navigator.clearPath();
         param1.navigator.mode |= RVOAgentMode.STATIC;
         this._game.rvoSimulator.removeAgent(param1.navigator);
         param1.dodgedAttack.remove(this.onAgentDodgedAttack);
         param1.damageTaken.remove(this.onAgentDamageTaken);
         param1.died.remove(this.onEnemyDie);
         param1.actorClicked.remove(this.onEnemyClicked);
         param1.actorMouseOver.remove(this.onEnemyMouseOver);
         param1.actorMouseOut.remove(this.onEnemyMouseOut);
         param1.movementStopped.remove(this.onEnemySurvivorMovementStopped);
         param1.killedEnemy.remove(this.onAgentKilledEnemy);
         param1.navigator.targetUnreachable.remove(this.onSurvivorTargetUnreachable);
         param1.suppressedStateChanged.remove(this.onAgentSuppressedStateChanged);
         param1.actor.mouseEnabled = false;
         if(param1.isElite)
         {
            _loc5_ = this._ui_eliteIndicatorsByEnemy[param1];
            if(_loc5_ != null)
            {
               _loc5_.dispose();
               this._ui_eliteIndicatorsByEnemy[param1] = null;
               delete this._ui_eliteIndicatorsByEnemy[param1];
            }
            this.onEliteEnemyDied(param1,param2);
         }
         this.enemyDied.dispatch(param1,param2);
         if(this._mouseOverAgent == param1)
         {
            this._mouseOverAgent = null;
            this.updateMouseCursor();
         }
         var _loc4_:UISuppressedIndicator = this._ui_suppressionIndicatorsByAgent[param1];
         if(_loc4_ != null)
         {
            _loc4_.dispose();
            delete this._ui_suppressionIndicatorsByAgent[param1];
         }
         if(param1 is Survivor)
         {
            this.cancelSurvivorSpeech(Survivor(param1));
            if(this._isPvP)
            {
               this.trackSurvivorDeathCover(Survivor(param1),"defender");
            }
         }
      }
      
      protected function onEliteEnemySpawned(param1:AIActorAgent) : void
      {
         var elapsed:Number;
         var eliteTypeName:String;
         var enemy:AIActorAgent = param1;
         clearTimeout(this._eliteVignetteTimeout);
         elapsed = getTimer() - this._startTime;
         if(elapsed < 5)
         {
            return;
         }
         this._guiMission.setRushState(2);
         this._scene.camera.shake(25);
         this._eliteVignetteTimeout = setTimeout(function():void
         {
            _guiMission.setRushState(0);
         },2000);
         eliteTypeName = EnemyEliteType.getName(enemy.eliteType).toLowerCase();
         Audio.sound.play("sound/interface/enemy-spawned-" + eliteTypeName + ".mp3");
      }
      
      private function onEliteEnemyDied(param1:AIActorAgent, param2:Object) : void
      {
         var srvSource:Survivor;
         var enemy:AIActorAgent = param1;
         var source:Object = param2;
         if(enemy.enemyId <= -1)
         {
            return;
         }
         srvSource = source as Survivor;
         if(srvSource == null || srvSource.team != AIAgent.TEAM_PLAYER)
         {
            return;
         }
         this._missionData.stats.addCustomStat("elite","kills");
         this._missionData.stats.addCustomStat("elite",EnemyEliteType.getName(enemy.eliteType).toLowerCase(),"kills");
         MiniTaskSystem.getInstance().getAchievement("killelite").increment(1,0);
         Network.getInstance().save({"id":enemy.enemyId},SaveDataMethod.MISSION_ELITE_KILLED,function(param1:Object):void
         {
            if(param1 == null || param1.success !== true)
            {
               return;
            }
            if(param1.item == null)
            {
               return;
            }
            var _loc2_:Item = ItemFactory.createItemFromObject(param1.item);
            if(_loc2_ == null)
            {
               return;
            }
            _missionData.addLootItem(_loc2_);
            _guiMission.addFoundLoot(_loc2_);
         });
      }
      
      protected function onEnemyClicked(param1:AIAgent) : void
      {
         if(!this._missionActive || this._selectedSurvivor == null || param1 == null || param1.health <= 0)
         {
            return;
         }
         if(this._selectedSurvivor.agentData.currentForcedTarget == param1)
         {
            return;
         }
         this._selectedSurvivor.navigator.cancelAndStop();
         this._selectedSurvivor.agentData.useGuardPoint = false;
         this._selectedSurvivor.agentData.forceTarget(param1);
         if(!this._selectedSurvivor.agentData.reloading && !this._selectedSurvivor.agentData.suppressed && !this._selectedSurvivor.isImmobilized() || this._selectedSurvivor.stateMachine.state is ActorScavengeState && this._selectedSurvivor.stateMachine.state is SurvivorHealingState)
         {
            this._selectedSurvivor.stateMachine.setState(new SurvivorAlertState(this._selectedSurvivor));
         }
         this.flagFirstInteraction();
      }
      
      protected function onEnemyMouseOver(param1:AIAgent) : void
      {
         this._mouseOverAgent = param1;
         if(this._selectedSurvivor == null)
         {
            return;
         }
         if(this._selectedSurvivor.weaponData.isMelee)
         {
            MouseCursors.setCursor(MouseCursors.ATTACK_MELEE);
            return;
         }
         if(this._mouseOverAgent is Building)
         {
            MouseCursors.setCursor(MouseCursors.ATTACK_SUPPRESS);
            return;
         }
         MouseCursors.setCursor(MouseCursors.ATTACK);
      }
      
      protected function onEnemyMouseOut(param1:AIAgent) : void
      {
         this._mouseOverAgent = null;
         if(this._selectedSurvivor == null)
         {
            return;
         }
         this.updateMouseCursor();
      }
      
      protected function onMouseOverBuilding(param1:BuildingEntity) : void
      {
         var _loc2_:Building = param1.buildingData;
         if(_loc2_.forceScavengable || !(_loc2_.entity.flags & EntityFlags.EMPTY_CONTAINER) && _loc2_.scavengable)
         {
            if(this._missionData.isPvPPractice)
            {
               return;
            }
            this.onSearchableEntityMouseOver(param1);
            return;
         }
         if(_loc2_.health <= 0)
         {
            return;
         }
         if(_loc2_.isTrap && _loc2_.flags & EntityFlags.TRAP_DETECTED && this._selectedSurvivor.canDisarmTraps)
         {
            this.onTrapMouseOver(_loc2_);
            return;
         }
         if(_loc2_.maxHealth > 0 && !_loc2_.isTrap)
         {
            this.onEnemyMouseOver(_loc2_);
            return;
         }
      }
      
      protected function onMouseOutBuilding(param1:BuildingEntity) : void
      {
         var _loc2_:Building = param1.buildingData;
         if(_loc2_.forceScavengable || !(_loc2_.entity.flags & EntityFlags.EMPTY_CONTAINER) && _loc2_.scavengable)
         {
            this.onSearchableEntityMouseOut(param1);
            return;
         }
         if(_loc2_.isTrap)
         {
            this.onTrapMouseOut(_loc2_);
         }
         else
         {
            this.onEnemyMouseOut(_loc2_);
         }
      }
      
      protected function onBuildingClicked(param1:BuildingEntity) : void
      {
         var _loc2_:Building = param1.buildingData;
         if(this._selectedSurvivor == null || _loc2_ == null)
         {
            return;
         }
         if(!(_loc2_.entity.flags & EntityFlags.EMPTY_CONTAINER) && _loc2_.scavengable)
         {
            this.scavengeEntity(this._selectedSurvivor,_loc2_.entity);
            return;
         }
         if(_loc2_.health <= 0)
         {
            return;
         }
         if(_loc2_.isTrap && _loc2_.flags & EntityFlags.TRAP_DETECTED && this._selectedSurvivor.canDisarmTraps)
         {
            this.onTrapClicked(_loc2_);
            return;
         }
         if(_loc2_.maxHealth > 0)
         {
            this.onEnemyClicked(_loc2_);
            return;
         }
      }
      
      private function onScavengeStarted(param1:Survivor, param2:GameEntity) : void
      {
         var _loc4_:UISearchProgress = null;
         if(this._hudIndicatorsVisible)
         {
            _loc4_ = this._ui_scavengeIndicatorsBySurvivor[param1];
            if(_loc4_ == null)
            {
               _loc4_ = new UISearchProgress(param1,param2);
               this._ui_scavengeIndicatorsBySurvivor[param1] = _loc4_;
            }
            _loc4_.entity = param2;
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
         }
         var _loc3_:UIRangeIndicator = this._ui_rangeIndicatorsBySurvivor[param1];
         if(_loc3_.scene != null)
         {
            this._scene.removeEntity(_loc3_);
         }
         this.fireTriggers(EntityTrigger.ScavengeStarted,param2);
         ++_scavIndex;
         this._scavSrvDict[param1] = _scavIndex;
         Network.getInstance().connection.send(NetworkMessage.SCAV_STARTED,_scavIndex,getTimer());
      }
      
      protected function onScavengeComplete(param1:Survivor, param2:GameEntity, param3:Number, param4:Number) : void
      {
         var _loc5_:Item = null;
         var _loc10_:int = 0;
         var _loc11_:XML = null;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:UIFloatingMessage = null;
         var _loc17_:uint = 0;
         var _loc18_:Number = NaN;
         if(!this._missionActive)
         {
            return;
         }
         var _loc6_:XMLList = this._scene.getItemXMLListInSearchableEntity(param2);
         if(_loc6_ != null)
         {
            if(_loc6_.length() > 0)
            {
               for each(_loc11_ in _loc6_)
               {
                  _loc5_ = ItemFactory.createItemFromXML(_loc11_);
                  if(_loc5_ != null)
                  {
                     this._missionData.addLootItem(_loc5_);
                     this._guiMission.addFoundLoot(_loc5_);
                     if(_loc5_.qualityType > _loc10_)
                     {
                        _loc10_ = _loc5_.qualityType;
                     }
                  }
               }
               if(_loc10_ >= ItemQualityType.BLUE)
               {
                  if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_SCAVENGEFOUNDGREAT)
                  {
                     this.startSurvivorSpeech(param1,"scavengegreat");
                  }
               }
               else if(_loc10_ >= ItemQualityType.GREEN)
               {
                  if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_SCAVENGEFOUNDGOOD)
                  {
                     this.startSurvivorSpeech(param1,"scavengegood");
                  }
               }
            }
            else
            {
               this._guiMission.addFoundLoot(null);
               if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_SCAVENGEEMPTY)
               {
                  this.startSurvivorSpeech(param1,"scavengeempty");
               }
            }
         }
         if((param2.flags & EntityFlags.MULTI_SCAVENGE) == 0)
         {
            ++this._missionData.containersSearched;
            ++this._missionData.stats.containersSearched;
         }
         if(this._missionData.containersSearched == this._scene.totalSearchableEntities)
         {
            this._missionData.allContainersSearched = true;
         }
         var _loc7_:Number = param3 / 1000;
         if(this._missionData.fastestScavenge > _loc7_)
         {
            this._missionData.fastestScavenge = _loc7_;
         }
         if(this._isPvP)
         {
            if(Boolean(_loc6_) && _loc6_.length() > 0)
            {
               _loc5_ = ItemFactory.createItemFromXML(_loc6_[0]);
            }
            else
            {
               _loc5_ = null;
            }
            if(!this._missionData.isPvPPractice)
            {
               Tracking.trackEvent("PvP","buildingLooted",_loc5_ ? _loc5_.getName() : "nothing",_loc5_ ? _loc5_.quantity : 0);
            }
         }
         if((param2.flags & EntityFlags.MULTI_SCAVENGE) == 0)
         {
            _loc12_ = int(Config.constant.BASE_SCAVENGE_XP) * int(this._missionData.opponent.level + 1);
            _loc12_ = this.awardXP(_loc12_);
         }
         else
         {
            _loc12_ = -1;
         }
         if(!this._isPvP && (param2.flags & EntityFlags.MULTI_SCAVENGE) == 0)
         {
            MiniTaskSystem.getInstance().getAchievement("efficient").increment(1,_loc12_);
            MiniTaskSystem.getInstance().getAchievement("scavenger").increment(1 / this._scene.totalSearchableEntities,_loc12_);
            ++this._containerSearchCount;
            if(this._containerSearchCount == this._scene.totalSearchableEntities && this._missionData.assignmentType != AssignmentType.Arena)
            {
               this._guiMission.ui_timer.defaultMessage = Language.getInstance().getString("mission_time_searchComplete");
               this._guiMission.ui_timer.warningMessage = Language.getInstance().getString("mission_time_warningSearchComplete");
            }
         }
         if(this._hudIndicatorsVisible)
         {
            if(_loc12_ >= 0)
            {
               _loc13_ = param2.transform.position.x;
               _loc14_ = param2.transform.position.y;
               _loc15_ = param2.transform.position.z + (param2.asset.boundBox.maxX - param2.asset.boundBox.minZ) + 20;
               _loc16_ = UIFloatingMessage.pool.get() as UIFloatingMessage;
               _loc17_ = _loc12_ > 0 ? 16363264 : 12040119;
               _loc16_.init(this._lang.getString("msg_xp_awarded",_loc12_),_loc17_,this._scene,_loc13_,_loc14_,_loc15_,100);
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc16_);
            }
         }
         var _loc8_:UISearchProgress = this._ui_scavengeIndicatorsBySurvivor[param1];
         if(_loc8_ != null)
         {
            _loc8_.entity = null;
            if(_loc8_.parent != null)
            {
               _loc8_.parent.removeChild(_loc8_);
            }
         }
         if(this.ui_entityRollover.entity == param2)
         {
            this.ui_entityRollover.entity = null;
            if(this.ui_entityRollover.parent != null)
            {
               this.ui_entityRollover.parent.removeChild(this.ui_entityRollover);
            }
            this.updateMouseCursor();
         }
         this.showRangeIndicator();
         if((param2.flags & EntityFlags.MULTI_SCAVENGE) != 0)
         {
            _loc18_ = 2;
            if(param2 is BuildingEntity)
            {
               _loc18_ = Number(int(BuildingEntity(param2).buildingData.xml.cooldown) || _loc18_);
            }
            this.setScavengeCooldown(param2,_loc18_);
         }
         else
         {
            param2.flags |= EntityFlags.SCAVENGED;
            param2.flags |= EntityFlags.EMPTY_CONTAINER;
            this._scene.emptySearchableEntity(param2);
         }
         param2.asset.mouseEnabled = param2.asset.mouseChildren = false;
         param2.assetClicked.remove(this.onSearchableEntityClicked);
         param2.assetMouseOver.remove(this.onSearchableEntityMouseOver);
         param2.assetMouseOut.remove(this.onSearchableEntityMouseOut);
         if(param2 is BuildingEntity)
         {
            BuildingEntity(param2).onScavenged.dispatch();
         }
         this.fireTriggers(EntityTrigger.ScavengeCompleted,param2);
         if(this._tutorial.active && this._tutorial.step == Tutorial.STEP_SCAVENGING)
         {
            if(this._scene.searchableEntities.length == 0)
            {
               this._tutorial.setState(Tutorial.STATE_SCAVENGING_COMPLETE,true);
            }
         }
         var _loc9_:int = int(this._scavSrvDict[param1]);
         Network.getInstance().connection.send(NetworkMessage.SCAV_ENDED,_loc9_,getTimer(),param3,param4);
         this.scavengedCompleted.dispatch(param1,param2);
      }
      
      private function setScavengeCooldown(param1:GameEntity, param2:int) : void
      {
         this._scavengeCooldown[param1] = {
            "start":this._time,
            "duration":param2 * 1000
         };
      }
      
      private function onScavengeCancelled(param1:Survivor, param2:GameEntity) : void
      {
         if(!(param2.flags & EntityFlags.EMPTY_CONTAINER) && this._actionMode)
         {
            param2.asset.mouseEnabled = true;
         }
         var _loc3_:UISearchProgress = this._ui_scavengeIndicatorsBySurvivor[param1];
         if(_loc3_ != null)
         {
            _loc3_.entity = null;
            if(_loc3_.parent != null)
            {
               _loc3_.parent.removeChild(_loc3_);
            }
         }
         this.showRangeIndicator();
      }
      
      private function onUISurvivorLocationClicked(param1:MouseEvent) : void
      {
         var _loc2_:Survivor = null;
         var _loc3_:Object = null;
         var _loc4_:Vector3D = null;
         for(_loc3_ in this._ui_survivorLocationsBySurvivor)
         {
            if(this._ui_survivorLocationsBySurvivor[_loc3_] == param1.currentTarget)
            {
               _loc2_ = _loc3_ as Survivor;
               break;
            }
         }
         if(_loc2_ != null)
         {
            this.selectSurvivor(_loc2_);
            _loc4_ = this._selectedSurvivor.actor.transform.position;
            this._scene.panTo(_loc4_.x,_loc4_.y,_loc4_.z);
         }
      }
      
      private function onSurvivorLevelIncreased(param1:Survivor, param2:int) : void
      {
         ++this._missionData.stats.levelUps;
         if(param1 == this._playerSurvivor)
         {
            return;
         }
         this._gui.messageArea.addNotification(this._lang.getString("srv_level_up",param1.fullName).toUpperCase(),16363264,2,true);
      }
      
      private function onSurvivorHealCompleted(param1:Survivor, param2:Survivor, param3:Number) : void
      {
         var _loc5_:UISurvivorIndicator = null;
         var _loc4_:* = param2.health >= param2.getHealableHealth();
         if(this._selectedSurvivor != param2)
         {
            _loc5_ = this._ui_survivorIndicatorsBySurvivor[param2];
            _loc5_.showHealth = param2.injuries.length > 0 || !_loc4_;
         }
         if(param1 != param2 && Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_HEALCOMPLETE)
         {
            this.startSurvivorSpeech(param2,"healcomplete");
         }
         this._missionData.stats.hpHealed += int(param3 * 100);
         MiniTaskSystem.getInstance().getAchievement("medic").increment(param3 / this.getTotalSurvivorHealth(),0);
         MiniTaskSystem.getInstance().getAchievement("infirmary").decrement(1);
         if(_loc4_)
         {
            this._gui.messageArea.addNotification(this._lang.getString("msg_survivor_healed",param2.firstName.toUpperCase()),Effects.COLOR_GOOD,2,true);
         }
      }
      
      private function onSurvivorHealStarted(param1:Survivor, param2:Survivor) : void
      {
         MiniTaskSystem.getInstance().getAchievement("infirmary").increment(1,0);
      }
      
      private function onSurvivorHealCancelled(param1:Survivor, param2:Survivor, param3:Number) : void
      {
         MiniTaskSystem.getInstance().getAchievement("medic").increment(param3 / this.getTotalSurvivorHealth(),0);
         MiniTaskSystem.getInstance().getAchievement("infirmary").decrement(1);
      }
      
      private function getTotalSurvivorHealth() : Number
      {
         var _loc2_:Survivor = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in this._survivors)
         {
            _loc1_ += _loc2_.maxHealth;
         }
         return _loc1_;
      }
      
      private function onSurvivorMouseOver(param1:Survivor) : void
      {
         var ui_select:UISelectedIndicator = null;
         var srv:Survivor = param1;
         ui_select = this._ui_selectedIndicatorsBySurvivor[srv];
         this._mouseOverAgent = srv;
         if(this._actionMode)
         {
            if(this._selectedSurvivor != null && this._selectedSurvivor.canHeal && (this._assignmentData == null || this._assignmentData.type != AssignmentType.Arena))
            {
               MouseCursors.setCursor(MouseCursors.HEAL);
            }
            if(ui_select != null)
            {
               ui_select.transitionOut(function():void
               {
                  if(ui_select.scene != null)
                  {
                     ui_select.scene.removeEntity(ui_select);
                  }
               });
            }
            return;
         }
         if(srv == this._selectedSurvivor)
         {
            return;
         }
         if(ui_select != null)
         {
            ui_select.transform.position.x = srv.actor.transform.position.x;
            ui_select.transform.position.y = srv.actor.transform.position.y;
            ui_select.transform.position.z = srv.actor.transform.position.z + 5;
            ui_select.updateTransform();
            ui_select.transitionIn();
            this._scene.addEntity(ui_select);
         }
      }
      
      private function onSurvivorMouseOut(param1:Survivor) : void
      {
         var ui_select:UISelectedIndicator = null;
         var srv:Survivor = param1;
         this.updateMouseCursor();
         this._mouseOverAgent = null;
         if(srv == this._selectedSurvivor)
         {
            return;
         }
         ui_select = this._ui_selectedIndicatorsBySurvivor[srv];
         ui_select.transitionOut(function():void
         {
            if(ui_select.scene != null)
            {
               ui_select.scene.removeEntity(ui_select);
            }
         });
      }
      
      private function onMissionEndTimerCompleted(param1:TimerEvent) : void
      {
         this.leaveMission();
      }
      
      protected function onTimeExpired() : void
      {
         this.timerExhausted.dispatch();
         if(!this._endTimer.running)
         {
            this._endTimer.start();
         }
      }
      
      private function onStatTimerTick(param1:TimerEvent) : void
      {
         this._missionData.sendStats();
      }
      
      protected function onSurvivorNoiseGenerated(param1:Survivor, param2:NoiseSource) : void
      {
      }
      
      protected function onBuildingDamageTaken(param1:Building, param2:Number, param3:Object, param4:Boolean) : void
      {
         var _loc7_:Survivor = null;
         var _loc5_:UIBuildingIndicator = this._ui_buildingHealthByBuilding[param1];
         if(_loc5_ == null)
         {
            _loc5_ = this._ui_buildingHealthByBuilding[param1] = new UIBuildingIndicator(param1);
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc5_);
         }
         var _loc6_:Boolean = this._missionData.allianceMatch == true && this._missionData.allianceRoundActive && this._missionData.allianceError == false;
         if(param1.health <= 0)
         {
            if(param3 is Explosion)
            {
               ++this._missionData.stats.buildingsExplosiveDestroyed;
               if(!this._missionData.isPvPPractice)
               {
                  Tracking.trackEvent("Mission","BuildingDestroyed","explosive",1);
                  if(_loc6_)
                  {
                     Tracking.trackEvent("Alliance","BuildingDestroyed","explosive",1);
                  }
               }
            }
            else if(param3 is Survivor)
            {
               _loc7_ = Survivor(param3);
               if(!this._missionData.isPvPPractice)
               {
                  Tracking.trackEvent("Mission","BuildingDestroyed",_loc7_.weaponData.isMelee ? "melee" : "projectile",1);
                  if(_loc6_)
                  {
                     Tracking.trackEvent("Alliance","BuildingDestroyed",_loc7_.weaponData.isMelee ? "melee" : "projectile",1);
                  }
               }
            }
         }
      }
      
      protected function onBuildingDestroyed(param1:Building, param2:Object) : void
      {
         var _loc6_:Vector.<Cell> = null;
         var _loc7_:int = 0;
         var _loc8_:Survivor = null;
         var _loc9_:Cell = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:DustClouds = null;
         var _loc13_:UIBuildingIcon = null;
         var _loc14_:Cell = null;
         var _loc15_:CoverData = null;
         var _loc3_:int = int(this._buildingAgents.indexOf(param1));
         if(_loc3_ > -1)
         {
            this._buildingAgents.splice(_loc3_,1);
         }
         var _loc4_:int = 10;
         if(param1.assignable && param1.doorPosition != null)
         {
            _loc6_ = this._scene.map.getCellsEntityIsOccupying(param1.buildingEntity);
            _loc7_ = int(this._allAgents.length - 1);
            while(_loc7_ >= 0)
            {
               _loc8_ = this._allAgents[_loc7_] as Survivor;
               if(!(_loc8_ == null || !(_loc8_.flags & AIAgentFlags.MOUNTED)))
               {
                  _loc9_ = this._scene.map.getCellAtCoords(_loc8_.entity.transform.position.x,_loc8_.entity.transform.position.y);
                  if(_loc6_.indexOf(_loc9_) > -1)
                  {
                     _loc8_.die(param2);
                     _loc8_.actor.asset.visible = false;
                  }
               }
               _loc7_--;
            }
            _loc4_ = 30;
         }
         if(!param1.isTrap)
         {
            _loc10_ = param1.buildingEntity.transform.position.x + param1.buildingEntity.centerPoint.x;
            _loc11_ = param1.buildingEntity.transform.position.y + param1.buildingEntity.centerPoint.y;
            _loc12_ = new DustClouds(_loc10_,_loc11_,0,_loc4_,200,300);
            this._scene.addEntity(_loc12_);
            if(this._isPvP && !this._missionData.isPvPPractice)
            {
               Tracking.trackEvent("PvP","buildingDestroyed",null,1);
            }
         }
         var _loc5_:UIBuildingIndicator = this._ui_buildingHealthByBuilding[param1];
         if(_loc5_ != null)
         {
            _loc5_.dispose();
            delete this._ui_buildingHealthByBuilding[param1];
         }
         if(param1.isTrap)
         {
            _loc13_ = this._ui_trapDetectedByBuilding[param1];
            if(param1.flags & EntityFlags.TRAP_DISARMED)
            {
               if(_loc13_ == null)
               {
                  if(this._hudIndicatorsVisible)
                  {
                     _loc13_ = new UIBuildingIcon(param1,BmpIconTrapDisarmed,50);
                     this._ui_trapDetectedByBuilding[param1] = _loc13_;
                     this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChildAt(_loc13_,0);
                  }
               }
               else
               {
                  _loc13_.iconClass = BmpIconTrapDisarmed;
               }
            }
            else if(_loc13_ != null)
            {
               _loc13_.dispose();
               delete this._ui_trapDetectedByBuilding[param1];
            }
         }
         else
         {
            if(this._missionData.enemyResults != null)
            {
               this._missionData.enemyResults.buildingsDestroyed.push(param1);
            }
            ++this._missionData.stats.buildingsDestroyed;
            this.SendMissionEvent(MissionEventTypes.BUILDING_DESTROYED,param1.type);
         }
         if(param1.coverRating != 0)
         {
            for each(_loc14_ in param1.buildingEntity.getCoverTiles())
            {
               _loc15_ = this._scene.getCoverData(_loc14_);
               if(_loc15_ != null)
               {
                  _loc15_.calculateRating();
               }
            }
            this.updateCoverRatingsForAgents(this._survivors);
            this.updateCoverRatingsForAgents(this._enemies);
         }
         this.fireTriggers(EntityTrigger.Death,param1.buildingEntity);
      }
      
      private function onSurvivorTrapDetected(param1:Survivor, param2:Vector.<Building> = null) : void
      {
         var _loc3_:Building = null;
         var _loc4_:UIBuildingIcon = null;
         if(param2 == null || param2.length == 0)
         {
            return;
         }
         for each(_loc3_ in param2)
         {
            if(_loc3_.isTrap)
            {
               _loc3_.buildingEntity.asset.visible = true;
               _loc4_ = this._ui_trapDetectedByBuilding[_loc3_];
               if(_loc4_ == null)
               {
                  _loc4_ = new UIBuildingIcon(_loc3_,BmpIconTrap,50);
                  this._ui_trapDetectedByBuilding[_loc3_] = _loc4_;
               }
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChildAt(_loc4_,0);
            }
         }
         if(Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_TRAPSPOTTED)
         {
            this.startSurvivorSpeech(param1,"trapspotted",true);
         }
         Audio.sound.play("sound/interface/int-detecttrap.mp3");
      }
      
      private function onSurvivorMountedBuildingChanged(param1:Survivor, param2:Building) : void
      {
         var _loc3_:XML = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:UIRangeIndicator = null;
         if(param1.mountedBuilding == null)
         {
            param1.weaponData.setRangeModifiers(0,0);
         }
         else
         {
            _loc3_ = param2.getLevelXML();
            _loc4_ = Number(_loc3_.rng_min.toString());
            _loc5_ = Number(_loc3_.rng_max.toString());
            if(param1.weaponData.isMelee)
            {
               _loc5_ = -int.MAX_VALUE;
            }
            param1.weaponData.setRangeModifiers(_loc4_,_loc5_);
         }
         if(this._hudIndicatorsVisible)
         {
            _loc6_ = this._ui_rangeIndicatorsBySurvivor[param1];
            if(_loc6_ != null)
            {
               _loc6_.range = param1.weaponData.range;
               _loc6_.minEffectiveRange = param1.weaponData.minEffectiveRange;
               _loc6_.minRange = param1.weaponData.minRange;
               _loc6_.yellow = param1.agentData.suppressed;
               _loc6_.transitionIn();
            }
         }
      }
      
      private function onSurvivorInjuryAdded(param1:Survivor, param2:Injury) : void
      {
         var _loc3_:Vector3D = param1.entity.transform.position;
         var _loc4_:Number = _loc3_.x;
         var _loc5_:Number = _loc3_.y;
         var _loc6_:Number = _loc3_.z + param1.entity.getHeight() + 80;
         var _loc7_:UIFloatingMessage = UIFloatingMessage.pool.get() as UIFloatingMessage;
         _loc7_.init(param2.getName(),15597568,this._scene,_loc4_,_loc5_,_loc6_,60,1);
         this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc7_);
         if(Settings.getInstance().voices && Math.random() < Config.constant.SURVIVOR_TALK_CHANCE_INJURY)
         {
            this.startSurvivorSpeech(param1,"injury");
         }
      }
      
      private function onAgentKilledEnemy(param1:AIAgent, param2:AIAgent) : void
      {
         if(param2 is Building)
         {
            return;
         }
         var _loc3_:Number = param2 is Zombie ? Number(Config.constant.SURVIVOR_TALK_CHANCE_KILL_ZOMBIE) : Number(Config.constant.SURVIVOR_TALK_CHANCE_KILL_SURVIVOR);
         var _loc4_:Survivor = param1 as Survivor;
         if(_loc4_ != null && Math.random() < _loc3_)
         {
            this.startSurvivorSpeech(_loc4_,"kill");
         }
      }
      
      private function onSurvivorTargetUnreachable(param1:NavigatorAgent) : void
      {
         var _loc2_:AIAgent = param1.aiAgent;
         _loc2_.agentData.guardPoint.setTo(_loc2_.entity.transform.position.x,_loc2_.entity.transform.position.y,0);
      }
      
      private function onSurvivorClicked(param1:Survivor) : void
      {
         this.flagFirstInteraction();
         this.selectSurvivor(param1);
      }
      
      private function onSurvivorMoveCommandPathFound(param1:NavigatorAgent, param2:Path) : void
      {
         if(param1.path != null && param1.path.numWaypoints > 0)
         {
            param1.path.getWaypoint(param2.numWaypoints - 1,this._tmpVector);
            this._scene.map.getCellCoords(this._tmpVector.x,this._tmpVector.y,this._tmpVector);
            param1.aiAgent.agentData.guardPoint.copyFrom(this._tmpVector);
            param1.aiAgent.agentData.useGuardPoint = true;
         }
      }
      
      private function onStageRightClicked(param1:MouseEvent) : void
      {
         if(!(param1.target is View) || this._selectedSurvivor == null)
         {
            return;
         }
         this.toggleActiveGearMode();
      }
      
      private function onStageClicked(param1:MouseEvent) : void
      {
         if(!(param1.target is View) || this._selectedSurvivor == null)
         {
            return;
         }
         if(this._keysDown & KeyFlags.CONTROL)
         {
            this.toggleActiveGearMode();
         }
      }
      
      private function onStageResize(param1:Event) : void
      {
         if(this._failureSnapshot != null)
         {
            this._failureSnapshot.bitmapData.dispose();
            this._failureSnapshot.bitmapData = this._game.getSceneSnapshot();
         }
      }
      
      private function onAssignmentUpdateTimer(param1:TimerEvent) : void
      {
         if(!this._missionActive)
         {
            return;
         }
         if(this._arenaData != null)
         {
            ArenaSystem.updateState(this._arenaData);
         }
      }
      
      public function get missionData() : MissionData
      {
         return this._missionData;
      }
   }
}

