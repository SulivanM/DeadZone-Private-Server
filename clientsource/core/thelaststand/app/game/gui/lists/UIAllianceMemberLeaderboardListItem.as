package thelaststand.app.game.gui.lists
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.system.LoaderContext;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIAllianceMemberLeaderboardListItem extends UIPagedListItem
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private var _lang:Language;
      
      private var _alternating:Boolean;
      
      private var _member:AllianceMember;
      
      private var _remotePlayerData:RemotePlayerData;
      
      private var _separators:Vector.<UIListSeparator> = new Vector.<UIListSeparator>();
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var txt_rank:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_score:BodyTextField;
      
      private var txt_raidEfficiency:BodyTextField;
      
      private var txt_missionEfficiency:BodyTextField;
      
      private var _raidStatsHit:Sprite;
      
      private var _missionStatsHit:Sprite;
      
      private var _rank:uint = 0;
      
      private var ui_busy:UIBusySpinner;
      
      public function UIAllianceMemberLeaderboardListItem()
      {
         super();
         this._lang = Language.getInstance();
         _width = 487;
         _height = 40;
         this._lang = Language.getInstance();
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         var _loc1_:Number = 0;
         this.txt_rank = new BodyTextField({
            "text":" ",
            "color":13421772,
            "size":14,
            "bold":true,
            "align":"center",
            "autoSize":"none",
            "width":40,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_rank.y = int((_height - this.txt_rank.height) * 0.5);
         addChild(this.txt_rank);
         _loc1_ += 40;
         this.createSeparator(_loc1_);
         this.ui_portrait = new UIImage(30,30,0,1,false);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,32,32);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = _loc1_ + 13;
         this.ui_portrait.y = Math.round((_height - this.ui_portrait.height) * 0.5 + 1);
         addChild(this.ui_portrait);
         this.ui_busy = new UIBusySpinner();
         this.ui_busy.x = int(this.ui_portrait.x + this.ui_portrait.width * 0.5);
         this.ui_busy.y = int(this.ui_portrait.y + this.ui_portrait.height * 0.5);
         this.txt_name = new BodyTextField({
            "text":" ",
            "color":13421772,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_name.x = this.ui_portrait.x + this.ui_portrait.width + 10;
         this.txt_name.y = int((_height - this.txt_name.height) * 0.5);
         addChild(this.txt_name);
         _loc1_ += 205;
         this.txt_name.width = _loc1_ - this.txt_name.x - 10;
         this.createSeparator(_loc1_);
         this.txt_score = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "align":"center",
            "autoSize":"none",
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_score.x = _loc1_ + 5;
         this.txt_score.y = int((_height - this.txt_score.height) * 0.5);
         addChild(this.txt_score);
         _loc1_ += 102;
         this.txt_score.width = _loc1_ - this.txt_score.x - 5;
         this.createSeparator(_loc1_);
         this.txt_raidEfficiency = new BodyTextField({
            "htmlText":" <br/> ",
            "color":9145227,
            "size":12,
            "bold":true,
            "align":"center",
            "autoSize":TextFieldAutoSize.CENTER,
            "multiline":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_raidEfficiency.x = _loc1_ + 2;
         this.txt_raidEfficiency.y = int((_height - this.txt_raidEfficiency.height) * 0.5) - 4;
         this.txt_raidEfficiency.width = 70;
         addChild(this.txt_raidEfficiency);
         this._raidStatsHit = new Sprite();
         this._raidStatsHit.graphics.beginFill(0,0);
         this._raidStatsHit.graphics.drawRect(0,0,this.txt_raidEfficiency.width,_height);
         this._raidStatsHit.x = this.txt_raidEfficiency.x;
         this._raidStatsHit.y = 0;
         addChild(this._raidStatsHit);
         this.txt_missionEfficiency = new BodyTextField({
            "htmlText":" <br/> ",
            "color":9145227,
            "size":12,
            "bold":true,
            "align":"center",
            "autoSize":TextFieldAutoSize.CENTER,
            "multiline":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_missionEfficiency.x = this.txt_raidEfficiency.x + this.txt_raidEfficiency.width + 1;
         this.txt_missionEfficiency.y = this.txt_raidEfficiency.y;
         addChild(this.txt_missionEfficiency);
         this.txt_missionEfficiency.width = 70;
         this._missionStatsHit = new Sprite();
         this._missionStatsHit.graphics.beginFill(0,0);
         this._missionStatsHit.graphics.drawRect(0,0,this.txt_missionEfficiency.width,_height);
         this._missionStatsHit.x = this.txt_missionEfficiency.x;
         this._missionStatsHit.y = 0;
         addChild(this._missionStatsHit);
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIListSeparator = null;
         var _loc2_:Resource = null;
         if(this.ui_portrait != null && this.ui_portrait.uri != null)
         {
            _loc2_ = ResourceManager.getInstance().getResource(this.ui_portrait.uri);
            if(_loc2_ != null && !_loc2_.loaded)
            {
               ResourceManager.getInstance().purge(this.ui_portrait.uri);
            }
         }
         TweenMax.killChildTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this);
         super.dispose();
         if(this._member != null)
         {
            this._member = null;
         }
         this._lang = null;
         this._remotePlayerData = null;
         for each(_loc1_ in this._separators)
         {
            _loc1_.dispose();
         }
         this._separators = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_raidEfficiency.dispose();
         this.txt_raidEfficiency = null;
         this.txt_missionEfficiency.dispose();
         this.txt_missionEfficiency = null;
         this.txt_rank.dispose();
         this.txt_rank = null;
         this.txt_score.dispose();
         this.txt_score = null;
      }
      
      private function createSeparator(param1:int) : void
      {
         var _loc2_:UIListSeparator = new UIListSeparator(_height);
         _loc2_.x = int(param1 - _loc2_.width * 0.5);
         addChild(_loc2_);
         this._separators.push(_loc2_);
      }
      
      private function update() : void
      {
         if(this._member == null)
         {
            this.ui_portrait.visible = this.txt_name.visible = this.txt_raidEfficiency.visible = this.txt_missionEfficiency.visible = this.txt_rank.visible = this.txt_score.visible = false;
            this._raidStatsHit.visible = this._missionStatsHit.visible = false;
            TooltipManager.getInstance().remove(this._raidStatsHit);
            TooltipManager.getInstance().remove(this._missionStatsHit);
            return;
         }
         this._raidStatsHit.visible = this._missionStatsHit.visible = true;
         TooltipManager.getInstance().add(this._raidStatsHit,this.GenerateRaidTooltip,new Point(this._raidStatsHit.width * 0.5,0),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(this._missionStatsHit,this.GenerateMissionTooltip,new Point(this._missionStatsHit.width * 0.5,0),TooltipDirection.DIRECTION_DOWN);
         var _loc1_:* = this._member.nickname == "$formermember";
         var _loc2_:String = this._remotePlayerData != null ? this._remotePlayerData.getPortraitURI() : null;
         this.ui_portrait.uri = _loc2_;
         this.txt_rank.text = this._rank + ".";
         this.txt_rank.visible = true;
         this.txt_name.htmlText = _loc1_ ? "[" + Language.getInstance().getString("alliance.formermember").toUpperCase() + "]" : this._member.nickname;
         this.txt_name.height = int((_height - this.txt_name.height) * 0.5);
         this.txt_name.visible = true;
         this.txt_score.text = NumberFormatter.format(this._member.points,0);
         this.txt_score.visible = true;
         this.txt_raidEfficiency.htmlText = NumberFormatter.format(this._member.efficiency,2) + "%<br/><font size=\'-1\' color=\'#6a6a6a\'>FW:" + this._member.wins + " FL:" + this._member.defLosses + "</font>";
         this.txt_raidEfficiency.visible = true;
         this.txt_missionEfficiency.htmlText = NumberFormatter.format(this._member.missionEfficiency,2) + "%<br/><font size=\'-1\' color=\'#6a6a6a\'>MS:" + this._member.missionSuccess + " MF:" + this._member.missionFail + "</font>";
         this.txt_missionEfficiency.visible = true;
         if(!_loc1_ && this._remotePlayerData == null)
         {
            addChild(this.ui_busy);
            this.ui_portrait.visible = false;
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         else
         {
            if(this.ui_busy.parent)
            {
               this.ui_busy.parent.removeChild(this.ui_busy);
            }
            if(_loc1_)
            {
               this.ui_portrait.visible = false;
            }
            else
            {
               this.ui_portrait.visible = true;
               addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
               addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            }
         }
      }
      
      private function GenerateMissionTooltip() : String
      {
         return this.CommonTooltipParse("alliance.members_missionstatdetails");
      }
      
      private function GenerateRaidTooltip() : String
      {
         return this.CommonTooltipParse("alliance.members_raidstatdetails");
      }
      
      private function CommonTooltipParse(param1:String) : String
      {
         if(this._member == null)
         {
            return "";
         }
         var _loc2_:String = Language.getInstance().getString(param1);
         _loc2_ = _loc2_.replace("%ow",this._member.wins);
         _loc2_ = _loc2_.replace("%ol",this._member.losses);
         _loc2_ = _loc2_.replace("%a",this._member.abandons);
         _loc2_ = _loc2_.replace("%dw",this._member.defWins);
         _loc2_ = _loc2_.replace("%dl",this._member.defLosses);
         _loc2_ = _loc2_.replace("%pa",this._member.pointsAttack);
         _loc2_ = _loc2_.replace("%pd",this._member.pointsDefend);
         _loc2_ = _loc2_.replace("%ms",this._member.missionSuccess);
         _loc2_ = _loc2_.replace("%mf",this._member.missionFail);
         _loc2_ = _loc2_.replace("%ma",this._member.missionAbandon);
         return _loc2_.replace("%pm",this._member.pointsMission);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":(this._alternating ? COLOR_ALT : COLOR_NORMAL)});
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!selected)
         {
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL);
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      public function get member() : AllianceMember
      {
         return this._member;
      }
      
      public function set member(param1:AllianceMember) : void
      {
         this._member = param1;
         this.update();
      }
      
      public function get remotePlayerData() : RemotePlayerData
      {
         return this._remotePlayerData;
      }
      
      public function set remotePlayerData(param1:RemotePlayerData) : void
      {
         this._remotePlayerData = param1;
         if(this._member != null)
         {
            this.update();
         }
      }
      
      public function get rank() : uint
      {
         return this._rank;
      }
      
      public function set rank(param1:uint) : void
      {
         this._rank = param1;
         this.update();
      }
   }
}

