package thelaststand.app.game.gui.lists
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.gui.UIPageContainer;
   
   public class UIPagedList extends UIPageContainer
   {
      
      protected static const DISPLAY_ROW_FIRST:String = "rowFirst";
      
      protected static const DISPLAY_COL_FIRST:String = "colFirst";
      
      private var _listItemClass:Class;
      
      private var _allowSelection:Boolean = true;
      
      protected var _items:Vector.<UIPagedListItem>;
      
      protected var _itemWidth:int = 82;
      
      protected var _itemHeight:int = 115;
      
      protected var _selectedItem:UIPagedListItem;
      
      protected var _itemSpacingX:int = 0;
      
      protected var _itemSpacingY:int = 0;
      
      protected var _displayOrder:String = "colFirst";
      
      public var changed:Signal;
      
      public function UIPagedList()
      {
         super();
         _paddingX = 10;
         _paddingY = 10;
         this._items = new Vector.<UIPagedListItem>();
         this.changed = new Signal();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIPagedListItem = null;
         super.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.changed.removeAll();
         this._selectedItem = null;
         this._listItemClass = null;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
      }
      
      public function getItem(param1:int) : UIPagedListItem
      {
         if(param1 < 0 || param1 >= this._items.length)
         {
            return null;
         }
         return this._items[param1];
      }
      
      public function selectItem(param1:int) : void
      {
         var _loc2_:UIPagedListItem = null;
         if(param1 >= 0)
         {
            if(this._items.length == 0)
            {
               return;
            }
            if(param1 >= this._items.length)
            {
               param1 = int(this._items.length - 1);
            }
            _loc2_ = this._items[param1];
         }
         if(this._selectedItem != null)
         {
            this._selectedItem.selected = false;
            this._selectedItem = null;
         }
         if(_loc2_ != null)
         {
            this._selectedItem = _loc2_;
            this._selectedItem.selected = this._allowSelection;
         }
      }
      
      public function selectItemById(param1:String) : Boolean
      {
         var _loc2_:UIPagedListItem = null;
         var _loc3_:UIPagedListItem = null;
         if(this._selectedItem != null && this._selectedItem.id == param1)
         {
            return true;
         }
         for each(_loc3_ in this._items)
         {
            if(_loc3_.id == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(this._selectedItem != _loc2_ && this._selectedItem != null)
         {
            this._selectedItem.selected = false;
            this._selectedItem = null;
         }
         if(_loc2_ != null)
         {
            this._selectedItem = _loc2_;
            this._selectedItem.selected = this._allowSelection;
         }
         return this._selectedItem != null;
      }
      
      public function getSelectedItemPage() : int
      {
         if(this._selectedItem == null)
         {
            return 0;
         }
         var _loc1_:int = int(this._items.indexOf(this._selectedItem));
         var _loc2_:int = Math.max(Math.floor(_pageWidth / this._itemWidth),1);
         var _loc3_:int = Math.floor(_pageHeight / this._itemHeight);
         return Math.floor(_loc1_ / (_loc2_ * _loc3_));
      }
      
      protected function createItems() : void
      {
         this.positionItems();
      }
      
      protected function getColsPerPage() : int
      {
         var _loc1_:int = this._itemSpacingX <= 0 ? 0 : this._itemSpacingX;
         var _loc2_:int = this._itemWidth + _loc1_;
         return Math.max(Math.floor((_pageWidth + _loc1_) / _loc2_),1);
      }
      
      protected function getRowsPerPage() : int
      {
         var _loc1_:int = this._itemSpacingY <= 0 ? 0 : this._itemSpacingY;
         var _loc2_:int = this._itemHeight + _loc1_;
         return Math.max(Math.floor((_pageHeight + _loc1_) / _loc2_),1);
      }
      
      protected function positionItems() : void
      {
         if(this._displayOrder == DISPLAY_ROW_FIRST)
         {
            this.positionItemsRowFirst();
         }
         else
         {
            this.positionItemsColFirst();
         }
         super.gotoPage(_currentPage,false);
      }
      
      protected function positionItemsColFirst() : void
      {
         var _loc1_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:UIPagedListItem = null;
         _loc1_ = this.getColsPerPage();
         var _loc2_:int = this.getRowsPerPage();
         _numPages = Math.ceil(this._items.length / (_loc1_ * _loc2_));
         var _loc3_:int = this._itemSpacingX == 0 ? int(Math.round((_pageWidth - this._itemWidth * _loc1_) / (_loc1_ - 1))) : this._itemSpacingX;
         var _loc4_:int = this._itemSpacingY == 0 ? int(Math.round((_pageHeight - this._itemHeight * _loc2_) / (_loc2_ - 1))) : this._itemSpacingY;
         var _loc8_:int = _paddingX;
         var _loc9_:int = _paddingY;
         var _loc10_:int = 0;
         var _loc11_:int = int(this._items.length);
         while(_loc10_ < _loc11_)
         {
            _loc12_ = this._items[_loc10_];
            _loc12_.x = _loc8_;
            _loc12_.y = _loc9_;
            if(++_loc6_ == _loc1_)
            {
               if(++_loc5_ >= _loc2_)
               {
                  _loc7_++;
                  _loc6_ = 0;
                  _loc5_ = 0;
                  _loc8_ = _paddingX + (_pageWidth + _paddingX * 2) * _loc7_;
                  _loc9_ = _paddingY;
               }
               else
               {
                  _loc6_ = 0;
                  _loc8_ = _paddingX + (_pageWidth + _paddingX * 2) * _loc7_;
                  _loc9_ += _loc12_.height + _loc4_;
               }
            }
            else
            {
               _loc8_ += _loc12_.width + _loc3_;
            }
            _loc10_++;
         }
      }
      
      protected function positionItemsRowFirst() : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:UIPagedListItem = null;
         var _loc1_:int = this.getColsPerPage();
         var _loc2_:int = this.getRowsPerPage();
         _numPages = Math.ceil(this._items.length / (_loc1_ * _loc2_));
         var _loc3_:int = this._itemSpacingX == 0 ? int(Math.round((_pageWidth - this._itemWidth * _loc1_) / (_loc1_ - 1))) : this._itemSpacingX;
         var _loc4_:int = this._itemSpacingY == 0 ? int(Math.round((_pageHeight - this._itemHeight * _loc2_) / (_loc2_ - 1))) : this._itemSpacingY;
         var _loc8_:int = _paddingX;
         var _loc9_:int = _paddingY;
         var _loc10_:int = 0;
         var _loc11_:int = int(this._items.length);
         while(_loc10_ < _loc11_)
         {
            _loc12_ = this._items[_loc10_];
            _loc12_.x = _loc8_;
            _loc12_.y = _loc9_;
            if(++_loc5_ == _loc2_)
            {
               if(++_loc6_ >= _loc1_)
               {
                  _loc7_++;
                  _loc6_ = 0;
                  _loc5_ = 0;
                  _loc8_ = _paddingX + (_pageWidth + _paddingX * 2) * _loc7_;
                  _loc9_ = _paddingY;
               }
               else
               {
                  _loc5_ = 0;
                  _loc8_ += _loc12_.width + _loc3_;
                  _loc9_ = _paddingY;
               }
            }
            else
            {
               _loc9_ += _loc12_.height + _loc4_;
            }
            _loc10_++;
         }
      }
      
      override protected function draw() : void
      {
         super.draw();
         this.positionItems();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.positionItems();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      protected function onItemClicked(param1:MouseEvent) : void
      {
         var _loc2_:UIPagedListItem = param1.currentTarget as UIPagedListItem;
         if(this._allowSelection && _loc2_ == this._selectedItem)
         {
            return;
         }
         if(_loc2_ != this._selectedItem)
         {
            if(this._selectedItem != null)
            {
               this._selectedItem.selected = false;
               this._selectedItem = null;
            }
            this._selectedItem = _loc2_;
            this._selectedItem.selected = this._allowSelection;
         }
         this.changed.dispatch();
      }
      
      public function get currentPage() : int
      {
         return _currentPage;
      }
      
      public function get listItemClass() : Class
      {
         return this._listItemClass;
      }
      
      public function set listItemClass(param1:Class) : void
      {
         this._listItemClass = param1;
         var _loc2_:UIPagedListItem = new this._listItemClass();
         this._itemWidth = _loc2_.width;
         this._itemHeight = _loc2_.height;
         _loc2_.dispose();
      }
      
      public function get itemHeight() : int
      {
         return this._itemHeight;
      }
      
      public function get itemWidth() : int
      {
         return this._itemWidth;
      }
      
      public function get numItems() : int
      {
         return this._items.length;
      }
      
      public function get numPages() : int
      {
         return _numPages;
      }
      
      public function get selectedItem() : UIPagedListItem
      {
         return this._selectedItem;
      }
      
      public function get selectedIndex() : int
      {
         return this._selectedItem != null ? int(this._items.indexOf(this._selectedItem)) : -1;
      }
      
      override public function get width() : Number
      {
         return _width;
      }
      
      override public function set width(param1:Number) : void
      {
         _width = param1;
         _pageWidth = int(_width - _paddingX * 2);
         if(stage)
         {
            this.positionItems();
         }
         super.width = _width;
      }
      
      override public function get height() : Number
      {
         return _height;
      }
      
      override public function set height(param1:Number) : void
      {
         _height = param1;
         _pageHeight = int(_height - _paddingY * 2);
         if(stage)
         {
            this.positionItems();
         }
         super.height = _height;
      }
      
      public function get allowSelection() : Boolean
      {
         return this._allowSelection;
      }
      
      public function set allowSelection(param1:Boolean) : void
      {
         this._allowSelection = param1;
      }
   }
}

