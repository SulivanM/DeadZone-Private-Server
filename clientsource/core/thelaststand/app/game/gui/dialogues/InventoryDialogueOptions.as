package thelaststand.app.game.gui.dialogues
{
   public class InventoryDialogueOptions
   {
      
      public var itemListOptions:ItemListOptions = null;
      
      public var showResources:Boolean = false;
      
      public var showStoreButton:Boolean = true;
      
      public var showRecyclerButton:Boolean = true;
      
      public var showIncineratorButton:Boolean = true;
      
      public var disableUnavailableItems:Boolean = false;
      
      public var trackingPageTag:String = null;
      
      public var trackingEventTag:String = null;
      
      public var preProcessorFunction:Function = null;
      
      public var clearNewFlagsOnClose:Boolean = true;
      
      public function InventoryDialogueOptions()
      {
         super();
      }
   }
}

