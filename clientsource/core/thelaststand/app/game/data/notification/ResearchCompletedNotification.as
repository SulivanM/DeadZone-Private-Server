package thelaststand.app.game.data.notification
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class ResearchCompletedNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _closed:Signal;
      
      private var _data:Object;
      
      public function ResearchCompletedNotification(param1:Object)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = param1;
      }
      
      public function open() : void
      {
         var level:int;
         var xml:XML;
         var lang:Language;
         var name:String;
         var dlg:EventAlertDialogue;
         var category:String = null;
         var group:String = null;
         var thisRef:INotification = null;
         if(this.data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         category = String(this.data.category);
         group = String(this.data.group);
         level = int(this.data.level);
         xml = ResearchSystem.getCategoryGroupXML(category,group);
         if(xml == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         name = ResearchSystem.getCategoryGroupName(category,group,level);
         dlg = new EventAlertDialogue("images/ui/event-research-complete.jpg",110,110,"left","research-complete");
         dlg.addTitle(lang.getString("research_notification_title"),6469334);
         dlg.addBody(lang.getString("research_notification_msg",name));
         dlg.addButton(lang.getString("research_notification_open"),true).clicked.addOnce(function(param1:MouseEvent):void
         {
            DialogueController.getInstance().openResearch(category,group);
         });
         dlg.addButton(lang.getString("research_notification_ok"),true,{"width":60});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            _closed.dispatch(thisRef);
         });
         dlg.open();
         Audio.sound.play("sound/interface/research-start.mp3");
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
         return NotificationType.RESEARCH_COMPLETED;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

