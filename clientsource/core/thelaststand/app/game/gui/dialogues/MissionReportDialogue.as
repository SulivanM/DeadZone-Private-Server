package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class MissionReportDialogue extends BaseDialogue
   {
      
      private const PAGE_SUMMARY:String = "summary";
      
      private const PAGE_LOOT:String = "loot";
      
      private const PAGE_SURVIVORS:String = "survivors";
      
      private var _lang:Language = Language.getInstance();
      
      private var _missionData:MissionData;
      
      private var _currentPageId:String;
      
      private var _currentPage:Sprite;
      
      private var mc_container:Sprite = new Sprite();
      
      private var mc_summary:MissionReportSummary;
      
      private var mc_loot:MissionReportLoot;
      
      private var mc_survivors:MissionReportSurvivors;
      
      private var btn_summary:PushButton;
      
      private var btn_loot:PushButton;
      
      private var btn_survivors:PushButton;
      
      private var btn_return:PurchasePushButton;
      
      private var btn_ok:PushButton;
      
      public function MissionReportDialogue(param1:MissionData)
      {
         this._missionData = param1;
         super("mission-report-dialogue-" + param1.id.toUpperCase(),this.mc_container,true);
         _autoSize = false;
         _width = 358;
         _height = 434;
         _padding = 15;
         addTitle(this._lang.getString("mission_report_title"),9582109);
         var _loc2_:int = 3;
         var _loc3_:int = 12;
         var _loc4_:int = (_width - _padding * 2 - _loc3_ * (_loc2_ - 1)) / _loc2_;
         this.btn_summary = new PushButton(this._lang.getString("mission_report_btn_summary"));
         this.btn_summary.clicked.add(this.onButtonClicked);
         this.btn_summary.width = _loc4_;
         this.btn_summary.y = 10;
         this.mc_container.addChild(this.btn_summary);
         this.btn_loot = new PushButton(this._lang.getString("mission_report_btn_loot"));
         this.btn_loot.clicked.add(this.onButtonClicked);
         this.btn_loot.width = _loc4_;
         this.btn_loot.x = int(this.btn_summary.x + this.btn_summary.width + _loc3_);
         this.btn_loot.enabled = this._missionData.type == "compound" ? false : (this._missionData.automated ? this._missionData.complete : true);
         this.btn_loot.y = this.btn_summary.y;
         this.mc_container.addChild(this.btn_loot);
         this.btn_survivors = new PushButton(this._lang.getString("mission_report_btn_survivors"));
         this.btn_survivors.clicked.add(this.onButtonClicked);
         this.btn_survivors.width = _loc4_;
         this.btn_survivors.x = int(this.btn_loot.x + this.btn_loot.width + _loc3_);
         this.btn_survivors.y = this.btn_summary.y;
         this.mc_container.addChild(this.btn_survivors);
         this.btn_ok = new PushButton(this._lang.getString("mission_report_btn_ok"));
         this.btn_ok.clicked.add(this.onButtonClicked);
         this.btn_ok.x = int(_width - _padding * 2 - this.btn_ok.width);
         this.btn_ok.y = int(_height - _padding * 2 - this.btn_ok.height - 10);
         this.mc_container.addChild(this.btn_ok);
         if(this._missionData.type != "compound" && !this._missionData.complete || this._missionData.returnTimer != null && this._missionData.returnTimer.getSecondsRemaining() > 5)
         {
            this.btn_return = new PurchasePushButton(this._lang.getString("mission_report_btn_return"));
            this.btn_return.clicked.add(this.onButtonClicked);
            this.btn_return.showIcon = false;
            this.btn_return.x = int(this.btn_ok.x - this.btn_return.width - _loc3_);
            this.btn_return.y = this.btn_ok.y;
            this.mc_container.addChild(this.btn_return);
            if(this._missionData.returnTimer != null)
            {
               this._missionData.returnTimer.completed.addOnce(this.onMissionComplete);
            }
            if(this._missionData.automated)
            {
               TooltipManager.getInstance().add(this.btn_loot,this._lang.getString("mission_report_unknown"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            }
         }
         this.mc_summary = new MissionReportSummary(this._missionData);
         this.mc_loot = new MissionReportLoot(this._missionData);
         this.mc_survivors = new MissionReportSurvivors(this._missionData);
         this.gotoPage("summary");
      }
      
      override public function dispose() : void
      {
         this.mc_summary.dispose();
         this.mc_loot.dispose();
         this.mc_survivors.dispose();
         if(this._missionData != null && this._missionData.returnTimer != null)
         {
            this._missionData.returnTimer.completed.remove(this.onMissionComplete);
         }
         this._missionData = null;
         TooltipManager.getInstance().removeAllFromParent(this.mc_container,true);
         super.dispose();
      }
      
      private function gotoPage(param1:String, param2:Boolean = false) : void
      {
         if(!param2 && param1 == this._currentPageId)
         {
            return;
         }
         if(this._currentPage != null)
         {
            PushButton(this["btn_" + this._currentPageId]).selected = false;
            if(this._currentPage.parent != null)
            {
               this._currentPage.parent.removeChild(this._currentPage);
            }
            this._currentPage = null;
         }
         this._currentPageId = param1;
         switch(param1)
         {
            case this.PAGE_SUMMARY:
               this._currentPage = this.mc_summary;
               break;
            case this.PAGE_LOOT:
               this._currentPage = this.mc_loot;
               break;
            case this.PAGE_SURVIVORS:
               this._currentPage = this.mc_survivors;
         }
         if(this._currentPage != null)
         {
            this._currentPage.x = 0;
            this._currentPage.y = this.btn_summary.y + this.btn_summary.height + 14;
            this.mc_container.addChild(this._currentPage);
            PushButton(this["btn_" + this._currentPageId]).selected = true;
         }
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:SpeedUpDialogue = null;
         switch(param1.currentTarget)
         {
            case this.btn_summary:
               this.gotoPage("summary");
               break;
            case this.btn_loot:
               this.gotoPage("loot");
               break;
            case this.btn_survivors:
               this.gotoPage("survivors");
               break;
            case this.btn_ok:
               close();
               break;
            case this.btn_return:
               _loc2_ = new SpeedUpDialogue(this._missionData);
               _loc2_.open();
         }
      }
      
      private function onMissionComplete(param1:TimerData) : void
      {
         if(this.btn_return.parent != null)
         {
            this.btn_return.parent.removeChild(this.btn_return);
         }
         this.btn_loot.enabled = true;
         TooltipManager.getInstance().remove(this.btn_loot);
         this.mc_loot.updateLootList();
         this.mc_survivors.updateSurvivorList();
         this.mc_summary = new MissionReportSummary(this._missionData);
         if(this._currentPageId == "summary")
         {
            this.gotoPage("summary");
         }
         if(this.btn_return != null && this.btn_return.parent != null)
         {
            this.btn_return.parent.removeChild(this.btn_return);
         }
      }
   }
}

