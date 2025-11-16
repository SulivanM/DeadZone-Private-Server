package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.gui.UIPagination;
   
   public class MissionReportLoot extends Sprite
   {
      
      private var _missionData:MissionData;
      
      private var _width:int = 328;
      
      private var ui_list:UIInventoryList;
      
      private var ui_page:UIPagination;
      
      public function MissionReportLoot(param1:MissionData)
      {
         super();
         this._missionData = param1;
         var _loc2_:ItemListOptions = new ItemListOptions();
         _loc2_.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc2_.allowSelection = false;
         _loc2_.showNewIcons = false;
         this.ui_list = new UIInventoryList(48,5,_loc2_);
         this.ui_list.width = this._width;
         this.ui_list.height = 274;
         this.ui_list.itemList = this._missionData.loot;
         addChild(this.ui_list);
         this.ui_page = new UIPagination(this.ui_list.numPages);
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 10);
         this.ui_page.changed.add(this.onPageChanged);
         addChild(this.ui_page);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         this.ui_list.dispose();
         this.ui_page.dispose();
      }
      
      public function updateLootList() : void
      {
         this.ui_list.itemList = this._missionData.loot;
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
   }
}

