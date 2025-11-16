package thelaststand.app.game.gui.lists
{
   public class UIInventoryCategoryList extends UIPagedList
   {
      
      private var _categories:Vector.<Object>;
      
      public function UIInventoryCategoryList()
      {
         super();
         _paddingX = _paddingY = 3;
         _itemSpacingX = 0;
         _itemSpacingY = 0;
         listItemClass = UIInventoryCategoryListItem;
      }
      
      public function get categories() : Vector.<Object>
      {
         return this._categories;
      }
      
      public function set categories(param1:Vector.<Object>) : void
      {
         this._categories = param1;
         this.createItems();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._categories = null;
      }
      
      public function getItemByCategory(param1:String) : UIInventoryCategoryListItem
      {
         var _loc2_:UIInventoryCategoryListItem = null;
         for each(_loc2_ in _items)
         {
            if(_loc2_.category == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:UIInventoryCategoryListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         var _loc2_:int = 1;
         var _loc3_:int = _pageHeight / _itemHeight;
         var _loc4_:int = 0;
         _loc5_ = int(this._categories.length);
         while(_loc4_ < _loc5_)
         {
            _loc1_ = new UIInventoryCategoryListItem();
            _loc1_.clicked.add(onItemClicked);
            _loc6_ = this._categories[_loc4_];
            _loc7_ = UIInventoryCategoryListItem(_loc1_);
            _loc7_.width = _pageWidth;
            _loc7_.alternating = _loc4_ % 2 != 0;
            _loc7_.id = _loc7_.category = _loc6_.data;
            _loc7_.label = _loc6_.label;
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc4_++;
         }
         super.createItems();
      }
   }
}

