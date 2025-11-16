package thelaststand.app.game.gui.store
{
   import flash.events.Event;
   import thelaststand.app.game.gui.lists.UIOffersList;
   import thelaststand.app.game.gui.lists.UIStoreItemList;
   import thelaststand.app.game.gui.lists.UIStoreItemListItem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.StoreManager;
   
   public class UIStorePromoPage extends UIComponent
   {
      
      private const MAX_PROMO_ITEMS:int = 8;
      
      private var _width:int;
      
      private var _height:int;
      
      private var ui_promoItems:UIStoreItemList;
      
      private var ui_offers:UIOffersList;
      
      private var ui_offersPage:UIPagination;
      
      public function UIStorePromoPage(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         this.ui_promoItems = new UIStoreItemList();
         this.ui_promoItems.changed.add(this.onPromoItemSelected);
         addChild(this.ui_promoItems);
         this.ui_offers = new UIOffersList();
         addChild(this.ui_offers);
         this.ui_offersPage = new UIPagination();
         this.ui_offersPage.changed.add(this.onOffersPageChanged);
         this.ui_offersPage.maxDots = 14;
         addChild(this.ui_offersPage);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      override protected function draw() : void
      {
         this.ui_promoItems.width = 154;
         this.ui_promoItems.height = this._height;
         this.ui_promoItems.x = this._width - this.ui_promoItems.width;
         this.ui_promoItems.y = 0;
         this.ui_offers.height = this._height;
         this.ui_offers.x = int((this.ui_promoItems.x - 14 - this.ui_offers.width) * 0.5);
         this.ui_offers.y = 0;
         this.ui_offersPage.numPages = this.ui_offers.numPages;
         this.ui_offersPage.x = int(this.ui_offers.x + (this.ui_offers.width - this.ui_offersPage.width) * 0.5);
         this.ui_offersPage.y = int(this.ui_offers.y + this.ui_offers.height + 10);
      }
      
      private function updatePromoItems() : void
      {
         var _loc2_:Vector.<String> = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc1_:Vector.<String> = StoreManager.getInstance().getPromotedItemKeys();
         if(_loc1_.length > this.MAX_PROMO_ITEMS)
         {
            _loc2_ = new Vector.<String>(this.MAX_PROMO_ITEMS,true);
            _loc3_ = 0;
            while(_loc3_ < this.MAX_PROMO_ITEMS)
            {
               _loc4_ = int(Math.random() * _loc1_.length);
               _loc5_ = _loc1_[_loc4_];
               _loc1_.splice(_loc4_,1);
               _loc2_[_loc3_] = _loc5_;
               _loc3_++;
            }
         }
         else
         {
            _loc2_ = _loc1_;
         }
         this.ui_promoItems.storeItemList = StoreManager.getInstance().getItems(_loc2_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(StoreManager.getInstance().loaded)
         {
            this.updatePromoItems();
         }
         else
         {
            StoreManager.getInstance().loadCompleted.add(this.updatePromoItems);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         StoreManager.getInstance().loadCompleted.remove(this.updatePromoItems);
      }
      
      private function onOffersPageChanged(param1:int) : void
      {
         this.ui_offers.gotoPage(param1);
      }
      
      private function onPromoItemSelected() : void
      {
         var _loc1_:UIStoreItemListItem = UIStoreItemListItem(this.ui_promoItems.selectedItem);
         if(_loc1_ == null)
         {
            return;
         }
         PaymentSystem.getInstance().buyStoreItem(_loc1_.storeItem);
      }
   }
}

