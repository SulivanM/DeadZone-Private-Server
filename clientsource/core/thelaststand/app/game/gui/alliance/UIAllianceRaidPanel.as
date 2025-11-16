package thelaststand.app.game.gui.alliance
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.geom.Matrix;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerDisplay;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceRaidPanel extends UIComponent
   {
      
      private var _width:int = 200;
      
      private var _height:int = 140;
      
      private var _missionData:MissionData;
      
      private var _enlisting:Boolean;
      
      private var bmd_banner:BitmapData;
      
      private var bmp_bannerWin:Bitmap;
      
      private var bmp_bannerLose:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var txt_info:BodyTextField;
      
      private var txt_defeat:BodyTextField;
      
      private var txt_ptsWin:BodyTextField;
      
      private var txt_ptsLose:BodyTextField;
      
      public function UIAllianceRaidPanel(param1:MissionData)
      {
         super();
         this._missionData = param1;
         this._enlisting = param1.allianceAttackerEnlisting || param1.allianceDefenderEnlisting;
         mouseEnabled = mouseChildren = false;
         this.txt_title = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         addChild(this.txt_title);
         if(param1.allianceAttackerLockout)
         {
            this.txt_title.text = Language.getInstance().getString("alliance.raidinfo_attackerlockout").toUpperCase();
            this.txt_info = new BodyTextField({
               "color":13834778,
               "size":14,
               "bold":true,
               "width":180,
               "multiline":true
            });
            this.txt_info.text = Language.getInstance().getString("alliance.raidinfo_attackerlockout_desc").toUpperCase();
            addChild(this.txt_info);
         }
         else if(param1.allianceDefenderLocked)
         {
            this.txt_title.text = Language.getInstance().getString("alliance.raidinfo_defenderlocked").toUpperCase();
            this.txt_info = new BodyTextField({
               "color":13834778,
               "size":14,
               "bold":true,
               "width":180,
               "multiline":true
            });
            this.txt_info.text = Language.getInstance().getString("alliance.raidinfo_defenderlocked_desc").toUpperCase();
            addChild(this.txt_info);
         }
         else if(this._enlisting)
         {
            if(param1.allianceAttackerEnlisting)
            {
               this.txt_title.text = Language.getInstance().getString("alliance.raidinfo_attackerenlisting").toUpperCase();
            }
            else
            {
               this.txt_title.text = Language.getInstance().getString("alliance.raidinfo_defenderenlisting").toUpperCase();
            }
            this.txt_info = new BodyTextField({
               "color":13834778,
               "size":14,
               "bold":true,
               "width":180,
               "multiline":true
            });
            this.txt_info.text = Language.getInstance().getString("alliance.raidinfo_ptsenlisting").toUpperCase();
            addChild(this.txt_info);
         }
         else
         {
            this.bmd_banner = AllianceBannerDisplay.getInstance().generateBitmap();
            this.bmp_bannerWin = new Bitmap(this.bmd_banner,"auto",true);
            this.bmp_bannerWin.height = 38;
            this.bmp_bannerWin.scaleX = this.bmp_bannerWin.scaleY;
            addChild(this.bmp_bannerWin);
            this.bmp_bannerLose = new Bitmap(this.bmd_banner,"auto",true);
            this.bmp_bannerLose.height = int(this.bmp_bannerWin.height);
            this.bmp_bannerLose.scaleX = this.bmp_bannerLose.scaleY;
            addChild(this.bmp_bannerLose);
            this.txt_title.text = Language.getInstance().getString("alliance.raidinfo_title").toUpperCase();
            addChild(this.txt_title);
            this.txt_defeat = new BodyTextField({
               "color":16777215,
               "size":14,
               "bold":true
            });
            this.txt_defeat.text = Language.getInstance().getString("alliance.raidinfo_defeat").toUpperCase();
            addChild(this.txt_defeat);
            this.txt_ptsWin = new BodyTextField({
               "color":4899625,
               "size":30,
               "bold":true
            });
            addChild(this.txt_ptsWin);
            this.txt_ptsLose = new BodyTextField({
               "color":13834778,
               "size":24,
               "bold":true
            });
            addChild(this.txt_ptsLose);
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_title.dispose();
         if(this._enlisting || this._missionData.allianceDefenderLocked || this._missionData.allianceAttackerLockout)
         {
            this.txt_info.dispose();
         }
         else
         {
            this.txt_defeat.dispose();
            this.txt_ptsWin.dispose();
            this.txt_ptsLose.dispose();
            this.bmd_banner.dispose();
         }
         this._missionData = null;
      }
      
      override protected function draw() : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         graphics.clear();
         this.txt_title.x = 8;
         this.txt_title.y = 6;
         if(this._enlisting || this._missionData.allianceDefenderLocked || this._missionData.allianceAttackerLockout)
         {
            this.txt_info.x = int(this.txt_title.x);
            this.txt_info.y = int(this.txt_title.y + this.txt_title.height + 4);
            this._height = int(this.txt_info.y + this.txt_info.height + this.txt_title.y);
         }
         else
         {
            this._height = 140;
            _loc5_ = this._missionData.allianceAttackerWinPoints;
            _loc6_ = this._missionData.allianceAttackerLosePoints;
            this.bmp_bannerWin.x = int(this.txt_title.x + 2);
            this.bmp_bannerWin.y = int(this.txt_title.y + this.txt_title.height + (34 - this.bmp_bannerWin.height) * 0.5);
            this.txt_ptsWin.htmlText = Language.getInstance().getString("alliance.raidinfo_ptswin",(_loc5_ < 0 ? "-" : "+") + Math.abs(_loc5_));
            this.txt_ptsWin.x = 46;
            this.txt_ptsWin.y = int(this.txt_title.y + this.txt_title.height + (34 - this.txt_ptsWin.height) * 0.5);
            if(_loc6_ != 0)
            {
               this.txt_defeat.x = int(this.txt_title.x);
               this.txt_defeat.y = int(this.txt_ptsWin.y + this.txt_ptsWin.height + 8);
               this.bmp_bannerLose.x = int(this.txt_defeat.x + 2);
               this.bmp_bannerLose.y = int(this.txt_defeat.y + this.txt_defeat.height + (40 - this.bmp_bannerLose.height) * 0.5);
               this.txt_ptsLose.htmlText = Language.getInstance().getString("alliance.raidinfo_ptslose",(_loc6_ < 0 ? "-" : "+") + Math.abs(_loc6_));
               this.txt_ptsLose.x = int(this.txt_ptsWin.x);
               this.txt_ptsLose.y = int(this.txt_defeat.y + this.txt_defeat.height + (40 - this.txt_ptsWin.height) * 0.5);
            }
            else
            {
               this._height = 70;
               this.txt_ptsLose.parent.removeChild(this.txt_ptsLose);
               this.txt_defeat.parent.removeChild(this.txt_defeat);
               this.bmp_bannerLose.parent.removeChild(this.bmp_bannerLose);
            }
         }
         var _loc1_:Matrix = new Matrix();
         var _loc2_:Array = [150,255];
         _loc1_.createGradientBox(this._width,this._height);
         graphics.beginGradientFill(GradientType.LINEAR,[0,0],[0.7,0],_loc2_,_loc1_);
         graphics.drawRect(0,1,this._width,this._height - 2);
         graphics.endFill();
         var _loc3_:Array = [8026746,8026746];
         var _loc4_:Array = [0.5,0];
         graphics.beginGradientFill(GradientType.LINEAR,_loc3_,_loc4_,_loc2_,_loc1_);
         graphics.drawRect(0,0,this._width,1);
         graphics.endFill();
         graphics.beginGradientFill(GradientType.LINEAR,_loc3_,_loc4_,_loc2_,_loc1_);
         graphics.drawRect(0,this._height - 1,this._width,1);
         graphics.endFill();
      }
   }
}

