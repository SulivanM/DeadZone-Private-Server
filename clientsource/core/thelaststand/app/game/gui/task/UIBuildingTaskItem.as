package thelaststand.app.game.gui.task
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.common.lang.Language;
   
   public class UIBuildingTaskItem extends UITaskItem
   {
      
      private var _building:Building;
      
      private var _level:int;
      
      private var _timer:TimerData;
      
      public function UIBuildingTaskItem(param1:Building)
      {
         super();
         _priority = TaskItemPriority.BuildingConstruction;
         this._building = _target = param1;
         this._timer = this._building.upgradeTimer;
         if(this._timer != null)
         {
            this._level = this._timer.data.level;
            setLabel(this._building.getName() + " - " + Language.getInstance().getString("lvl",this._level + 1));
         }
         setIcon(12029964,new BmpIconButtonBuild());
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._building = null;
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
         if(stage != null && this._building != null)
         {
            stage.dispatchEvent(new GameEvent(GameEvent.CENTER_ON_ENTITY,true,false,this._building.entity));
            Audio.sound.play("sound/interface/int-click.mp3");
         }
      }
   }
}

