package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.gui.dialogues.MissionReportDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class MissionReturnNotification implements INotification
   {
      
      private var _active:Boolean = true;
      
      private var _data:MissionData;
      
      private var _closed:Signal;
      
      public function MissionReturnNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = Network.getInstance().playerData.missionList.getMissionById(param1);
         if(this._data != null)
         {
            this._active = !this._data.automated;
         }
      }
      
      public function open() : void
      {
         var lang:Language;
         var dlg:MissionReportDialogue;
         var thisRef:INotification = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         dlg = new MissionReportDialogue(this._data);
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
         return NotificationType.MISSION_RETURN;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

