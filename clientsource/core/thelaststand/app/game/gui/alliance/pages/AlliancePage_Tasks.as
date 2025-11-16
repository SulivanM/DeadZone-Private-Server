package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.lists.UIAllianceMemberTaskContributionList;
   import thelaststand.app.gui.UIPagination;
   
   public class AlliancePage_Tasks extends Sprite implements IAlliancePage
   {
      
      private var _dialogue:AllianceDialogue;
      
      private var ui_overview:AlliancePage_Tasks_Overview;
      
      private var ui_list:UIAllianceMemberTaskContributionList;
      
      private var ui_listPage:UIPagination;
      
      public function AlliancePage_Tasks()
      {
         super();
         this.ui_overview = new AlliancePage_Tasks_Overview();
         addChild(this.ui_overview);
         this.ui_list = new UIAllianceMemberTaskContributionList();
         this.ui_list.y = this.ui_overview.y + this.ui_overview.height + 5;
         this.ui_list.pageCountChange.add(this.onPageCountChange);
         addChild(this.ui_list);
         this.ui_listPage = new UIPagination(this.ui_list.numPages,0);
         this.ui_listPage.x = int(this.ui_list.x + (this.ui_list.width - this.ui_listPage.width) * 0.5);
         this.ui_listPage.y = this.ui_list.y + this.ui_list.height + 10;
         this.ui_listPage.changed.add(this.onListPageChanged);
         addChild(this.ui_listPage);
      }
      
      public function dispose() : void
      {
         this._dialogue = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.ui_overview.dispose();
         this.ui_list.dispose();
      }
      
      private function onListPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
      
      private function onPageCountChange() : void
      {
         this.ui_listPage.numPages = this.ui_list.numPages;
         this.ui_listPage.x = int(this.ui_list.x + (this.ui_list.width - this.ui_listPage.width) * 0.5);
      }
      
      public function get dialogue() : AllianceDialogue
      {
         return this._dialogue;
      }
      
      public function set dialogue(param1:AllianceDialogue) : void
      {
         this._dialogue = param1;
      }
   }
}

