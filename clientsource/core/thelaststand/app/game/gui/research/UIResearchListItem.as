package thelaststand.app.game.gui.research
{
   import com.exileetiquette.math.MathUtils;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIResearchListItem extends UIComponent
   {
      
      public static const STATE_UNAVAILABLE:uint = 0;
      
      public static const STATE_AVAILABLE:uint = 1;
      
      public static const STATE_RESEARCHING:uint = 2;
      
      public static const STATE_COMPLETED:uint = 3;
      
      private var _width:int;
      
      private var _height:int = 28;
      
      private var _state:uint = 0;
      
      private var _iconPadding:int = 4;
      
      private var _category:String;
      
      private var _group:String;
      
      private var _maxLevel:int;
      
      private var _level:int;
      
      private var _xmlGroup:XML;
      
      private var _selected:Boolean;
      
      private var _progress:Number;
      
      private var _progressColor:uint = 537931;
      
      private var mc_progress:Shape;
      
      private var mc_iconBackground:Shape;
      
      private var bmp_icon:Bitmap;
      
      private var txt_group:BodyTextField;
      
      private var txt_effect:BodyTextField;
      
      public function UIResearchListItem()
      {
         super();
         mouseChildren = false;
         this.mc_progress = new Shape();
         this.mc_progress.graphics.beginFill(this._progressColor);
         this.mc_progress.graphics.drawRect(0,0,2,2);
         this.mc_progress.graphics.endFill();
         addChild(this.mc_progress);
         this.mc_iconBackground = new Shape();
         addChild(this.mc_iconBackground);
         this.bmp_icon = new Bitmap();
         addChild(this.bmp_icon);
         this.txt_group = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_group);
         this.txt_effect = new BodyTextField({
            "color":16777215,
            "size":13,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_effect);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function get xmlGroup() : XML
      {
         return this._xmlGroup;
      }
      
      public function set xmlGroup(param1:XML) : void
      {
         this._xmlGroup = param1;
         this._category = this._xmlGroup.parent().@id.toString();
         this._group = this._xmlGroup.@id.toString();
         this._maxLevel = ResearchSystem.getMaxLevel(this._category,this._group);
         invalidate();
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function set level(param1:int) : void
      {
         this._level = param1;
         invalidate();
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
      
      public function set progress(param1:Number) : void
      {
         this._progress = MathUtils.clamp(param1,0,1);
         this.mc_progress.height = this._height;
         this.mc_progress.width = this._width * this._progress;
         this.mc_progress.visible = this._progress > 0;
      }
      
      public function get progressColor() : uint
      {
         return this._progressColor;
      }
      
      public function set progressColor(param1:uint) : void
      {
         if(param1 != this._progressColor)
         {
            this._progressColor = param1;
            this.mc_progress.graphics.clear();
            this.mc_progress.graphics.beginFill(this._progressColor);
            this.mc_progress.graphics.drawRect(0,0,2,2);
            this.mc_progress.graphics.endFill();
         }
      }
      
      public function get state() : uint
      {
         return this._state;
      }
      
      public function set state(param1:uint) : void
      {
         this._state = param1;
         invalidate();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this.updateSelectedState();
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
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_group.dispose();
         this.txt_effect.dispose();
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
         }
      }
      
      override protected function draw() : void
      {
         this._xmlGroup;
         graphics.clear();
         graphics.beginFill(0,0.5);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         var _loc1_:int = int(this._height - this._iconPadding * 2);
         this.mc_iconBackground.graphics.clear();
         this.mc_iconBackground.graphics.beginFill(1907997);
         this.mc_iconBackground.graphics.drawRect(0,0,_loc1_,_loc1_);
         this.mc_iconBackground.graphics.endFill();
         this.mc_iconBackground.x = this._iconPadding;
         this.mc_iconBackground.y = this._iconPadding;
         var _loc2_:* = ResearchSystem.getCategoryGroupName(this._category,this._group).toUpperCase() + "  <font color=\'#FFCC00\'>" + Language.getInstance().getString("lvl",this._level + 1) + "</font>";
         this.txt_group.htmlText = _loc2_;
         this.txt_group.x = int(this.mc_iconBackground.x + this.mc_iconBackground.width + 4);
         this.txt_group.y = int((this._height - this.txt_group.height) * 0.5);
         this.txt_effect.text = "(" + ResearchSystem.getCategoryGroupEffectDescription(this._category,this._group,this._level) + ")";
         this.txt_effect.x = int(this._width - this.txt_effect.width - 4);
         this.txt_effect.y = int((this._height - this.txt_effect.height) * 0.5);
         this.mc_progress.height = this._height;
         this.mc_progress.width = this._width * this._progress;
         this.mc_progress.visible = this._progress > 0;
         this.updateState();
      }
      
      private function updateState() : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Class = null;
         var _loc1_:String = this.txt_group.htmlText;
         switch(this._state)
         {
            case STATE_UNAVAILABLE:
               this.txt_group.textColor = 5066061;
               this.txt_effect.textColor = 5066061;
               _loc2_ = 0;
               _loc3_ = null;
               break;
            case STATE_AVAILABLE:
               this.txt_group.textColor = 16777215;
               this.txt_group.htmlText = _loc1_;
               this.txt_effect.textColor = 7258192;
               _loc2_ = 1907997;
               _loc3_ = null;
               break;
            case STATE_RESEARCHING:
               this.txt_group.textColor = 16777215;
               this.txt_group.htmlText = _loc1_;
               this.txt_effect.textColor = 7258192;
               _loc2_ = 1921383;
               _loc3_ = BmpIconResearch;
               break;
            case STATE_COMPLETED:
               this.txt_group.textColor = 7258192;
               this.txt_effect.textColor = 7258192;
               _loc2_ = 1461516;
               _loc3_ = BmpIconTradeTickGreen;
         }
         if(_loc3_ == null)
         {
            if(this.bmp_icon.bitmapData != null)
            {
               this.bmp_icon.bitmapData.dispose();
            }
         }
         else
         {
            if(this.bmp_icon.bitmapData != null)
            {
               this.bmp_icon.bitmapData.dispose();
            }
            this.bmp_icon.bitmapData = new _loc3_() as BitmapData;
         }
         this.bmp_icon.x = int(this.mc_iconBackground.x + (this.mc_iconBackground.width - this.bmp_icon.width) / 2);
         this.bmp_icon.y = int(this.mc_iconBackground.y + (this.mc_iconBackground.height - this.bmp_icon.height) / 2);
         var _loc4_:ColorTransform = new ColorTransform();
         _loc4_.color = _loc2_;
         this.mc_iconBackground.transform.colorTransform = _loc4_;
      }
      
      private function updateSelectedState() : void
      {
         var _loc1_:ColorTransform = new ColorTransform();
         if(this._selected)
         {
            TweenMax.to(this,0,{
               "colorTransform":{"exposure":1.25},
               "overwrite":true
            });
         }
         else
         {
            TweenMax.to(this,0,{
               "colorTransform":{"exposure":1},
               "overwrite":true
            });
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this._selected)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-over.mp3");
         TweenMax.to(this,0,{
            "colorTransform":{"exposure":1.1},
            "overwrite":true
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this._selected)
         {
            return;
         }
         TweenMax.to(this,0.25,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
         if(this._selected)
         {
            return;
         }
         TweenMax.to(this,0,{"colorTransform":{"exposure":1.5}});
         TweenMax.to(this,0.25,{
            "delay":0.01,
            "colorTransform":{"exposure":1.1}
         });
      }
   }
}

