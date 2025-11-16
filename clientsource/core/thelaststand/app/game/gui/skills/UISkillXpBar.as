package thelaststand.app.game.gui.skills
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TimelineMax;
   import com.greensock.TweenAlign;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Quad;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.skills.SkillState;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UISkillXpBar extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _padding:int = 3;
      
      private var _skill:SkillState;
      
      private var _showName:Boolean = true;
      
      private var _bmdBarFill:BitmapData;
      
      private var _bmpMatrix:Matrix = new Matrix();
      
      private var _barTweenProxy:Object = {};
      
      private var _currentProgress:Number = 0;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var mc_bar:Shape;
      
      public function UISkillXpBar()
      {
         super();
         this.mc_bar = new Shape();
         addChild(this.mc_bar);
         this.txt_name = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_name);
         this.txt_level = new BodyTextField({
            "color":7261167,
            "size":14,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_level);
         TooltipManager.getInstance().add(this,this.getTooltip,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
      }
      
      public function get showName() : Boolean
      {
         return this._showName;
      }
      
      public function set showName(param1:Boolean) : void
      {
         this._showName = param1;
         invalidate();
      }
      
      public function get skillState() : SkillState
      {
         return this._skill;
      }
      
      public function set skillState(param1:SkillState) : void
      {
         if(param1 == this._skill)
         {
            return;
         }
         if(this._skill != null)
         {
            this._skill.changed.remove(this.onSkillStateChanged);
         }
         this._skill = param1;
         if(this._skill != null)
         {
            this._skill.changed.add(this.onSkillStateChanged);
         }
         invalidate();
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
         TooltipManager.getInstance().remove(this);
         TweenMax.killTweensOf(this._barTweenProxy);
         TweenMax.killTweensOf(this.mc_bar);
         this.txt_name.dispose();
         this.txt_level.dispose();
         if(this._bmdBarFill != null)
         {
            this._bmdBarFill.dispose();
         }
         if(this._skill != null)
         {
            this._skill.changed.remove(this.onSkillStateChanged);
         }
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         if(this._skill == null)
         {
            this.txt_level.visible = false;
            this.txt_name.visible = false;
            this.mc_bar.visible = false;
         }
         else
         {
            this.txt_name.htmlText = Language.getInstance().getString("skills." + this._skill.id).toUpperCase();
            this.txt_name.visible = this._showName;
            this.updateLevelText(this._skill.level);
            this.txt_level.visible = true;
            this.mc_bar.visible = true;
            this._currentProgress = this._skill.levelProgress;
            this.drawProgressBar(this._skill.levelProgress);
         }
         this.txt_name.x = 8;
         this.txt_name.y = int((this._height - this.txt_name.height) * 0.5);
      }
      
      private function getTooltip() : String
      {
         var _loc1_:int = 0;
         if(this._skill == null)
         {
            return null;
         }
         if(this._skill.isAtMaxLevel)
         {
            _loc1_ = this._skill.getXpForLevel(this._skill.maxLevel);
            return NumberFormatter.format(_loc1_,0) + " / " + NumberFormatter.format(_loc1_,0);
         }
         return NumberFormatter.format(this._skill.xp,0) + " / " + NumberFormatter.format(this._skill.getXpForLevel(this._skill.level + 1),0);
      }
      
      private function drawProgressBar(param1:Number) : void
      {
         if(this._bmdBarFill == null)
         {
            this._bmdBarFill = new BmpResearchProgressBg();
         }
         var _loc2_:int = this._width - this._padding * 2;
         var _loc3_:int = this._height - this._padding * 2;
         var _loc4_:int = Math.max(_loc2_ * param1,1);
         this.mc_bar.x = this._padding;
         this.mc_bar.y = this._padding;
         this._bmpMatrix.createBox(1,1,0,0,0);
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginBitmapFill(this._bmdBarFill,this._bmpMatrix,true,true);
         this.mc_bar.graphics.drawRect(0,0,_loc4_,_loc3_);
         this.mc_bar.graphics.endFill();
         this.mc_bar.visible = param1 > 0;
      }
      
      private function onSkillStateChanged(param1:SkillState, param2:int, param3:int) : void
      {
         var _loc8_:Number = NaN;
         TweenMax.killTweensOf(this._barTweenProxy);
         TweenMax.killTweensOf(this.mc_bar);
         this.mc_bar.transform.colorTransform = Effects.CT_DEFAULT;
         var _loc4_:int = param1.level - param3;
         var _loc5_:TimelineMax = new TimelineMax({"align":TweenAlign.SEQUENCE});
         var _loc6_:Number = 0;
         var _loc7_:int = 0;
         while(_loc7_ <= param3)
         {
            _loc8_ = _loc7_ == 0 ? this._currentProgress : 0;
            if(_loc7_ == param3)
            {
               if(!param1.isAtMaxLevel)
               {
                  _loc6_ += this.tweenBar(_loc5_,_loc6_,_loc8_,param1.levelProgress,this._skill.level,Quad.easeOut);
               }
            }
            else
            {
               _loc6_ += this.tweenBar(_loc5_,_loc6_,_loc8_,1,_loc4_ + _loc7_,Linear.easeNone,true);
            }
            _loc7_++;
         }
         _loc5_.play();
      }
      
      private function tweenBar(param1:TimelineMax, param2:Number, param3:Number, param4:Number, param5:int, param6:Function, param7:Boolean = false) : Number
      {
         var glowUpTime:Number;
         var fadeUpTime:Number = NaN;
         var fadeDownTime:Number = NaN;
         var color:Object = null;
         var timeline:TimelineMax = param1;
         var offset:Number = param2;
         var startProgress:Number = param3;
         var endProgress:Number = param4;
         var level:int = param5;
         var ease:Function = param6;
         var levelUp:Boolean = param7;
         var change:Number = endProgress - startProgress;
         var width:int = this._width - this._padding * 2;
         var time:Number = Math.max(change * width * (1 / 150),0.1);
         timeline.insert(TweenMax.to(this._barTweenProxy,time,{
            "value":endProgress,
            "ease":ease,
            "onInit":function():void
            {
               _barTweenProxy.value = startProgress;
            },
            "onStart":function():void
            {
               mc_bar.transform.colorTransform = Effects.CT_DEFAULT;
               updateLevelText(level);
            },
            "onUpdate":function():void
            {
               drawProgressBar(_barTweenProxy.value);
            },
            "onComplete":function():void
            {
               _currentProgress = endProgress;
               drawProgressBar(endProgress);
            }
         }),offset);
         glowUpTime = 0.15;
         timeline.insert(TweenMax.to(this.mc_bar,glowUpTime,{
            "colorTransform":{"exposure":1.25},
            "ease":Quad.easeOut
         }),offset);
         timeline.insert(TweenMax.to(this.mc_bar,1,{
            "colorTransform":{"exposure":1},
            "ease":Quad.easeInOut
         }),offset + glowUpTime);
         if(levelUp)
         {
            fadeUpTime = 0.15;
            offset += time;
            timeline.insert(TweenMax.to(this.mc_bar,fadeUpTime,{
               "colorTransform":{"exposure":2},
               "ease":Quad.easeOut,
               "onComplete":function():void
               {
                  updateLevelText(level + 1);
               }
            }),offset);
            fadeDownTime = 1;
            color = level + 1 == this._skill.maxLevel ? {"exposure":1} : {"alphaMultiplier":0};
            offset += fadeUpTime;
            timeline.insert(TweenMax.to(this.mc_bar,fadeDownTime,{
               "colorTransform":color,
               "ease":Quad.easeInOut
            }),offset);
            time += fadeUpTime + fadeDownTime;
         }
         return time;
      }
      
      private function updateLevelText(param1:int) : void
      {
         this.txt_level.text = Language.getInstance().getString("lvl",param1 + 1).toUpperCase();
         this.txt_level.x = int(this._width - this.txt_level.width - 4);
         this.txt_level.y = int((this._height - this.txt_level.height) * 0.5);
      }
   }
}

