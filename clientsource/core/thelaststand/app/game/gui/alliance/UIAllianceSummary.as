package thelaststand.app.game.gui.alliance
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceSummaryCache;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerPanelDisplay;
   import thelaststand.app.game.gui.iteminfo.UIItemTitle;
   import thelaststand.app.gui.UIBusySpinner;
   
   public class UIAllianceSummary extends Sprite
   {
      
      private static const INNER_SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,8,8,5,1,true);
      
      private static const STROKE:GlowFilter = new GlowFilter(6905685,1,1.75,1.75,10,1);
      
      private static const DROP_SHADOW:DropShadowFilter = new DropShadowFilter(1,45,0,1,8,8,1,2);
      
      private static const BMP_TITLEBAR:BitmapData = new BmpTopBarBackground();
      
      private var mc_background:Shape;
      
      private var ui_title:UIItemTitle;
      
      private var bannerPanel:AllianceBannerPanelDisplay;
      
      private var _allianceId:String = "";
      
      private var allianceSummary:UIAllianceSummary;
      
      private var _spinner:UIBusySpinner;
      
      public function UIAllianceSummary()
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(1184274);
         this.mc_background.graphics.drawRect(0,0,10,10);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [INNER_SHADOW,STROKE,DROP_SHADOW];
         addChild(this.mc_background);
         this.bannerPanel = new AllianceBannerPanelDisplay(null);
         this.bannerPanel.x = this.bannerPanel.y = 1;
         addChild(this.bannerPanel);
         this.mc_background.width = this.bannerPanel.width + 2;
         this.mc_background.height = this.bannerPanel.height + 2;
         this._spinner = new UIBusySpinner();
         this._spinner.x = int(this.mc_background.width * 0.5);
         this._spinner.y = int(this.mc_background.height * 0.5);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bannerPanel.dispose();
         this._spinner.dispose();
      }
      
      public function setAlliance(param1:String) : void
      {
         if(param1 == this._allianceId)
         {
            return;
         }
         this.bannerPanel.allianceData = null;
         this._allianceId = param1;
         if(this._allianceId == "")
         {
            return;
         }
         this._spinner.visible = true;
         AllianceSummaryCache.getInstance().getSummary(this._allianceId,this.onSummaryLoaded);
      }
      
      private function onSummaryLoaded(param1:AllianceDataSummary) : void
      {
         this._spinner.visible = false;
         if(param1 == null || param1.id != this._allianceId)
         {
            return;
         }
         this.bannerPanel.allianceData = param1;
      }
      
      override public function get width() : Number
      {
         return this.mc_background.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.mc_background.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

