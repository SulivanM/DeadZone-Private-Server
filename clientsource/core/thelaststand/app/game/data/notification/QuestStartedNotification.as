package thelaststand.app.game.data.notification
{
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.game.gui.dialogues.QuestsDialogue;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class QuestStartedNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:Quest;
      
      private var _closed:Signal;
      
      public function QuestStartedNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = QuestSystem.getInstance().getQuestOrAchievementById(param1);
         this._active = this._data.important;
      }
      
      public function open() : void
      {
         var lang:Language;
         var thisRef:INotification = null;
         var dlg:EventAlertDialogue = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         dlg = new EventAlertDialogue(this._data.imageStartURI,110,110,"left","quest-started");
         dlg.addTitle(this._data.getName(),BaseDialogue.TITLE_COLOR_GREY);
         dlg.addTitleIcon(new BmpIconHUDObjectives());
         dlg.addBody(this._data.getDescription());
         dlg.addButton(lang.getString("quest_new_ok"),true,{"width":90});
         dlg.addButton(lang.getString("quest_new_track"),false,{
            "icon":new Bitmap(new BmpIconQuestTracking()),
            "iconBackgroundColor":Quest.getColor("general"),
            "width":106
         }).clicked.addOnce(function(param1:MouseEvent):void
         {
            dlg.close();
            var _loc2_:QuestsDialogue = new QuestsDialogue("tasks",_data);
            _loc2_.open();
         });
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
         return NotificationType.QUEST_STARTED;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

