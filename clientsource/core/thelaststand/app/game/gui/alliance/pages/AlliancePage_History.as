package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_History extends Sprite implements IAlliancePage
   {
      
      private var _dialogue:AllianceDialogue;
      
      private var _lang:Language = Language.getInstance();
      
      private var _allianceSystem:AllianceSystem;
      
      private var topAlliancesPanel:TopAlliancesPanel;
      
      private var myAlliancePanel:MyAlliancePanel;
      
      private var winningsPanel:WinningsCollectionPanel;
      
      private var lifetimeStatsPanel:LifetimeStatsPanel;
      
      private var noAlliancePanel:NoAlliancePanel;
      
      private var disposed:Boolean = false;
      
      public function AlliancePage_History()
      {
         super();
         this.topAlliancesPanel = new TopAlliancesPanel();
         addChild(this.topAlliancesPanel);
         this.myAlliancePanel = new MyAlliancePanel();
         this.myAlliancePanel.y = this.topAlliancesPanel.y + this.topAlliancesPanel.height + 5;
         addChild(this.myAlliancePanel);
         this.noAlliancePanel = new NoAlliancePanel();
         this.noAlliancePanel.y = this.myAlliancePanel.y;
         addChild(this.noAlliancePanel);
         this.winningsPanel = new WinningsCollectionPanel();
         this.winningsPanel.x = this.topAlliancesPanel.x + this.topAlliancesPanel.width + 5;
         addChild(this.winningsPanel);
         this.lifetimeStatsPanel = new LifetimeStatsPanel();
         this.lifetimeStatsPanel.x = this.winningsPanel.x;
         this.lifetimeStatsPanel.y = this.winningsPanel.y + this.winningsPanel.height + 5;
         addChild(this.lifetimeStatsPanel);
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.connected.add(this.onAllianceConnected);
         this._allianceSystem.disconnected.add(this.onAllianceDisconnected);
         if(this._allianceSystem.isConnected)
         {
            this.onAllianceConnected();
         }
         else
         {
            this.onAllianceDisconnected();
         }
         this.requestPreviousRoundWinners();
      }
      
      public function dispose() : void
      {
         this.disposed = true;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.topAlliancesPanel.dispose();
         this.topAlliancesPanel = null;
         this.myAlliancePanel.dispose();
         this.myAlliancePanel = null;
         this.winningsPanel.dispose();
         this.winningsPanel = null;
         this.lifetimeStatsPanel.dispose();
         this.lifetimeStatsPanel = null;
         this.noAlliancePanel.dispose();
         this.noAlliancePanel = null;
         this._dialogue = null;
         this._lang = null;
         this._allianceSystem.connected.remove(this.onAllianceConnected);
         this._allianceSystem.disconnected.remove(this.onAllianceDisconnected);
         this._allianceSystem = null;
      }
      
      private function onAllianceConnected() : void
      {
         if(this._allianceSystem.alliance == null)
         {
            return;
         }
         this.myAlliancePanel.visible = true;
         this.requestMyAlliancesRankData();
         this.noAlliancePanel.visible = false;
      }
      
      private function onAllianceDisconnected() : void
      {
         this.myAlliancePanel.visible = false;
         this.noAlliancePanel.visible = true;
      }
      
      private function requestPreviousRoundWinners() : void
      {
         this.topAlliancesPanel.clear();
         this.myAlliancePanel.clear();
         this._allianceSystem.getPreviousRoundWinners(this.onWinnersResultsReceived);
      }
      
      private function onWinnersResultsReceived(param1:Boolean, param2:AllianceList) : void
      {
         if(this.disposed)
         {
            return;
         }
         this.topAlliancesPanel.populate(param2);
      }
      
      private function requestMyAlliancesRankData() : void
      {
         this._allianceSystem.getLastRoundRanks(this.onRankRequestResultsReceived);
      }
      
      private function onRankRequestResultsReceived(param1:Boolean, param2:AllianceDataSummary, param3:int, param4:int) : void
      {
         if(this.disposed == true || this._allianceSystem.isConnected == false)
         {
            return;
         }
         this.myAlliancePanel.populate(param2,param3,param4);
      }
      
      public function get dialogue() : AllianceDialogue
      {
         return this._dialogue;
      }
      
      public function set dialogue(param1:AllianceDialogue) : void
      {
         this._dialogue = param1;
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import thelaststand.app.core.Config;
import thelaststand.app.core.Global;
import thelaststand.app.data.PlayerData;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.alliance.AllianceDataSummary;
import thelaststand.app.game.data.alliance.AllianceLifetimeStats;
import thelaststand.app.game.data.alliance.AllianceList;
import thelaststand.app.game.data.alliance.AllianceSystem;
import thelaststand.app.game.gui.alliance.UIAllianceWarStatsSummary;
import thelaststand.app.game.gui.alliance.banner.AllianceBannerDisplay;
import thelaststand.app.game.gui.buttons.PurchasePushButton;
import thelaststand.app.game.gui.lists.UIListSeparator;
import thelaststand.app.gui.TooltipDirection;
import thelaststand.app.gui.TooltipManager;
import thelaststand.app.gui.UIBusySpinner;
import thelaststand.app.gui.UIImage;
import thelaststand.app.gui.UITitleBar;
import thelaststand.app.gui.buttons.PushButton;
import thelaststand.app.gui.dialogues.BaseDialogue;
import thelaststand.app.gui.dialogues.BusyDialogue;
import thelaststand.app.gui.dialogues.MessageBox;
import thelaststand.app.network.Network;
import thelaststand.app.network.SaveDataMethod;
import thelaststand.app.utils.GraphicUtils;
import thelaststand.common.lang.Language;

class TopAlliancesPanel extends Sprite
{
   
   private var disposed:Boolean = false;
   
   private var bg:Shape;
   
   private var titleBar:UITitleBar;
   
   private var titleBmp:Bitmap;
   
   private var txt_roundLabel:BodyTextField;
   
   private var busySpinner:UIBusySpinner;
   
   private var txt_calculating:BodyTextField;
   
   private var band0:AllianceRankBand;
   
   private var band1:AllianceRankBand;
   
   private var band2:AllianceRankBand;
   
   public function TopAlliancesPanel()
   {
      super();
      this.bg = new Shape();
      addChild(this.bg);
      GraphicUtils.drawUIBlock(this.bg.graphics,460,282);
      this.titleBar = new UITitleBar(null,4539717);
      this.titleBar.x = this.titleBar.y = 5;
      this.titleBar.width = this.bg.width - this.titleBar.x * 2;
      this.titleBar.height = 34;
      addChild(this.titleBar);
      this.txt_roundLabel = new BodyTextField({
         "text":"",
         "color":14079702,
         "size":15,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_roundLabel.x = this.titleBar.x + this.titleBar.width - (this.txt_roundLabel.width + 5);
      this.txt_roundLabel.y = this.titleBar.y + 5;
      addChild(this.txt_roundLabel);
      this.band0 = new AllianceRankBand(4342338,5);
      this.band0.x = this.titleBar.x;
      this.band0.y = this.titleBar.y + this.titleBar.height + 5;
      addChild(this.band0);
      this.band1 = new AllianceRankBand(3092271,5);
      this.band1.x = this.band0.x;
      this.band1.y = this.band0.y + this.band0.height;
      addChild(this.band1);
      this.band2 = new AllianceRankBand(1118481);
      this.band2.x = this.band1.x;
      this.band2.y = this.band1.y + this.band1.height;
      addChild(this.band2);
      this.busySpinner = new UIBusySpinner();
      this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
      this.busySpinner.x = int(this.band1.x + this.band1.width * 0.5);
      this.busySpinner.y = int(this.band1.y + this.band2.height * 0.5);
      addChild(this.busySpinner);
      this.txt_calculating = new BodyTextField({
         "color":16777215,
         "size":16,
         "bold":true,
         "autoSize":"left",
         "align":"center",
         "multiline":true,
         "filters":[Effects.STROKE]
      });
      this.txt_calculating.htmlText = Language.getInstance().getString("alliance.history_calculating");
      this.txt_calculating.width = this.band2.width;
      this.txt_calculating.x = this.busySpinner.x - this.txt_calculating.width * 0.5;
      this.txt_calculating.y = this.busySpinner.y - this.txt_calculating.height * 0.5;
      this.titleBmp = new Bitmap(new BmpTitle_AllianceHistory(),"auto",true);
      this.titleBmp.x = this.titleBar.x + 5;
      this.titleBmp.y = this.titleBar.y - 2;
      addChild(this.titleBmp);
      this.updateLabel();
   }
   
   public function dispose() : void
   {
      this.disposed = true;
      if(parent)
      {
         parent.removeChild(this);
      }
      this.txt_roundLabel.dispose();
      this.titleBar.dispose();
      this.titleBmp.bitmapData.dispose();
      this.txt_roundLabel.dispose();
      this.txt_calculating.dispose();
      this.busySpinner.dispose();
      this.band0.dispose();
      this.band1.dispose();
      this.band2.dispose();
   }
   
   public function clear() : void
   {
      if(this.txt_calculating.parent)
      {
         this.txt_calculating.parent.removeChild(this.txt_calculating);
      }
      addChild(this.busySpinner);
      this.band0.populate(null);
      this.band1.populate(null);
      this.band2.populate(null);
   }
   
   private function updateLabel() : void
   {
      this.txt_roundLabel.text = Language.getInstance().getString("alliance.history_lastResults",AllianceSystem.getInstance().round.number - 1);
      this.txt_roundLabel.x = this.titleBar.x + this.titleBar.width - (this.txt_roundLabel.width + 5);
   }
   
   public function populate(param1:AllianceList) : void
   {
      if(this.disposed)
      {
         return;
      }
      if(this.busySpinner.parent)
      {
         this.busySpinner.parent.removeChild(this.busySpinner);
      }
      if(param1 == null || param1.numAlliances == 0)
      {
         addChild(this.txt_calculating);
         return;
      }
      var _loc2_:int = Math.min(param1.numAlliances,3);
      var _loc3_:int = 0;
      while(_loc3_ < _loc2_)
      {
         AllianceRankBand(this["band" + _loc3_]).populate(param1.getAlliance(_loc3_),_loc3_ + 1);
         _loc3_++;
      }
   }
}

class MyAlliancePanel extends Sprite
{
   
   private var bg:Shape;
   
   private var titleBg:Shape;
   
   private var txt_title:BodyTextField;
   
   private var band:AllianceRankBand;
   
   private var busySpinner:UIBusySpinner;
   
   private var disposed:Boolean;
   
   public function MyAlliancePanel()
   {
      super();
      this.bg = new Shape();
      addChild(this.bg);
      GraphicUtils.drawUIBlock(this.bg.graphics,460,108);
      this.titleBg = new Shape();
      this.titleBg.graphics.beginFill(3552822,1);
      this.titleBg.graphics.drawRect(0,0,448,24);
      this.titleBg.x = this.titleBg.y = 5;
      addChild(this.titleBg);
      this.txt_title = new BodyTextField({
         "text":Language.getInstance().getString("alliance.history_yourResults_title"),
         "color":8355711,
         "size":13,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_title.x = this.titleBg.x + 10;
      this.txt_title.y = this.titleBg.y + 2;
      addChild(this.txt_title);
      this.band = new AllianceRankBand(921102,0,AllianceRankBand.MEMBER_RANK);
      this.band.x = this.titleBg.x;
      this.band.y = this.titleBg.y + this.titleBg.height;
      addChild(this.band);
      this.busySpinner = new UIBusySpinner();
      this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
      this.busySpinner.x = this.band.x + int(this.band.width * 0.5);
      this.busySpinner.y = this.band.y + int(this.band.height * 0.5);
      addChild(this.busySpinner);
   }
   
   public function dispose() : void
   {
      this.disposed = true;
      if(parent)
      {
         parent.removeChild(this);
      }
      this.txt_title.dispose();
      this.busySpinner.dispose();
      this.band.dispose();
   }
   
   public function populate(param1:AllianceDataSummary, param2:int, param3:int) : void
   {
      if(this.disposed)
      {
         return;
      }
      if(this.busySpinner.parent)
      {
         this.busySpinner.parent.removeChild(this.busySpinner);
      }
      this.band.populate(param1,param2,param3);
   }
   
   public function clear() : void
   {
      addChild(this.busySpinner);
      this.band.populate(null);
   }
}

class AllianceRankBand extends Sprite
{
   
   public static const TAG_AND_MEMBERCOUNT:String = "tageMemberCount";
   
   public static const MEMBER_RANK:String = "memberRank";
   
   private var bg:Shape;
   
   private var sep0:UIListSeparator;
   
   private var sep1:UIListSeparator;
   
   private var txt_rank:BodyTextField;
   
   private var txt_title:BodyTextField;
   
   private var txt_subtitle:BodyTextField;
   
   private var txt_score:BodyTextField;
   
   private var txt_subscore:BodyTextField;
   
   private var icon:Bitmap;
   
   private var _iconHeight:Number = 64;
   
   private var _layout:String = "tageMemberCount";
   
   public function AllianceRankBand(param1:uint = 4342338, param2:int = 0, param3:String = "tageMemberCount")
   {
      super();
      this._layout = param3;
      this.bg = new Shape();
      this.bg.graphics.beginFill(param1,1);
      this.bg.graphics.drawRect(0,0,450,74);
      addChild(this.bg);
      this.sep0 = new UIListSeparator(this.bg.height + param2);
      this.sep0.x = 48;
      addChild(this.sep0);
      this.sep1 = new UIListSeparator(this.bg.height + param2);
      this.sep1.x = 345;
      addChild(this.sep1);
      this.txt_rank = new BodyTextField({
         "text":"3.",
         "color":10263708,
         "size":36,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_rank.maxWidth = 32;
      this.txt_rank.x = 5;
      this.txt_rank.y = int((this.bg.height - this.txt_rank.height) * 0.5);
      addChild(this.txt_rank);
      this.icon = new Bitmap();
      this.icon.x = this.sep0.x + this.sep0.width + 5;
      this.icon.y = int((this.bg.height - this._iconHeight) * 0.5);
      addChild(this.icon);
      this.txt_title = new BodyTextField({
         "text":"PUT TITLE IN",
         "color":16777215,
         "size":36,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_title.x = this.icon.x + 58;
      this.txt_title.y = 8;
      this.txt_title.maxWidth = this.sep1.x - this.txt_title.x - 4;
      addChild(this.txt_title);
      this.txt_subtitle = new BodyTextField({
         "text":"subtitle",
         "color":10921638,
         "size":13,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_subtitle.x = this.txt_title.x;
      this.txt_subtitle.y = 46;
      addChild(this.txt_subtitle);
      this.txt_score = new BodyTextField({
         "text":"1234",
         "color":16777215,
         "size":36,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_score.maxWidth = 100;
      this.txt_score.x = this.sep1.x + 5;
      this.txt_score.y = 8;
      addChild(this.txt_score);
      this.txt_subscore = new BodyTextField({
         "text":"subscore",
         "color":10921638,
         "size":13,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_subscore.maxWidth = 1000;
      this.txt_subscore.x = this.txt_score.x;
      this.txt_subscore.y = 46;
      addChild(this.txt_subscore);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.sep0.dispose();
      this.sep1.dispose();
      this.txt_rank.dispose();
      this.txt_title.dispose();
      this.txt_subtitle.dispose();
      this.txt_score.dispose();
      this.txt_subscore.dispose();
      if(this.icon.bitmapData)
      {
         this.icon.bitmapData.dispose();
         this.icon.bitmapData = null;
      }
   }
   
   public function populate(param1:AllianceDataSummary, param2:int = -1, param3:int = -1) : void
   {
      var _loc8_:String = null;
      var _loc9_:String = null;
      this.sep0.visible = this.sep1.visible = this.txt_rank.visible = this.txt_title.visible = this.txt_subtitle.visible = this.txt_score.visible = this.txt_subscore.visible = this.icon.visible = param1 != null;
      if(param1 == null)
      {
         return;
      }
      this.txt_rank.text = param2 > 0 ? param2 + "." : "-";
      this.txt_rank.x = int((this.sep0.x - this.txt_rank.width) * 0.5);
      if(param2 > 0)
      {
         this.txt_rank.x += 4 * this.txt_rank.scaleX;
      }
      if(this.icon.bitmapData)
      {
         this.icon.bitmapData.dispose();
      }
      var _loc4_:AllianceBannerDisplay = AllianceBannerDisplay.getInstance();
      _loc4_.byteArray = param1.banner.byteArray;
      this.icon.bitmapData = _loc4_.generateBitmap(this._iconHeight);
      this.icon.smoothing = true;
      this.txt_title.text = param1.name;
      var _loc5_:String = "";
      if(this._layout == MEMBER_RANK)
      {
         _loc8_ = param3 > 0 ? "#" + param3 : "-";
         this.txt_subtitle.htmlText = Language.getInstance().getString("alliance.history_yourResults_rank",_loc8_);
      }
      else
      {
         _loc5_ = param1.tagBracketed;
         if(param1.memberCount > 0)
         {
            _loc9_ = Language.getInstance().getString("alliance.history_memberCount");
            _loc9_ = _loc9_.replace("%count",param1.memberCount.toString());
            _loc9_ = _loc9_.replace("%total",Config.constant.ALLIANCE_MEMBER_MAX_COUNT);
            _loc5_ += " - " + _loc9_;
         }
         this.txt_subtitle.htmlText = _loc5_;
      }
      var _loc6_:Number = this.txt_title.height + this.txt_subtitle.height - 6;
      this.txt_title.y = int((this.bg.height - _loc6_) * 0.5);
      this.txt_subtitle.y = this.txt_title.y + this.txt_title.height - 6;
      var _loc7_:Number = this.bg.width - (this.sep1.x + this.sep1.width);
      this.txt_score.htmlText = NumberFormatter.format(param1.points,0,",",false);
      this.txt_score.x = this.sep1.x + this.sep1.width + int((_loc7_ - this.txt_score.width) * 0.5);
      this.txt_subscore.htmlText = Language.getInstance().getString("alliance.history_effiency",NumberFormatter.format(param1.efficiency,2,",",true));
      this.txt_subscore.x = this.sep1.x + this.sep1.width + int((_loc7_ - this.txt_subscore.width) * 0.5);
      _loc6_ = this.txt_score.height + this.txt_subscore.height - 6;
      this.txt_score.y = int((this.bg.height - _loc6_) * 0.5);
      this.txt_subscore.y = this.txt_score.y + this.txt_score.height - 6;
   }
}

class NoAlliancePanel extends Sprite
{
   
   private var bg:Shape;
   
   private var titleBar:UITitleBar;
   
   private var txt_title:BodyTextField;
   
   private var stars_left:Bitmap;
   
   private var stars_right:Bitmap;
   
   private var bodyBG:Shape;
   
   private var txt_body:BodyTextField;
   
   public function NoAlliancePanel()
   {
      super();
      this.bg = new Shape();
      addChild(this.bg);
      GraphicUtils.drawUIBlock(this.bg.graphics,460,108);
      this.titleBar = new UITitleBar(null,7806494);
      this.titleBar.width = this.bg.width - 10;
      this.titleBar.height = 34;
      this.titleBar.x = this.titleBar.y = 5;
      addChild(this.titleBar);
      this.stars_left = new Bitmap(new BmpBountyStars());
      TweenMax.to(this.stars_left,0,{"tint":16037977});
      this.stars_left.x = this.titleBar.x + 26;
      this.stars_left.y = this.titleBar.y + int((this.titleBar.height - this.stars_left.height) * 0.5);
      addChild(this.stars_left);
      this.stars_right = new Bitmap(this.stars_left.bitmapData);
      TweenMax.to(this.stars_right,0,{"tint":16037977});
      this.stars_right.x = this.titleBar.x + this.titleBar.width - (this.stars_right.width + 26);
      this.stars_right.y = this.stars_left.y;
      addChild(this.stars_right);
      this.txt_title = new BodyTextField({
         "text":" ",
         "color":16037977,
         "size":28,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_title.maxWidth = this.stars_right.x - (this.stars_left.x + this.stars_left.width);
      this.txt_title.text = Language.getInstance().getString("alliance.history_noAlliance_title");
      this.txt_title.x = this.titleBar.x + int((this.titleBar.width - this.txt_title.width) * 0.5);
      this.txt_title.y = this.titleBar.y + int((this.titleBar.height - this.txt_title.height) * 0.5);
      addChild(this.txt_title);
      this.bodyBG = new Shape();
      this.bodyBG.x = this.titleBar.x;
      this.bodyBG.y = this.titleBar.y + this.titleBar.height + 1;
      this.bodyBG.graphics.beginFill(4197902,1);
      this.bodyBG.graphics.drawRect(0,0,this.titleBar.width,this.bg.height - this.bodyBG.y - 5);
      addChild(this.bodyBG);
      this.txt_body = new BodyTextField({
         "text":Language.getInstance().getString("alliance.history_noAlliance_body"),
         "color":16774630,
         "size":13,
         "align":"center",
         "multiline":true,
         "bold":false
      });
      this.txt_body.width = this.bodyBG.width - 30;
      this.txt_body.x = this.bodyBG.x + 15;
      this.txt_body.y = this.bodyBG.y + int((this.bodyBG.height - this.txt_body.height) * 0.5);
      addChild(this.txt_body);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.titleBar.dispose();
      this.txt_title.dispose();
      this.stars_left.bitmapData.dispose();
      this.txt_body.dispose();
   }
}

class WinningsCollectionPanel extends Sprite
{
   
   private var bg:Shape;
   
   private var titleBar:UITitleBar;
   
   private var burstBG:UIImage;
   
   private var txt_title:BodyTextField;
   
   private var txt_subtitle:BodyTextField;
   
   private var txt_amount:BodyTextField;
   
   private var icon:Bitmap;
   
   private var busySpinner:UIBusySpinner;
   
   private var busyDlg:BusyDialogue;
   
   private var btn_collect:PushButton;
   
   private var disposed:Boolean;
   
   private var _lang:Language;
   
   private var _playerData:PlayerData;
   
   private var _bandCenter:int;
   
   public function WinningsCollectionPanel()
   {
      super();
      this._lang = Language.getInstance();
      this._playerData = Network.getInstance().playerData;
      this.bg = new Shape();
      addChild(this.bg);
      GraphicUtils.drawUIBlock(this.bg.graphics,248,220);
      this.titleBar = new UITitleBar(null,3038465);
      this.titleBar.x = this.titleBar.y = 5;
      this.titleBar.width = this.bg.width - this.titleBar.x * 2;
      addChild(this.titleBar);
      this.burstBG = new UIImage(228,115,0,1,false,"images/alliances/alliance-collectFuelBg.jpg");
      this.burstBG.x = int((this.titleBar.width - this.burstBG.width) * 0.5);
      this.burstBG.y = this.titleBar.y + this.titleBar.height + 5;
      addChild(this.burstBG);
      this.bg.graphics.beginFill(0);
      this.bg.graphics.drawRect(this.titleBar.x,this.burstBG.y,this.titleBar.width,this.bg.height - this.burstBG.y - 5);
      this.txt_title = new BodyTextField({
         "text":this._lang.getString("alliance.history_spoils_title"),
         "color":8512543,
         "size":24,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_title.x = int((this.bg.width - this.txt_title.width) * 0.5);
      this.txt_title.y = this.titleBar.y + 5;
      addChild(this.txt_title);
      this.txt_subtitle = new BodyTextField({
         "text":this._lang.getString("alliance.history_spoils_unclaimed"),
         "color":8886147,
         "size":15,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_subtitle.x = this.titleBar.x + int((this.titleBar.width - this.txt_subtitle.width) * 0.5);
      this.txt_subtitle.y = this.burstBG.y + 7;
      addChild(this.txt_subtitle);
      this._bandCenter = this.burstBG.y + 63;
      this.icon = new Bitmap(new BmpIconFuelLarge(),"auto",true);
      this.icon.y = this._bandCenter - int(this.icon.height * 0.5) + 2;
      addChild(this.icon);
      this.txt_amount = new BodyTextField({
         "text":"0",
         "color":16762368,
         "size":48,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_amount.x = this.txt_title.x;
      this.txt_amount.y = this._bandCenter - int(this.txt_amount.height * 0.5);
      this.txt_amount.maxWidth = this.titleBar.width - 10 - this.icon.width;
      addChild(this.txt_amount);
      this.busySpinner = new UIBusySpinner();
      this.busySpinner.scaleX = this.busySpinner.scaleY = 2;
      this.busySpinner.x = this.titleBar.x + int(this.titleBar.width * 0.5);
      this.busySpinner.y = this._bandCenter;
      addChild(this.busySpinner);
      this.btn_collect = new PushButton(this._lang.getString("alliance.history_spoils_collect"));
      this.btn_collect.backgroundColor = PurchasePushButton.DEFAULT_COLOR;
      this.btn_collect.width = this.titleBar.width - 20;
      this.btn_collect.x = this.titleBar.x + 10;
      this.btn_collect.y = this.bg.height - 15 - this.btn_collect.height;
      TooltipManager.getInstance().add(this.btn_collect,Language.getInstance().getString("alliance.history_spoils_collectTooltip"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
      addChild(this.btn_collect);
      this.btn_collect.enabled = false;
      this.btn_collect.clicked.add(this.onButtonClick);
      this.busyDlg = null;
      addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      this._playerData.uncollectedWinningsChanged.add(this.onWinningsChanged);
   }
   
   public function dispose() : void
   {
      this.disposed = true;
      if(parent)
      {
         parent.removeChild(this);
      }
      this.titleBar.dispose();
      this.burstBG.dispose();
      this.txt_title.dispose();
      this.txt_subtitle.dispose();
      this.txt_amount.dispose();
      this.icon.bitmapData.dispose();
      this.btn_collect.dispose();
      this._lang = null;
      removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      this._playerData.uncollectedWinningsChanged.remove(this.onWinningsChanged);
      TooltipManager.getInstance().remove(this.btn_collect);
   }
   
   private function onAddedToStage(param1:Event) : void
   {
      this.checkForOustandingWinnings();
   }
   
   private function onWinningsChanged() : void
   {
      if(this._playerData.uncollectedWinnings == true)
      {
         this.checkForOustandingWinnings();
      }
   }
   
   private function checkForOustandingWinnings() : void
   {
      addChild(this.busySpinner);
      this.displayAmount(0);
      this.txt_amount.visible = false;
      this.icon.visible = false;
      Network.getInstance().save(null,SaveDataMethod.ALLIANCE_QUERY_WINNINGS,function(param1:Object):void
      {
         if(disposed)
         {
            return;
         }
         if(busySpinner.parent)
         {
            busySpinner.parent.removeChild(busySpinner);
         }
         var _loc2_:int = 0;
         if("uncollected" in param1)
         {
            _loc2_ = int(param1.uncollected);
         }
         displayAmount(_loc2_);
      });
   }
   
   private function displayAmount(param1:int) : void
   {
      this.txt_amount.text = NumberFormatter.format(param1,0);
      var _loc2_:Number = this.txt_amount.width + 5 + this.icon.width;
      this.txt_amount.x = this.titleBar.x + int((this.titleBar.width - _loc2_) * 0.5);
      this.txt_amount.y = this._bandCenter - int(this.txt_amount.height * 0.5);
      this.icon.x = this.txt_amount.x + this.txt_amount.width + 5;
      this.txt_amount.visible = this.icon.visible = true;
      var _loc3_:String = this._lang.getString("alliance.history_spoils_collect");
      if(param1 > 0)
      {
         _loc3_ += " - " + param1;
      }
      this.btn_collect.label = _loc3_;
      this.btn_collect.enabled = param1 > 0;
   }
   
   private function onButtonClick(param1:MouseEvent) : void
   {
      switch(param1.target)
      {
         case this.btn_collect:
            this.collectWinnings();
      }
   }
   
   private function onFail() : void
   {
      if(this.busyDlg != null)
      {
         this.busyDlg.close();
      }
      this.busyDlg = null;
      var _loc1_:MessageBox = new MessageBox(this._lang.getString("alliance.collectwinnings_error"),null,true);
      _loc1_.addTitle(this._lang.getString("alliance.collectwinnings_errorTitle"),BaseDialogue.TITLE_COLOR_RUST);
      _loc1_.addButton(this._lang.getString("alliance.collectwinnings_ok"));
      _loc1_.open();
   }
   
   private function collectWinnings() : void
   {
      this.busyDlg = new BusyDialogue(this._lang.getString("alliance.collectwinnings_busy"),"alliance-collectBusy");
      this.busyDlg.open();
      Network.getInstance().startAsyncOp();
      Network.getInstance().save({},SaveDataMethod.ALLIANCE_COLLECT_WINNINGS,function(param1:Object):void
      {
         var _loc2_:MessageBox = null;
         Network.getInstance().completeAsyncOp();
         busyDlg.close();
         busyDlg = null;
         if(param1.success)
         {
            _loc2_ = new MessageBox(_lang.getString("alliance.collectwinnings_success",param1.amount),null,true);
            _loc2_.addTitle(_lang.getString("alliance.collectwinnings_successTitle"),BaseDialogue.TITLE_COLOR_GREEN);
            _loc2_.addButton(_lang.getString("alliance.collectwinnings_ok"));
            _loc2_.open();
            displayAmount(0);
            _playerData.uncollectedWinnings = false;
         }
         else
         {
            onFail();
         }
      });
   }
}

class LifetimeStatsPanel extends Sprite
{
   
   private var disposed:Boolean;
   
   private var bg:Shape;
   
   private var txt_title:BodyTextField;
   
   private var band0:LifetimeStatsBand;
   
   private var band1:LifetimeStatsBand;
   
   private var band2:LifetimeStatsBand;
   
   private var btn_more:PushButton;
   
   private var allianceStatsSummary:UIAllianceWarStatsSummary;
   
   public function LifetimeStatsPanel()
   {
      var lang:Language;
      var a:Array;
      var i:int;
      var last:LifetimeStatsBand = null;
      var b:LifetimeStatsBand = null;
      super();
      lang = Language.getInstance();
      this.bg = new Shape();
      addChild(this.bg);
      GraphicUtils.drawUIBlock(this.bg.graphics,248,172);
      this.bg.graphics.beginFill(0,1);
      this.bg.graphics.drawRect(5,5,this.bg.width - 10,this.bg.height - 10);
      this.bg.graphics.beginFill(3552822,1);
      this.bg.graphics.drawRect(5,5,this.bg.width - 10,28);
      this.txt_title = new BodyTextField({
         "text":lang.getString("alliance.history_lifetime_title"),
         "color":16777215,
         "size":16,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_title.x = int((this.bg.width - this.txt_title.width) * 0.5);
      this.txt_title.y = 7;
      addChild(this.txt_title);
      this.band0 = new LifetimeStatsBand(this.bg.width - 20,0);
      this.band1 = new LifetimeStatsBand(this.bg.width - 20,3552822);
      this.band2 = new LifetimeStatsBand(this.bg.width - 20,0);
      a = [{
         "band":this.band0,
         "label":lang.getString("alliance.history_lifetime_fuel")
      },{
         "band":this.band1,
         "label":lang.getString("alliance.history_lifetime_points")
      },{
         "band":this.band2,
         "label":lang.getString("alliance.history_lifetime_bannersTaken")
      }];
      i = 0;
      while(i < a.length)
      {
         b = a[i].band;
         b.label = a[i].label;
         b.x = 10;
         b.y = last ? last.y + last.height : 38;
         addChild(b);
         last = b;
         i++;
      }
      this.btn_more = new PushButton(lang.getString("alliance.history_lifetime_viewmore"));
      this.btn_more.width = this.bg.width - 20;
      this.btn_more.x = 10;
      this.btn_more.y = this.band2.y + this.band2.height + 5;
      this.btn_more.enabled = false;
      this.btn_more.clicked.add(this.onButtonClick);
      addChild(this.btn_more);
      AllianceSystem.getInstance().getLifetimeStats(function(param1:Boolean, param2:AllianceLifetimeStats):void
      {
         if(Boolean(disposed) || !param1 || param2 == null)
         {
            return;
         }
         band1.value = param2.points;
         band2.value = param2.wins;
         btn_more.enabled = true;
      });
      Network.getInstance().playerData.uncollectedWinningsChanged.add(this.onWinningsChanged);
      this.getTotalWinnings();
   }
   
   public function dispose() : void
   {
      this.disposed = true;
      if(parent)
      {
         parent.removeChild(this);
      }
      this.txt_title.dispose();
      this.band0.dispose();
      this.band1.dispose();
      this.band2.dispose();
      this.btn_more.dispose();
      this.HideStatusPopup();
      if(this.allianceStatsSummary != null)
      {
         this.allianceStatsSummary.dispose();
      }
      this.allianceStatsSummary = null;
      Network.getInstance().playerData.uncollectedWinningsChanged.remove(this.onWinningsChanged);
   }
   
   private function onButtonClick(param1:MouseEvent) : void
   {
      var e:MouseEvent = param1;
      if(this.allianceStatsSummary != null)
      {
         this.ShowStatsPopup();
         return;
      }
      AllianceSystem.getInstance().getLifetimeStats(function(param1:Boolean, param2:AllianceLifetimeStats):void
      {
         if(!param1 || !visible || allianceStatsSummary != null)
         {
            return;
         }
         allianceStatsSummary = new UIAllianceWarStatsSummary();
         allianceStatsSummary.setData(param2);
         ShowStatsPopup();
      });
   }
   
   private function ShowStatsPopup() : void
   {
      this.allianceStatsSummary.x = -this.allianceStatsSummary.width;
      this.allianceStatsSummary.y = this.bg.height - this.allianceStatsSummary.height;
      addChild(this.allianceStatsSummary);
      Global.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.HideStatusPopup,true,int.MAX_VALUE,true);
   }
   
   private function HideStatusPopup(param1:MouseEvent = null) : void
   {
      Global.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.HideStatusPopup);
      if(this.allianceStatsSummary == null)
      {
         return;
      }
      if(this.allianceStatsSummary.parent != null)
      {
         this.allianceStatsSummary.parent.removeChild(this.allianceStatsSummary);
      }
   }
   
   private function onWinningsChanged() : void
   {
      if(Network.getInstance().playerData.uncollectedWinnings == true)
      {
         this.getTotalWinnings();
      }
   }
   
   private function getTotalWinnings() : void
   {
      Network.getInstance().save(null,SaveDataMethod.ALLIANCE_QUERY_WINNINGS,function(param1:Object):void
      {
         if(disposed)
         {
            return;
         }
         var _loc2_:int = 0;
         if("lifetime" in param1)
         {
            _loc2_ = int(param1.lifetime);
         }
         band0.value = _loc2_;
      });
   }
}

class LifetimeStatsBand extends Sprite
{
   
   private var bg:Shape;
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   public function LifetimeStatsBand(param1:uint, param2:uint = 0)
   {
      super();
      this.bg = new Shape();
      this.bg.graphics.beginFill(param2,1);
      this.bg.graphics.drawRect(0,0,param1,30);
      addChild(this.bg);
      this.txt_label = new BodyTextField({
         "text":"label",
         "color":16777215,
         "size":14,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_label.x = 10;
      this.txt_label.y = 4;
      addChild(this.txt_label);
      this.txt_value = new BodyTextField({
         "text":"-",
         "color":16777215,
         "size":16,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_value.x = param1 - 10 - this.txt_value.width;
      this.txt_value.y = 2;
      addChild(this.txt_value);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.txt_label.dispose();
      this.txt_value.dispose();
   }
   
   public function set label(param1:String) : void
   {
      this.txt_label.text = param1;
   }
   
   public function set value(param1:int) : void
   {
      this.txt_value.text = NumberFormatter.format(param1,0,",",false);
      this.txt_value.x = this.bg.width - 10 - this.txt_value.width;
   }
}
