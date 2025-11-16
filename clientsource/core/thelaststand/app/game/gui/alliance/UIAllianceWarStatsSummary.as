package thelaststand.app.game.gui.alliance
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import thelaststand.app.game.data.alliance.AllianceLifetimeStats;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceWarStatsSummary extends Sprite
   {
      
      private static const INNER_SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,8,8,5,1,true);
      
      private static const STROKE:GlowFilter = new GlowFilter(6905685,1,1.75,1.75,10,1);
      
      private static const DROP_SHADOW:DropShadowFilter = new DropShadowFilter(1,45,0,1,8,8,1,2);
      
      private static const BMP_TITLEBAR:BitmapData = new BmpTopBarBackground();
      
      private static const WIDTH:int = 300;
      
      private var mc_background:Shape;
      
      private var ui_title:UITitleBar;
      
      private var _order:Array;
      
      private var _lang:Language;
      
      public function UIAllianceWarStatsSummary()
      {
         var _loc1_:StatsBand = null;
         var _loc3_:Object = null;
         var _loc4_:StatsBand = null;
         this._order = [];
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this._lang = Language.getInstance();
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(1184274);
         this.mc_background.graphics.drawRect(0,0,10,10);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [INNER_SHADOW,STROKE,DROP_SHADOW];
         addChild(this.mc_background);
         this.ui_title = new UITitleBar({
            "text":" ",
            "size":22
         });
         this.ui_title.width = WIDTH - 12;
         this.ui_title.x = this.ui_title.y = 6;
         addChild(this.ui_title);
         this._order = [{
            "label":this._lang.getString("alliance.history_lifetime_points"),
            "prop":"points"
         },{
            "label":this._lang.getString("alliance.history_lifetime_attackSuccess"),
            "prop":"wins"
         },{
            "label":this._lang.getString("alliance.history_lifetime_attackFail"),
            "prop":"losses"
         },{
            "label":this._lang.getString("alliance.history_lifetime_attackAbandon"),
            "prop":"abandons"
         },{
            "label":this._lang.getString("alliance.history_lifetime_attackPoints"),
            "prop":"pointsAttack"
         },{
            "label":this._lang.getString("alliance.history_lifetime_defenseSuccess"),
            "prop":"defWins"
         },{
            "label":this._lang.getString("alliance.history_lifetime_defenseFail"),
            "prop":"defLosses"
         },{
            "label":this._lang.getString("alliance.history_lifetime_defensePoints"),
            "prop":"pointsDefend"
         },{
            "label":this._lang.getString("alliance.history_lifetime_raidPerc"),
            "prop":"raidPerc",
            "perc":true
         },{
            "label":this._lang.getString("alliance.history_lifetime_missionSuccess"),
            "prop":"missionSuccess"
         },{
            "label":this._lang.getString("alliance.history_lifetime_missionFail"),
            "prop":"missionFail"
         },{
            "label":this._lang.getString("alliance.history_lifetime_missionAbandon"),
            "prop":"missionAbandon"
         },{
            "label":this._lang.getString("alliance.history_lifetime_missionPerc"),
            "prop":"missionPerc",
            "perc":true
         }];
         var _loc2_:int = 0;
         while(_loc2_ < this._order.length)
         {
            _loc3_ = this._order[_loc2_];
            _loc4_ = new StatsBand(WIDTH - 12,Boolean(_loc3_.perc),_loc2_ % 2 == 0 ? 0 : 3552822);
            _loc3_["band"] = _loc4_;
            _loc4_.label = _loc3_.label;
            _loc4_.x = 6;
            _loc4_.y = _loc1_ == null ? this.ui_title.y + this.ui_title.height + 4 : _loc1_.y + _loc1_.height;
            addChild(_loc4_);
            _loc1_ = _loc4_;
            _loc2_++;
         }
         this.mc_background.width = WIDTH;
         this.mc_background.height = _loc1_.y + _loc1_.height + 8;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this.ui_title.dispose();
      }
      
      public function setData(param1:AllianceLifetimeStats) : void
      {
         var _loc3_:Object = null;
         var _loc4_:StatsBand = null;
         this.ui_title.title = param1.userName + " " + this._lang.getString("alliance.history_lifetime_summaryTitle");
         var _loc2_:int = 0;
         while(_loc2_ < this._order.length)
         {
            _loc3_ = this._order[_loc2_];
            _loc4_ = _loc3_["band"];
            _loc4_.value = param1[_loc3_["prop"]];
            _loc2_++;
         }
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

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Shape;
import flash.display.Sprite;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;

class StatsBand extends Sprite
{
   
   private var bg:Shape;
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   private var _isPerc:Boolean = false;
   
   public function StatsBand(param1:uint, param2:Boolean, param3:uint = 0)
   {
      super();
      this._isPerc = param2;
      this.bg = new Shape();
      this.bg.graphics.beginFill(param3,1);
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
   
   public function set value(param1:Number) : void
   {
      if(this._isPerc)
      {
         this.txt_value.text = NumberFormatter.format(param1,2,",",true) + "%";
      }
      else
      {
         this.txt_value.text = NumberFormatter.format(param1,0,",",false);
      }
      this.txt_value.x = this.bg.width - 10 - this.txt_value.width;
   }
}
