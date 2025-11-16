package thelaststand.app.game.gui
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIXPCounterBar extends Sprite
   {
      
      private var _xpCount:int = 0;
      
      private var _levelCount:int = 0;
      
      private var _width:int = 0;
      
      private var _height:int = 26;
      
      private var _padding:int = 3;
      
      private var mc_hitArea:Sprite;
      
      private var mc_bg:Shape;
      
      private var mc_xpBG:Shape;
      
      private var ui_xp:UILargeProgressBar;
      
      private var ui_targetXP:UILargeProgressBar;
      
      private var ui_xpPlayhead:XPEarnedPlayhead;
      
      private var txt_xp:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      public var startXP:int = 0;
      
      public var startLevel:int = 0;
      
      public var endXP:int = 0;
      
      public var endLevel:int = 0;
      
      public var xpTotal:int = 0;
      
      public var levelMax:int = -1;
      
      public function UIXPCounterBar(param1:int = 330, param2:int = 26)
      {
         super();
         this._width = param1;
         this._height = param2;
         mouseChildren = false;
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_targetXP = new UILargeProgressBar(14392064,this._width - this._padding * 2,param2 - this._padding * 2);
         this.ui_targetXP.alpha = 0.15;
         this.ui_targetXP.animate = false;
         this.ui_targetXP.maxValue = 0;
         this.ui_targetXP.value = 0;
         this.ui_targetXP.x = this._padding;
         this.ui_targetXP.y = this._padding;
         addChild(this.ui_targetXP);
         this.ui_xp = new UILargeProgressBar(14392064,this._width - this._padding * 2,this._height - this._padding * 2);
         this.ui_xp.animate = false;
         this.ui_xp.maxValue = 0;
         this.ui_xp.value = 0;
         this.ui_xp.x = this.ui_targetXP.x;
         this.ui_xp.y = this.ui_targetXP.y;
         addChild(this.ui_xp);
         this.mc_xpBG = new Shape();
         this.mc_xpBG.graphics.beginFill(12027148,0.85);
         this.mc_xpBG.graphics.drawRect(0,0,10,10);
         this.mc_xpBG.graphics.endFill();
         addChild(this.mc_xpBG);
         this.ui_xpPlayhead = new XPEarnedPlayhead();
         this.ui_xpPlayhead.y = int(this.ui_xp.y + this.ui_xp.height * 0.5);
         this.ui_xpPlayhead.filters = [Effects.STROKE];
         addChild(this.ui_xpPlayhead);
         this.txt_xp = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         this.txt_xp.filters = [Effects.TEXT_SHADOW];
         this.txt_xp.text = " ";
         this.txt_xp.x = 0;
         this.txt_xp.y = -22;
         addChild(this.txt_xp);
         this.txt_level = new BodyTextField({
            "color":16766340,
            "size":14,
            "bold":true
         });
         this.txt_level.filters = [Effects.STROKE,Effects.TEXT_SHADOW];
         this.txt_level.text = " ";
         this.txt_level.x = int(this._width - this.txt_level.width);
         this.txt_level.y = int(this.ui_xp.y + (this.ui_xp.height - this.txt_level.height) * 0.5);
         addChild(this.txt_level);
         this.mc_xpBG.height = int(this.txt_xp.height + 2);
         this.mc_xpBG.y = int(this.txt_xp.y + (this.txt_xp.height - this.mc_xpBG.height) * 0.5);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.y = this.mc_xpBG.y;
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,this._width,this._height + 24);
         this.mc_hitArea.graphics.endFill();
         hitArea = this.mc_hitArea;
         addChildAt(this.mc_hitArea,0);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         removeEventListener(Event.ENTER_FRAME,this.updateXPAnimation);
         this.ui_targetXP.dispose();
         this.ui_targetXP = null;
         this.ui_xp.dispose();
         this.ui_xp = null;
         this.ui_xpPlayhead.filters = [];
         this.ui_xpPlayhead = null;
         this.txt_xp.dispose();
         this.txt_xp = null;
         this.txt_level.dispose();
         this.txt_level = null;
      }
      
      public function animate() : void
      {
         var _loc1_:ColorTransform = null;
         this._xpCount = this.xpTotal;
         this._levelCount = this.startLevel;
         this.ui_xp.animate = this.ui_targetXP.animate = false;
         this.ui_xpPlayhead.visible = this.mc_xpBG.visible = this.txt_xp.visible = true;
         this.ui_xp.maxValue = Network.getInstance().playerData.getPlayerSurvivor().getXPForLevel(this.startLevel + 1);
         this.ui_xp.value = this.startXP;
         this.ui_xpPlayhead.x = int(this.ui_xp.x + this.ui_xp.width * (this.ui_xp.value / this.ui_xp.maxValue));
         this.ui_targetXP.maxValue = this.ui_xp.maxValue;
         this.ui_targetXP.value = this.endLevel == this.startLevel ? this.endXP : this.ui_targetXP.maxValue;
         this.txt_xp.text = Language.getInstance().getString("msg_xp_awarded",int(this.xpTotal - this._xpCount));
         this.txt_xp.x = Math.max(0,Math.min(int(this.ui_xpPlayhead.x - this.txt_xp.width * 0.5),this._width - this.txt_xp.width));
         this.txt_level.text = Language.getInstance().getString("lvl",this._levelCount + 1) + (this.levelMax > -1 && this._levelCount >= this.levelMax ? " (" + Language.getInstance().getString("max").toUpperCase() + ")" : "");
         this.txt_level.x = int(this._width - this.txt_level.width - 4);
         this.mc_xpBG.width = this.txt_xp.width + 4;
         this.mc_xpBG.x = int(this.txt_xp.x + (this.txt_xp.width - this.mc_xpBG.width) * 0.5);
         if(this.xpTotal == 0)
         {
            _loc1_ = new ColorTransform();
            _loc1_.color = 3750201;
            this.mc_xpBG.transform.colorTransform = _loc1_;
            this.txt_xp.textColor = 10263708;
         }
         addEventListener(Event.ENTER_FRAME,this.updateXPAnimation,false,0,true);
      }
      
      private function updateXPAnimation(param1:Event) : void
      {
         var _loc2_:Number = this.xpTotal * (1 / 60) / 3;
         this._xpCount -= _loc2_;
         if(this._xpCount < 0)
         {
            this._xpCount = 0;
         }
         var _loc3_:Number = this.ui_xp.value + _loc2_;
         if(_loc3_ > this.ui_xp.maxValue)
         {
            ++this._levelCount;
            _loc3_ -= this.ui_xp.value;
            this.ui_xp.value = this.ui_targetXP.value = 0;
            this.ui_xp.maxValue = this.ui_targetXP.maxValue = Network.getInstance().playerData.getPlayerSurvivor().getXPForLevel(this._levelCount + 1);
            this.ui_targetXP.value = this._levelCount == this.endLevel ? this.endXP : this.ui_targetXP.maxValue;
            this.txt_level.text = Language.getInstance().getString("lvl",this._levelCount + 1);
            this.txt_level.x = int(this._width - this.txt_level.width - 4);
            this.txt_level.scaleX = this.txt_level.scaleY = 1;
            this.txt_level.transform.colorTransform = Effects.CT_DEFAULT;
            TweenMax.from(this.txt_level,0.5,{
               "colorTransform":{"exposure":2},
               "transformAroundCenter":{
                  "scaleX":1.15,
                  "scaleY":1.15
               }
            });
         }
         if(this._levelCount == this.endLevel && _loc3_ > this.endXP)
         {
            _loc3_ = this.endXP;
         }
         this.ui_xp.value = _loc3_;
         this.ui_xpPlayhead.x = int(this.ui_xp.x + this.ui_xp.width * (this.ui_xp.value / this.ui_xp.maxValue));
         this.txt_xp.text = Language.getInstance().getString("msg_xp_awarded",NumberFormatter.format(int(this.xpTotal - this._xpCount),0));
         this.txt_xp.x = Math.max(0,Math.min(int(this.ui_xpPlayhead.x - this.txt_xp.width * 0.5),this._width - this.txt_xp.width));
         this.mc_xpBG.width = this.txt_xp.width + 4;
         this.mc_xpBG.x = int(this.txt_xp.x + (this.txt_xp.width - this.mc_xpBG.width) * 0.5);
         if(this._xpCount == 0)
         {
            removeEventListener(Event.ENTER_FRAME,this.updateXPAnimation);
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
   }
}

