package thelaststand.app.game
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.core.Global;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.TutorialArrow;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskType;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.app.game.gui.dialogues.ConstructionDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class Tutorial
   {
      
      private static var _instance:Tutorial;
      
      public static const STEP_INTRO:String = "intro";
      
      public static const STEP_CAMERA:String = "camera";
      
      public static const STEP_RESOURCES:String = "resources";
      
      public static const STEP_CONSTRUCTION:String = "openConstruction";
      
      public static const STEP_BUILD_WORKBENCH:String = "buildWorkbench";
      
      public static const STEP_PLACE_WORKBENCH:String = "placeWorkbench";
      
      public static const STEP_FOOD_WATER:String = "foodWater";
      
      public static const STEP_FOOD_WATER_SPEEDUP:String = "foodWaterSpeedUp";
      
      public static const STEP_SURVIVOR_SPOTTED:String = "survivorSpotted";
      
      public static const STEP_SURVIVOR_ARRIVE:String = "survivorArrive";
      
      public static const STEP_SURVIVOR_ASSIGN:String = "survivorAssign";
      
      public static const STEP_OPEN_MAP:String = "openMap";
      
      public static const STEP_SHOW_MAP:String = "showMap";
      
      public static const STEP_GOTO_TUTORIAL_SCENE:String = "gotoTutorialScene";
      
      public static const STEP_SELECT_TEAM:String = "selectTeam";
      
      public static const STEP_MOVEMENT:String = "movement";
      
      public static const STEP_COMBAT:String = "combat";
      
      public static const STEP_UNLIMITED_AMMO:String = "unlimitedAmmo";
      
      public static const STEP_SCAVENGING:String = "scavenging";
      
      public static const STEP_EXIT_ZONES:String = "exitZones";
      
      public static const STEP_RETURN_SPEED_UP:String = "returnSpeedUp";
      
      public static const STEP_BUILD_RESOURCE_STORAGE:String = "buildResStorage";
      
      public static const STEP_UPGRADE_WORKBENCH:String = "upgradeWorkbench";
      
      public static const STEP_SPEED_UP_WORKBENCH:String = "speedUpgradeWorkbench";
      
      public static const STEP_BUILD_PRODUCTION:String = "buildProduction";
      
      public static const STEP_COLLECT_RESOURCES:String = "collect";
      
      public static const STEP_JUNK_REMOVAL:String = "junk";
      
      public static const STEP_SECURITY:String = "security";
      
      public static const STEP_RALLY_FLAG:String = "rallyFlag";
      
      public static const STEP_ZOMBIE_ATTACK:String = "infectedSighted";
      
      public static const STEP_MORE_SURIVOVRS:String = "moreSurvivors";
      
      public static const STEP_COMFORT:String = "comfort";
      
      public static const STEP_MORALE:String = "morale";
      
      public static const STEP_END_TUTORIAL:String = "endTutorial";
      
      public static const STATE_WORKBENCH_PLACED:String = "workbenchPlaced";
      
      public static const STATE_WORKBENCH_BUILT:String = "workbenchBuilt";
      
      public static const STATE_FOOD_STORAGE_BUILT:String = "foodStorageBuilt";
      
      public static const STATE_FOOD_STORAGE_COMPLETE:String = "foodStorageComplete";
      
      public static const STATE_WATER_STORAGE_BUILT:String = "waterStorageBuilt";
      
      public static const STATE_WATER_STORAGE_COMPLETE:String = "waterStorageComplete";
      
      public static const STATE_WOOD_STORAGE_BUILT:String = "woodStorageBuilt";
      
      public static const STATE_METAL_STORAGE_BUILT:String = "metalStorageBuilt";
      
      public static const STATE_CLOTH_STORAGE_BUILT:String = "clothStorageBuilt";
      
      public static const STATE_AMMO_STORAGE_BUILT:String = "ammoStorageBuilt";
      
      public static const STATE_SURVIVOR_ARRIVED:String = "survivorArrived";
      
      public static const STATE_MOVEMENT_COUNT:String = "movementCount";
      
      public static const STATE_SCAVENGING_COMPLETE:String = "scavengingComplete";
      
      public static const STATE_MISSION_COMPLETE:String = "missionComplete";
      
      public static const STATE_ZOMBIE_ATTACK_READY:String = "zombieAttackReady";
      
      public static const STATE_SURVIVORS_ASSIGNED:String = "survivorsAssigned";
      
      private const TUTORIAL_DIALOGUE_NAME:String = "tutorial-step";
      
      private const TITLE_COLOR:uint = 4671303;
      
      private const PANEL_WIDTH:int = 290;
      
      private var _active:Boolean;
      
      private var _arrows:Vector.<TutorialArrow>;
      
      private var _currentStep:String;
      
      private var _dialogueMgr:DialogueManager;
      
      private var _lang:Language;
      
      private var _step:int;
      
      private var _steps:Vector.<String>;
      
      private var _states:Dictionary;
      
      private var _playerData:PlayerData;
      
      private var _allowedBuildings:Array;
      
      private var _survivorCheckInterval:Number;
      
      private var _zombieAttackRequested:Boolean = false;
      
      public var stepChanged:Signal;
      
      public var stateSet:Signal;
      
      public var completed:Signal;
      
      public function Tutorial(param1:TutorialSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("Tutorial is a Singleton and cannot be directly instantiated. Use Tutorial.getInstance().");
         }
         this._lang = Language.getInstance();
         this._playerData = Network.getInstance().playerData;
         this._arrows = new Vector.<TutorialArrow>();
         this._states = new Dictionary(true);
         this._allowedBuildings = [];
         this._dialogueMgr = DialogueManager.getInstance();
         this._dialogueMgr.dialogueOpened.add(this.onDialogueChanged);
         this._dialogueMgr.dialogueClosed.add(this.onDialogueChanged);
         this._steps = Vector.<String>([STEP_INTRO,STEP_CAMERA,STEP_RESOURCES,STEP_CONSTRUCTION,STEP_BUILD_WORKBENCH,STEP_PLACE_WORKBENCH,STEP_FOOD_WATER,STEP_FOOD_WATER_SPEEDUP,STEP_SURVIVOR_SPOTTED,STEP_SURVIVOR_ARRIVE,STEP_SURVIVOR_ASSIGN,STEP_OPEN_MAP,STEP_SHOW_MAP,STEP_GOTO_TUTORIAL_SCENE,STEP_SELECT_TEAM,STEP_MOVEMENT,STEP_COMBAT,STEP_UNLIMITED_AMMO,STEP_SCAVENGING,STEP_EXIT_ZONES,STEP_RETURN_SPEED_UP,STEP_BUILD_RESOURCE_STORAGE,STEP_UPGRADE_WORKBENCH,STEP_SPEED_UP_WORKBENCH,STEP_BUILD_PRODUCTION,STEP_COLLECT_RESOURCES,STEP_JUNK_REMOVAL,STEP_SECURITY,STEP_RALLY_FLAG,STEP_ZOMBIE_ATTACK,STEP_MORE_SURIVOVRS,STEP_COMFORT,STEP_MORALE,STEP_END_TUTORIAL]);
         this.stepChanged = new Signal();
         this.stateSet = new Signal(String,Object);
         this.completed = new Signal();
      }
      
      public static function getInstance() : Tutorial
      {
         return _instance || (_instance = new Tutorial(new TutorialSingletonEnforcer()));
      }
      
      public function end() : void
      {
         if(!this._active)
         {
            return;
         }
         this._active = false;
         this.completed.dispatch();
         TweenMax.killDelayedCallsTo(this.executeCurrentStep);
         clearInterval(this._survivorCheckInterval);
         this.clearCurrentObjects();
         this.stepChanged.removeAll();
         this.stateSet.removeAll();
         this.completed.removeAll();
         this._lang = null;
         this._playerData = null;
         this._steps = null;
         this._states = null;
         this._allowedBuildings = null;
         this._dialogueMgr.dialogueOpened.remove(this.onDialogueChanged);
         this._dialogueMgr.dialogueClosed.remove(this.onDialogueChanged);
         this._dialogueMgr = null;
         Global.stage.removeEventListener(GameEvent.CONSTRUCTION_START,this.onBuildingConstructionStarted);
         Global.stage.removeEventListener(NavigationEvent.REQUEST,this.onNavigationRequest);
         Network.getInstance().save({},SaveDataMethod.TUTORIAL_COMPLETE);
      }
      
      public function addArrow(param1:Object, param2:Number = 0, param3:Point = null) : TutorialArrow
      {
         var _loc4_:TutorialArrow = new TutorialArrow(param1,param2,param3);
         Global.stage.addChild(_loc4_);
         TweenMax.from(_loc4_,0.5,{"alpha":0});
         this._arrows.push(_loc4_);
         return _loc4_;
      }
      
      public function clearArrows() : void
      {
         var _loc1_:TutorialArrow = null;
         for each(_loc1_ in this._arrows)
         {
            _loc1_.dispose();
         }
         this._arrows.length = 0;
      }
      
      public function isBuildingAllowed(param1:String, param2:int = 1) : Boolean
      {
         if(this._allowedBuildings.indexOf(param1) == -1)
         {
            return false;
         }
         var _loc3_:int = Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType(param1);
         if(_loc3_ >= param2)
         {
            return false;
         }
         return true;
      }
      
      public function firstStep() : void
      {
         TweenMax.killDelayedCallsTo(this.executeCurrentStep);
         if(!this._active || this._steps == null)
         {
            return;
         }
         this.clearCurrentObjects();
         this._step = 0;
         this._currentStep = this._steps[this._step];
         this.executeCurrentStep();
      }
      
      public function gotoStep(param1:int) : void
      {
         TweenMax.killDelayedCallsTo(this.executeCurrentStep);
         if(!this._active || this._steps == null)
         {
            return;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 >= this._steps.length)
         {
            param1 = int(this._steps.length - 1);
         }
         this._step = param1;
         this._currentStep = this._steps[this._step];
         this.executeCurrentStep();
      }
      
      public function gotoStepId(param1:String) : void
      {
         if(!this._active || this._steps == null)
         {
            return;
         }
         var _loc2_:int = int(this._steps.indexOf(param1));
         this.gotoStep(_loc2_);
      }
      
      public function nextStep(param1:Number = 0) : void
      {
         TweenMax.killDelayedCallsTo(this.executeCurrentStep);
         if(!this._active || this._steps == null)
         {
            return;
         }
         if(++this._step >= this._steps.length)
         {
            this.end();
            return;
         }
         this._currentStep = this._steps[this._step];
         if(param1 > 0)
         {
            TweenMax.delayedCall(param1,this.executeCurrentStep);
         }
         else
         {
            this.executeCurrentStep();
         }
      }
      
      public function setState(param1:String, param2:Object) : void
      {
         this._states[param1] = param2;
         this.stateSet.dispatch(param1,param2);
      }
      
      public function getState(param1:String) : Object
      {
         return this._states[param1];
      }
      
      public function getStepNum(param1:String) : int
      {
         return this._steps.indexOf(param1);
      }
      
      private function executeCurrentStep() : void
      {
         var _loc1_:Dialogue = null;
         TweenMax.killDelayedCallsTo(this.executeCurrentStep);
         clearInterval(this._survivorCheckInterval);
         this.clearCurrentObjects();
         if(this["step_" + this._currentStep]())
         {
            this.stepChanged.dispatch();
            _loc1_ = DialogueManager.getInstance().getDialogueById(this.TUTORIAL_DIALOGUE_NAME);
            if(_loc1_ != null)
            {
               TweenMax.from(_loc1_.sprite,0.5,{
                  "delay":0.25,
                  "x":Number(_loc1_.sprite.width + 20).toString(),
                  "ease":Back.easeInOut,
                  "easeParams":[0.75]
               });
            }
         }
         else
         {
            this.nextStep();
         }
      }
      
      private function clearCurrentObjects() : void
      {
         var _loc1_:Dialogue = DialogueManager.getInstance().getDialogueById(this.TUTORIAL_DIALOGUE_NAME);
         if(_loc1_ != null)
         {
            TweenMax.killTweensOf(_loc1_);
            _loc1_.close();
         }
         this.clearArrows();
         Global.stage.removeEventListener(GameEvent.CONSTRUCTION_START,this.onBuildingConstructionStarted);
      }
      
      private function step_intro() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("workbench") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_intro_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body",this._playerData.getPlayerSurvivor().fullName),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         return true;
      }
      
      private function step_camera() : Boolean
      {
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("workbench") > 0)
         {
            return false;
         }
         var _loc1_:String = "tutorial.step_camera_";
         var _loc2_:MessageBox = new MessageBox(this._lang.getString(_loc1_ + "body",this._playerData.getPlayerSurvivor().fullName),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         _loc2_.addTitle(this._lang.getString(_loc1_ + "title"),this.TITLE_COLOR);
         _loc2_.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _loc2_.align = Dialogue.ALIGN_TOP_RIGHT;
         _loc2_.open();
         return true;
      }
      
      private function step_resources() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("workbench") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_resources_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body",this._playerData.getPlayerSurvivor().fullName),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         return true;
      }
      
      private function step_openConstruction() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("workbench") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_openConstruction_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = ["workbench"];
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "construction-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               nextStep();
               ConstructionDialogue(param2).refresh();
            }
         });
         return true;
      }
      
      private function step_buildWorkbench() : Boolean
      {
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("workbench") > 0)
         {
            return false;
         }
         var _loc1_:String = "tutorial.step_buildWorkbench_";
         var _loc2_:MessageBox = new MessageBox(this._lang.getString(_loc1_ + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         _loc2_.addTitle(this._lang.getString(_loc1_ + "title"),this.TITLE_COLOR);
         _loc2_.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _loc2_.align = Dialogue.ALIGN_TOP_RIGHT;
         _loc2_.open();
         Global.stage.addEventListener(GameEvent.CONSTRUCTION_START,this.onBuildingConstructionStarted,false,int.MAX_VALUE,true);
         return true;
      }
      
      private function step_placeWorkbench() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         if(Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType("workbench") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_placeWorkbench_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._playerData.compound.buildings.buildingAdded.add(function(param1:Building):void
         {
            var bld:Building = param1;
            if(bld.type == "workbench")
            {
               Network.getInstance().playerData.compound.buildings.buildingAdded.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               _states[STATE_WORKBENCH_PLACED] = bld;
               clearCurrentObjects();
               bld.upgradeStarted.addOnce(function(param1:Building, param2:Boolean):void
               {
                  var workbench:Building = param1;
                  var buy:Boolean = param2;
                  if(buy)
                  {
                     setState(STATE_WORKBENCH_BUILT,bld);
                     nextStep(0.1);
                  }
                  else
                  {
                     bld.upgradeTimer.completed.addOnce(function(param1:TimerData):void
                     {
                        setState(STATE_WORKBENCH_BUILT,bld);
                        nextStep(0.1);
                     });
                  }
               });
            }
         });
         return true;
      }
      
      private function step_foodWater() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var buildings:BuildingCollection = null;
         buildings = this._playerData.compound.buildings;
         var foodStorages:Vector.<Building> = buildings.getBuildingsOfType("storage-food");
         var waterStorages:Vector.<Building> = buildings.getBuildingsOfType("storage-water");
         if(foodStorages.length > 0)
         {
            this._states[STATE_FOOD_STORAGE_BUILT] = foodStorages[0];
         }
         if(waterStorages.length > 0)
         {
            this._states[STATE_WATER_STORAGE_BUILT] = waterStorages[0];
         }
         if(this._states[STATE_FOOD_STORAGE_BUILT] is Building && this._states[STATE_WATER_STORAGE_BUILT] is Building)
         {
            this._allowedBuildings = [];
            return false;
         }
         stepLangId = "tutorial.step_foodWater_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = ["storage-food","storage-water"];
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "construction-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               clearArrows();
               ConstructionDialogue(param2).refresh();
            }
         });
         buildings.buildingAdded.add(function(param1:Building):void
         {
            if(!_active)
            {
               buildings.buildingAdded.remove(arguments.callee);
               return;
            }
            if(param1.type == "storage-food")
            {
               _states[STATE_FOOD_STORAGE_BUILT] = param1;
            }
            else if(param1.type == "storage-water")
            {
               _states[STATE_WATER_STORAGE_BUILT] = param1;
            }
            if(_states[STATE_FOOD_STORAGE_BUILT] is Building && _states[STATE_WATER_STORAGE_BUILT] is Building)
            {
               buildings.buildingAdded.remove(arguments.callee);
               _allowedBuildings = [];
               nextStep(0.1);
            }
         });
         return true;
      }
      
      private function step_foodWaterSpeedUp() : Boolean
      {
         var foodStorage:Building;
         var waterStorage:Building;
         var stepLangId:String = "tutorial.step_foodWaterSpeedUp_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         foodStorage = this._states[STATE_FOOD_STORAGE_BUILT] as Building;
         if(foodStorage.upgradeTimer == null || foodStorage.upgradeTimer.hasEnded())
         {
            this.setState(STATE_FOOD_STORAGE_COMPLETE,true);
         }
         else
         {
            foodStorage.upgradeTimer.completed.addOnce(function(param1:TimerData):void
            {
               var _loc2_:Building = null;
               if(!_active)
               {
                  return;
               }
               setState(STATE_FOOD_STORAGE_COMPLETE,true);
               clearArrows();
               if(!_states[STATE_WATER_STORAGE_COMPLETE])
               {
                  _loc2_ = _states[STATE_WATER_STORAGE_BUILT] as Building;
                  if(_loc2_ != null)
                  {
                     addArrow(_loc2_.entity,90,new Point(0,-20));
                  }
               }
            });
            this.addArrow(foodStorage.entity,90,new Point(0,-20));
         }
         waterStorage = this._states[STATE_WATER_STORAGE_BUILT] as Building;
         if(waterStorage.upgradeTimer == null || waterStorage.upgradeTimer.hasEnded())
         {
            this.setState(STATE_WATER_STORAGE_COMPLETE,true);
         }
         else
         {
            waterStorage.upgradeTimer.completed.addOnce(function(param1:TimerData):void
            {
               var _loc2_:Building = null;
               if(!_active)
               {
                  return;
               }
               setState(STATE_WATER_STORAGE_COMPLETE,true);
               clearArrows();
               if(!_states[STATE_FOOD_STORAGE_COMPLETE])
               {
                  _loc2_ = _states[STATE_FOOD_STORAGE_BUILT] as Building;
                  if(_loc2_ != null)
                  {
                     addArrow(_loc2_.entity,90,new Point(0,-20));
                  }
               }
            });
            if(this._states[STATE_FOOD_STORAGE_COMPLETE])
            {
               this.addArrow(waterStorage.entity,90,new Point(0,-20));
            }
         }
         if(this._states[STATE_FOOD_STORAGE_COMPLETE] === true && this._states[STATE_WATER_STORAGE_COMPLETE] === true)
         {
            return false;
         }
         this.stateSet.add(function(param1:String, param2:Object):void
         {
            if(!_active)
            {
               stateSet.remove(arguments.callee);
               return;
            }
            if(_states[STATE_FOOD_STORAGE_COMPLETE] === true && _states[STATE_WATER_STORAGE_COMPLETE] === true)
            {
               stateSet.remove(arguments.callee);
               nextStep();
            }
         });
         return true;
      }
      
      private function step_survivorSpotted() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var survivors:SurvivorCollection = null;
         survivors = this._playerData.compound.survivors;
         if(survivors.length > 1)
         {
            this._states[STATE_SURVIVOR_ARRIVED] = survivors.getSurvivor(survivors.length - 1);
            return false;
         }
         this._survivorCheckInterval = setInterval(function():void
         {
            Network.getInstance().send(NetworkMessage.REQUEST_SURVIVOR_CHECK,null,function(param1:Object):void
            {
               if(param1 != null && param1.success === true)
               {
                  clearInterval(_survivorCheckInterval);
               }
            });
         },500);
         stepLangId = "tutorial.step_survivorSpotted_";
         this._dialogueMgr.closeAllNonModal();
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         survivors.survivorAdded.addOnce(function(param1:Survivor):void
         {
            survivors.survivorAdded.remove(arguments.callee);
            if(!_active)
            {
               return;
            }
            _states[STATE_SURVIVOR_ARRIVED] = param1;
         });
         this._dialogueMgr.dialogueClosed.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2 is EventAlertDialogue)
            {
               DialogueManager.getInstance().dialogueClosed.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               nextStep(1);
            }
         });
         return true;
      }
      
      private function step_survivorArrive() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var srv:Survivor = this._states[STATE_SURVIVOR_ARRIVED] as Survivor;
         if(srv == null || srv.classId != SurvivorClass.UNASSIGNED)
         {
            return false;
         }
         stepLangId = "tutorial.step_survivorArrive_";
         this._dialogueMgr.closeAllNonModal();
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "survivor-dialgoue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               nextStep(0.1);
            }
         });
         return true;
      }
      
      private function step_survivorAssign() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var srv:Survivor = this._states[STATE_SURVIVOR_ARRIVED] as Survivor;
         if(srv == null || srv.classId != SurvivorClass.UNASSIGNED)
         {
            return false;
         }
         stepLangId = "tutorial.step_survivorAssign_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         srv ||= this._playerData.compound.survivors.getSurvivor(this._playerData.compound.survivors.length - 1);
         srv.classChanged.addOnce(function(param1:Survivor):void
         {
            var srv:Survivor = param1;
            if(!_active)
            {
               return;
            }
            clearCurrentObjects();
            setTimeout(function():void
            {
               DialogueManager.getInstance().closeAll();
               if(!_active)
               {
                  return;
               }
               nextStep(1);
            },100);
         });
         return true;
      }
      
      private function step_openMap() : Boolean
      {
         var _loc2_:MissionData = null;
         var _loc3_:String = null;
         var _loc4_:MessageBox = null;
         var _loc1_:BuildingCollection = this._playerData.compound.buildings;
         if(_loc1_.getNumBuildingsOfType("storage-wood") > 0 || _loc1_.getNumBuildingsOfType("storage-metal") > 0 || _loc1_.getNumBuildingsOfType("storage-cloth") > 0)
         {
            this._step = this.getStepNum(STEP_BUILD_RESOURCE_STORAGE) - 1;
            return false;
         }
         for each(_loc2_ in this._playerData.missionList.getMissionsByAreaType("tutorialStore"))
         {
            if(!_loc2_.complete || _loc2_.lockTimer != null || _loc2_.returnTimer != null)
            {
               this._step = this.getStepNum(STEP_RETURN_SPEED_UP) - 1;
               return false;
            }
         }
         _loc3_ = "tutorial.step_openMap_";
         _loc4_ = new MessageBox(this._lang.getString(_loc3_ + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         _loc4_.addTitle(this._lang.getString(_loc3_ + "title"),this.TITLE_COLOR);
         _loc4_.align = Dialogue.ALIGN_TOP_RIGHT;
         _loc4_.open();
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_showMap() : Boolean
      {
         var stepLangId:String = "tutorial.step_showMap_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_gotoTutorialScene() : Boolean
      {
         var stepLangId:String = "tutorial.step_gotoTutorialScene_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "mission-loadout")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               nextStep(0.1);
            }
         });
         return true;
      }
      
      private function step_selectTeam() : Boolean
      {
         var _loc1_:String = "tutorial.step_selectTeam_";
         var _loc2_:MessageBox = new MessageBox(this._lang.getString(_loc1_ + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         _loc2_.addTitle(this._lang.getString(_loc1_ + "title"),this.TITLE_COLOR);
         _loc2_.align = Dialogue.ALIGN_TOP_RIGHT;
         _loc2_.open();
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_movement() : Boolean
      {
         var stateListener:Function = null;
         var stepLangId:String = "tutorial.step_movement_";
         stateListener = function(param1:String, param2:Object):void
         {
            if(_states[STATE_MOVEMENT_COUNT] >= 1)
            {
               stateSet.remove(stateListener);
               nextStep();
            }
         };
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120}).clicked.addOnce(function(param1:MouseEvent):void
         {
            stateSet.remove(stateListener);
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this.stateSet.add(stateListener);
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_combat() : Boolean
      {
         var stepLangId:String = "tutorial.step_combat_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_unlimitedAmmo() : Boolean
      {
         var stepLangId:String = "tutorial.step_ammo_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_scavenging() : Boolean
      {
         var stateListener:Function = null;
         var stepLangId:String = "tutorial.step_scavenging_";
         stateListener = function(param1:String, param2:Object):void
         {
            if(_states[STATE_SCAVENGING_COMPLETE] === true)
            {
               stateSet.remove(stateListener);
               nextStep();
            }
         };
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120}).clicked.addOnce(function(param1:MouseEvent):void
         {
            stateSet.remove(stateListener);
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this.stateSet.add(stateListener);
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_exitZones() : Boolean
      {
         var _loc1_:String = "tutorial.step_exitZones_";
         var _loc2_:MessageBox = new MessageBox(this._lang.getString(_loc1_ + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         _loc2_.addTitle(this._lang.getString(_loc1_ + "title"),this.TITLE_COLOR);
         _loc2_.addButton(this._lang.getString(_loc1_ + "continue"),true,{"width":120});
         _loc2_.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _loc2_.align = Dialogue.ALIGN_TOP_RIGHT;
         _loc2_.open();
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_returnSpeedUp() : Boolean
      {
         var mission:MissionData;
         var stepLangId:String = null;
         var dlg:MessageBox = null;
         Network.getInstance().connection.send(NetworkMessage.REQUEST_ZOMBIE_ATTACK);
         this._zombieAttackRequested = true;
         mission = this._states[STATE_MISSION_COMPLETE] as MissionData || this._playerData.missionList.getMissionsByAreaType("tutorialStore")[0];
         if(mission == null || mission.returnTimer == null || mission.returnTimer.hasEnded())
         {
            return false;
         }
         stepLangId = "tutorial.step_returnSpeedUp_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         mission.returnTimer.completed.addOnce(function(param1:TimerData):void
         {
            if(!_active)
            {
               return;
            }
            clearCurrentObjects();
            nextStep(1);
         });
         return true;
      }
      
      private function step_buildResStorage() : Boolean
      {
         var metalStorage:Vector.<Building>;
         var clothStorage:Vector.<Building>;
         var ammoStorage:Vector.<Building>;
         var stepLangId:String;
         var dlg:MessageBox;
         var buildings:BuildingCollection = null;
         buildings = this._playerData.compound.buildings;
         var woodStorage:Vector.<Building> = buildings.getBuildingsOfType("storage-wood");
         if(woodStorage.length > 0)
         {
            this._states[STATE_WOOD_STORAGE_BUILT] = woodStorage[0];
         }
         metalStorage = buildings.getBuildingsOfType("storage-metal");
         if(metalStorage.length > 0)
         {
            this._states[STATE_METAL_STORAGE_BUILT] = metalStorage[0];
         }
         clothStorage = buildings.getBuildingsOfType("storage-cloth");
         if(clothStorage.length > 0)
         {
            this._states[STATE_CLOTH_STORAGE_BUILT] = clothStorage[0];
         }
         ammoStorage = buildings.getBuildingsOfType("storage-ammunition");
         if(ammoStorage.length > 0)
         {
            this._states[STATE_AMMO_STORAGE_BUILT] = ammoStorage[0];
         }
         if(this._states[STATE_WOOD_STORAGE_BUILT] is Building && this._states[STATE_METAL_STORAGE_BUILT] is Building && this._states[STATE_CLOTH_STORAGE_BUILT] is Building && this._states[STATE_AMMO_STORAGE_BUILT] is Building)
         {
            return false;
         }
         stepLangId = "tutorial.step_buildResStorage_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = ["storage-wood","storage-metal","storage-cloth","storage-ammunition"];
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "construction-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               ConstructionDialogue(param2).refresh();
               clearArrows();
            }
         });
         buildings.buildingAdded.add(function(param1:Building):void
         {
            if(!_active)
            {
               buildings.buildingAdded.remove(arguments.callee);
               return;
            }
            switch(param1.type)
            {
               case "storage-wood":
                  _states[STATE_WOOD_STORAGE_BUILT] = param1;
                  break;
               case "storage-metal":
                  _states[STATE_METAL_STORAGE_BUILT] = param1;
                  break;
               case "storage-cloth":
                  _states[STATE_CLOTH_STORAGE_BUILT] = param1;
                  break;
               case "storage-ammunition":
                  _states[STATE_AMMO_STORAGE_BUILT] = param1;
            }
            if(_states[STATE_WOOD_STORAGE_BUILT] is Building && _states[STATE_METAL_STORAGE_BUILT] is Building && _states[STATE_CLOTH_STORAGE_BUILT] is Building && _states[STATE_AMMO_STORAGE_BUILT] is Building)
            {
               buildings.buildingAdded.remove(arguments.callee);
               clearCurrentObjects();
               _allowedBuildings = [];
               nextStep(0.25);
            }
         });
         return true;
      }
      
      private function step_upgradeWorkbench() : Boolean
      {
         var stepLangId:String = null;
         var dlg:MessageBox = null;
         var bld:Building = this._playerData.compound.buildings.getBuildingsOfType("workbench")[0];
         if(bld.level > 0 || bld.upgradeTimer != null && bld.upgradeTimer.data.level > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_upgradeWorkbench_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this.addArrow(bld.entity,90,new Point(0,-20));
         bld.upgradeStarted.addOnce(function(param1:Building, param2:Boolean):void
         {
            if(!_active)
            {
               return;
            }
            clearArrows();
            nextStep(0.5);
         });
         return true;
      }
      
      private function step_speedUpgradeWorkbench() : Boolean
      {
         var stepLangId:String = null;
         var dlg:MessageBox = null;
         var bld:Building = this._playerData.compound.buildings.getBuildingsOfType("workbench")[0];
         if(bld.upgradeTimer == null || bld.upgradeTimer.hasEnded())
         {
            return false;
         }
         stepLangId = "tutorial.step_speedUpgradeWorkbench_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this.addArrow(bld.entity,90,new Point(0,-20));
         bld.upgradeTimer.completed.addOnce(function(param1:TimerData):void
         {
            if(!_active)
            {
               return;
            }
            clearArrows();
            nextStep(0.5);
         });
         return true;
      }
      
      private function step_buildProduction() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var buildings:BuildingCollection = null;
         buildings = this._playerData.compound.buildings;
         if(buildings.getNumBuildingsOfType("resource-food") > 0 || buildings.getNumBuildingsOfType("resource-water") > 0 || buildings.getNumBuildingsOfType("resource-wood") > 0 || buildings.getNumBuildingsOfType("resource-metal") > 0 || buildings.getNumBuildingsOfType("resource-cloth") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_buildProduction_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = ["resource-food","resource-water","resource-wood","resource-metal","resource-cloth"];
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "construction-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               ConstructionDialogue(param2).refresh();
               clearArrows();
            }
         });
         buildings.buildingAdded.add(function(param1:Building):void
         {
            if(!_active)
            {
               buildings.buildingAdded.remove(arguments.callee);
               return;
            }
            if(param1.productionResource != null)
            {
               buildings.buildingAdded.remove(arguments.callee);
               clearCurrentObjects();
               _allowedBuildings = [];
               nextStep(0.1);
            }
         });
         return true;
      }
      
      private function step_collect() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var buildings:BuildingCollection = this._playerData.compound.buildings;
         if(buildings.getNumBuildingsOfType("barricadeSmall") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_collect_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         return true;
      }
      
      private function step_junk() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var junkList:Vector.<Building>;
         var bld:Building;
         var buildings:BuildingCollection = this._playerData.compound.buildings;
         if(buildings.getNumBuildingsOfType("barricadeSmall") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_junk_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120}).clicked.addOnce(function(param1:MouseEvent):void
         {
            nextStep(0.1);
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         junkList = this._playerData.compound.buildings.getBuildingsOfType("junk-tutorial");
         bld = junkList.length > 0 ? junkList[0] : null;
         if(bld != null)
         {
            this.addArrow(bld.entity,90,new Point(0,-20));
         }
         this._playerData.compound.tasks.taskAdded.add(function(param1:Task):void
         {
            if(!_active)
            {
               Network.getInstance().playerData.compound.tasks.taskAdded.remove(arguments.callee);
               return;
            }
            if(param1 != null && param1.type == TaskType.JUNK_REMOVAL)
            {
               Network.getInstance().playerData.compound.tasks.taskAdded.remove(arguments.callee);
               if(_step <= getStepNum(STEP_JUNK_REMOVAL))
               {
                  clearCurrentObjects();
                  nextStep();
               }
            }
         });
         return true;
      }
      
      private function step_security() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var buildings:BuildingCollection = null;
         buildings = this._playerData.compound.buildings;
         if(buildings.getNumBuildingsOfType("barricadeSmall") > 0)
         {
            return false;
         }
         stepLangId = "tutorial.step_security_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = ["barricadeSmall"];
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "construction-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               clearArrows();
            }
         });
         buildings.buildingAdded.add(function(param1:Building):void
         {
            if(!_active)
            {
               buildings.buildingAdded.remove(arguments.callee);
               return;
            }
            if(param1.type == "barricadeSmall")
            {
               buildings.buildingAdded.remove(arguments.callee);
               _allowedBuildings = [];
               nextStep(0.25);
            }
         });
         return true;
      }
      
      private function step_rallyFlag() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var bld:Building;
         var numAssigned:int;
         var i:int = 0;
         var srv:Survivor = null;
         var survivorList:SurvivorCollection = null;
         if(!this._zombieAttackRequested)
         {
            Network.getInstance().connection.send(NetworkMessage.REQUEST_ZOMBIE_ATTACK);
            this._zombieAttackRequested = true;
         }
         stepLangId = "tutorial.step_rallyFlag_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         bld = this._playerData.compound.buildings.getBuildingsOfType("rally")[0];
         this.addArrow(bld.entity,90,new Point(0,-20));
         numAssigned = 0;
         survivorList = Network.getInstance().playerData.compound.survivors;
         i = 0;
         while(i < survivorList.length)
         {
            srv = survivorList.getSurvivor(i);
            if(srv == null || srv.rallyAssignment != null)
            {
               numAssigned++;
            }
            else
            {
               srv.rallyAssignmentChanged.add(this.onSurvivorRallyAssignementChanged);
            }
            i++;
         }
         this.stateSet.add(function(param1:String, param2:Object):void
         {
            if(param1 != STATE_SURVIVORS_ASSIGNED)
            {
               return;
            }
            if(int(param2) >= survivorList.length)
            {
               stateSet.remove(arguments.callee);
               i = 0;
               while(i < survivorList.length)
               {
                  srv = survivorList.getSurvivor(i);
                  if(srv != null)
                  {
                     srv.rallyAssignmentChanged.remove(onSurvivorRallyAssignementChanged);
                  }
                  ++i;
               }
               if(!_active)
               {
                  return;
               }
               clearCurrentObjects();
               nextStep(2);
            }
         });
         this.setState(STATE_SURVIVORS_ASSIGNED,numAssigned);
         return true;
      }
      
      private function step_infectedSighted() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:MessageBox = null;
         if(this._states[STATE_ZOMBIE_ATTACK_READY] !== true)
         {
            _loc1_ = "tutorial.step_infectedSighted_";
            _loc2_ = new MessageBox(this._lang.getString(_loc1_ + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
            _loc2_.addTitle(this._lang.getString(_loc1_ + "title"),this.TITLE_COLOR);
            _loc2_.align = Dialogue.ALIGN_TOP_RIGHT;
            _loc2_.open();
         }
         Global.stage.addEventListener(NavigationEvent.REQUEST,this.onNavigationRequest,false,0,true);
         return true;
      }
      
      private function step_moreSurvivors() : Boolean
      {
         var stepLangId:String = "tutorial.step_moreSurvivors_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "compound-report-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               clearArrows();
               nextStep(1);
            }
         });
         return true;
      }
      
      private function step_comfort() : Boolean
      {
         var stepLangId:String;
         var dlg:MessageBox;
         var buildings:BuildingCollection = null;
         buildings = this._playerData.compound.buildings;
         if(buildings.getNumBuildingsOfType("bed") > 1)
         {
            return false;
         }
         stepLangId = "tutorial.step_comfort_";
         dlg = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = ["bed"];
         this._dialogueMgr.dialogueOpened.add(function(param1:GenericEvent, param2:Dialogue):void
         {
            if(param2 != null && param2.id == "construction-dialogue")
            {
               DialogueManager.getInstance().dialogueOpened.remove(arguments.callee);
               if(!_active)
               {
                  return;
               }
               ConstructionDialogue(param2).refresh();
               clearArrows();
            }
         });
         buildings.buildingAdded.add(function(param1:Building):void
         {
            if(!_active)
            {
               buildings.buildingAdded.remove(arguments.callee);
               return;
            }
            if(param1.type == "bed")
            {
               buildings.buildingAdded.remove(arguments.callee);
               nextStep(0.25);
            }
         });
         return true;
      }
      
      private function step_morale() : Boolean
      {
         var stepLangId:String = "tutorial.step_morale_";
         var dlg:MessageBox = new MessageBox(this._lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(this._lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(this._lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         return true;
      }
      
      private function step_endTutorial() : Boolean
      {
         var stepLangId:String = "tutorial.step_endTutorial_";
         var lang:Language = Language.getInstance();
         var dlg:MessageBox = new MessageBox(lang.getString(stepLangId + "body"),this.TUTORIAL_DIALOGUE_NAME,false,false,this.PANEL_WIDTH,this.PANEL_WIDTH);
         dlg.addTitle(lang.getString(stepLangId + "title"),this.TITLE_COLOR);
         dlg.addButton(lang.getString(stepLangId + "continue"),true,{"width":120});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            nextStep();
         });
         dlg.buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         dlg.align = Dialogue.ALIGN_TOP_RIGHT;
         dlg.open();
         this._allowedBuildings = [];
         return true;
      }
      
      private function onDialogueChanged(param1:GenericEvent, param2:Dialogue) : void
      {
         var _loc5_:TutorialArrow = null;
         var _loc3_:Dialogue = DialogueManager.getInstance().getDialogueById(this.TUTORIAL_DIALOGUE_NAME);
         var _loc4_:Boolean = _loc3_ != null && this._dialogueMgr.getActiveDialogue() == _loc3_;
         if(_loc3_ != null)
         {
            _loc3_.sprite.visible = _loc4_;
         }
         for each(_loc5_ in this._arrows)
         {
            _loc5_.visible = _loc4_;
         }
      }
      
      private function onBuildingConstructionStarted(param1:GameEvent) : void
      {
         var _loc2_:Dialogue = DialogueManager.getInstance().getDialogueById(this.TUTORIAL_DIALOGUE_NAME);
         switch(this._currentStep)
         {
            case Tutorial.STEP_BUILD_WORKBENCH:
               if(param1.data.id == "workbench")
               {
                  Global.stage.removeEventListener(GameEvent.CONSTRUCTION_START,this.onBuildingConstructionStarted);
                  if(_loc2_ != null)
                  {
                     _loc2_.close();
                  }
                  this.nextStep();
                  return;
               }
         }
      }
      
      private function onSurvivorRallyAssignementChanged(param1:Survivor) : void
      {
         var _loc2_:int = 0;
         var _loc3_:SurvivorCollection = Network.getInstance().playerData.compound.survivors;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            param1 = _loc3_.getSurvivor(_loc4_);
            if(param1.rallyAssignment != null)
            {
               _loc2_++;
            }
            _loc4_++;
         }
         this.setState(STATE_SURVIVORS_ASSIGNED,_loc2_);
      }
      
      private function onNavigationRequest(param1:NavigationEvent) : void
      {
         var e:NavigationEvent = param1;
         if(this._currentStep == STEP_OPEN_MAP && e.location == NavigationLocation.WORLD_MAP)
         {
            this.clearCurrentObjects();
            Global.stage.removeEventListener(NavigationEvent.REQUEST,this.onNavigationRequest);
            this.nextStep(2);
            return;
         }
         if(this._currentStep == STEP_SELECT_TEAM && e.location == NavigationLocation.MISSION)
         {
            this.clearCurrentObjects();
            Global.stage.removeEventListener(NavigationEvent.REQUEST,this.onNavigationRequest);
            return;
         }
         if(this._step >= this.getStepNum(STEP_MOVEMENT) && this._step <= this.getStepNum(STEP_EXIT_ZONES) && e.location == NavigationLocation.PLAYER_COMPOUND)
         {
            this.clearCurrentObjects();
            Global.stage.removeEventListener(NavigationEvent.REQUEST,this.onNavigationRequest);
            this._dialogueMgr.dialogueClosed.add(function(param1:GenericEvent, param2:Dialogue):void
            {
               if(param2 != null && param2.id.indexOf("mission-report-dialogue") == 0)
               {
                  DialogueManager.getInstance().dialogueClosed.remove(arguments.callee);
                  if(!_active)
                  {
                     return;
                  }
                  gotoStep(getStepNum(STEP_EXIT_ZONES) + 1);
               }
            });
            return;
         }
         if(this._currentStep == STEP_ZOMBIE_ATTACK)
         {
            if(e.location == NavigationLocation.MISSION)
            {
               this.clearCurrentObjects();
            }
            else if(e.location == NavigationLocation.PLAYER_COMPOUND)
            {
               this._dialogueMgr.dialogueClosed.add(function(param1:GenericEvent, param2:Dialogue):void
               {
                  if(param2 != null && param2.id.indexOf("mission-report-dialogue") == 0)
                  {
                     DialogueManager.getInstance().dialogueClosed.remove(arguments.callee);
                     if(!_active)
                     {
                        return;
                     }
                     nextStep(1);
                  }
               });
            }
            return;
         }
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         this._active = param1;
      }
      
      public function get numSteps() : int
      {
         return this._steps != null ? int(this._steps.length) : 0;
      }
      
      public function get stepNum() : int
      {
         return this._step;
      }
      
      public function get step() : String
      {
         return this._currentStep;
      }
      
      public function get dialogue() : Dialogue
      {
         return DialogueManager.getInstance().getDialogueById(this.TUTORIAL_DIALOGUE_NAME);
      }
   }
}

class TutorialSingletonEnforcer
{
   
   public function TutorialSingletonEnforcer()
   {
      super();
   }
}
