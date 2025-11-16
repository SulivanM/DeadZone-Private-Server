package thelaststand.app.game.gui.lists
{
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceList;
   import thelaststand.app.game.gui.dialogues.AllianceOpponentMemberListDialogue;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceEnemyList extends UIPagedList
   {
      
      private var _header:UIGenericListHeader;
      
      private var _allianceList:AllianceList;
      
      private var _launchEnabled:Boolean = true;
      
      public function UIAllianceEnemyList()
      {
         super();
         _paddingX = _paddingY = 2;
         _itemSpacingY = 1;
         this._header = new UIGenericListHeader(Language.getInstance().getString("alliance.members_col_enemies"),36);
         this._header.y = _paddingY;
         addChild(this._header);
         listItemClass = UIAllianceEnemyListItem;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this);
         this._header.dispose();
         if(this._allianceList != null)
         {
            this._allianceList.changed.remove(this.onListChanged);
            this._allianceList = null;
         }
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIAllianceEnemyListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         if(this._allianceList == null || this._allianceList.numAlliances == 0)
         {
            return;
         }
         var _loc2_:int = getRowsPerPage();
         var _loc3_:int = _loc2_ * Math.ceil(Math.max(this._allianceList.numAlliances,1) / _loc2_);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_ = new UIAllianceEnemyListItem();
            if(_loc4_ < this._allianceList.numAlliances)
            {
               _loc1_.alliance = this._allianceList.getAlliance(_loc4_);
               _loc1_.triggered.add(this.onItemTriggered);
            }
            _loc1_.launchEnabled = this._launchEnabled;
            _items.push(_loc1_);
            mc_pageContainer.addChild(_loc1_);
            _loc4_++;
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
         var _loc10_:UIAllianceEnemyListItem = null;
         _loc3_ = _paddingX;
         _loc4_ = _paddingY;
         this._header.x = _loc3_;
         this._header.width = int(_width - _loc3_ * 2);
         var _loc5_:int = getColsPerPage();
         var _loc6_:int = getRowsPerPage();
         _numPages = Math.ceil(_items.length / (_loc5_ * _loc6_));
         var _loc7_:int = _paddingY + this._header.height + _itemSpacingY;
         _loc3_ = _paddingX;
         _loc4_ = _loc7_;
         _loc1_ = 0;
         _loc2_ = int(_items.length);
         while(_loc1_ < _loc2_)
         {
            _loc10_ = UIAllianceEnemyListItem(_items[_loc1_]);
            _loc10_.x = _loc3_;
            _loc10_.y = _loc4_;
            _loc10_.alternating = _loc8_ % 2 == 0;
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
               _loc4_ += _loc10_.height + _itemSpacingY;
            }
            _loc1_++;
         }
         super.gotoPage(_currentPage,false);
      }
      
      private function onListChanged() : void
      {
         this.positionItems();
      }
      
      private function onItemTriggered(param1:UIAllianceEnemyListItem) : void
      {
         if(!this._launchEnabled)
         {
            return;
         }
         var _loc2_:AllianceDataSummary = param1.alliance;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:AllianceOpponentMemberListDialogue = new AllianceOpponentMemberListDialogue(_loc2_.id,_loc2_.name,_loc2_.tag);
         _loc3_.open();
      }
      
      public function get allianceList() : AllianceList
      {
         return this._allianceList;
      }
      
      public function set allianceList(param1:AllianceList) : void
      {
         if(param1 == this._allianceList)
         {
            return;
         }
         if(this._allianceList != null)
         {
            this._allianceList.changed.remove(this.onListChanged);
         }
         this._allianceList = param1;
         this.createItems();
         if(this._allianceList != null)
         {
            this._allianceList.changed.add(this.onListChanged);
         }
      }
      
      public function get launchEnabled() : Boolean
      {
         return this._launchEnabled;
      }
      
      public function set launchEnabled(param1:Boolean) : void
      {
         var _loc2_:UIAllianceEnemyListItem = null;
         this._launchEnabled = param1;
         for each(_loc2_ in _items)
         {
            _loc2_.launchEnabled = this._launchEnabled;
         }
      }
   }
}

