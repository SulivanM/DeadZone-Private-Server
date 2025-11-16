package thelaststand.app.game.gui.compound
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.display.Effects;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.IGUILayer;
   import thelaststand.app.game.gui.UIHUDPanel;
   import thelaststand.app.game.gui.buttons.UIHUDAllianceButton;
   import thelaststand.app.game.gui.buttons.UIHUDBountyOfficeButton;
   import thelaststand.app.game.gui.buttons.UIHUDButton;
   import thelaststand.app.game.gui.buttons.UIHUDCrafting;
   import thelaststand.app.game.gui.buttons.UIHUDInventory;
   import thelaststand.app.game.gui.buttons.UIHUDMapButton;
   import thelaststand.app.game.gui.buttons.UIHUDQuestButton;
   import thelaststand.app.game.gui.buttons.UIHUDStoreButton;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.dialogues.BountyOfficeDialogue;
   import thelaststand.app.game.gui.dialogues.ConstructionDialogue;
   import thelaststand.app.game.gui.dialogues.CraftingDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryDialogue;
   import thelaststand.app.game.gui.dialogues.QuestsDialogue;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.game.gui.dialogues.SurvivorDialogue;
   import thelaststand.app.game.gui.mission.UIMissionTimer;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class CompoundGUILayer extends Sprite implements IGUILayer
   {
      
      private var _gui:GameGUI;
      
      private var _lang:Language;
      
      private var _name:String;
      
      private var _network:Network;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _transitionedOut:Signal;
      
      private var _tutorial:Tutorial;
      
      private var _zombieAttackPreparation:Boolean = false;
      
      private var _zombieAttackTimer:Timer;
      
      private var _hudLocked:Boolean = false;
      
      private var btn_engageZombieAttack:PushButton;
      
      private var btn_research:UIHUDButton;
      
      private var btn_map:UIHUDButton;
      
      private var btn_ctr:UIHUDButton;
      
      private var btn_srv:UIHUDButton;
      
      private var btn_qst:UIHUDButton;
      
      private var btn_bounty:UIHUDButton;
      
      private var btn_alliance:UIHUDButton;
      
      private var btn_cft:UIHUDButton;
      
      private var btn_store:UIHUDButton;
      
      private var btn_inv:UIHUDButton;
      
      private var hud_left:UIHUDPanel;
      
      private var hud_right:UIHUDPanel;
      
      private var ui_notifications:UINotificationArea;
      
      private var ui_attackTimer:UIMissionTimer;
      
      public function CompoundGUILayer()
      {
         super();
         mouseEnabled = false;
         this._lang = Language.getInstance();
         this._network = Network.getInstance();
         this._allianceSystem = AllianceSystem.getInstance();
         this._transitionedOut = new Signal(CompoundGUILayer);
         this.ui_notifications = new UINotificationArea();
         addChild(this.ui_notifications);
         this.ui_attackTimer = new UIMissionTimer();
         this.ui_attackTimer.showWarning = false;
         this.btn_engageZombieAttack = new PushButton(this._lang.getString("zombie_attack_ok"),null,-1,null,7545099);
         this.btn_engageZombieAttack.clicked.add(this.onClickEngageZombieAttack);
         this.btn_engageZombieAttack.showBorder = false;
         this.hud_left = new UIHUDPanel();
         addChild(this.hud_left);
         this.btn_store = this.hud_left.addButton(new UIHUDStoreButton("store"));
         this.btn_store.enabled = !this._network.shutdownMissionsLocked;
         this.btn_store.clicked.add(this.onHUDButtonClicked);
         this.btn_ctr = this.hud_left.addButton(new UIHUDButton("construction",new Bitmap(new BmpIconHUDConstruction())));
         this.btn_ctr.clicked.add(this.onHUDButtonClicked);
         this.btn_inv = this.hud_left.addButton(new UIHUDInventory("inventory"));
         this.btn_inv.clicked.add(this.onHUDButtonClicked);
         this.btn_cft = this.hud_left.addButton(new UIHUDCrafting("crafting"));
         this.btn_cft.clicked.add(this.onHUDButtonClicked);
         this.btn_cft.enabled = false;
         this.btn_research = this.hud_left.addButton(new UIHUDButton("research",new Bitmap(new BmpIconHUDResearch())));
         this.btn_research.enabled = false;
         this.btn_research.clicked.add(this.onHUDButtonClicked);
         this.hud_right = new UIHUDPanel(true);
         addChild(this.hud_right);
         this.btn_alliance = this.hud_right.addButton(new UIHUDAllianceButton("alliance"));
         this.btn_alliance.clicked.add(this.onHUDButtonClicked);
         this.btn_alliance.visible = false;
         this.btn_bounty = this.hud_right.addButton(new UIHUDBountyOfficeButton("bounty"),-5);
         this.btn_bounty.clicked.add(this.onHUDButtonClicked);
         this.btn_bounty.visible = false;
         this.btn_qst = this.hud_right.addButton(new UIHUDQuestButton("quests"));
         this.btn_qst.clicked.add(this.onHUDButtonClicked);
         this.btn_srv = this.hud_right.addButton(new UIHUDButton("survivors",new Bitmap(new BmpIconHUDSurvivors())));
         this.btn_srv.clicked.add(this.onHUDButtonClicked);
         this.btn_map = this.hud_right.addButton(new UIHUDMapButton("worldmap"));
         this.btn_map.clicked.add(this.onHUDButtonClicked);
         this.btn_map.enabled = !this._network.shutdownMissionsLocked;
         var _loc1_:TooltipManager = TooltipManager.getInstance();
         _loc1_.add(this.btn_ctr,this._lang.getString("tooltip.construct"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_inv,this._lang.getString("tooltip.inventory"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_srv,this._lang.getString("tooltip.survivors"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_map,this.getMapTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_store,this.getStoreTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_qst,this._lang.getString("tooltip.quests"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_cft,this.getCraftingTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_research,this.getResearchTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_bounty,this.getBountyTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_alliance,this.getAllianceTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         this._network.playerData.getPlayerSurvivor().levelIncreased.add(this.onPlayerLevelIncreased);
         this._network.playerData.compound.buildings.buildingAdded.add(this.onBuildingAdded);
         this._network.playerData.compound.buildings.buildingRemoved.add(this.onBuildingRemoved);
         this._network.onShutdownMissionsLockChange.add(this.onMissionLockdownChange);
         this._allianceSystem.connectionAttempted.add(this.onAllianceSystemConnecting);
         this._allianceSystem.connectionFailed.add(this.onAllianceSystemConnectionFailed);
         this._allianceSystem.connected.add(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._tutorial = Tutorial.getInstance();
         if(this._tutorial.active)
         {
            this._tutorial.stepChanged.add(this.onTutorialStepChanged);
            this.btn_map.enabled = this._tutorial.step != Tutorial.STEP_OPEN_MAP;
         }
         TimerManager.getInstance().timerCompleted.add(this.onTimerComplete);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.ui_notifications.dispose();
         this.ui_notifications = null;
         this.ui_attackTimer.removeEventListener(Event.ENTER_FRAME,this.onAttackTimerUpdate);
         this.ui_attackTimer.dispose();
         this.ui_attackTimer = null;
         this.btn_engageZombieAttack.dispose();
         this.btn_engageZombieAttack = null;
         this.hud_left.dispose();
         this.hud_left = null;
         this.hud_right.dispose();
         this.hud_right = null;
         this.btn_map = null;
         this.btn_ctr = null;
         this.btn_srv = null;
         this.btn_qst = null;
         this.btn_store = null;
         this.btn_alliance = null;
         this.btn_bounty = null;
         this.btn_inv = null;
         TimerManager.getInstance().timerCompleted.remove(this.onTimerComplete);
         this._network.playerData.compound.buildings.buildingAdded.remove(this.onBuildingAdded);
         this._network.playerData.compound.buildings.buildingRemoved.remove(this.onBuildingRemoved);
         this._network.playerData.getPlayerSurvivor().levelIncreased.remove(this.onPlayerLevelIncreased);
         this._network.onShutdownMissionsLockChange.remove(this.onMissionLockdownChange);
         this._allianceSystem.connectionAttempted.remove(this.onAllianceSystemConnecting);
         this._allianceSystem.connectionFailed.remove(this.onAllianceSystemConnectionFailed);
         this._allianceSystem.connected.remove(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem = null;
         if(this._zombieAttackTimer != null)
         {
            this._zombieAttackTimer.removeEventListener(TimerEvent.TIMER,this.onAttackTimerUpdate);
            this._zombieAttackTimer = null;
         }
         this._gui = null;
         this._lang = null;
         this._network = null;
         this._transitionedOut.removeAll();
         this._transitionedOut = null;
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._tutorial = null;
      }
      
      public function lockHUD() : void
      {
         if(this._hudLocked || Tutorial.getInstance().active)
         {
            return;
         }
         this._hudLocked = true;
         this.hud_left.mouseChildren = false;
         this.hud_right.mouseChildren = false;
         this.hud_left.filters = [Effects.GREYSCALE.filter];
         this.hud_right.filters = [Effects.GREYSCALE.filter];
      }
      
      public function unlockHUD() : void
      {
         if(!this._hudLocked)
         {
            return;
         }
         this._hudLocked = false;
         this.hud_left.mouseChildren = true;
         this.hud_right.mouseChildren = true;
         this.hud_left.filters = [];
         this.hud_right.filters = [];
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         var _loc3_:int = 960;
         var _loc4_:int = int((this._width - _loc3_) * 0.5);
         this.ui_attackTimer.x = int(this._width * 0.5);
         this.ui_attackTimer.y = this._width < 860 ? 36 : 6;
         this.btn_engageZombieAttack.x = int((this._width - this.btn_engageZombieAttack.width) * 0.5);
         this.btn_engageZombieAttack.y = int(this.ui_attackTimer.y + 24);
         this.hud_left.x = Math.max(_loc4_ + 4,4);
         this.hud_left.y = int(this._height - this.hud_left.height - 8);
         this.hud_right.x = int(Math.min(_loc4_ + _loc3_ - 4,this._width - 4) - this.hud_right.width);
         this.hud_right.y = int(this._height - this.hud_right.height - 8);
         this.ui_notifications.x = 8;
         this.ui_notifications.y = this._gui.resouces.y + this._gui.resouces.height - this._gui.header.height + 18;
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         var _loc2_:AllianceDialogue = null;
         mouseChildren = true;
         this.ui_notifications.visible = !this._tutorial.active;
         if(!this._tutorial.active)
         {
            TweenMax.from(this.hud_left,0.25,{
               "delay":param1,
               "y":this._height + 100,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
            Audio.sound.play("sound/interface/int-open.mp3");
            this.hud_left.visible = true;
         }
         else
         {
            this.hud_left.visible = false;
         }
         if(!this._tutorial.active)
         {
            TweenMax.from(this.hud_right,0.25,{
               "delay":param1,
               "y":this._height + 100,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
            if(!Audio.sound.isPlaying("sound/interface/int-open.mp3"))
            {
               Audio.sound.play("sound/interface/int-open.mp3");
            }
            this.hud_right.visible = true;
         }
         else
         {
            this.hud_right.visible = false;
         }
         if(AllianceDialogState.getInstance().allianceDialogReturnType != AllianceDialogState.SHOW_NONE)
         {
            _loc2_ = new AllianceDialogue();
            _loc2_.open();
            AllianceDialogState.getInstance().allianceDialogReturnType = AllianceDialogState.SHOW_NONE;
         }
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         mouseChildren = false;
         var _loc2_:Function = Back.easeIn;
         var _loc3_:Array = [0.75];
         TweenMax.to(this.hud_left,0.25,{
            "delay":param1,
            "y":this._height + 100,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.to(this.hud_right,0.25,{
            "delay":param1,
            "y":this._height + 100,
            "ease":_loc2_,
            "easeParams":_loc3_,
            "onComplete":this.transitionedOut.dispatch,
            "onCompleteParams":[this]
         });
         if(this.ui_attackTimer.parent != null)
         {
            this.ui_attackTimer.parent.removeChild(this.ui_attackTimer);
         }
         if(this.btn_engageZombieAttack.parent != null)
         {
            this.btn_engageZombieAttack.parent.removeChild(this.btn_engageZombieAttack);
         }
         this.ui_attackTimer.removeEventListener(Event.ENTER_FRAME,this.onAttackTimerUpdate);
      }
      
      private function checkCraftingEnabled() : void
      {
         this.btn_cft.enabled = this._network.playerData.compound.buildings.getNumCraftingBuildings() > 0;
         if(this.btn_cft.enabled)
         {
            TweenMax.from(this.btn_cft,2,{
               "glowFilter":{
                  "color":16777215,
                  "blurX":20,
                  "blurY":20,
                  "alpha":1,
                  "strength":2,
                  "quality":1
               },
               "colorTransform":{"exposure":2}
            });
         }
      }
      
      private function checkResearchEnabled() : void
      {
         this.btn_research.enabled = this._network.playerData.compound.buildings.getFirstBuildingOfType("bench-research",false) != null;
         if(this.btn_research.enabled)
         {
            TweenMax.from(this.btn_research,2,{
               "glowFilter":{
                  "color":16777215,
                  "blurX":20,
                  "blurY":20,
                  "alpha":1,
                  "strength":2,
                  "quality":1
               },
               "colorTransform":{"exposure":2}
            });
         }
      }
      
      private function areAlliancesEnabled() : Boolean
      {
         if(this._zombieAttackPreparation)
         {
            return false;
         }
         return this._allianceSystem.canAccessAlliances();
      }
      
      private function getCraftingTooltip() : String
      {
         if(this.btn_cft.enabled)
         {
            return this._lang.getString("tooltip.crafting");
         }
         return this._lang.getString("tooltip.crafting_locked");
      }
      
      private function getResearchTooltip() : String
      {
         if(this.btn_research.enabled)
         {
            return this._lang.getString("tooltip.research");
         }
         return this._lang.getString("tooltip.research_locked");
      }
      
      private function getMapTooltip() : String
      {
         if(this._network.shutdownMissionsLocked)
         {
            return this._lang.getString("tooltip.worldmap_shutdown");
         }
         return this._lang.getString("tooltip.worldmap");
      }
      
      private function getStoreTooltip() : String
      {
         if(this._network.shutdownMissionsLocked)
         {
            return this._lang.getString("tooltip.store_shutdown");
         }
         if(Network.getInstance().data.saleCategories.length > 0)
         {
            return this._lang.getString("tooltip.store_sale");
         }
         return this._lang.getString("tooltip.store");
      }
      
      private function getBountyTooltip() : String
      {
         return this._lang.getString(this._network.playerData.getPlayerSurvivor().level >= int(Config.constant.BOUNTY_MIN_LEVEL) ? "tooltip.bountylist" : "tooltip.bountylistDisabled");
      }
      
      private function getAllianceTooltip() : String
      {
         var _loc1_:String = "tooltip.alliances";
         if(this.btn_alliance.enabled == false)
         {
            if(this._zombieAttackPreparation)
            {
               _loc1_ = "tooltip.alliancesZombieAttackImminent";
            }
            else if(!this._allianceSystem.buildingRequirementsMet)
            {
               _loc1_ = "tooltip.alliancesBuildingRequired";
            }
            else if(this._allianceSystem.isConnecting)
            {
               _loc1_ = "tooltip.alliancesConnecting";
            }
            else
            {
               _loc1_ = "tooltip.alliancesDisabled";
            }
         }
         return this._lang.getString(_loc1_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var _loc2_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         this.btn_cft.enabled = this._network.playerData.compound.buildings.getNumCraftingBuildings() > 0;
         this.btn_research.enabled = this._network.playerData.compound.buildings.getFirstBuildingOfType("bench-research",false) != null;
         this.btn_bounty.visible = _loc2_ >= int(Config.constant.BOUNTY_MIN_LEVEL) || _loc2_ >= int(Config.constant.BOUNTY_ZOMBIE_MIN_LEVEL);
         this.btn_alliance.visible = this._network.playerData.getPlayerSurvivor().level >= int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL);
         this.updateAllianceButtonState();
         this.hud_right.refreshLayout();
         stage.addEventListener(GameEvent.ZOMBIE_ATTACK_PREPARATION,this.onZombieAttackPreparation,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(GameEvent.ZOMBIE_ATTACK_PREPARATION,this.onZombieAttackPreparation);
      }
      
      private function onBuildingAdded(param1:Building) : void
      {
         if(param1.craftingCategories.length > 0 && !this.btn_cft.enabled)
         {
            this.checkCraftingEnabled();
         }
         if(!this.btn_research.enabled)
         {
            this.checkResearchEnabled();
         }
         if(param1.type == "alliance-flag")
         {
            this.updateAllianceButtonState();
         }
      }
      
      private function onBuildingRemoved(param1:Building) : void
      {
         this.btn_cft.enabled = this._network.playerData.compound.buildings.getNumCraftingBuildings() > 0;
         this.btn_research.enabled = this._network.playerData.compound.buildings.getFirstBuildingOfType("bench-research",false) != null;
         this.updateAllianceButtonState();
      }
      
      private function onTimerComplete(param1:TimerData) : void
      {
         var _loc2_:Building = param1.target as Building;
         if(_loc2_ != null)
         {
            if(_loc2_.craftingCategories.length > 0 && !this.btn_cft.enabled)
            {
               this.checkCraftingEnabled();
            }
            if(!this.btn_research.enabled)
            {
               this.checkResearchEnabled();
            }
            if(_loc2_.type == "alliance-flag")
            {
               if(this.areAlliancesEnabled())
               {
                  this.btn_alliance.enabled = true;
                  TweenMax.from(this.btn_alliance,2,{
                     "glowFilter":{
                        "color":16777215,
                        "blurX":20,
                        "blurY":20,
                        "alpha":1,
                        "strength":2,
                        "quality":1
                     },
                     "colorTransform":{"exposure":2}
                  });
               }
            }
         }
      }
      
      private function onMissionLockdownChange(param1:Boolean) : void
      {
         this.btn_map.enabled = !param1 && this._zombieAttackPreparation;
         this.btn_store.enabled = !param1 && this._zombieAttackPreparation;
      }
      
      private function updateAllianceButtonState() : void
      {
         this.btn_alliance.enabled = this._allianceSystem.canAccessAlliances() && this._allianceSystem.isConnecting == false;
      }
      
      private function onAllianceSystemConnecting() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onAllianceSystemConnectionFailed() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onAllianceSystemConnected() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onPlayerLevelIncreased(param1:Survivor, param2:int) : void
      {
         if(this._zombieAttackPreparation)
         {
            return;
         }
         var _loc3_:Boolean = false;
         var _loc4_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         var _loc5_:Boolean = _loc4_ >= int(Config.constant.BOUNTY_MIN_LEVEL) || _loc4_ >= int(Config.constant.BOUNTY_ZOMBIE_MIN_LEVEL);
         if((_loc5_) && !this.btn_bounty.visible)
         {
            this.btn_bounty.visible = _loc5_;
            if(this.btn_bounty.visible)
            {
               TweenMax.from(this.btn_bounty,2,{
                  "glowFilter":{
                     "color":16777215,
                     "blurX":20,
                     "blurY":20,
                     "alpha":1,
                     "strength":2,
                     "quality":1
                  },
                  "colorTransform":{"exposure":2}
               });
               _loc3_ = true;
            }
         }
         if(param2 >= int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL) && !this.btn_alliance.visible)
         {
            this.btn_alliance.visible = this._network.playerData.getPlayerSurvivor().level >= int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL);
            if(this.btn_alliance.visible)
            {
               TweenMax.from(this.btn_alliance,2,{
                  "glowFilter":{
                     "color":16777215,
                     "blurX":20,
                     "blurY":20,
                     "alpha":1,
                     "strength":2,
                     "quality":1
                  },
                  "colorTransform":{"exposure":2}
               });
               this.updateAllianceButtonState();
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            this.hud_right.refreshLayout();
            this.setSize(this._width,this._height);
         }
      }
      
      private function onHUDButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:ConstructionDialogue = null;
         var _loc3_:InventoryDialogue = null;
         var _loc4_:SurvivorDialogue = null;
         var _loc5_:StoreDialogue = null;
         var _loc6_:QuestsDialogue = null;
         var _loc7_:CraftingDialogue = null;
         var _loc8_:BountyOfficeDialogue = null;
         var _loc9_:AllianceDialogue = null;
         if(this._network.isBusy)
         {
            return;
         }
         switch(UIHUDButton(param1.currentTarget).id)
         {
            case "construction":
               _loc2_ = new ConstructionDialogue();
               _loc2_.open();
               break;
            case "inventory":
               _loc3_ = new InventoryDialogue();
               _loc3_.open();
               break;
            case "survivors":
               _loc4_ = new SurvivorDialogue();
               _loc4_.open();
               break;
            case "worldmap":
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.WORLD_MAP));
               break;
            case "store":
               _loc5_ = new StoreDialogue();
               _loc5_.open();
               break;
            case "quests":
               _loc6_ = new QuestsDialogue();
               _loc6_.open();
               break;
            case "crafting":
               _loc7_ = new CraftingDialogue();
               _loc7_.open();
               break;
            case "bounty":
               _loc8_ = new BountyOfficeDialogue();
               _loc8_.open();
               break;
            case "alliance":
               _loc9_ = new AllianceDialogue();
               _loc9_.open();
               break;
            case "research":
               DialogueController.getInstance().openResearch();
         }
      }
      
      private function onZombieAttackPreparation(param1:GameEvent) : void
      {
         this._zombieAttackPreparation = true;
         this.btn_map.enabled = false;
         this.btn_bounty.enabled = false;
         this.btn_alliance.enabled = false;
         if(this._zombieAttackTimer != null)
         {
            this._zombieAttackTimer.removeEventListener(TimerEvent.TIMER,this.onAttackTimerUpdate);
            this._zombieAttackTimer = null;
         }
         this._zombieAttackTimer = Timer(param1.data);
         this._zombieAttackTimer.addEventListener(TimerEvent.TIMER,this.onAttackTimerUpdate,false,0,true);
         this.ui_attackTimer.time = this._zombieAttackTimer.repeatCount;
         addChild(this.ui_attackTimer);
         addChild(this.btn_engageZombieAttack);
      }
      
      private function onAttackTimerUpdate(param1:Event) : void
      {
         if(DialogueManager.getInstance().numModalDialoguesOpen > 0)
         {
            return;
         }
         var _loc2_:int = this._zombieAttackTimer.repeatCount - this._zombieAttackTimer.currentCount;
         this.ui_attackTimer.time = _loc2_;
         if(_loc2_ <= 0)
         {
            if(this.ui_attackTimer.parent != null)
            {
               this.ui_attackTimer.parent.removeChild(this.ui_attackTimer);
            }
            if(this.btn_engageZombieAttack.parent != null)
            {
               this.btn_engageZombieAttack.parent.removeChild(this.btn_engageZombieAttack);
            }
            this._zombieAttackTimer.removeEventListener(TimerEvent.TIMER,this.onAttackTimerUpdate);
         }
      }
      
      private function onClickEngageZombieAttack(param1:MouseEvent) : void
      {
         stage.dispatchEvent(new GameEvent(GameEvent.ZOMBIE_ATTACK_ENGAGE,true));
      }
      
      private function onTutorialStepChanged() : void
      {
         switch(this._tutorial.step)
         {
            case Tutorial.STEP_CONSTRUCTION:
               TweenMax.from(this.hud_left,0.25,{
                  "y":this._height + 100,
                  "ease":Back.easeOut,
                  "easeParams":[0.75]
               });
               Audio.sound.play("sound/interface/int-open.mp3");
               this.hud_left.visible = true;
            case Tutorial.STEP_FOOD_WATER:
            case Tutorial.STEP_BUILD_RESOURCE_STORAGE:
            case Tutorial.STEP_BUILD_PRODUCTION:
            case Tutorial.STEP_SECURITY:
               this._tutorial.addArrow(this.btn_ctr,90,new Point(this.btn_ctr.width * 0.5,-10));
               break;
            case Tutorial.STEP_COMFORT:
               if(DialogueManager.getInstance().numModalDialoguesOpen == 0)
               {
                  this._tutorial.addArrow(this.btn_ctr,90,new Point(this.btn_ctr.width * 0.5,-10));
                  break;
               }
               DialogueManager.getInstance().dialogueClosed.add(function(param1:GenericEvent, param2:Dialogue):void
               {
                  if(DialogueManager.getInstance().numModalDialoguesOpen <= 0)
                  {
                     DialogueManager.getInstance().dialogueClosed.remove(arguments.callee);
                     _tutorial.addArrow(btn_ctr,90,new Point(btn_ctr.width * 0.5,-10));
                  }
               });
               break;
            case Tutorial.STEP_SURVIVOR_ARRIVE:
               TweenMax.from(this.hud_right,0.25,{
                  "y":this._height + 100,
                  "ease":Back.easeOut,
                  "overwrite":true,
                  "easeParams":[0.75]
               });
               Audio.sound.play("sound/interface/int-open.mp3");
               this.hud_right.visible = true;
               this._tutorial.addArrow(this.btn_srv,90,new Point(this.btn_map.width * 0.5,-10));
               break;
            case Tutorial.STEP_OPEN_MAP:
               this.btn_map.enabled = true;
               if(!this.hud_right.visible)
               {
                  TweenMax.from(this.hud_right,0.25,{
                     "y":this._height + 100,
                     "ease":Back.easeOut,
                     "easeParams":[0.75]
                  });
                  Audio.sound.play("sound/interface/int-open.mp3");
                  this.hud_right.visible = true;
               }
               this._tutorial.addArrow(this.btn_map,90,new Point(this.btn_map.width * 0.5,-10));
               break;
            case Tutorial.STEP_END_TUTORIAL:
               this.btn_map.enabled = true;
               this.hud_right.visible = true;
               this.hud_left.visible = true;
               this.ui_notifications.visible = true;
               break;
            default:
               this.btn_map.enabled = false;
         }
         if(this._tutorial.stepNum > this._tutorial.getStepNum(Tutorial.STEP_CONSTRUCTION) && !this.hud_left.visible)
         {
            TweenMax.from(this.hud_left,0.25,{
               "y":this._height + 100,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
            Audio.sound.play("sound/interface/int-open.mp3");
            this.hud_left.visible = true;
         }
         if(this._tutorial.stepNum > this._tutorial.getStepNum(Tutorial.STEP_SURVIVOR_ARRIVE) && !this.hud_right.visible)
         {
            TweenMax.from(this.hud_right,0.25,{
               "y":this._height + 100,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
            Audio.sound.play("sound/interface/int-open.mp3");
            this.hud_right.visible = true;
         }
      }
      
      public function get transitionedOut() : Signal
      {
         return this._transitionedOut;
      }
      
      public function get useFullWindow() : Boolean
      {
         return false;
      }
      
      public function get gui() : GameGUI
      {
         return this._gui;
      }
      
      public function set gui(param1:GameGUI) : void
      {
         this._gui = param1;
      }
   }
}

