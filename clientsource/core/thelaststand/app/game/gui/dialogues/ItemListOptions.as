package thelaststand.app.game.gui.dialogues
{
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.itemfilters.ItemFilter;
   import thelaststand.app.game.gui.inventory.UIInventoryFilter;
   import thelaststand.app.gui.UIComponent;
   
   public class ItemListOptions
   {
      
      public var disabledList:Vector.<String> = null;
      
      public var levelAdjustment:int = 0;
      
      public var loadout:SurvivorLoadout = null;
      
      public var showNoneItem:Boolean = false;
      
      public var showResourceLimited:Boolean = true;
      
      public var showActiveGearQuantities:Boolean = false;
      
      public var itemInfoParams:Object = null;
      
      public var allowSelection:Boolean = true;
      
      public var allowSelectionOfUnequippable:Boolean = false;
      
      public var showNewIcons:Boolean = true;
      
      public var showEquippedIcons:Boolean = false;
      
      public var showControls:Boolean = false;
      
      public var showMaxUpgradeLevel:Boolean = false;
      
      public var clothingPreviews:uint = 2;
      
      public var sortItems:Boolean = true;
      
      public var maxLevel:int = 2147483647;
      
      public var header:UIComponent = null;
      
      public var filter:ItemFilter;
      
      public var ui_filter:UIInventoryFilter;
      
      public var allowFilterDispose:Boolean = true;
      
      public var allowHeaderDispose:Boolean = true;
      
      public var headerColor:uint = 4934477;
      
      public var itemSize:int = 48;
      
      public var itemSpacing:int = 12;
      
      public var columns:uint = 5;
      
      public var rows:uint = 6;
      
      public function ItemListOptions(param1:Object = null)
      {
         super();
         if(param1 != null)
         {
            this.setProperties(param1);
         }
      }
      
      public function setProperties(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(_loc2_ in this)
            {
               this[_loc2_] = param1[_loc2_];
            }
         }
      }
   }
}

