package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.lists.UIAllianceViewMemberList;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   
   public class AllianceViewMemberListDialogue extends BaseDialogue
   {
      private var _lang:Language;
      
      private var mc_container:Sprite = new Sprite();
      
      private var list:UIAllianceViewMemberList;
      
      private var controls:UIPagination;
      
      private var busySpinner:UIBusySpinner;
      
      private var disposed:Boolean = false;
      
      private var applyDialogState:Boolean = false;
      
      public function AllianceViewMemberListDialogue(param1:String, param2:String = "", param3:String = "")
      {
         super("alliance-viewMemberList",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 414;
         _height = 398;
         var _loc4_:String = this._lang.getString("alliance.opponentList_title");
         if(param2 != "")
         {
            _loc4_ += " - " + param2;
            if(param3 != "")
            {
               _loc4_ += " [" + param3 + "]";
            }
         }
         addTitle(_loc4_,TITLE_COLOR_RUST);
         var _loc5_:int = _padding * 0.5;
         this.list = new UIAllianceViewMemberList();
         this.list.x = 0;
         this.list.y = _loc5_;
         this.list.actioned.add(this.onActioned);
         this.mc_container.addChild(this.list);
         this.busySpinner = new UIBusySpinner();
         this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
         this.busySpinner.x = int(this.list.x + this.list.width * 0.5);
         this.busySpinner.y = int(this.list.y + this.list.height * 0.5);
         this.mc_container.addChild(this.busySpinner);
         AllianceSystem.getInstance().getOpponentMemberList(param1,this.onMemberListLoaded);
         AllianceSystem.getInstance().roundEnded.add(this.onRoundEnded);
         var _loc6_:AllianceDialogState = AllianceDialogState.getInstance();
         _loc6_.allianceId = param1;
         _loc6_.allianceName = param2;
         _loc6_.allianceTag = param3;
         this.applyDialogState = _loc6_.allianceDialogReturnType != AllianceDialogState.SHOW_NONE;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.disposed = true;
         this.list.dispose();
         this.busySpinner.dispose();
         if(this.controls)
         {
            this.controls.dispose();
         }
         AllianceSystem.getInstance().roundEnded.remove(this.onRoundEnded);
      }
      
      private function onMemberListLoaded(param1:AllianceMemberList) : void
      {
         if(this.disposed == true)
         {
            return;
         }
         if(this.busySpinner.parent)
         {
            this.busySpinner.parent.removeChild(this.busySpinner);
         }
         this.list.members = param1;
         this.controls = new UIPagination(this.list.numPages,0);
         this.controls.x = int((_width - this.controls.width) * 0.5);
         this.controls.y = this.list.y + this.list.height + 7;
         this.controls.changed.add(this.onPageChange);
         this.mc_container.addChild(this.controls);
         if(this.applyDialogState)
         {
            this.list.applyDialogState();
            this.list.gotoPage(AllianceDialogState.getInstance().playerPage);
            this.controls.currentPage = this.list.currentPage;
         }
      }
      
      private function onPageChange(param1:int) : void
      {
         this.list.gotoPage(param1);
      }
      
      private function onActioned(param1:RemotePlayerData, param2:String) : void
      {
         var _loc3_:AllianceDialogState = AllianceDialogState.getInstance();
         _loc3_.playerPage = this.list.currentPage;
         _loc3_.allianceDialogReturnType = AllianceDialogState.SHOW_TOP_100;
         this.list.writeDialogState();
         switch(param2)
         {
            case "view":
            case "help":
               _loc3_.viewingFromWars = true;
               Tracking.trackEvent("OpponentMemberList","View",param1.isFriend ? "friend" : "unknown");
               this.mc_container.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.NEIGHBOR_COMPOUND,param1));
         }
         close();
      }
      
      private function onRoundEnded() : void
      {
         close();
      }
   }
}
