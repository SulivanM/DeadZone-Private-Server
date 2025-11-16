package thelaststand.app.game.gui.alliance.banner
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.utils.ByteArray;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceBannerData;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class AllianceBannerPanelDisplay extends AllianceBannerPanelAbstract
   {
      
      public static const LAYOUT_OVERVIEW:String = "normal";
      
      public static const LAYOUT_DIALOGUE:String = "dialogue";
      
      public static const LAYOUT_DIALOGUE_ADMIN:String = "dialogue_admin";
      
      private var _bandsContainer:Sprite;
      
      private var _bandBG1:Bitmap;
      
      private var _bandBG2:Bitmap;
      
      private var txt_band1:BodyTextField;
      
      private var txt_band2:BodyTextField;
      
      private var _layout:String;
      
      private var _allianceData:AllianceDataSummary;
      
      private var _allianceSystem:AllianceSystem = AllianceSystem.getInstance();
      
      public function AllianceBannerPanelDisplay(param1:AllianceDataSummary, param2:String = "normal")
      {
         this._allianceData = param1;
         this._layout = param2;
         super(this._allianceData ? this._allianceData.banner : null,param2 == LAYOUT_DIALOGUE ? 404 : 368);
         this._bandsContainer = new Sprite();
         this._bandsContainer.y = _height - 80;
         addChild(this._bandsContainer);
         this._bandBG1 = new Bitmap(new BmpAllianceBannerGrad());
         this._bandBG1.smoothing = true;
         this._bandBG1.x = 1;
         this._bandBG1.width = width - 2;
         this._bandBG1.height = 34;
         this._bandsContainer.addChild(this._bandBG1);
         this._bandBG2 = new Bitmap(this._bandBG1.bitmapData);
         this._bandBG2.smoothing = true;
         this._bandBG2.x = this._bandBG1.x;
         this._bandBG2.y = this._bandBG1.y + this._bandBG1.height + 4;
         this._bandBG2.width = this._bandBG1.width;
         this._bandBG2.height = 28;
         this._bandsContainer.addChild(this._bandBG2);
         this.txt_band1 = new BodyTextField({
            "text":"title",
            "color":16777215,
            "size":18,
            "bold":true,
            "maxWidth":_width - 2,
            "autoSize":"left",
            "filters":[Effects.STROKE]
         });
         this.txt_band1.maxWidth = _width - 2;
         this._bandsContainer.addChild(this.txt_band1);
         this.txt_band2 = new BodyTextField({
            "text":"other",
            "color":16777215,
            "size":14,
            "bold":true,
            "maxWidth":_width - 2,
            "autoSize":"left",
            "filters":[Effects.STROKE]
         });
         this.txt_band2.maxWidth = _width - 2;
         this._bandsContainer.addChild(this.txt_band2);
         bmp_titleBar.visible = txt_label.visible = param2 == LAYOUT_OVERVIEW;
         _bannerDisplay.y += param2 == LAYOUT_OVERVIEW ? 30 : 10;
         this._bandBG1.visible = this.txt_band1.visible = param2 != LAYOUT_OVERVIEW;
         this.refreshTextFields();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._allianceData != null)
         {
            if(this._allianceData.banner != null)
            {
               this._allianceData.banner.onChange.remove(this.OnAllianceBannerChange);
            }
         }
         this._allianceData = null;
         TweenMax.killChildTweensOf(this);
         this._bandBG1.bitmapData.dispose();
         this._bandBG1.bitmapData = null;
         this._bandBG2.bitmapData = null;
         this.txt_band1.dispose();
         this.txt_band2.dispose();
         this._allianceSystem = null;
      }
      
      private function refreshTextFields() : void
      {
         var _loc4_:AllianceMember = null;
         if(this._allianceData == null)
         {
            label = this.band1Title = this.band2Title = "";
            return;
         }
         var _loc1_:Language = Language.getInstance();
         if(this._layout == LAYOUT_OVERVIEW)
         {
            label = this._allianceData.name + " [" + this._allianceData.tag + "]";
         }
         else
         {
            label = "";
         }
         var _loc2_:String = "";
         if(this._layout != LAYOUT_OVERVIEW && this._allianceSystem.isConnected && Boolean(this._allianceSystem.alliance))
         {
            _loc4_ = this._allianceSystem.alliance.members.getMemberById(Network.getInstance().playerData.id);
            _loc2_ = this._allianceSystem.alliance.getRankName(_loc4_ != null ? _loc4_.rank : 0);
         }
         this.band1Title = _loc2_;
         this._bandBG1.visible = _loc2_ != "";
         var _loc3_:String = _loc1_.getString("alliance.banner_memberCount");
         _loc3_ = _loc3_.replace("%count",this._allianceData.memberCount);
         _loc3_ = _loc3_.replace("%total",Config.constant.ALLIANCE_MEMBER_MAX_COUNT);
         this.band2Title = _loc3_;
      }
      
      private function OnAllianceBannerChange() : void
      {
         _bannerDisplay.byteArray = this._allianceData ? this._allianceData.banner.byteArray : null;
      }
      
      public function get allianceData() : AllianceDataSummary
      {
         return this._allianceData;
      }
      
      public function set allianceData(param1:AllianceDataSummary) : void
      {
         if(this._allianceData != null)
         {
            if(this._allianceData.banner != null)
            {
               this._allianceData.banner.onChange.remove(this.OnAllianceBannerChange);
            }
         }
         this._allianceData = param1;
         _bannerDisplay.byteArray = this._allianceData ? this._allianceData.banner.byteArray : null;
         if(this._allianceData != null)
         {
            if(this._allianceData.banner != null)
            {
               this._allianceData.banner.onChange.add(this.OnAllianceBannerChange);
            }
         }
         this.refreshTextFields();
      }
      
      public function get band1Title() : String
      {
         return this.txt_band1.text;
      }
      
      public function set band1Title(param1:String) : void
      {
         this.txt_band1.text = param1;
         this.txt_band1.x = int((_width - this.txt_band1.width) * 0.5);
         this.txt_band1.y = this._bandBG1.y + int((this._bandBG1.height - this.txt_band1.height) * 0.5);
      }
      
      public function get band2Title() : String
      {
         return this.txt_band2.text;
      }
      
      public function set band2Title(param1:String) : void
      {
         this.txt_band2.text = param1;
         this.txt_band2.x = int((_width - this.txt_band2.width) * 0.5);
         this.txt_band2.y = this._bandBG2.y + int((this._bandBG2.height - this.txt_band2.height) * 0.5);
      }
   }
}

