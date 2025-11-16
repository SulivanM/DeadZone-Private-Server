package thelaststand.app.game.gui.lists
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceRank;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   
   public class UIAllianceRankList extends UIPagedList
   {
      
      private var _rankList:Array;
      
      private var _showEditButtons:Boolean;
      
      private var _alliance:AllianceData;
      
      public var editRank:Signal = new Signal(int);
      
      public function UIAllianceRankList(param1:Boolean = false)
      {
         super();
         this._alliance = AllianceSystem.getInstance().alliance;
         if(this._alliance != null)
         {
            this._alliance.rankNameChanged.add(this.onRankNameChanged);
         }
         _paddingX = _paddingY = 3;
         _itemSpacingX = 0;
         _itemSpacingY = 0;
         this._showEditButtons = param1;
         listItemClass = UIAllianceRankListItem;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._rankList = null;
         if(this._alliance != null)
         {
            this._alliance.rankNameChanged.remove(this.onRankNameChanged);
            this._alliance = null;
         }
      }
      
      public function getItemByRank(param1:int) : UIAllianceRankListItem
      {
         var _loc2_:UIAllianceRankListItem = null;
         for each(_loc2_ in _items)
         {
            if(_loc2_.rank == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UIPagedListItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:UIAllianceRankListItem = null;
         for each(_loc1_ in _items)
         {
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         _loc2_ = 1;
         _loc3_ = _pageHeight / _itemHeight;
         _loc4_ = 0;
         _loc5_ = int(this._rankList.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = int(this._rankList[_loc4_]);
            _loc1_ = new UIAllianceRankListItem(this._showEditButtons);
            _loc1_.clicked.add(onItemClicked);
            _loc7_ = UIAllianceRankListItem(_loc1_);
            _loc7_.width = _pageWidth;
            _loc7_.alternating = _loc4_ % 2 != 0;
            _loc7_.id = String(_loc6_);
            _loc7_.rank = _loc6_;
            _loc7_.label = this._alliance.getRankName(_loc6_);
            _loc7_.clickedEdit.add(this.onRankItemEditClicked);
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc4_++;
         }
         super.createItems();
      }
      
      private function onRankItemEditClicked(param1:UIAllianceRankListItem) : void
      {
         this.editRank.dispatch(param1.rank);
      }
      
      private function onRankNameChanged(param1:int) : void
      {
         var _loc2_:UIAllianceRankListItem = null;
         for each(_loc2_ in _items)
         {
            if(_loc2_.rank == param1)
            {
               _loc2_.name = this._alliance.getRankName(param1);
            }
         }
      }
      
      public function get rankList() : Array
      {
         return this._rankList;
      }
      
      public function set rankList(param1:Array) : void
      {
         this._rankList = param1 || AllianceRank.getAllRanks();
         this.createItems();
      }
   }
}

