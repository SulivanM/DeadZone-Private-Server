package thelaststand.app.game.gui.alliance.banner
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import flash.utils.ByteArray;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceBannerData;
   import thelaststand.app.utils.GraphicUtils;
   
   public class AllianceBannerPanelAbstract extends Sprite
   {
      
      protected var _bg:Bitmap;
      
      protected var _bannerDisplay:AllianceBannerDisplay;
      
      protected var _ready:Boolean = false;
      
      protected var _width:Number = 232;
      
      protected var _height:Number = 404;
      
      protected var bmp_titleBar:Bitmap;
      
      protected var txt_label:BodyTextField;
      
      public var onReady:Signal = new Signal();
      
      public function AllianceBannerPanelAbstract(param1:AllianceBannerData, param2:Number = 404)
      {
         super();
         this._height = param2;
         this.onReady = new Signal();
         GraphicUtils.drawUIBlock(this.graphics,this._width,this._height);
         this._bannerDisplay = new AllianceBannerDisplay();
         this._bannerDisplay.x = int((this._width - 184) * 0.5);
         this._bannerDisplay.y = 28;
         addChild(this._bannerDisplay);
         if(param1)
         {
            this._bannerDisplay.byteArray = param1.byteArray;
         }
         this.bmp_titleBar = new Bitmap(new BmpTopBarBackground(),"always",true);
         this.bmp_titleBar.x = this.bmp_titleBar.y = 4;
         this.bmp_titleBar.width = this._width - this.bmp_titleBar.x * 2;
         this.bmp_titleBar.height = 32;
         addChild(this.bmp_titleBar);
         this.bmp_titleBar.filters = [Effects.STROKE];
         this.txt_label = new BodyTextField({
            "text":"",
            "color":11579568,
            "size":18,
            "bold":true,
            "align":TextFormatAlign.CENTER,
            "autoSize":TextFieldAutoSize.CENTER,
            "filters":[Effects.STROKE]
         });
         this.txt_label.maxWidth = this._width - 10;
         this.txt_label.y = 8;
         addChild(this.txt_label);
         if(this._bannerDisplay.ready)
         {
            this.onBannerReady();
         }
         else
         {
            this._bannerDisplay.onReady.addOnce(this.onBannerReady);
         }
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         if(this._bg)
         {
            this._bg.bitmapData.dispose();
         }
         this._bannerDisplay.dispose();
         this.txt_label.dispose();
         this.bmp_titleBar.bitmapData.dispose();
         this.onReady.removeAll();
      }
      
      protected function onBannerReady() : void
      {
         var _loc1_:Class = this._bannerDisplay.bannerResourceMC.loaderInfo.applicationDomain.getDefinition("BmpBGAllianceBannerBg") as Class;
         this._bg = new Bitmap(new _loc1_() as BitmapData,"auto",true);
         this._bg.x = this._bg.y = 1;
         this._bg.width = this._width - 2;
         this._bg.height = this._height - 2;
         addChildAt(this._bg,0);
         this._bg.alpha = 0;
         TweenMax.to(this._bg,0.25,{"alpha":1});
         this._ready = true;
         this.onReady.dispatch();
      }
      
      public function generateThumbnail() : BitmapData
      {
         return this._bannerDisplay.generateThumbnail();
      }
      
      public function generateBitmap() : BitmapData
      {
         return this._bannerDisplay.generateBitmap();
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
      
      public function get ready() : Boolean
      {
         return this._ready;
      }
      
      public function get bannerData() : AllianceBannerData
      {
         return this._bannerDisplay.bannerData;
      }
      
      public function get byteArray() : ByteArray
      {
         return this._bannerDisplay.byteArray;
      }
      
      public function set byteArray(param1:ByteArray) : void
      {
         this._bannerDisplay.byteArray = param1;
      }
      
      public function get hexString() : String
      {
         return this._bannerDisplay.hexString;
      }
      
      public function set hexString(param1:String) : void
      {
         this._bannerDisplay.hexString = param1;
      }
      
      public function get label() : String
      {
         return this.txt_label.text;
      }
      
      public function set label(param1:String) : void
      {
         this.txt_label.text = param1;
         this.txt_label.x = int((this.bmp_titleBar.width - this.txt_label.width) * 0.5);
      }
   }
}

