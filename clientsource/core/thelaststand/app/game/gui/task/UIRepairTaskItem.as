package thelaststand.app.game.gui.task
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.events.GameEvent;
   import thelaststand.common.lang.Language;
   
   public class UIRepairTaskItem extends UITaskItem
   {
      
      private var _building:Building;
      
      private var _timer:TimerData;
      
      public function UIRepairTaskItem(param1:Building)
      {
         super();
         _priority = TaskItemPriority.BuildingRepair;
         this._building = _target = param1;
         this._timer = this._building.repairTimer;
         if(this._timer != null)
         {
            setLabel(this._building.getName() + " - " + Language.getInstance().getString("lvl",this._building.level + 1));
         }
         setIcon(10830376,new BmpIconButtonRepair());
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
         if(this._building.productionResource == GameResources.CASH)
         {
            btn_speedUp.enabled = false;
         }
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

