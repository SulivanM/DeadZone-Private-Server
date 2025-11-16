package thelaststand.app.game.logic
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.JunkBuilding;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskCollection;
   import thelaststand.app.game.data.TaskStatus;
   import thelaststand.app.game.data.TaskType;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.task.JunkRemovalTask;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.actors.Actor;
   import thelaststand.app.game.entities.buildings.AllianceFlagEntity;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.buildings.DoorBuildingEntity;
   import thelaststand.app.game.entities.gui.UISelectedIndicator;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.UIEntityRollover;
   import thelaststand.app.game.gui.UIFloatingMessage;
   import thelaststand.app.game.gui.compound.CompoundGUILayer;
   import thelaststand.app.game.gui.compound.UIBuildingControl;
   import thelaststand.app.game.gui.compound.UIBuildingIcon;
   import thelaststand.app.game.gui.compound.UIConstructionProgress;
   import thelaststand.app.game.logic.ai.states.SurvivorCompoundIdleState;
   import thelaststand.app.game.logic.ai.states.SurvivorTaskState;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.game.scenes.CompoundScene;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.NavEdgeFlag;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.map.TraversalArea;
   import thelaststand.engine.objects.GameEntity;
   
   public class PlayerCompoundDirector implements ISceneDirector
   {
      
      private static const BUILDING_PLACEMENT_VALID:int = 1;
      
      private static const BUILDING_PLACEMENT_INVALID:int = 3;
      
      private static const BUILDING_PLACEMENT_INDOOR_ONLY:int = 4;
      
      private static const BUILDING_PLACEMENT_OUTDOOR_ONLY:int = 5;
      
      private static const BUILDING_PLACEMENT_DOORWAY_ONLY:int = 6;
      
      private static const BUILDING_PLACEMENT_NO_DOORWAY:int = 7;
      
      private var _buildingId:int = 9999;
      
      private var _timeManager:TimerManager;
      
      private var _game:Game;
      
      private var _gui:GameGUI;
      
      private var _guiCompound:CompoundGUILayer;
      
      private var _network:Network;
      
      private var _lang:Language;
      
      private var _resources:ResourceManager;
      
      private var _tutorial:Tutorial;
      
      private var _scene:CompoundScene;
      
      private var _selectedBuilding:Building;
      
      private var _selectedSurvivor:Survivor;
      
      private var _mouseOverSurvivor:Survivor;
      
      private var _survivors:Vector.<Survivor>;
      
      private var _movingBuilding:Building;
      
      private var _movingBuildingRotation:int;
      
      private var _movingBuildingFootprint:Rectangle;
      
      private var _placingNewBuilding:Boolean;
      
      private var _buyingNewBuilding:Boolean;
      
      private var _placementLegal:Boolean;
      
      private var _ui_constructionProgressByBuilding:Dictionary;
      
      private var _ui_resourceFullByBuilding:Dictionary;
      
      private var _ui_repairByBuilding:Dictionary;
      
      private var _ui_selectedBySurvivor:Dictionary;
      
      private var _awaitingNewBuildingResponse:Boolean = false;
      
      private var _startupBuildingsValid:Boolean;
      
      private var ui_buildingControl:UIBuildingControl;
      
      private var ui_entityRollover:UIEntityRollover;
      
      private var ui_survivorName:BodyTextField;
      
      public function PlayerCompoundDirector(param1:Game, param2:CompoundScene, param3:GameGUI)
      {
         super();
         this._game = param1;
         this._scene = param2;
         this._survivors = new Vector.<Survivor>();
         this._gui = param3;
         this._guiCompound = new CompoundGUILayer();
         this._ui_constructionProgressByBuilding = new Dictionary(true);
         this._ui_resourceFullByBuilding = new Dictionary(true);
         this._ui_repairByBuilding = new Dictionary(true);
         this._ui_selectedBySurvivor = new Dictionary(true);
         this.ui_entityRollover = new UIEntityRollover();
         this.ui_buildingControl = new UIBuildingControl();
         this.ui_survivorName = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.ui_survivorName.filters = [Effects.STROKE];
         this._resources = ResourceManager.getInstance();
         this._timeManager = TimerManager.getInstance();
         this._network = Network.getInstance();
         this._lang = Language.getInstance();
         this._tutorial = Tutorial.getInstance();
      }
      
      public function dispose() : void
      {
         this.setBuildingInteraction(false);
         this.ui_buildingControl.dispose();
         this.ui_buildingControl = null;
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().kicked.remove(this.onAllianceKicked);
         this._scene = null;
         this._network = null;
         this._resources = null;
         this._lang = null;
         this._timeManager = null;
         this._movingBuilding = null;
         this._selectedBuilding = null;
         this._gui = null;
         this._ui_constructionProgressByBuilding = null;
         this._game = null;
         this._survivors = null;
         this._guiCompound = null;
         this._movingBuilding = null;
         this._movingBuildingFootprint = null;
      }
      
      public function end() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:UIConstructionProgress = null;
         var _loc4_:UIBuildingIcon = null;
         var _loc5_:UIBuildingIcon = null;
         var _loc6_:Survivor = null;
         var _loc7_:Building = null;
         var _loc8_:Task = null;
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().kicked.remove(this.onAllianceKicked);
         this._gui.clearLayer(this._gui.getLayer(this._gui.SCENE_LAYER_NAME));
         this._gui.messageArea.setMessage("");
         for each(_loc3_ in this._ui_constructionProgressByBuilding)
         {
            delete this._ui_constructionProgressByBuilding[_loc3_.building];
            _loc3_.dispose();
         }
         for each(_loc4_ in this._ui_resourceFullByBuilding)
         {
            delete this._ui_resourceFullByBuilding[_loc4_.building];
            _loc4_.dispose();
         }
         for each(_loc5_ in this._ui_repairByBuilding)
         {
            delete this._ui_repairByBuilding[_loc5_.building];
            _loc5_.dispose();
         }
         DialogueManager.getInstance().dialogueOpened.remove(this.onDialogueOpened);
         this._network.playerData.getPlayerSurvivor().levelIncreased.remove(this.onPlayerLevelUp);
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._gui.stage.removeEventListener(GameEvent.CENTER_ON_ENTITY,this.onCenterOnEntityRequest);
         this._gui.stage.removeEventListener(GameEvent.CONSTRUCTION_START,this.onConstructionStarted);
         this._gui.removeLayer(this._guiCompound,true,this._guiCompound.dispose);
         this._gui.keyPressed.remove(this.onKeyPress);
         this._gui.keyReleased.remove(this.onKeyRelease);
         this._timeManager.timerStarted.remove(this.onTimerStarted);
         this._timeManager.timerCancelled.remove(this.onTimerCancelled);
         this._timeManager.timerCompleted.remove(this.onTimerCompleted);
         this.ui_buildingControl.moveClicked.remove(this.moveBuilding);
         this.ui_buildingControl.removeClicked.remove(this.removeJunk);
         this.ui_buildingControl.pauseTaskClicked.remove(this.pauseTask);
         this.ui_buildingControl.hidden.remove(this.onBuildingControlHidden);
         this._scene.mouseMap.tileMouseOver.remove(this.onPlacementCellChanged);
         this._scene.mouseMap.tileClicked.remove(this.onPlacementCellClicked);
         this._scene.mouseMap.enabled = false;
         this._network.playerData.compound.survivors.survivorAdded.remove(this.onNewSurvivorAdded);
         for each(_loc6_ in this._survivors)
         {
            this.cleanSurvivor(_loc6_);
            this._scene.removeEntity(_loc6_.actor);
         }
         this._survivors.length = 0;
         this.setBuildingInteraction(false);
         _loc1_ = 0;
         _loc2_ = this._network.playerData.compound.buildings.numBuildings;
         while(_loc1_ < _loc2_)
         {
            _loc7_ = this._network.playerData.compound.buildings.getBuilding(_loc1_);
            _loc7_.buildingEntity.footprintVisible = false;
            _loc7_.traversalArea = null;
            _loc7_.died.remove(this.onBuildingDied);
            _loc7_.upgradeStarted.remove(this.onBuildingUpgradeStarted);
            _loc7_.repairStarted.remove(this.onBuildingRepairStarted);
            _loc7_.repairCompleted.remove(this.onBuildingRepairCompleted);
            _loc7_.resourcesCollected.remove(this.onBuildingResourcesCollected);
            _loc7_.resourceValueChanged.remove(this.onBuildingResourcesChanged);
            _loc7_.recycled.remove(this.onBuildingRecycled);
            _loc7_.entity.assetMouseDown.remove(this.onBuildingEntityMouseDown);
            _loc7_.entity.assetMouseOver.remove(this.onBuildingEntityMouseOver);
            _loc7_.entity.assetMouseOut.remove(this.onBuildingEntityMouseOut);
            _loc1_++;
         }
         if(this._movingBuilding != null && this._awaitingNewBuildingResponse)
         {
            this._scene.removeEntity(this._movingBuilding.buildingEntity);
         }
         _loc1_ = 0;
         _loc2_ = this._network.playerData.compound.tasks.length;
         while(_loc1_ < _loc2_)
         {
            _loc8_ = this._network.playerData.compound.tasks.getTask(_loc1_);
            _loc8_.completed.remove(this.onTaskCompleted);
            _loc8_.statusChanged.remove(this.onTaskStatusChanged);
            _loc1_++;
         }
         this._selectedBuilding = null;
         this._movingBuilding = null;
         this._movingBuildingFootprint = null;
      }
      
      public function start(param1:Number, ... rest) : void
      {
         var _loc3_:Rectangle = null;
         var _loc7_:JunkRemovalTask = null;
         var _loc8_:Building = null;
         var _loc9_:TraversalArea = null;
         var _loc10_:Survivor = null;
         var _loc11_:MessageBox = null;
         this._gui.stage.addEventListener(GameEvent.CENTER_ON_ENTITY,this.onCenterOnEntityRequest,false,0,true);
         this._gui.stage.addEventListener(GameEvent.CONSTRUCTION_START,this.onConstructionStarted,false,0,true);
         this._gui.addEventListener(MouseEvent.MOUSE_DOWN,this.onGUIMouseDown,false,0,true);
         this._gui.addLayer("compound",this._guiCompound);
         this._gui.keyPressed.add(this.onKeyPress);
         this._gui.keyReleased.add(this.onKeyRelease);
         this._guiCompound.transitionIn(0.25);
         this.ui_buildingControl.moveClicked.add(this.moveBuilding);
         this.ui_buildingControl.removeClicked.add(this.removeJunk);
         this.ui_buildingControl.pauseTaskClicked.add(this.pauseTask);
         this.ui_buildingControl.hidden.add(this.onBuildingControlHidden);
         this._timeManager.timerStarted.add(this.onTimerStarted);
         this._timeManager.timerCancelled.add(this.onTimerCancelled);
         this._timeManager.timerCompleted.add(this.onTimerCompleted);
         DialogueManager.getInstance().dialogueOpened.add(this.onDialogueOpened);
         this._network.playerData.getPlayerSurvivor().levelIncreased.add(this.onPlayerLevelUp);
         this._tutorial.stepChanged.add(this.onTutorialStepChanged);
         var _loc4_:int = 0;
         var _loc5_:int = this._network.playerData.compound.buildings.numBuildings;
         while(_loc4_ < _loc5_)
         {
            _loc8_ = this._network.playerData.compound.buildings.getBuilding(_loc4_);
            _loc8_.entity.assetMouseDown.add(this.onBuildingEntityMouseDown);
            _loc8_.entity.assetMouseOver.add(this.onBuildingEntityMouseOver);
            _loc8_.entity.assetMouseOut.add(this.onBuildingEntityMouseOut);
            _loc8_.died.add(this.onBuildingDied);
            if(!(_loc8_ is JunkBuilding))
            {
               _loc8_.repairStarted.add(this.onBuildingRepairStarted);
               _loc8_.repairCompleted.add(this.onBuildingRepairCompleted);
               _loc8_.upgradeStarted.add(this.onBuildingUpgradeStarted);
               _loc8_.resourcesCollected.add(this.onBuildingResourcesCollected);
               _loc8_.resourceValueChanged.add(this.onBuildingResourcesChanged);
               _loc8_.recycled.add(this.onBuildingRecycled);
            }
            _loc8_.buildingEntity.showAssignFlags(true);
            if(_loc8_.isDecoyTrap)
            {
               _loc8_.buildingEntity.showDecoyMarker(true);
            }
            if(_loc8_.isDoor)
            {
               _loc3_ = _loc8_.buildingEntity.getFootprintRect(_loc8_.tileX,_loc8_.tileY,_loc3_ || new Rectangle());
               ++_loc3_.width;
               ++_loc3_.height;
               _loc9_ = this._scene.map.addTraversalArea(_loc3_,15);
               _loc9_.data = _loc8_;
               _loc8_.traversalArea = _loc9_;
               if(DoorBuildingEntity(_loc8_.buildingEntity).isOpen)
               {
                  DoorBuildingEntity(_loc8_.buildingEntity).toggleOpen();
               }
            }
            this.updateBuildingDisplay(_loc8_);
            _loc4_++;
         }
         this._network.playerData.compound.survivors.survivorAdded.add(this.onNewSurvivorAdded);
         _loc4_ = 0;
         _loc5_ = this._network.playerData.compound.survivors.length;
         while(_loc4_ < _loc5_)
         {
            _loc10_ = this._network.playerData.compound.survivors.getSurvivor(_loc4_);
            if(!(_loc10_.state & SurvivorState.ON_MISSION || _loc10_.state & SurvivorState.ON_ASSIGNMENT))
            {
               this.addSurvivor(_loc10_);
            }
            _loc4_++;
         }
         var _loc6_:Vector.<Task> = this._network.playerData.compound.tasks.getTasksOfType(TaskType.JUNK_REMOVAL);
         for each(_loc7_ in _loc6_)
         {
            if(!(Boolean(_loc7_.complete) || _loc7_.target == null))
            {
               _loc7_.completed.addOnce(this.onTaskCompleted);
               _loc7_.statusChanged.add(this.onTaskStatusChanged);
            }
         }
         this.setBuildingInteraction(this._tutorial.active ? Boolean(this._tutorial.stepNum > this._tutorial.getStepNum(Tutorial.STEP_CONSTRUCTION)) : true);
         this.updateAllianceFlag();
         AllianceSystem.getInstance().connected.add(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().disconnected.add(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().kicked.add(this.onAllianceKicked);
         if(!this.getBuildingPlacementValidity())
         {
            this._startupBuildingsValid = false;
            _loc11_ = new MessageBox(this._lang.getString("bld_place_invalid_msg"));
            _loc11_.addTitle(this._lang.getString("bld_place_invalid_title"));
            _loc11_.addButton(this._lang.getString("bld_place_invalid_ok"));
            _loc11_.open();
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:Survivor = null;
         var _loc7_:UISelectedIndicator = null;
         var _loc8_:Vector3D = null;
         var _loc9_:Point = null;
         var _loc5_:TaskCollection = this._network.playerData.compound.tasks;
         _loc3_ = _loc5_.length - 1;
         while(_loc3_ >= 0)
         {
            _loc5_.getTask(_loc3_).updateTimer();
            _loc3_--;
         }
         _loc3_ = 0;
         _loc4_ = int(this._survivors.length);
         while(_loc3_ < _loc4_)
         {
            _loc6_ = this._survivors[_loc3_];
            if(_loc6_.stateMachine.state == null)
            {
               _loc6_.stateMachine.setState(new SurvivorCompoundIdleState(_loc6_));
            }
            _loc6_.update(param1,param2);
            _loc7_ = this._ui_selectedBySurvivor[_loc6_];
            if(_loc7_.scene != null)
            {
               _loc7_.transform.position.x = _loc6_.actor.transform.position.x;
               _loc7_.transform.position.y = _loc6_.actor.transform.position.y;
               _loc7_.updateTransform();
            }
            _loc3_++;
         }
         if(this._mouseOverSurvivor != null)
         {
            _loc8_ = this._mouseOverSurvivor.actor.transform.position;
            _loc9_ = this._scene.getScreenPosition(_loc8_.x,_loc8_.y,_loc8_.z + this._mouseOverSurvivor.actor.getHeight() + 80);
            this.ui_survivorName.x = _loc9_.x - this.ui_survivorName.width * 0.5;
            this.ui_survivorName.y = _loc9_.y;
         }
      }
      
      private function addSurvivor(param1:Survivor, param2:Boolean = false) : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Cell = null;
         var _loc6_:JunkRemovalTask = null;
         var _loc7_:GameEntity = null;
         var _loc8_:Vector.<Cell> = null;
         if(param1 == null || param1.actor == null)
         {
            return;
         }
         param1.stateMachine.clear();
         param1.setActiveLoadout(null);
         param1.healthModifier = 1;
         param1.health = param1.maxHealth;
         param1.switchToWalk();
         param1.navigator.map = this._scene.map;
         param1.navigator.pathOptions.edgeFlagMask = NavEdgeFlag.ALL_NOT_DISABLED ^ NavEdgeFlag.TRAVERSAL_AREA;
         this._game.rvoSimulator.addAgent(param1.navigator);
         if(param2)
         {
            _loc3_ = this._scene.spawnPointsPlayer[0].clone();
            _loc3_.x += (Math.random() * 2 - 1) * 1000;
            param1.actor.targetForward = null;
            param1.actor.transform.setRotationEuler(0,0,_loc3_.w * Math.PI / 180);
         }
         else if(param1.state & SurvivorState.ON_TASK && param1.task != null && !param1.task.complete)
         {
            _loc6_ = param1.task as JunkRemovalTask;
            if(_loc6_ != null && _loc6_.target != null)
            {
               _loc7_ = _loc6_.target.entity;
               if(_loc7_ != null)
               {
                  _loc8_ = this._scene.map.getAccessibleCellsAroundEntity(_loc7_,null,new <Class>[Actor]);
                  if(_loc8_.length > 0)
                  {
                     _loc4_ = _loc8_[int(Math.random() * _loc8_.length)];
                     param1.stateMachine.setState(new SurvivorTaskState(param1,_loc7_));
                  }
               }
            }
            if(_loc4_ != null)
            {
               _loc3_ = this._scene.map.getCellCoords(_loc4_.x,_loc4_.y);
            }
         }
         if(_loc3_ == null)
         {
            _loc4_ = this._scene.getRandomUnoccupiedCellIndoors();
            _loc3_ = this._scene.map.getCellCoords(_loc4_.x,_loc4_.y);
         }
         param1.actor.transform.position.x = _loc3_.x;
         param1.actor.transform.position.y = _loc3_.y;
         param1.actor.transform.position.z = 0;
         param1.actor.updateTransform();
         param1.actor.setInteractionBoundBoxActiveState(true);
         param1.actorClicked.add(this.selectSurvivor);
         param1.actorMouseOver.add(this.onSurvivorMouseOver);
         param1.actorMouseOut.add(this.onSurvivorMouseOut);
         param1.taskChanged.add(this.onSurvivorTaskChanged);
         param1.classChanged.addOnce(this.onSurvivorClassChanged);
         param1.reassignmentStarted.addOnce(this.onSurvivorReassignStarted);
         param1.navigator.cancelAndStop();
         this._scene.addEntity(param1.actor);
         if(param1.stateMachine.state == null)
         {
            param1.stateMachine.setState(new SurvivorCompoundIdleState(param1));
            param1.actor.animatedAsset.gotoAndPlay(param1.getAnimation("idle"),0,true,0.05,0);
         }
         var _loc5_:UISelectedIndicator = new UISelectedIndicator();
         _loc5_.name = "_ui_selectedIndicator" + param1.id;
         this._ui_selectedBySurvivor[param1] = _loc5_;
         this._survivors.push(param1);
      }
      
      private function cleanSurvivor(param1:Survivor) : void
      {
         this._game.rvoSimulator.removeAgent(param1.navigator);
         param1.navigator.map = null;
         param1.stateMachine.clear();
         param1.navigator.cancelAndStop();
         param1.actorClicked.remove(this.selectSurvivor);
         param1.actorMouseOver.remove(this.onSurvivorMouseOver);
         param1.actorMouseOut.remove(this.onSurvivorMouseOut);
         param1.taskChanged.remove(this.onSurvivorTaskChanged);
         param1.classChanged.remove(this.onSurvivorClassChanged);
         param1.reassignmentStarted.remove(this.onSurvivorReassignStarted);
      }
      
      private function cancelBuildingPlacement() : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Building = null;
         if(this._movingBuilding == null || this._awaitingNewBuildingResponse)
         {
            return;
         }
         if(this._network.isBusy)
         {
            return;
         }
         this._scene.mouseMap.tileMouseOver.remove(this.onPlacementCellChanged);
         this._scene.mouseMap.tileClicked.remove(this.onPlacementCellClicked);
         this._scene.mouseMap.enabled = false;
         this._scene.map.clearBufferCells(this._movingBuilding.buildingEntity);
         if(this._placingNewBuilding)
         {
            this._movingBuilding.dispose();
         }
         else
         {
            _loc3_ = this._scene.map.getCellCoords(this._movingBuilding.tileX,this._movingBuilding.tileY);
            this._movingBuilding.rotation = this._movingBuildingRotation;
            this._movingBuilding.buildingEntity.footprintValid = true;
            this._movingBuilding.buildingEntity.transform.position.x = _loc3_.x;
            this._movingBuilding.buildingEntity.transform.position.y = _loc3_.y;
            this._movingBuilding.buildingEntity.flags &= ~EntityFlags.BEING_MOVED;
            this._movingBuilding.buildingEntity.updateTransform();
            this._scene.map.updateCellsForEntity(this._movingBuilding.buildingEntity);
            this._scene.map.setBufferCells(this._movingBuilding.buildingEntity);
         }
         var _loc1_:int = 0;
         var _loc2_:int = this._network.playerData.compound.buildings.numBuildings;
         while(_loc1_ < _loc2_)
         {
            _loc4_ = this._network.playerData.compound.buildings.getBuilding(_loc1_);
            if(_loc4_.entity.asset != null)
            {
               _loc4_.buildingEntity.footprintVisible = false;
            }
            _loc1_++;
         }
         this._movingBuilding = null;
         this._movingBuildingFootprint = null;
         this._placingNewBuilding = false;
         this._buyingNewBuilding = false;
         this.setBuildingInteraction(true);
      }
      
      private function selectSurvivor(param1:Survivor) : void
      {
         var uiSelect:UISelectedIndicator = null;
         var ui_selectSurvivor:UISelectedIndicator = null;
         var srv:Survivor = param1;
         if(this._selectedSurvivor == srv)
         {
            return;
         }
         if(this._selectedBuilding != null)
         {
            this.selectBuilding(null);
         }
         if(this._selectedSurvivor != null)
         {
            uiSelect = this._ui_selectedBySurvivor[this._selectedSurvivor];
            uiSelect.transitionOut(function():void
            {
               if(uiSelect.scene != null)
               {
                  uiSelect.scene.removeEntity(uiSelect);
               }
            });
         }
         this._selectedSurvivor = srv;
         if(this._selectedSurvivor != null)
         {
            ui_selectSurvivor = this._ui_selectedBySurvivor[srv];
            ui_selectSurvivor.transform.position.x = srv.actor.transform.position.x;
            ui_selectSurvivor.transform.position.y = srv.actor.transform.position.y;
            ui_selectSurvivor.transform.position.z = srv.actor.transform.position.z + 5;
            ui_selectSurvivor.updateTransform();
            ui_selectSurvivor.alpha = 1;
            if(ui_selectSurvivor.scene == null)
            {
               this._scene.addEntity(ui_selectSurvivor);
               ui_selectSurvivor.transitionIn();
            }
         }
      }
      
      public function createBuilding(param1:String, param2:Boolean = false) : void
      {
         var bld:Building = null;
         var mx:int = 0;
         var my:int = 0;
         var v:Vector3D = null;
         var bldId:String = param1;
         var buy:Boolean = param2;
         if(!this._network.playerData.canBuildBuilding(bldId,0,buy))
         {
            return;
         }
         bld = new Building(this._resources.getResource("xml/buildings.xml").content.item.(@id == bldId)[0]);
         bld.entity.name = "bld-" + bld.xml.@id.toString() + "-" + this._buildingId++;
         bld.entity.asset.mouseChildren = false;
         this._scene.mouseMap.enabled = true;
         mx = this._scene.mouseMap.mouseCell.x;
         my = this._scene.mouseMap.mouseCell.y;
         v = this._scene.map.getCellCoords(mx,my);
         bld.entity.transform.position.setTo(v.x,v.y,0);
         bld.entity.updateTransform();
         bld.entity.asset.visible = mx >= 0 && my >= 0;
         if(bld.isDecoyTrap)
         {
            bld.buildingEntity.showDecoyMarker(true);
         }
         this._scene.addEntity(bld.entity);
         this._placingNewBuilding = true;
         this._buyingNewBuilding = buy;
         this.moveBuilding(bld);
      }
      
      private function moveBuilding(param1:Building) : void
      {
         var _loc4_:Building = null;
         this.selectBuilding(null);
         this._movingBuilding = param1;
         this._movingBuildingRotation = param1.rotation;
         if(!this._placingNewBuilding)
         {
            this._movingBuildingFootprint = this._movingBuilding.buildingEntity.getFootprintRect(this._movingBuilding.tileX,this._movingBuilding.tileY);
         }
         this._scene.mouseMap.enabled = true;
         this._scene.mouseMap.tileMouseOver.add(this.onPlacementCellChanged);
         this._scene.mouseMap.tileClicked.add(this.onPlacementCellClicked);
         this._movingBuilding.buildingEntity.flags |= EntityFlags.BEING_MOVED;
         this._movingBuilding.buildingEntity.footprintVisible = true;
         this._placementLegal = this._movingBuilding.buildingEntity.isCurrentPositionValid();
         var _loc2_:int = 0;
         var _loc3_:int = this._network.playerData.compound.buildings.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this._network.playerData.compound.buildings.getBuilding(_loc2_);
            _loc4_.buildingEntity.footprintVisible = true;
            _loc2_++;
         }
         this.updateMovingBuildingValidity();
         this.setBuildingInteraction(false);
         this._gui.messageArea.setMessage(this._lang.getString("bld_instruct_rotate"),4);
      }
      
      private function removeJunk(param1:JunkBuilding, param2:Survivor = null) : void
      {
         var availableSurvivors:Vector.<Survivor>;
         var task:JunkRemovalTask = null;
         var currTask:Task = null;
         var i:int = 0;
         var srv:Survivor = null;
         var msg:MessageBox = null;
         var assigned:Array = null;
         var bld:JunkBuilding = param1;
         var survivor:Survivor = param2;
         if(!(bld.buildingEntity.flags & EntityFlags.REMOVABLE_JUNK))
         {
            return;
         }
         this.ui_buildingControl.hide();
         availableSurvivors = new Vector.<Survivor>();
         if(survivor == null)
         {
            i = 0;
            while(i < this._survivors.length)
            {
               srv = this._survivors[i];
               if(!(Boolean(srv.state & SurvivorState.ON_MISSION) || Boolean(srv.state & SurvivorState.ON_TASK) || Boolean(srv.state & SurvivorState.ON_ASSIGNMENT)))
               {
                  availableSurvivors.push(srv);
               }
               i++;
            }
         }
         else
         {
            availableSurvivors.push(survivor);
         }
         if(availableSurvivors.length == 0)
         {
            msg = new MessageBox(this._lang.getString("no_srv_available_msg"),null,true);
            msg.addTitle(this._lang.getString("no_srv_available_title"));
            msg.addButton(this._lang.getString("no_srv_available_ok"));
            msg.open();
            return;
         }
         for each(currTask in bld.tasks)
         {
            if(currTask is JunkRemovalTask && JunkRemovalTask(currTask).target == bld)
            {
               task = currTask as JunkRemovalTask;
               break;
            }
         }
         if(task == null)
         {
            task = new JunkRemovalTask(bld);
            for each(srv in availableSurvivors)
            {
               task.assignSurvivor(srv);
            }
            this._network.save(task.writeObject(),SaveDataMethod.TASK_STARTED,function(param1:Object):void
            {
               if(param1 == null || param1.items == null)
               {
                  _network.client.errorLog.writeError("PlayerCompoundDirector: removeJunk: SaveDataMethod.TASK_STARTED: Null or invalid response object received","","",{});
                  _network.throwSyncError();
                  return;
               }
               task.setItems(param1.items as Array);
               task.updateTimer();
               task.completed.addOnce(onTaskCompleted);
               task.statusChanged.add(onTaskStatusChanged);
               _network.playerData.compound.tasks.addTask(task);
               updateBuildingDisplay(bld);
            });
            this.onBuildingEntityMouseOut(BuildingEntity(bld.buildingEntity));
         }
         else
         {
            assigned = [];
            for each(srv in availableSurvivors)
            {
               task.assignSurvivor(srv);
               assigned.push(srv.id);
            }
            this._network.save({
               "taskId":task.id,
               "survivors":assigned
            },SaveDataMethod.TASK_SURVIVOR_ASSIGNED);
         }
      }
      
      private function pauseTask(param1:Task) : void
      {
         this.ui_buildingControl.hide();
         var _loc2_:Array = param1.removeAllSurvivors();
         if(_loc2_.length > 0)
         {
            this._network.save({
               "taskId":param1.id,
               "survivors":_loc2_
            },SaveDataMethod.TASK_SURVIVOR_REMOVED);
         }
      }
      
      private function selectBuilding(param1:Building) : void
      {
         if(Network.getInstance().isBusy)
         {
            return;
         }
         if(param1 == this._selectedBuilding)
         {
            return;
         }
         if(this._selectedBuilding != null)
         {
            this._selectedBuilding = null;
            this.ui_buildingControl.hide();
         }
         if(this._selectedSurvivor != null)
         {
            if(param1 is JunkBuilding)
            {
               this.removeJunk(JunkBuilding(param1),this._selectedSurvivor);
               this.selectSurvivor(null);
               return;
            }
            this.selectSurvivor(null);
         }
         if(param1 == null)
         {
            return;
         }
         this._selectedBuilding = param1;
         this.ui_buildingControl.building = param1;
         this.ui_buildingControl.show(this._gui);
      }
      
      private function setBuildingInteraction(param1:Boolean) : void
      {
         var _loc4_:Building = null;
         var _loc2_:int = 0;
         var _loc3_:int = this._network.playerData.compound.buildings.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this._network.playerData.compound.buildings.getBuilding(_loc2_);
            if(_loc4_.buildingEntity.asset != null)
            {
               _loc4_.buildingEntity.asset.mouseChildren = param1;
            }
            _loc2_++;
         }
      }
      
      private function updateBuildingDisplay(param1:Building) : void
      {
         var _loc5_:Task = null;
         var _loc6_:* = false;
         var _loc7_:UIBuildingIcon = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:UIBuildingIcon = this._ui_repairByBuilding[param1];
         if(param1.dead && param1.repairTimer == null)
         {
            if(_loc2_ == null)
            {
               _loc2_ = new UIBuildingIcon(param1,BmpIconRepair,-60);
               this._ui_repairByBuilding[param1] = _loc2_;
            }
            if(_loc2_.parent == null)
            {
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChildAt(_loc2_,0);
            }
            if(param1.destroyable)
            {
               return;
            }
         }
         else if(_loc2_ != null && _loc2_.parent != null)
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         var _loc3_:* = param1.upgradeTimer != null && !(param1.dead && param1.destroyable) || param1.repairTimer != null;
         if(!_loc3_)
         {
            if(param1.type == "recycler")
            {
               _loc3_ = this._network.playerData.batchRecycleJobs.numActiveJobs > 0;
            }
            else if(param1.tasks.length > 0)
            {
               _loc5_ = param1.tasks[0];
               _loc3_ = !_loc5_.complete;
            }
         }
         var _loc4_:UIConstructionProgress = this._ui_constructionProgressByBuilding[param1];
         if(_loc3_)
         {
            if(_loc4_ == null)
            {
               _loc4_ = new UIConstructionProgress(param1);
               this._ui_constructionProgressByBuilding[param1] = _loc4_;
            }
            _loc4_.updateLabel();
            if(_loc4_.parent == null)
            {
               this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc4_);
            }
            return;
         }
         if(_loc4_ != null && _loc4_.parent != null)
         {
            _loc4_.parent.removeChild(_loc4_);
         }
         if(param1.productionResource != null)
         {
            _loc6_ = param1.resourceValue >= param1.resourceCapacity;
            _loc7_ = this._ui_resourceFullByBuilding[param1];
            if(_loc6_)
            {
               if(_loc7_ == null)
               {
                  _loc7_ = new UIBuildingIcon(param1,BmpIconCollect,120);
                  this._ui_resourceFullByBuilding[param1] = _loc7_;
               }
               if(_loc7_.parent == null)
               {
                  this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChildAt(_loc7_,0);
               }
            }
            else if(_loc7_ != null && _loc7_.parent != null)
            {
               _loc7_.parent.removeChild(_loc7_);
            }
         }
      }
      
      private function getBuildingPlacementValidity() : Boolean
      {
         var _loc1_:Boolean = this.runBuildingPlacementValidityCheck();
         if(_loc1_)
         {
            this._guiCompound.unlockHUD();
         }
         else
         {
            this._guiCompound.lockHUD();
         }
         return _loc1_;
      }
      
      private function validateBuildingPlacement(param1:Building) : int
      {
         var _loc3_:Vector.<Point> = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Point = null;
         var _loc9_:Boolean = false;
         var _loc2_:Cell = this._scene.map.getCellAtCoords2(param1.entity.transform.position);
         if(param1.doorwayOnly)
         {
            if(!this._scene.isBuildingFullyInDoorway(param1,_loc2_.x,_loc2_.y))
            {
               return BUILDING_PLACEMENT_DOORWAY_ONLY;
            }
         }
         else
         {
            if(this._scene.isBuildingInDoorway(param1,_loc2_.x,_loc2_.y))
            {
               return BUILDING_PLACEMENT_NO_DOORWAY;
            }
            _loc3_ = param1.buildingEntity.getTileCoords();
            _loc4_ = true;
            _loc5_ = true;
            _loc6_ = param1.canBuildIndoors();
            _loc7_ = param1.canBuildOutdoors();
            for each(_loc8_ in _loc3_)
            {
               if(!this._scene.isInBuildArea(_loc8_.x,_loc8_.y))
               {
                  _loc4_ = false;
               }
               _loc9_ = this._scene.isIndoors(_loc8_.x,_loc8_.y);
               if(!_loc9_)
               {
                  _loc5_ = false;
               }
               if(_loc6_ && !_loc7_ && !_loc9_ || !_loc6_ && _loc7_ && _loc9_)
               {
                  _loc4_ = false;
               }
               if(!_loc4_)
               {
                  break;
               }
            }
            if(!_loc4_)
            {
               if(_loc5_ && !_loc6_)
               {
                  return BUILDING_PLACEMENT_OUTDOOR_ONLY;
               }
               if(!_loc5_ && !_loc7_)
               {
                  return BUILDING_PLACEMENT_INDOOR_ONLY;
               }
               return BUILDING_PLACEMENT_INVALID;
            }
            if(!param1.buildingEntity.isCurrentPositionValid())
            {
               return BUILDING_PLACEMENT_INVALID;
            }
         }
         return BUILDING_PLACEMENT_VALID;
      }
      
      private function runBuildingPlacementValidityCheck() : Boolean
      {
         var _loc2_:Building = null;
         var _loc5_:int = 0;
         var _loc1_:Boolean = true;
         var _loc3_:int = 0;
         var _loc4_:int = this._network.playerData.compound.buildings.numBuildings;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this._network.playerData.compound.buildings.getBuilding(_loc3_);
            if(!(_loc2_ is JunkBuilding))
            {
               _loc5_ = this.validateBuildingPlacement(_loc2_);
               if(_loc5_ != BUILDING_PLACEMENT_VALID)
               {
                  _loc1_ = false;
                  _loc2_.buildingEntity.footprintValid = false;
               }
            }
            _loc3_++;
         }
         _loc3_ = 0;
         _loc4_ = this._network.playerData.compound.buildings.numBuildings;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this._network.playerData.compound.buildings.getBuilding(_loc3_);
            _loc2_.buildingEntity.footprintVisible = !_loc1_;
            if(_loc1_)
            {
               _loc2_.buildingEntity.footprintValid = _loc1_;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      private function updateMovingBuildingValidity() : void
      {
         var _loc2_:String = null;
         if(this._movingBuilding == null)
         {
            return;
         }
         var _loc1_:int = this.validateBuildingPlacement(this._movingBuilding);
         this._placementLegal = _loc1_ == BUILDING_PLACEMENT_VALID;
         this._movingBuilding.buildingEntity.footprintValid = this._placementLegal;
         if(this._gui.messageArea.currentMessage != this._lang.getString("bld_instruct_rotate"))
         {
            if(!this._placementLegal)
            {
               switch(_loc1_)
               {
                  case BUILDING_PLACEMENT_INDOOR_ONLY:
                     _loc2_ = this._lang.getString("bld_instruct_indoor");
                     break;
                  case BUILDING_PLACEMENT_OUTDOOR_ONLY:
                     _loc2_ = this._lang.getString("bld_instruct_outdoor");
                     break;
                  case BUILDING_PLACEMENT_DOORWAY_ONLY:
                     _loc2_ = this._lang.getString("bld_instruct_doorway");
               }
               if(_loc2_ != null && this._gui.messageArea.currentMessage != _loc2_)
               {
                  this._gui.messageArea.setMessage(_loc2_,3,16711680);
               }
            }
         }
      }
      
      private function addXPFloaterMessage(param1:int, param2:GameEntity, param3:int = 0) : void
      {
         if(param2.asset == null)
         {
            return;
         }
         this.addFloaterMessage(this._lang.getString("msg_xp_awarded",NumberFormatter.format(param1,0)),16363264,param2,param3);
      }
      
      private function addFloaterMessage(param1:String, param2:uint, param3:GameEntity, param4:int) : void
      {
         var _loc5_:Vector3D = param3.getAssetCenter();
         _loc5_.x += param3.transform.position.x;
         _loc5_.y += param3.transform.position.y;
         _loc5_.z += param3.transform.position.z + param4;
         var _loc6_:UIFloatingMessage = UIFloatingMessage.pool.get() as UIFloatingMessage;
         _loc6_.init(param1,param2,this._scene,_loc5_.x,_loc5_.y,_loc5_.z,100);
         this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(_loc6_);
      }
      
      private function updateAllianceFlag() : void
      {
         var _loc1_:Building = this._network.playerData.compound.buildings.getFirstBuildingOfType("alliance-flag");
         if(_loc1_ != null && _loc1_.entity != null)
         {
            AllianceFlagEntity(_loc1_.entity).bannerData = AllianceSystem.getInstance().inAlliance && AllianceSystem.getInstance().alliance != null ? AllianceSystem.getInstance().alliance.banner : null;
         }
      }
      
      private function onGUIMouseDown(param1:MouseEvent) : void
      {
         if(!this._placingNewBuilding)
         {
            return;
         }
         var _loc2_:IEventDispatcher = param1.target as IEventDispatcher;
         if(_loc2_ != null && (Boolean(_loc2_.hasEventListener(MouseEvent.MOUSE_DOWN)) || Boolean(_loc2_.hasEventListener(MouseEvent.CLICK)) || Boolean(_loc2_.hasEventListener(MouseEvent.MOUSE_UP))))
         {
            this.cancelBuildingPlacement();
            param1.stopPropagation();
         }
      }
      
      private function onPlacementCellChanged(param1:int, param2:int, param3:int, param4:int) : void
      {
         this._scene.map.clearBufferCells(this._movingBuilding.buildingEntity);
         if(param1 < 0 || param2 < 0)
         {
            this._movingBuilding.buildingEntity.asset.visible = false;
            this._placementLegal = false;
            return;
         }
         var _loc5_:Vector3D = this._scene.map.getCellCoords(param1,param2);
         this._movingBuilding.buildingEntity.transform.position.setTo(_loc5_.x,_loc5_.y,0);
         this._movingBuilding.buildingEntity.updateTransform();
         this._movingBuilding.buildingEntity.asset.visible = true;
         this._scene.map.updateCellsForEntity(this._movingBuilding.buildingEntity,true);
         this._scene.map.setBufferCells(this._movingBuilding.buildingEntity);
         this.updateMovingBuildingValidity();
      }
      
      private function onPlacementCellClicked(param1:int, param2:int) : void
      {
         var handlePlacement:Function;
         var building:Building = null;
         var footprint:Rectangle = null;
         var cellX:int = param1;
         var cellY:int = param2;
         if(!this._placementLegal)
         {
            Audio.sound.play("sound/interface/int-error.mp3");
            return;
         }
         if(!Building.isWithinCompoundBounds(cellX,cellY))
         {
            Audio.sound.play("sound/interface/int-error.mp3");
            return;
         }
         building = this._movingBuilding;
         footprint = this._movingBuildingFootprint;
         this._scene.mouseMap.tileMouseOver.remove(this.onPlacementCellChanged);
         this._scene.mouseMap.tileClicked.remove(this.onPlacementCellClicked);
         this._scene.mouseMap.enabled = false;
         handlePlacement = function():void
         {
            var _loc4_:Rectangle = null;
            var _loc5_:Boolean = false;
            var _loc6_:Rectangle = null;
            var _loc7_:TraversalArea = null;
            var _loc8_:Building = null;
            if(_scene != null)
            {
               _scene.map.clearBufferCells(building.buildingEntity);
            }
            building.tileX = cellX;
            building.tileY = cellY;
            building.buildingEntity.flags &= ~EntityFlags.BEING_MOVED;
            if(_scene == null)
            {
               return;
            }
            var _loc1_:Vector3D = _scene.map.getCellCoords(building.tileX,building.tileY);
            building.buildingEntity.transform.position.setTo(_loc1_.x,_loc1_.y,0);
            building.buildingEntity.updateTransform();
            building.buildingEntity.asset.visible = true;
            _scene.map.updateCellsForEntity(building.buildingEntity);
            _scene.map.setBufferCells(building.buildingEntity);
            if(!building.buildingEntity.passable)
            {
               _loc4_ = building.buildingEntity.getFootprintRect(building.tileX,building.tileY);
               _loc5_ = false;
               if(!_placingNewBuilding)
               {
                  if(!footprint.equals(_loc4_))
                  {
                     if(building.traversalArea != null)
                     {
                        _scene.map.removeTraversalArea(building.traversalArea);
                     }
                     if(footprint.intersects(_loc4_))
                     {
                        _loc6_ = footprint.union(_loc4_);
                        var _loc9_:* = _loc6_;
                        var _loc10_:* = _loc9_.width + 1;
                        _loc9_.width = _loc10_;
                        _loc9_ = _loc6_;
                        _loc10_ = _loc9_.height + 1;
                        _loc9_.height = _loc10_;
                        _scene.map.rebuildNavGraphArea(_loc6_);
                     }
                     else
                     {
                        _loc9_ = footprint;
                        _loc10_ = _loc9_.width + 1;
                        _loc9_.width = _loc10_;
                        _loc9_ = footprint;
                        _loc10_ = _loc9_.height + 1;
                        _loc9_.height = _loc10_;
                        _loc9_ = _loc4_;
                        _loc10_ = _loc9_.width + 1;
                        _loc9_.width = _loc10_;
                        _loc9_ = _loc4_;
                        _loc10_ = _loc9_.height + 1;
                        _loc9_.height = _loc10_;
                        _scene.map.rebuildNavGraphArea(footprint);
                        _scene.map.rebuildNavGraphArea(_loc4_);
                     }
                     _loc5_ = building.isDoor;
                  }
               }
               else
               {
                  _scene.map.rebuildNavGraphArea(_loc4_);
                  _loc5_ = building.isDoor;
               }
               if(_loc5_)
               {
                  _loc7_ = _scene.map.addTraversalArea(_loc4_,15);
                  _loc7_.data = building;
                  building.traversalArea = _loc7_;
               }
            }
            var _loc2_:int = 0;
            var _loc3_:int = _network.playerData.compound.buildings.numBuildings;
            while(_loc2_ < _loc3_)
            {
               _loc8_ = _network.playerData.compound.buildings.getBuilding(_loc2_);
               _loc8_.buildingEntity.footprintVisible = false;
               _loc2_++;
            }
            setBuildingInteraction(true);
            _movingBuilding = null;
            _placingNewBuilding = false;
            _buyingNewBuilding = false;
            if(!_startupBuildingsValid)
            {
               _startupBuildingsValid = getBuildingPlacementValidity();
            }
         };
         if(this._placingNewBuilding)
         {
            this._awaitingNewBuildingResponse = true;
            this._guiCompound.mouseChildren = false;
            building.tileX = cellX;
            building.tileY = cellY;
            building.construct(this._buyingNewBuilding,function(param1:Boolean):void
            {
               _awaitingNewBuildingResponse = false;
               if(_guiCompound != null)
               {
                  _guiCompound.mouseChildren = true;
               }
               if(!param1)
               {
                  cancelBuildingPlacement();
                  return;
               }
               if(_scene != null)
               {
                  _scene.map.clearBufferCells(building.buildingEntity);
               }
               Network.getInstance().playerData.compound.buildings.addBuilding(building);
               handlePlacement();
               if(_scene == null)
               {
                  return;
               }
               building.buildingEntity.assetMouseDown.add(onBuildingEntityMouseDown);
               building.buildingEntity.assetMouseOver.add(onBuildingEntityMouseOver);
               building.buildingEntity.assetMouseOut.add(onBuildingEntityMouseOut);
               if(!(building is JunkBuilding))
               {
                  building.upgradeStarted.add(onBuildingUpgradeStarted);
                  building.repairStarted.add(onBuildingRepairStarted);
                  building.repairCompleted.add(onBuildingRepairCompleted);
                  building.resourcesCollected.add(onBuildingResourcesCollected);
                  building.resourceValueChanged.add(onBuildingResourcesChanged);
                  building.recycled.add(onBuildingRecycled);
               }
               Audio.sound.play("sound/interface/int-building-construct.mp3");
            });
         }
         else
         {
            this._network.startAsyncOp();
            this._network.save({
               "id":building.id,
               "tx":cellX,
               "ty":cellY,
               "rotation":building.rotation
            },SaveDataMethod.BUILDING_MOVE,function(param1:Object):void
            {
               Network.getInstance().completeAsyncOp();
               if(param1 == null || param1.success !== true)
               {
                  cancelBuildingPlacement();
                  return;
               }
               if(_scene != null)
               {
                  _scene.map.clearBufferCells(building.buildingEntity);
               }
               cellX = int(param1.x);
               cellY = int(param1.y);
               building.rotation = int(param1.r);
               handlePlacement();
               if(_scene == null)
               {
                  return;
               }
               Audio.sound.play("sound/interface/int-building-move.mp3");
            });
         }
      }
      
      private function onKeyPress(param1:KeyboardEvent) : void
      {
         if(this._network.isBusy)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case Keyboard.SPACE:
               if(this._movingBuilding)
               {
                  this._scene.map.clearBufferCells(this._movingBuilding.buildingEntity);
                  ++this._movingBuilding.rotation;
                  this._scene.map.setBufferCells(this._movingBuilding.buildingEntity);
               }
               this.updateMovingBuildingValidity();
               break;
            case Keyboard.ESCAPE:
               this.selectSurvivor(null);
               this.cancelBuildingPlacement();
         }
      }
      
      private function onKeyRelease(param1:KeyboardEvent) : void
      {
      }
      
      private function onTimerStarted(param1:TimerData) : void
      {
         var _loc3_:BatchRecycleJob;
         var _loc4_:Building = null;
         var _loc2_:Building = param1.target as Building;
         if(_loc2_ != null)
         {
            this.updateBuildingDisplay(_loc2_);
            return;
         }
         _loc3_ = param1.target as BatchRecycleJob;
         if(_loc3_ != null)
         {
            try
            {
               _loc4_ = this._network.playerData.compound.buildings.getBuildingsOfType("recycler")[0];
               this.updateBuildingDisplay(_loc4_);
            }
            catch(e:Error)
            {
            }
            return;
         }
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         var _loc3_:Building;
         var _loc4_:MissionData;
         var _loc5_:BatchRecycleJob;
         var _loc2_:Survivor = null;
         var _loc6_:int = 0;
         var _loc7_:Building = null;
         if(param1 == null)
         {
            return;
         }
         _loc3_ = param1.target as Building;
         if(_loc3_ != null)
         {
            this.updateBuildingDisplay(_loc3_);
            if(param1.data.type == "upgrade")
            {
               _loc6_ = Building.getBuildingXP(_loc3_.type,_loc3_.level);
               if(_loc6_ > 0)
               {
                  this._gui.messageArea.addNotification(this._lang.getString("msg_bld_complete",_loc3_.getName().toUpperCase(),_loc3_.level + 1,_loc6_),16363264,3,true);
                  this.addXPFloaterMessage(_loc6_,_loc3_.buildingEntity,60);
               }
            }
            return;
         }
         _loc4_ = param1.target as MissionData;
         if(_loc4_ != null)
         {
            if(param1.data.type == "return" && _loc4_.returnTimer == param1)
            {
               for each(_loc2_ in _loc4_.survivors)
               {
                  if(_loc2_ != null)
                  {
                     this.addSurvivor(_loc2_,true);
                  }
               }
            }
         }
         _loc2_ = param1.target as Survivor;
         if(_loc2_ != null)
         {
            if(!(_loc2_.state & SurvivorState.ON_MISSION) && !(_loc2_.state & SurvivorState.REASSIGNING) && !(_loc2_.state & SurvivorState.ON_ASSIGNMENT))
            {
               this.addSurvivor(_loc2_);
            }
         }
         _loc5_ = param1.target as BatchRecycleJob;
         if(_loc5_ != null)
         {
            try
            {
               _loc7_ = this._network.playerData.compound.buildings.getBuildingsOfType("recycler")[0];
               this.updateBuildingDisplay(_loc7_);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      private function onTimerCancelled(param1:TimerData) : void
      {
         var _loc2_:Building = param1.target as Building;
         if(_loc2_ != null)
         {
            this.updateBuildingDisplay(_loc2_);
            if(param1.data.level == 0)
            {
               if(this.ui_buildingControl.building == _loc2_)
               {
                  this.ui_buildingControl.building = null;
               }
               this._network.playerData.compound.buildings.removeBuilding(_loc2_);
               this._scene.map.clearBufferCells(_loc2_.buildingEntity);
               _loc2_.dispose();
               if(!this._startupBuildingsValid)
               {
                  this._startupBuildingsValid = this.getBuildingPlacementValidity();
               }
            }
            return;
         }
      }
      
      private function onConstructionStarted(param1:GameEvent) : void
      {
         if(this._network.isBusy)
         {
            return;
         }
         var _loc2_:String = param1.data.id;
         var _loc3_:Boolean = Boolean(param1.data.buy);
         this.createBuilding(_loc2_,_loc3_);
      }
      
      private function onBuildingDied(param1:Building, param2:Object) : void
      {
         if(this.ui_buildingControl.building == param1)
         {
            this.ui_buildingControl.hide();
         }
         this.updateBuildingDisplay(param1);
      }
      
      private function onBuildingUpgradeStarted(param1:Building, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         if(this.ui_buildingControl.building == param1)
         {
            this.ui_buildingControl.hide();
         }
         if(param2)
         {
            _loc3_ = Building.getBuildingXP(param1.type,param1.level);
            if(_loc3_ > 0)
            {
               this.addXPFloaterMessage(_loc3_,param1.buildingEntity,60);
            }
         }
         this.updateBuildingDisplay(param1);
      }
      
      private function onBuildingRepairStarted(param1:Building, param2:Boolean) : void
      {
         if(this.ui_buildingControl.building == param1)
         {
            this.ui_buildingControl.hide();
         }
         this.updateBuildingDisplay(param1);
         Audio.sound.play("sound/interface/int-building-construct.mp3");
      }
      
      private function onBuildingRepairCompleted(param1:Building) : void
      {
         var _loc2_:Rectangle = param1.buildingEntity.getFootprintRect(param1.tileX,param1.tileY);
         ++_loc2_.width;
         ++_loc2_.height;
         this._scene.map.rebuildNavGraphArea(_loc2_);
      }
      
      private function onBuildingRecycled(param1:Building) : void
      {
         if(this._selectedBuilding == param1)
         {
            this.selectBuilding(null);
         }
         this._scene.map.clearBufferCells(param1.buildingEntity);
         if(!this._startupBuildingsValid)
         {
            this._startupBuildingsValid = this.getBuildingPlacementValidity();
         }
         var _loc2_:UIConstructionProgress = this._ui_constructionProgressByBuilding[param1];
         if(_loc2_ != null)
         {
            _loc2_.dispose();
            delete this._ui_constructionProgressByBuilding[param1];
         }
         var _loc3_:UIBuildingIcon = this._ui_resourceFullByBuilding[param1];
         if(_loc3_ != null)
         {
            _loc3_.dispose();
            delete this._ui_resourceFullByBuilding[param1];
         }
         var _loc4_:UIBuildingIcon = this._ui_repairByBuilding[param1];
         if(_loc4_ != null)
         {
            _loc4_.dispose();
            delete this._ui_repairByBuilding[param1];
         }
      }
      
      private function onBuildingResourcesChanged(param1:Building) : void
      {
         this.updateBuildingDisplay(param1);
      }
      
      private function onBuildingResourcesCollected(param1:Building, param2:int) : void
      {
         if(param2 <= 0)
         {
            return;
         }
         var _loc3_:String = param1.productionResource;
         var _loc4_:String = "+" + NumberFormatter.format(int(param2),0) + " " + this._lang.getString("items." + _loc3_).toUpperCase();
         this.addFloaterMessage(_loc4_,GameResources.RESOURCE_COLORS[_loc3_],param1.buildingEntity,60);
         this.updateBuildingDisplay(param1);
      }
      
      private function onBuildingEntityMouseDown(param1:BuildingEntity) : void
      {
         this.selectBuilding(param1.buildingData);
      }
      
      private function onBuildingEntityMouseOver(param1:BuildingEntity) : void
      {
         this.ui_entityRollover.entity = param1;
         var _loc2_:* = (param1.flags & EntityFlags.REMOVABLE_JUNK) != 0;
         if(_loc2_)
         {
            this.ui_entityRollover.label = this._lang.getString("blds.junk");
         }
         else
         {
            this.ui_entityRollover.label = param1.buildingData.getName() + "<br/><font color=\'" + Color.colorToHex(11842740) + "\'>" + this._lang.getString("level",param1.buildingData.level + 1) + "</font>";
         }
         this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(this.ui_entityRollover);
         MouseCursors.setCursor(MouseCursors.INTERACT);
         if(this._selectedSurvivor != null && _loc2_)
         {
            this._gui.messageArea.setMessage(this._lang.getString("msg_click_remove"),3);
         }
      }
      
      private function onBuildingEntityMouseOut(param1:BuildingEntity) : void
      {
         this.ui_entityRollover.entity = null;
         this.ui_entityRollover.label = null;
         if(this.ui_entityRollover.parent != null)
         {
            this.ui_entityRollover.parent.removeChild(this.ui_entityRollover);
         }
         MouseCursors.setCursor(MouseCursors.DEFAULT);
      }
      
      private function onBuildingControlHidden() : void
      {
         this.selectBuilding(null);
      }
      
      private function onTaskCompleted(param1:Task) : void
      {
         var _loc3_:Survivor = null;
         var _loc4_:JunkRemovalTask = null;
         var _loc5_:GameEntity = null;
         var _loc2_:int = param1.getXP();
         if(param1 is JunkRemovalTask)
         {
            _loc4_ = JunkRemovalTask(param1);
            _loc5_ = _loc4_.target.buildingEntity;
            if(_loc5_ != null)
            {
               if(_loc2_ > 0)
               {
                  this.addXPFloaterMessage(_loc2_,_loc5_,60);
               }
               this._scene.removeEntity(_loc5_);
            }
            this.updateBuildingDisplay(_loc4_.target);
         }
         param1.statusChanged.remove(this.onTaskStatusChanged);
         param1.completed.remove(this.onTaskCompleted);
         for each(_loc3_ in _loc4_.survivors)
         {
            _loc3_.stateMachine.setState(new SurvivorCompoundIdleState(_loc3_));
         }
         if(_loc2_ > 0)
         {
            this._gui.messageArea.addNotification(this._lang.getString("survivor_tasks_complete." + param1.type,_loc2_),16363264,2,true);
         }
      }
      
      private function onTaskStatusChanged(param1:Task) : void
      {
         var _loc2_:JunkRemovalTask = null;
         if(param1.status == TaskStatus.COMPLETE)
         {
            return;
         }
         if(param1 is JunkRemovalTask)
         {
            _loc2_ = JunkRemovalTask(param1);
            this.updateBuildingDisplay(_loc2_.target);
         }
      }
      
      private function onPlayerLevelUp(param1:Survivor, param2:int) : void
      {
         this._gui.messageArea.addNotification(this._lang.getString("msg_level_up"),16363264,2,true);
      }
      
      private function onSurvivorTaskChanged(param1:Survivor) : void
      {
         var currentCell:Cell;
         var availableCells:Vector.<Cell> = null;
         var targetCell:Cell = null;
         var junkEnt:GameEntity = null;
         var srv:Survivor = param1;
         if(srv.task == null)
         {
            srv.stateMachine.setState(new SurvivorCompoundIdleState(srv));
            return;
         }
         currentCell = this._scene.map.getCellAtCoords(srv.actor.transform.position.x,srv.actor.transform.position.y);
         if(srv.task is JunkRemovalTask)
         {
            junkEnt = JunkRemovalTask(srv.task).target.entity;
            availableCells = this._scene.map.getAccessibleCellsAroundEntity(junkEnt,null,Vector.<Class>([Actor]));
         }
         if(availableCells == null || availableCells.length == 0)
         {
            return;
         }
         targetCell = this._scene.map.getClosestCellFromListToPoint(availableCells,srv.actor.transform.position);
         if(targetCell != null)
         {
            srv.navigator.resume();
            srv.navigator.moveToCell(targetCell.x,targetCell.y);
            srv.navigator.pathCompleted.addOnce(function(param1:NavigatorAgent, param2:Path):void
            {
               srv.stateMachine.clear();
               srv.stateMachine.setState(new SurvivorTaskState(srv,junkEnt));
            });
         }
         else
         {
            srv.stateMachine.setState(new SurvivorTaskState(srv,junkEnt));
         }
      }
      
      private function onNewSurvivorAdded(param1:Survivor) : void
      {
         this.addSurvivor(param1,true);
      }
      
      private function onSurvivorClassChanged(param1:Survivor) : void
      {
      }
      
      private function onDialogueOpened(param1:GenericEvent, param2:Dialogue) : void
      {
         this.cancelBuildingPlacement();
      }
      
      private function onTutorialStepChanged() : void
      {
         this.setBuildingInteraction(Boolean(this._tutorial.stepNum > this._tutorial.getStepNum(Tutorial.STEP_CONSTRUCTION)));
      }
      
      private function onSurvivorMouseOver(param1:Survivor) : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Point = null;
         this._mouseOverSurvivor = param1;
         if(this.ui_survivorName.stage == null)
         {
            this.ui_survivorName.text = this._mouseOverSurvivor.fullName;
            this.ui_survivorName.alpha = 0;
            TweenMax.to(this.ui_survivorName,0.15,{
               "alpha":1,
               "overwrite":true
            });
            _loc3_ = param1.actor.transform.position;
            _loc4_ = this._scene.getScreenPosition(_loc3_.x,_loc3_.y,_loc3_.z + param1.actor.getHeight() + 80);
            this.ui_survivorName.x = _loc4_.x - this.ui_survivorName.width * 0.5;
            this.ui_survivorName.y = _loc4_.y;
            this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChildAt(this.ui_survivorName,0);
         }
         if(param1 == this._selectedSurvivor)
         {
            return;
         }
         var _loc2_:UISelectedIndicator = this._ui_selectedBySurvivor[param1];
         _loc2_.transform.position.x = param1.actor.transform.position.x;
         _loc2_.transform.position.y = param1.actor.transform.position.y;
         _loc2_.transform.position.z = param1.actor.transform.position.z + 5;
         _loc2_.updateTransform();
         _loc2_.alpha = 0.75;
         _loc2_.transitionIn();
         if(_loc2_.scene == null)
         {
            this._scene.addEntity(_loc2_);
         }
      }
      
      private function onSurvivorMouseOut(param1:Survivor) : void
      {
         var ui_selectSurvivor:UISelectedIndicator = null;
         var srv:Survivor = param1;
         this._mouseOverSurvivor = null;
         if(this.ui_survivorName.parent != null)
         {
            this.ui_survivorName.parent.removeChild(this.ui_survivorName);
         }
         if(srv == this._selectedSurvivor)
         {
            return;
         }
         ui_selectSurvivor = this._ui_selectedBySurvivor[srv];
         ui_selectSurvivor.transitionOut(function():void
         {
            if(ui_selectSurvivor.scene != null)
            {
               ui_selectSurvivor.scene.removeEntity(ui_selectSurvivor);
            }
         });
      }
      
      private function onCenterOnEntityRequest(param1:GameEvent) : void
      {
         var _loc2_:GameEntity = param1.data as GameEntity;
         if(_loc2_ == null || _loc2_.asset == null)
         {
            return;
         }
         var _loc3_:Vector3D = _loc2_.getAssetCenter();
         _loc3_.x += _loc2_.transform.position.x;
         _loc3_.y += _loc2_.transform.position.y;
         _loc3_.z = _loc2_.transform.position.z - 100;
         this._scene.panTo(_loc3_.x,_loc3_.y,_loc3_.z);
      }
      
      private function onSurvivorReassignStarted(param1:Survivor) : void
      {
         var _loc2_:int = int(this._survivors.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._survivors.splice(_loc2_,1);
         }
         this.cleanSurvivor(param1);
         var _loc3_:UISelectedIndicator = this._ui_selectedBySurvivor[param1];
         if(_loc3_ != null)
         {
            _loc3_.dispose();
            delete this._ui_selectedBySurvivor[param1];
         }
      }
      
      private function onAllianceSystemConnectionChanged() : void
      {
         this.updateAllianceFlag();
      }
      
      private function onAllianceKicked() : void
      {
         this.updateAllianceFlag();
      }
   }
}

