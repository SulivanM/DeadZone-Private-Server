package thelaststand.app.game.gui.alliance
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.Timer;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceRound;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerDisplay;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceWarBanner extends Sprite
   {
      
      private var bg:UIImage;
      
      private var endContainer:Sprite;
      
      private var txt_endLabel:BodyTextField;
      
      private var txt_endTime:BodyTextField;
      
      private var rankBand:BlackBand;
      
      private var pointsBand:BlackBand;
      
      private var centerY:int;
      
      private var banner:AllianceBannerDisplay;
      
      private var bannerBitmap:Bitmap;
      
      private var nonMemberGraphic:Bitmap;
      
      private var prizesPanel:PrizesPanel;
      
      private var _lang:Language;
      
      private var _allianceSystem:AllianceSystem;
      
      private var refreshTimer:Timer;
      
      private var disposed:Boolean = false;
      
      public function UIAllianceWarBanner()
      {
         super();
         this._lang = Language.getInstance();
         this._allianceSystem = AllianceSystem.getInstance();
         graphics.beginFill(6291970,1);
         graphics.drawRect(5,43,198,21);
         this.bg = new UIImage(200,282,0,1,false);
         this.bg.uri = "images/alliances/bg-allianceWar.jpg";
         this.bg.x = this.bg.y = 4;
         addChild(this.bg);
         this.endContainer = new Sprite();
         this.endContainer.y = 42;
         addChild(this.endContainer);
         this.txt_endLabel = new BodyTextField({
            "text":"",
            "color":11972784,
            "size":15,
            "bold":true,
            "autoSize":"left",
            "filters":[Effects.STROKE]
         });
         this.endContainer.addChild(this.txt_endLabel);
         this.txt_endTime = new BodyTextField({
            "text":"",
            "color":16711680,
            "size":18,
            "bold":true,
            "autoSize":"left",
            "filters":[Effects.STROKE]
         });
         this.endContainer.addChild(this.txt_endTime);
         this.updateTimeRemaining();
         this.rankBand = new BlackBand(this.bg.width,18,28);
         this.rankBand.x = this.bg.x;
         this.rankBand.y = 66;
         addChild(this.rankBand);
         this.rankBand.labelStr = this._lang.getString("alliance.warbanner_calcRank");
         this.pointsBand = new BlackBand(this.bg.width,18,22);
         this.pointsBand.x = this.bg.x;
         this.pointsBand.y = 252;
         addChild(this.pointsBand);
         this.updateAlliancePoints();
         this.centerY = int((this.pointsBand.y - (this.rankBand.y + this.rankBand.height)) * 0.5 + (this.rankBand.y + this.rankBand.height));
         this._allianceSystem.connected.add(this.onConnected);
         this._allianceSystem.disconnected.add(this.onDisconnected);
         this._allianceSystem.roundStarted.add(this.updateTimeRemaining);
         this._allianceSystem.roundEnded.add(this.updateTimeRemaining);
         if(this._allianceSystem.inAlliance)
         {
            this.onConnected();
         }
         else
         {
            this.onDisconnected();
         }
         this.prizesPanel = new PrizesPanel(this.bg.width);
         this.prizesPanel.x = this.bg.x;
         this.prizesPanel.y = this.bg.height + 5;
         addChild(this.prizesPanel);
         GraphicUtils.drawUIBlock(graphics,this.bg.width + 8,this.prizesPanel.y + this.prizesPanel.height + 4);
         this.refreshTimer = new Timer(2 * 60 * 1000);
         this.refreshTimer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
         this.refreshTimer.start();
      }
      
      public function dispose() : void
      {
         this.disposed = true;
         this.bg.dispose();
         this.bg = null;
         this.pointsBand.dispose();
         this.rankBand.dispose();
         if(this.banner)
         {
            this.banner.dispose();
            this.banner = null;
         }
         if(this.bannerBitmap)
         {
            this.bannerBitmap.bitmapData.dispose();
            this.bannerBitmap = null;
         }
         this.prizesPanel.dispose();
         this._allianceSystem.connected.remove(this.onConnected);
         this._allianceSystem.disconnected.remove(this.onDisconnected);
         this._allianceSystem.roundStarted.remove(this.updateTimeRemaining);
         this._allianceSystem.roundEnded.remove(this.updateTimeRemaining);
         if(this._allianceSystem.alliance != null)
         {
            this._allianceSystem.alliance.pointsChanged.remove(this.updateAlliancePoints);
            if(this._allianceSystem.alliance.banner)
            {
               this._allianceSystem.alliance.banner.onChange.remove(this.updateBanner);
            }
         }
         this.refreshTimer.stop();
         this.refreshTimer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.refreshTimer = null;
         this._lang = null;
         this._allianceSystem = null;
      }
      
      private function onConnected() : void
      {
         if(this.disposed)
         {
            return;
         }
         this.rankBand.visible = this.pointsBand.visible = true;
         if(this.nonMemberGraphic != null)
         {
            if(this.nonMemberGraphic.parent)
            {
               removeChild(this.nonMemberGraphic);
            }
            this.nonMemberGraphic.bitmapData.dispose();
            this.nonMemberGraphic = null;
         }
         this.updateBanner();
         this._allianceSystem.alliance.pointsChanged.add(this.updateAlliancePoints);
         if(this._allianceSystem.alliance.banner)
         {
            this._allianceSystem.alliance.banner.onChange.add(this.updateBanner);
         }
         this.updateAlliancePoints();
         this.updateAllianceRank();
      }
      
      private function updateBanner() : void
      {
         if(this.banner == null)
         {
            this.banner = new AllianceBannerDisplay();
         }
         if(this.bannerBitmap == null)
         {
            this.bannerBitmap = new Bitmap();
         }
         if(this.bannerBitmap.bitmapData)
         {
            this.bannerBitmap.bitmapData.dispose();
         }
         this.banner.byteArray = this._allianceSystem.alliance.banner.byteArray;
         this.bannerBitmap.bitmapData = this.banner.generateBitmap();
         this.bannerBitmap.smoothing = true;
         addChild(this.bannerBitmap);
         this.bannerBitmap.scaleX = this.bannerBitmap.scaleY = 0.75;
         this.bannerBitmap.x = int((this.bg.width - this.bannerBitmap.width) * 0.5);
         this.bannerBitmap.y = this.centerY - int(this.bannerBitmap.height * 0.5);
      }
      
      private function onDisconnected() : void
      {
         var _loc1_:AllianceBannerDisplay = null;
         if(this.disposed)
         {
            return;
         }
         this.rankBand.visible = this.pointsBand.visible = false;
         if(this._allianceSystem.alliance)
         {
            this._allianceSystem.alliance.pointsChanged.remove(this.updateAlliancePoints);
            if(this._allianceSystem.alliance.banner)
            {
               this._allianceSystem.alliance.banner.onChange.add(this.updateBanner);
            }
         }
         if(this.bannerBitmap)
         {
            this.bannerBitmap.bitmapData.dispose();
            this.bannerBitmap = null;
         }
         if(this.nonMemberGraphic == null)
         {
            _loc1_ = AllianceBannerDisplay.getInstance();
            _loc1_.clear();
            this.nonMemberGraphic = new Bitmap(_loc1_.generateBitmap(210),"auto",true);
            addChildAt(this.nonMemberGraphic,getChildIndex(this.bg) + 1);
         }
         this.nonMemberGraphic.x = int((this.bg.width - this.nonMemberGraphic.width) * 0.5) + 5;
         this.nonMemberGraphic.y = this.centerY - int(this.nonMemberGraphic.height * 0.5) + 2;
      }
      
      private function updateAllianceRank() : void
      {
         var _loc1_:URLVariables = null;
         var _loc2_:URLRequest = null;
         var _loc3_:URLLoader = null;
         if(this._allianceSystem.inAlliance && Boolean(this._allianceSystem.alliance))
         {
            if(Network.getInstance().serverTime < this._allianceSystem.round.activeTime.time)
            {
               this.rankBand.labelStr = this._lang.getString("alliance.warbanner_unranked");
               this.rankBand.valueStr = "";
            }
            else
            {
               _loc1_ = new URLVariables();
               _loc1_.action = "rank";
               _loc1_.round = this._allianceSystem.round.number;
               _loc1_.allianceId = this._allianceSystem.alliance.id;
               _loc1_.service = Network.getInstance().service;
               _loc2_ = new URLRequest(Config.getPath("alliance_url"));
               _loc2_.method = URLRequestMethod.POST;
               _loc2_.data = _loc1_;
               _loc3_ = new URLLoader();
               _loc3_.addEventListener(Event.COMPLETE,this.onUpdateRankLoadComplete,false,0,true);
               _loc3_.addEventListener(IOErrorEvent.IO_ERROR,this.onUpdateRankLoadFail,false,0,true);
               _loc3_.load(_loc2_);
            }
         }
         else
         {
            this.rankBand.labelStr = "";
            this.rankBand.valueStr = "";
         }
      }
      
      private function onUpdateRankLoadComplete(param1:Event) : void
      {
         var obj:Object = null;
         var e:Event = param1;
         if(this.disposed)
         {
            return;
         }
         if(this._allianceSystem.inAlliance == false || this._allianceSystem.alliance == null)
         {
            this.onUpdateRankLoadFail(null);
            return;
         }
         try
         {
            obj = JSON.parse(URLLoader(e.target).data);
         }
         catch(e:Error)
         {
            return;
         }
         if(obj.success != true)
         {
            return;
         }
         if(obj.rank < 1)
         {
            this.rankBand.labelStr = this._lang.getString("alliance.warbanner_unranked");
            this.rankBand.valueStr = "";
         }
         else
         {
            this.rankBand.labelStr = this._lang.getString("alliance.warbanner_ranked");
            this.rankBand.valueStr = "#" + obj.rank;
         }
      }
      
      private function onUpdateRankLoadFail(param1:Event = null) : void
      {
         this.rankBand.labelStr = "";
         this.rankBand.valueStr = "";
      }
      
      private function updateAlliancePoints() : void
      {
         if(this._allianceSystem.inAlliance && Boolean(this._allianceSystem.alliance))
         {
            this.pointsBand.labelStr = this._lang.getString("alliance.warbanner_pointsLabel");
            this.pointsBand.valueStr = this._allianceSystem.alliance.points.toString();
         }
      }
      
      private function updateTimeRemaining() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._allianceSystem == null)
         {
            return;
         }
         var _loc1_:AllianceRound = this._allianceSystem.round;
         if(_loc1_ == null)
         {
            return;
         }
         if(Network.getInstance().serverTime < _loc1_.activeTime.time)
         {
            this.txt_endLabel.text = this._lang.getString("alliance.warbanner_starts");
            _loc3_ = _loc1_.activeTime.time - Network.getInstance().serverTime;
         }
         else
         {
            this.txt_endLabel.text = this._lang.getString("alliance.warbanner_ends");
            _loc3_ = _loc1_.endTime.time - Network.getInstance().serverTime;
         }
         this.txt_endTime.text = DateTimeUtils.secondsToString(_loc3_ / 1000,false,false,true);
         this.txt_endTime.x = this.txt_endLabel.width + 4;
         this.txt_endLabel.y = int((21 - this.txt_endLabel.height) * 0.5) + 2;
         this.txt_endTime.y = int((21 - this.txt_endTime.height) * 0.5) + 2;
         this.endContainer.x = int((this.bg.width - this.endContainer.width) * 0.5);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.updateTimeRemaining();
         if(this._allianceSystem.inAlliance && Boolean(this._allianceSystem.alliance))
         {
            this.updateAlliancePoints();
            this.updateAllianceRank();
         }
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.common.lang.Language;
import thelaststand.common.resources.ResourceManager;

class BlackBand extends Sprite
{
   
   private var bg:Shape;
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   private var container:Sprite;
   
   private var _width:Number = 100;
   
   private var _height:Number = 28;
   
   public function BlackBand(param1:Number, param2:Number, param3:Number)
   {
      super();
      var _loc4_:Matrix = new Matrix();
      _loc4_.createGradientBox(param1,this._height);
      this.bg = new Shape();
      this.bg.graphics.beginGradientFill(GradientType.LINEAR,[0,0,0,0],[0.2,1,1,0.2],[0,51,204,255],_loc4_);
      this.bg.graphics.drawRect(0,0,param1,this._height);
      addChild(this.bg);
      this.container = new Sprite();
      addChild(this.container);
      this.txt_label = new BodyTextField({
         "text":"",
         "color":7631988,
         "size":18,
         "bold":true,
         "autoSize":"left",
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.container.addChild(this.txt_label);
      this.txt_value = new BodyTextField({
         "text":"",
         "color":16777215,
         "size":20,
         "bold":true,
         "autoSize":"left",
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.container.addChild(this.txt_value);
      this.updateLayout();
   }
   
   public function get labelStr() : String
   {
      return this.txt_label.text;
   }
   
   public function set labelStr(param1:String) : void
   {
      this.txt_label.text = param1;
      this.updateLayout();
   }
   
   public function get valueStr() : String
   {
      return this.txt_value.text;
   }
   
   public function set valueStr(param1:String) : void
   {
      this.txt_value.text = param1;
      this.updateLayout();
   }
   
   public function dispose() : void
   {
      this.txt_label.dispose();
      this.txt_label = null;
      this.txt_value.dispose();
      this.txt_value = null;
   }
   
   private function updateLayout() : void
   {
      this.txt_value.x = this.txt_label.width + 5;
      this.txt_value.y = int((this.bg.height - this.txt_value.height) * 0.5) - 1;
      this.txt_label.y = int((this.bg.height - this.txt_label.height) * 0.5);
      this.container.x = int((this.bg.width - this.container.width) * 0.5);
   }
}

class PrizesPanel extends Sprite
{
   
   private var _width:Number;
   
   private var txt_title:BodyTextField;
   
   private var txt_footer:BodyTextField;
   
   private var band1:GreenBand;
   
   private var band2:GreenBand;
   
   private var band3:GreenBand;
   
   public function PrizesPanel(param1:Number)
   {
      super();
      this._width = param1;
      var _loc2_:Language = Language.getInstance();
      var _loc3_:Shape = new Shape();
      _loc3_.graphics.beginFill(5072902,1);
      _loc3_.graphics.drawRect(0,0,this._width,20);
      addChild(_loc3_);
      this.txt_title = new BodyTextField({
         "color":7843645,
         "size":14,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_title.htmlText = _loc2_.getString("alliance.prizes_title");
      this.txt_title.maxWidth = this._width;
      this.txt_title.x = int((_loc3_.width - this.txt_title.width) * 0.5);
      this.txt_title.y = int((_loc3_.height - this.txt_title.height) * 0.5);
      addChild(this.txt_title);
      var _loc4_:XML = ResourceManager.getInstance().getResource("xml/alliances.xml").content as XML;
      var _loc5_:int = int(_loc4_.rewards[0].@memberCount);
      var _loc6_:Number = _loc5_ * int(_loc4_.rewards[0].item[0]);
      var _loc7_:Number = _loc5_ * int(_loc4_.rewards[0].item[1]);
      var _loc8_:Number = _loc5_ * int(_loc4_.rewards[0].item[2]);
      this.band1 = new GreenBand(this._width,_loc2_.getString("alliance.prizes_1st"),NumberFormatter.format(_loc6_,0),20,false);
      this.band1.y = _loc3_.y + _loc3_.height + 2;
      addChild(this.band1);
      this.band2 = new GreenBand(this._width,_loc2_.getString("alliance.prizes_2nd"),NumberFormatter.format(_loc7_,0),17,true);
      this.band2.y = this.band1.y + this.band1.height;
      addChild(this.band2);
      this.band3 = new GreenBand(this._width,_loc2_.getString("alliance.prizes_3rd"),NumberFormatter.format(_loc8_,0),14,false);
      this.band3.y = this.band2.y + this.band2.height;
      addChild(this.band3);
      _loc3_ = new Shape();
      _loc3_.graphics.beginFill(4216833,0.26);
      _loc3_.graphics.drawRect(0,0,this._width,30);
      _loc3_.y = this.band3.y + this.band3.height;
      addChild(_loc3_);
      this.txt_footer = new BodyTextField({
         "color":6253125,
         "size":11,
         "bold":true,
         "autoSize":"left",
         "multiline":true,
         "wordWrap":false,
         "filters":[Effects.STROKE]
      });
      this.txt_footer.width = this._width;
      this.txt_footer.htmlText = _loc2_.getString("alliance.prizes_footer");
      this.txt_footer.x = int((_loc3_.width - this.txt_footer.width) * 0.5);
      this.txt_footer.y = _loc3_.y + int((_loc3_.height - this.txt_footer.height) * 0.5);
      addChild(this.txt_footer);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.band1.dispose();
      this.band2.dispose();
      this.band3.dispose();
   }
}

class GreenBand extends Sprite
{
   
   private var bg:Shape;
   
   private var _width:Number = 20;
   
   private var _height:Number = 20;
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   private var icon:Bitmap;
   
   public function GreenBand(param1:Number, param2:String, param3:String, param4:Number = 12, param5:Boolean = false)
   {
      super();
      mouseEnabled = mouseChildren = false;
      this._width = param1;
      var _loc6_:Number = param5 ? 4216833 : 3292946;
      var _loc7_:Number = param5 ? 0.3 : 1;
      var _loc8_:Matrix = new Matrix();
      _loc8_.createGradientBox(this.width,this._height);
      this.bg = new Shape();
      this.bg.graphics.beginGradientFill(GradientType.LINEAR,[_loc6_,_loc6_,_loc6_],[_loc7_,_loc7_,0],[0,90,255],_loc8_);
      this.bg.graphics.drawRect(0,0,this._width,this._height);
      addChild(this.bg);
      this.icon = new Bitmap(new BmpIconFuel(),"auto",true);
      this.icon.scaleX = this.icon.scaleY = 0.5;
      this.icon.x = this._width - this.icon.width - 5;
      this.icon.y = int((this._height - this.icon.height) * 0.5);
      addChild(this.icon);
      this.txt_label = new BodyTextField({
         "text":param2,
         "color":16777215,
         "size":14,
         "bold":true,
         "autoSize":"left",
         "align":"center",
         "filters":[Effects.STROKE]
      });
      this.txt_label.x = 10;
      this.txt_label.y = int((this._height - this.txt_label.height) * 0.5) - 1;
      addChild(this.txt_label);
      this.txt_value = new BodyTextField({
         "text":param3,
         "color":10480209,
         "size":param4,
         "bold":true,
         "autoSize":"left",
         "filters":[Effects.STROKE]
      });
      this.txt_value.x = this.icon.x - this.txt_value.width - 3;
      this.txt_value.y = int((this._height - this.txt_value.height) * 0.5) - 1;
      addChild(this.txt_value);
   }
   
   public function dispose() : void
   {
      this.txt_label.dispose();
      this.txt_value.dispose();
      this.icon.bitmapData.dispose();
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
}
