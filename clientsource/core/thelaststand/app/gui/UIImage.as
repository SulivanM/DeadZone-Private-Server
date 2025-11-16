package thelaststand.app.gui
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.system.LoaderContext;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIImage extends Sprite
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _uri:String;
      
      private var _isPNG:Boolean;
      
      private var _context:LoaderContext;
      
      private var _bgColor:uint;
      
      private var _bgAlpha:Number;
      
      protected var mc_background:Sprite;
      
      protected var mc_busy:UIBusySpinner;
      
      protected var bmp_image:Bitmap;
      
      public var maintainAspectRatio:Boolean = true;
      
      public var imageDisplayed:Signal;
      
      public function UIImage(param1:int, param2:int, param3:uint = 0, param4:Number = 1, param5:Boolean = true, param6:String = null)
      {
         super();
         this._width = param1;
         this._height = param2;
         this._bgColor = param3;
         this._bgAlpha = param4;
         mouseChildren = false;
         this.imageDisplayed = new Signal(UIImage);
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(param3,param4);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.bmp_image = new Bitmap();
         addChild(this.bmp_image);
         if(param5)
         {
            this.mc_busy = new UIBusySpinner();
         }
         if(param6 != null)
         {
            this.uri = param6;
         }
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killTweensOf(this);
         ResourceManager.getInstance().resourceLoadCompleted.remove(this.onResourceLoadCompleted);
         this._context = null;
         this.imageDisplayed.removeAll();
         if(this.bmp_image != null)
         {
            this.bmp_image.filters = [];
            this.bmp_image.bitmapData = null;
            this.bmp_image = null;
         }
         if(this.mc_busy != null)
         {
            this.mc_busy.dispose();
         }
         this.mc_busy = null;
         this.mc_background.filters = [];
         filters = [];
      }
      
      public function getURIViaFunction(param1:Function) : void
      {
         var self:UIImage = null;
         var func:Function = param1;
         if(this.mc_busy != null)
         {
            addChild(this.mc_busy);
            this.mc_busy.x = int(this.mc_background.x + this._width * 0.5);
            this.mc_busy.y = int(this.mc_background.y + this._height * 0.5);
         }
         self = this;
         func(function(param1:String):void
         {
            self.uri = param1;
         });
      }
      
      public function prioritize(param1:Number = NaN) : void
      {
         if(this._uri == null)
         {
            return;
         }
         var _loc2_:ResourceManager = ResourceManager.getInstance();
         if(_loc2_.isInQueue(this._uri))
         {
            _loc2_.prioritize(this._uri,param1);
         }
      }
      
      public function getBitmap() : Bitmap
      {
         return this.bmp_image;
      }
      
      private function resizeImage() : void
      {
         if(this.bmp_image.bitmapData == null)
         {
            return;
         }
         this.bmp_image.scaleX = this.bmp_image.scaleY = 1;
         if(this.maintainAspectRatio)
         {
            if(this.bmp_image.width >= this.bmp_image.height)
            {
               this.bmp_image.width = this._width;
               this.bmp_image.scaleY = this.bmp_image.scaleX;
            }
            else
            {
               this.bmp_image.height = this._height;
               this.bmp_image.scaleX = this.bmp_image.scaleY;
            }
         }
         else
         {
            this.bmp_image.width = this._width;
            this.bmp_image.height = this._height;
         }
      }
      
      private function displayImage(param1:BitmapData) : void
      {
         this.bmp_image.bitmapData = param1;
         this.bmp_image.pixelSnapping = "auto";
         this.bmp_image.smoothing = true;
         this.resizeImage();
         this.bmp_image.x = int(this.mc_background.x + (this._width - this.bmp_image.width) * 0.5);
         this.bmp_image.y = int(this.mc_background.y + (this._height - this.bmp_image.height) * 0.5);
         this.bmp_image.alpha = 1;
         if(this.mc_busy != null && this.mc_busy.parent != null)
         {
            this.mc_busy.parent.removeChild(this.mc_busy);
         }
         this.imageDisplayed.dispatch(this);
      }
      
      private function onResourceLoadCompleted(param1:Resource) : void
      {
         if(this._uri == null || param1.uri == null)
         {
            return;
         }
         if(param1.uri.toLowerCase() == this._uri.toLowerCase())
         {
            ResourceManager.getInstance().resourceLoadCompleted.remove(this.onResourceLoadCompleted);
            this.displayImage(param1.content as BitmapData);
         }
      }
      
      private function update() : void
      {
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(this._bgColor,this._bgAlpha);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.resizeImage();
         this.bmp_image.x = int(this.mc_background.x + (this._width - this.bmp_image.width) * 0.5);
         this.bmp_image.y = int(this.mc_background.y + (this._height - this.bmp_image.height) * 0.5);
         if(this.mc_busy != null)
         {
            this.mc_busy.x = int(this.mc_background.x + this._width * 0.5);
            this.mc_busy.y = int(this.mc_background.y + this._height * 0.5);
         }
      }
      
      public function get context() : LoaderContext
      {
         return this._context;
      }
      
      public function set context(param1:LoaderContext) : void
      {
         this._context = param1;
      }
      
      public function get bitmap() : Bitmap
      {
         return this.bmp_image;
      }
      
      public function get isPNG() : Boolean
      {
         return this._isPNG;
      }
      
      public function get uri() : String
      {
         return this._uri;
      }
      
      public function set uri(param1:String) : void
      {
         var _loc2_:ResourceManager = ResourceManager.getInstance();
         this._uri = param1;
         this._isPNG = this._uri != null ? this._uri.indexOf(".png") > -1 : Boolean(null);
         this.bmp_image.scaleX = this.bmp_image.scaleY = 1;
         this.bmp_image.bitmapData = null;
         if(this._uri == null)
         {
            _loc2_.resourceLoadCompleted.remove(this.onResourceLoadCompleted);
            if(this.mc_busy != null && this.mc_busy.parent != null)
            {
               this.mc_busy.parent.removeChild(this.mc_busy);
            }
            return;
         }
         if(!_loc2_.exists(this._uri))
         {
            if(this.mc_busy != null)
            {
               addChild(this.mc_busy);
               this.mc_busy.x = int(this.mc_background.x + this._width * 0.5);
               this.mc_busy.y = int(this.mc_background.y + this._height * 0.5);
            }
            _loc2_.resourceLoadCompleted.add(this.onResourceLoadCompleted);
            _loc2_.load(this._uri,{
               "type":ResourceManager.TYPE_IMAGE,
               "context":this._context
            });
         }
         else if(_loc2_.isInQueue(this._uri))
         {
            _loc2_.resourceLoadCompleted.add(this.onResourceLoadCompleted);
            if(this.mc_busy != null)
            {
               addChild(this.mc_busy);
               this.mc_busy.x = int(this.mc_background.x + this._width * 0.5);
               this.mc_busy.y = int(this.mc_background.y + this._height * 0.5);
            }
         }
         else
         {
            this.displayImage(_loc2_.getResource(this._uri).content as BitmapData);
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.update();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this.update();
      }
   }
}

