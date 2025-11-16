package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.network.Network;
   
   public class UIHUDBountyOfficeButton extends UIHUDButton
   {
      
      private var _bounty:InfectedBounty;
      
      private var _ptInfectedBountyNote:Point;
      
      private var ui_newInfectedBounty:UINotificationCount;
      
      public function UIHUDBountyOfficeButton(param1:String)
      {
         super(param1,new Bitmap(new BmpIconHUDBounty()));
         this._ptInfectedBountyNote = new Point(10,10);
         this.ui_newInfectedBounty = new UINotificationCount();
         this.ui_newInfectedBounty.x = this._ptInfectedBountyNote.x;
         this.ui_newInfectedBounty.y = this._ptInfectedBountyNote.y;
         this.ui_newInfectedBounty.label = "!";
         this.ui_newInfectedBounty.visible = false;
         addChild(this.ui_newInfectedBounty);
         this._bounty = Network.getInstance().playerData.infectedBounty;
         Network.getInstance().playerData.infectedBountyReceived.add(this.onInfectedBountyReceived);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function get width() : Number
      {
         return mc_hitArea.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return mc_hitArea.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         super.dispose();
         Network.getInstance().playerData.infectedBountyReceived.remove(this.onInfectedBountyReceived);
         Network.getInstance().playerData.inventory.itemRemoved.remove(this.onInventoryItemRemoved);
         this.ui_newInfectedBounty.dispose();
         if(this._bounty != null)
         {
            this._bounty.completed.remove(this.onInfectedBountyCompleted);
            this._bounty.viewed.remove(this.onInfectedBountyViewed);
            this._bounty = null;
         }
      }
      
      private function updateInfectedBountyNofication() : void
      {
         var _loc1_:Item = null;
         if(this._bounty == null)
         {
            this.ui_newInfectedBounty.visible = false;
            return;
         }
         if(this._bounty.isCompleted)
         {
            _loc1_ = Network.getInstance().playerData.inventory.getItemById(this._bounty.rewardItemId);
            if(_loc1_ != null)
            {
               Network.getInstance().playerData.inventory.itemRemoved.add(this.onInventoryItemRemoved);
               this.ui_newInfectedBounty.color = 622336;
               this.ui_newInfectedBounty.visible = true;
            }
            else
            {
               this.ui_newInfectedBounty.visible = false;
            }
         }
         else if(!this._bounty.isViewed)
         {
            this.ui_newInfectedBounty.color = 10030858;
            this.ui_newInfectedBounty.visible = true;
            this._bounty.viewed.addOnce(this.onInfectedBountyViewed);
         }
         else
         {
            this.ui_newInfectedBounty.visible = false;
         }
      }
      
      private function onInfectedBountyReceived(param1:InfectedBounty) : void
      {
         if(this._bounty != null)
         {
            this._bounty.completed.remove(this.onInfectedBountyCompleted);
            this._bounty.viewed.remove(this.onInfectedBountyViewed);
            this._bounty = null;
         }
         this._bounty = param1;
         if(this._bounty != null)
         {
            this._bounty.completed.addOnce(this.onInfectedBountyCompleted);
         }
         this.updateInfectedBountyNofication();
      }
      
      private function onInfectedBountyViewed(param1:InfectedBounty) : void
      {
         this._bounty.viewed.remove(this.onInfectedBountyViewed);
         this.updateInfectedBountyNofication();
      }
      
      private function onInfectedBountyCompleted(param1:InfectedBounty) : void
      {
         this._bounty.completed.remove(this.onInfectedBountyCompleted);
         this.updateInfectedBountyNofication();
      }
      
      private function onInventoryItemRemoved(param1:Item) : void
      {
         var _loc2_:Inventory = Network.getInstance().playerData.inventory;
         if(this._bounty == null || !this._bounty.rewardItemId)
         {
            _loc2_.itemRemoved.remove(this.onInventoryItemRemoved);
            return;
         }
         if(param1.id.toUpperCase() == this._bounty.rewardItemId.toUpperCase())
         {
            _loc2_.itemRemoved.remove(this.onInventoryItemRemoved);
            this.updateInfectedBountyNofication();
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._bounty != null)
         {
            this._bounty.completed.addOnce(this.onInfectedBountyCompleted);
         }
         this.updateInfectedBountyNofication();
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
         TweenMax.to(this.ui_newInfectedBounty,0.15,{
            "x":this._ptInfectedBountyNote.x - 5,
            "y":this._ptInfectedBountyNote.y - 7
         });
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         super.onMouseOut(param1);
         TweenMax.to(this.ui_newInfectedBounty,0.15,{
            "x":this._ptInfectedBountyNote.x,
            "y":this._ptInfectedBountyNote.y
         });
      }
   }
}

