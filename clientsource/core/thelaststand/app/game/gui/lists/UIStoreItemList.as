package thelaststand.app.game.gui.lists
{
   import flash.events.MouseEvent;
   import thelaststand.app.data.Currency;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.data.store.StoreSale;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.iteminfo.UILimitInfo;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.StoreManager;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIStoreItemList extends UIPagedList
   {
      
      private var _category:String;
      
      private var _showCosts:Boolean = true;
      
      private var _itemList:Vector.<StoreItem>;
      
      private var _fullList:Vector.<StoreItem>;
      
      private var _maxLevel:int = 0;
      
      private var _disposed:Boolean;
      
      private var _xmlEffects:XML;
      
      private var ui_itemInfo:UIItemInfo;
      
      public function UIStoreItemList(param1:int = 6)
      {
         super();
         this._xmlEffects = ResourceManager.getInstance().getResource("xml/effects.xml").content;
         this._maxLevel = Network.getInstance().playerData.compound.survivors.getHighestLevel();
         _paddingX = _paddingY = param1;
         listItemClass = UIStoreItemListItem;
         _itemWidth = 64;
         _itemHeight = 84;
         _itemSpacingX = _itemSpacingY = param1;
         this.ui_itemInfo = new UIItemInfo();
      }
      
      override public function dispose() : void
      {
         this._disposed = true;
         this._itemList = null;
         this._fullList = null;
         this.ui_itemInfo.dispose();
         this.ui_itemInfo = null;
         super.dispose();
      }
      
      override protected function createItems() : void
      {
         var _loc7_:UIStoreItemListItem = null;
         var _loc8_:StoreItem = null;
         if(_items == null)
         {
            return;
         }
         _selectedItem = null;
         var _loc1_:int = 0;
         if(this._itemList != null)
         {
            this._itemList.sort(this.itemSort);
            _loc1_ = int(this._itemList.length);
         }
         var _loc2_:int = getColsPerPage();
         var _loc3_:int = getRowsPerPage();
         var _loc4_:int = _loc2_ * _loc3_ * Math.ceil(Math.max(_loc1_,1) / (_loc2_ * _loc3_));
         var _loc5_:int = 0;
         var _loc6_:int = Math.max(_items.length,_loc1_,_loc4_);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_ < _items.length ? UIStoreItemListItem(_items[_loc5_]) : null;
            if(_loc5_ >= _loc4_)
            {
               if(_loc7_ != null)
               {
                  this.ui_itemInfo.removeRolloverTarget(_loc7_);
                  _loc7_.dispose();
               }
            }
            else
            {
               if(_loc7_ == null)
               {
                  _loc7_ = new UIStoreItemListItem();
                  mc_pageContainer.addChild(_loc7_);
                  _items.push(_loc7_);
               }
               if(this._itemList != null && _loc5_ < _loc1_ && this._itemList[_loc5_] != null)
               {
                  _loc8_ = this._itemList[_loc5_];
                  _loc7_.storeItem = _loc8_;
                  _loc7_.showCost = this._showCosts;
                  _loc7_.showRed = (_loc8_.item.category == "weapon" || _loc8_.item.category == "gear") && _loc8_.item.level > this._maxLevel;
                  _loc7_.enabled = true;
                  this.ui_itemInfo.addRolloverTarget(_loc7_);
                  _loc7_.clicked.add(onItemClicked);
                  _loc7_.mouseOver.add(this.onItemMouseOver);
                  _loc7_.mouseOut.add(this.onItemMouseOut);
               }
               else
               {
                  _loc7_.storeItem = null;
                  _loc7_.showRed = false;
                  _loc7_.enabled = false;
                  _loc7_.clicked.remove(onItemClicked);
                  _loc7_.mouseOver.remove(this.onItemMouseOver);
                  _loc7_.mouseOut.remove(this.onItemMouseOut);
                  this.ui_itemInfo.removeRolloverTarget(_loc7_);
               }
            }
            _loc5_++;
         }
         _items.length = _loc4_;
         super.createItems();
      }
      
      private function itemSort(param1:StoreItem, param2:StoreItem) : int
      {
         var _loc11_:EffectItem = null;
         var _loc12_:EffectItem = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(param1 == null)
         {
            return -1;
         }
         if(param2 == null)
         {
            return 1;
         }
         if(param1.isOnSale && !param2.isOnSale)
         {
            return -1;
         }
         if(param2.isOnSale && !param1.isOnSale)
         {
            return 1;
         }
         var _loc3_:int = param2.priority - param1.priority;
         if(_loc3_ != 0)
         {
            return _loc3_;
         }
         if(param1.item.category == "effect" && param2.item.category == "effect")
         {
            _loc11_ = EffectItem(param1.item);
            _loc12_ = EffectItem(param2.item);
            _loc13_ = int(_loc11_.effect.group.toString().toLowerCase().localeCompare(_loc12_.effect.group.toString().toLowerCase()));
            if(_loc13_ != 0)
            {
               return _loc13_;
            }
            _loc14_ = int(_loc11_.effect.type.toLowerCase().localeCompare(_loc12_.effect.type.toLowerCase()));
            if(_loc14_ != 0)
            {
               return _loc14_;
            }
         }
         var _loc4_:int = param1.item.level - param2.item.level;
         if(_loc4_ != 0)
         {
            return _loc4_;
         }
         var _loc5_:* = param1.currency == Currency.US_DOLLARS;
         var _loc6_:* = param2.currency == Currency.US_DOLLARS;
         if(_loc5_ && !_loc6_)
         {
            return -1;
         }
         if(!_loc5_ && _loc6_)
         {
            return 1;
         }
         var _loc7_:int = param1.currency == Currency.US_DOLLARS ? int(param1.cost * 100) : int(param1.cost);
         var _loc8_:int = param2.currency == Currency.US_DOLLARS ? int(param2.cost * 100) : int(param2.cost);
         var _loc9_:int = _loc8_ - _loc7_;
         if(_loc9_ != 0)
         {
            return _loc9_;
         }
         var _loc10_:int = param2.item.quantity - param1.item.quantity;
         if(_loc10_ != 0)
         {
            return _loc10_;
         }
         return param1.item.getBaseName().toLowerCase().localeCompare(param2.item.getBaseName().toLowerCase());
      }
      
      private function onItemMouseOver(param1:MouseEvent) : void
      {
         if(stage == null)
         {
            return;
         }
         var _loc2_:StoreItem = UIStoreItemListItem(param1.currentTarget).storeItem;
         var _loc3_:StoreSale = _loc2_.isOnSale ? StoreManager.getInstance().getSale(_loc2_.saleId) : null;
         var _loc4_:Date = _loc3_ != null ? _loc3_.dateEnd : _loc2_.dateEnd;
         var _loc5_:int = _loc3_ != null ? _loc3_.levelMax : _loc2_.levelMax;
         var _loc6_:Object = {
            "showAction":false,
            "adminOnly":_loc2_.adminOnly
         };
         if(_loc4_ != null)
         {
            _loc6_.limits = _loc6_.limits || [];
            _loc6_.limits.push(new UILimitInfo("available_sale_date",_loc4_));
         }
         if(_loc5_ < int.MAX_VALUE)
         {
            _loc6_.limits = _loc6_.limits || [];
            _loc6_.limits.push(new UILimitInfo("available_sale_level",_loc5_ + 1));
         }
         this.ui_itemInfo.setItem(_loc2_.item,null,_loc6_);
      }
      
      private function onItemMouseOut(param1:MouseEvent) : void
      {
      }
      
      public function get storeItemList() : Vector.<StoreItem>
      {
         return this._fullList;
      }
      
      public function set storeItemList(param1:Vector.<StoreItem>) : void
      {
         this._fullList = param1;
         if(this._fullList != null)
         {
            this._itemList = this._fullList.concat();
         }
         this.createItems();
      }
      
      public function get itemInfo() : UIItemInfo
      {
         return this.ui_itemInfo;
      }
      
      public function get showCosts() : Boolean
      {
         return this._showCosts;
      }
      
      public function set showCosts(param1:Boolean) : void
      {
         this._showCosts = param1;
      }
   }
}

