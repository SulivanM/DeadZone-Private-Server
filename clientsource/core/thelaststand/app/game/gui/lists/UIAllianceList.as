package thelaststand.app.game.gui.lists
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceList;
   import thelaststand.app.gui.TooltipManager;
   
   public class UIAllianceList extends UIPagedList
   {
      
      private var _allianceList:AllianceList;
      
      private var _header:UIGenericListHeader;
      
      public var viewAlliance:Signal = new Signal(AllianceDataSummary);
      
      public function UIAllianceList(param1:String = "")
      {
         super();
         _fillColor = 1973790;
         _paddingX = _paddingY = 4;
         _itemSpacingX = 0;
         _itemSpacingY = 0;
         listItemClass = UIAllianceListItem;
         this._header = new UIGenericListHeader(param1,22);
         this._header.y = _paddingY;
         addChild(this._header);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this);
         this._header.dispose();
         this._allianceList = null;
         this.viewAlliance.removeAll();
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIAllianceListItem = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:AllianceDataSummary = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         var _loc2_:int = 1;
         _loc3_ = _pageHeight / _itemHeight;
         _loc4_ = _loc3_ * Math.ceil(Math.max(this._allianceList.numAlliances,1) / _loc3_);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc1_ = new UIAllianceListItem();
            if(_loc5_ < this._allianceList.numAlliances)
            {
               _loc6_ = this._allianceList.getAlliance(_loc5_);
               _loc1_.allianceData = _loc6_;
               _loc1_.clickedView.add(this.onViewClicked);
               _loc1_.id = _loc6_.id;
            }
            else
            {
               _loc1_.allianceData = null;
               _loc1_.clickedView.remove(this.onViewClicked);
            }
            _loc1_.width = _width;
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc5_++;
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
         var _loc10_:UIAllianceListItem = null;
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
            _loc10_ = _items[_loc1_] as UIAllianceListItem;
            _loc10_.x = _loc3_;
            _loc10_.y = _loc4_;
            _loc10_.alternating = _loc8_ % 2 == 0;
            _loc10_.width = _width - _paddingX * 2;
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
      
      private function onViewClicked(param1:UIAllianceListItem) : void
      {
         this.viewAlliance.dispatch(param1.allianceData);
      }
      
      public function get allianceList() : AllianceList
      {
         return this._allianceList;
      }
      
      public function set allianceList(param1:AllianceList) : void
      {
         this._allianceList = param1;
         this.createItems();
      }
   }
}

