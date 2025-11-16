package thelaststand.app.game.gui.task
{
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.gui.dialogues.RecycleItemsDialogue;
   import thelaststand.common.lang.Language;
   
   public class UIRecycleJobTaskItem extends UITaskItem
   {
      
      private var _job:BatchRecycleJob;
      
      private var _timer:TimerData;
      
      public function UIRecycleJobTaskItem(param1:BatchRecycleJob)
      {
         super();
         _priority = TaskItemPriority.RecycleJob;
         this._job = _target = param1;
         this._timer = this._job.timer;
         if(this._timer != null)
         {
            setLabel(Language.getInstance().getString("tasks.batch_recycle"));
         }
         setIcon(3183890,new BmpIconRecycle());
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._job = null;
         this._timer = null;
      }
      
      override public function update() : void
      {
         if(this._timer == null)
         {
            return;
         }
         setTime(this._timer.getSecondsRemaining());
         setProgress(this._timer.getProgress());
      }
      
      override protected function handleClick() : void
      {
         var _loc1_:RecycleItemsDialogue = new RecycleItemsDialogue(this._job);
         _loc1_.open();
      }
   }
}

