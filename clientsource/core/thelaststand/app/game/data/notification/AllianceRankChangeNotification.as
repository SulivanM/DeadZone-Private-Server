package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class AllianceRankChangeNotification implements INotification
   {
      
      private var _active:Boolean = true;
      
      private var _closed:Signal;
      
      private var _data:Object;
      
      public function AllianceRankChangeNotification(param1:Object)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = param1;
      }
      
      public function open() : void
      {
         var lang:Language;
         var rankName:String;
         var dlg:EventAlertDialogue;
         var thisRef:INotification = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         if(this._data.allianceId != Network.getInstance().playerData.allianceId)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         rankName = lang.getString("alliance.rank_" + int(this._data.rank));
         if(AllianceSystem.getInstance().alliance)
         {
            rankName = AllianceSystem.getInstance().alliance.getRankName(int(this._data.rank));
         }
         dlg = new EventAlertDialogue("images/alliances/alliance-rankchange.jpg",110,110,"left","alliance-rankChange");
         dlg.addTitle(lang.getString("alliance_rank_title"),BaseDialogue.TITLE_COLOR_GREY);
         dlg.addBody(lang.getString("alliance_rank_msg",rankName));
         dlg.addButton(lang.getString("alliance_rank_ok"),true,{"width":90});
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
         return NotificationType.ALLIANCE_RANK_CHANGE;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

