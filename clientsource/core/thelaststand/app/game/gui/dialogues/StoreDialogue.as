package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.AttireFlags;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.store.StoreCollection;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.data.store.StoreSale;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryList;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryListItem;
   import thelaststand.app.game.gui.lists.UIStoreItemList;
   import thelaststand.app.game.gui.lists.UIStoreItemListItem;
   import thelaststand.app.game.gui.store.UIFuelCounter;
   import thelaststand.app.game.gui.store.UIStoreClothingPage;
   import thelaststand.app.game.gui.store.UIStoreCollectionPage;
   import thelaststand.app.game.gui.store.UIStorePromoPage;
   import thelaststand.app.game.gui.store.UIStoreProtectionPage;
   import thelaststand.app.game.gui.store.UIStoreResourcePage;
   import thelaststand.app.game.gui.store.UIStoreSalePage;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.OfferSystem;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.StoreManager;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class StoreDialogue extends BaseDialogue
   {
      
      private static const DEFAULT_CATEGORY:String = "promo";
      
      private static const ALL_CATEGORIES:Vector.<Object> = new <Object>[{
         "data":"promo",
         "label":Language.getInstance().getString("store_cat_promo")
      },{
         "data":"sale",
         "label":Language.getInstance().getString("store_cat_sale")
      },{
         "data":"collections",
         "label":Language.getInstance().getString("store_cat_collection")
      },{
         "data":"new",
         "label":Language.getInstance().getString("store_cat_new")
      },{
         "data":"weapon",
         "label":Language.getInstance().getString("inv_cat.weapon")
      },{
         "data":"protection",
         "label":Language.getInstance().getString("store_protection_label")
      },{
         "data":"clothing",
         "label":Language.getInstance().getString("inv_cat.clothing")
      },{
         "data":"accessories",
         "label":Language.getInstance().getString("inv_cat.accessories")
      },{
         "data":"activeGear",
         "label":Language.getInstance().getString("inv_cat.activeGear")
      },{
         "data":"gear",
         "label":Language.getInstance().getString("inv_cat.gear")
      },{
         "data":"crate-key",
         "label":Language.getInstance().getString("inv_cat.crate-key")
      },{
         "data":"effect",
         "label":Language.getInstance().getString("inv_cat.effect")
      },{
         "data":"schematic",
         "label":Language.getInstance().getString("inv_cat.schematic")
      },{
         "data":"crafting",
         "label":Language.getInstance().getString("inv_cat.crafting")
      },{
         "data":"craftkit",
         "label":Language.getInstance().getString("inv_cat.craftkit")
      },{
         "data":"research",
         "label":Language.getInstance().getString("inv_cat.research")
      },{
         "data":"medical",
         "label":Language.getInstance().getString("inv_cat.medical")
      },{
         "data":"resource",
         "label":Language.getInstance().getString("inv_cat.resource")
      }];
      
      private var _catButtons:Vector.<PushButton>;
      
      private var _currentPage:Sprite;
      
      private var _displayAreaWidth:int;
      
      private var _displayAreaHeight:int;
      
      private var _displayAreaY:int;
      
      private var _lang:Language;
      
      private var _selectedCategory:String;
      
      private var _selectedSubCategory:String;
      
      private var _selectedCategoryBtn:PushButton;
      
      private var _disposed:Boolean = false;
      
      private var _categories:Vector.<Object>;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_moreFuel:PurchasePushButton;
      
      private var ui_promoPage:UIStorePromoPage;
      
      private var ui_salePage:UIStoreSalePage;
      
      private var ui_resourcePage:UIStoreResourcePage;
      
      private var ui_protectionPage:UIStoreProtectionPage;
      
      private var ui_collectionPage:UIStoreCollectionPage;
      
      private var ui_clothingPage:UIStoreClothingPage;
      
      private var ui_accessoriesPage:UIStoreClothingPage;
      
      private var ui_itemListPage:UIStoreItemList;
      
      private var ui_fuelCounter:UIFuelCounter;
      
      private var ui_page:UIPagination;
      
      private var ui_categories:UIInventoryCategoryList;
      
      public function StoreDialogue(param1:String = null, param2:String = null)
      {
         super("store",this.mc_container,true);
         DialogueManager.getInstance().closeDialogue("store");
         this._selectedCategory = param1 || DEFAULT_CATEGORY;
         this._selectedSubCategory = param2 || null;
         _autoSize = false;
         _width = 750;
         _height = 460;
         this._lang = Language.getInstance();
         addTitle(this._lang.getString("store_title"),13317903,534);
         this.ui_categories = new UIInventoryCategoryList();
         this.ui_categories.height = 382;
         this.ui_categories.width = 184;
         this.ui_categories.x = 0;
         this.ui_categories.y = int(_padding * 0.5);
         this.ui_categories.changed.add(this.onCategoryChanged);
         this.mc_container.addChild(this.ui_categories);
         this._displayAreaWidth = _width - this.ui_categories.x - this.ui_categories.width - _padding * 3;
         this._displayAreaHeight = int(this.ui_categories.height);
         this._displayAreaY = int(this.ui_categories.y);
         this.ui_itemListPage = new UIStoreItemList();
         this.ui_itemListPage.allowSelection = false;
         this.ui_itemListPage.changed.add(this.onStoreItemSelected);
         this.ui_itemListPage.width = this._displayAreaWidth;
         this.ui_itemListPage.height = this._displayAreaHeight;
         this.ui_itemListPage.x = int(_width - _padding * 2 - this.ui_itemListPage.width);
         this.ui_itemListPage.y = this._displayAreaY;
         this.ui_page = new UIPagination();
         this.ui_page.changed.add(this.onPageChanged);
         this.ui_page.x = int(this.ui_itemListPage.x + (this.ui_itemListPage.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_itemListPage.y + this.ui_itemListPage.height + 14);
         this.mc_container.addChild(this.ui_page);
         this.btn_moreFuel = new PurchasePushButton(this._lang.getString("store_btn_fuel"));
         this.btn_moreFuel.clicked.add(this.onFuelClicked);
         this.btn_moreFuel.width = 140;
         this.btn_moreFuel.x = int(_width - _padding * 2 - 45 - this.btn_moreFuel.width);
         this.btn_moreFuel.y = -35;
         this.mc_container.addChild(this.btn_moreFuel);
         this.ui_fuelCounter = new UIFuelCounter();
         this.ui_fuelCounter.x = 16;
         this.ui_fuelCounter.y = int(_height - _padding - this.ui_fuelCounter.height - 7);
         this.ui_fuelCounter.addEventListener(MouseEvent.CLICK,this.onClickFuelCounter,false,0,true);
         this.mc_container.addChild(this.ui_fuelCounter);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._disposed = true;
         this.btn_moreFuel.dispose();
         this.ui_fuelCounter.dispose();
         this.ui_itemListPage.dispose();
         this.ui_page.dispose();
         if(this.ui_resourcePage != null)
         {
            this.ui_resourcePage.dispose();
         }
         if(this.ui_protectionPage != null)
         {
            this.ui_protectionPage.dispose();
         }
         if(this.ui_collectionPage != null)
         {
            this.ui_collectionPage.dispose();
         }
         if(this.ui_clothingPage != null)
         {
            this.ui_clothingPage.dispose();
         }
         if(this.ui_accessoriesPage != null)
         {
            this.ui_accessoriesPage.dispose();
         }
         if(this.ui_promoPage != null)
         {
            this.ui_promoPage.dispose();
         }
         if(this.ui_salePage != null)
         {
            this.ui_salePage.dispose();
         }
      }
      
      public function selectCategory(param1:String, param2:String = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:UIInventoryCategoryListItem = null;
         var _loc3_:Boolean = this.ui_categories.selectItemById(param1);
         if(!_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ < this.ui_categories.numItems)
            {
               _loc5_ = UIInventoryCategoryListItem(this.ui_categories.getItem(_loc4_));
               if(_loc5_.enabled)
               {
                  this.selectCategory(_loc5_.category);
                  return;
               }
               _loc4_++;
            }
            return;
         }
         this._selectedCategory = param1;
         this._selectedSubCategory = param2;
         this.displayCurrentCategory();
         Tracking.trackPageview("store/" + this._selectedCategory + "/page1");
      }
      
      private function loadStoreItems() : void
      {
         if(StoreManager.getInstance().loaded)
         {
            this.onStoreItemsLoaded();
            return;
         }
         var _loc1_:BusyDialogue = new BusyDialogue(this._lang.getString("store_loading"),"store-loadinginventory");
         _loc1_.open();
         StoreManager.getInstance().loadCompleted.addOnce(this.onStoreItemsLoaded);
         StoreManager.getInstance().loadFailed.addOnce(this.onStoreItemsFailed);
         StoreManager.getInstance().loadStoreItems();
      }
      
      private function onStoreItemsLoaded() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:StoreSale = null;
         if(this._disposed)
         {
            return;
         }
         DialogueManager.getInstance().closeDialogue("store-loadinginventory");
         StoreManager.getInstance().loadCompleted.remove(this.onStoreItemsLoaded);
         StoreManager.getInstance().loadFailed.remove(this.onStoreItemsFailed);
         if(this._categories == null)
         {
            this._categories = new Vector.<Object>();
            _loc1_ = 0;
            for(; _loc1_ < ALL_CATEGORIES.length; _loc1_++)
            {
               _loc2_ = ALL_CATEGORIES[_loc1_];
               switch(_loc2_.data)
               {
                  case "promo":
                     if(OfferSystem.getInstance().numOffers != 0)
                     {
                        break;
                     }
                     continue;
                  case "sale":
                     _loc3_ = StoreManager.getInstance().getPromoSale();
                     if(!(_loc3_ == null || !_loc3_.isActive()))
                     {
                        break;
                     }
                     continue;
                  case "collections":
                     if(StoreManager.getInstance().getCollectionIds().length != 0)
                     {
                        break;
                     }
                     continue;
                  case "new":
                     if(StoreManager.getInstance().getNumNewItems() != 0)
                     {
                        break;
                     }
                     continue;
               }
               this._categories.push(_loc2_);
            }
            this.ui_categories.categories = this._categories;
            this.selectCategory(this._selectedCategory,this._selectedSubCategory);
         }
         this.updateQuantities();
         this.updatePagination();
      }
      
      private function onStoreItemsFailed() : void
      {
         var msg:MessageBox;
         if(this._disposed)
         {
            return;
         }
         DialogueManager.getInstance().closeDialogue("store-loadinginventory");
         StoreManager.getInstance().loadCompleted.remove(this.onStoreItemsLoaded);
         StoreManager.getInstance().loadFailed.remove(this.onStoreItemsFailed);
         msg = new MessageBox(this._lang.getString("store_loading_error"));
         msg.addTitle(this._lang.getString("store_loading_error_title"));
         msg.addButton(this._lang.getString("store_loading_error_ok"));
         msg.closed.addOnce(function(param1:Dialogue):void
         {
            close();
         });
         msg.open();
      }
      
      private function displayCurrentCategory() : void
      {
         var _loc1_:Vector.<StoreItem> = null;
         if(this._currentPage != null)
         {
            if(this._currentPage.parent != null)
            {
               this._currentPage.parent.removeChild(this._currentPage);
            }
            this._currentPage = null;
         }
         switch(this._selectedCategory)
         {
            case "promo":
               if(this.ui_promoPage == null)
               {
                  this.ui_promoPage = new UIStorePromoPage(this._displayAreaWidth,this._displayAreaHeight);
                  this.ui_promoPage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
                  this.ui_promoPage.y = this._displayAreaY;
               }
               this._currentPage = this.ui_promoPage;
               this.ui_page.visible = false;
               break;
            case "sale":
               if(this.ui_salePage == null)
               {
                  this.ui_salePage = new UIStoreSalePage(this._displayAreaWidth,this._displayAreaHeight);
                  this.ui_salePage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
                  this.ui_salePage.y = this._displayAreaY;
               }
               this._currentPage = this.ui_salePage;
               this.ui_page.visible = false;
               break;
            case "collections":
               if(this.ui_collectionPage == null)
               {
                  this.ui_collectionPage = new UIStoreCollectionPage(this._displayAreaWidth,this._displayAreaHeight);
                  this.ui_collectionPage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
                  this.ui_collectionPage.y = this._displayAreaY;
               }
               if(this._selectedSubCategory != null)
               {
                  this.ui_collectionPage.selectCollectionById(this._selectedSubCategory);
               }
               this._currentPage = this.ui_collectionPage;
               this.ui_page.visible = false;
               break;
            case "resource":
               if(this.ui_resourcePage == null)
               {
                  this.ui_resourcePage = new UIStoreResourcePage(this._displayAreaWidth,this._displayAreaHeight);
                  this.ui_resourcePage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
                  this.ui_resourcePage.y = this._displayAreaY;
               }
               if(this._selectedSubCategory != null)
               {
                  this.ui_resourcePage.selectResource(this._selectedSubCategory);
               }
               this._currentPage = this.ui_resourcePage;
               this.ui_page.visible = false;
               break;
            case "protection":
               if(this.ui_protectionPage == null)
               {
                  this.ui_protectionPage = new UIStoreProtectionPage(this._displayAreaWidth,this._displayAreaHeight);
                  this.ui_protectionPage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
                  this.ui_protectionPage.y = this._displayAreaY;
               }
               this._currentPage = this.ui_protectionPage;
               this.ui_page.visible = false;
               break;
            case "clothing":
               if(this.ui_clothingPage == null)
               {
                  this.ui_clothingPage = new UIStoreClothingPage(this._displayAreaWidth,this._displayAreaHeight);
               }
               this.ui_clothingPage.attireFlags = AttireFlags.CLOTHING;
               this.ui_clothingPage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
               this.ui_clothingPage.y = this._displayAreaY;
               this.ui_clothingPage.updateItemsList();
               this._currentPage = this.ui_clothingPage;
               this.ui_page.visible = false;
               break;
            case "accessories":
               if(this.ui_clothingPage == null)
               {
                  this.ui_clothingPage = new UIStoreClothingPage(this._displayAreaWidth,this._displayAreaHeight);
               }
               this.ui_clothingPage.attireFlags = AttireFlags.ACCESSORIES;
               this.ui_clothingPage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
               this.ui_clothingPage.y = this._displayAreaY;
               this.ui_clothingPage.updateItemsList();
               this._currentPage = this.ui_clothingPage;
               this.ui_page.visible = false;
               break;
            default:
               this._currentPage = this.ui_itemListPage;
               this.ui_itemListPage.width = this._displayAreaWidth;
               this.ui_itemListPage.x = int(this.ui_categories.x + this.ui_categories.width + _padding);
               this.ui_itemListPage.allowSelection = false;
               _loc1_ = this.getItemsForCategory(this._selectedCategory);
               this.ui_itemListPage.storeItemList = _loc1_;
               this.ui_page.visible = this.ui_itemListPage.numPages > 1;
               this.updatePagination();
         }
         if(this._currentPage != null)
         {
            this.mc_container.addChildAt(this._currentPage,0);
         }
      }
      
      private function updateQuantities() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:UIInventoryCategoryListItem = null;
         var _loc4_:String = null;
         var _loc5_:StoreSale = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Vector.<String> = null;
         var _loc11_:Vector.<StoreItem> = null;
         var _loc12_:Boolean = false;
         var _loc13_:* = false;
         var _loc14_:StoreCollection = null;
         for each(_loc2_ in this._categories)
         {
            _loc3_ = this.ui_categories.getItemByCategory(_loc2_.data);
            if(_loc3_ == null)
            {
               continue;
            }
            _loc4_ = String(_loc3_.id);
            switch(_loc4_)
            {
               case "resource":
                  _loc3_.showNew = false;
                  _loc3_.showQuantity = false;
                  break;
               case "protection":
                  _loc3_.showNew = false;
                  _loc3_.showQuantity = false;
                  break;
               case "promo":
                  _loc3_.showNew = true;
                  _loc3_.showQuantity = false;
                  break;
               case "sale":
                  _loc5_ = StoreManager.getInstance().getPromoSale();
                  _loc6_ = _loc5_ != null && _loc5_.isActive();
                  _loc3_.enabled = _loc6_;
                  _loc3_.showNew = _loc6_;
                  _loc3_.showQuantity = false;
                  break;
               case "new":
                  _loc7_ = StoreManager.getInstance().getNumNewItems();
                  _loc3_.quantity = _loc7_;
                  _loc3_.enabled = _loc3_.showNew = _loc3_.showQuantity = _loc7_ > 0;
                  break;
               case "collections":
                  _loc10_ = StoreManager.getInstance().getCollectionIds();
                  _loc1_ = 0;
                  while(_loc1_ < _loc10_.length)
                  {
                     _loc14_ = StoreManager.getInstance().getCollection(_loc10_[_loc1_]);
                     if(_loc14_ != null)
                     {
                        _loc8_ += _loc14_.isActive() ? 1 : 0;
                        _loc9_ ||= _loc14_.isNew;
                     }
                     _loc1_++;
                  }
                  _loc3_.showQuantity = _loc8_ > 0;
                  _loc3_.quantity = _loc8_;
                  _loc3_.showNew = _loc9_;
                  _loc3_.enabled = _loc8_ > 0;
                  break;
               default:
                  _loc11_ = this.getItemsForCategory(_loc4_);
                  _loc12_ = false;
                  _loc13_ = _loc11_.length > 0;
                  _loc1_ = 0;
                  while(_loc1_ < _loc11_.length)
                  {
                     _loc12_ ||= _loc11_[_loc1_].isNew;
                     if(_loc12_)
                     {
                        break;
                     }
                     _loc1_++;
                  }
                  _loc3_.showQuantity = _loc3_.enabled = _loc13_;
                  _loc3_.quantity = _loc11_.length;
                  _loc3_.showNew = _loc13_ && _loc12_;
            }
         }
      }
      
      private function getItemsForCategory(param1:String) : Vector.<StoreItem>
      {
         var items:Vector.<StoreItem> = null;
         var attireFlags:uint = 0;
         var category:String = param1;
         if(category == "new")
         {
            items = StoreManager.getInstance().getNewItems();
         }
         else if(category == "activeGear")
         {
            items = StoreManager.getInstance().getItemsByCategory("gear").filter(function(param1:StoreItem, param2:int, param3:Vector.<StoreItem>):Boolean
            {
               return Gear(param1.item).isActiveGear;
            });
         }
         else if(category == "gear")
         {
            items = StoreManager.getInstance().getItemsByCategory("gear").filter(function(param1:StoreItem, param2:int, param3:Vector.<StoreItem>):Boolean
            {
               return !Gear(param1.item).isActiveGear;
            });
         }
         else if(category == "crafting")
         {
            items = StoreManager.getInstance().getItemsWhere(function(param1:StoreItem):Boolean
            {
               return param1.item.category == "crafting" || param1.item.category == "upgradekit";
            });
         }
         else if(category == "research")
         {
            items = StoreManager.getInstance().getItemsWhere(function(param1:StoreItem):Boolean
            {
               return param1.item.category == "research-note" || param1.item.category == "research";
            });
         }
         else if(category == "clothing" || category == "accessories")
         {
            attireFlags = category == "clothing" ? AttireFlags.CLOTHING : AttireFlags.ACCESSORIES;
            items = StoreManager.getInstance().getItemsWhere(function(param1:StoreItem):Boolean
            {
               if(param1.item.category != "clothing")
               {
                  return false;
               }
               var _loc2_:* = ClothingAccessory(param1.item);
               if(_loc2_ == null)
               {
                  return false;
               }
               return (_loc2_.getAttireFlags(Gender.MALE) & attireFlags) != 0 || (_loc2_.getAttireFlags(Gender.FEMALE) & attireFlags) != 0;
            });
         }
         else
         {
            items = StoreManager.getInstance().getItemsByCategory(category);
         }
         return items;
      }
      
      private function updatePagination() : void
      {
         this.ui_page.numPages = this.ui_itemListPage.numPages;
         this.ui_page.currentPage = 0;
         this.ui_page.x = int(this.ui_itemListPage.x + (this.ui_itemListPage.width - this.ui_page.width) * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var self:StoreDialogue = null;
         var msg:MessageBox = null;
         var e:Event = param1;
         if(!Settings.getInstance().storeEnabled)
         {
            self = this;
            msg = new MessageBox(this._lang.getString("store_disabled_msg"));
            msg.addTitle(this._lang.getString("store_disabled_title"));
            msg.addButton(this._lang.getString("store_disabled_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               self.close();
            });
            msg.open();
            return;
         }
         this.loadStoreItems();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onCategoryChanged() : void
      {
         var _loc1_:String = UIInventoryCategoryListItem(this.ui_categories.selectedItem).category;
         this.selectCategory(_loc1_);
         Tracking.trackEvent("Store","Category",_loc1_);
      }
      
      private function onFuelClicked(param1:MouseEvent) : void
      {
         Tracking.trackEvent("Store","GetMoreFuel");
         PaymentSystem.getInstance().openBuyCoinsScreen(false);
      }
      
      private function onStoreItemSelected() : void
      {
         var listItem:UIStoreItemListItem = UIStoreItemListItem(this.ui_itemListPage.selectedItem);
         PaymentSystem.getInstance().buyStoreItem(listItem.storeItem,function(param1:Boolean):void
         {
         });
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_itemListPage.gotoPage(param1);
         Tracking.trackPageview("store/" + this._selectedCategory + "/page" + (param1 + 1));
      }
      
      private function onClickFuelCounter(param1:MouseEvent) : void
      {
         Tracking.trackEvent("Store","FuelCounter");
      }
      
      private function onPromoGotoStore(param1:String) : void
      {
         this.selectCategory(param1);
      }
   }
}

