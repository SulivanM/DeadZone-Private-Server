package thelaststand.app.game.gui.lists
{
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.network.Network;
   
   public class UISurvivorList extends UIPagedList
   {
      
      private var _showLoadout:Boolean;
      
      private var _showMorale:Boolean = true;
      
      private var _showInjuries:Boolean = true;
      
      private var _survivorList:Vector.<Survivor>;
      
      private var _loadoutType:String = "offence";
      
      public function UISurvivorList(param1:Boolean = true)
      {
         super();
         _paddingX = 3;
         _paddingY = 3;
         _itemSpacingY = 1;
         this._showLoadout = param1;
         listItemClass = UISurvivorListItem;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._survivorList = null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc4_:int = 0;
         var _loc5_:UISurvivorListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         this._survivorList.sort(this.survivorSort);
         var _loc2_:int = _pageHeight / _itemHeight;
         var _loc3_:int = _loc2_ * Math.ceil(Math.max(this._survivorList.length,1) / _loc2_);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc4_ < this._survivorList.length)
            {
               if(this._survivorList[_loc4_] == null)
               {
                  _loc1_ = new UISurvivorListNoneItem();
               }
               else
               {
                  _loc1_ = new UISurvivorListItem(this._showLoadout);
                  _loc1_.width = _width - _paddingX * 2;
                  _loc5_ = UISurvivorListItem(_loc1_);
                  _loc5_.showInjuries = this._showInjuries;
                  _loc5_.showMorale = this._showMorale;
                  _loc5_.showLoadout = this._showLoadout;
                  _loc5_.loadoutType = this._loadoutType;
                  _loc5_.survivor = this._survivorList[_loc4_];
               }
               _loc1_.clicked.add(onItemClicked);
            }
            else
            {
               _loc1_ = new UISurvivorListItem(this._showLoadout);
               _loc1_.width = _width - _paddingX * 2;
            }
            _loc1_["alternating"] = _loc4_ % 2 != 0;
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc4_++;
         }
         super.createItems();
      }
      
      private function survivorSort(param1:Survivor, param2:Survivor) : int
      {
         if(param1 == null)
         {
            return -1;
         }
         if(param2 == null)
         {
            return 1;
         }
         var _loc3_:Survivor = Network.getInstance().playerData.getPlayerSurvivor();
         if(param1 == _loc3_)
         {
            return -1;
         }
         if(param2 == _loc3_)
         {
            return 1;
         }
         var _loc4_:int = int(param1.classId.localeCompare(param2.classId));
         if(_loc4_ == 0)
         {
            _loc4_ = int(param1.fullName.localeCompare(param2.fullName));
         }
         return _loc4_;
      }
      
      public function get showMorale() : Boolean
      {
         return this._showMorale;
      }
      
      public function set showMorale(param1:Boolean) : void
      {
         this._showMorale = param1;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            UISurvivorListItem(_items[_loc2_]).showMorale = this._showMorale;
            _loc2_++;
         }
      }
      
      public function get showInjuries() : Boolean
      {
         return this._showInjuries;
      }
      
      public function set showInjuries(param1:Boolean) : void
      {
         this._showInjuries = param1;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            UISurvivorListItem(_items[_loc2_]).showInjuries = this._showLoadout;
            _loc2_++;
         }
      }
      
      public function get showLoadout() : Boolean
      {
         return this._showLoadout;
      }
      
      public function set showLoadout(param1:Boolean) : void
      {
         this._showLoadout = param1;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            UISurvivorListItem(_items[_loc2_]).showLoadout = this._showLoadout;
            _loc2_++;
         }
      }
      
      public function get survivorList() : Vector.<Survivor>
      {
         return this._survivorList;
      }
      
      public function set survivorList(param1:Vector.<Survivor>) : void
      {
         this._survivorList = param1;
         this.createItems();
         if(this._showLoadout && UISurvivorListItem(_items[0]).survivor != null)
         {
            _items[0].selected = true;
            _selectedItem = _items[0];
            changed.dispatch();
         }
      }
      
      public function get loadoutType() : String
      {
         return this._loadoutType;
      }
      
      public function set loadoutType(param1:String) : void
      {
         this._loadoutType = param1;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            UISurvivorListItem(_items[_loc2_]).loadoutType = this._loadoutType;
            _loc2_++;
         }
      }
   }
}

