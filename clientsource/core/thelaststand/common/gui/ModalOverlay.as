package thelaststand.common.gui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ModalOverlay extends Sprite
   {
      
      public function ModalOverlay()
      {
         super();
         buttonMode = true;
         useHandCursor = false;
         tabEnabled = false;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function draw() : void
      {
         if(!stage)
         {
            return;
         }
         graphics.clear();
         graphics.beginFill(0,0.8);
         graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         graphics.endFill();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         this.draw();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(Event.RESIZE,this.onStageResize);
      }
      
      private function onStageResize(param1:Event) : void
      {
         this.draw();
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

