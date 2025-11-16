package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIHUDInventory extends UIHUDButton
   {
      
      private var _ptSize:Point;
      
      private var _ptFull:Point;
      
      private var _inventory:Inventory;
      
      private var bmp_full:Bitmap;
      
      private var ui_size:UINotificationCount;
      
      public function UIHUDInventory(param1:String)
      {
         var _loc2_:BitmapData = Network.getInstance().playerData.isInventoryUpgraded() ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory();
         super(param1,new Bitmap(_loc2_));
         this.ui_size = new UINotificationCount();
         this.ui_size.x = 18;
         this.ui_size.y = 14;
         this.ui_size.label = "0";
         addChild(this.ui_size);
         this.bmp_full = new Bitmap(new BmpIconNotification(),"never",true);
         this.bmp_full.height = 28;
         this.bmp_full.scaleX = this.bmp_full.scaleY;
         this.bmp_full.x = int(45 - this.bmp_full.width * 0.5);
         this.bmp_full.y = int(this.ui_size.y - this.bmp_full.height * 0.5);
         this.bmp_full.filters = [Effects.ICON_SHADOW];
         addChildAt(this.bmp_full,getChildIndex(this.ui_size));
         this._ptSize = new Point(this.ui_size.x,this.ui_size.y);
         this._ptFull = new Point(this.bmp_full.x,this.bmp_full.y);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         this._inventory = Network.getInstance().playerData.inventory;
         this._inventory.itemAdded.add(this.onInventoryChanged);
         this._inventory.itemRemoved.add(this.onInventoryChanged);
         Network.getInstance().playerData.inventorySizeChanged.add(this.onInventorySizeChanged);
         this.update();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_size.dispose();
         Network.getInstance().playerData.inventorySizeChanged.remove(this.onInventorySizeChanged);
         this.bmp_full.bitmapData.dispose();
         this._inventory.itemAdded.remove(this.onInventoryChanged);
         this._inventory.itemRemoved.remove(this.onInventoryChanged);
         this._inventory = null;
      }
      
      private function update() : void
      {
         var _loc1_:int = 0;
         if(this._inventory.numItems > this._inventory.numItemsWarningThreshold)
         {
            _loc1_ = Math.ceil(this._inventory.numItems / this._inventory.maxItems * 100);
            if(_loc1_ >= 100)
            {
               this.ui_size.label = Language.getInstance().getString("full").toUpperCase();
               this.bmp_full.visible = true;
            }
            else
            {
               this.ui_size.label = _loc1_ + "%";
               this.bmp_full.visible = false;
            }
            this.ui_size.visible = true;
         }
         else
         {
            this.ui_size.visible = false;
            this.bmp_full.visible = false;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.update();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown || mc_icon == null)
         {
            return;
         }
         super.onMouseOver(param1);
         TweenMax.to(this.ui_size,0.15,{
            "x":this._ptSize.x - 5,
            "y":this._ptSize.y - 7
         });
         TweenMax.to(this.bmp_full,0.15,{
            "x":this._ptFull.x + 5,
            "y":this._ptFull.y - 7
         });
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         super.onMouseOut(param1);
         TweenMax.to(this.ui_size,0.15,{
            "x":this._ptSize.x,
            "y":this._ptSize.y
         });
         TweenMax.to(this.bmp_full,0.15,{
            "x":this._ptFull.x,
            "y":this._ptFull.y
         });
      }
      
      private function onInventoryChanged(param1:Item) : void
      {
         this.update();
      }
      
      private function onInventorySizeChanged() : void
      {
         var _loc1_:BitmapData = Network.getInstance().playerData.isInventoryUpgraded() ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory();
         icon = new Bitmap(_loc1_);
         this.update();
      }
   }
}

