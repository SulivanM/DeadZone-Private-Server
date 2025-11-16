package thelaststand.app.game.data.notification
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.game.gui.dialogues.QuestsDialogue;
   import thelaststand.app.game.logic.GlobalQuestSystem;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class QuestCompleteNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:Quest;
      
      private var _closed:Signal;
      
      private var _dialogue:EventAlertDialogue;
      
      public function QuestCompleteNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         if(param1.indexOf("$global") == 0)
         {
            param1 = param1.replace("$global","");
            this._data = GlobalQuestSystem.getInstance().getQuestById(param1);
         }
         else
         {
            this._data = QuestSystem.getInstance().getQuestOrAchievementById(param1);
         }
         if(this._data != null)
         {
            this._data.rewardCollected.addOnce(this.onQuestCollected);
            this._active = this._data.important;
         }
      }
      
      public function open() : void
      {
         var lang:Language;
         var questName:String;
         var strBody:String;
         var thisRef:INotification = null;
         var dlg:EventAlertDialogue = null;
         if(this._data == null || this._data.collected)
         {
            if(this._data != null)
            {
               this._data.rewardCollected.remove(this.onQuestCollected);
            }
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         questName = this._data.getName();
         strBody = lang.getString(this._data.id + "_complete");
         if(strBody == "?")
         {
            strBody = lang.getString("quest_complete_msg");
         }
         dlg = this._dialogue = new EventAlertDialogue(this._data.imageCompleteURI,110,110,"left","quest-complete");
         dlg.addTitle(lang.getString("quest_complete_title"),Quest.getColor("general"));
         dlg.addTitleIcon(new BmpIconHUDObjectives());
         dlg.addSubtitle(questName);
         dlg.addBody(strBody);
         dlg.addButton(lang.getString("quest_complete_view"),false,{"width":126}).clicked.addOnce(function(param1:MouseEvent):void
         {
            dlg.close();
            var _loc2_:QuestsDialogue = new QuestsDialogue("tasks",_data);
            _loc2_.open();
         });
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            if(_data != null)
            {
               _data.rewardCollected.remove(onQuestCollected);
            }
            _dialogue = null;
            _closed.dispatch(thisRef);
         });
         dlg.open();
      }
      
      private function onQuestCollected(param1:Quest) : void
      {
         if(this._data != null)
         {
            this._data.rewardCollected.remove(this.onQuestCollected);
         }
         NotificationSystem.getInstance().removeNotification(this);
         if(this._dialogue != null)
         {
            this._dialogue.close();
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
         return NotificationType.QUEST_COMPLETE;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

