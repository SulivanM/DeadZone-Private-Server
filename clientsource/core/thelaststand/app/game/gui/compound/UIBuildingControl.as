package thelaststand.app.game.gui.compound
{
   import alternativa.engine3d.core.BoundBox;
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.text.AntiAliasType;
   import flash.ui.Keyboard;
   import org.osflash.signals.Signal;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.JunkBuilding;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskType;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.buildings.DoorBuildingEntity;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.ConstructionUpgradeDialogue;
   import thelaststand.app.game.gui.dialogues.CraftingDialogue;
   import thelaststand.app.game.gui.dialogues.JunkItemsDialogue;
   import thelaststand.app.game.gui.dialogues.RecycleDialogue;
   import thelaststand.app.game.gui.dialogues.RecycleItemsDialogue;
   import thelaststand.app.game.gui.dialogues.RenameCarDialogue;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.engine.utils.BoundingBoxUtils;
   
   public class UIBuildingControl extends Sprite
   {
      
      private var _building:Building;
      
      private var _lang:Language;
      
      private var _neighborBuilding:Boolean;
      
      private var _padding:int = 10;
      
      private var _width:int = 130;
      
      private var _height:int = 168;
      
      private var _targetPos:Vector3D;
      
      private var _speedUpTarget:*;
      
      private var _buttons:Vector.<PushButton>;
      
      private var _reassignSurvivor:Survivor;
      
      private var _reassignTimer:TimerData;
      
      private var btn_help:PushButton;
      
      private var btn_taskControl:PushButton;
      
      private var btn_contents:PushButton;
      
      private var btn_move:PushButton;
      
      private var btn_dismantle:PushButton;
      
      private var btn_upgrade:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var btn_speedUp:PushButton;
      
      private var btn_collect:PushButton;
      
      private var btn_assign:PushButton;
      
      private var btn_startRecycle:PushButton;
      
      private var btn_startDispose:PushButton;
      
      private var btn_craft:PushButton;
      
      private var btn_door:PushButton;
      
      private var btn_repair:PushButton;
      
      private var btn_repairNow:PurchasePushButton;
      
      private var btn_restock:PushButton;
      
      private var btn_rename:PushButton;
      
      private var btn_research:PushButton;
      
      private var mc_background:Shape;
      
      private var txt_name:TitleTextField;
      
      private var txt_level:TitleTextField;
      
      private var txt_resource:BodyTextField;
      
      private var mc_jobPanel:UIBuildingJobPanel;
      
      private var mc_ratingComfort:RatingDisplay;
      
      private var mc_ratingSecurity:RatingDisplay;
      
      private var mc_ratingRange:RatingDisplay;
      
      private var mc_productionProgress:ProductionProgress;
      
      private var ui_assignment:UIRallyAssignment;
      
      public var moveClicked:Signal;
      
      public var removeClicked:Signal;
      
      public var pauseTaskClicked:Signal;
      
      public var helpClicked:Signal;
      
      public var hidden:Signal;
      
      public function UIBuildingControl(param1:Boolean = false)
      {
         var _loc4_:PushButton = null;
         this._targetPos = new Vector3D();
         super();
         this._lang = Language.getInstance();
         this._neighborBuilding = param1;
         this.hidden = new Signal();
         this.mc_productionProgress = new ProductionProgress(this._width - this._padding * 2);
         this.ui_assignment = new UIRallyAssignment();
         this.ui_assignment.mouseOverSlot.add(this.onMouseOverAssignmentSlot);
         this.ui_assignment.mouseOutSlot.add(this.onMouseOutAssignmentSlot);
         this.mc_background = new Shape();
         this.mc_background.filters = [BaseDialogue.INNER_SHADOW,BaseDialogue.STROKE,BaseDialogue.DROP_SHADOW];
         addChild(this.mc_background);
         this.txt_name = new TitleTextField({
            "color":14408667,
            "size":18
         });
         this.txt_name.text = " ";
         this.txt_name.maxWidth = this._width - 8;
         this.txt_name.y = this._padding - 6;
         addChild(this.txt_name);
         this.txt_level = new TitleTextField({
            "color":11053224,
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_level);
         this.txt_resource = new BodyTextField({
            "color":16777215,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_resource.text = " ";
         this.txt_resource.filters = [Effects.STROKE];
         addChild(this.txt_resource);
         var _loc2_:int = int(this._width - this._padding * 2);
         var _loc3_:int = int((this._width - _loc2_) * 0.5);
         this.btn_move = new PushButton(this._lang.getString("bld_control_move"),new BmpIconButtonMove(),6964590);
         this.btn_cancel = new PushButton(this._lang.getString("bld_control_cancel"),new BmpIconButtonClose(),7545099);
         this.btn_speedUp = new PurchasePushButton(this._lang.getString("bld_control_speedup"),0,false);
         this.btn_upgrade = new PushButton(this._lang.getString("bld_control_upgrade"),new BmpIconButtonUpgrade(),3044237);
         this.btn_dismantle = new PushButton(this._lang.getString("bld_control_dismantle"),new BmpIconDismantle(),16761856);
         this.btn_collect = new PushButton(this._lang.getString("bld_control_collect"),new BmpIconButtonCollect(),10899245);
         this.btn_taskControl = new PushButton(this._lang.getString("bld_control_remove"),new BmpIconButtonClose(),16761856);
         this.btn_contents = new PushButton(this._lang.getString("bld_control_junkcontents"),new BmpIconButtonCollect(),7545099);
         this.btn_help = new PurchasePushButton(this._lang.getString("bld_control_help"),0,false);
         this.btn_startRecycle = new PushButton(this._lang.getString("bld_control_startrecycle"),new BmpIconRecycle(),3183890);
         this.btn_startDispose = new PushButton(this._lang.getString("bld_control_startdispose"),new BmpIconIncinerator(),12071698);
         this.btn_assign = new PushButton(this._lang.getString("bld_control_assign"),new BmpIconButtonAssign(),8530705);
         this.btn_craft = new PushButton(this._lang.getString("bld_control_craft"),new BmpIconCrafting(),4151908);
         this.btn_door = new PushButton(this._lang.getString("bld_control_open"),new BmpIconDoor(),4151908);
         this.btn_repair = new PushButton(this._lang.getString("bld_control_repair"),new BmpIconButtonRepair(),10830376);
         this.btn_repairNow = new PurchasePushButton(this._lang.getString("bld_control_repairnow"),0,false);
         this.btn_restock = new PushButton(this._lang.getString("bld_control_restock"),new BmpIconButtonRepair(),10830376);
         this.btn_rename = new PushButton(this._lang.getString("bld_control_rename"),new BmpIconRename(),3044237);
         this.btn_research = new PushButton(this._lang.getString("bld_control_research"),new BmpIconResearchSmall(),3044237);
         this._buttons = Vector.<PushButton>([this.btn_speedUp,this.btn_help,this.btn_restock,this.btn_repair,this.btn_repairNow,this.btn_rename,this.btn_door,this.btn_collect,this.btn_research,this.btn_startRecycle,this.btn_startDispose,this.btn_craft,this.btn_upgrade,this.btn_assign,this.btn_contents,this.btn_taskControl,this.btn_move,this.btn_dismantle,this.btn_cancel]);
         for each(_loc4_ in this._buttons)
         {
            _loc4_.clicked.add(this.onButtonClicked);
            _loc4_.width = _loc2_;
            _loc4_.x = _loc3_;
         }
         this.mc_ratingComfort = new RatingDisplay(new BmpIconComfort(),this._lang.getString("bld_comfort"));
         this.mc_ratingSecurity = new RatingDisplay(new BmpIconSecurity(),this._lang.getString("bld_security"));
         this.mc_ratingRange = new RatingDisplay(new BmpIconRange(),this._lang.getString("bld_range"));
         this.moveClicked = new Signal(Building);
         this.removeClicked = new Signal(Building);
         this.pauseTaskClicked = new Signal(Task);
         this.helpClicked = new Signal(Building);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         DialogueManager.getInstance().dialogueOpened.add(this.onDialogueOpened);
         DialogueManager.getInstance().dialogueClosed.add(this.onDialogueClosed);
      }
      
      public function dispose() : void
      {
         var _loc1_:PushButton = null;
         var _loc2_:Task = null;
         Network.getInstance().playerData.stateUpdated.remove(this.onStateUpdated);
         DialogueManager.getInstance().dialogueOpened.remove(this.onDialogueOpened);
         DialogueManager.getInstance().dialogueClosed.remove(this.onDialogueClosed);
         if(this._building)
         {
            if(this._building.upgradeTimer != null)
            {
               this._building.upgradeTimer.cancelled.remove(this.onTimerCancelledOrCompleted);
               this._building.upgradeTimer.completed.remove(this.onTimerCancelledOrCompleted);
            }
            if(this._building.repairTimer != null)
            {
               this._building.repairTimer.completed.remove(this.onTimerCancelledOrCompleted);
            }
            for each(_loc2_ in this._building.tasks)
            {
               _loc2_.completed.remove(this.onTaskCompleted);
            }
         }
         for each(_loc1_ in this._buttons)
         {
            _loc1_.dispose();
         }
         this._buttons = null;
         if(this.mc_jobPanel != null)
         {
            TweenMax.killTweensOf(this.mc_jobPanel);
            this.mc_jobPanel.dispose();
            this.mc_jobPanel = null;
         }
         this.txt_name.dispose();
         this.txt_level.dispose();
         this.txt_resource.dispose();
         this.ui_assignment.dispose();
         this.mc_background.filters = [];
         this.moveClicked.removeAll();
         this.removeClicked.removeAll();
         this.pauseTaskClicked.removeAll();
         this.helpClicked.removeAll();
         this.hidden.removeAll();
         this._lang = null;
         this._building = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function show(param1:Sprite) : void
      {
         if(this._building != null)
         {
            if(this._building.repairTimer != null)
            {
               this._building.repairTimer.completed.addOnce(this.onTimerCancelledOrCompleted);
            }
            if(this._building.upgradeTimer != null)
            {
               this._building.upgradeTimer.cancelled.addOnce(this.onTimerCancelledOrCompleted);
               this._building.upgradeTimer.completed.addOnce(this.onTimerCancelledOrCompleted);
            }
            if(this._building.tasks.length > 0)
            {
               this._building.tasks[0].completed.addOnce(this.onTaskCompleted);
            }
            if(this._building.assignable && !this._building.dead)
            {
               this._building.buildingEntity.showAssignPosition();
            }
         }
         param1.addChild(this);
         Audio.sound.play("sound/interface/int-open.mp3");
      }
      
      public function hide() : void
      {
         var _loc1_:Task = null;
         if(this._building != null)
         {
            if(this._building.assignable)
            {
               this._building.saveAssignments();
               this._building.buildingEntity.hideAssignPositions();
            }
            if(this._building.repairTimer != null)
            {
               this._building.repairTimer.completed.remove(this.onTimerCancelledOrCompleted);
            }
            if(this._building.upgradeTimer != null)
            {
               this._building.upgradeTimer.cancelled.remove(this.onTimerCancelledOrCompleted);
               this._building.upgradeTimer.completed.remove(this.onTimerCancelledOrCompleted);
            }
            for each(_loc1_ in this._building.tasks)
            {
               _loc1_.completed.remove(this.onTaskCompleted);
            }
         }
         if(parent != null)
         {
            parent.removeChild(this);
            this.hidden.dispatch();
            Audio.sound.play("sound/interface/int-close.mp3");
         }
      }
      
      private function removeElements() : void
      {
         var _loc1_:PushButton = null;
         if(this.mc_jobPanel != null)
         {
            TweenMax.killTweensOf(this.mc_jobPanel);
            this.mc_jobPanel.dispose();
            this.mc_jobPanel = null;
         }
         for each(_loc1_ in this._buttons)
         {
            if(_loc1_.parent != null)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
         if(this.ui_assignment.parent != null)
         {
            this.ui_assignment.parent.removeChild(this.ui_assignment);
         }
         if(this.mc_productionProgress.parent != null)
         {
            this.mc_productionProgress.parent.removeChild(this.mc_productionProgress);
         }
         if(this.mc_ratingComfort.parent != null)
         {
            this.mc_ratingComfort.parent.removeChild(this.mc_ratingComfort);
         }
         if(this.mc_ratingSecurity.parent != null)
         {
            this.mc_ratingSecurity.parent.removeChild(this.mc_ratingSecurity);
         }
         if(this.mc_ratingRange.parent != null)
         {
            this.mc_ratingRange.parent.removeChild(this.mc_ratingRange);
         }
         if(this.txt_resource.parent != null)
         {
            this.txt_resource.parent.removeChild(this.txt_resource);
         }
      }
      
      private function showNeighborInterface() : int
      {
         var _loc1_:int = 0;
         if(this._building is JunkBuilding)
         {
            this.txt_name.text = this._lang.getString("blds.junk").toUpperCase();
            this.txt_name.x = int((this._width - this.txt_name.width) * 0.5);
            this.txt_level.text = this._lang.getString("bld_control_timetoremove",DateTimeUtils.secondsToString(JunkBuilding(this._building).removalTime));
            this.txt_level.x = int((this._width - this.txt_level.width) * 0.5);
            this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
            addChild(this.txt_level);
            _loc1_ = int(this.txt_level.y + this.txt_level.height + this._padding);
         }
         else
         {
            this.txt_name.text = this._building.getName().toUpperCase();
            this.txt_name.x = int((this._width - this.txt_name.width) * 0.5);
            if(this._building.maxLevel > 0)
            {
               this.txt_level.text = this._lang.getString("level",this._building.level + 1).toUpperCase();
               this.txt_level.x = int((this._width - this.txt_level.width) * 0.5);
               this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
               addChild(this.txt_level);
               _loc1_ = int(this.txt_level.y + this.txt_level.height + this._padding);
            }
            else
            {
               if(this.txt_level.parent != null)
               {
                  this.txt_level.parent.removeChild(this.txt_level);
               }
               _loc1_ = int(this.txt_name.y + this.txt_name.height + this._padding);
            }
            if(this._building.upgradeTimer != null && !this._building.dead)
            {
               this._building.upgradeTimer.completed.addOnce(this.onTimerCancelledOrCompleted);
               this._building.upgradeTimer.cancelled.addOnce(this.onTimerCancelledOrCompleted);
               addChild(this.btn_help);
               this.mc_jobPanel = new UIBuildingTimerPanel();
               this.mc_jobPanel.jobTitle = this._lang.getString(this._building.isUnderConstruction() ? "bld_control_constructing" : "bld_control_upgrading");
               UIBuildingTimerPanel(this.mc_jobPanel).message = this._lang.getString("bld_control_speeduptofinish");
               UIBuildingTimerPanel(this.mc_jobPanel).time = this._building.upgradeTimer.getTimeRemaining();
               addChildAt(this.mc_jobPanel,0);
            }
         }
         return _loc1_;
      }
      
      private function showJunkInterface() : int
      {
         this.txt_name.text = this._lang.getString("blds.junk").toUpperCase();
         this.txt_name.x = int((this._width - this.txt_name.width) * 0.5);
         this.txt_level.text = this._lang.getString("bld_control_timetoremove",DateTimeUtils.secondsToString(JunkBuilding(this._building).removalTime));
         this.txt_level.x = int((this._width - this.txt_level.width) * 0.5);
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
         addChild(this.txt_level);
         var _loc1_:int = int(this.txt_level.y + this.txt_level.height + this._padding);
         var _loc2_:Boolean = true;
         var _loc3_:Task = this._building.tasks.length > 0 ? this._building.tasks[0] : null;
         if(_loc3_ != null && _loc3_.type == TaskType.JUNK_REMOVAL)
         {
            this._speedUpTarget = _loc3_;
            _loc3_.completed.addOnce(this.onTaskCompleted);
            this.btn_speedUp.enabled = _loc3_.getSecondsRemaining() > 5;
            addChild(this.btn_speedUp);
            addChild(this.btn_contents);
            if(_loc3_.survivors.length > 0)
            {
               _loc2_ = false;
               this.btn_taskControl.data = "pause";
               this.btn_taskControl.label = this._lang.getString("bld_control_pause");
               Bitmap(this.btn_taskControl.icon).bitmapData = new BmpIconPause();
               this.btn_taskControl.enabled = true;
            }
            this.mc_jobPanel = new UIBuildingTimerPanel();
            this.mc_jobPanel.jobTitle = this._lang.getString("bld_control_removing");
            UIBuildingTimerPanel(this.mc_jobPanel).message = this._lang.getString("bld_control_speeduptofinish");
            UIBuildingTimerPanel(this.mc_jobPanel).time = _loc3_.survivors.length == 0 ? this._lang.getString("bld_onhold").toUpperCase() : DateTimeUtils.secondsToString((_loc3_.length - _loc3_.time) / _loc3_.survivors.length,true,true);
            addChildAt(this.mc_jobPanel,0);
         }
         if(_loc2_)
         {
            this.btn_taskControl.data = "remove";
            this.btn_taskControl.label = this._lang.getString("bld_control_remove");
            Bitmap(this.btn_taskControl.icon).bitmapData = new BmpIconButtonClose();
            this.btn_taskControl.enabled = true;
         }
         addChild(this.btn_taskControl);
         return _loc1_;
      }
      
      private function showBuildingInterface() : int
      {
         var _loc1_:int = 0;
         var _loc6_:Task = null;
         var _loc7_:BatchRecycleJob = null;
         var _loc8_:ResearchTask = null;
         var _loc9_:Number = NaN;
         var _loc10_:SurvivorCollection = null;
         var _loc11_:int = 0;
         var _loc12_:Survivor = null;
         var _loc13_:* = false;
         var _loc14_:DoorBuildingEntity = null;
         var _loc2_:int = Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType(this._building.type);
         var _loc3_:Boolean = this._building.recyclable && _loc2_ > Building.getMinNumOfBuilding(this._building.type);
         var _loc4_:Boolean = true;
         var _loc5_:Boolean = true;
         this.txt_name.text = this._building.getName().toUpperCase();
         this.txt_name.x = int((this._width - this.txt_name.width) * 0.5);
         if(this._building.maxLevel > 0)
         {
            this.txt_level.text = this._lang.getString("level",this._building.level + 1).toUpperCase();
            this.txt_level.x = int((this._width - this.txt_level.width) * 0.5);
            this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
            addChild(this.txt_level);
            _loc1_ = int(this.txt_level.y + this.txt_level.height + this._padding);
         }
         else
         {
            if(this.txt_level.parent != null)
            {
               this.txt_level.parent.removeChild(this.txt_level);
            }
            _loc1_ = int(this.txt_name.y + this.txt_name.height + this._padding);
         }
         if(this._building.dead && this._building.repairTimer == null)
         {
            this.mc_jobPanel = new UIBuildingRepairPanel(this._building);
            addChildAt(this.mc_jobPanel,0);
            this.btn_dismantle.enabled = !Tutorial.getInstance().active;
            addChild(this.btn_dismantle);
            if(this._building.productionResource != null)
            {
               this.btn_restock.enabled = Network.getInstance().playerData.canRepairBuilding(this._building.type,this._building.level);
               addChild(this.btn_restock);
            }
            else
            {
               this.btn_repair.enabled = Network.getInstance().playerData.canRepairBuilding(this._building.type,this._building.level);
               this.btn_repairNow.cost = Building.getBuildingRepairFuelCost(this._building.type,this._building.level);
               addChild(this.btn_repair);
               addChild(this.btn_repairNow);
            }
         }
         if(this._building.tasks.length > 0)
         {
            _loc6_ = this._building.tasks[0];
            _loc6_.completed.addOnce(this.onTaskCompleted);
         }
         if(this._building.productionResource != null || this._building.storageResource != null)
         {
            this.mc_productionProgress.x = int((this._width - this.mc_productionProgress.width) * 0.5);
            this.mc_productionProgress.y = _loc1_ - 5;
            this.mc_productionProgress.value = this._building.resourceValue / this._building.resourceCapacity;
            addChild(this.mc_productionProgress);
            this.txt_resource.y = int(this.mc_productionProgress.y + (this.mc_productionProgress.height - this.txt_resource.height) * 0.5);
            addChild(this.txt_resource);
            this.updateResourceProgress();
            this.mc_productionProgress.color = this._building.storageResource != null ? uint(GameResources.RESOURCE_COLORS[this._building.storageResource]) : 4894528;
            _loc1_ = int(this.mc_productionProgress.y + this.mc_productionProgress.height + this._padding);
         }
         else if(this._building.type == "recycler")
         {
            _loc7_ = Network.getInstance().playerData.batchRecycleJobs.getJob(0);
            if(_loc7_ != null && _loc7_.timer != null && !_loc7_.timer.hasEnded())
            {
               this._speedUpTarget = _loc7_;
               this.mc_jobPanel = new UIBuildingTimerPanel();
               this.mc_jobPanel.jobTitle = this._lang.getString("bld_control_recycling");
               UIBuildingTimerPanel(this.mc_jobPanel).message = this._lang.getString("bld_control_speeduptofinish");
               UIBuildingTimerPanel(this.mc_jobPanel).time = _loc7_.timer.getTimeRemaining();
               addChildAt(this.mc_jobPanel,0);
               _loc5_ = false;
               _loc3_ = false;
               this.btn_speedUp.enabled = _loc7_.timer.getSecondsRemaining() > 5;
               addChild(this.txt_resource);
               addChild(this.btn_speedUp);
               addChild(this.btn_contents);
               this.updateRecycleProgress();
            }
            else if(this._building.upgradeTimer == null)
            {
               addChild(this.btn_startRecycle);
            }
         }
         else if(this._building.type == "incinerator")
         {
            addChild(this.btn_startDispose);
         }
         else if(this._building.type == "alliance-flag")
         {
            if(AllianceSystem.getInstance().inAlliance)
            {
               _loc3_ = false;
            }
         }
         else if(this._building.type == "bench-research")
         {
            _loc8_ = Network.getInstance().playerData.researchState.currentTask;
            if(_loc8_ != null && !_loc8_.isCompleted)
            {
               _loc5_ = false;
               _loc3_ = false;
               this.mc_jobPanel = new UIBuildingTimerPanel();
               this.mc_jobPanel.jobTitle = this._lang.getString("bld_control_researching");
               UIBuildingTimerPanel(this.mc_jobPanel).message = ResearchSystem.getCategoryGroupName(_loc8_.category,_loc8_.group,_loc8_.level);
               UIBuildingTimerPanel(this.mc_jobPanel).time = _loc8_.timeReamining;
               addChildAt(this.mc_jobPanel,0);
            }
            if(this._building.upgradeTimer == null)
            {
               addChild(this.btn_research);
            }
         }
         else if(this._building.type == "trainingCenter")
         {
            this._reassignTimer = null;
            this._reassignSurvivor = null;
            _loc9_ = 0;
            _loc10_ = Network.getInstance().playerData.compound.survivors;
            _loc11_ = 0;
            while(_loc11_ < _loc10_.length)
            {
               _loc12_ = _loc10_.getSurvivor(_loc11_);
               if(_loc12_.reassignTimer != null && _loc12_.reassignTimer.getSecondsRemaining() > _loc9_)
               {
                  this._reassignTimer = _loc12_.reassignTimer;
                  this._reassignSurvivor = _loc12_;
                  _loc9_ = this._reassignTimer.getSecondsRemaining();
               }
               _loc11_++;
            }
            if(this._reassignTimer != null)
            {
               _loc5_ = false;
               _loc3_ = false;
               this.mc_jobPanel = new UIBuildingTimerPanel();
               this.mc_jobPanel.jobTitle = this._lang.getString("bld_control_training");
               UIBuildingTimerPanel(this.mc_jobPanel).message = this._reassignSurvivor.fullName;
               UIBuildingTimerPanel(this.mc_jobPanel).time = this._reassignTimer.getTimeRemaining();
               addChildAt(this.mc_jobPanel,0);
            }
         }
         else if(this._building.type == "resource-fuel")
         {
         }
         if(this._building.assignable && !this._building.dead && this._building.repairTimer == null && this._building.upgradeTimer == null)
         {
            this.ui_assignment.building = this._building;
         }
         if(this._building.repairTimer != null)
         {
            this._speedUpTarget = this._building;
            this._building.repairTimer.cancelled.addOnce(this.onTimerCancelledOrCompleted);
            _loc13_ = this._building.productionResource != null;
            this.mc_jobPanel = new UIBuildingTimerPanel();
            this.mc_jobPanel.jobTitle = this._lang.getString(_loc13_ ? "bld_control_restocking" : "bld_control_repairing");
            UIBuildingTimerPanel(this.mc_jobPanel).message = _loc13_ ? "" : this._lang.getString("bld_control_speeduptofinish");
            UIBuildingTimerPanel(this.mc_jobPanel).time = this._building.repairTimer.getTimeRemaining();
            addChildAt(this.mc_jobPanel,0);
            if(this._building.productionResource != "cash")
            {
               this.btn_speedUp.enabled = this._building.repairTimer.getSecondsRemaining() > 5;
               addChild(this.btn_speedUp);
            }
         }
         else if(this._building.upgradeTimer != null && !this._building.dead)
         {
            this._speedUpTarget = this._building;
            this._building.upgradeTimer.completed.addOnce(this.onTimerCancelledOrCompleted);
            this._building.upgradeTimer.cancelled.addOnce(this.onTimerCancelledOrCompleted);
            this.btn_cancel.enabled = !Tutorial.getInstance().active;
            this.btn_speedUp.enabled = this._building.upgradeTimer.getSecondsRemaining() > 5;
            addChild(this.btn_speedUp);
            addChild(this.btn_cancel);
            this.mc_jobPanel = new UIBuildingTimerPanel();
            this.mc_jobPanel.jobTitle = this._lang.getString(this._building.isUnderConstruction() ? "bld_control_constructing" : "bld_control_upgrading");
            UIBuildingTimerPanel(this.mc_jobPanel).message = this._lang.getString("bld_control_speeduptofinish");
            UIBuildingTimerPanel(this.mc_jobPanel).time = this._building.upgradeTimer.getTimeRemaining();
            addChildAt(this.mc_jobPanel,0);
         }
         else if(!this._building.destroyable || !this._building.dead)
         {
            if(!this._building.dead && this._building.productionResource != null)
            {
               addChild(this.btn_collect);
               this.updateCollectButton();
            }
            this.btn_upgrade.enabled = this._building.level < this._building.maxLevel;
            if(_loc5_ && this._building.level < this._building.maxLevel)
            {
               addChild(this.btn_upgrade);
            }
            if(_loc3_)
            {
               this.btn_dismantle.enabled = !Tutorial.getInstance().active;
               addChild(this.btn_dismantle);
            }
            if(_loc4_)
            {
               addChild(this.btn_move);
            }
            if(this._building.craftingCategories.length > 0)
            {
               addChild(this.btn_craft);
            }
         }
         if(this._building.isDoor && !this._building.dead && this._building.repairTimer == null)
         {
            _loc14_ = this._building.buildingEntity as DoorBuildingEntity;
            if(_loc14_ != null)
            {
               this.btn_door.label = this._lang.getString(_loc14_.isOpen ? "bld_control_close" : "bld_control_open");
               addChild(this.btn_door);
            }
         }
         if(this._building.type == "car" && Network.getInstance().playerData.upgrades.get(PlayerUpgrades.DeathMobileUpgrade))
         {
            addChild(this.btn_rename);
         }
         return _loc1_;
      }
      
      private function updateButtonPositions(param1:int) : int
      {
         var _loc3_:PushButton = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._buttons.length)
         {
            _loc3_ = this._buttons[_loc2_];
            if(_loc3_.parent != null)
            {
               _loc3_.y = param1;
               param1 += _loc3_.height + this._padding;
            }
            _loc2_++;
         }
         return param1;
      }
      
      private function update() : void
      {
         if(this._building == null)
         {
            return;
         }
         this.removeElements();
         var _loc1_:int = this._width - 1;
         var _loc2_:int = 0;
         if(this._neighborBuilding)
         {
            _loc2_ = this.showNeighborInterface();
         }
         else if(this._building is JunkBuilding)
         {
            _loc2_ = this.showJunkInterface();
         }
         else
         {
            _loc2_ = this.showBuildingInterface();
         }
         _loc2_ = this.updateButtonPositions(_loc2_);
         if(!this._neighborBuilding)
         {
            if(this.building.comfort != 0)
            {
               _loc2_ += int(this._padding * 0.5);
               this.mc_ratingComfort.value = this._building.comfort;
               this.mc_ratingComfort.x = int((this._width - this.mc_ratingComfort.width) * 0.5);
               this.mc_ratingComfort.y = _loc2_;
               addChild(this.mc_ratingComfort);
               _loc2_ += this.mc_ratingComfort.height + this._padding;
            }
            if(this.building.security != 0)
            {
               _loc2_ += int(this._padding * 0.5);
               this.mc_ratingSecurity.value = this._building.security;
               this.mc_ratingSecurity.x = int((this._width - this.mc_ratingSecurity.width) * 0.5);
               this.mc_ratingSecurity.y = _loc2_;
               addChild(this.mc_ratingSecurity);
               _loc2_ += this.mc_ratingSecurity.height + this._padding;
            }
            if(this.building.assignable)
            {
               if(this._building.numAssignedSurvivors > 0)
               {
                  this.mc_ratingRange.value = Number(Math.ceil(this._building.getAttackRanges().max / 100).toFixed(2));
                  this.mc_ratingRange.x = int((this._width - this.mc_ratingRange.width) * 0.5);
                  this.mc_ratingRange.y = _loc2_;
                  addChild(this.mc_ratingRange);
                  _loc2_ += this.mc_ratingRange.height + this._padding;
               }
               if(!this._building.dead && this._building.repairTimer == null && this._building.upgradeTimer == null)
               {
                  _loc2_ = Math.max(this.ui_assignment.height + 10,_loc2_);
                  this.ui_assignment.x = _loc1_;
                  this.ui_assignment.y = int((_loc2_ - this.ui_assignment.height) * 0.5);
                  addChildAt(this.ui_assignment,getChildIndex(this.mc_background));
                  TweenMax.from(this.ui_assignment,0.25,{
                     "x":2,
                     "ease":Cubic.easeOut
                  });
                  _loc1_ += int(this.ui_assignment.width);
               }
            }
         }
         if(this.mc_jobPanel != null)
         {
            _loc2_ = Math.max(this.mc_jobPanel.height + 10,_loc2_);
            this.mc_jobPanel.x = _loc1_;
            this.mc_jobPanel.y = int((_loc2_ - this.mc_jobPanel.height) * 0.5);
            TweenMax.from(this.mc_jobPanel,0.25,{
               "x":2,
               "ease":Cubic.easeOut
            });
         }
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(5460561);
         this.mc_background.graphics.drawRect(0,0,this._width,_loc2_);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(BaseDialogue.BMP_GRIME);
         this.mc_background.graphics.drawRect(0,0,this._width,_loc2_);
         this.mc_background.graphics.endFill();
         this._height = _loc2_;
      }
      
      private function updateCollectButton() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         if(this._building.productionResource == GameResources.CASH)
         {
            _loc1_ = Number.POSITIVE_INFINITY;
            _loc2_ = Math.floor(this._building.resourceValue);
            this.btn_collect.label = this._lang.getString("bld_control_collect",_loc2_);
            this.btn_collect.enabled = this._building.resourceValue >= 1;
         }
         else
         {
            _loc1_ = int(Network.getInstance().playerData.compound.resources.getAvailableStorageCapacity(this._building.productionResource));
            _loc2_ = _loc1_ == 0 ? 0 : int(Math.min(_loc1_,Math.floor(this._building.resourceValue)));
            this.btn_collect.label = _loc1_ <= 0 ? this._lang.getString("bld_control_collect_full") : this._lang.getString("bld_control_collect",_loc2_);
            this.btn_collect.enabled = _loc1_ > 0 && this._building.resourceValue >= 1 && _loc2_ > 0;
         }
      }
      
      private function updateRecycleProgress() : void
      {
         if(this.mc_productionProgress.parent == null)
         {
            return;
         }
         var _loc1_:BatchRecycleJob = Network.getInstance().playerData.batchRecycleJobs.getJob(0);
         if(_loc1_ == null || _loc1_.timer == null)
         {
            return;
         }
         this.mc_productionProgress.value = _loc1_.timer.getProgress();
         this.txt_resource.text = DateTimeUtils.secondsToString(_loc1_.timer.getSecondsRemaining());
         this.txt_resource.x = int((this._width - this.txt_resource.width) * 0.5);
      }
      
      private function updateResourceProgress() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc1_:String = "";
         this.mc_productionProgress.value = this._building.resourceValue / this._building.resourceCapacity;
         if(this._building.productionResource != null)
         {
            if(this._building.upgradeTimer != null)
            {
               _loc1_ = this._lang.getString("bld_control_production_upgrading");
            }
            else if(this._building.repairTimer != null)
            {
               _loc1_ = this._lang.getString("bld_control_production_restocking");
            }
            else if(this._building.dead)
            {
               _loc1_ = this._lang.getString("bld_control_production_empty");
            }
            else
            {
               _loc2_ = Building.getResourceCapacity(this._building) / (Building.getProductionRate(this._building) / 60 / 60);
               _loc3_ = Math.round(_loc2_ * (1 - this.mc_productionProgress.value));
               if(_loc3_ <= 0)
               {
                  _loc1_ = this._lang.getString("bld_control_production_full");
               }
               else
               {
                  _loc1_ = DateTimeUtils.secondsToString(_loc3_,true,true);
               }
            }
         }
         else if(this._building.storageResource != null)
         {
            _loc1_ = Math.floor(this._building.resourceValue) + " / " + Building.getResourceCapacity(this._building);
         }
         this.txt_resource.text = _loc1_;
         this.txt_resource.x = int((this._width - this.txt_resource.width) * 0.5);
      }
      
      private function calculate3DPosition() : void
      {
         if(this._building == null)
         {
            return;
         }
         var _loc1_:BuildingEntity = this._building.buildingEntity;
         if(_loc1_ == null || _loc1_.scene == null || _loc1_.asset == null)
         {
            return;
         }
         var _loc2_:BoundBox = new BoundBox();
         BoundingBoxUtils.transformBounds(_loc1_.asset,_loc1_.asset.matrix,_loc2_);
         var _loc3_:Number = _loc2_.maxX - _loc2_.minX;
         var _loc4_:Number = _loc2_.maxY - _loc2_.minY;
         var _loc5_:Number = _loc2_.maxZ - _loc2_.minZ;
         this._targetPos.x = _loc1_.transform.position.x + _loc2_.minX + _loc3_ * 0.5;
         this._targetPos.y = _loc1_.transform.position.y + _loc2_.minY + _loc4_ * 0.5;
         this._targetPos.z = _loc1_.transform.position.z + _loc2_.minZ + _loc5_ * 0.5;
      }
      
      private function showDismantleDialogue() : void
      {
         var boughtMsg:MessageBox = null;
         if(this._building.purchaseOnly)
         {
            boughtMsg = new MessageBox(this._lang.getString("dismantle_purchaseonly_msg",this._building.getName()),null,true);
            boughtMsg.addTitle(this._lang.getString("dismantle_purchaseonly_title"));
            boughtMsg.addButton(this._lang.getString("dismantle_purchaseonly_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               new RecycleDialogue(_building).open();
            });
            boughtMsg.addButton(this._lang.getString("dismantle_purchaseonly_cancel"));
            boughtMsg.open();
         }
         else
         {
            new RecycleDialogue(this._building).open();
         }
      }
      
      private function showRepairNowDialogue() : void
      {
         var cost:int = int(Building.getBuildingRepairFuelCost(this._building.type,this._building.level));
         var msg:MessageBox = new MessageBox(this._lang.getString("construct_repair_msg",this._building.getName(),cost),null,true);
         msg.addTitle(this._lang.getString("construct_repair_title",this._building.getName()),BaseDialogue.TITLE_COLOR_BUY);
         msg.addButton(this._lang.getString("construct_repair_cancel"));
         msg.addButton(this._lang.getString("construct_repair_ok"),true,{
            "buttonClass":PurchasePushButton,
            "cost":cost,
            "width":160
         }).clicked.addOnce(function(param1:MouseEvent):void
         {
            _building.repair(true);
         });
         msg.open();
      }
      
      private function showUpgradeDialogue() : void
      {
         var _loc1_:ConstructionUpgradeDialogue = null;
         if(this._building.type == "car")
         {
            DialogueController.getInstance().openDeathMobileUpgradeScreen();
         }
         else
         {
            _loc1_ = new ConstructionUpgradeDialogue(this._building);
            _loc1_.open();
         }
      }
      
      private function showRenameDialogue() : void
      {
         if(this._building.type != "car")
         {
            return;
         }
         var _loc1_:RenameCarDialogue = new RenameCarDialogue(this._building);
         _loc1_.open();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onStageKeyRelease,false,0,true);
         Network.getInstance().playerData.stateUpdated.add(this.onStateUpdated);
         this.onEnterFrame(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.focus = stage;
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onStageKeyRelease);
         Network.getInstance().playerData.stateUpdated.remove(this.onStateUpdated);
      }
      
      private function onStageMouseDown(param1:MouseEvent) : void
      {
         if(contains(param1.target as DisplayObject))
         {
            param1.stopPropagation();
            return;
         }
         this.hide();
      }
      
      private function onStageKeyRelease(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            this.hide();
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc4_:Task = null;
         var _loc5_:Number = NaN;
         var _loc6_:BatchRecycleJob = null;
         var _loc7_:ResearchTask = null;
         if(this._building == null)
         {
            return;
         }
         var _loc2_:BuildingEntity = this._building.buildingEntity;
         if(_loc2_ == null || _loc2_.scene == null || _loc2_.asset == null)
         {
            return;
         }
         var _loc3_:Point = _loc2_.scene.getScreenPosition(this._targetPos.x,this._targetPos.y,this._targetPos.z);
         x = int(_loc3_.x + (this.building.assignable ? 70 : 0));
         y = int(_loc3_.y - this.height * 0.5);
         if(this._building.productionResource != null || this._building.storageResource != null)
         {
            this.updateResourceProgress();
            if(this._building.productionResource != null)
            {
               this.updateCollectButton();
            }
         }
         if(this._building.repairTimer != null)
         {
            UIBuildingTimerPanel(this.mc_jobPanel).time = this._building.repairTimer.getTimeRemaining();
            this.btn_speedUp.enabled = this._building.repairTimer.getSecondsRemaining() > 5;
         }
         else if(!this._building.dead)
         {
            if(this._building.upgradeTimer != null)
            {
               UIBuildingTimerPanel(this.mc_jobPanel).time = this._building.upgradeTimer.getTimeRemaining();
               this.btn_speedUp.enabled = this._building.upgradeTimer.getSecondsRemaining() > 5;
            }
            else if(this._building.tasks.length > 0)
            {
               _loc4_ = this._building.tasks[0];
               if(_loc4_.survivors.length == 0)
               {
                  UIBuildingTimerPanel(this.mc_jobPanel).time = this._lang.getString("bld_onhold").toUpperCase();
               }
               else
               {
                  _loc5_ = (_loc4_.length - _loc4_.time) / _loc4_.survivors.length;
                  UIBuildingTimerPanel(this.mc_jobPanel).time = DateTimeUtils.secondsToString(_loc5_,true,true);
               }
               this.btn_speedUp.enabled = _loc4_.getSecondsRemaining() > 5;
            }
            else if(this._building.type == "recycler")
            {
               _loc6_ = Network.getInstance().playerData.batchRecycleJobs.getJob(0);
               if(_loc6_ != null && _loc6_.timer != null)
               {
                  UIBuildingTimerPanel(this.mc_jobPanel).time = _loc6_.timer.getTimeRemaining();
                  this.btn_speedUp.enabled = _loc6_.timer.getSecondsRemaining() > 5;
               }
            }
            else if(this._building.type == "bench-research")
            {
               _loc7_ = Network.getInstance().playerData.researchState.currentTask;
               if(_loc7_ != null && !_loc7_.isCompleted)
               {
                  UIBuildingTimerPanel(this.mc_jobPanel).time = _loc7_.timeReamining;
               }
            }
            else if(this._building.type == "trainingCenter")
            {
               if(this._reassignTimer != null)
               {
                  if(this._reassignTimer.hasEnded())
                  {
                     this._reassignSurvivor = null;
                     this._reassignTimer = null;
                  }
                  else
                  {
                     UIBuildingTimerPanel(this.mc_jobPanel).message = this._reassignSurvivor.fullName;
                     UIBuildingTimerPanel(this.mc_jobPanel).time = this._reassignTimer.getTimeRemaining();
                  }
               }
            }
         }
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         var junkBld:JunkBuilding = null;
         var dlgSpeedUp:SpeedUpDialogue = null;
         var dlgCraft:CraftingDialogue = null;
         var door:DoorBuildingEntity = null;
         var dlgJunkContents:JunkItemsDialogue = null;
         var recycleJob:BatchRecycleJob = null;
         var dlgRecycleContents:RecycleItemsDialogue = null;
         var dlgJunkStart:JunkItemsDialogue = null;
         var e:MouseEvent = param1;
         var btn:PushButton = e.currentTarget as PushButton;
         junkBld = this._building as JunkBuilding;
         switch(btn)
         {
            case this.btn_move:
               this.moveClicked.dispatch(this._building);
               break;
            case this.btn_dismantle:
               if(!this._building.recyclable)
               {
                  break;
               }
               this.showDismantleDialogue();
               break;
            case this.btn_collect:
               Network.getInstance().playerData.compound.collectResources(this._building);
               break;
            case this.btn_repair:
            case this.btn_restock:
               this._building.repair();
               break;
            case this.btn_repairNow:
               this.showRepairNowDialogue();
               break;
            case this.btn_upgrade:
               this.showUpgradeDialogue();
               break;
            case this.btn_speedUp:
               dlgSpeedUp = new SpeedUpDialogue(this._speedUpTarget);
               dlgSpeedUp.open();
               break;
            case this.btn_cancel:
               this._building.cancelUpgrade();
               break;
            case this.btn_contents:
               if(junkBld != null && junkBld.tasks.length > 0)
               {
                  dlgJunkContents = new JunkItemsDialogue(junkBld.tasks[0].items,junkBld.tasks[0].getXP(),false,true);
                  dlgJunkContents.open();
                  break;
               }
               if(this._building.type == "recycler")
               {
                  recycleJob = Network.getInstance().playerData.batchRecycleJobs.getJob(0);
                  if(recycleJob != null)
                  {
                     dlgRecycleContents = new RecycleItemsDialogue(recycleJob);
                     dlgRecycleContents.open();
                  }
               }
               break;
            case this.btn_startRecycle:
               DialogueController.getInstance().openBatchRecycle();
               break;
            case this.btn_startDispose:
               DialogueController.getInstance().openBatchDispose();
               break;
            case this.btn_research:
               DialogueController.getInstance().openResearch();
               break;
            case this.btn_taskControl:
               if(btn.data == "remove")
               {
                  if(this._building.tasks.length > 0)
                  {
                     this.removeClicked.dispatch(this._building);
                     break;
                  }
                  dlgJunkStart = new JunkItemsDialogue(junkBld.items,junkBld.xp,false);
                  dlgJunkStart.started.addOnce(function():void
                  {
                     removeClicked.dispatch(junkBld);
                  });
                  dlgJunkStart.open();
                  break;
               }
               if(btn.data == "pause")
               {
                  this.pauseTaskClicked.dispatch(this._building.tasks[0]);
               }
               break;
            case this.btn_help:
               this.helpClicked.dispatch(this._building);
               break;
            case this.btn_craft:
               dlgCraft = new CraftingDialogue(this._building.craftingCategories[0]);
               dlgCraft.open();
               break;
            case this.btn_door:
               door = this._building.buildingEntity as DoorBuildingEntity;
               if(door != null)
               {
                  door.toggleOpen();
                  this.btn_door.label = this._lang.getString(door.isOpen ? "bld_control_close" : "bld_control_open");
               }
               break;
            case this.btn_rename:
               this.showRenameDialogue();
         }
         this.hide();
      }
      
      private function onTimerCancelledOrCompleted(param1:TimerData) : void
      {
         this.update();
      }
      
      private function onTaskCompleted(param1:Task) : void
      {
         if(param1.type == TaskType.JUNK_REMOVAL)
         {
            this.hide();
            return;
         }
         this.update();
      }
      
      private function onMouseOverAssignmentSlot(param1:int) : void
      {
         if(!this._building.assignable)
         {
            return;
         }
         this._building.buildingEntity.showAssignPosition(param1);
      }
      
      private function onMouseOutAssignmentSlot(param1:int) : void
      {
         if(!this._building.assignable)
         {
            return;
         }
         this._building.buildingEntity.showAssignPosition();
      }
      
      private function onStateUpdated() : void
      {
         var _loc1_:PushButton = null;
         if(this._building.dead && this._building.repairTimer == null)
         {
            _loc1_ = this._building.productionResource != null ? this.btn_restock : this.btn_repair;
            _loc1_.enabled = Network.getInstance().playerData.canRepairBuilding(this._building.type,this._building.level);
         }
      }
      
      private function onDialogueOpened(param1:GenericEvent, param2:Dialogue) : void
      {
         if(param2.modal)
         {
            visible = false;
         }
      }
      
      private function onDialogueClosed(param1:GenericEvent, param2:Dialogue) : void
      {
         if(DialogueManager.getInstance().numModalDialoguesOpen <= 0)
         {
            visible = true;
         }
      }
      
      public function get building() : Building
      {
         return this._building;
      }
      
      public function set building(param1:Building) : void
      {
         this._building = param1;
         if(this._building == null)
         {
            this.hide();
         }
         else
         {
            this.update();
            this.calculate3DPosition();
            this.onEnterFrame(null);
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

import com.deadreckoned.threshold.display.Color;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;

class ProductionProgress extends Sprite
{
   
   private var _color:uint = 4894528;
   
   private var _width:int;
   
   private var _height:int = 14;
   
   private var _value:Number = 0;
   
   private var mc_bar:Shape;
   
   public function ProductionProgress(param1:int)
   {
      super();
      this._width = param1;
      graphics.beginFill(2631204);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      filters = [new GlowFilter(7039851,1,3,3,3,2)];
      this.mc_bar = new Shape();
      this.mc_bar.x = this.mc_bar.y = 2;
      this.mc_bar.scaleX = this._value;
      this.draw();
      addChild(this.mc_bar);
   }
   
   private function draw() : void
   {
      var _loc1_:Color = new Color(this._color);
      _loc1_.adjustBrightness(0.25);
      _loc1_.s *= 0.75;
      var _loc2_:Matrix = new Matrix();
      _loc2_.createGradientBox(this._width,this._height,Math.PI * 0.5);
      this.mc_bar.graphics.clear();
      this.mc_bar.graphics.beginGradientFill("linear",[this._color,_loc1_.RGB],[1,1],[0,255],_loc2_);
      this.mc_bar.graphics.drawRect(0,0,this._width - 4,this._height - 4);
      this.mc_bar.graphics.endFill();
   }
   
   public function get color() : uint
   {
      return this._color;
   }
   
   public function set color(param1:uint) : void
   {
      this._color = param1;
      this.draw();
   }
   
   public function get value() : Number
   {
      return this._value;
   }
   
   public function set value(param1:Number) : void
   {
      if(this._value == param1)
      {
         return;
      }
      if(param1 < 0)
      {
         param1 = 0;
      }
      else if(param1 > 1)
      {
         param1 = 1;
      }
      this._value = param1;
      this.mc_bar.scaleX = this._value;
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
   }
   
   override public function get height() : Number
   {
      return this._height;
   }
   
   override public function set height(param1:Number) : void
   {
   }
}

class RatingDisplay extends Sprite
{
   
   private var _label:String;
   
   private var _value:int;
   
   private var bmp_icon:Bitmap;
   
   private var txt_label:TextField;
   
   public function RatingDisplay(param1:BitmapData, param2:String)
   {
      super();
      this._label = param2;
      this.bmp_icon = new Bitmap(param1);
      this.bmp_icon.filters = [Effects.ICON_SHADOW];
      addChild(this.bmp_icon);
      this.txt_label = new BodyTextField({
         "color":14211288,
         "size":11,
         "bold":true
      });
      this.txt_label.filters = [Effects.TEXT_SHADOW];
      this.txt_label.text = this._label.toUpperCase();
      this.txt_label.y = int(this.bmp_icon.y + (this.bmp_icon.height - this.txt_label.height) * 0.5);
      this.txt_label.x = int(this.bmp_icon.x + this.bmp_icon.width + 2);
      addChild(this.txt_label);
   }
   
   public function get value() : int
   {
      return this._value;
   }
   
   public function set value(param1:int) : void
   {
      this._value = param1;
      this.txt_label.text = this._value + " " + this._label.toUpperCase();
      this.txt_label.x = int(this.bmp_icon.x + this.bmp_icon.width + 2);
   }
}
