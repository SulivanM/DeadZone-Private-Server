package thelaststand.app.game.logic
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.BatchDisposeDialogue;
   import thelaststand.app.game.gui.dialogues.BatchRecycleDialogue;
   import thelaststand.app.game.gui.dialogues.ConstructionDialogue;
   import thelaststand.app.game.gui.dialogues.HelpPage;
   import thelaststand.app.game.gui.dialogues.InjuriesDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryFullDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryUpgradeDialogue;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.game.gui.dialogues.TutorialHelpDialogue;
   import thelaststand.app.game.gui.dialogues.UpgradeCarDialogue;
   import thelaststand.app.game.gui.research.ResearchDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class DialogueController
   {
      
      private static var _instance:DialogueController;
      
      private var _network:Network;
      
      private var _payments:PaymentSystem;
      
      private var _lang:Language;
      
      private var _dlgManager:DialogueManager;
      
      public function DialogueController(param1:DialogueControllerSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("DialogueController is a Singleton and cannot be directly instantiated. Use DialogueController.getInstance().");
         }
         this._network = Network.getInstance();
         this._payments = PaymentSystem.getInstance();
         this._lang = Language.getInstance();
         this._dlgManager = DialogueManager.getInstance();
      }
      
      public static function getInstance() : DialogueController
      {
         if(!_instance)
         {
            _instance = new DialogueController(new DialogueControllerSingletonEnforcer());
         }
         return _instance;
      }
      
      public function openLoseProtectionWarning(param1:Function = null) : void
      {
         var acceptCallback:Function = param1;
         var msg:MessageBox = new MessageBox(this._lang.getString("attack_loseprotection_msg"));
         msg.addTitle(this._lang.getString("attack_loseprotection_title"));
         msg.addImage("images/ui/protection.jpg");
         msg.addButton(this._lang.getString("attack_loseprotection_ok"),true,{"backgroundColor":7545099}).clicked.addOnce(function(param1:MouseEvent):void
         {
            Tracking.trackEvent("Player","AcceptLoseProtection");
            if(acceptCallback != null)
            {
               acceptCallback();
            }
         });
         msg.addButton(this._lang.getString("attack_loseprotection_cancel"));
         msg.open();
      }
      
      public function openDeathMobileUpgradeScreen() : void
      {
         if(DialogueManager.getInstance().getDialogueById("upgrade-car") != null)
         {
            return;
         }
         var _loc1_:UpgradeCarDialogue = new UpgradeCarDialogue();
         _loc1_.open();
      }
      
      public function showGenericRequestError() : void
      {
         var _loc1_:MessageBox = new MessageBox(Language.getInstance().getString("generic_request_error_msg"));
         _loc1_.addTitle(Language.getInstance().getString("generic_request_error_title"));
         _loc1_.addButton(Language.getInstance().getString("generic_request_error_ok"));
         _loc1_.open();
      }
      
      public function showDisabledFeatureError() : void
      {
         var _loc1_:MessageBox = new MessageBox(Language.getInstance().getString("diabledfeature_msg"));
         _loc1_.addTitle(Language.getInstance().getString("diabledfeature_title"));
         _loc1_.addButton(Language.getInstance().getString("diabledfeature_ok"));
         _loc1_.open();
      }
      
      public function showInjuryTutorial() : void
      {
         var _loc1_:TutorialHelpDialogue = new TutorialHelpDialogue(Language.getInstance().getString("injury_tut_title"),new <Sprite>[new HelpPage("images/ui/help-injury.jpg",Language.getInstance().getString("injury_tut_firsthelp_title"),Language.getInstance().getString("injury_tut_firsthelp_msg"))]);
         _loc1_.open();
         Global.showInjuryTutorial = false;
      }
      
      public function showSchematicTutorial() : void
      {
         var _loc1_:TutorialHelpDialogue = new TutorialHelpDialogue(Language.getInstance().getString("schem_tut_title"),new <Sprite>[new HelpPage("images/ui/tutorial-schematics.jpg",Language.getInstance().getString("schem_tut_firstschem_title1"),Language.getInstance().getString("schem_tut_firstschem_msg1")),new HelpPage("images/ui/tutorial-schematics-bench.jpg",Language.getInstance().getString("schem_tut_firstschem_title2"),Language.getInstance().getString("schem_tut_firstschem_msg2")),new HelpPage("images/ui/tutorial-schematics-unlock.jpg",Language.getInstance().getString("schem_tut_firstschem_title3"),Language.getInstance().getString("schem_tut_firstschem_msg3"))]);
         _loc1_.open();
         Global.showSchematicTutorial = false;
      }
      
      public function showEffectBookTutorial() : void
      {
         var _loc1_:TutorialHelpDialogue = new TutorialHelpDialogue(Language.getInstance().getString("effect_tut_title"),new <Sprite>[new HelpPage("images/ui/help-effects-1.jpg",Language.getInstance().getString("effect_tut_firsteffect_title1"),Language.getInstance().getString("effect_tut_firsteffect_msg1")),new HelpPage("images/ui/help-effects-2.jpg",Language.getInstance().getString("effect_tut_firsteffect_title2"),Language.getInstance().getString("effect_tut_firsteffect_msg2"))]);
         _loc1_.open();
         Global.showEffectTutorial = false;
      }
      
      public function showPvPPracticeTutorial() : void
      {
         var dlg:TutorialHelpDialogue = new TutorialHelpDialogue(Language.getInstance().getString("pvppractice_tut_title"),new <Sprite>[new HelpPage("images/ui/help-pvppractice-1.jpg",Language.getInstance().getString("pvppractice_tut_title1"),Language.getInstance().getString("pvppractice_tut_msg1"))]);
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            Network.getInstance().save(null,SaveDataMethod.TUTORIAL_PVP_PRACTICE);
         });
         dlg.open();
      }
      
      public function showInventoryWarning(param1:Function) : void
      {
         var _loc2_:InventoryFullDialogue = null;
         var _loc3_:Inventory = Network.getInstance().playerData.inventory;
         if(_loc3_.isFull)
         {
            if(!Settings.getInstance().session_dontAskInventoryFull)
            {
               _loc2_ = new InventoryFullDialogue(InventoryFullDialogue.SCAVENGE_FULL);
            }
         }
         else if(_loc3_.isNearlyFull)
         {
            if(!Settings.getInstance().session_dontAskInventoryNearCapacity)
            {
               _loc2_ = new InventoryFullDialogue(InventoryFullDialogue.SCAVENGE_NEAR_FULL);
            }
         }
         if(_loc2_ != null)
         {
            _loc2_.ignored.addOnce(param1);
            _loc2_.open();
            return;
         }
         param1();
      }
      
      public function openInventoryUpgrade() : void
      {
         var _loc1_:InventoryUpgradeDialogue = new InventoryUpgradeDialogue();
         _loc1_.open();
      }
      
      public function openResearch(param1:String = null, param2:String = null) : ResearchDialogue
      {
         var _loc3_:ResearchDialogue = new ResearchDialogue();
         _loc3_.open();
         if(param1 != null && param2 != null)
         {
            _loc3_.select(param1,param2);
         }
         return _loc3_;
      }
      
      public function openBatchDispose(param1:String = "all") : BatchDisposeDialogue
      {
         var building:Building;
         var dlg:BatchDisposeDialogue;
         var msg:MessageBox = null;
         var category:String = param1;
         var blds:Vector.<Building> = Network.getInstance().playerData.compound.buildings.getBuildingsOfType("incinerator",false);
         if(blds.length == 0)
         {
            msg = new MessageBox(this._lang.getString("batch_dispose_build_msg"));
            msg.addTitle(this._lang.getString("batch_dispose_build_title"));
            msg.addButton(this._lang.getString("batch_dispose_build_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               new ConstructionDialogue("incinerator").open();
            });
            msg.addButton(this._lang.getString("batch_dispose_build_cancel"));
            msg.addImage(Building.getBuildingXML("incinerator").img.@uri.toString());
            msg.open();
            return null;
         }
         building = blds[0];
         if(building.upgradeTimer != null)
         {
            msg = new MessageBox(this._lang.getString("batch_dispose_upgrading_msg"));
            msg.addTitle(this._lang.getString("batch_dispose_upgrading_title"));
            msg.addButton(this._lang.getString("batch_dispose_upgrading_ok"));
            msg.open();
            return null;
         }
         dlg = new BatchDisposeDialogue(building.resourceCapacity,category);
         dlg.open();
         return dlg;
      }
      
      public function openBatchRecycle(param1:String = "all") : BatchRecycleDialogue
      {
         var building:Building;
         var dlgRecycle:BatchRecycleDialogue;
         var msg:MessageBox = null;
         var category:String = param1;
         var recyclerBlds:Vector.<Building> = Network.getInstance().playerData.compound.buildings.getBuildingsOfType("recycler",false);
         if(recyclerBlds.length == 0)
         {
            msg = new MessageBox(this._lang.getString("batch_recycle_build_msg"));
            msg.addTitle(this._lang.getString("batch_recycle_build_title"));
            msg.addButton(this._lang.getString("batch_recycle_build_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               new ConstructionDialogue("recycler").open();
            });
            msg.addButton(this._lang.getString("batch_recycle_build_cancel"));
            msg.addImage(Building.getBuildingXML("recycler").img.@uri.toString());
            msg.open();
            return null;
         }
         building = recyclerBlds[0];
         if(building.upgradeTimer != null)
         {
            msg = new MessageBox(this._lang.getString("batch_recycle_upgrading_msg"));
            msg.addTitle(this._lang.getString("batch_recycle_upgrading_title"));
            msg.addButton(this._lang.getString("batch_recycle_upgrading_ok"));
            msg.open();
            return null;
         }
         if(Network.getInstance().playerData.batchRecycleJobs.numActiveJobs >= int(Config.constant.BATCH_RECYCLE_MAX_JOBS))
         {
            msg = new MessageBox(this._lang.getString("batch_recycle_toomanyjobs_msg"));
            msg.addTitle(this._lang.getString("batch_recycle_toomanyjobs_title"));
            msg.addButton(this._lang.getString("batch_recycle_toomanyjobs_ok"));
            msg.addButton(this._lang.getString("batch_recycle_toomanyjobs_speedup"),false,{
               "buttonClass":PurchasePushButton,
               "showIcon":false,
               "width":100
            }).clicked.add(function(param1:MouseEvent):void
            {
               var _loc2_:BatchRecycleJob = Network.getInstance().playerData.batchRecycleJobs.getJob(0);
               if(_loc2_ == null)
               {
                  msg.close();
                  return;
               }
               var _loc3_:SpeedUpDialogue = new SpeedUpDialogue(_loc2_);
               _loc3_.speedUpSelected.addOnce(msg.close);
               _loc3_.open();
            });
            msg.open();
            return null;
         }
         dlgRecycle = new BatchRecycleDialogue(building.resourceCapacity,category);
         dlgRecycle.open();
         return dlgRecycle;
      }
      
      public function openHeal(param1:Survivor) : InjuriesDialogue
      {
         var dlg:InjuriesDialogue;
         var dlgAway:MessageBox = null;
         var survivor:Survivor = param1;
         if(survivor == null || survivor.injuries.length == 0)
         {
            return null;
         }
         if(Boolean(survivor.state & SurvivorState.ON_MISSION) || Boolean(survivor.state & SurvivorState.ON_ASSIGNMENT))
         {
            dlgAway = new MessageBox(this._lang.getString("srv_heal_away_msg",survivor.firstName));
            dlgAway.addTitle(this._lang.getString("srv_heal_away_title",survivor.firstName));
            dlgAway.addButton(this._lang.getString("srv_heal_away_ok"));
            if(!(survivor.state & SurvivorState.ON_ASSIGNMENT))
            {
               dlgAway.addButton(this._lang.getString("srv_heal_away_speedup"),true,{
                  "buttonClass":PurchasePushButton,
                  "width":100
               }).clicked.addOnce(function(param1:MouseEvent):void
               {
                  var _loc3_:SpeedUpDialogue = null;
                  var _loc2_:MissionData = _network.playerData.missionList.getMissionById(survivor.missionId);
                  if(_loc2_ != null)
                  {
                     _loc3_ = new SpeedUpDialogue(_loc2_);
                     _loc3_.open();
                  }
               });
            }
            dlgAway.open();
            return null;
         }
         dlg = new InjuriesDialogue(survivor);
         dlg.open();
         return dlg;
      }
   }
}

class DialogueControllerSingletonEnforcer
{
   
   public function DialogueControllerSingletonEnforcer()
   {
      super();
   }
}
