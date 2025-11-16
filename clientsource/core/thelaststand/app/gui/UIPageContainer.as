package thelaststand.app.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class UIPageContainer extends Sprite
   {
      
      protected var _strokeColor:int = 7763574;
      
      protected var _fillColor:int = 2434341;
      
      protected var _currentPage:int = 0;
      
      protected var _numPages:int;
      
      protected var _pageWidth:int;
      
      protected var _pageHeight:int;
      
      protected var _width:int = 200;
      
      protected var _height:int = 200;
      
      protected var _paddingX:int = 10;
      
      protected var _paddingY:int = 10;
      
      protected var mc_pageContainer:Sprite;
      
      private var mc_background:Shape;
      
      private var mc_containerMask:Shape;
      
      public function UIPageContainer()
      {
         super();
         this.mc_background = new Shape();
         addChild(this.mc_background);
         this.mc_pageContainer = new Sprite();
         addChild(this.mc_pageContainer);
         this.mc_containerMask = new Shape();
         addChild(this.mc_containerMask);
      }
      
      public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         TweenMax.killChildTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function gotoPage(param1:int, param2:Boolean = true) : void
      {
         var tx:int = 0;
         var page:int = param1;
         var animate:Boolean = param2;
         if(page >= this._numPages)
         {
            page = this._numPages - 1;
         }
         if(page < 0)
         {
            page = 0;
         }
         this._currentPage = page;
         tx = -this._currentPage * (this._pageWidth + this._paddingX * 2);
         if(animate && stage != null)
         {
            this.mc_pageContainer.cacheAsBitmap = true;
            this.mc_pageContainer.mouseChildren = false;
            TweenMax.to(this.mc_pageContainer,0.25,{
               "x":tx,
               "ease":Quad.easeInOut,
               "overwrite":true,
               "onComplete":function():void
               {
                  mc_pageContainer.x = tx;
                  mc_pageContainer.visible = true;
                  mc_pageContainer.mask = mc_containerMask;
                  mc_pageContainer.mouseChildren = true;
                  mc_pageContainer.cacheAsBitmap = false;
               }
            });
         }
         else
         {
            this.mc_pageContainer.x = tx;
            this.mc_pageContainer.visible = true;
            this.mc_pageContainer.mouseChildren = true;
            this.mc_pageContainer.cacheAsBitmap = false;
            this.mc_pageContainer.mask = this.mc_containerMask;
         }
      }
      
      protected function draw() : void
      {
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(this._strokeColor);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginFill(this._fillColor);
         this.mc_background.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         this.mc_background.graphics.endFill();
         TweenMax.killTweensOf(this.mc_pageContainer);
         this.mc_pageContainer.x = -this._currentPage * (this._pageWidth + this._paddingX * 2);
         this.mc_containerMask.graphics.clear();
         this.mc_containerMask.graphics.beginFill(16711680,0.25);
         this.mc_containerMask.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         this.mc_containerMask.graphics.endFill();
         this.mc_pageContainer.mask = this.mc_containerMask;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.draw();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this.draw();
      }
   }
}

