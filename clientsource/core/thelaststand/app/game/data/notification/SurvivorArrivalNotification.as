package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class SurvivorArrivalNotification implements INotification
   {
      
      private var _active:Boolean = true;
      
      private var _data:Survivor;
      
      private var _closed:Signal;
      
      public function SurvivorArrivalNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = Network.getInstance().playerData.compound.survivors.getSurvivorById(param1);
      }
      
      public function open() : void
      {
         var lang:Language;
         var dlg:EventAlertDialogue;
         var thisRef:INotification = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         DialogueManager.getInstance().closeDialogue("buy-new-survivor");
         dlg = new EventAlertDialogue("images/ui/event-new-survivor.jpg",270,152,"left","event-survivor-arrive");
         dlg.addTitle(lang.getString("srv_arrive_title"),2271965);
         dlg.addSubtitle(this._data.fullName.toUpperCase());
         dlg.addBody(lang.getString("srv_arrive_msg"));
         dlg.addButton(lang.getString("srv_arrive_ok"),true,{"width":106});
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
         return NotificationType.SURVIVOR_ARRIVED;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

