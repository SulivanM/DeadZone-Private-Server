package thelaststand.app.gui
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   
   public class UIInsetPanelGroup extends Sprite
   {
      
      private var BMP_GRIME:BitmapData = new BmpDialogueBackground();
      
      private var SECTION_SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,10,10,1,1,true);
      
      private var _padding:int = 1;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _ty:int;
      
      private var _panels:Vector.<Shape>;
      
      private var mc_grime:Shape;
      
      public function UIInsetPanelGroup(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         graphics.beginFill(7829367);
         graphics.drawRect(0,0,param1,param2);
         graphics.endFill();
         this.mc_grime = new Shape();
         this.mc_grime.alpha = 0.15;
         this.mc_grime.cacheAsBitmap = true;
         addChild(this.mc_grime);
         this._panels = new Vector.<Shape>();
         this._ty = this._padding;
      }
      
      public function dispose() : void
      {
         var _loc1_:Shape = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this._panels)
         {
            _loc1_.filters = [];
         }
         this._panels = null;
         this.mc_grime.graphics.clear();
         graphics.clear();
         filters = [];
         this.SECTION_SHADOW = null;
         this.BMP_GRIME.dispose();
         this.BMP_GRIME = null;
      }
      
      public function addPanel(param1:int, param2:int = 0) : void
      {
         var _loc4_:Shape = null;
         var _loc3_:int = param1 - this._padding * 2;
         graphics.beginFill(2827043);
         graphics.drawRect(this._padding,this._ty,this._width - this._padding * 2,_loc3_);
         graphics.endFill();
         this.mc_grime.graphics.beginBitmapFill(this.BMP_GRIME);
         this.mc_grime.graphics.drawRect(this._padding,this._ty,this._width - this._padding * 2,_loc3_);
         this.mc_grime.graphics.endFill();
         this._ty += _loc3_ + this._padding;
         if(param2 > 0)
         {
            _loc4_ = new Shape();
            _loc4_.x = this._padding;
            _loc4_.y = this._ty;
            _loc4_.graphics.beginFill(2434341);
            _loc4_.graphics.drawRect(0,0,this._width - this._padding * 2,param2);
            _loc4_.graphics.endFill();
            _loc4_.filters = [this.SECTION_SHADOW];
            addChild(_loc4_);
            this._panels.push(_loc4_);
            this._ty += param2 + this._padding;
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

