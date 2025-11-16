package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.gui.lists.UISurvivorList;
   import thelaststand.app.gui.UIPagination;
   
   public class MissionReportSurvivors extends Sprite
   {
      
      private var _missionData:MissionData;
      
      private var _width:int = 328;
      
      private var ui_list:UISurvivorList;
      
      private var ui_page:UIPagination;
      
      public function MissionReportSurvivors(param1:MissionData)
      {
         super();
         this._missionData = param1;
         if(this._missionData.returnTimer != null)
         {
            this._missionData.returnTimer.completed.addOnce(this.onMissionCompleted);
         }
         this.ui_list = new UISurvivorList(false);
         this.ui_list.width = this._width;
         this.ui_list.height = 275;
         this.ui_list.survivorList = this._missionData.survivors;
         addChild(this.ui_list);
         this.ui_page = new UIPagination(this.ui_list.numPages);
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 9);
         this.ui_page.changed.add(this.onPageChanged);
         addChild(this.ui_page);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._missionData.returnTimer != null)
         {
            this._missionData.returnTimer.completed.remove(this.onMissionCompleted);
         }
         this._missionData = null;
         this.ui_list.dispose();
         this.ui_page.dispose();
      }
      
      public function updateSurvivorList() : void
      {
         this.ui_list.survivorList = this._missionData.survivors;
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
      
      private function onMissionCompleted(param1:TimerData) : void
      {
      }
   }
}

