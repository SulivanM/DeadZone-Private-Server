package thelaststand.app.game.gui.lists
{
   import flash.events.Event;
   import thelaststand.app.network.OfferSystem;
   
   public class UIOffersList extends UIPagedList
   {
      
      private var _offers:Vector.<Object>;
      
      public function UIOffersList()
      {
         var _loc1_:UIOffersListItem = null;
         super();
         _paddingX = 6;
         _paddingY = 6;
         listItemClass = UIOffersListItem;
         _loc1_ = new UIOffersListItem();
         _itemWidth = _loc1_.width;
         _itemHeight = _loc1_.height;
         width = _itemWidth + _paddingX * 2;
         height = _itemHeight + _paddingY * 2;
         this._offers = OfferSystem.getInstance().getOffers();
         this.createItems();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         this._offers = null;
         super.dispose();
      }
      
      override public function gotoPage(param1:int, param2:Boolean = true) : void
      {
         super.gotoPage(param1,param2);
         var _loc3_:Object = this._offers[param1];
         if(_loc3_ != null)
         {
            OfferSystem.getInstance().setOfferViewedState(_loc3_,true);
         }
      }
      
      public function gotoItem(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._offers.length)
         {
            if(this._offers[_loc4_].key == param1)
            {
               _loc3_ = _loc4_;
               break;
            }
            _loc4_++;
         }
         this.gotoPage(_loc4_,param2);
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc2_:int = 0;
         var _loc3_:UIOffersListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         this._offers.sort(this.itemCompare);
         _items.length = 0;
         _selectedItem = null;
         _loc2_ = 0;
         while(_loc2_ < this._offers.length)
         {
            _loc1_ = new listItemClass();
            _loc3_ = _loc1_ as UIOffersListItem;
            _loc3_.offer = this._offers[_loc2_];
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc2_++;
         }
         super.createItems();
      }
      
      private function itemCompare(param1:Object, param2:Object) : int
      {
         var _loc3_:int = int(param1.priority);
         var _loc4_:int = int(param2.priority);
         if(_loc3_ != _loc4_)
         {
            return _loc4_ - _loc3_;
         }
         if(Boolean(param1.viewed) && !param2.viewed)
         {
            return -1;
         }
         if(!param1.viewed && Boolean(param2.viewed))
         {
            return 1;
         }
         var _loc5_:Date = param1.expires as Date;
         var _loc6_:Date = param2.expires as Date;
         if(_loc5_ != null && _loc6_ == null)
         {
            return -1;
         }
         if(_loc5_ == null && _loc6_ != null)
         {
            return 1;
         }
         if(_loc5_ != null && _loc6_ != null)
         {
            return _loc5_.time - _loc6_.time;
         }
         if(param1.PriceCoins === 0)
         {
            return -1;
         }
         if(param2.PriceCoins === 0)
         {
            return 1;
         }
         return 0;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._offers.length == 0)
         {
            return;
         }
         var _loc2_:Object = this._offers[_currentPage];
         if(_loc2_ != null)
         {
            OfferSystem.getInstance().setOfferViewedState(_loc2_,true);
         }
      }
   }
}

