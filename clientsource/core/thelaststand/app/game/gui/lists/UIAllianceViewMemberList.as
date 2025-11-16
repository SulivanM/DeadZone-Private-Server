package thelaststand.app.game.gui.lists
{
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.game.gui.alliance.UIAllianceMemberPopupMenu;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceViewMemberList extends UIPagedList
   {
      
      private var _lang:Language;
      
      private var _members:AllianceMemberList;
      
      private var _columns:Vector.<UIGenericSortedListHeader>;
      
      private var _columnSepartors:Vector.<UIListSeparator>;
      
      private var _sortProperty:String = "attack";
      
      private var _sortDirection:int = -1;
      
      private var _selectedColumn:UIGenericSortedListHeader;
      
      private var _disposed:Boolean = false;
      
      private var ui_editPopup:UIAllianceMemberPopupMenu;
      
      private var _usersLoaded:Boolean = false;
      
      public var actioned:Signal;
      
      public function UIAllianceViewMemberList()
      {
         var _loc3_:String = null;
         var _loc4_:UIGenericSortedListHeader = null;
         var _loc5_:UIListSeparator = null;
         super();
         this.actioned = new Signal(RemotePlayerData,String);
         this._lang = Language.getInstance();
         _paddingX = _paddingY = 2;
         _itemSpacingY = 1;
         listItemClass = UIAllianceViewMemberListItem;
         var _loc1_:Vector.<Object> = new <Object>[{
            "field":"",
            "width":37
         },{
            "field":"online",
            "width":27
         },{
            "field":"level",
            "width":210
         },{
            "field":"",
            "width":96
         }];
         this._columns = new Vector.<UIGenericSortedListHeader>();
         this._columnSepartors = new Vector.<UIListSeparator>();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_].field == "" ? "" : this._lang.getString("alliance.opponentList_col_" + _loc1_[_loc2_].field);
            _loc4_ = new UIGenericSortedListHeader(_loc3_);
            _loc4_.addEventListener(MouseEvent.CLICK,this.onClickHeader,false,0,true);
            _loc4_.width = _loc1_[_loc2_].width;
            _loc4_.data = _loc1_[_loc2_].field;
            if(_loc1_[_loc2_].field == "")
            {
               _loc4_.visible = false;
            }
            TooltipManager.getInstance().add(_loc4_,this._lang.getString("alliance.opponentList_colTip_" + _loc1_[_loc2_].field),new Point(NaN,2),TooltipDirection.DIRECTION_DOWN);
            if(_loc4_.data == this._sortProperty)
            {
               _loc4_.dir = this._sortDirection;
               _loc4_.selected = true;
               this._selectedColumn = _loc4_;
            }
            _loc5_ = new UIListSeparator(_loc4_.height + 1);
            addChild(_loc4_);
            addChild(_loc5_);
            this._columns.push(_loc4_);
            this._columnSepartors.push(_loc5_);
            _loc2_++;
         }
         removeChild(_loc5_);
         removeChild(this._columnSepartors[0]);
         width = 385;
         height = 328;
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIGenericSortedListHeader = null;
         var _loc2_:UIListSeparator = null;
         this._disposed = true;
         this.actioned.removeAll();
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         for each(_loc1_ in this._columns)
         {
            _loc1_.dispose();
         }
         for each(_loc2_ in this._columnSepartors)
         {
            _loc2_.dispose();
         }
         if(this._members != null)
         {
            this._members.memberAdded.remove(this.onMembersChanged);
            this._members.memberRemoved.remove(this.onMembersChanged);
            this._members = null;
         }
         if(this.ui_editPopup)
         {
            this.ui_editPopup.dispose();
         }
         this._columns = null;
         this._columnSepartors = null;
         this._selectedColumn = null;
         this._lang = null;
      }
      
      public function writeDialogState() : void
      {
         var _loc1_:AllianceDialogState = AllianceDialogState.getInstance();
         _loc1_.sortProperty = this._sortProperty;
         _loc1_.sortDirection = this._sortDirection;
      }
      
      public function applyDialogState() : void
      {
         var _loc1_:AllianceDialogState = AllianceDialogState.getInstance();
         this._sortProperty = _loc1_.sortProperty == "" ? "attack" : _loc1_.sortProperty;
         this._sortDirection = _loc1_.sortDirection;
         this.positionItems();
      }
      
      override protected function createItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UIAllianceViewMemberListItem = null;
         var _loc6_:AllianceMember = null;
         for each(_loc2_ in _items)
         {
            _loc2_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         if(this._members == null || this._members.numMembers == 0)
         {
            return;
         }
         var _loc3_:Array = [];
         var _loc4_:int = getRowsPerPage();
         var _loc5_:int = _loc4_ * Math.ceil(Math.max(this._members.numMembers,1) / _loc4_);
         _loc1_ = 0;
         while(_loc1_ < _loc5_)
         {
            _loc2_ = new UIAllianceViewMemberListItem();
            _loc2_.alternating = _loc1_ % 2 != 0;
            _loc2_.actioned.add(this.onItemActioned);
            if(_loc1_ < this._members.numMembers)
            {
               _loc6_ = this._members.getMember(_loc1_);
               _loc2_.member = _loc6_;
               _loc3_.push(_loc6_.id);
            }
            else
            {
               _loc2_.member = null;
            }
            mc_pageContainer.addChild(_loc2_);
            _items.push(_loc2_);
            _loc1_++;
         }
         super.createItems();
         RemotePlayerManager.getInstance().getLoadPlayers(_loc3_,this.onRemotePlayersLoaded,RemotePlayerManager.STATE | RemotePlayerManager.SUMMARY);
      }
      
      override protected function positionItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:UIGenericSortedListHeader = null;
         var _loc11_:UIListSeparator = null;
         var _loc12_:UIAllianceViewMemberListItem = null;
         _loc3_ = _paddingX;
         _loc4_ = _paddingY;
         this._pageHeight;
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
            _loc3_ += _loc10_.width + _loc11_.width;
            _loc1_++;
         }
         var _loc5_:int = getColsPerPage();
         _loc6_ = getRowsPerPage();
         _numPages = Math.ceil(_items.length / (_loc5_ * _loc6_));
         _items.sort(this.itemSort);
         var _loc7_:int = _paddingY + this._columns[0].height + _itemSpacingY;
         _loc3_ = _paddingX;
         _loc4_ = _loc7_;
         _loc1_ = 0;
         _loc2_ = int(_items.length);
         while(_loc1_ < _loc2_)
         {
            _loc12_ = _items[_loc1_] as UIAllianceViewMemberListItem;
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
      
      private function itemSort(param1:UIAllianceViewMemberListItem, param2:UIAllianceViewMemberListItem) : int
      {
         if(param1.member == null)
         {
            return 1;
         }
         if(param2.member == null)
         {
            return -1;
         }
         var _loc3_:* = this._sortDirection > 0 ? param1.getSortValue(this._sortProperty) : param2.getSortValue(this._sortProperty);
         var _loc4_:* = this._sortDirection > 0 ? param2.getSortValue(this._sortProperty) : param1.getSortValue(this._sortProperty);
         if(_loc3_ is Number && !isNaN(Number(_loc3_)))
         {
            return Number(_loc3_) - Number(_loc4_);
         }
         if(_loc3_ is String)
         {
            return String(_loc3_).localeCompare(String(_loc4_));
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
      
      private function getItemByMemberId(param1:String) : UIAllianceViewMemberListItem
      {
         var _loc3_:UIAllianceViewMemberListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            _loc3_ = UIAllianceViewMemberListItem(_items[_loc2_]);
            if(_loc3_ != null && _loc3_.member.id == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function onClickHeader(param1:MouseEvent) : void
      {
         var _loc2_:UIGenericSortedListHeader = param1.currentTarget as UIGenericSortedListHeader;
         var _loc3_:Boolean = true;
         if(this._selectedColumn != _loc2_)
         {
            if(this._selectedColumn != null)
            {
               this._selectedColumn.selected = false;
            }
            this._selectedColumn = null;
            _loc3_ = false;
         }
         this._selectedColumn = _loc2_;
         this._selectedColumn.selected = true;
         this._sortProperty = _loc2_.data as String;
         if(_loc3_)
         {
            this._sortDirection = _loc2_.dir = _loc2_.dir == 1 ? -1 : 1;
         }
         this.positionItems();
      }
      
      private function onMembersChanged(param1:AllianceMember) : void
      {
         this.createItems();
      }
      
      private function onRemotePlayersLoaded(param1:Vector.<RemotePlayerData>) : void
      {
         var _loc2_:RemotePlayerData = null;
         var _loc3_:UIAllianceViewMemberListItem = null;
         if(this._disposed)
         {
            return;
         }
         this._usersLoaded = true;
         for each(_loc2_ in param1)
         {
            if(_loc2_ != null)
            {
               _loc3_ = this.getItemByMemberId(_loc2_.id);
               if(_loc3_ != null)
               {
                  _loc3_.remotePlayerData = _loc2_;
               }
            }
         }
         this.positionItems();
      }
      
      private function onItemActioned(param1:RemotePlayerData, param2:String) : void
      {
         this.actioned.dispatch(param1,param2);
      }
      
      public function get members() : AllianceMemberList
      {
         return this._members;
      }
      
      public function set members(param1:AllianceMemberList) : void
      {
         if(param1 == this._members)
         {
            return;
         }
         if(this._members != null)
         {
            this._members.memberAdded.remove(this.onMembersChanged);
            this._members.memberRemoved.remove(this.onMembersChanged);
         }
         this._members = param1;
         this._members.memberAdded.add(this.onMembersChanged);
         this._members.memberRemoved.add(this.onMembersChanged);
         this.createItems();
      }
   }
}

