package thelaststand.app.game.gui.lists
{
   import flash.events.MouseEvent;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.iteminfo.UILimitInfo;
   import thelaststand.app.network.Network;
   
   public class UISchematicList extends UIPagedList
   {
      
      private var _schematics:Vector.<Schematic>;
      
      private var _itemSize:int;
      
      private var ui_itemInfo:UIItemInfo;
      
      public function UISchematicList(param1:int = 64)
      {
         super();
         this._itemSize = param1;
         _paddingX = 10;
         _paddingY = 10;
         listItemClass = UISchematicListItem;
         _itemWidth = this._itemSize + 4;
         _itemHeight = this._itemSize + 4;
         this.ui_itemInfo = new UIItemInfo();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._schematics = null;
         this.ui_itemInfo.dispose();
         this.ui_itemInfo = null;
      }
      
      override protected function createItems() : void
      {
         var _loc1_:UISchematicListItem = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         for each(_loc1_ in _items)
         {
            this.ui_itemInfo.removeRolloverTarget(_loc1_);
            _loc1_.dispose();
         }
         _items.length = 0;
         _selectedItem = null;
         var _loc2_:int = getColsPerPage();
         _loc3_ = getRowsPerPage();
         _loc4_ = _loc2_ * _loc3_ * Math.ceil(Math.max(this._schematics.length,1) / (_loc2_ * _loc3_));
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc5_ < this._schematics.length)
            {
               _loc1_ = new UISchematicListItem(this._itemSize);
               _loc1_.schematic = this._schematics[_loc5_];
               _loc1_.locked = !Network.getInstance().playerData.meetsRequirements(_loc1_.schematic.getNonItemRequirements());
               _loc1_.mouseOver.add(this.onItemMouseOver);
               _loc1_.mouseOut.add(this.onItemMouseOut);
               _loc1_.clicked.add(onItemClicked);
               this.ui_itemInfo.addRolloverTarget(_loc1_);
            }
            else
            {
               _loc1_ = new UISchematicListItem(this._itemSize);
               _loc1_.enabled = false;
               _loc1_.locked = false;
            }
            mc_pageContainer.addChild(_loc1_);
            _items.push(_loc1_);
            _loc5_++;
         }
         super.createItems();
      }
      
      private function onItemMouseOver(param1:MouseEvent) : void
      {
         if(stage == null)
         {
            return;
         }
         var _loc2_:UISchematicListItem = UISchematicListItem(param1.currentTarget);
         var _loc3_:Date = _loc2_.schematic.getExpiryDate();
         var _loc4_:int = _loc2_.schematic.getMaxLevel();
         var _loc5_:Object = {"showAction":false};
         if(_loc3_ != null)
         {
            _loc5_.limits = _loc5_.limits || [];
            _loc5_.limits.push(new UILimitInfo("available_craft_date",_loc3_));
         }
         if(_loc4_ < int.MAX_VALUE)
         {
            _loc5_.limits = _loc5_.limits || [];
            _loc5_.limits.push(new UILimitInfo("available_craft_level",_loc4_ + 1));
         }
         this.ui_itemInfo.extraInfo = _loc2_.schematic.getCraftInfo();
         this.ui_itemInfo.setItem(_loc2_.schematic.outputItem,null,_loc5_);
      }
      
      private function onItemMouseOut(param1:MouseEvent) : void
      {
      }
      
      public function get schematics() : Vector.<Schematic>
      {
         return this._schematics;
      }
      
      public function set schematics(param1:Vector.<Schematic>) : void
      {
         this._schematics = param1;
         this.createItems();
      }
   }
}

