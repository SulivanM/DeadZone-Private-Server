package thelaststand.app.game.gui.lists
{
   import thelaststand.app.data.NewsArticle;
   
   public class UINewsList extends UIPagedList
   {
      
      private var _articles:Vector.<NewsArticle>;
      
      public function UINewsList()
      {
         var _loc1_:UINewsListItem = null;
         super();
         _paddingX = _paddingY = 0;
         listItemClass = UINewsListItem;
         _loc1_ = new UINewsListItem();
         _itemWidth = _loc1_.width;
         _itemHeight = _loc1_.height;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc2_:int = 0;
         var _loc3_:UINewsListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         this._articles.sort(this.sortByDate);
         _items.length = 0;
         _selectedItem = null;
         _loc2_ = 0;
         while(_loc2_ < this._articles.length)
         {
            _loc1_ = new listItemClass();
            _loc3_ = _loc1_ as UINewsListItem;
            _loc3_.article = this._articles[_loc2_];
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc2_++;
         }
         super.createItems();
      }
      
      private function sortByDate(param1:NewsArticle, param2:NewsArticle) : int
      {
         if(param1.date.time < param2.date.time)
         {
            return 1;
         }
         if(param2.date.time < param1.date.time)
         {
            return -1;
         }
         return 0;
      }
      
      public function get articles() : Vector.<NewsArticle>
      {
         return this._articles;
      }
      
      public function set articles(param1:Vector.<NewsArticle>) : void
      {
         this._articles = param1.concat();
         this.createItems();
      }
   }
}

