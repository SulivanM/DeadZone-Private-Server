package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.math.MathUtils;
   import flash.display.Sprite;
   import flash.geom.Point;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.gui.UIRequirementsChecklist;
   import thelaststand.app.game.gui.survivor.UISurvivorArrivalProgress;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class CompoundReportDialogue extends BaseDialogue
   {
      
      private static var BAR_COLORS:Array = [8100169,5015205,9980051,10917503,11626328];
      
      private static var BAR_ICONS:Array = [new BmpIconFood(),new BmpIconWater(),new BmpIconComfort(),new BmpIconSecurity(),new BmpIconMorale()];
      
      private static var BAR_IDS:Array = ["food","water","comfort","security","morale"];
      
      private var _bars:Vector.<CompoundProgressBar>;
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var _newSurvivorCost:int;
      
      private var mc_container:Sprite;
      
      private var txt_desc:BodyTextField;
      
      private var ui_requirements:UIRequirementsChecklist;
      
      private var prog_survivor:UISurvivorArrivalProgress;
      
      public function CompoundReportDialogue()
      {
         var _loc1_:int = 0;
         var _loc4_:CompoundProgressBar = null;
         this.mc_container = new Sprite();
         super("compound-report-dialogue",this.mc_container,true);
         _autoSize = false;
         _width = 335;
         _height = 390;
         _padding = 12;
         _buttonClass = PushButton;
         _buttonSpacing = 34;
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         _loc1_ = _width - _padding * 2;
         addTitle(this._lang.getString("compound_report_title"),6398924);
         addButton(this._lang.getString("compound_report_ok"),true,{"width":118});
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_desc.width = _loc1_;
         this.txt_desc.y = 8;
         this.txt_desc.text = this._lang.getString("compound_report_desc");
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.mc_container.addChild(this.txt_desc);
         this.prog_survivor = new UISurvivorArrivalProgress();
         this.prog_survivor.width = _loc1_;
         this.prog_survivor.y = 56;
         this.mc_container.addChild(this.prog_survivor);
         this._bars = new Vector.<CompoundProgressBar>();
         var _loc2_:int = int(this.prog_survivor.y + this.prog_survivor.height + 10);
         var _loc3_:int = 0;
         while(_loc3_ < 5)
         {
            _loc4_ = new CompoundProgressBar(_loc1_,BAR_COLORS[_loc3_],BAR_ICONS[_loc3_]);
            _loc4_.label = this._lang.getString("compound_report_" + BAR_IDS[_loc3_]);
            _loc4_.y = _loc2_;
            this._tooltip.add(_loc4_,this._lang.getString("compound_report_" + BAR_IDS[_loc3_] + "_desc"),new Point(4,_loc4_.height * 0.5),TooltipDirection.DIRECTION_RIGHT,0.1);
            this._bars.push(_loc4_);
            this.mc_container.addChild(_loc4_);
            _loc2_ += _loc4_.height + 6;
            _loc3_++;
         }
         _loc2_ += 4;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc1_,62,0,_loc2_);
         this.ui_requirements = new UIRequirementsChecklist();
         this.ui_requirements.x = 3;
         this.ui_requirements.y = int(_loc2_ + this.ui_requirements.x);
         this.ui_requirements.width = int(_loc1_ - this.ui_requirements.x * 2);
         this.mc_container.addChild(this.ui_requirements);
         this.updateProgress();
      }
      
      override public function dispose() : void
      {
         this._tooltip.removeAllFromParent(this.mc_container,true);
         this._tooltip = null;
         super.dispose();
      }
      
      override public function open() : void
      {
         super.open();
         Tracking.trackPageview("compoundReport");
      }
      
      private function updateProgress() : void
      {
         var _loc1_:CompoundProgressBar = null;
         var _loc2_:PlayerData = Network.getInstance().playerData;
         var _loc3_:int = _loc2_.compound.survivors.length;
         var _loc4_:XML = ResourceManager.getInstance().getResource("xml/survivor.xml").content.survivor[_loc3_ - 1];
         var _loc5_:int = int(Config.constant.MAX_SURVIVORS);
         if(_loc3_ >= _loc5_)
         {
            this.prog_survivor.progress = 1;
            for each(_loc1_ in this._bars)
            {
               _loc1_.valueLabel = "";
               _loc1_.bar.value = 1;
               _loc1_.bar.maxValue = 1;
            }
            this.ui_requirements.list = null;
            return;
         }
         var _loc6_:int = 24 * 60 * 60;
         var _loc7_:int = int(Config.constant.SURVIVOR_ADULT_FOOD_CONSUMPTION);
         var _loc8_:int = int(Config.constant.SURVIVOR_ADULT_WATER_CONSUMPTION);
         if(_loc4_ == null)
         {
            return;
         }
         var _loc9_:Number = Number(_loc4_.food);
         var _loc10_:Number = _loc2_.compound.resources.getResourceDaysRemaining(GameResources.FOOD);
         _loc1_ = this.getProgressBar("food");
         _loc1_.valueLabel = this._lang.getString(_loc10_ != 1 ? "num_days" : "num_day",MathUtils.roundDownToNearest(_loc10_,0.5)) + " / " + this._lang.getString(_loc9_ != 1 ? "num_days" : "num_day",_loc9_);
         _loc1_.bar.maxValue = _loc9_;
         _loc1_.bar.value = Math.max(_loc10_,0);
         var _loc11_:Number = Number(_loc4_.water);
         var _loc12_:Number = _loc2_.compound.resources.getResourceDaysRemaining(GameResources.WATER);
         _loc1_ = this.getProgressBar("water");
         _loc1_.valueLabel = this._lang.getString(_loc12_ != 1 ? "num_days" : "num_day",MathUtils.roundDownToNearest(_loc12_,0.5)) + " / " + this._lang.getString(_loc11_ != 1 ? "num_days" : "num_day",_loc11_);
         _loc1_.bar.maxValue = _loc11_;
         _loc1_.bar.value = Math.max(_loc12_,0);
         var _loc13_:int = _loc2_.compound.getComfortRating();
         var _loc14_:int = int(_loc4_.comfort);
         _loc1_ = this.getProgressBar("comfort");
         _loc1_.valueLabel = _loc13_ + " / " + _loc14_;
         _loc1_.bar.maxValue = _loc14_;
         _loc1_.bar.value = Math.max(_loc13_,0);
         var _loc15_:int = _loc2_.compound.getSecurityRating();
         var _loc16_:int = int(_loc4_.security);
         _loc1_ = this.getProgressBar("security");
         _loc1_.valueLabel = _loc15_ + " / " + _loc16_;
         _loc1_.bar.maxValue = _loc16_;
         _loc1_.bar.value = Math.max(_loc15_,0);
         var _loc17_:int = _loc2_.compound.morale.getRoundedTotal();
         var _loc18_:int = int(_loc4_.morale);
         _loc1_ = this.getProgressBar("morale");
         _loc1_.valueLabel = _loc17_ + " / " + _loc18_;
         var _loc19_:Number = 0;
         if(_loc17_ >= _loc18_)
         {
            _loc19_ = 1;
         }
         else if(_loc18_ < 0)
         {
            _loc19_ = 1 + (_loc17_ - _loc18_) / -_loc18_;
         }
         _loc1_.bar.maxValue = 1;
         _loc1_.bar.value = Math.max(_loc19_,0);
         this.ui_requirements.list = _loc4_.req.children();
         var _loc20_:Number = 0;
         var _loc21_:int = 0;
         while(_loc21_ < this._bars.length)
         {
            _loc20_ += this._bars[_loc21_].bar.maxValue != 0 ? this._bars[_loc21_].bar.value / this._bars[_loc21_].bar.maxValue : 1;
            _loc21_++;
         }
         this.prog_survivor.progress = _loc20_ / this._bars.length;
      }
      
      private function getProgressBar(param1:String) : CompoundProgressBar
      {
         return this._bars[BAR_IDS.indexOf(param1)];
      }
   }
}

import com.deadreckoned.threshold.display.Color;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.gui.UILargeProgressBar;
import thelaststand.app.utils.GraphicUtils;

class CompoundProgressBar extends Sprite
{
   
   private var _label:String;
   
   private var _valueLabel:String = "0 / 0";
   
   private var bmp_icon:Bitmap;
   
   private var mc_iconBG:Shape;
   
   private var mc_track:Shape;
   
   private var mc_bar:UILargeProgressBar;
   
   private var txt_label:BodyTextField;
   
   private var txt_valueLabel:BodyTextField;
   
   public function CompoundProgressBar(param1:int, param2:uint, param3:BitmapData)
   {
      super();
      mouseChildren = false;
      var _loc4_:Color = new Color(param2);
      _loc4_.s *= 0.5;
      _loc4_.v *= 0.75;
      this.mc_iconBG = new Shape();
      this.mc_iconBG.graphics.beginFill(_loc4_.RGB);
      this.mc_iconBG.graphics.drawRect(0,0,36,28);
      this.mc_iconBG.graphics.endFill();
      addChild(this.mc_iconBG);
      this.bmp_icon = new Bitmap(param3);
      this.bmp_icon.x = int(this.mc_iconBG.x + (this.mc_iconBG.width - this.bmp_icon.width) * 0.5);
      this.bmp_icon.y = int(this.mc_iconBG.y + (this.mc_iconBG.height - this.bmp_icon.height) * 0.5);
      this.bmp_icon.filters = [Effects.ICON_SHADOW];
      addChild(this.bmp_icon);
      this.mc_track = new Shape();
      this.mc_track.x = int(this.mc_iconBG.x + this.mc_iconBG.width + 3);
      GraphicUtils.drawUIBlock(this.mc_track.graphics,param1 - this.mc_track.x,28);
      addChild(this.mc_track);
      var _loc5_:int = 4;
      this.mc_bar = new UILargeProgressBar(param2,this.mc_track.width - _loc5_ * 2,this.mc_track.height - _loc5_ * 2);
      this.mc_bar.x = this.mc_track.x + _loc5_;
      this.mc_bar.y = this.mc_track.y + _loc5_;
      this.mc_bar.maxValue = 100;
      this.mc_bar.value = 100;
      addChild(this.mc_bar);
      this.txt_label = new BodyTextField({
         "color":16777215,
         "size":14,
         "bold":true
      });
      this.txt_label.text = " ";
      this.txt_label.x = int(this.mc_bar.x + 2);
      this.txt_label.y = int(this.mc_bar.y + (this.mc_bar.height - this.txt_label.height) * 0.5);
      this.txt_label.filters = [Effects.TEXT_SHADOW_DARK];
      addChild(this.txt_label);
      this.txt_valueLabel = new BodyTextField({
         "color":16777215,
         "size":14,
         "bold":true
      });
      this.txt_valueLabel.text = this._valueLabel;
      this.txt_valueLabel.x = int(this.mc_bar.x + this.mc_bar.width - this.txt_valueLabel.width - 2);
      this.txt_valueLabel.y = int(this.mc_bar.y + (this.mc_bar.height - this.txt_label.height) * 0.5);
      this.txt_valueLabel.filters = [Effects.TEXT_SHADOW_DARK];
      addChild(this.txt_valueLabel);
   }
   
   public function get bar() : UILargeProgressBar
   {
      return this.mc_bar;
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
      this.txt_label.text = this._label.toUpperCase();
   }
   
   public function get valueLabel() : String
   {
      return this._valueLabel;
   }
   
   public function set valueLabel(param1:String) : void
   {
      this._valueLabel = param1;
      this.txt_valueLabel.text = this._valueLabel;
      this.txt_valueLabel.x = int(this.mc_bar.x + this.mc_bar.width - this.txt_valueLabel.width - 2);
   }
}
