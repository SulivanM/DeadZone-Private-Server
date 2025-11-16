package thelaststand.app.game.data.notification
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.gui.buttons.AbstractButton;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class AllianceRoundWinnerNotification implements INotification
   {
      
      private var _active:Boolean = true;
      
      private var _closed:Signal;
      
      private var _data:Object;
      
      public function AllianceRoundWinnerNotification(param1:Object)
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
         var msg:String;
         var collectBtn:AbstractButton;
         var thisRef:INotification = null;
         if(this._data == null)
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
         dlg = new EventAlertDialogue("images/alliances/alliance-roundWinner.jpg",110,110,"left","alliance-roundWinner");
         dlg.addTitle(lang.getString("alliance_winner_title"),BaseDialogue.TITLE_COLOR_GREEN);
         msg = lang.getString("alliance_winner_msg");
         msg = msg.replace("%allianceRank",this.data.allianceRank + 1);
         msg = msg.replace("%memberRank",this.data.memberRank + 1);
         msg = msg.replace("%reward",this.data.reward);
         msg = msg.replace("%round",this.data.round);
         dlg.addBody(msg);
         collectBtn = dlg.addButton(lang.getString("alliance_winner_collect"),true,{
            "width":90,
            "backgroundColor":PurchasePushButton.DEFAULT_COLOR
         });
         collectBtn.clicked.addOnce(this.openAllianceHistory);
         dlg.addButton(lang.getString("alliance_winner_ok"),true,{"width":90});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            _closed.dispatch(thisRef);
         });
         dlg.open();
      }
      
      private function openAllianceHistory(param1:MouseEvent) : void
      {
         var _loc2_:AllianceDialogue = DialogueManager.getInstance().getDialogueById("allianceDialogue") as AllianceDialogue;
         if(_loc2_)
         {
            _loc2_.showPage(AllianceDialogue.ID_HISTORY);
         }
         else
         {
            _loc2_ = new AllianceDialogue(AllianceDialogue.ID_HISTORY);
            _loc2_.open();
         }
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
         return NotificationType.ALLIANCE_WINNINGS;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

