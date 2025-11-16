package thelaststand.app.game.gui.lists
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.alliance.AllianceTask;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceMemberTaskContributionList extends UIPagedList
   {
      
      private var _lang:Language;
      
      private var _members:AllianceMemberList;
      
      private var _columns:Vector.<UIGenericSortedListHeader>;
      
      private var _columnSepartors:Vector.<UIListSeparator>;
      
      private var _sortProperty:String = "name";
      
      private var _sortDirection:int = -1;
      
      private var _selectedColumn:UIGenericSortedListHeader;
      
      private var _disposed:Boolean = false;
      
      private var _contributionObject:Object;
      
      private var busySpinner:UIBusySpinner;
      
      public var pageCountChange:Signal;
      
      public function UIAllianceMemberTaskContributionList()
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:UIGenericSortedListHeader = null;
         var _loc6_:UIListSeparator = null;
         this.pageCountChange = new Signal();
         super();
         this._lang = Language.getInstance();
         _paddingX = _paddingY = 2;
         _itemSpacingY = 1;
         _width = 720;
         _height = 242;
         listItemClass = UIAllianceMemberTaskContributionListItem;
         var _loc1_:Vector.<Object> = new <Object>[{
            "field":"name",
            "width":256
         },{
            "field":"task0",
            "width":112
         },{
            "field":"task1",
            "width":112
         },{
            "field":"task2",
            "width":112
         },{
            "field":"task3",
            "width":108
         }];
         this._columns = new Vector.<UIGenericSortedListHeader>();
         this._columnSepartors = new Vector.<UIListSeparator>();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_].field;
            _loc4_ = _loc3_ == "name" ? this._lang.getString("alliance.task_name_col") : "-";
            _loc5_ = new UIGenericSortedListHeader(_loc4_);
            _loc5_.addEventListener(MouseEvent.CLICK,this.onClickHeader,false,0,true);
            _loc5_.width = _loc1_[_loc2_].width;
            _loc5_.data = _loc1_[_loc2_].field;
            if(_loc5_.data == this._sortProperty)
            {
               _loc5_.dir = this._sortDirection;
               _loc5_.selected = true;
               this._selectedColumn = _loc5_;
            }
            addChild(_loc5_);
            this._columns.push(_loc5_);
            if(_loc3_)
            {
               _loc6_ = new UIListSeparator(_loc5_.height + 1);
               addChild(_loc6_);
               this._columnSepartors.push(_loc6_);
            }
            else
            {
               this._columnSepartors.push(null);
            }
            _loc2_++;
         }
         removeChild(_loc6_);
         this.busySpinner = new UIBusySpinner();
         this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
         this.busySpinner.x = _width * 0.5;
         this.busySpinner.y = _height * 0.5;
         addChild(this.busySpinner);
         this._members = AllianceSystem.getInstance().alliance.members;
         this._members.memberAdded.add(this.onMembersChanged);
         this._members.memberRemoved.add(this.onMembersChanged);
         this.updateTaskContributions();
         height = _height;
         width = _width;
         AllianceSystem.getInstance().roundStarted.add(this.updateTaskContributions);
         AllianceSystem.getInstance().contributedToTask.add(this.updateTaskContributions);
         this.updateHeaderLabels();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIGenericSortedListHeader = null;
         var _loc2_:UIListSeparator = null;
         this._disposed = true;
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         for each(_loc1_ in this._columns)
         {
            _loc1_.dispose();
         }
         for each(_loc2_ in this._columnSepartors)
         {
            if(_loc2_ != null)
            {
               _loc2_.dispose();
            }
         }
         if(this._members != null)
         {
            this._members.memberAdded.remove(this.onMembersChanged);
            this._members.memberRemoved.remove(this.onMembersChanged);
            this._members = null;
         }
         this.busySpinner.dispose();
         this._contributionObject = null;
         this._columns = null;
         this._columnSepartors = null;
         this._selectedColumn = null;
         this._lang = null;
         this.pageCountChange.removeAll();
         AllianceSystem.getInstance().roundStarted.remove(this.updateTaskContributions);
         AllianceSystem.getInstance().contributedToTask.remove(this.updateTaskContributions);
      }
      
      private function updateTaskContributions() : void
      {
         this._contributionObject = null;
         addChild(this.busySpinner);
         this.createItems();
         AllianceSystem.getInstance().getMemberContributionList(this.onContributionsLoaded);
      }
      
      private function onContributionsLoaded(param1:Object) : void
      {
         if(this._disposed)
         {
            return;
         }
         this._contributionObject = param1;
         if(this.busySpinner.parent)
         {
            this.busySpinner.parent.removeChild(this.busySpinner);
         }
         this.createItems();
      }
      
      private function updateHeaderLabels() : void
      {
         var _loc4_:AllianceTask = null;
         var _loc1_:uint = 1;
         var _loc2_:uint = uint(AllianceSystem.getInstance().alliance.numTasks);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = AllianceSystem.getInstance().alliance.getTask(_loc3_);
            this._columns[_loc1_ + _loc3_].label = _loc4_.getName().toUpperCase();
            _loc3_++;
         }
      }
      
      override protected function createItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UIAllianceMemberTaskContributionListItem = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         for each(_loc2_ in _items)
         {
            _loc2_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         if(this._members == null || this._members.numMembers == 0 || this._contributionObject == null)
         {
            this.pageCountChange.dispatch();
            return;
         }
         var _loc3_:Array = [];
         var _loc4_:int = getRowsPerPage();
         _loc1_ = 0;
         while(_loc1_ < this._members.numMembers)
         {
            _loc2_ = new UIAllianceMemberTaskContributionListItem();
            _loc2_.alternating = _loc1_ % 2 != 0;
            _loc2_.member = this._members.getMember(_loc1_);
            _loc2_.parseTaskContributions(_loc2_.member.id in this._contributionObject ? this._contributionObject[_loc2_.member.id] : null);
            _loc3_.push(_loc2_.member.id);
            mc_pageContainer.addChild(_loc2_);
            _items.push(_loc2_);
            _loc1_++;
         }
         for(_loc5_ in this._contributionObject)
         {
            if(_loc5_.toLowerCase() != "key")
            {
               if(this._members.getMemberById(_loc5_) == null)
               {
                  _loc2_ = new UIAllianceMemberTaskContributionListItem();
                  _loc2_.alternating = _loc1_ % 2 != 0;
                  _loc2_.member = new AllianceMember({
                     "id":_loc5_,
                     "nickname":"$formermember"
                  });
                  _loc2_.parseTaskContributions(this._contributionObject[_loc5_]);
                  mc_pageContainer.addChild(_loc2_);
                  _items.push(_loc2_);
                  _loc1_++;
               }
            }
         }
         _loc6_ = _loc4_ * Math.ceil(Math.max(_items.length,1) / _loc4_);
         while(_items.length < _loc6_)
         {
            _loc2_ = new UIAllianceMemberTaskContributionListItem();
            _loc2_.alternating = _loc1_ % 2 != 0;
            _loc2_.member = null;
            _loc2_.parseTaskContributions(null);
            mc_pageContainer.addChild(_loc2_);
            _items.push(_loc2_);
         }
         super.createItems();
         this.pageCountChange.dispatch();
         RemotePlayerManager.getInstance().getLoadPlayers(_loc3_,this.onRemotePlayersLoaded);
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
         var _loc12_:UIAllianceMemberTaskContributionListItem = null;
         _loc3_ = _paddingX;
         _loc4_ = _paddingY;
         _loc1_ = 0;
         _loc2_ = int(this._columns.length);
         while(_loc1_ < _loc2_)
         {
            _loc10_ = this._columns[_loc1_];
            _loc10_.x = _loc3_;
            _loc10_.y = _loc4_;
            _loc11_ = this._columnSepartors[_loc1_];
            if(_loc11_ != null)
            {
               _loc11_.x = _loc3_ + _loc10_.width;
               _loc11_.y = _loc4_;
               _loc3_ += _loc10_.width + _loc11_.width;
            }
            else
            {
               _loc3_ += _loc10_.width;
            }
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
            _loc12_ = _items[_loc1_] as UIAllianceMemberTaskContributionListItem;
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
      
      private function itemSort(param1:UIAllianceMemberTaskContributionListItem, param2:UIAllianceMemberTaskContributionListItem) : int
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
      
      private function getItemByMemberId(param1:String) : UIAllianceMemberTaskContributionListItem
      {
         var _loc3_:UIAllianceMemberTaskContributionListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            _loc3_ = UIAllianceMemberTaskContributionListItem(_items[_loc2_]);
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
         var _loc3_:UIAllianceMemberTaskContributionListItem = null;
         if(this._disposed)
         {
            return;
         }
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
      }
   }
}

