package thelaststand.app.game.gui.alliance
{
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.lists.UIAllianceMemberLeaderboardList;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.common.lang.Language;
   
   public class AllianceMemberLeaderboard extends Sprite
   {
      
      private var _width:Number = 495;
      
      private var _listHeight:Number = 350;
      
      private var list:UIAllianceMemberLeaderboardList;
      
      private var controls:UIPagination;
      
      private var busySpinner:UIBusySpinner;
      
      private var disposed:Boolean = false;
      
      private var txt_empty:BodyTextField;
      
      private var _round:int = -1;
      
      public function AllianceMemberLeaderboard(param1:int)
      {
         super();
         this.list = new UIAllianceMemberLeaderboardList();
         addChild(this.list);
         this.list.width = this._width;
         this.list.height = this._listHeight;
         this.busySpinner = new UIBusySpinner();
         this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
         this.busySpinner.x = int(this._width * 0.5);
         this.busySpinner.y = int(this._listHeight * 0.5);
         addChild(this.busySpinner);
         this.txt_empty = new BodyTextField({
            "text":Language.getInstance().getString("alliance.members_nonRecords"),
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_empty.x = int((this._width - this.txt_empty.width) * 0.5);
         this.txt_empty.y = int((this._listHeight - this.txt_empty.height) * 0.5);
         this._round = param1;
         AllianceSystem.getInstance().getMemberLeaderboard(this._round,this.onListCollected);
      }
      
      public function dispose() : void
      {
         this.disposed = true;
         this.list.dispose();
         this.busySpinner.dispose();
         this.txt_empty.dispose();
         if(this.controls)
         {
            this.controls.dispose();
         }
      }
      
      private function onListCollected(param1:AllianceMemberList) : void
      {
         if(this.disposed)
         {
            return;
         }
         if(this.busySpinner.parent)
         {
            this.busySpinner.parent.removeChild(this.busySpinner);
         }
         if(param1 == null || param1.numMembers == 0)
         {
            addChild(this.txt_empty);
            this.list.members = null;
            return;
         }
         this.list.members = param1;
         this.controls = new UIPagination(this.list.numPages,0);
         this.controls.x = int((this._width - this.controls.width) * 0.5);
         this.controls.y = this._listHeight + 7;
         this.controls.changed.add(this.onPageChange);
         addChild(this.controls);
      }
      
      private function onPageChange(param1:int) : void
      {
         this.list.gotoPage(param1);
      }
      
      public function get round() : int
      {
         return this._round;
      }
      
      public function set round(param1:int) : void
      {
         if(param1 < -1)
         {
            param1 = -1;
         }
         if(param1 == this._round)
         {
            return;
         }
         this._round = param1;
         addChild(this.busySpinner);
         this.list.members = null;
         AllianceSystem.getInstance().getMemberLeaderboard(this._round,this.onListCollected);
      }
   }
}

