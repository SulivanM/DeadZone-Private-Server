package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.GradientType;
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.gui.UIRewardsProgressBar;
   import thelaststand.app.game.gui.raid.RaidDialogue;
   import thelaststand.app.game.gui.tooltip.UIArenaRewardTooltip;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ArenaRewardsView extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _session:ArenaSession;
      
      private var ui_titleBar:UITitleBar;
      
      private var ui_progress:UIRewardsProgressBar;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_rollover:BodyTextField;
      
      private var txt_pts:BodyTextField;
      
      private var txt_ptsTitle:BodyTextField;
      
      private var bmp_ptsIcon:Bitmap;
      
      private var ui_rewardTooltip:UIArenaRewardTooltip;
      
      public function ArenaRewardsView()
      {
         super();
         this.ui_titleBar = new UITitleBar(null,RaidDialogue.COLOR);
         this.ui_titleBar.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "color":16747020,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_title);
         this.bmp_ptsIcon = new Bitmap(new BmpBountySkull());
         addChild(this.bmp_ptsIcon);
         this.txt_pts = new BodyTextField({
            "text":"000",
            "color":15527148,
            "size":34,
            "bold":true,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.CENTER
         });
         addChild(this.txt_pts);
         this.txt_ptsTitle = new BodyTextField({
            "color":12762055,
            "size":12,
            "multiline":true,
            "bold":true,
            "leading":-2
         });
         this.txt_ptsTitle.text = Language.getInstance().getString("arena.points");
         this.txt_ptsTitle.width = 50;
         addChild(this.txt_ptsTitle);
         this.txt_desc = new BodyTextField({
            "color":15527148,
            "size":13,
            "multiline":true,
            "bold":true,
            "leading":-2,
            "align":TextFormatAlign.CENTER
         });
         this.txt_desc.htmlText = Language.getInstance().getString("arena.rewards_msg");
         addChild(this.txt_desc);
         this.txt_rollover = new BodyTextField({
            "color":9853236,
            "size":11,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_rollover.text = Language.getInstance().getString("arena.rewards_rollover");
         addChild(this.txt_rollover);
         this.ui_rewardTooltip = new UIArenaRewardTooltip();
         this.ui_progress = new UIRewardsProgressBar();
         this.ui_progress.borderColor = 7812366;
         this.ui_progress.barColor = 11098127;
         this.ui_progress.tooltip = this.ui_rewardTooltip;
         addChild(this.ui_progress);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      public function setData(param1:ArenaSession) : void
      {
         this._session = param1;
         this.ui_progress.setData(this._session.xml.rewards.tier);
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_ptsIcon.bitmapData.dispose();
         this.bmp_ptsIcon.bitmapData = null;
         this.txt_pts.dispose();
         this.txt_ptsTitle.dispose();
         this.txt_desc.dispose();
         this.txt_rollover.dispose();
         this.ui_rewardTooltip.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_titleBar.width = this._width - 6;
         this.ui_titleBar.height = 24;
         this.ui_titleBar.x = this.ui_titleBar.y = 3;
         this.txt_title.text = Language.getInstance().getString("arena.rewards_title",Language.getInstance().getString("arena." + this._session.name + ".name")).toUpperCase();
         this.txt_title.x = 10;
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         _loc1_ = 6;
         var _loc2_:int = 40;
         _loc3_ = int(this.ui_titleBar.y + this.ui_titleBar.height + _loc1_);
         this.bmp_ptsIcon.x = _loc1_ + 8;
         this.bmp_ptsIcon.y = int(_loc3_ + (_loc2_ - this.bmp_ptsIcon.height) * 0.5);
         this.txt_ptsTitle.x = int(_loc1_ + 100);
         this.txt_ptsTitle.y = int(_loc3_ + (_loc2_ - this.txt_ptsTitle.height) * 0.5);
         this.txt_pts.text = NumberFormatter.format(this._session.points,0);
         this.txt_pts.maxWidth = int(this.txt_ptsTitle.x - (this.bmp_ptsIcon.x + this.bmp_ptsIcon.width) - 8);
         this.txt_pts.x = int(this.bmp_ptsIcon.x + this.bmp_ptsIcon.width + 4);
         this.txt_pts.y = int(_loc3_ + (_loc2_ - this.txt_pts.height) * 0.5);
         var _loc4_:Matrix = new Matrix();
         var _loc5_:int = int(this.txt_ptsTitle.x + this.txt_ptsTitle.width - _loc1_);
         _loc4_.createGradientBox(_loc5_,_loc2_);
         graphics.beginGradientFill(GradientType.LINEAR,[855309,855309],[1,0],[100,255],_loc4_);
         graphics.drawRect(_loc1_,_loc3_,_loc5_,_loc2_);
         graphics.endFill();
         var _loc6_:int = 10;
         var _loc7_:int = int(this.txt_ptsTitle.x + this.txt_ptsTitle.width + _loc1_);
         graphics.beginFill(855309);
         graphics.drawRect(_loc7_,_loc3_,int(this._width - _loc7_ - _loc1_),_loc2_);
         graphics.endFill();
         this.txt_desc.x = int(_loc7_ + _loc6_);
         this.txt_desc.width = int(this._width - this.txt_desc.x - _loc1_ - _loc6_ * 2);
         this.txt_desc.y = int(_loc3_ + (_loc2_ - this.txt_desc.height) * 0.5);
         this.txt_rollover.x = int((this._width - this.txt_rollover.width) * 0.5);
         this.txt_rollover.y = int(this._height - this.txt_rollover.height - 2);
         this.ui_progress.width = int(this._width - _loc1_ * 2 - 10);
         this.ui_progress.x = _loc1_;
         this.ui_progress.y = int(this.txt_rollover.y - 42);
         this.ui_progress.fadedValue = this._session.points;
         this.ui_progress.solidValue = this._session.currentRewardTier > -1 ? int(this._session.xml.rewards.tier[this._session.currentRewardTier].@score) : 0;
         this.ui_progress.redraw();
      }
   }
}

