package thelaststand.app.game.gui.store
{
   import flash.events.Event;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.data.store.StoreSale;
   import thelaststand.app.game.gui.lists.UIStoreItemList;
   import thelaststand.app.game.gui.lists.UIStoreItemListItem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.network.StoreManager;
   
   public class UIStoreClothingPage extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _sale:StoreSale;
      
      private var _attireFlags:uint;
      
      private var ui_itemList:UIStoreItemList;
      
      private var ui_itemPage:UIPagination;
      
      private var ui_preview:UIStoreClothingPreview;
      
      public function UIStoreClothingPage(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         this._attireFlags = this.attireFlags;
         this.ui_itemList = new UIStoreItemList();
         this.ui_itemList.itemInfo.displayClothingPreview = false;
         this.ui_itemList.changed.add(this.onItemSelected);
         addChild(this.ui_itemList);
         this.ui_itemPage = new UIPagination();
         this.ui_itemPage.changed.add(this.onPageChanged);
         addChild(this.ui_itemPage);
         this.ui_preview = new UIStoreClothingPreview();
         addChild(this.ui_preview);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,1,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get attireFlags() : uint
      {
         return this._attireFlags;
      }
      
      public function set attireFlags(param1:uint) : void
      {
         this._attireFlags = param1;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_itemList.dispose();
         this.ui_itemPage.dispose();
         this.ui_preview.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         this.ui_preview.x = 0;
         this.ui_preview.y = 0;
         this.ui_itemList.x = int(this.ui_preview.x + this.ui_preview.width + 14);
         this.ui_itemList.y = 0;
         this.ui_itemList.width = int(this._width - this.ui_itemList.x);
         this.ui_itemList.height = this._height;
         this.ui_itemPage.visible = this.ui_itemList.numPages > 1;
         this.ui_itemPage.numPages = this.ui_itemList.numPages;
         this.ui_itemPage.y = int(this.ui_itemList.y + this.ui_itemList.height + 12);
         this.ui_itemPage.x = int(this.ui_itemList.x + (this.ui_itemList.width - this.ui_itemPage.width) * 0.5);
      }
      
      public function updateItemsList() : void
      {
         var first:UIStoreItemListItem;
         if(stage == null)
         {
            return;
         }
         this.ui_itemList.storeItemList = StoreManager.getInstance().getItemsWhere(function(param1:StoreItem):Boolean
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
            return (_loc2_.getAttireFlags(Gender.MALE) & _attireFlags) != 0 || (_loc2_.getAttireFlags(Gender.FEMALE) & _attireFlags) != 0;
         });
         first = this.ui_itemList.getItem(0) as UIStoreItemListItem;
         if(first != null && first.storeItem != null)
         {
            this.ui_itemList.selectItem(0);
            this.ui_preview.setItem(first.storeItem);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateItemsList();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onItemSelected() : void
      {
         var _loc1_:UIStoreItemListItem = UIStoreItemListItem(this.ui_itemList.selectedItem);
         if(_loc1_ != null)
         {
            this.ui_preview.setItem(_loc1_.storeItem);
         }
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_itemList.gotoPage(param1);
      }
   }
}

