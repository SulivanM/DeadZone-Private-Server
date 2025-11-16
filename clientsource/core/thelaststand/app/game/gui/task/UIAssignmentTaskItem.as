package thelaststand.app.game.gui.task
{
   import thelaststand.app.core.Global;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.gui.arena.ArenaDialogue;
   import thelaststand.app.game.gui.raid.RaidDialogue;
   import thelaststand.common.lang.Language;
   
   public class UIAssignmentTaskItem extends UITaskItem
   {
      
      private var _assignment:AssignmentData;
      
      public function UIAssignmentTaskItem(param1:AssignmentData)
      {
         super();
         _priority = TaskItemPriority.RaidMission;
         this._assignment = param1;
         _target = param1;
         _showSpeedUp = false;
         var _loc2_:Language = Language.getInstance();
         var _loc3_:RaidData = this._assignment as RaidData;
         if(_loc3_ != null)
         {
            setLabel(_loc2_.getString("raid.title",_loc2_.getString("raid." + _loc3_.name + ".name")));
            setIcon(RaidDialogue.COLOR,new BmpIconSkull());
         }
         var _loc4_:ArenaSession = this._assignment as ArenaSession;
         if(_loc4_ != null)
         {
            setLabel(_loc2_.getString("arena.title",_loc2_.getString("arena." + _loc4_.name + ".name")));
            setIcon(RaidDialogue.COLOR,new BmpIconSkull());
         }
         setTime(-1);
         setProgress(0);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._assignment = null;
      }
      
      override protected function handleClick() : void
      {
         if(Global.game.zombieAttackImminent)
         {
            return;
         }
         if(Global.game.location == NavigationLocation.PLAYER_COMPOUND || Global.game.location == NavigationLocation.WORLD_MAP)
         {
            this.runClickHandler();
         }
      }
      
      private function runClickHandler() : void
      {
         var _loc3_:RaidDialogue = null;
         var _loc4_:ArenaDialogue = null;
         var _loc1_:RaidData = this._assignment as RaidData;
         if(_loc1_ != null)
         {
            _loc3_ = new RaidDialogue(this._assignment);
            _loc3_.open();
            return;
         }
         var _loc2_:ArenaSession = this._assignment as ArenaSession;
         if(_loc2_ != null)
         {
            _loc4_ = new ArenaDialogue(this._assignment);
            _loc4_.open();
            return;
         }
      }
   }
}

