package thelaststand.app.game.gui.injury
{
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.Shape;
   import flash.geom.Matrix;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.utils.GraphicUtils;
   
   public class UIInjuryHealthBar extends UIComponent
   {
      
      private var _maxHealth:Number = 1;
      
      private var _injuryDamage:Number = 0;
      
      private var _highlightDamage:Number = 0;
      
      private var _fillMatrix:Matrix = new Matrix();
      
      private var _width:int = 245;
      
      private var _height:int = 26;
      
      private var mc_bar:Shape;
      
      private var mc_grime:Shape;
      
      private var bmd_grime:BitmapData;
      
      public function UIInjuryHealthBar()
      {
         super();
         this.mc_bar = new Shape();
         this.mc_bar.x = this.mc_bar.y = 3;
         addChild(this.mc_bar);
         this.mc_grime = new Shape();
         this.mc_grime.x = this.mc_bar.x;
         this.mc_grime.y = this.mc_bar.y;
         this.mc_grime.alpha = 0.2;
         addChild(this.mc_grime);
         this.bmd_grime = new BmpXPBarGrime();
      }
      
      public function get maxHealth() : Number
      {
         return this._maxHealth;
      }
      
      public function set maxHealth(param1:Number) : void
      {
         if(param1 == this._maxHealth)
         {
            return;
         }
         this._maxHealth = param1;
         invalidate();
      }
      
      public function get injuryDamage() : Number
      {
         return this._injuryDamage;
      }
      
      public function set injuryDamage(param1:Number) : void
      {
         if(param1 == this._injuryDamage)
         {
            return;
         }
         this._injuryDamage = param1;
         invalidate();
      }
      
      public function get highlightDamage() : Number
      {
         return this._highlightDamage;
      }
      
      public function set highlightDamage(param1:Number) : void
      {
         if(param1 == this._highlightDamage)
         {
            return;
         }
         this._highlightDamage = param1;
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
         this.bmd_grime.dispose();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height,0,0,0,4473667);
         var _loc1_:int = int(this._width - this.mc_bar.y * 2);
         var _loc2_:int = int(this._height - this.mc_bar.y * 2);
         var _loc3_:Number = (this._maxHealth - this._injuryDamage) / this._maxHealth * _loc1_;
         var _loc4_:Number = this._injuryDamage / this._maxHealth * _loc1_;
         var _loc5_:Number = Math.min(this._highlightDamage,this._injuryDamage) / this._maxHealth * _loc1_;
         var _loc6_:Number = 0;
         this._fillMatrix.createGradientBox(this._width,this._height,Math.PI * 0.5);
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginGradientFill(GradientType.LINEAR,[8369681,5665803],[1,1],[0,255],this._fillMatrix);
         this.mc_bar.graphics.drawRect(0,0,_loc3_,_loc2_);
         this.mc_bar.graphics.endFill();
         this.mc_bar.graphics.beginGradientFill(GradientType.LINEAR,[9052446,5641489],[1,1],[0,255],this._fillMatrix);
         this.mc_bar.graphics.drawRect(_loc3_,0,_loc4_,_loc2_);
         this.mc_bar.graphics.endFill();
         this.mc_bar.graphics.beginGradientFill(GradientType.LINEAR,[15466496,10420224],[1,1],[0,255],this._fillMatrix);
         this.mc_bar.graphics.drawRect(_loc3_,0,_loc5_,_loc2_);
         this.mc_bar.graphics.endFill();
         this.mc_grime.graphics.clear();
         this.mc_grime.graphics.beginBitmapFill(this.bmd_grime);
         this.mc_grime.graphics.drawRect(0,0,_loc1_,_loc2_);
         this.mc_grime.graphics.endFill();
      }
   }
}

