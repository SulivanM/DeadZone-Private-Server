package thelaststand.app.game.gui.task
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskStatus;
   import thelaststand.app.game.data.task.JunkRemovalTask;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.common.lang.Language;
   
   public class UITaskTaskItem extends UITaskItem
   {
      
      private var _task:Task;
      
      public function UITaskTaskItem(param1:Task)
      {
         super();
         _priority = TaskItemPriority.General;
         this._task = _target = param1;
         this._task.statusChanged.add(this.onTaskStatusChanged);
         setIcon(12029964,new BmpIconButtonBuild());
         this.onTaskStatusChanged(this._task);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._task.statusChanged.remove(this.onTaskStatusChanged);
         this._task = null;
      }
      
      override public function update() : void
      {
         if(this._task == null || this._task.status != TaskStatus.ACTIVE)
         {
            return;
         }
         setTime(this._task.getSecondsRemaining());
         setProgress(this._task.time / this._task.length);
      }
      
      private function onTaskStatusChanged(param1:Task) : void
      {
         var _loc2_:Language = Language.getInstance();
         setLabel(_loc2_.getString("survivor_tasks." + this._task.type) + (this._task.status == TaskStatus.INACTIVE ? " - " + _loc2_.getString("bld_onhold") : ""));
         setTime(this._task.getSecondsRemaining());
         setProgress(this._task.time / this._task.length);
      }
      
      override protected function handleClick() : void
      {
         var _loc1_:JunkRemovalTask = this._task as JunkRemovalTask;
         if(_loc1_ != null)
         {
            if(stage != null && _loc1_.target != null)
            {
               stage.dispatchEvent(new GameEvent(GameEvent.CENTER_ON_ENTITY,true,false,_loc1_.target.entity));
            }
            Audio.sound.play("sound/interface/int-click.mp3");
         }
      }
   }
}

