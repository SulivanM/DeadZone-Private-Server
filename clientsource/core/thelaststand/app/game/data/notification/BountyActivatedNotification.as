package thelaststand.app.game.data.notification
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.gui.dialogues.BountyListDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class BountyActivatedNotification implements INotification
   {
      
      private var _active:Boolean = true;
      
      private var _closed:Signal;
      
      private var _data:Object;
      
      private var _allowOpen:Boolean;
      
      public function BountyActivatedNotification(param1:Object)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = param1;
         this._allowOpen = this._data == null || this._data.allowOpen !== false;
      }
      
      public function open() : void
      {
         var thisRef:INotification = null;
         var dlg:EventAlertDialogue = null;
         thisRef = this;
         var lang:Language = Language.getInstance();
         dlg = new EventAlertDialogue("images/ui/event-bounty.jpg",110,110,"left","bounty-activated");
         dlg.addTitle(lang.getString("bounty_active_title"),BaseDialogue.TITLE_COLOR_GREY);
         dlg.addBody(lang.getString("bounty_active_msg"));
         if(this._allowOpen)
         {
            dlg.addButton(lang.getString("bounty_active_open"),false,{"width":106}).clicked.addOnce(function(param1:MouseEvent):void
            {
               dlg.close();
               var _loc2_:BountyListDialogue = new BountyListDialogue();
               _loc2_.open();
            });
         }
         dlg.addButton(lang.getString("bounty_active_ok"),true,{"width":90});
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
         return NotificationType.BOUNTY_ACTIVATED;
      }
      
      public function get data() : *
      {
         return null;
      }
   }
}

