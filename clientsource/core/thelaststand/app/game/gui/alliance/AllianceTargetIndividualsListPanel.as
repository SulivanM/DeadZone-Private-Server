package thelaststand.app.game.gui.alliance
{
   import flash.display.Sprite;
   import flash.events.Event;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.alliance.AllianceMemberList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.lists.UIAllianceOpponentMemberList;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.network.RemotePlayerData;
   
   public class AllianceTargetIndividualsListPanel extends Sprite
   {
      
      private var _width:Number = 495;
      
      private var _listHeight:Number = 350;
      
      private var list:UIAllianceOpponentMemberList;
      
      private var controls:UIPagination;
      
      private var busySpinner:UIBusySpinner;
      
      private var disposed:Boolean = false;
      
      public function AllianceTargetIndividualsListPanel()
      {
         super();
         this.list = new UIAllianceOpponentMemberList();
         this.list.actioned.add(this.onActioned);
         addChild(this.list);
         this.busySpinner = new UIBusySpinner();
         this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
         this.busySpinner.x = int(this._width * 0.5);
         this.busySpinner.y = int(this._listHeight * 0.5);
         this.controls = new UIPagination(1,0);
         this.controls.changed.add(this.onPageChange);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         this.disposed = true;
         this.list.actioned.remove(this.onActioned);
         this.list.dispose();
         this.busySpinner.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this.controls)
         {
            this.controls.dispose();
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addChild(this.busySpinner);
         if(this.controls.parent)
         {
            this.controls.parent.removeChild(this.controls);
         }
         AllianceSystem.getInstance().getIndividualTargetsList(40,this.onTargetListReceived);
      }
      
      private function onTargetListReceived(param1:AllianceMemberList) : void
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
            if(this.list.members)
            {
               this.list.members.clear();
            }
            return;
         }
         addChild(this.controls);
         if(this.list.members == param1)
         {
            return;
         }
         this.list.members = param1;
         this.controls.numPages = this.list.numPages;
         this.controls.x = int((this._width - this.controls.width) * 0.5);
         this.controls.y = this._listHeight + 7;
         var _loc2_:int = 0;
         var _loc3_:AllianceDialogState = AllianceDialogState.getInstance();
         if(_loc3_.allianceDialogReturnType == AllianceDialogState.SHOW_INDIVIDUALS)
         {
            _loc2_ = _loc3_.playerPage;
            this.list.applyDialogState();
         }
         this.controls.currentPage = _loc2_;
         this.list.gotoPage(_loc2_);
      }
      
      private function onPageChange(param1:int) : void
      {
         AllianceDialogState.getInstance().alliancePage = param1;
         this.list.gotoPage(param1);
      }
      
      private function onActioned(param1:RemotePlayerData, param2:String) : void
      {
         var target:RemotePlayerData = param1;
         var action:String = param2;
         var dlgState:AllianceDialogState = AllianceDialogState.getInstance();
         dlgState.playerPage = this.list.currentPage;
         dlgState.allianceDialogReturnType = AllianceDialogState.SHOW_INDIVIDUALS;
         dlgState.alliancePage = this.list.currentPage;
         this.list.writeDialogState();
         switch(action)
         {
            case "attack":
               target.attemptAttack(true,function(param1:Boolean):void
               {
                  if(param1)
                  {
                     Tracking.trackEvent("IndividualWarTarget","Attack",target.isFriend ? "friend" : "unknown");
                  }
                  AllianceSystem.getInstance().touchIndividualTargetCacheTime();
               });
               return;
            case "view":
            case "help":
               dlgState.viewingFromWars = true;
               AllianceSystem.getInstance().touchIndividualTargetCacheTime();
               Tracking.trackEvent("IndividualWarTarget","View",target.isFriend ? "friend" : "unknown");
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.NEIGHBOR_COMPOUND,target));
         }
      }
   }
}

