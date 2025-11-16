package thelaststand.app.game.gui.lists
{
   import thelaststand.app.game.data.quests.Quest;
   
   public class UIAchievementList extends UIPagedList
   {
      
      public static const SORT_XP:String = "xp";
      
      public static const SORT_ALPHABETICAL:String = "alpha";
      
      private var _achievements:Vector.<Quest>;
      
      private var _sort:String;
      
      public function UIAchievementList()
      {
         super();
         _paddingX = _paddingY = 5;
         listItemClass = UIAchievementListItem;
         _itemWidth = 319;
         _itemHeight = 70;
         _displayOrder = UIPagedList.DISPLAY_ROW_FIRST;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:UIAchievementListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         this._achievements.sort(this.getSortAlgorithm());
         _items.length = 0;
         _selectedItem = null;
         var _loc2_:int = 2;
         var _loc3_:int = _pageHeight / _itemHeight;
         _loc4_ = _loc2_ * _loc3_ * Math.ceil(Math.max(this._achievements.length,1) / (_loc2_ * _loc3_));
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc1_ = new UIAchievementListItem();
            _loc6_ = _loc1_ as UIAchievementListItem;
            _loc6_.alternating = _loc5_ % _loc3_ % 2 == 0;
            if(_loc5_ < this._achievements.length)
            {
               _loc6_.achievement = this._achievements[_loc5_];
               _loc6_.id = this._achievements[_loc5_].id;
               _loc6_.mouseEnabled = true;
            }
            else
            {
               _loc6_.achievement = null;
               _loc6_.id = null;
               _loc6_.mouseEnabled = false;
            }
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc5_++;
         }
         super.createItems();
      }
      
      private function getSortAlgorithm() : Function
      {
         if(this._sort == SORT_ALPHABETICAL)
         {
            return this.achievementSortAlphabetical;
         }
         return this.achievementSortXP;
      }
      
      private function achievementSortXP(param1:Quest, param2:Quest) : int
      {
         var _loc3_:int = param1.getXPReward();
         var _loc4_:int = param2.getXPReward();
         var _loc5_:int = _loc3_ - _loc4_;
         if(_loc5_ == 0)
         {
            return param1.getName().toLowerCase().localeCompare(param2.getName().toLowerCase());
         }
         return _loc5_;
      }
      
      private function achievementSortAlphabetical(param1:Quest, param2:Quest) : int
      {
         return param1.getName().toLowerCase().localeCompare(param2.getName().toLowerCase());
      }
      
      public function get achievements() : Vector.<Quest>
      {
         return this._achievements;
      }
      
      public function set achievements(param1:Vector.<Quest>) : void
      {
         this._achievements = param1;
         this.createItems();
      }
      
      public function get sort() : String
      {
         return this._sort;
      }
      
      public function set sort(param1:String) : void
      {
         this._sort = param1;
         if(this._achievements != null && this._achievements.length > 0)
         {
            this.createItems();
         }
      }
   }
}

