package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.GearType;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorLoadoutManager;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.itemfilters.GearFilter;
   import thelaststand.app.game.data.itemfilters.ItemFilter;
   import thelaststand.app.game.data.itemfilters.WeaponsFilter;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.inventory.UIInventoryFilter;
   import thelaststand.app.game.gui.inventory.UIInventoryGearFilter;
   import thelaststand.app.game.gui.inventory.UIInventorySize;
   import thelaststand.app.game.gui.inventory.UIInventoryWeaponFilter;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryList;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryListItem;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInsetPanelGroup;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class BatchRecycleDialogue extends BaseDialogue
   {
      
      private var _maxItems:int;
      
      private var _arrows:Vector.<Bitmap>;
      
      private var _selectedCategory:String;
      
      private var _lang:Language;
      
      private var _job:BatchRecycleJob;
      
      private var _selectedFilter:ColorMatrix;
      
      private var _filters:Dictionary;
      
      private var _currentFilter:ItemFilter;
      
      private var _currentItemList:Vector.<Item>;
      
      private var _currentFilteredItemList:Vector.<Item>;
      
      private var _ctrlDown:Boolean = false;
      
      private const _categories:Vector.<Object>;
      
      private var bmp_inventory:Bitmap;
      
      private var bmp_recycle:Bitmap;
      
      private var mc_time:IconTime;
      
      private var btn_start:PushButton;
      
      private var btn_buy:PurchasePushButton;
      
      private var btn_clear:PushButton;
      
      private var ui_inventory:UIInventoryList;
      
      private var ui_outputItems:UIInventoryList;
      
      private var ui_inventoryPage:UIPagination;
      
      private var ui_outputItemsPage:UIPagination;
      
      private var ui_infoPanel:UIInsetPanelGroup;
      
      private var mc_container:Sprite;
      
      private var txt_numSelected:BodyTextField;
      
      private var txt_numDesc:BodyTextField;
      
      private var txt_inventoryTitle:BodyTextField;
      
      private var txt_inventoryCount:BodyTextField;
      
      private var txt_timeTitle:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var ui_catList:UIInventoryCategoryList;
      
      private var ui_size:UIInventorySize;
      
      private var ui_filter:UIInventoryFilter;
      
      public function BatchRecycleDialogue(param1:int, param2:String = "all")
      {
         var _loc11_:Bitmap = null;
         this._filters = new Dictionary(true);
         this._categories = new <Object>[{
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
         this.mc_container = new Sprite();
         super("batch-recycle-dialogue",this.mc_container,true);
         this._job = new BatchRecycleJob(param1);
         _autoSize = false;
         _width = 756;
         _height = 438;
         this._lang = Language.getInstance();
         this._selectedCategory = param2;
         this._selectedFilter = new ColorMatrix();
         this._selectedFilter.adjustBrightness(110,110,110);
         this._selectedFilter.colorize(65280,0.75);
         var _loc3_:Boolean = Network.getInstance().playerData.isInventoryUpgraded();
         this.ui_size = new UIInventorySize();
         this.ui_size.width = 184;
         this.ui_size.warningThreshold = Network.getInstance().playerData.inventory.numItemsWarningThreshold;
         this.ui_size.maxSize = Network.getInstance().playerData.inventory.maxItems;
         this.ui_size.size = Network.getInstance().playerData.inventory.numItems;
         this.ui_size.showAddMore = Network.getInstance().playerData.canUpgradeInventory();
         this.ui_size.isUpgraded = _loc3_;
         this.mc_container.addChild(this.ui_size);
         this.ui_catList = new UIInventoryCategoryList();
         this.ui_catList.width = 184;
         this.ui_catList.height = 374;
         this.ui_catList.x = 0;
         this.ui_catList.y = int(this.ui_size.y + this.ui_size.height + 12);
         this.ui_catList.categories = this._categories;
         this.ui_catList.changed.add(this.onCategoryChanged);
         this.mc_container.addChild(this.ui_catList);
         var _loc4_:ItemListOptions = new ItemListOptions();
         _loc4_.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc4_.showActiveGearQuantities = true;
         _loc4_.showEquippedIcons = true;
         _loc4_.allowSelection = false;
         this.ui_inventory = new UIInventoryList(48,6,_loc4_);
         this.ui_inventory.width = 176;
         this.ui_inventory.height = 338;
         this.ui_inventory.x = int(this.ui_catList.x + this.ui_catList.width + 8);
         this.ui_inventory.y = int(this.ui_size.y + this.ui_size.height + 12);
         this.ui_inventory.changed.add(this.onItemSelected);
         this.mc_container.addChild(this.ui_inventory);
         this.ui_inventoryPage = new UIPagination();
         this.ui_inventoryPage.numPages = this.ui_inventory.numPages;
         this.ui_inventoryPage.maxWidth = this.ui_inventory.width;
         this.ui_inventoryPage.maxDots = 6;
         this.ui_inventoryPage.y = int(this.ui_catList.y + this.ui_catList.height - this.ui_inventoryPage.height + 4);
         this.ui_inventoryPage.changed.add(this.onInventoryPageChanged);
         this.mc_container.addChild(this.ui_inventoryPage);
         var _loc5_:ItemListOptions = new ItemListOptions();
         _loc5_.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc5_.allowSelection = false;
         _loc5_.sortItems = false;
         this.ui_outputItems = new UIInventoryList(48,6,_loc5_);
         this.ui_outputItems.width = 118;
         this.ui_outputItems.height = int(this.ui_inventory.height);
         this.ui_outputItems.x = int(this.ui_inventory.x + this.ui_inventory.width + 30);
         this.ui_outputItems.y = int(this.ui_inventory.y);
         this.ui_outputItems.itemList = this._job.items;
         this.mc_container.addChild(this.ui_outputItems);
         this.ui_outputItemsPage = new UIPagination();
         this.ui_outputItemsPage.numPages = this.ui_outputItems.numPages;
         this.ui_outputItemsPage.maxWidth = this.ui_outputItems.width;
         this.ui_outputItemsPage.maxDots = 3;
         this.ui_outputItemsPage.x = int(this.ui_outputItems.x + (this.ui_outputItems.width - this.ui_outputItemsPage.width) * 0.5);
         this.ui_outputItemsPage.y = int(this.ui_outputItems.y + this.ui_outputItems.height + 10);
         this.ui_outputItemsPage.changed.add(this.onItemPageChanged);
         this.mc_container.addChild(this.ui_outputItemsPage);
         var _loc6_:int = 32;
         var _loc7_:int = this.ui_inventory.height / (_loc6_ + 6);
         var _loc8_:int = (this.ui_inventory.height - _loc6_ * _loc7_) / _loc7_;
         var _loc9_:int = (_loc6_ + _loc8_) * _loc7_ - _loc8_;
         this._arrows = new Vector.<Bitmap>();
         var _loc10_:int = 0;
         while(_loc10_ < _loc7_)
         {
            _loc11_ = new Bitmap(new BmpBatchRecycleArrow(),"never",true);
            _loc11_.height = _loc6_;
            _loc11_.scaleX = _loc11_.scaleY;
            _loc11_.x = int(this.ui_inventory.x + this.ui_inventory.width);
            _loc11_.y = int(this.ui_inventory.y + (this.ui_inventory.height - _loc9_) * 0.5 + (_loc6_ + _loc8_) * _loc10_);
            this.mc_container.addChild(_loc11_);
            this._arrows.push(_loc11_);
            _loc10_++;
         }
         this.ui_infoPanel = new UIInsetPanelGroup(204,this.ui_inventory.height);
         this.ui_infoPanel.x = int(this.ui_outputItems.x + this.ui_outputItems.width + 10);
         this.ui_infoPanel.y = int(this.ui_outputItems.y);
         this.ui_infoPanel.addPanel(10,110);
         this.ui_infoPanel.addPanel(18,95);
         this.ui_infoPanel.addPanel(18,77);
         this.ui_infoPanel.addPanel(10);
         this.mc_container.addChild(this.ui_infoPanel);
         this.txt_numSelected = new BodyTextField({
            "color":16777215,
            "size":22,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_numSelected.text = this._lang.getString("batch_recycle_numitems","0 / " + this._job.maxItems);
         this.txt_numSelected.x = int(this.ui_infoPanel.x + (this.ui_infoPanel.width - this.txt_numSelected.width) * 0.5 + 10);
         this.txt_numSelected.y = int(this.ui_infoPanel.y + 22);
         this.mc_container.addChild(this.txt_numSelected);
         this.txt_numDesc = new BodyTextField({
            "color":11513775,
            "size":12,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_numDesc.text = this._lang.getString("batch_recycle_numitems_desc");
         this.txt_numDesc.x = int(this.ui_infoPanel.x + (this.ui_infoPanel.width - this.txt_numDesc.width) * 0.5);
         this.txt_numDesc.y = int(this.txt_numSelected.y + this.txt_numSelected.height - 6);
         this.mc_container.addChild(this.txt_numDesc);
         this.bmp_recycle = new Bitmap(new BmpIconRecycle());
         this.bmp_recycle.filters = [Effects.TEXT_SHADOW];
         this.bmp_recycle.alpha = 0.5;
         this.bmp_recycle.x = int(this.txt_numSelected.x - this.bmp_recycle.width - 8);
         this.bmp_recycle.y = int(this.txt_numSelected.y + (this.txt_numSelected.height - this.bmp_recycle.height) * 0.5);
         this.mc_container.addChild(this.bmp_recycle);
         this.btn_clear = new PushButton(this._lang.getString("batch_recycle_clear"));
         this.btn_clear.width = 160;
         this.btn_clear.x = int(this.ui_infoPanel.x + (this.ui_infoPanel.width - this.btn_clear.width) * 0.5);
         this.btn_clear.y = int(this.txt_numDesc.y + this.txt_numDesc.height + 10);
         this.btn_clear.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_clear);
         this.bmp_inventory = new Bitmap(_loc3_ ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory(),"auto",true);
         this.bmp_inventory.scaleX = this.bmp_inventory.scaleY = 0.75;
         this.bmp_inventory.filters = [Effects.ICON_SHADOW];
         this.bmp_inventory.x = int(this.ui_infoPanel.x + this.ui_infoPanel.width * 0.07);
         this.bmp_inventory.y = int(this.ui_infoPanel.y + 185 - this.bmp_inventory.height * 0.5);
         this.mc_container.addChild(this.bmp_inventory);
         this.txt_inventoryTitle = new BodyTextField({
            "color":11513775,
            "size":12,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_inventoryTitle.text = this._lang.getString("batch_recycle_inv_cap");
         this.txt_inventoryTitle.x = int(this.bmp_inventory.x + this.bmp_inventory.width + 10);
         this.txt_inventoryTitle.y = int(this.bmp_inventory.y + this.bmp_inventory.height * 0.5 - this.txt_inventoryTitle.height - 2);
         this.mc_container.addChild(this.txt_inventoryTitle);
         this.txt_inventoryCount = new BodyTextField({
            "color":16777215,
            "size":20,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_inventoryCount.text = "0 / 0";
         this.txt_inventoryCount.x = int(this.txt_inventoryTitle.x + (this.txt_inventoryTitle.width - this.txt_inventoryCount.width) * 0.5);
         this.txt_inventoryCount.y = int(this.txt_inventoryTitle.y + this.txt_inventoryTitle.height - 4);
         this.mc_container.addChild(this.txt_inventoryCount);
         this.txt_timeTitle = new BodyTextField({
            "color":11513775,
            "size":12,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_timeTitle.text = this._lang.getString("batch_recycle_time");
         this.txt_timeTitle.x = int(this.ui_infoPanel.x + (this.ui_infoPanel.width - this.txt_timeTitle.width) * 0.5);
         this.txt_timeTitle.y = int(this.ui_infoPanel.y + 268);
         this.mc_container.addChild(this.txt_timeTitle);
         this.txt_time = new BodyTextField({
            "color":16777215,
            "size":20,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_time.text = " ";
         this.txt_time.x = int(this.txt_timeTitle.x + (this.txt_timeTitle.width - this.txt_time.width) * 0.5 + 10);
         this.txt_time.y = int(this.txt_timeTitle.y + this.txt_timeTitle.height - 2);
         this.mc_container.addChild(this.txt_time);
         this.mc_time = new IconTime();
         this.mc_time.x = int(this.txt_time.x - this.mc_time.width - 5);
         this.mc_time.y = int(this.txt_time.y + (this.txt_time.height - this.mc_time.height) * 0.5);
         this.mc_container.addChild(this.mc_time);
         this.btn_start = new PushButton(this._lang.getString("batch_recycle_start"),new BmpIconRecycle(),3183890);
         this.btn_start.clicked.add(this.onButtonClicked);
         this.btn_start.width = 72;
         this.btn_start.x = int(this.ui_infoPanel.x + this.ui_infoPanel.width - this.btn_start.width - 2);
         this.btn_start.y = int(this.ui_outputItemsPage.y);
         this.btn_start.enabled = false;
         this.mc_container.addChild(this.btn_start);
         this.btn_buy = new PurchasePushButton(this._lang.getString("batch_recycle_buy"),0,true);
         this.btn_buy.width = this.ui_infoPanel.width - this.btn_start.width - 18;
         this.btn_buy.x = int(this.ui_infoPanel.x + 2);
         this.btn_buy.y = int(this.ui_outputItemsPage.y);
         this.btn_buy.enabled = false;
         this.btn_buy.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_buy);
         this._filters["weapon"] = {
            "filter":new WeaponsFilter(),
            "ui":new UIInventoryWeaponFilter(),
            "width":488
         };
         this._filters["gear"] = this._filters["activeGear"] = this._filters["schematic"] = {
            "filter":new GearFilter(),
            "ui":new UIInventoryGearFilter(),
            "width":376
         };
         this.setCategory(this._selectedCategory);
         Network.getInstance().playerData.inventorySizeChanged.add(this.onPlayerInventorySizeChanged);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         var _loc1_:Bitmap = null;
         var _loc2_:Object = null;
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         Network.getInstance().playerData.inventorySizeChanged.remove(this.onPlayerInventorySizeChanged);
         super.dispose();
         if(this._job != null && this._job.timer == null)
         {
            this._job.dispose();
         }
         this.ui_inventory.dispose();
         this.ui_inventoryPage.dispose();
         this.ui_outputItems.dispose();
         this.ui_outputItemsPage.dispose();
         this.ui_infoPanel.dispose();
         this.ui_catList.dispose();
         this.txt_numSelected.dispose();
         this.txt_numDesc.dispose();
         this.btn_clear.dispose();
         this.bmp_recycle.filters = [];
         this.bmp_recycle.bitmapData.dispose();
         this.bmp_inventory.filters = [];
         this.bmp_inventory.bitmapData.dispose();
         this.btn_start.dispose();
         this.btn_buy.dispose();
         for each(_loc1_ in this._arrows)
         {
            _loc1_.bitmapData.dispose();
            _loc1_.bitmapData = null;
         }
         for each(_loc2_ in this._filters)
         {
            _loc2_.ui.dispose();
         }
         this._job = null;
         this._lang = null;
         this._arrows = null;
         this._currentFilteredItemList = null;
         this._currentItemList = null;
         this._currentFilter = null;
         this._filters = null;
      }
      
      private function clear() : void
      {
         var _loc2_:UIInventoryListItem = null;
         this._job.clearItems();
         var _loc1_:int = 0;
         while(_loc1_ < this.ui_inventory.numItems)
         {
            _loc2_ = this.ui_inventory.getItem(_loc1_) as UIInventoryListItem;
            _loc2_.selected = false;
            _loc2_.filters = [];
            _loc1_++;
         }
         this.ui_outputItems.itemList = this._job.items;
         this.ui_outputItems.gotoPage(0,false);
         this.updateDisplay();
      }
      
      private function start(param1:Boolean = false) : void
      {
         var cost:int;
         var btnData:Object;
         var dlgConfirm:MessageBox = null;
         var buy:Boolean = param1;
         if(Network.getInstance().isBusy)
         {
            return;
         }
         cost = this._job.getCost();
         dlgConfirm = new MessageBox(this._lang.getString(buy ? "batch_recycle_confirm_msg_buy" : "batch_recycle_confirm_msg",NumberFormatter.format(cost,0)),"recycle-confirm",true);
         dlgConfirm.addTitle(this._lang.getString("batch_recycle_confirm_title"),BaseDialogue.TITLE_COLOR_GREEN);
         dlgConfirm.addButton(this._lang.getString("batch_recycle_confirm_cancel"));
         btnData = buy ? {
            "buttonClass":PurchasePushButton,
            "cost":cost,
            "width":180
         } : {
            "iconBackgroundColor":3183890,
            "icon":new Bitmap(new BmpIconRecycle())
         };
         dlgConfirm.addButton(this._lang.getString(buy ? "batch_recycle_confirm_ok_buy" : "batch_recycle_confirm_ok"),false,btnData).clicked.addOnce(function(param1:MouseEvent):void
         {
            var busy:BusyDialogue = null;
            var e:MouseEvent = param1;
            busy = new BusyDialogue(Language.getInstance().getString("batch_recycle_recycling"));
            busy.open();
            _job.start(buy,function(param1:Boolean):void
            {
               var _loc2_:MessageBox = null;
               busy.close();
               dlgConfirm.close();
               if(param1)
               {
                  close();
               }
               else
               {
                  _loc2_ = new MessageBox(Language.getInstance().getString("batch_recycle_fail_msg"));
                  _loc2_.addTitle(Language.getInstance().getString("batch_recycle_fail_title"));
                  _loc2_.addButton(Language.getInstance().getString("batch_recycle_fail_ok"));
                  _loc2_.open();
               }
            });
         });
         dlgConfirm.open();
      }
      
      private function getInventoryCountAfterRecycle() : int
      {
         var _loc3_:Item = null;
         var _loc1_:Inventory = Network.getInstance().playerData.inventory;
         var _loc2_:int = _loc1_.numItems;
         for each(_loc3_ in this._job.items)
         {
            if(_loc3_.category != "resource")
            {
               if(_loc3_.quantifiable)
               {
                  if(!_loc1_.containsType(_loc3_.type))
                  {
                     _loc2_++;
                  }
               }
               else
               {
                  _loc2_++;
               }
            }
         }
         return _loc2_;
      }
      
      private function setCategory(param1:String, param2:int = 0) : void
      {
         var _loc4_:Object = null;
         var _loc3_:* = param1 != this._selectedCategory;
         this._selectedCategory = param1;
         this._currentItemList = this.getItemsForCategory(this._selectedCategory);
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
            _loc4_ = this._filters[this._selectedCategory];
            if(_loc4_ != null)
            {
               this._currentFilter = _loc4_.filter;
               this.ui_filter = _loc4_.ui;
               this.ui_filter.filterData = this._currentFilter.data;
               this.ui_filter.x = int(this.ui_inventory.x);
               this.ui_filter.y = int(this.ui_size.y);
               this.ui_filter.width = int(_loc4_.width);
               this.ui_filter.changed.add(this.onFilterChanged);
               this.mc_container.addChild(this.ui_filter);
               this.ui_inventory.options.sortItems = !this._currentFilter.willSort;
            }
            else
            {
               this.ui_inventory.options.sortItems = true;
            }
         }
         this._currentFilteredItemList = this._currentFilter != null ? this._currentFilter.filter(this._currentItemList) : this._currentItemList;
         this.ui_inventory.itemList = this._currentFilteredItemList;
         this.ui_inventory.gotoPage(param2);
         this.highlightSelecteditems();
         this.updateInventoryPagination();
         this.ui_catList.selectItemById(this._selectedCategory);
         this.updateCategoryNewFlagAndQuantities();
         this.updateDisplay();
      }
      
      private function highlightSelecteditems() : void
      {
         var _loc2_:UIInventoryListItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.ui_inventory.numItems)
         {
            _loc2_ = this.ui_inventory.getItem(_loc1_) as UIInventoryListItem;
            if(_loc2_.itemData != null && this._job.contains(_loc2_.itemData))
            {
               _loc2_.filters = [this._selectedFilter.filter];
            }
            else
            {
               _loc2_.filters = [];
            }
            _loc1_++;
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
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("crafting"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("upgradekit"));
               _loc2_ = _loc2_.concat(_loc3_.getItemsOfCategory("craftkit"));
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
      
      private function disableUnavailableItems() : void
      {
         var _loc2_:Item = null;
         var _loc3_:SurvivorLoadout = null;
         var _loc1_:SurvivorLoadoutManager = Network.getInstance().playerData.loadoutManager;
         for each(_loc2_ in this.ui_inventory.itemList)
         {
            if(_loc2_ is EffectItem)
            {
               if(Network.getInstance().playerData.compound.effects.containsEffect(EffectItem(_loc2_).effect))
               {
                  this.ui_inventory.setEnabledStateByItemId(_loc2_.id,false);
               }
            }
            else
            {
               _loc3_ = _loc1_.getItemOffensiveLoadout(_loc2_);
               if(_loc3_ != null)
               {
                  if(Boolean(_loc3_.survivor.state & SurvivorState.ON_MISSION) || Boolean(_loc3_.survivor.state & SurvivorState.ON_ASSIGNMENT))
                  {
                     this.ui_inventory.setEnabledStateByItemId(_loc2_.id,false);
                  }
               }
            }
         }
      }
      
      private function updateDisplay() : void
      {
         var _loc1_:int = this._job.numItemsToRecycle;
         this.txt_numSelected.text = this._lang.getString("batch_recycle_numitems",_loc1_ + " / " + this._job.maxItems);
         this.txt_numSelected.textColor = _loc1_ >= this._job.maxItems ? Effects.COLOR_WARNING : 16777215;
         this.txt_numSelected.x = int(this.ui_infoPanel.x + (this.ui_infoPanel.width - this.txt_numSelected.width) * 0.5 + 10);
         this.bmp_recycle.x = int(this.txt_numSelected.x - this.bmp_recycle.width - 8);
         var _loc2_:int = this.getInventoryCountAfterRecycle();
         var _loc3_:int = Network.getInstance().playerData.inventory.maxItems;
         this.txt_inventoryCount.text = NumberFormatter.format(_loc2_,0) + " / " + NumberFormatter.format(_loc3_,0);
         this.txt_inventoryCount.textColor = _loc2_ > _loc3_ ? Effects.COLOR_WARNING : 16777215;
         this.txt_inventoryCount.x = int(this.txt_inventoryTitle.x + (this.txt_inventoryTitle.width - this.txt_inventoryCount.width) * 0.5);
         var _loc4_:int = this._job.getTotalTime();
         this.txt_time.text = DateTimeUtils.secondsToString(_loc4_,false,_loc4_ <= 0);
         this.txt_time.x = int(this.txt_timeTitle.x + (this.txt_timeTitle.width - this.txt_time.width) * 0.5 + 10);
         this.mc_time.x = int(this.txt_time.x - this.mc_time.width - 5);
         var _loc5_:int = this._job.getCost();
         this.btn_start.enabled = _loc1_ > 0;
         this.btn_buy.enabled = _loc1_ > 0 && _loc5_ > 0;
         this.btn_buy.label = this._lang.getString("batch_recycle_buy");
         this.btn_buy.cost = _loc5_;
      }
      
      private function updateInventoryPagination() : void
      {
         this.ui_inventoryPage.numPages = this.ui_inventory.numPages;
         this.ui_inventoryPage.currentPage = this.ui_inventory.currentPage;
         this.ui_inventoryPage.x = int(this.ui_inventory.x + (this.ui_inventory.width - this.ui_inventoryPage.width) * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.mc_container.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress,false,0,true);
         this.mc_container.stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this.mc_container.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPress);
         this.mc_container.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease);
      }
      
      private function onCategoryChanged() : void
      {
         var _loc1_:UIInventoryCategoryListItem = UIInventoryCategoryListItem(this.ui_catList.selectedItem);
         this.setCategory(_loc1_.category,0);
      }
      
      private function onInventoryPageChanged(param1:int) : void
      {
         this.ui_inventory.gotoPage(param1);
      }
      
      private function onItemPageChanged(param1:int) : void
      {
         this.ui_outputItems.gotoPage(param1);
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_clear:
               this.clear();
               break;
            case this.btn_start:
               this.start();
               break;
            case this.btn_buy:
               this.start(true);
         }
      }
      
      private function onKeyPress(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.CONTROL)
         {
            this._ctrlDown = true;
         }
      }
      
      private function onKeyRelease(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.CONTROL)
         {
            this._ctrlDown = false;
         }
      }
      
      private function onItemSelected() : void
      {
         var update:Function;
         var listItem:UIInventoryListItem = null;
         var item:Item = null;
         var addAll:Boolean = false;
         var numItems:int = 0;
         var addItem:Function = null;
         var loadout:SurvivorLoadout = null;
         var equipper:Survivor = null;
         var dlgAway:MessageBox = null;
         var boughtMsg:MessageBox = null;
         var uniqueMsg:MessageBox = null;
         var effectMsg:MessageBox = null;
         listItem = UIInventoryListItem(this.ui_inventory.selectedItem);
         item = listItem.itemData;
         addAll = this._ctrlDown;
         var selected:Boolean = this._job.contains(item);
         numItems = this._job.numItemsToRecycle;
         if(!selected && numItems >= this._job.maxItems)
         {
            this.txt_numSelected.transform.colorTransform = new ColorTransform();
            TweenMax.from(this.txt_numSelected,0.5,{"colorTransform":{"exposure":2}});
            return;
         }
         update = function():void
         {
            var _loc1_:int = ui_outputItems.currentPage;
            ui_outputItems.itemList = _job.items;
            ui_outputItems.gotoPage(_loc1_);
            ui_outputItemsPage.numPages = ui_outputItems.numPages;
            ui_outputItemsPage.currentPage = ui_outputItems.currentPage;
            ui_outputItemsPage.x = int(ui_outputItems.x + (ui_outputItems.width - ui_outputItemsPage.width) * 0.5);
            updateDisplay();
         };
         if(selected)
         {
            this._job.removeItem(item);
            listItem.filters = [];
            update();
         }
         else
         {
            addItem = function():void
            {
               var qty:int = 0;
               var dlgHowMany:HowManyDialogue = null;
               var itemQty:int = item.quantifiable ? Network.getInstance().playerData.loadoutManager.getAvailableQuantity(item) : int(item.quantity);
               if(itemQty > 1)
               {
                  qty = Math.min(itemQty,_job.maxItems - numItems);
                  if(addAll)
                  {
                     _job.addItem(item,qty);
                     listItem.filters = [_selectedFilter.filter];
                     update();
                  }
                  else
                  {
                     dlgHowMany = new HowManyDialogue(_lang.getString("howmany_recycle_title",item.getName()),_lang.getString("howmany_recycle_msg"),qty);
                     dlgHowMany.amountSelected.addOnce(function(param1:int):void
                     {
                        if(param1 == 0)
                        {
                           return;
                        }
                        _job.addItem(item,param1);
                        listItem.filters = [_selectedFilter.filter];
                        update();
                     });
                     dlgHowMany.open();
                  }
               }
               else if(itemQty > 0)
               {
                  _job.addItem(item);
                  listItem.filters = [_selectedFilter.filter];
                  update();
               }
               else
               {
                  Audio.sound.play("sound/interface/int-error.mp3");
               }
            };
            loadout = Network.getInstance().playerData.loadoutManager.getItemOffensiveLoadout(item);
            if(loadout != null && loadout.survivor != null && (Boolean(loadout.survivor.state & SurvivorState.ON_MISSION) || Boolean(loadout.survivor.state & SurvivorState.ON_ASSIGNMENT)))
            {
               equipper = loadout.survivor;
               dlgAway = new MessageBox(this._lang.getString("srv_mission_cantrecycle_away_msg",equipper.firstName));
               dlgAway.addTitle(this._lang.getString("srv_mission_cantrecycle_away_title",equipper.firstName));
               dlgAway.addButton(this._lang.getString("srv_mission_cantrecycle_away_ok"));
               if(!(loadout.survivor.state & SurvivorState.ON_ASSIGNMENT))
               {
                  dlgAway.addButton(this._lang.getString("srv_mission_cantrecycle_away_speedup"),true,{
                     "buttonClass":PurchasePushButton,
                     "width":100
                  }).clicked.add(function(param1:MouseEvent):void
                  {
                     var _loc2_:SpeedUpDialogue = new SpeedUpDialogue(Network.getInstance().playerData.missionList.getMissionById(equipper.missionId));
                     _loc2_.open();
                  });
               }
               dlgAway.open();
            }
            else if(item.bought)
            {
               boughtMsg = new MessageBox(this._lang.getString("recycle_bought_msg",item.getName()),null,true);
               boughtMsg.addImage(item.getImageURI());
               boughtMsg.addTitle(this._lang.getString("recycle_bought_title"));
               boughtMsg.addButton(this._lang.getString("recycle_bought_ok")).clicked.addOnce(function(param1:MouseEvent):void
               {
                  addItem();
               });
               boughtMsg.addButton(this._lang.getString("recycle_bought_cancel"));
               boughtMsg.open();
            }
            else if(item.category == "clothing" || item.qualityType == ItemQualityType.PREMIUM || ItemQualityType.isSpecial(item.qualityType))
            {
               uniqueMsg = new MessageBox(this._lang.getString("recycle_unique_msg",item.getName()),null,true);
               uniqueMsg.addImage(item.getImageURI());
               uniqueMsg.addTitle(this._lang.getString("recycle_unique_title"));
               uniqueMsg.addButton(this._lang.getString("recycle_unique_ok")).clicked.addOnce(function(param1:MouseEvent):void
               {
                  addItem();
               });
               uniqueMsg.addButton(this._lang.getString("recycle_unique_cancel"));
               uniqueMsg.open();
            }
            else if(item is EffectItem && Network.getInstance().playerData.compound.effects.containsEffect(EffectItem(item).effect))
            {
               effectMsg = new MessageBox(this._lang.getString("effect_equipped_msg"),null,true);
               effectMsg.addImage(item.getImageURI());
               effectMsg.addTitle(this._lang.getString("effect_equipped_title"));
               effectMsg.addButton(this._lang.getString("effect_equipped_ok"));
               effectMsg.open();
            }
            else
            {
               addItem();
            }
         }
      }
      
      private function onPlayerInventorySizeChanged() : void
      {
         this.ui_size.maxSize = Network.getInstance().playerData.inventory.maxItems;
         this.ui_size.showAddMore = Network.getInstance().playerData.canUpgradeInventory();
         this.ui_size.isUpgraded = Network.getInstance().playerData.isInventoryUpgraded();
         if(this.ui_size.isUpgraded)
         {
            this.ui_size.playUpgradeAnimation();
         }
         this.bmp_inventory.bitmapData.dispose();
         this.bmp_inventory.bitmapData = Network.getInstance().playerData.isInventoryUpgraded() ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory();
         this.bmp_inventory.smoothing = true;
         this.updateDisplay();
      }
      
      private function onFilterChanged() : void
      {
         this._currentFilteredItemList = this._currentFilter.filter(this._currentItemList);
         var _loc1_:int = this.ui_inventory.currentPage;
         this.ui_inventory.itemList = this._currentFilteredItemList;
         this.ui_inventory.gotoPage(_loc1_);
         this.highlightSelecteditems();
         this.updateInventoryPagination();
      }
   }
}

