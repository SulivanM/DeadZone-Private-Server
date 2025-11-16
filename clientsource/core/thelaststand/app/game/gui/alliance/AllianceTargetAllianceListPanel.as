package thelaststand.app.game.gui.alliance
{
   import flash.display.Sprite;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.AllianceOpponentMemberListDialogue;
   import thelaststand.app.game.gui.lists.UIAllianceList;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.common.lang.Language;
   
   public class AllianceTargetAllianceListPanel extends Sprite
   {
      
      private var _width:Number = 495;
      
      private var _listHeight:Number = 350;
      
      private var list:UIAllianceList;
      
      private var controls:UIPagination;
      
      private var busySpinner:UIBusySpinner;
      
      private var disposed:Boolean = false;
      
      public var defaultPageNum:int = 0;
      
      public function AllianceTargetAllianceListPanel()
      {
         super();
         this.list = new UIAllianceList(Language.getInstance().getString("alliance.viewtarget_title"));
         this.list.width = this._width;
         this.list.height = this._listHeight;
         this.list.viewAlliance.add(this.onViewAlliance);
         addChild(this.list);
         this.busySpinner = new UIBusySpinner();
         this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
         this.busySpinner.x = int(this._width * 0.5);
         this.busySpinner.y = int(this._listHeight * 0.5);
         addChild(this.busySpinner);
         AllianceSystem.getInstance().getAllianceTargetList(48,this.onListCollected);
      }
      
      public function dispose() : void
      {
         this.disposed = true;
         this.list.dispose();
         this.busySpinner.dispose();
         this.list.viewAlliance.remove(this.onViewAlliance);
         if(this.controls)
         {
            this.controls.dispose();
         }
      }
      
      private function onListCollected(param1:AllianceList) : void
      {
         if(this.disposed)
         {
            return;
         }
         if(this.busySpinner.parent)
         {
            this.busySpinner.parent.removeChild(this.busySpinner);
         }
         if(param1 == null)
         {
            return;
         }
         this.list.allianceList = param1;
         this.controls = new UIPagination(this.list.numPages,0);
         this.controls.x = int((this._width - this.controls.width) * 0.5);
         this.controls.y = this._listHeight + 7;
         this.controls.changed.add(this.onPageChange);
         addChild(this.controls);
         this.list.gotoPage(this.defaultPageNum);
         this.controls.currentPage = this.defaultPageNum;
      }
      
      private function onViewAlliance(param1:AllianceDataSummary) : void
      {
         var _loc2_:AllianceOpponentMemberListDialogue = new AllianceOpponentMemberListDialogue(param1.id,param1.name,param1.tag);
         _loc2_.open();
      }
      
      private function onPageChange(param1:int) : void
      {
         AllianceDialogState.getInstance().alliancePage = param1;
         this.list.gotoPage(param1);
      }
   }
}

