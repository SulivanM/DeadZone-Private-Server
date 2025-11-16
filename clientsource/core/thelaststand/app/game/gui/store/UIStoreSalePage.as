package thelaststand.app.game.gui.store
{
   import flash.display.Sprite;
   import flash.events.Event;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.data.store.StoreSale;
   import thelaststand.app.game.gui.lists.UIStoreItemList;
   import thelaststand.app.game.gui.lists.UIStoreItemListItem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.StoreManager;
   import thelaststand.app.utils.GraphicUtils;
   
   public class UIStoreSalePage extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _sale:StoreSale;
      
      private var ui_itemList:UIStoreItemList;
      
      private var ui_itemPage:UIPagination;
      
      private var mc_header:Sprite;
      
      public function UIStoreSalePage(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         this.mc_header = new Sprite();
         addChild(this.mc_header);
         this.ui_itemList = new UIStoreItemList();
         this.ui_itemList.allowSelection = false;
         this.ui_itemList.changed.add(this.onItemSelected);
         addChild(this.ui_itemList);
         this.ui_itemPage = new UIPagination();
         this.ui_itemPage.changed.add(this.onPageChanged);
         addChild(this.ui_itemPage);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_itemList.dispose();
         this.ui_itemPage.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         graphics.clear();
         this.drawHeader();
         _loc1_ = this._height - 188;
         this.ui_itemList.x = 0;
         this.ui_itemList.width = int(this._width - this.ui_itemList.x);
         this.ui_itemList.height = _loc1_;
         this.ui_itemList.y = int(this._height - _loc1_);
         this.ui_itemPage.visible = this.ui_itemList.numPages > 1;
         this.ui_itemPage.y = int(this.ui_itemList.y + this.ui_itemList.height + 12);
         this.ui_itemPage.x = int(this.ui_itemList.x + (this.ui_itemList.width - this.ui_itemPage.width) * 0.5);
      }
      
      private function drawHeader() : void
      {
         this.mc_header.x = 0;
         this.mc_header.y = 0;
         this.mc_header.graphics.clear();
         GraphicUtils.drawUIBlock(this.mc_header.graphics,this._width,178);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._sale = StoreManager.getInstance().getSale("testsale");
         var _loc2_:Vector.<StoreItem> = StoreManager.getInstance().getItems(this._sale.itemKeys);
         this.ui_itemList.storeItemList = _loc2_;
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_itemList.gotoPage(param1);
      }
      
      private function onItemSelected() : void
      {
         var _loc1_:UIStoreItemListItem = UIStoreItemListItem(this.ui_itemList.selectedItem);
         if(_loc1_ == null)
         {
            return;
         }
         PaymentSystem.getInstance().buyStoreItem(_loc1_.storeItem);
      }
   }
}

