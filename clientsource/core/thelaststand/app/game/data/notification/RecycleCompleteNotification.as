package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.gui.dialogues.RecycleItemsDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   
   public class RecycleCompleteNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:BatchRecycleJob;
      
      private var _closed:Signal;
      
      public function RecycleCompleteNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = Network.getInstance().playerData.batchRecycleJobs.getJobById(param1);
      }
      
      public function open() : void
      {
         var msg:RecycleItemsDialogue;
         var thisRef:INotification = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         msg = new RecycleItemsDialogue(this._data);
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
         return NotificationType.BATCH_RECYCLE_COMPLETE;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

