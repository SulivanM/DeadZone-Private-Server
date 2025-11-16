package thelaststand.app.gui
{
   import com.deadreckoned.threshold.core.IDisposable;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class UIComponent extends Sprite implements IDisposable
   {
      
      private var _invalid:Boolean = true;
      
      private var _data:* = null;
      
      public function UIComponent()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      protected function get isInvalid() : Boolean
      {
         return this._invalid;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function set data(param1:*) : void
      {
         this._data = param1;
      }
      
      public function dispose() : void
      {
         if(stage)
         {
            stage.removeEventListener(Event.RENDER,this.onStageRender);
         }
         if(parent)
         {
            parent.removeChild(this);
         }
         filters = [];
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function invalidate() : void
      {
         this._invalid = true;
         if(stage != null)
         {
            stage.invalidate();
         }
      }
      
      public function redraw() : void
      {
         this.draw();
         this._invalid = false;
      }
      
      protected function draw() : void
      {
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(Event.RENDER,this.onStageRender,false,0,true);
         if(this._invalid)
         {
            this.redraw();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(Event.RENDER,this.onStageRender);
      }
      
      private function onStageRender(param1:Event) : void
      {
         if(this._invalid)
         {
            this.redraw();
         }
      }
   }
}

