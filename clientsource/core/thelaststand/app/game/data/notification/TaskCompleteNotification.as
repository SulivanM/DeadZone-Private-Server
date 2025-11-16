package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.task.JunkRemovalTask;
   import thelaststand.app.game.gui.dialogues.JunkItemsDialogue;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class TaskCompleteNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:Task;
      
      private var _closed:Signal;
      
      public function TaskCompleteNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = Network.getInstance().playerData.compound.tasks.getTaskById(param1);
      }
      
      public function open() : void
      {
         var lang:Language;
         var thisRef:INotification = null;
         var msg:BaseDialogue = null;
         var junkTask:JunkRemovalTask = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         if(this._data is JunkRemovalTask)
         {
            junkTask = JunkRemovalTask(this._data);
            msg = new JunkItemsDialogue(junkTask.items,junkTask.getXP(),true);
         }
         if(msg != null)
         {
            msg.closed.addOnce(function(param1:Dialogue):void
            {
               _closed.dispatch(thisRef);
            });
            msg.open();
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
         return NotificationType.TASK_COMPLETE;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

