package thelaststand.app.game.gui.lists
{
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.display.Effects;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.UIAllianceMemberPopupMenu;
   import thelaststand.app.game.gui.dialogues.AllianceRankDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceMemberList extends UIPagedList
   {
      
      private var _lang:Language;
      
      private var _members:AllianceMemberList;
      
      private var _columns:Vector.<UIGenericSortedListHeader>;
      
      private var _columnSepartors:Vector.<UIListSeparator>;
      
      private var _sortProperty:String = "rank";
      
      private var _sortDirection:int = -1;
      
      private var _selectedColumn:UIGenericSortedListHeader;
      
      private var _disposed:Boolean = false;
      
      private var ui_editPopup:UIAllianceMemberPopupMenu;
      
      public function UIAllianceMemberList()
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:UIGenericSortedListHeader = null;
         var _loc6_:UIListSeparator = null;
         super();
         this._lang = Language.getInstance();
         _paddingX = _paddingY = 2;
         _itemSpacingY = 1;
         listItemClass = UIAllianceMemberListItem;
         var _loc1_:Vector.<Object> = new <Object>[{
            "field":"",
            "width":40
         },{
            "field":"online",
            "width":40
         },{
            "field":"level",
            "width":361
         },{
            "field":"rank",
            "width":120
         },{
            "field":"lastLogin",
            "width":145
         }];
         this._columns = new Vector.<UIGenericSortedListHeader>();
         this._columnSepartors = new Vector.<UIListSeparator>();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_].field;
            _loc4_ = !(_loc3_ == "" || _loc3_ == "online") ? this._lang.getString("alliance.members_col_" + _loc1_[_loc2_].field) : "";
            _loc5_ = new UIGenericSortedListHeader(_loc4_);
            _loc5_.addEventListener(MouseEvent.CLICK,this.onClickHeader,false,0,true);
            _loc5_.width = _loc1_[_loc2_].width;
            _loc5_.data = _loc1_[_loc2_].field;
            if(!_loc3_)
            {
               _loc5_.visible = false;
            }
            TooltipManager.getInstance().add(_loc5_,this._lang.getString("alliance.members_colTip_" + _loc1_[_loc2_].field),new Point(NaN,2),TooltipDirection.DIRECTION_DOWN);
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
         AllianceSystem.getInstance().alliance.members.memberRankChanged.add(this.onMemberRankChanged);
      }
      
      override public function dispose() : void
      {
         var _loc2_:UIGenericSortedListHeader = null;
         var _loc3_:UIListSeparator = null;
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         var _loc1_:AllianceData = AllianceSystem.getInstance().alliance;
         if(Boolean(_loc1_) && Boolean(_loc1_.members))
         {
            AllianceSystem.getInstance().alliance.members.memberRankChanged.remove(this.onMemberRankChanged);
         }
         for each(_loc2_ in this._columns)
         {
            _loc2_.dispose();
         }
         for each(_loc3_ in this._columnSepartors)
         {
            if(_loc3_ != null)
            {
               _loc3_.dispose();
            }
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
      
      public function refreshAllRanks() : void
      {
         var _loc1_:UIAllianceMemberListItem = null;
         for each(_loc1_ in _items)
         {
            if(_loc1_ != null)
            {
               _loc1_.refreshRank();
            }
         }
      }
      
      private function onMemberRankChanged(param1:AllianceMember) : void
      {
         if(param1.id == Network.getInstance().playerData.id)
         {
            this.createItems();
         }
      }
      
      override protected function createItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UIAllianceMemberListItem = null;
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
            _loc2_ = new UIAllianceMemberListItem();
            _loc2_.alternating = _loc1_ % 2 != 0;
            if(_loc1_ < this._members.numMembers)
            {
               _loc6_ = this._members.getMember(_loc1_);
               _loc2_.member = _loc6_;
               _loc2_.onEditMember.add(this.onEditMemberClicked);
               _loc3_.push(_loc6_.id);
            }
            else
            {
               _loc2_.member = null;
               _loc2_.onEditMember.remove(this.onEditMemberClicked);
            }
            mc_pageContainer.addChild(_loc2_);
            _items.push(_loc2_);
            _loc1_++;
         }
         super.createItems();
         RemotePlayerManager.getInstance().getLoadPlayers(_loc3_,this.onRemotePlayersLoaded);
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
         var _loc12_:UIAllianceMemberListItem = null;
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
            _loc12_ = _items[_loc1_] as UIAllianceMemberListItem;
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
      
      private function itemSort(param1:UIAllianceMemberListItem, param2:UIAllianceMemberListItem) : int
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
      
      private function getItemByMemberId(param1:String) : UIAllianceMemberListItem
      {
         var _loc3_:UIAllianceMemberListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            _loc3_ = UIAllianceMemberListItem(_items[_loc2_]);
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
         var _loc3_:UIAllianceMemberListItem = null;
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
      
      private function onEditMemberClicked(param1:UIAllianceMemberListItem) : void
      {
         if(this.ui_editPopup == null)
         {
            this.ui_editPopup = new UIAllianceMemberPopupMenu();
            this.ui_editPopup.itemSelected.add(this.onPopupMenuSelect);
         }
         this.ui_editPopup.populate(param1);
         this.ui_editPopup.x = mouseX - (this.ui_editPopup.width - 3);
         this.ui_editPopup.y = mouseY - 3;
         if(this.ui_editPopup.y + this.ui_editPopup.height > _height)
         {
            this.ui_editPopup.y = _height - (this.ui_editPopup.height + 3);
         }
         addChild(this.ui_editPopup);
      }
      
      private function onPopupMenuSelect(param1:String, param2:UIAllianceMemberListItem) : void
      {
         switch(param1)
         {
            case "kick":
               this.kickUser(param2);
               break;
            case "rank":
               this.changeUserRank(param2);
               break;
            case "view":
               if(param2.remotePlayerData == null)
               {
                  break;
               }
               Tracking.trackEvent("AllianceMemberList","View",param2.remotePlayerData.isFriend ? "friend" : "AllianceMember");
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.NEIGHBOR_COMPOUND,param2.remotePlayerData));
         }
      }
      
      private function changeUserRank(param1:UIAllianceMemberListItem) : void
      {
         var _loc2_:AllianceRankDialogue = new AllianceRankDialogue(AllianceRankDialogue.MODE_EDIT_PLAYER_RANK,param1.member);
         _loc2_.open();
      }
      
      private function kickUser(param1:UIAllianceMemberListItem) : void
      {
         var deleteBtn:PushButton;
         var isClient:Boolean = false;
         var name:String = null;
         var item:UIAllianceMemberListItem = param1;
         isClient = item.member.id == Network.getInstance().playerData.id;
         name = item.member.nickname;
         var dlg:MessageBox = new MessageBox(this._lang.getString(isClient ? "alliance.leave_msg" : "alliance.kick_member_msg",name),"kick-user");
         dlg.addTitle(this._lang.getString(isClient ? "alliance.leave_title" : "alliance.kick_member_title",name));
         deleteBtn = dlg.addButton(this._lang.getString(isClient ? "alliance.leave_confirm" : "alliance.kick_member_confirm")) as PushButton;
         dlg.addButton(this._lang.getString("alliance.kick_member_cancel"));
         deleteBtn.backgroundColor = Effects.BUTTON_WARNING_RED;
         deleteBtn.clicked.addOnce(function(param1:MouseEvent):void
         {
            var dlgBusy:BusyDialogue = null;
            var e:MouseEvent = param1;
            dlgBusy = new BusyDialogue(_lang.getString(isClient ? "alliance.leave_busy" : "alliance.kick_member_busy",name));
            dlgBusy.open();
            AllianceSystem.getInstance().kickMember(item.member,function(param1:RPCResponse):void
            {
               var _loc4_:MessageBox = null;
               dlgBusy.close();
               if(_disposed)
               {
                  return;
               }
               var _loc2_:Language = Language.getInstance();
               if(!param1.success)
               {
                  _loc4_ = new MessageBox(_loc2_.getString(isClient ? "alliance.leave_errorMsg" : "alliance.kick_member_errorMsg",name));
                  _loc4_.addTitle(_loc2_.getString(isClient ? "alliance.leave_errorTitle" : "alliance.kick_member_errorTitle",name),BaseDialogue.TITLE_COLOR_RUST);
                  _loc4_.addButton(_loc2_.getString(isClient ? "alliance.leave_ok" : "alliance.kick_member_ok"));
                  _loc4_.open();
                  return;
               }
               var _loc3_:MessageBox = new MessageBox(_loc2_.getString(isClient ? "alliance.leave_successMsg" : "alliance.kick_member_successMsg",name));
               _loc3_.addTitle(_loc2_.getString(isClient ? "alliance.leave_successTitle" : "alliance.kick_member_successTitle",name));
               _loc3_.addButton(_loc2_.getString(isClient ? "alliance.leave_ok" : "alliance.kick_member_ok"));
               _loc3_.open();
               if(isClient)
               {
                  mouseEnabled = mouseChildren = false;
               }
               else
               {
                  createItems();
               }
            });
         });
         dlg.open();
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

