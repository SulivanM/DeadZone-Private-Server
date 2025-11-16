package thelaststand.app.game.gui.lists
{
   import thelaststand.app.game.data.quests.Quest;
   
   public class UIQuestTaskList extends UIPagedList
   {
      
      private var _quests:Vector.<Quest>;
      
      public function UIQuestTaskList()
      {
         super();
         _paddingX = 3;
         _paddingY = 3;
         listItemClass = UIQuestTaskListItem;
         _itemWidth = 296;
         _itemHeight = 26;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._quests = null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc2_:int = 0;
         var _loc6_:UIQuestTaskListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         this._quests.sort(this.questSort);
         _items.length = 0;
         _selectedItem = null;
         _loc2_ = 1;
         var _loc3_:int = _pageHeight / _itemHeight;
         var _loc4_:int = _loc2_ * _loc3_ * Math.ceil(Math.max(this._quests.length,1) / (_loc2_ * _loc3_));
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc1_ = new UIQuestTaskListItem();
            _loc1_.clicked.add(onItemClicked);
            _loc6_ = _loc1_ as UIQuestTaskListItem;
            _loc6_.alternating = _loc5_ % 2 != 0;
            if(_loc5_ < this._quests.length)
            {
               _loc6_.quest = this._quests[_loc5_];
               _loc6_.id = this._quests[_loc5_].id;
               _loc6_.mouseEnabled = true;
            }
            else
            {
               _loc6_.quest = null;
               _loc6_.id = null;
               _loc6_.mouseEnabled = false;
            }
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc5_++;
         }
         super.createItems();
      }
      
      private function questSort(param1:Quest, param2:Quest) : int
      {
         if(param1.collected && !param2.collected)
         {
            return 1;
         }
         if(param2.collected && !param1.collected)
         {
            return -1;
         }
         if(param1.failed && !param2.failed)
         {
            return 1;
         }
         if(param2.failed && !param1.failed)
         {
            return -1;
         }
         if(param1.complete && !param2.complete)
         {
            return 1;
         }
         if(param2.complete && !param1.complete)
         {
            return -1;
         }
         var _loc3_:int = param1.level - param2.level;
         if(_loc3_ == 0)
         {
            return param1.getName().toLowerCase().localeCompare(param2.getName().toLowerCase());
         }
         return _loc3_;
      }
      
      public function get quests() : Vector.<Quest>
      {
         return this._quests;
      }
      
      public function set quests(param1:Vector.<Quest>) : void
      {
         this._quests = param1;
         this.createItems();
      }
   }
}

