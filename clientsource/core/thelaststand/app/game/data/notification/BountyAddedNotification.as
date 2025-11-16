package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class BountyAddedNotification implements INotification
   {
      
      private var _active:Boolean = true;
      
      private var _closed:Signal;
      
      public function BountyAddedNotification()
      {
         super();
         this._closed = new Signal(INotification);
      }
      
      public function open() : void
      {
         var thisRef:INotification = null;
         thisRef = this;
         var lang:Language = Language.getInstance();
         var dlg:EventAlertDialogue = new EventAlertDialogue("images/ui/event-bounty.jpg",110,110,"left","bounty-added");
         dlg.addTitle(lang.getString("bounty_added_title"),BaseDialogue.TITLE_COLOR_GREY);
         dlg.addBody(lang.getString("bounty_added_msg"));
         dlg.addButton(lang.getString("bounty_added_ok"),true,{"width":90});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            _closed.dispatch(thisRef);
         });
         dlg.open();
         Audio.sound.play("sound/interface/bounty-general.mp3");
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
         return NotificationType.BOUNTY_ADDED;
      }
      
      public function get data() : *
      {
         return null;
      }
   }
}

