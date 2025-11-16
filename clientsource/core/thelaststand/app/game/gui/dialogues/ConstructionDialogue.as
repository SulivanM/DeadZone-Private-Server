package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.construction.UIConstructionInfo;
   import thelaststand.app.game.gui.lists.UIConstructionList;
   import thelaststand.app.game.gui.lists.UIConstructionListItem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class ConstructionDialogue extends BaseDialogue
   {
      
      private static var _selectedCategory:String = "construct";
      
      private static var _selectedId:String = null;
      
      private var _catButtons:Vector.<PushButton>;
      
      private var _lang:Language;
      
      private var _selectedCategoryButton:PushButton;
      
      private var _xml:XML;
      
      private var _tutorial:Tutorial;
      
      private var btn_build:PushButton;
      
      private var btn_buildNow:PurchasePushButton;
      
      private var mc_container:Sprite;
      
      private var ui_info:UIConstructionInfo;
      
      private var ui_itemList:UIConstructionList;
      
      private var ui_pagination:UIPagination;
      
      private const _categories:Array;
      
      public function ConstructionDialogue(param1:String = null)
      {
         var _loc9_:XML = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:PushButton = null;
         this._categories = [{
            "id":"construct",
            "size":0.18
         },{
            "id":"storage",
            "size":0.14
         },{
            "id":"resource",
            "size":0.16
         },{
            "id":"defence",
            "size":0.14
         },{
            "id":"trap",
            "size":0.12
         },{
            "id":"comfort",
            "size":0.14
         },{
            "id":"misc",
            "size":0.12
         }];
         this.mc_container = new Sprite();
         super("construction-dialogue",this.mc_container,true);
         _autoSize = false;
         _width = 720;
         _height = 490;
         this._lang = Language.getInstance();
         this._xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content;
         if(param1 != null)
         {
            _loc9_ = Building.getBuildingXML(param1);
            if(_loc9_ != null)
            {
               _selectedCategory = _loc9_.@type.toString();
               _selectedId = param1;
            }
         }
         this._tutorial = Tutorial.getInstance();
         if(this._tutorial.active)
         {
            switch(this._tutorial.step)
            {
               case Tutorial.STEP_CONSTRUCTION:
                  _selectedCategory = "construct";
                  break;
               case Tutorial.STEP_FOOD_WATER:
               case Tutorial.STEP_BUILD_RESOURCE_STORAGE:
                  _selectedCategory = "storage";
                  break;
               case Tutorial.STEP_BUILD_PRODUCTION:
                  _selectedCategory = "resource";
                  break;
               case Tutorial.STEP_SECURITY:
                  _selectedCategory = "defence";
                  break;
               case Tutorial.STEP_COMFORT:
                  _selectedCategory = "comfort";
            }
         }
         this._catButtons = new Vector.<PushButton>();
         var _loc2_:int = int(this._categories.length);
         var _loc3_:int = 12;
         var _loc4_:int = int(_width - _padding * 2 - 36 - _loc3_ * _loc2_ + _loc3_);
         var _loc5_:int = 0;
         var _loc6_:int = _padding - 4;
         var _loc7_:int = 0;
         while(_loc7_ < _loc2_)
         {
            _loc10_ = this._categories[_loc7_].id as String;
            _loc11_ = int(_loc4_ * this._categories[_loc7_].size);
            _loc12_ = new PushButton(this._lang.getString("bld_types." + _loc10_),null,-1,{"size":14});
            _loc12_.clicked.add(this.onCategoryButtonClicked);
            _loc12_.data = _loc10_;
            _loc12_.x = _loc5_;
            _loc12_.width = _loc11_;
            this.mc_container.addChild(_loc12_);
            if(_loc10_ == _selectedCategory)
            {
               this._selectedCategoryButton = _loc12_;
               this._selectedCategoryButton.selected = true;
            }
            _loc5_ += _loc12_.width + _loc3_;
            this._catButtons.push(_loc12_);
            _loc7_++;
         }
         this.ui_info = new UIConstructionInfo();
         this.ui_info.x = int(_width - this.ui_info.width - _padding - 20);
         this.ui_info.y = int(_loc12_.y + _loc12_.height + 20);
         this.mc_container.addChild(this.ui_info);
         this.btn_buildNow = new PurchasePushButton();
         this.btn_buildNow.clicked.add(this.onBuildClicked);
         this.btn_buildNow.label = this._lang.getString("construct_buildnow");
         this.btn_buildNow.enabled = false;
         this.btn_buildNow.x = int(this.ui_info.x + 10);
         this.btn_buildNow.y = int(this.ui_info.y + this.ui_info.height + 10);
         this.btn_buildNow.width = 150;
         this.mc_container.addChild(this.btn_buildNow);
         this.btn_build = new PushButton(this._lang.getString("construct_build"),new BmpIconButtonBuild(),16761856);
         this.btn_build.clicked.add(this.onBuildClicked);
         this.btn_build.width = 100;
         this.btn_build.x = int(this.ui_info.x + this.ui_info.width - this.btn_build.width - 10);
         this.btn_build.y = this.btn_buildNow.y;
         this.mc_container.addChild(this.btn_build);
         this.ui_itemList = new UIConstructionList();
         this.ui_itemList.width = this.ui_info.x - 16;
         this.ui_itemList.height = 385;
         this.ui_itemList.x = 0;
         this.ui_itemList.y = int(this.ui_info.y);
         this.ui_itemList.changed.add(this.onBuildingSelected);
         this.ui_itemList.category = _selectedCategory;
         this.mc_container.addChild(this.ui_itemList);
         this.ui_pagination = new UIPagination();
         this.ui_pagination.y = int(this.btn_build.y);
         this.ui_pagination.changed.add(this.onPageChanged);
         this.mc_container.addChild(this.ui_pagination);
         if(_selectedId != null)
         {
            this.ui_itemList.selectItemById(_selectedId);
         }
         if(this.ui_itemList.selectedItem == null)
         {
            this.ui_itemList.selectItem(0);
         }
         var _loc8_:int = this.ui_itemList.getSelectedItemPage();
         this.ui_itemList.gotoPage(_loc8_,false);
         this.ui_pagination.numPages = this.ui_itemList.numPages;
         this.ui_pagination.currentPage = _loc8_;
         this.ui_pagination.x = int((this.ui_info.x - this.ui_pagination.width) * 0.5);
         _selectedId = this.ui_itemList.selectedItem != null ? UIConstructionListItem(this.ui_itemList.selectedItem).dataXML.@id.toString() : null;
         this.ui_info.setBuilding(_selectedId,0);
         this.onBuildingSelected();
         Network.getInstance().playerData.inventory.itemAdded.add(this.onPlayerItemAdded);
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onPlayerResourceChanged);
      }
      
      override public function dispose() : void
      {
         var _loc1_:PushButton = null;
         super.dispose();
         this.ui_pagination.dispose();
         this.ui_itemList.dispose();
         this.btn_build.dispose();
         this.btn_buildNow.dispose();
         this.ui_info.dispose();
         this._tutorial = null;
         this._xml = null;
         this._lang = null;
         this._selectedCategoryButton = null;
         for each(_loc1_ in this._catButtons)
         {
            _loc1_.dispose();
         }
         this._catButtons = null;
         TooltipManager.getInstance().removeAllFromParent(this.mc_container,true);
         Network.getInstance().playerData.inventory.itemAdded.remove(this.onPlayerItemAdded);
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onPlayerResourceChanged);
      }
      
      public function refresh() : void
      {
         this.onBuildingSelected();
      }
      
      private function onBuildClicked(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = param1.currentTarget == this.btn_buildNow;
         if(_selectedId == null)
         {
            return;
         }
         if(_loc2_)
         {
            _loc3_ = Building.getBuildingUpgradeFuelCost(this.ui_itemList.selectedItem.id,0);
            if(_loc3_ > Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH))
            {
               PaymentSystem.getInstance().openBuyCoinsScreen();
               return;
            }
         }
         this.mc_container.stage.dispatchEvent(new GameEvent(GameEvent.CONSTRUCTION_START,true,false,{
            "id":_selectedId,
            "buy":_loc2_
         }));
         close();
         DialogueManager.getInstance().closeAllModal();
      }
      
      private function onBuildingSelected() : void
      {
         if(this.ui_itemList.selectedItem == null)
         {
            _selectedId = null;
            return;
         }
         _selectedId = UIConstructionListItem(this.ui_itemList.selectedItem).dataXML.@id.toString();
         this.ui_info.setBuilding(_selectedId,0);
         if(this._tutorial.active)
         {
            this._tutorial.clearArrows();
            if(!this._tutorial.isBuildingAllowed(_selectedId,this._tutorial.step == Tutorial.STEP_COMFORT ? 2 : 1))
            {
               this.btn_build.enabled = false;
               this.btn_buildNow.enabled = false;
               this.btn_buildNow.label = this._lang.getString("construct_buildnow");
               return;
            }
            if(this._tutorial.step == Tutorial.STEP_BUILD_WORKBENCH && _selectedId != "workbench" || this._tutorial.step == Tutorial.STEP_FOOD_WATER && _selectedId != "storage-food" && _selectedId != "storage-water")
            {
               this.btn_build.enabled = false;
               this.btn_buildNow.enabled = false;
               this.btn_buildNow.label = this._lang.getString("construct_buildnow");
               return;
            }
            if(_selectedId == "workbench" && this._tutorial.step == Tutorial.STEP_BUILD_WORKBENCH)
            {
               this._tutorial.addArrow(this.btn_build,90,new Point(this.btn_build.width * 0.5,0));
            }
         }
         this.updateBuildButtonStates();
      }
      
      private function updateBuildButtonStates() : void
      {
         var max:int;
         var num:int;
         var xmlLvl:XML;
         var bldXML:XML = null;
         var purchaseOnly:Boolean = false;
         var network:Network = null;
         var meetsBldReq:Boolean = false;
         var meetsLvlReq:Boolean = false;
         var meetsAllReq:Boolean = false;
         var costResources:Dictionary = null;
         var costItems:Dictionary = null;
         var hasResources:Boolean = false;
         var hasItems:Boolean = false;
         var cost:int = 0;
         bldXML = UIConstructionListItem(this.ui_itemList.selectedItem).dataXML;
         purchaseOnly = Boolean(bldXML.@purchase == "1");
         if(purchaseOnly)
         {
            this.btn_build.visible = false;
            this.btn_buildNow.x = int(this.ui_info.x - 10 + (this.ui_info.width - this.btn_build.width) * 0.5);
            this.btn_buildNow.visible = true;
         }
         else
         {
            this.btn_build.visible = true;
            this.btn_build.x = int(this.ui_info.x + this.ui_info.width - this.btn_build.width - 10);
            this.btn_buildNow.x = int(this.ui_info.x + 10);
            this.btn_buildNow.visible = !Boolean(bldXML.@notbuyable == "1");
         }
         network = Network.getInstance();
         max = int(bldXML.@max.toString());
         num = network.playerData.compound.buildings.getNumBuildingsOfType(_selectedId);
         xmlLvl = bldXML.lvl.(@n == "0")[0];
         meetsBldReq = network.playerData.meetsRequirements(xmlLvl.req.bld);
         meetsLvlReq = network.playerData.meetsRequirements(xmlLvl.req.lvl);
         meetsAllReq = network.playerData.meetsRequirements(xmlLvl.req.children());
         costResources = new Dictionary(true);
         costItems = new Dictionary(true);
         Building.getBuildingUpgradeResourceItemCost(_selectedId,0,costResources,costItems);
         hasResources = network.playerData.compound.resources.hasResources(costResources);
         hasItems = network.playerData.inventory.containsQuantitiesOfTypes(costItems);
         this.btn_build.enabled = !purchaseOnly && num < max && meetsAllReq && hasResources && hasItems;
         if(this.btn_build.enabled)
         {
            TooltipManager.getInstance().remove(this.btn_build);
         }
         else
         {
            TooltipManager.getInstance().add(this.btn_build,this._lang.getString("tooltip." + (num >= max ? "bld_max_reached" : "all_req_notmet")),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         cost = Building.getBuildingUpgradeFuelCost(_selectedId,0);
         this.btn_buildNow.enabled = cost > 0 && num < max && meetsBldReq && meetsLvlReq;
         this.btn_buildNow.label = this._lang.getString("construct_buildnow");
         this.btn_buildNow.cost = this.btn_buildNow.enabled ? cost : 0;
         if(this.btn_buildNow.enabled)
         {
            TooltipManager.getInstance().add(this.btn_buildNow,this._lang.getString("tooltip.bld_build_now") + "<br/><br/>" + this._lang.getString("tooltip.spend_fuel",NumberFormatter.format(cost,0)),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else
         {
            TooltipManager.getInstance().add(this.btn_buildNow,this._lang.getString("tooltip." + (num >= max ? "bld_max_reached" : "bld_req_notmet")),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
      }
      
      private function onCategoryButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         if(_loc2_ == this._selectedCategoryButton)
         {
            return;
         }
         if(this._selectedCategoryButton != null)
         {
            this._selectedCategoryButton.selected = false;
            this._selectedCategoryButton = null;
         }
         this._selectedCategoryButton = _loc2_;
         this._selectedCategoryButton.selected = true;
         var _loc3_:String = String(_loc2_.data);
         this.ui_itemList.category = _loc3_;
         this.ui_itemList.selectItem(0);
         this.onBuildingSelected();
         this.ui_pagination.numPages = this.ui_itemList.numPages;
         this.ui_pagination.x = int((this.ui_info.x - this.ui_pagination.width) * 0.5);
         _selectedCategory = _loc3_;
         _selectedId = this.ui_itemList.selectedItem != null ? UIConstructionListItem(this.ui_itemList.selectedItem).dataXML.@id.toString() : null;
         this.ui_info.setBuilding(_selectedId,0);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_itemList.gotoPage(param1);
      }
      
      private function onPlayerResourceChanged(param1:String, param2:Number) : void
      {
         this.ui_itemList.category = _selectedCategory;
         this.ui_itemList.selectItemById(_selectedId);
         this.onBuildingSelected();
      }
      
      private function onPlayerItemAdded(param1:Item) : void
      {
         this.ui_itemList.category = _selectedCategory;
         this.ui_itemList.selectItemById(_selectedId);
         this.onBuildingSelected();
      }
   }
}

