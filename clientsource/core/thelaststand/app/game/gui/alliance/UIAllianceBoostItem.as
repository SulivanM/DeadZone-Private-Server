package thelaststand.app.game.gui.alliance
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.MiscEffectItem;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceBoostItem extends UIComponent
   {
      
      private var _cost:uint;
      
      private var _active:Boolean;
      
      private var _effect:Effect;
      
      private var _color:uint;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _costHeight:int = 18;
      
      private var _borderGlow:GlowFilter;
      
      private var _strokeGlow:GlowFilter;
      
      private var mc_background:Sprite;
      
      private var mc_border:Shape;
      
      private var ui_image:UIImage;
      
      private var bmp_token:Bitmap;
      
      private var txt_cost:BodyTextField;
      
      private var _effectItem:MiscEffectItem;
      
      public var mouseOver:NativeSignal;
      
      public var mouseOut:NativeSignal;
      
      public var clicked:NativeSignal;
      
      public function UIAllianceBoostItem(param1:uint, param2:Effect)
      {
         super();
         mouseChildren = false;
         this._color = param1;
         this._effect = param2;
         this.mc_background = new Sprite();
         addChild(this.mc_background);
         this._borderGlow = new GlowFilter(5460819,1,4,4,10,1,false,true);
         this._strokeGlow = new GlowFilter(855309,1,2,2,10,1);
         this.mc_border = new Shape();
         this.mc_border.filters = [this._borderGlow,this._strokeGlow];
         addChild(this.mc_border);
         this.ui_image = new UIImage(62,62,0,0,true,this._effect.imageURI);
         addChild(this.ui_image);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver.add(this.onMouseOver);
         this.mouseOut.add(this.onMouseOut);
      }
      
      public function get effect() : Effect
      {
         return this._effect;
      }
      
      public function get effectItem() : MiscEffectItem
      {
         if(this._effectItem == null)
         {
            this._effectItem = new MiscEffectItem();
         }
         this._effectItem.effect = this._effect;
         return this._effectItem;
      }
      
      public function get cost() : uint
      {
         return this._cost;
      }
      
      public function set cost(param1:uint) : void
      {
         if(param1 == this._cost)
         {
            return;
         }
         this._cost = param1;
         invalidate();
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         this._active = param1;
         this._borderGlow.color = this._active ? 8677392 : 5460819;
         this.updateBorderFilters();
         invalidate();
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
      
      override public function dispose() : void
      {
         super.dispose();
         this._effect = null;
         this.mouseOver.removeAll();
         this.mouseOut.removeAll();
         this.clicked.removeAll();
         this.ui_image.dispose();
         if(this.bmp_token != null)
         {
            this.bmp_token.bitmapData.dispose();
         }
         if(this.txt_cost != null)
         {
            this.txt_cost.dispose();
         }
         if(this._effectItem != null)
         {
            this._effectItem.dispose();
         }
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         TweenMax.killChildTweensOf(this);
         this._width = int(this.ui_image.width + 2);
         this._height = this._cost > 0 ? int(this._width + this._costHeight + 1) : this._width;
         this.ui_image.x = this.ui_image.y = 1;
         this.mc_border.graphics.clear();
         this.mc_border.graphics.beginFill(16711680);
         this.mc_border.graphics.drawRect(0,0,this._width,this._height);
         this.mc_border.graphics.endFill();
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(855309);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginFill(this._color);
         this.mc_background.graphics.drawRect(1,1,this.ui_image.width,this.ui_image.height);
         this.mc_background.graphics.endFill();
         if(this._cost > 0)
         {
            _loc1_ = int(this.ui_image.y + this.ui_image.height + 1);
            this.mc_background.graphics.beginFill(this._active ? 13406506 : 7022104);
            this.mc_background.graphics.drawRect(1,_loc1_,this.ui_image.width,this._costHeight);
            this.mc_background.graphics.endFill();
            if(this.txt_cost == null)
            {
               this.txt_cost = new BodyTextField({
                  "color":16777215,
                  "size":13,
                  "bold":true,
                  "filters":[Effects.STROKE]
               });
               addChild(this.txt_cost);
            }
            if(this._active)
            {
               this.txt_cost.text = Language.getInstance().getString("alliance.overview_boosts_active");
               this.txt_cost.textColor = 16765008;
               this.txt_cost.x = int((this._width - this.txt_cost.width) * 0.5);
               if(this.bmp_token != null)
               {
                  this.bmp_token.visible = false;
               }
            }
            else
            {
               if(this.bmp_token == null)
               {
                  this.bmp_token = new Bitmap(new BmpIconAllianceTokensSmall());
                  addChild(this.bmp_token);
               }
               this.txt_cost.text = NumberFormatter.format(this.cost,0);
               this.txt_cost.textColor = 16777215;
               _loc2_ = -1;
               _loc3_ = int(this.txt_cost.width + this.bmp_token.width + _loc2_);
               this.txt_cost.x = int((this._width - _loc3_) * 0.5 + 4);
               this.bmp_token.visible = true;
               this.bmp_token.x = int(this.txt_cost.x + this.txt_cost.width + _loc2_);
               this.bmp_token.y = int(_loc1_ + (this._costHeight - this.bmp_token.height) * 0.5);
            }
            this.txt_cost.y = int(_loc1_ + (this._costHeight - this.txt_cost.height) * 0.5);
         }
      }
      
      private function updateBorderFilters() : void
      {
         this.mc_border.filters = [this._borderGlow,this._strokeGlow];
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this._active)
         {
            return;
         }
         TweenMax.to(this._borderGlow,0,{
            "hexColors":{"color":8553090},
            "onUpdate":this.updateBorderFilters,
            "overwrite":true
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this._active)
         {
            return;
         }
         TweenMax.to(this._borderGlow,0.25,{
            "hexColors":{"color":5460819},
            "onUpdate":this.updateBorderFilters,
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
      }
   }
}

