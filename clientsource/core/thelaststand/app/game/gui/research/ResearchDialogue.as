package thelaststand.app.game.gui.research
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Settings;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.research.ResearchState;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.tab.TabBar;
   import thelaststand.app.game.gui.tab.TabBarButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class ResearchDialogue extends BaseDialogue
   {
      
      private static var selectedCategory:String;
      
      private static var selectedGroup:String;
      
      private var _selectedLevel:int;
      
      private var mc_container:Sprite;
      
      private var btn_start:PurchasePushButton;
      
      private var ui_taskProgressBar:UIResearchProgressBar;
      
      private var ui_taskList:UIResearchCategoryList;
      
      private var ui_completedList:UIResearchCompletedList;
      
      private var ui_requirementsPanel:UIResearchRequirementsPanel;
      
      private var ui_completedPanel:UIResearchRequirementsPanel;
      
      private var ui_tabStrip:TabBar;
      
      private var ui_tabTasks:TabBarButton;
      
      private var ui_tabCompleted:TabBarButton;
      
      public function ResearchDialogue()
      {
         var _loc2_:Array = null;
         this.mc_container = new Sprite();
         super("research",this.mc_container,true,true);
         _autoSize = false;
         _width = 760;
         _height = 460;
         addTitle(Language.getInstance().getString("research_title"),BaseDialogue.TITLE_COLOR_GREY,-1,new BmpIconResearchTitle());
         this.ui_taskProgressBar = new UIResearchProgressBar();
         this.ui_taskProgressBar.width = int(_width - _padding * 2);
         this.ui_taskProgressBar.height = 35;
         this.ui_taskProgressBar.x = 0;
         this.ui_taskProgressBar.y = 5;
         this.ui_taskProgressBar.mouseChildren = false;
         this.ui_taskProgressBar.addEventListener(MouseEvent.CLICK,this.onClickResearchBar,false,0,true);
         this.mc_container.addChild(this.ui_taskProgressBar);
         this.ui_requirementsPanel = new UIResearchRequirementsPanel();
         this.ui_requirementsPanel.showRequirements = true;
         this.ui_requirementsPanel.width = 266;
         this.ui_requirementsPanel.x = int(_width - this.ui_requirementsPanel.width - _padding * 2);
         this.ui_taskList = new UIResearchCategoryList();
         this.ui_taskList.x = 0;
         this.ui_taskList.y = int(this.ui_taskProgressBar.y + this.ui_taskProgressBar.height + 28);
         this.ui_taskList.height = int(_height - this.ui_taskList.y - _padding * 2 - 7);
         this.ui_taskList.width = int(this.ui_requirementsPanel.x - 4);
         this.ui_taskList.selectionChanged.add(this.onSelectedResearchTaskChanged);
         this.ui_taskList.visible = true;
         this.mc_container.addChild(this.ui_taskList);
         this.ui_completedList = new UIResearchCompletedList();
         this.ui_completedList.x = int(this.ui_taskList.x);
         this.ui_completedList.y = int(this.ui_taskList.y);
         this.ui_completedList.height = int(this.ui_taskList.height);
         this.ui_completedList.width = int(this.ui_taskList.width);
         this.ui_completedList.selectionChanged.add(this.onSelectedResearchCompletedChanged);
         this.ui_completedList.visible = false;
         this.mc_container.addChild(this.ui_completedList);
         this.ui_requirementsPanel.y = int(this.ui_taskList.y);
         this.ui_requirementsPanel.height = int(_height - this.ui_requirementsPanel.y - _padding * 2 - 48);
         this.mc_container.addChild(this.ui_requirementsPanel);
         this.ui_completedPanel = new UIResearchRequirementsPanel();
         this.ui_completedPanel.x = int(this.ui_requirementsPanel.x);
         this.ui_completedPanel.y = int(this.ui_requirementsPanel.y);
         this.ui_completedPanel.width = int(this.ui_requirementsPanel.width);
         this.ui_completedPanel.height = int(this.ui_completedList.height);
         this.ui_completedPanel.showRequirements = false;
         this.ui_completedPanel.visible = false;
         this.mc_container.addChild(this.ui_completedPanel);
         this.ui_tabStrip = new TabBar();
         this.ui_tabStrip.x = this.ui_taskList.x + 2;
         this.ui_tabStrip.y = this.ui_taskList.y - (this.ui_tabStrip.height - 1);
         this.ui_tabStrip.onChange.add(this.onTabBarChange);
         this.mc_container.addChild(this.ui_tabStrip);
         this.ui_tabTasks = new TabBarButton("tasks",Language.getInstance().getString("research_tab_tasks"));
         this.ui_tabCompleted = new TabBarButton("completed",Language.getInstance().getString("research_tab_completed"));
         this.ui_tabStrip.addButton(this.ui_tabTasks);
         this.ui_tabStrip.addButton(this.ui_tabCompleted);
         this.btn_start = new PurchasePushButton(Language.getInstance().getString("research_start"),0,true);
         this.btn_start.enabled = false;
         this.btn_start.width = 170;
         this.btn_start.x = int(this.ui_requirementsPanel.x + (this.ui_requirementsPanel.width - this.btn_start.width) * 0.5);
         this.btn_start.y = int(_height - this.btn_start.height - _padding * 2 - 10);
         this.btn_start.clicked.add(this.onClickStartResearch);
         this.mc_container.addChild(this.btn_start);
         sprite.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         sprite.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         var _loc1_:String = Settings.getInstance().getData("research_selected",null);
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_.split(":");
            if(_loc2_.length >= 2)
            {
               selectedCategory = _loc2_[0];
               selectedGroup = _loc2_[1];
            }
         }
         this.ui_tabStrip.selectedIndex = 0;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_taskList.dispose();
         this.ui_completedList.dispose();
         this.ui_taskProgressBar.dispose();
         this.ui_requirementsPanel.dispose();
         this.ui_completedPanel.dispose();
         this.btn_start.dispose();
      }
      
      public function select(param1:String, param2:String) : void
      {
         if(param1 == null || param2 == null)
         {
            this.ui_taskList.selectFirst();
         }
         else
         {
            this.ui_taskList.select(param1,param2);
         }
      }
      
      public function invalidate() : void
      {
         var _loc1_:ResearchTask = Network.getInstance().playerData.researchState.currentTask;
         this.ui_taskProgressBar.researchTask = _loc1_;
         this.ui_taskList.invalidate();
         this.ui_completedList.invalidate();
         this.ui_completedPanel.invalidate();
         this.ui_tabCompleted.enabled = Network.getInstance().playerData.researchState.getCompletedTaskCount() > 0;
         if(_loc1_ != null)
         {
            this.ui_requirementsPanel.setResearch(_loc1_.category,_loc1_.group,_loc1_.level);
         }
         else
         {
            this.ui_requirementsPanel.invalidate();
         }
         this.updateStartButtonState();
      }
      
      private function updateStartButtonState() : void
      {
         var _loc1_:Building = Network.getInstance().playerData.compound.buildings.getFirstBuildingOfType("bench-research");
         if(_loc1_ == null || _loc1_.isUnderConstruction() || _loc1_.upgradeTimer != null)
         {
            this.btn_start.enabled = false;
            this.btn_start.cost = 0;
            return;
         }
         var _loc2_:ResearchState = Network.getInstance().playerData.researchState;
         if(_loc2_.currentTask != null && !_loc2_.currentTask.isCompleted)
         {
            this.btn_start.enabled = false;
            this.btn_start.cost = 0;
            return;
         }
         var _loc3_:int = ResearchSystem.getMaxLevel(selectedCategory,selectedGroup);
         var _loc4_:int = _loc2_.getLevel(selectedCategory,selectedGroup);
         if(_loc4_ >= _loc3_)
         {
            this.btn_start.enabled = false;
            this.btn_start.cost = 0;
            return;
         }
         var _loc5_:XML = ResearchSystem.getCategoryGroupLevelXML(selectedCategory,selectedGroup,this._selectedLevel);
         if(_loc5_ == null)
         {
            this.btn_start.enabled = false;
            this.btn_start.cost = 0;
            return;
         }
         var _loc6_:int = ResearchSystem.calculateFuelCost(selectedCategory,selectedGroup,this._selectedLevel);
         this.btn_start.enabled = Network.getInstance().playerData.meetsRequirements(_loc5_.req.children());
         this.btn_start.cost = _loc6_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.invalidate();
         this.select(selectedCategory,selectedGroup);
         this.ui_completedList.selectFirst();
         var _loc2_:ResearchState = Network.getInstance().playerData.researchState;
         _loc2_.researchStarted.add(this.onResearchStarted);
         _loc2_.researchCompleted.add(this.onResearchCompleted);
         var _loc3_:PlayerData = Network.getInstance().playerData;
         _loc3_.compound.resources.resourceChanged.add(this.onResourceChanged);
         _loc3_.inventory.itemAdded.add(this.onInventoryItemChanged);
         _loc3_.inventory.itemRemoved.add(this.onInventoryItemChanged);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         var _loc2_:ResearchState = Network.getInstance().playerData.researchState;
         _loc2_.researchStarted.remove(this.onResearchStarted);
         _loc2_.researchCompleted.remove(this.onResearchCompleted);
         var _loc3_:PlayerData = Network.getInstance().playerData;
         _loc3_.compound.resources.resourceChanged.remove(this.onResourceChanged);
         _loc3_.inventory.itemAdded.remove(this.onInventoryItemChanged);
         _loc3_.inventory.itemRemoved.remove(this.onInventoryItemChanged);
      }
      
      private function onSelectedResearchTaskChanged(param1:String, param2:String, param3:int) : void
      {
         var category:String = param1;
         var group:String = param2;
         var level:int = param3;
         selectedCategory = category;
         selectedGroup = group;
         this._selectedLevel = level;
         this.ui_requirementsPanel.setResearch(category,group,level);
         this.updateStartButtonState();
         setTimeout(function():void
         {
            Settings.getInstance().setData("research_selected",category + ":" + group,true);
         },1000);
      }
      
      private function onSelectedResearchCompletedChanged(param1:String, param2:String, param3:int) : void
      {
         this.ui_completedPanel.setResearch(param1,param2,param3);
      }
      
      private function onResearchStarted(param1:ResearchTask) : void
      {
         this.invalidate();
         Audio.sound.play("sound/interface/research-start.mp3");
      }
      
      private function onResearchCompleted(param1:ResearchTask) : void
      {
         this.invalidate();
      }
      
      private function onClickStartResearch(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(selectedCategory == null || selectedGroup == null)
         {
            return;
         }
         this.btn_start.enabled = false;
         ResearchSystem.getInstance().startResearch(selectedCategory,selectedGroup,function(param1:Boolean, param2:ResearchTask):void
         {
            invalidate();
         });
      }
      
      private function onClickResearchBar(param1:MouseEvent) : void
      {
         var _loc2_:ResearchTask = Network.getInstance().playerData.researchState.currentTask;
         if(_loc2_ != null)
         {
            this.select(_loc2_.category,_loc2_.group);
            Audio.sound.play("sound/interface/int-click.mp3");
         }
      }
      
      private function onTabBarChange(param1:String) : void
      {
         switch(param1)
         {
            case "tasks":
               this.ui_taskList.visible = true;
               this.ui_completedList.visible = false;
               this.btn_start.visible = true;
               this.ui_requirementsPanel.visible = true;
               this.ui_completedPanel.visible = false;
               break;
            case "completed":
               this.ui_taskList.visible = false;
               this.ui_completedList.visible = true;
               this.btn_start.visible = false;
               this.ui_requirementsPanel.visible = false;
               this.ui_completedPanel.visible = true;
         }
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         this.updateStartButtonState();
      }
      
      private function onInventoryItemChanged(param1:Item) : void
      {
         this.updateStartButtonState();
      }
   }
}

