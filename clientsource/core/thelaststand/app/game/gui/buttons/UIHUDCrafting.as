package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.network.Network;
   
   public class UIHUDCrafting extends UIHUDButton
   {
      
      private var _ptNew:Point;
      
      private var _ptLimited:Point;
      
      private var _inventory:Inventory;
      
      private var ui_new:UINotificationCount;
      
      private var ui_limited:UINotificationCount;
      
      public function UIHUDCrafting(param1:String)
      {
         super(param1,new Bitmap(new BmpIconHUDSchematic()));
         this.ui_new = new UINotificationCount();
         this.ui_new.x = 18;
         this.ui_new.y = 14;
         this.ui_new.label = "0";
         addChild(this.ui_new);
         this.ui_limited = new UINotificationCount(13475084);
         this.ui_limited.x = 34;
         this.ui_limited.y = 8;
         this.ui_limited.label = "0";
         addChild(this.ui_limited);
         this._ptNew = new Point(this.ui_new.x,this.ui_new.y);
         this._ptLimited = new Point(this.ui_limited.x,this.ui_limited.y);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         this._inventory = Network.getInstance().playerData.inventory;
         this._inventory.schematicAdded.add(this.onSchematicsChanged);
         this._inventory.schematicNewFlagsCleared.add(this.onSchematicsChanged);
         this._inventory.limitedSchematicsChanged.add(this.onSchematicsChanged);
         this.update();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_new.dispose();
         this._inventory.schematicAdded.remove(this.onSchematicsChanged);
         this._inventory.schematicNewFlagsCleared.remove(this.onSchematicsChanged);
         this._inventory.limitedSchematicsChanged.remove(this.onSchematicsChanged);
         this._inventory = null;
      }
      
      private function update() : void
      {
         var _loc1_:int = this._inventory.getNumNewSchematics();
         if(_loc1_ > 0)
         {
            this.ui_new.label = _loc1_.toString();
            this.ui_new.visible = true;
         }
         else
         {
            this.ui_new.visible = false;
         }
         var _loc2_:int = this._inventory.numLimitedSchematics;
         if(_loc2_ > 0)
         {
            this.ui_limited.label = _loc2_.toString();
            this.ui_limited.visible = true;
         }
         else
         {
            this.ui_limited.visible = false;
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
         TweenMax.to(this.ui_new,0.15,{
            "x":this._ptNew.x - 5,
            "y":this._ptNew.y - 7
         });
         TweenMax.to(this.ui_limited,0.15,{
            "x":this._ptLimited.x - 1,
            "y":this._ptLimited.y - 7
         });
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         super.onMouseOut(param1);
         TweenMax.to(this.ui_new,0.15,{
            "x":this._ptNew.x,
            "y":this._ptNew.y
         });
         TweenMax.to(this.ui_limited,0.15,{
            "x":this._ptLimited.x,
            "y":this._ptLimited.y
         });
      }
      
      private function onSchematicsChanged(param1:Schematic = null) : void
      {
         this.update();
      }
   }
}

