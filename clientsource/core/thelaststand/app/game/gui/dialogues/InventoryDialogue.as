package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.GearType;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadoutManager;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.itemfilters.GearFilter;
   import thelaststand.app.game.data.itemfilters.ItemFilter;
   import thelaststand.app.game.data.itemfilters.WeaponsFilter;
   import thelaststand.app.game.gui.inventory.UIInventoryFilter;
   import thelaststand.app.game.gui.inventory.UIInventoryGearFilter;
   import thelaststand.app.game.gui.inventory.UIInventorySize;
   import thelaststand.app.game.gui.inventory.UIInventoryWeaponFilter;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryList;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryListItem;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class InventoryDialogue extends BaseDialogue
   {
      
      private static var _selectedCategory:String;
      
      private var _lang:Language;
      
      private var _options:InventoryDialogueOptions;
      
      private var _categories:Vector.<Object>;
      
      private var _resourceItems:Array;
      
      private var _xml:XML;
      
      private var _filters:Dictionary = new Dictionary(true);
      
      private var _currentFilter:ItemFilter;
      
      private var _currentItemList:Vector.<Item>;
      
      private var _currentFilteredItemList:Vector.<Item>;
      
      private var btn_store:PushButton;
      
      private var btn_batchRecycle:PushButton;
      
      private var btn_batchDispose:PushButton;
      
      private var mc_container:Sprite;
      
      private var ui_catList:UIInventoryCategoryList;
      
      private var ui_itemList:UIInventoryList;
      
      private var ui_pagination:UIPagination;
      
      private var ui_size:UIInventorySize;
      
      private var ui_filter:UIInventoryFilter;
      
      private const _categoriesNormal:Vector.<Object> = new <Object>[{
         "data":"all",
         "label":Language.getInstance().getString("inv_cat.all")
      },{
         "data":"new",
         "label":Language.getInstance().getString("inv_cat.new")
      },{
         "data":"weapon",
         "label":Language.getInstance().getString("inv_cat.weapon")
      },{
         "data":"gear",
         "label":Language.getInstance().getString("inv_cat.gear")
      },{
         "data":"activeGear",
         "label":Language.getInstance().getString("inv_cat.activeGear")
      },{
         "data":"medical",
         "label":Language.getInstance().getString("inv_cat.medical")
      },{
         "data":"crafting",
         "label":Language.getInstance().getString("inv_cat.crafting")
      },{
         "data":"research",
         "label":Language.getInstance().getString("inv_cat.research")
      },{
         "data":"schematic",
         "label":Language.getInstance().getString("inv_cat.schematic")
      },{
         "data":"clothing",
         "label":Language.getInstance().getString("inv_cat.clothing")
      },{
         "data":"effect",
         "label":Language.getInstance().getString("inv_cat.effect")
      },{
         "data":"crate",
         "label":Language.getInstance().getString("inv_cat.crate")
      },{
         "data":"junk",
         "label":Language.getInstance().getString("inv_cat.junk")
      }];
      
      private const _categoriesResource:Vector.<Object> = new <Object>[{
         "data":"resource",
         "label":Language.getInstance().getString("inv_cat.resource")
      },{
         "data":"weapon",
         "label":Language.getInstance().getString("inv_cat.weapon")
      },{
         "data":"gear",
         "label":Language.getInstance().getString("inv_cat.gear")
      },{
         "data":"activeGear",
         "label":Language.getInstance().getString("inv_cat.activeGear")
      },{
         "data":"medical",
         "label":Language.getInstance().getString("inv_cat.medical")
      },{
         "data":"crafting",
         "label":Language.getInstance().getString("inv_cat.crafting")
      },{
         "data":"research",
         "label":Language.getInstance().getString("inv_cat.research")
      },{
         "data":"schematic",
         "label":Language.getInstance().getString("inv_cat.schematic")
      },{
         "data":"clothing",
         "label":Language.getInstance().getString("inv_cat.clothing")
      },{
         "data":"effect",
         "label":Language.getInstance().getString("inv_cat.effect")
      },{
         "data":"crate",
         "label":Language.getInstance().getString("inv_cat.crate")
      },{
         "data":"junk",
         "label":Language.getInstance().getString("inv_cat.junk")
      }];
      
      public var selected:Signal = new Signal(Item);
      
      public function InventoryDialogue(param1:String = null, param2:InventoryDialogueOptions = null)
      {
         this._options = param2 || new InventoryDialogueOptions();
         if(this._options.itemListOptions == null)
         {
            this._options.itemListOptions = new ItemListOptions();
            this._options.itemListOptions.clothingPreviews = ClothingPreviewDisplayOptions.DEFAULT;
            this._options.itemListOptions.showControls = true;
            this._options.itemListOptions.showActiveGearQuantities = true;
            this._options.itemListOptions.showEquippedIcons = true;
         }
         if(this._options.trackingPageTag == null)
         {
            this._options.trackingPageTag = "inventory";
         }
         if(this._options.trackingEventTag == null)
         {
            this._options.trackingEventTag = "inventory";
         }
         DialogueManager.getInstance().closeDialogue("inventory-dialogue");
         this.mc_container = new Sprite();
         super("inventory-dialogue",this.mc_container,true);
         this._categories = this._options.showResources ? this._categoriesResource : this._categoriesNormal;
         _autoSize = false;
         _width = 756;
         _height = 490;
         this._lang = Language.getInstance();
         this._xml = ResourceManager.getInstance().getResource("xml/items.xml").content;
         _selectedCategory = param1 || this._categories[0].data;
         var _loc3_:Boolean = Network.getInstance().playerData.isInventoryUpgraded();
         this.ui_size = new UIInventorySize();
         this.ui_size.warningThreshold = Network.getInstance().playerData.inventory.numItemsWarningThreshold;
         this.ui_size.maxSize = Network.getInstance().playerData.inventory.maxItems;
         this.ui_size.size = Network.getInstance().playerData.inventory.numItems;
         this.ui_size.isUpgraded = _loc3_;
         this.ui_size.showAddMore = Network.getInstance().playerData.canUpgradeInventory();
         this.mc_container.addChild(this.ui_size);
         this.ui_itemList = new UIInventoryList(64,10,this._options.itemListOptions);
         this.ui_itemList.width = 528;
         this.ui_itemList.height = 380;
         this.ui_itemList.x = int(_width - this.ui_itemList.width - _padding * 2);
         this.ui_itemList.y = 40;
         this.ui_itemList.changed.add(this.onItemSelected);
         var _loc4_:int = 28;
         var _loc5_:int = this.ui_itemList.x + this.ui_itemList.width - _loc4_ - 4;
         var _loc6_:int = int(this.ui_itemList.y + this.ui_itemList.height + 10);
         this.btn_batchDispose = new PushButton(null,new BmpIconIncinerator(),12071698);
         this.btn_batchDispose.clicked.add(this.onBatchDisposeClicked);
         this.btn_batchDispose.width = _loc4_;
         this.btn_batchDispose.x = _loc5_;
         this.btn_batchDispose.y = _loc6_;
         if(this._options.showIncineratorButton)
         {
            this.mc_container.addChild(this.btn_batchDispose);
            _loc5_ -= this.btn_batchDispose.width + 10;
         }
         this.btn_batchRecycle = new PushButton(null,new BmpIconRecycle(),3183890);
         this.btn_batchRecycle.clicked.add(this.onBatchRecycleClicked);
         this.btn_batchRecycle.width = _loc4_;
         this.btn_batchRecycle.x = _loc5_;
         this.btn_batchRecycle.y = _loc6_;
         if(this._options.showRecyclerButton)
         {
            this.mc_container.addChild(this.btn_batchRecycle);
         }
         this.ui_pagination = new UIPagination();
         this.ui_pagination.numPages = this.ui_itemList.numPages;
         this.ui_pagination.maxDots = 18;
         this.ui_pagination.maxWidth = int(this.btn_batchRecycle.x - this.ui_itemList.x - 44);
         this.ui_pagination.x = int(this.ui_itemList.x + 4 + (this.btn_batchRecycle.x - this.ui_itemList.x - this.ui_pagination.width) * 0.5);
         this.ui_pagination.y = int(this.btn_batchRecycle.y);
         this.ui_pagination.changed.add(this.onPageChanged);
         this.ui_catList = new UIInventoryCategoryList();
         this.ui_catList.width = 194;
         this.ui_catList.height = int(this.ui_itemList.height);
         this.ui_catList.x = 0;
         this.ui_catList.y = int(this.ui_itemList.y);
         this.ui_catList.categories = this._categories;
         this.ui_catList.changed.add(this.onCategoryChanged);
         this.mc_container.addChild(this.ui_catList);
         this.mc_container.addChild(this.ui_pagination);
         this.mc_container.addChild(this.ui_itemList);
         this.btn_store = new PushButton("",new BmpIconStore(),-1,null,4226049);
         this.btn_store.clicked.add(this.onStoreClicked);
         this.btn_store.width = 68;
         this.btn_store.x = this.ui_catList.x + 4;
         this.btn_store.y = this.ui_pagination.y;
         if(this._options.showStoreButton)
         {
            this.mc_container.addChild(this.btn_store);
         }
         this._filters["weapon"] = {
            "filter":new WeaponsFilter(),
            "ui":new UIInventoryWeaponFilter()
         };
         this._filters["gear"] = this._filters["activeGear"] = this._filters["schematic"] = {
            "filter":new GearFilter(),
            "ui":new UIInventoryGearFilter()
         };
         TooltipManager.getInstance().add(this.btn_store,this._lang.getString("tooltip.store"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         Network.getInstance().playerData.inventory.itemAdded.add(this.onInventoryChanged);
         Network.getInstance().playerData.inventory.itemRemoved.add(this.onInventoryChanged);
         Network.getInstance().playerData.inventorySizeChanged.add(this.onInventorySizeChanged);
         this.setCategory(_selectedCategory);
      }
      
      override public function dispose() : void
      {
         var _loc1_:Object = null;
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         Network.getInstance().playerData.inventory.itemAdded.remove(this.onInventoryChanged);
         Network.getInstance().playerData.inventory.itemRemoved.remove(this.onInventoryChanged);
         Network.getInstance().playerData.inventorySizeChanged.remove(this.onInventorySizeChanged);
         this.mc_container.removeEventListener(Event.ENTER_FRAME,this.redraw);
         super.dispose();
         this.selected.removeAll();
         this.ui_catList.dispose();
         this.ui_itemList.dispose();
         this.ui_pagination.dispose();
         this.btn_batchRecycle.dispose();
         this.btn_store.dispose();
         for each(_loc1_ in this._filters)
         {
            _loc1_.ui.dispose();
         }
         this._currentFilteredItemList = null;
         this._currentItemList = null;
         this._currentFilter = null;
         this._filters = null;
         this._options = null;
         this._lang = null;
         this._xml = null;
      }
      
      override public function close() : void
      {
         var _loc1_:Item = null;
         if(this._options.clearNewFlagsOnClose)
         {
            for each(_loc1_ in Network.getInstance().playerData.inventory.getAllItems())
            {
               _loc1_.isNew = false;
            }
         }
         Network.getInstance().save(null,SaveDataMethod.ITEM_CLEAR_NEW);
         super.close();
      }
      
      public function setItemTint(param1:String, param2:int) : void
      {
         this.ui_itemList.setItemTint(param1,param2);
      }
      
      public function refreshItems() : void
      {
         this.setCategory(_selectedCategory,this.ui_itemList.currentPage);
      }
      
      public function selectCategory(param1:String) : void
      {
         this.setCategory(param1);
      }
      
      private function disableUnavailableItems() : void
      {
         var _loc2_:Item = null;
         var _loc3_:Survivor = null;
         var _loc1_:SurvivorLoadoutManager = Network.getInstance().playerData.loadoutManager;
         for each(_loc2_ in this.ui_itemList.itemList)
         {
            if(_loc2_ != null)
            {
               if(_loc2_ is EffectItem)
               {
                  if(Network.getInstance().playerData.compound.effects.containsEffect(EffectItem(_loc2_).effect))
                  {
                     this.ui_itemList.setEnabledStateByItemId(_loc2_.id,false);
                  }
               }
               else if(_loc2_ is ClothingAccessory)
               {
                  _loc3_ = _loc1_.getItemClothingSurvivor(ClothingAccessory(_loc2_));
                  if(_loc3_ != null && (Boolean(_loc3_.state & SurvivorState.ON_MISSION) || Boolean(_loc3_.state & SurvivorState.ON_ASSIGNMENT)))
                  {
                     this.ui_itemList.setEnabledStateByItemId(_loc2_.id,false);
                  }
               }
               else if(_loc1_.getCompoundAvailableQuantity(_loc2_) == 0)
               {
                  this.ui_itemList.setEnabledStateByItemId(_loc2_.id,false);
               }
            }
         }
      }
      
      private function setCategory(param1:String, param2:int = 0) : void
      {
         var _loc4_:Item = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc3_:* = param1 != _selectedCategory;
         _selectedCategory = param1;
         this._currentItemList = this.getItemsForCategory(_selectedCategory);
         if(this._options.showResources && (_selectedCategory == "all" || _selectedCategory == "resource"))
         {
            if(this._resourceItems == null)
            {
               this._resourceItems = [];
               _loc5_ = [GameResources.WOOD,GameResources.METAL,GameResources.CLOTH,GameResources.FOOD,GameResources.WATER,GameResources.AMMUNITION];
               for each(_loc6_ in _loc5_)
               {
                  this._resourceItems.push(ItemFactory.createItemFromTypeId(_loc6_));
               }
            }
            for each(_loc4_ in this._resourceItems)
            {
               _loc4_.quantity = Network.getInstance().playerData.compound.resources.getAmount(_loc4_.type);
               this._currentItemList.unshift(_loc4_);
            }
         }
         if(_loc3_)
         {
            this._currentFilter = null;
            if(this.ui_filter != null)
            {
               if(this.ui_filter.parent != null)
               {
                  this.ui_filter.parent.removeChild(this.ui_filter);
               }
               this.ui_filter.changed.remove(this.onFilterChanged);
               this.ui_filter = null;
            }
            _loc7_ = this._filters[_selectedCategory];
            if(_loc7_ != null)
            {
               this._currentFilter = _loc7_.filter;
               this.ui_filter = _loc7_.ui;
               this.ui_filter.filterData = this._currentFilter.data;
               this.ui_filter.x = int(this.ui_itemList.x);
               this.ui_filter.y = int(this.ui_size.y);
               this.ui_filter.width = int(this.ui_itemList.width - btn_close.width - 20);
               this.ui_filter.changed.add(this.onFilterChanged);
               this.mc_container.addChild(this.ui_filter);
               this.ui_itemList.options.sortItems = !this._currentFilter.willSort;
            }
            else
            {
               this.ui_itemList.options.sortItems = true;
            }
         }
         if(this._options.preProcessorFunction != null)
         {
            this._currentItemList = this._options.preProcessorFunction(this._currentItemList);
         }
         this._currentFilteredItemList = this._currentFilter != null ? this._currentFilter.filter(this._currentItemList) : this._currentItemList;
         this.ui_itemList.itemList = this._currentFilteredItemList;
         this.ui_itemList.gotoPage(param2);
         this.updateItemListPagination();
         if(this._options.disableUnavailableItems)
         {
            this.disableUnavailableItems();
         }
         this.ui_catList.selectItemById(_selectedCategory);
         this.updateCategoryNewFlagAndQuantities();
         this.ui_size.size = Network.getInstance().playerData.inventory.numItems;
         if(_loc3_)
         {
            Tracking.trackPageview(this._options.trackingPageTag + "/" + _selectedCategory);
         }
      }
      
      private function getItemsForCategory(param1:String) : Vector.<Item>
      {
         var _loc2_:Vector.<Item> = null;
         var _loc3_:Inventory = Network.getInstance().playerData.inventory;
         switch(param1)
         {
            case "all":
               _loc2_ = _loc3_.getAllItems();
               break;
            case "new":
               _loc2_ = _loc3_.getNewItems();
               break;
            case "crate":
               _loc2_ = new Vector.<Item>();
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("crate-key"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("crate"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("crate-mystery"));
               break;
            case "gear":
               _loc2_ = _loc3_.getGear(GearType.PASSIVE);
               break;
            case "activeGear":
               _loc2_ = _loc3_.getGear(GearType.ACTIVE);
               break;
            case "crafting":
               _loc2_ = new Vector.<Item>();
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("upgradekit"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("craftkit"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("crafting"));
               break;
            case "research":
               _loc2_ = new Vector.<Item>();
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("research-note"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("research"));
               break;
            default:
               _loc2_ = _loc3_.getItemsOfCategory(param1);
         }
         return _loc2_;
      }
      
      private function updateCategoryNewFlagAndQuantities() : void
      {
         var _loc1_:Object = null;
         var _loc2_:UIInventoryCategoryListItem = null;
         var _loc3_:Vector.<Item> = null;
         var _loc4_:Boolean = false;
         var _loc5_:Item = null;
         for each(_loc1_ in this._categories)
         {
            _loc2_ = this.ui_catList.getItemByCategory(_loc1_.data);
            if(_loc2_ != null)
            {
               _loc3_ = this.getItemsForCategory(_loc1_.data);
               _loc4_ = false;
               for each(_loc5_ in _loc3_)
               {
                  if(_loc5_.isNew)
                  {
                     _loc4_ = true;
                     break;
                  }
               }
               _loc2_.showNew = _loc4_;
               _loc2_.quantity = _loc3_.length;
            }
         }
      }
      
      private function redraw(param1:Event = null) : void
      {
         this.mc_container.removeEventListener(Event.ENTER_FRAME,this.redraw);
         this.refreshItems();
      }
      
      private function updateItemListPagination() : void
      {
         this.ui_pagination.numPages = this.ui_itemList.numPages;
         this.ui_pagination.currentPage = this.ui_itemList.currentPage;
         this.ui_pagination.x = int(this.ui_itemList.x + 4 + (this.btn_batchRecycle.x - this.ui_itemList.x - this.ui_pagination.width) * 0.5);
      }
      
      private function onCategoryChanged() : void
      {
         var _loc1_:UIInventoryCategoryListItem = UIInventoryCategoryListItem(this.ui_catList.selectedItem);
         Tracking.trackEvent(this._options.trackingEventTag,"Category",_loc1_.category);
         this.setCategory(_loc1_.category,0);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_itemList.gotoPage(param1);
      }
      
      private function onStoreClicked(param1:MouseEvent) : void
      {
         Tracking.trackEvent(this._options.trackingEventTag,"Store");
         var _loc2_:StoreDialogue = new StoreDialogue();
         _loc2_.open();
      }
      
      private function onBatchRecycleClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var dlg:BatchRecycleDialogue = DialogueController.getInstance().openBatchRecycle(_selectedCategory);
         if(dlg != null)
         {
            dlg.closed.add(function(param1:Dialogue):void
            {
               setCategory(_selectedCategory,ui_itemList.currentPage);
            });
         }
      }
      
      private function onBatchDisposeClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var dlg:BatchDisposeDialogue = DialogueController.getInstance().openBatchDispose(_selectedCategory);
         if(dlg != null)
         {
            dlg.closed.add(function(param1:Dialogue):void
            {
               setCategory(_selectedCategory,ui_itemList.currentPage);
            });
         }
      }
      
      private function onInventoryChanged(param1:Item) : void
      {
         this.mc_container.addEventListener(Event.ENTER_FRAME,this.redraw);
      }
      
      private function onInventorySizeChanged() : void
      {
         var _loc1_:PlayerData = Network.getInstance().playerData;
         this.ui_size.warningThreshold = _loc1_.inventory.numItemsWarningThreshold;
         this.ui_size.maxSize = _loc1_.inventory.maxItems;
         this.ui_size.showAddMore = _loc1_.canUpgradeInventory();
         this.ui_size.isUpgraded = _loc1_.isInventoryUpgraded();
         if(this.ui_size.isUpgraded)
         {
            this.ui_size.playUpgradeAnimation();
         }
      }
      
      private function onItemSelected() : void
      {
         this.selected.dispatch(UIInventoryListItem(this.ui_itemList.selectedItem).itemData);
      }
      
      private function onFilterChanged() : void
      {
         this._currentFilteredItemList = this._currentFilter.filter(this._currentItemList);
         var _loc1_:int = this.ui_itemList.currentPage;
         this.ui_itemList.itemList = this._currentFilteredItemList;
         this.ui_itemList.gotoPage(_loc1_);
         this.updateItemListPagination();
         if(this._options.disableUnavailableItems)
         {
            this.disableUnavailableItems();
         }
      }
   }
}

