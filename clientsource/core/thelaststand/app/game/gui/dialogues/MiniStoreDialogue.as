package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.gui.lists.UIStoreItemList;
   import thelaststand.app.game.gui.lists.UIStoreItemListItem;
   import thelaststand.app.game.gui.store.UIFuelCounter;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.StoreManager;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class MiniStoreDialogue extends BaseDialogue
   {
      
      private var _disposed:Boolean = false;
      
      private var _itemType:String;
      
      private var _itemXML:XML;
      
      private var _listPadding:int = 6;
      
      private var _showMessageWhenNoneFound:Boolean = true;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_fuelCounter:UIFuelCounter;
      
      private var ui_storeList:UIStoreItemList;
      
      public var noItemsFound:Signal = new Signal();
      
      public function MiniStoreDialogue(param1:String, param2:Boolean = true)
      {
         super("mini-store",this.mc_container,true);
         this._itemType = param1;
         this._itemXML = ItemFactory.getItemDefinition(this._itemType);
         _autoSize = false;
         this._showMessageWhenNoneFound = param2;
         addTitle(Language.getInstance().getString("store_mini_title"),BaseDialogue.TITLE_COLOR_BUY);
         this.ui_storeList = new UIStoreItemList(this._listPadding);
         this.ui_storeList.changed.add(this.onItemSelected);
         this.ui_storeList.y = int(_padding * 0.5);
         this.mc_container.addChild(this.ui_storeList);
         this.ui_fuelCounter = new UIFuelCounter();
         this.mc_container.addChild(this.ui_fuelCounter);
      }
      
      override public function dispose() : void
      {
         DialogueManager.getInstance().closeDialogue("loading-mini-store-items");
         super.dispose();
         this._disposed = true;
         this._itemXML = null;
         this.ui_storeList.dispose();
         this.ui_fuelCounter.dispose();
         this.noItemsFound.removeAll();
      }
      
      override public function open() : void
      {
         var busy:BusyDialogue = null;
         var superOpen:Function = super.open;
         busy = new BusyDialogue(Language.getInstance().getString("store_loading_item"),"loading-mini-store-items");
         busy.open();
         StoreManager.getInstance().loadItemsByType(this._itemType,function(param1:Vector.<StoreItem>):void
         {
            var _loc3_:int = 0;
            var _loc4_:int = 0;
            var _loc5_:int = 0;
            var _loc6_:int = 0;
            busy.close();
            if(_disposed)
            {
               return;
            }
            var _loc2_:int = int(param1.length);
            if(_loc2_ > 0)
            {
               _loc3_ = Math.min(_loc2_,6);
               _loc4_ = Math.ceil(_loc2_ / _loc3_);
               _loc5_ = int(_loc3_ * 68 + (_loc3_ - 1) * _listPadding + _listPadding * 2);
               _loc6_ = int(_loc4_ * 88 + (_loc4_ - 1) * _listPadding + _listPadding * 2);
               ui_storeList.width = _loc5_;
               ui_storeList.height = _loc6_;
               ui_storeList.storeItemList = param1;
               ui_fuelCounter.y = int(ui_storeList.y + ui_storeList.height + 16);
               _width = Math.max(ui_storeList.width + _padding * 2,150);
               _height = int(ui_fuelCounter.y + ui_fuelCounter.height + 26);
               ui_storeList.x = int((_width - ui_storeList.width) * 0.5) - _padding;
               ui_fuelCounter.x = int((_width - ui_fuelCounter.width) * 0.5 + 10) - _padding;
               superOpen();
            }
            else
            {
               showNoneMessage();
            }
         });
      }
      
      private function showNoneMessage() : void
      {
         var itemName:String = null;
         var msg:MessageBox = null;
         if(this._showMessageWhenNoneFound)
         {
            itemName = Language.getInstance().getString("items." + this._itemType);
            msg = new MessageBox(Language.getInstance().getString("store_mini_noitems_msg",itemName),"mini-store-no-items",true);
            msg.addTitle(Language.getInstance().getString("store_mini_noitems_title"));
            msg.addButton(Language.getInstance().getString("store_mini_noitems_ok"));
            msg.closed.addOnce(function(param1:Dialogue):void
            {
               noItemsFound.dispatch();
               dispose();
            });
            msg.open();
         }
         else
         {
            this.noItemsFound.dispatch();
            this.dispose();
         }
      }
      
      private function onItemSelected() : void
      {
         var listItem:UIStoreItemListItem = UIStoreItemListItem(this.ui_storeList.selectedItem);
         PaymentSystem.getInstance().buyStoreItem(listItem.storeItem,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
   }
}

