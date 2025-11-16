package thelaststand.app.game.gui.task
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Global;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.common.lang.Language;
   
   public class UIResearchTaskItem extends UITaskItem
   {
      
      private var _researchTask:ResearchTask;
      
      public function UIResearchTaskItem(param1:ResearchTask)
      {
         super();
         _priority = TaskItemPriority.Research;
         _showSpeedUp = false;
         this._researchTask = _target = param1;
         var _loc2_:String = ResearchSystem.getCategoryGroupName(this._researchTask.category,this._researchTask.group,this._researchTask.level);
         setLabel(Language.getInstance().getString("research_task",_loc2_));
         setIcon(1921640,new BmpIconResearchSmall());
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._researchTask = null;
      }
      
      override public function update() : void
      {
         if(this._researchTask == null)
         {
            return;
         }
         setTime(this._researchTask.timeReamining);
         setProgress(this._researchTask.progress);
      }
      
      override protected function handleClick() : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
         if(Global.game.location == NavigationLocation.PLAYER_COMPOUND || Global.game.location == NavigationLocation.WORLD_MAP)
         {
            DialogueController.getInstance().openResearch(this._researchTask.category,this._researchTask.group);
         }
      }
   }
}

