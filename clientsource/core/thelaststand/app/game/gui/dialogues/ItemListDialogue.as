package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class ItemListDialogue extends BaseDialogue
   {
      
      private var _itemList:Vector.<Item>;
      
      private var _itemListFiltered:Vector.<Item>;
      
      private var _lang:Language;
      
      private var _options:ItemListOptions;
      
      private var mc_container:Sprite;
      
      private var ui_header:Sprite;
      
      private var ui_list:UIInventoryList;
      
      private var ui_page:UIPagination;
      
      public var selected:Signal;
      
      public function ItemListDialogue(param1:String, param2:Vector.<Item>, param3:ItemListOptions = null)
      {
         var _loc9_:String = null;
         this.mc_container = new Sprite();
         super("item-list-dialogue",this.mc_container,true);
         this._options = param3 || new ItemListOptions();
         _autoSize = false;
         _padding = 20;
         this._lang = Language.getInstance();
         this._itemList = this._itemListFiltered = param2;
         this.selected = new Signal(Item);
         this._options.showEquippedIcons = true;
         this._options.showNewIcons = false;
         var _loc4_:int = int.MAX_VALUE;
         if(this._options.loadout != null && !isNaN(this._options.levelAdjustment))
         {
            this._options.maxLevel = this._options.loadout.survivor.level - int(this._options.levelAdjustment);
         }
         addTitle(param1,this._options.headerColor);
         var _loc5_:int = 0;
         if(this._options.header != null)
         {
            if(this._options.rows > 5)
            {
               this._options.rows = 5;
            }
            this._options.header.x = this._options.header.y = 0;
            this.mc_container.addChild(this._options.header);
            _loc5_ = int(this._options.header.y + this._options.header.height + 10);
         }
         if(this._options.ui_filter != null)
         {
            this._itemListFiltered = this._options.filter.filter(this._itemList);
            this._options.sortItems = !this._options.filter.willSort;
            this._options.ui_filter.filterData = this._options.filter.data;
            this._options.ui_filter.x = 0;
            this._options.ui_filter.y = _loc5_;
            this._options.ui_filter.changed.add(this.onFilterChanged);
            this.mc_container.addChild(this._options.ui_filter);
            _loc5_ = int(this._options.ui_filter.y + this._options.ui_filter.height + 10);
         }
         var _loc6_:int = 10;
         var _loc7_:int = _loc6_ * 2 + this._options.itemSize * this._options.columns + this._options.itemSpacing * (this._options.columns - 1);
         var _loc8_:int = _loc6_ * 2 + this._options.itemSize * this._options.rows + this._options.itemSpacing * (this._options.rows - 1);
         if(this._options.ui_filter != null)
         {
            this._options.ui_filter.width = _loc7_;
         }
         this.ui_list = new UIInventoryList(this._options.itemSize,_loc6_,this._options);
         this.ui_list.y = _loc5_;
         this.ui_list.width = _loc7_;
         this.ui_list.height = _loc8_;
         this.ui_list.itemList = this._itemListFiltered;
         this.ui_list.changed.add(this.onItemSelected);
         this.mc_container.addChild(this.ui_list);
         if(this._options.disabledList != null)
         {
            for each(_loc9_ in this._options.disabledList)
            {
               this.ui_list.setEnabledStateByItemId(_loc9_,false);
            }
         }
         this.ui_page = new UIPagination(this.ui_list.numPages);
         this.ui_page.maxWidth = this.ui_list.width;
         this.ui_page.changed.add(this.onPageChanged);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 10);
         this.updateItemListPagination();
         this.mc_container.addChild(this.ui_page);
         _width = int(_loc7_ + _padding * 2);
         _height = int(this.ui_page.y + this.ui_page.height + _padding * 2);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this._itemList = null;
         this.selected.removeAll();
         this.ui_list.dispose();
         this.ui_page.dispose();
         if(this._options.header != null && this._options.allowHeaderDispose)
         {
            this._options.header.dispose();
         }
         if(this._options.ui_filter != null && this._options.allowFilterDispose)
         {
            this._options.ui_filter.dispose();
         }
      }
      
      public function selectItem(param1:Item, param2:Boolean = true) : void
      {
         if(param1 == null)
         {
            this.ui_list.selectItem(-1);
         }
         else
         {
            this.ui_list.selectItemById(param1.id.toUpperCase());
         }
         if(param2)
         {
            this.ui_list.gotoPage(this.ui_list.getSelectedItemPage());
            this.ui_page.currentPage = this.ui_list.currentPage;
         }
      }
      
      private function updateItemListPagination() : void
      {
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.currentPage = this.ui_list.currentPage;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
      }
      
      private function onItemSelected() : void
      {
         this.selected.dispatch(UIInventoryListItem(this.ui_list.selectedItem).itemData);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
      
      private function onFilterChanged() : void
      {
         this._itemListFiltered = this._options.filter.filter(this._itemList);
         var _loc1_:int = this.ui_list.currentPage;
         this.ui_list.itemList = this._itemListFiltered;
         this.ui_list.gotoPage(_loc1_);
         this.updateItemListPagination();
      }
      
      public function get list() : UIInventoryList
      {
         return this.ui_list;
      }
   }
}

