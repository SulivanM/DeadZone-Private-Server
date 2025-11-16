package thelaststand.app.game.data.notification
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.gui.dialogues.CraftingDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class CraftingAvailableNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _closed:Signal;
      
      public function CraftingAvailableNotification()
      {
         super();
         this._closed = new Signal(INotification);
      }
      
      public function open() : void
      {
         var thisRef:INotification = null;
         var dlg:EventAlertDialogue = null;
         thisRef = this;
         var lang:Language = Language.getInstance();
         dlg = new EventAlertDialogue("images/ui/schematic-unlocked.jpg",110,110,"left","crafting-unlocked");
         dlg.addTitle(lang.getString("crafting_unlocked_title"),5864895);
         dlg.addBody(lang.getString("crafting_unlocked_msg"));
         dlg.addButton(lang.getString("crafting_unlocked_craft"),false,{"width":106}).clicked.addOnce(function(param1:MouseEvent):void
         {
            dlg.close();
            var _loc2_:CraftingDialogue = new CraftingDialogue();
            _loc2_.open();
         });
         dlg.addButton(lang.getString("crafting_unlocked_ok"),true,{"width":90});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            _closed.dispatch(thisRef);
         });
         dlg.open();
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         this._active = param1;
      }
      
      public function get closed() : Signal
      {
         return this._closed;
      }
      
      public function get type() : String
      {
         return NotificationType.TASK_COMPLETE;
      }
      
      public function get data() : *
      {
         return null;
      }
   }
}

