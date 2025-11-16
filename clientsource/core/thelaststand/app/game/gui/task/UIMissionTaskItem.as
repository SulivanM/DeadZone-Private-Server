package thelaststand.app.game.gui.task
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.gui.dialogues.MissionReportDialogue;
   import thelaststand.common.lang.Language;
   
   public class UIMissionTaskItem extends UITaskItem
   {
      
      private var _mission:MissionData;
      
      private var _timer:TimerData;
      
      private var _hazardBD:BitmapData;
      
      private var _hazardShape:Shape;
      
      public function UIMissionTaskItem(param1:MissionData)
      {
         var _loc2_:Language = null;
         var _loc3_:String = null;
         var _loc4_:Graphics = null;
         super();
         _priority = TaskItemPriority.MissionReturn;
         this._mission = _target = param1;
         this._timer = this._mission.returnTimer;
         if(this._timer != null)
         {
            _loc2_ = Language.getInstance();
            _loc3_ = this._mission.opponent.isPlayer ? _loc2_.getString("tasks.compound_raid") : _loc2_.getString("suburbs." + this._mission.suburb);
            setLabel(_loc2_.getString("mission") + " - " + _loc3_);
         }
         setIcon(9972236,new BmpIconClass_fighter());
         if(param1.highActivityIndex > -1)
         {
            this._hazardBD = new BmpRedHazardTile();
            this._hazardShape = new Shape();
            _loc4_ = this._hazardShape.graphics;
            _loc4_.beginBitmapFill(this._hazardBD,null,true);
            _loc4_.drawRect(0,0,mc_iconBackground.width,mc_iconBackground.height);
            _loc4_.endFill();
            this._hazardShape.alpha = 0.7;
            addChildAt(this._hazardShape,getChildIndex(mc_iconBackground) + 1);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._mission = null;
         this._timer = null;
         if(this._hazardBD != null)
         {
            this._hazardBD.dispose();
         }
         this._hazardBD = null;
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
         var _loc1_:MissionReportDialogue = new MissionReportDialogue(this._mission);
         _loc1_.open();
      }
      
      override protected function positionElements() : void
      {
         super.positionElements();
         if(this._hazardShape != null)
         {
            this._hazardShape.x = mc_iconBackground.x;
            this._hazardShape.y = mc_iconBackground.y;
         }
      }
   }
}

