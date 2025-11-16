package thelaststand.app.game.gui.lists
{
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.common.lang.Language;
   
   public class UINeighborhoodList extends UIPagedList
   {
      
      private var _columns:Vector.<UIGenericSortedListHeader>;
      
      private var _columnSepartors:Vector.<UIListSeparator>;
      
      private var _filterProperty:String = "level";
      
      private var _filterDirection:int = -1;
      
      private var _selectedColumn:UIGenericSortedListHeader;
      
      private var _neighbors:Vector.<RemotePlayerData>;
      
      private var _masterList:Vector.<UIPagedListItem>;
      
      private var _stringFilter:String = "";
      
      public var actioned:Signal;
      
      public var filtered:Signal;
      
      public function UINeighborhoodList()
      {
         var _loc3_:UIGenericSortedListHeader = null;
         var _loc4_:UIListSeparator = null;
         super();
         this._neighbors = RemotePlayerManager.getInstance().neighbors;
         this._masterList = new Vector.<UIPagedListItem>();
         this.actioned = new Signal(RemotePlayerData,String);
         this.filtered = new Signal(String,Boolean);
         _paddingX = _paddingY = 2;
         _itemSpacingY = 1;
         var _loc1_:Vector.<Object> = Vector.<Object>([{
            "field":"online",
            "width":38
         },{
            "field":"level",
            "width":216
         },{
            "field":"relationship",
            "width":86
         },{
            "field":"battles",
            "width":84
         }]);
         this._columns = new Vector.<UIGenericSortedListHeader>();
         this._columnSepartors = new Vector.<UIListSeparator>();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = new UIGenericSortedListHeader();
            _loc3_.addEventListener(MouseEvent.CLICK,this.onClickHeader,false,0,true);
            _loc3_.width = _loc1_[_loc2_].width;
            _loc3_.data = _loc1_[_loc2_].field;
            TooltipManager.getInstance().add(_loc3_,Language.getInstance().getString("map_list_sort_" + _loc3_.data),new Point(NaN,2),TooltipDirection.DIRECTION_DOWN);
            if(_loc3_.data == this._filterProperty)
            {
               _loc3_.dir = this._filterDirection;
               _loc3_.selected = true;
               this._selectedColumn = _loc3_;
            }
            _loc4_ = new UIListSeparator(_loc3_.height + 1);
            addChild(_loc3_);
            addChild(_loc4_);
            this._columns.push(_loc3_);
            this._columnSepartors.push(_loc4_);
            _loc2_++;
         }
         listItemClass = UINeighborhoodListItem;
         this.createItems();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIGenericSortedListHeader = null;
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         for each(_loc1_ in this._columns)
         {
            _loc1_.dispose();
         }
         this._columns = null;
         this._masterList = null;
         this._columnSepartors = null;
         this._selectedColumn = null;
         this.actioned.removeAll();
         this.filtered.removeAll();
      }
      
      public function setStringFilter(param1:String) : void
      {
         var _loc4_:UINeighborhoodListItem = null;
         this._stringFilter = param1.toLowerCase().replace(/^\s+|\s+$/ig,"");
         _items.length = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._masterList.length)
         {
            _loc4_ = this._masterList[_loc2_] as UINeighborhoodListItem;
            if(param1 == "" || _loc4_.neighbor.nickname.toLowerCase().indexOf(this._stringFilter) > -1 || _loc4_.neighbor.allianceTag.toLowerCase().indexOf(this._stringFilter) > -1)
            {
               _loc4_.visible = true;
               _items.push(_loc4_);
            }
            else
            {
               _loc4_.visible = false;
            }
            _loc2_++;
         }
         var _loc3_:int = _numPages;
         this.positionItems();
         if(_numPages != _loc3_)
         {
            gotoPage(0,false);
         }
         this.filtered.dispatch(this._filterProperty,true);
      }
      
      override protected function createItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UINeighborhoodListItem = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for each(_loc2_ in _items)
         {
            _loc2_.dispose();
         }
         this._masterList.length = 0;
         _items.length = 0;
         _selectedItem = null;
         _loc3_ = getRowsPerPage();
         _loc4_ = _loc3_ * Math.ceil(Math.max(this._neighbors.length,1) / _loc3_);
         _loc1_ = 0;
         while(_loc1_ < _loc4_)
         {
            _loc2_ = new UINeighborhoodListItem();
            _loc2_.alternating = _loc1_ % 2 != 0;
            if(_loc1_ < this._neighbors.length)
            {
               _loc2_.neighbor = this._neighbors[_loc1_];
               _loc2_.actioned.add(this.onItemActioned);
            }
            mc_pageContainer.addChild(_loc2_);
            this._masterList.push(_loc2_);
            _items.push(_loc2_);
            _loc1_++;
         }
         super.createItems();
      }
      
      override protected function positionItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:UIGenericSortedListHeader = null;
         var _loc11_:UIListSeparator = null;
         var _loc12_:UINeighborhoodListItem = null;
         _loc3_ = _paddingX + 64;
         _loc4_ = _paddingY;
         _loc1_ = 0;
         _loc2_ = int(this._columns.length);
         while(_loc1_ < _loc2_)
         {
            _loc10_ = this._columns[_loc1_];
            _loc11_ = this._columnSepartors[_loc1_];
            _loc10_.x = _loc3_;
            _loc10_.y = _loc4_;
            _loc11_.x = _loc3_ + _loc10_.width;
            _loc11_.y = _loc4_;
            _loc3_ += _loc10_.width + 4;
            _loc1_++;
         }
         var _loc5_:int = getColsPerPage();
         var _loc6_:int = getRowsPerPage();
         _numPages = Math.ceil(_items.length / (_loc5_ * _loc6_));
         _items.sort(this.itemSort);
         var _loc7_:int = _paddingY + this._columns[0].height + _itemSpacingY;
         _loc3_ = _paddingX;
         _loc4_ = _loc7_;
         _loc1_ = 0;
         _loc2_ = int(_items.length);
         while(_loc1_ < _loc2_)
         {
            _loc12_ = _items[_loc1_] as UINeighborhoodListItem;
            _loc12_.x = _loc3_;
            _loc12_.y = _loc4_;
            _loc12_.alternating = _loc8_ % 2 == 0;
            if(++_loc8_ >= _loc6_)
            {
               _loc9_++;
               _loc8_ = 0;
               _loc3_ = _paddingX + (_pageWidth + _paddingX * 2) * _loc9_;
               _loc4_ = _loc7_;
            }
            else
            {
               _loc3_ = _paddingX + (_pageWidth + _paddingX * 2) * _loc9_;
               _loc4_ += _loc12_.height + _itemSpacingY;
            }
            _loc1_++;
         }
         super.gotoPage(_currentPage,false);
      }
      
      private function itemSort(param1:UINeighborhoodListItem, param2:UINeighborhoodListItem) : int
      {
         if(param1.neighbor == null)
         {
            return 1;
         }
         if(param2.neighbor == null)
         {
            return -1;
         }
         var _loc3_:* = this._filterDirection > 0 ? param1.neighbor[this._filterProperty] : param2.neighbor[this._filterProperty];
         var _loc4_:* = this._filterDirection > 0 ? param2.neighbor[this._filterProperty] : param1.neighbor[this._filterProperty];
         if(_loc3_ is String)
         {
            return String(_loc3_).localeCompare(String(_loc4_));
         }
         if(_loc3_ is Number)
         {
            return Number(_loc3_) - Number(_loc4_);
         }
         if(_loc3_ is Boolean)
         {
            if(_loc3_ == _loc4_)
            {
               return 0;
            }
            if(_loc3_ && !_loc4_)
            {
               return 1;
            }
            if(!_loc3_ && _loc4_)
            {
               return -1;
            }
         }
         return 0;
      }
      
      private function onClickHeader(param1:MouseEvent) : void
      {
         var _loc2_:UIGenericSortedListHeader = param1.currentTarget as UIGenericSortedListHeader;
         if(this._selectedColumn != _loc2_)
         {
            if(this._selectedColumn != null)
            {
               this._selectedColumn.selected = false;
            }
            this._selectedColumn = null;
         }
         this._selectedColumn = _loc2_;
         this._selectedColumn.selected = true;
         this._filterProperty = _loc2_.data as String;
         this._filterDirection = _loc2_.dir = _loc2_.dir == 1 ? -1 : 1;
         this.positionItems();
         this.filtered.dispatch(this._filterProperty,false);
      }
      
      private function onItemActioned(param1:RemotePlayerData, param2:String) : void
      {
         this.actioned.dispatch(param1,param2);
      }
   }
}

