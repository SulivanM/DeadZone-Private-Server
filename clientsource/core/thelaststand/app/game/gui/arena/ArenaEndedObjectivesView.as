package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.geom.Matrix;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.gui.UIRewardsProgressBar;
   import thelaststand.app.game.gui.raid.RaidDialogue;
   import thelaststand.app.game.gui.tooltip.UIArenaRewardTooltip;
   import thelaststand.app.game.gui.tooltip.UIRewardTierTooltip;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ArenaEndedObjectivesView extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _session:ArenaSession;
      
      private var _stagePanels:Vector.<StagePanel>;
      
      private var ui_title:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var ui_rewardProgress:UIRewardsProgressBar;
      
      private var ui_rewardTooltip:UIRewardTierTooltip;
      
      private var mc_rewardAreaGradient:Shape;
      
      private var txt_pts:BodyTextField;
      
      private var txt_ptsTitle:BodyTextField;
      
      private var bmp_ptsIcon:Bitmap;
      
      public function ArenaEndedObjectivesView()
      {
         super();
         this.ui_title = new UITitleBar(null,RaidDialogue.COLOR);
         this.ui_title.filters = [Effects.TEXT_SHADOW_DARK];
         this.ui_title.height = 30;
         this.ui_title.x = 3;
         this.ui_title.y = 3;
         addChild(this.ui_title);
         this.txt_title = new BodyTextField({
            "color":16747020,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.text = Language.getInstance().getString("arena.missionobjs").toUpperCase();
         addChild(this.txt_title);
         this.mc_rewardAreaGradient = new Shape();
         addChild(this.mc_rewardAreaGradient);
         this.ui_rewardTooltip = new UIArenaRewardTooltip();
         this.ui_rewardProgress = new UIRewardsProgressBar();
         this.ui_rewardProgress.borderColor = 7812366;
         this.ui_rewardProgress.barColor = 11098127;
         this.ui_rewardProgress.tooltip = this.ui_rewardTooltip;
         addChild(this.ui_rewardProgress);
         this.bmp_ptsIcon = new Bitmap(new BmpBountySkull());
         addChild(this.bmp_ptsIcon);
         this.txt_pts = new BodyTextField({
            "text":"000",
            "color":15527148,
            "size":34,
            "bold":true
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
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_rewardProgress.dispose();
         this.ui_rewardTooltip.dispose();
         this.bmp_ptsIcon.bitmapData.dispose();
         this.txt_ptsTitle.dispose();
         this.txt_pts.dispose();
         this.txt_title.dispose();
         this.ui_title.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:StagePanel = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Matrix = null;
         var _loc9_:StagePanel = null;
         graphics.clear();
         for each(_loc1_ in this._stagePanels)
         {
            _loc1_.dispose();
         }
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         _loc2_ = 6;
         this.ui_title.width = int(this._width - this.ui_title.x * 2);
         this.txt_title.x = int(this.ui_title.x + (this.ui_title.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.ui_title.y + (this.ui_title.height - this.txt_title.height) * 0.5);
         _loc3_ = this._width - _loc2_ * 2;
         _loc4_ = 56;
         _loc5_ = new Matrix();
         _loc5_.createGradientBox(_loc3_,_loc4_,0);
         this.mc_rewardAreaGradient.graphics.clear();
         this.mc_rewardAreaGradient.graphics.beginGradientFill("linear",[0,this._session.successful ? 2702864 : 3211267],[1,1],[0,255],_loc5_);
         this.mc_rewardAreaGradient.graphics.drawRect(0,0,_loc3_,_loc4_);
         this.mc_rewardAreaGradient.graphics.endFill();
         this.mc_rewardAreaGradient.x = _loc2_;
         this.mc_rewardAreaGradient.y = int(this._height - this.mc_rewardAreaGradient.height - _loc2_);
         this.ui_rewardProgress.setData(this._session.xml.rewards.tier);
         this.ui_rewardProgress.width = int(this._width - 170);
         this.ui_rewardProgress.x = int(this.mc_rewardAreaGradient.x + 8);
         this.ui_rewardProgress.y = int(this.mc_rewardAreaGradient.y + (this.mc_rewardAreaGradient.height - this.ui_rewardProgress.height) * 0.5 + 6);
         this.ui_rewardProgress.fadedValue = this._session.points;
         this.ui_rewardProgress.solidValue = this._session.successful ? (this._session.currentRewardTier > -1 ? int(this._session.xml.rewards.tier[this._session.currentRewardTier].@score) : 0) : -1;
         this.txt_ptsTitle.x = int(this._width - this.txt_ptsTitle.width - 2);
         this.txt_ptsTitle.y = int(this.mc_rewardAreaGradient.y + (this.mc_rewardAreaGradient.height - this.txt_ptsTitle.height) * 0.5);
         this.txt_ptsTitle.textColor = this._session.successful ? 10077510 : 13503243;
         this.txt_pts.maxWidth = int(this.txt_ptsTitle.x - (this.ui_rewardProgress.x + this.ui_rewardProgress.width) - 50);
         this.txt_pts.text = NumberFormatter.format(this._session.points,0);
         this.txt_pts.x = int(this.txt_ptsTitle.x - this.txt_pts.width - 6);
         this.txt_pts.y = int(this.mc_rewardAreaGradient.y + (this.mc_rewardAreaGradient.height - this.txt_pts.height) * 0.5);
         this.txt_pts.textColor = this._session.successful ? 10077510 : 13503243;
         this.bmp_ptsIcon.x = int(this.txt_ptsTitle.x - Math.max(64,this.txt_pts.width) - this.bmp_ptsIcon.width);
         this.bmp_ptsIcon.y = int(this.mc_rewardAreaGradient.y + (this.mc_rewardAreaGradient.height - this.bmp_ptsIcon.height) * 0.5);
         this._stagePanels = new Vector.<StagePanel>();
         var _loc6_:int = this.ui_title.y + this.ui_title.height + 6;
         var _loc7_:int = 88;
         var _loc8_:int = 0;
         while(_loc8_ < this._session.stageCount)
         {
            _loc9_ = new StagePanel(this._session,_loc8_);
            _loc9_.width = int(this._width - _loc2_ * 2);
            _loc9_.height = _loc7_;
            _loc9_.x = _loc2_;
            _loc9_.y = _loc6_;
            addChild(_loc9_);
            _loc6_ += int(_loc9_.height + 8);
            _loc8_++;
         }
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.game.data.arena.ArenaSession;
import thelaststand.app.game.data.arena.ArenaStageData;
import thelaststand.app.gui.UIComponent;
import thelaststand.app.gui.UIImage;
import thelaststand.common.lang.Language;

class StagePanel extends UIComponent
{
   
   private var _session:ArenaSession;
   
   private var _stage:ArenaStageData;
   
   private var _width:int;
   
   private var _height:int = 88;
   
   private var txt_name:BodyTextField;
   
   private var ui_image:UIImage;
   
   private var ui_objSrv:ObjectiveRow;
   
   private var ui_objSec:ObjectiveRow;
   
   public function StagePanel(param1:ArenaSession, param2:int)
   {
      super();
      this._session = param1;
      this._stage = this._session.getArenaStage(param2);
      this.txt_name = new BodyTextField({
         "color":13882323,
         "size":16,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_name.text = Language.getInstance().getString("arena." + this._session.name + ".stage_" + this._stage.stageXml.@id.toString()).toUpperCase();
      addChild(this.txt_name);
      this.ui_image = new UIImage(this._height,this._height);
      this.ui_image.uri = "images/arenas/" + this._session.name + "_" + this._stage.name + "_small.jpg";
      addChild(this.ui_image);
      var _loc3_:String = Language.getInstance().getString("arena.obj_survivors");
      var _loc4_:Boolean = this._stage.survivorCount > 0 && (this._session.currentStageIndex < this._session.stageCount - 1 || Boolean(this._session.successful));
      this.ui_objSrv = new ObjectiveRow(_loc3_,this._stage.survivorPoints,_loc4_);
      addChild(this.ui_objSrv);
      var _loc5_:String = Language.getInstance().getString("arena." + this._session.name + ".objectives");
      this.ui_objSec = new ObjectiveRow(_loc5_,this._stage.objectivePoints,this._stage.objectivePoints > 0);
      addChild(this.ui_objSec);
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
   
   override public function dispose() : void
   {
      super.dispose();
      this.ui_image.dispose();
      this.txt_name.dispose();
      this.ui_objSec.dispose();
      this.ui_objSrv.dispose();
   }
   
   override protected function draw() : void
   {
      var _loc1_:int = 4;
      this.ui_image.width = this.ui_image.height = this._height;
      var _loc2_:int = this.ui_image.x + this.ui_image.width + _loc1_;
      var _loc3_:int = this._width - _loc2_;
      var _loc4_:int = 24;
      graphics.beginFill(3552822);
      graphics.drawRect(_loc2_,0,_loc3_,_loc4_);
      this.txt_name.x = int(_loc2_ + 4);
      this.txt_name.maxWidth = int(this._width - this.txt_name.x - 10);
      this.txt_name.text = this.txt_name.text;
      this.txt_name.y = int((_loc4_ - this.txt_name.height) * 0.5);
      this.ui_objSrv.x = int(this.ui_image.x + this.ui_image.width + _loc1_);
      this.ui_objSrv.y = int(_loc4_ + _loc1_);
      this.ui_objSrv.width = int(this._width - this.ui_objSrv.x);
      this.ui_objSrv.height = 28;
      this.ui_objSec.x = this.ui_objSrv.x;
      this.ui_objSec.y = int(this.ui_objSrv.y + this.ui_objSrv.height + _loc1_);
      this.ui_objSec.width = int(this.ui_objSrv.width);
      this.ui_objSec.height = int(this.ui_objSrv.height);
   }
}

class ObjectiveRow extends UIComponent
{
   
   private var _width:int;
   
   private var _height:int;
   
   private var _name:String;
   
   private var _points:int;
   
   private var _success:Boolean;
   
   private var txt_name:BodyTextField;
   
   private var txt_points:BodyTextField;
   
   private var bmp_state:Bitmap;
   
   public function ObjectiveRow(param1:String, param2:int, param3:Boolean)
   {
      super();
      this._name = param1;
      this._points = param2;
      this._success = param3;
      this.bmp_state = new Bitmap();
      this.bmp_state.bitmapData = this._success ? new BmpIconTradeTickGreen() : new BmpIconTradeCrossRed();
      addChild(this.bmp_state);
      this.txt_name = new BodyTextField({
         "text":" ",
         "color":16777215,
         "size":15,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_name);
      this.txt_points = new BodyTextField({
         "text":" ",
         "color":16777215,
         "size":15,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_points);
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
   
   override public function dispose() : void
   {
      super.dispose();
      this.bmp_state.bitmapData.dispose();
      this.txt_name.dispose();
      this.txt_points.dispose();
   }
   
   override protected function draw() : void
   {
      var _loc1_:int = 28;
      graphics.clear();
      graphics.beginFill(0);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      graphics.beginFill(this._success ? 3358494 : 4727841);
      graphics.drawRect(0,0,_loc1_,this._height);
      graphics.endFill();
      this.bmp_state.x = int((_loc1_ - this.bmp_state.width) * 0.5);
      this.bmp_state.y = int((this._height - this.bmp_state.height) * 0.5);
      this.txt_name.text = this._name;
      this.txt_name.textColor = this._success ? 9360403 : 10696751;
      this.txt_name.x = int(_loc1_ + 6);
      this.txt_name.y = int((this._height - this.txt_name.height) * 0.5);
      this.txt_points.text = (this._points > 0 ? "+" : "") + NumberFormatter.format(this._points,0);
      this.txt_points.textColor = this.txt_name.textColor;
      this.txt_points.x = int(this._width - this.txt_points.width - 6);
      this.txt_points.y = this.txt_name.y;
   }
}
