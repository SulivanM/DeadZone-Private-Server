package thelaststand.app.game.gui.store
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.store.StoreCollection;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryList;
   import thelaststand.app.game.gui.lists.UIInventoryCategoryListItem;
   import thelaststand.app.game.gui.lists.UIStoreItemList;
   import thelaststand.app.game.gui.lists.UIStoreItemListItem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.StoreManager;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIStoreCollectionPage extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _selectedCollection:StoreCollection;
      
      private var _selectedIndex:int = 0;
      
      private var _padding:int = 14;
      
      private var ui_collectionList:UIInventoryCategoryList;
      
      private var ui_itemList:UIStoreItemList;
      
      private var ui_itemPage:UIPagination;
      
      private var btn_buyAll:PurchasePushButton;
      
      private var txt_title:TitleTextField;
      
      private var mc_header:Sprite;
      
      public function UIStoreCollectionPage(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         this.mc_header = new Sprite();
         this.ui_collectionList = new UIInventoryCategoryList();
         this.ui_collectionList.changed.add(this.onCategoryChanged);
         addChild(this.ui_collectionList);
         this.ui_itemList = new UIStoreItemList();
         this.ui_itemList.allowSelection = false;
         this.ui_itemList.changed.add(this.onItemSelected);
         addChild(this.ui_itemList);
         this.ui_itemPage = new UIPagination();
         this.ui_itemPage.changed.add(this.onPageChanged);
         addChild(this.ui_itemPage);
         this.txt_title = new TitleTextField({
            "color":16777215,
            "size":24,
            "filters":[Effects.STROKE_THICK]
         });
         this.mc_header.addChild(this.txt_title);
         this.btn_buyAll = new PurchasePushButton(Language.getInstance().getString("store_coll_buy"));
         this.btn_buyAll.clicked.add(this.onBuyAllClicked);
         this.btn_buyAll.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         this.mc_header.addChild(this.btn_buyAll);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_itemList.dispose();
         this.ui_collectionList.dispose();
         this.ui_itemPage.dispose();
         this.txt_title.dispose();
         this.btn_buyAll.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function selectCollectionById(param1:String) : void
      {
         this.ui_itemList.selectItemById(param1);
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         this.ui_collectionList.width = 208;
         this.ui_collectionList.height = this._height;
         this.updateLayout();
      }
      
      private function updateLayout() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.ui_itemList.x = int(this.ui_collectionList.x + this.ui_collectionList.width + 14);
         this.ui_itemList.width = int(this._width - this.ui_itemList.x);
         if(this._selectedCollection != null && this._selectedCollection.canBuyAll)
         {
            _loc1_ = int(this._height - 95);
            _loc2_ = int(this._height - _loc1_ - 14);
            _loc3_ = int(this.ui_itemList.width);
            this.mc_header.graphics.clear();
            GraphicUtils.drawUIBlock(this.mc_header.graphics,_loc3_,_loc2_);
            this.mc_header.x = int(this.ui_itemList.x);
            this.mc_header.y = 0;
            addChild(this.mc_header);
            _loc4_ = 10;
            this.btn_buyAll.currency = this._selectedCollection.currency;
            this.btn_buyAll.cost = this._selectedCollection.cost;
            this.btn_buyAll.width = int(_loc3_ - _loc4_ * 2);
            this.btn_buyAll.x = int((_loc3_ - this.btn_buyAll.width) * 0.5);
            this.btn_buyAll.y = int(_loc2_ - this.btn_buyAll.height - _loc4_);
            this.txt_title.text = this._selectedCollection.getName().toUpperCase();
            this.txt_title.maxWidth = int(_loc3_ - 20);
            this.txt_title.x = int((_loc3_ - this.txt_title.width) * 0.5);
            this.txt_title.y = int((this.btn_buyAll.y - this.txt_title.height) * 0.5);
         }
         else
         {
            _loc1_ = this._height;
            if(this.mc_header.parent != null)
            {
               this.mc_header.parent.removeChild(this.mc_header);
            }
         }
         this.ui_itemList.height = _loc1_;
         this.ui_itemList.y = int(this._height - _loc1_);
         this.ui_itemPage.visible = this.ui_itemList.numPages > 1;
         this.ui_itemPage.y = int(this.ui_itemList.y + this.ui_itemList.height + 12);
         this.ui_itemPage.x = int(this.ui_itemList.x + (this.ui_itemList.width - this.ui_itemPage.width) * 0.5);
      }
      
      private function updateCollectionList() : void
      {
         var _loc4_:String = null;
         var _loc5_:StoreCollection = null;
         var _loc6_:StoreCollection = null;
         var _loc7_:UIInventoryCategoryListItem = null;
         var _loc1_:Vector.<Object> = new Vector.<Object>();
         var _loc2_:Vector.<String> = StoreManager.getInstance().getCollectionIds();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            _loc5_ = StoreManager.getInstance().getCollection(_loc4_);
            if(_loc5_ != null)
            {
               _loc1_.push({
                  "data":_loc4_,
                  "label":_loc5_.getName()
               });
            }
            _loc3_++;
         }
         _loc1_.sort(this.categorySort);
         this.ui_collectionList.categories = _loc1_;
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            _loc6_ = StoreManager.getInstance().getCollection(_loc4_);
            if(_loc6_ != null)
            {
               _loc7_ = this.ui_collectionList.getItemByCategory(_loc4_);
               if(_loc7_ != null)
               {
                  _loc7_.quantity = _loc6_.itemKeys.length;
                  _loc7_.showNew = _loc6_.isNew;
                  _loc7_.showQuantity = true;
               }
               else
               {
                  _loc7_.showQuantity = false;
                  _loc7_.showNew = false;
               }
            }
            _loc3_++;
         }
         if(this._selectedCollection != null)
         {
            this.selectCollection(this._selectedCollection.id);
         }
         else if(this.ui_collectionList.categories.length > 0)
         {
            this.selectCollection(this.ui_collectionList.categories[0].data);
         }
      }
      
      private function selectCollection(param1:String) : void
      {
         var _loc2_:StoreCollection = StoreManager.getInstance().getCollection(param1);
         if(_loc2_ == null)
         {
            this._selectedCollection = null;
            this.ui_itemList.storeItemList = null;
            return;
         }
         this.ui_collectionList.selectItemById(_loc2_.id);
         if(this._selectedCollection == _loc2_)
         {
            return;
         }
         this._selectedCollection = _loc2_;
         if(stage != null)
         {
            this.updateLayout();
         }
         this.ui_itemList.showCosts = _loc2_.allowIndividualPurchases;
         this.ui_itemList.storeItemList = StoreManager.getInstance().getItems(_loc2_.itemKeys,true);
         this.ui_itemPage.numPages = this.ui_itemList.numPages;
         this.ui_itemPage.currentPage = this.ui_itemPage.currentPage;
         this.ui_itemPage.visible = this.ui_itemList.numPages > 1;
      }
      
      private function categorySort(param1:Object, param2:Object) : int
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc3_:StoreCollection = StoreManager.getInstance().getCollection(param1.data);
         var _loc4_:StoreCollection = StoreManager.getInstance().getCollection(param2.data);
         if(_loc3_.dateEnd != null && _loc4_.dateEnd != null)
         {
            _loc5_ = _loc3_.dateEnd.time / 10000;
            _loc6_ = _loc4_.dateEnd.time / 10000;
            _loc7_ = _loc5_ - _loc6_;
            if(_loc7_ != 0)
            {
               return int(_loc7_);
            }
         }
         if(_loc3_.levelMax < int.MAX_VALUE && _loc4_.levelMax < int.MAX_VALUE)
         {
            _loc8_ = _loc3_.levelMax - _loc4_.levelMax;
            if(_loc8_ != 0)
            {
               return _loc8_;
            }
         }
         return String(param1.label).toLowerCase().localeCompare(String(param2.label).toLowerCase());
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateCollectionList();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onCategoryChanged() : void
      {
         if(this.ui_collectionList.selectedItem == null)
         {
            return;
         }
         this.selectCollection(this.ui_collectionList.selectedItem.id);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_itemList.gotoPage(param1);
      }
      
      private function onItemSelected() : void
      {
         if(this._selectedCollection != null && !this._selectedCollection.allowIndividualPurchases)
         {
            return;
         }
         var _loc1_:UIStoreItemListItem = UIStoreItemListItem(this.ui_itemList.selectedItem);
         if(_loc1_ == null)
         {
            return;
         }
         PaymentSystem.getInstance().buyStoreItem(_loc1_.storeItem);
      }
      
      private function onBuyAllClicked(param1:MouseEvent) : void
      {
         if(this._selectedCollection == null || !this._selectedCollection.canBuyAll)
         {
            return;
         }
         PaymentSystem.getInstance().buyCollection(this._selectedCollection);
      }
   }
}

