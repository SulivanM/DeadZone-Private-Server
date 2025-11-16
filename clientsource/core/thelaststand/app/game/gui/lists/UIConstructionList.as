package thelaststand.app.game.gui.lists
{
   import thelaststand.app.network.Network;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIConstructionList extends UIPagedList
   {
      
      private var _category:String;
      
      private var _xml:XML;
      
      public function UIConstructionList()
      {
         super();
         _paddingX = 10;
         _paddingY = 10;
         _itemSpacingY = 14;
         this._xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content;
         listItemClass = UIConstructionListItem;
      }
      
      override public function dispose() : void
      {
         this._xml = null;
         super.dispose();
      }
      
      override protected function createItems() : void
      {
         var item:UIConstructionListItem = null;
         var itemList:XMLList = null;
         var numItems:int = 0;
         var i:int = 0;
         var node:XML = null;
         for each(item in _items)
         {
            item.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         itemList = this._xml.item.(@id.toString() != "" && @type.toString() == _category && (!hasOwnProperty("@buildable") || @buildable == "1"));
         numItems = int(itemList.length());
         i = 0;
         for(; i < numItems; i++)
         {
            node = itemList[i];
            if(node.@admin == "1")
            {
               if(!Network.getInstance().playerData.isAdmin)
               {
                  continue;
               }
            }
            item = new UIConstructionListItem();
            item.clicked.add(onItemClicked);
            item.dataXML = node;
            mc_pageContainer.addChild(item);
            _items.push(item);
         }
         super.createItems();
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function set category(param1:String) : void
      {
         this._category = param1;
         this.createItems();
      }
   }
}

