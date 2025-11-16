package thelaststand.app.game.gui.lists
{
   import flash.display.Sprite;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceMemberLeaderboardList extends UIPagedList
   {
      
      private var _lang:Language;
      
      private var _members:AllianceMemberList;
      
      private var _headers:Vector.<UIGenericListHeader>;
      
      private var _separators:Vector.<UIListSeparator>;
      
      private var _disposed:Boolean = false;
      
      public function UIAllianceMemberLeaderboardList()
      {
         var _loc4_:Sprite = null;
         var _loc5_:UIGenericListHeader = null;
         var _loc6_:UIListSeparator = null;
         super();
         _fillColor = 1973790;
         this._lang = Language.getInstance();
         _width = 495;
         _height = 350;
         _paddingX = _paddingY = 4;
         _itemSpacingX = 0;
         _itemSpacingY = 0;
         listItemClass = UIAllianceMemberLeaderboardListItem;
         this._headers = new Vector.<UIGenericListHeader>();
         this._separators = new Vector.<UIListSeparator>();
         var _loc1_:Array = [{
            "width":40,
            "label":this._lang.getString("alliance.members_header_num")
         },{
            "width":205,
            "label":this._lang.getString("alliance.members_header_name")
         },{
            "width":102,
            "label":this._lang.getString("alliance.members_header_pts")
         },{
            "width":140,
            "label":this._lang.getString("alliance.members_header_efficiency")
         }];
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc5_ = new UIGenericListHeader(_loc1_[_loc3_].label,22);
            _loc5_.width = _loc1_[_loc3_].width;
            _loc5_.x = _loc2_;
            addChild(_loc5_);
            this._headers.push(_loc5_);
            _loc2_ += _loc1_[_loc3_].width;
            if(_loc3_ < _loc1_.length - 1)
            {
               _loc6_ = new UIListSeparator(22);
               _loc6_.x = _loc2_ - int(_loc6_.width * 0.5);
               addChild(_loc6_);
               this._separators.push(_loc6_);
            }
            _loc3_++;
         }
         for each(_loc4_ in this._separators)
         {
            addChild(_loc4_);
         }
      }
      
      override public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         while(this._headers.length > 0)
         {
            this._headers.pop().dispose();
         }
         this._headers = null;
         while(this._separators.length > 0)
         {
            this._separators.pop().dispose();
         }
         this._separators = null;
         this._lang = null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UIAllianceMemberLeaderboardListItem = null;
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
            _loc2_ = new UIAllianceMemberLeaderboardListItem();
            _loc2_.alternating = _loc1_ % 2 != 0;
            if(_loc1_ < this._members.numMembers)
            {
               _loc6_ = this._members.getMember(_loc1_);
               _loc2_.member = _loc6_;
               _loc2_.rank = _loc1_ + 1;
               if(_loc6_.id != null && _loc6_.id != "")
               {
                  _loc3_.push(_loc6_.id);
               }
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
         var _loc10_:UIGenericListHeader = null;
         var _loc11_:UIListSeparator = null;
         var _loc12_:UIAllianceMemberLeaderboardListItem = null;
         _loc3_ = _paddingX;
         _loc4_ = _paddingY;
         _loc1_ = 0;
         _loc2_ = int(this._headers.length);
         while(_loc1_ < _loc2_)
         {
            _loc10_ = this._headers[_loc1_];
            _loc10_.x = _loc3_;
            _loc10_.y = _loc4_;
            if(_loc1_ < this._separators.length)
            {
               _loc11_ = this._separators[_loc1_];
               _loc11_.x = _loc3_ + _loc10_.width - _loc11_.width * 0.5;
               _loc11_.y = _loc4_;
            }
            _loc3_ += _loc10_.width;
            _loc1_++;
         }
         var _loc5_:int = getColsPerPage();
         var _loc6_:int = getRowsPerPage();
         _numPages = Math.ceil(_items.length / (_loc5_ * _loc6_));
         var _loc7_:int = _paddingY + this._headers[0].height + _itemSpacingY;
         _loc3_ = _paddingX;
         _loc4_ = _loc7_;
         _loc1_ = 0;
         _loc2_ = int(_items.length);
         while(_loc1_ < _loc2_)
         {
            _loc12_ = _items[_loc1_] as UIAllianceMemberLeaderboardListItem;
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
      
      private function getItemByMemberId(param1:String) : UIAllianceMemberLeaderboardListItem
      {
         var _loc3_:UIAllianceMemberLeaderboardListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < _items.length)
         {
            _loc3_ = UIAllianceMemberLeaderboardListItem(_items[_loc2_]);
            if(_loc3_ != null && _loc3_.member.id == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function onRemotePlayersLoaded(param1:Vector.<RemotePlayerData>) : void
      {
         var _loc2_:RemotePlayerData = null;
         var _loc3_:UIAllianceMemberLeaderboardListItem = null;
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
         this._members = param1;
         this.createItems();
      }
   }
}

