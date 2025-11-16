package thelaststand.app.gui
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class UIBusySpinner extends Sprite
   {
      
      private var mc_arm:BusySpinnerGraphic;
      
      public function UIBusySpinner(param1:Number = 0.4)
      {
         super();
         this.mc_arm = new BusySpinnerGraphic();
         this.mc_arm.alpha = param1;
         addChild(this.mc_arm);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         filters = [];
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this.mc_arm.rotation += 2;
      }
   }
}

