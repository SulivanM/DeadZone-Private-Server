package thelaststand.app.game.gui.inventory
{
   import flash.events.Event;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.itemfilters.IFilterData;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   
   public class UIInventoryFilter extends UIComponent
   {
      
      protected var _width:int = 80;
      
      protected var _filterData:IFilterData;
      
      private var _height:int = 24;
      
      public var changed:Signal = new Signal();
      
      public function UIInventoryFilter()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get filterData() : IFilterData
      {
         return this._filterData;
      }
      
      public function set filterData(param1:IFilterData) : void
      {
         this._filterData = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         this.changed.removeAll();
         this._filterData = null;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._filterData != null)
         {
            this._filterData.reset();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
   }
}

