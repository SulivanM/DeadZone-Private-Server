package thelaststand.app.game.gui.lists
{
   import flash.display.Sprite;
   import thelaststand.app.data.NewsArticle;
   
   public class UIContentList extends UIPagedList
   {
      
      private var _content:Vector.<Sprite>;
      
      public function UIContentList(param1:int, param2:int)
      {
         super();
         _paddingX = _paddingY = 0;
         listItemClass = UIPagedListItem;
         _itemWidth = param1;
         _itemHeight = param2;
      }
      
      override public function dispose() : void
      {
         this._content = null;
         super.dispose();
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc2_:int = 0;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         _loc2_ = 0;
         while(_loc2_ < this._content.length)
         {
            _loc1_ = new UIPagedListItem();
            _loc1_.mouseEnabled = _loc1_.mouseChildren = false;
            _loc1_.addChild(this._content[_loc2_]);
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
      
      public function get content() : Vector.<Sprite>
      {
         return this._content;
      }
      
      public function set content(param1:Vector.<Sprite>) : void
      {
         this._content = param1;
         this.createItems();
      }
   }
}

