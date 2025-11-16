package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.utils.DateTimeUtils;
   
   public class UIUnavailableBanner extends UIComponent
   {
      
      private const PADDING:int = 6;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _updateTimer:Timer;
      
      private var _timer:TimerData;
      
      private var _title:String;
      
      private var _message:String;
      
      private var _bottomPadding:int = 0;
      
      private var _titleColor:uint = 12735543;
      
      private var mc_background:Shape;
      
      private var bmp_time:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var txt_message:BodyTextField;
      
      public function UIUnavailableBanner(param1:uint = 12735543)
      {
         super();
         this._titleColor = param1;
         this.mc_background = new Shape();
         addChild(this.mc_background);
         this.txt_title = new BodyTextField({
            "color":this._titleColor,
            "size":23,
            "bold":true
         });
         addChild(this.txt_title);
         this.txt_message = new BodyTextField({
            "color":12434877,
            "size":14
         });
         addChild(this.txt_message);
         this._updateTimer = new Timer(500);
         this._updateTimer.addEventListener(TimerEvent.TIMER,this.updateTime,false,0,true);
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         invalidate();
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function set message(param1:String) : void
      {
         this._message = param1;
         invalidate();
      }
      
      public function get timer() : TimerData
      {
         return this._timer;
      }
      
      public function set timer(param1:TimerData) : void
      {
         this._timer = param1;
         invalidate();
         this._updateTimer.reset();
         if(this._timer == null)
         {
            this._updateTimer.stop();
         }
         else
         {
            this._updateTimer.start();
         }
      }
      
      public function get bottomPadding() : int
      {
         return this._bottomPadding;
      }
      
      public function set bottomPadding(param1:int) : void
      {
         this._bottomPadding = param1;
         invalidate();
      }
      
      public function get titleColor() : uint
      {
         return this._titleColor;
      }
      
      public function set titleColor(param1:uint) : void
      {
         this._titleColor = param1;
         this.txt_title.textColor = this._titleColor;
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
         this.txt_message.dispose();
         this.txt_title.dispose();
         if(this.txt_time != null)
         {
            this.txt_time.dispose();
         }
         if(this.bmp_time != null)
         {
            this.bmp_time.bitmapData.dispose();
         }
         this._updateTimer.stop();
      }
      
      override protected function draw() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Matrix = new Matrix();
         _loc1_.createGradientBox(this._width,this._height);
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginGradientFill("linear",[0,0,0,0],[0,1,1,0],[0,38,216,255],_loc1_);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.txt_title.htmlText = this._title;
         this.txt_title.maxWidth = int(this._width - 20);
         this.txt_title.x = int((this._width - this.txt_title.width) * 0.5);
         this.txt_title.y = this.PADDING;
         this.txt_message.htmlText = this._message;
         this.txt_message.maxWidth = int(this._width - 20);
         this.txt_message.x = int((this._width - this.txt_message.width) * 0.5);
         if(this._timer != null)
         {
            if(this.bmp_time == null)
            {
               this.bmp_time = new Bitmap(new BmpIconSearchTimer());
            }
            this.bmp_time.y = int((this._height - this.bmp_time.height) * 0.5) + 4;
            addChild(this.bmp_time);
            if(this.txt_time == null)
            {
               this.txt_time = new BodyTextField({
                  "text":" ",
                  "color":16777215,
                  "size":28,
                  "bold":true
               });
            }
            this.txt_time.y = int((this._height - this.txt_time.height) * 0.5) + 4;
            addChild(this.txt_time);
            this.txt_message.y = int(this._height - this.txt_message.height - (this.PADDING + 4));
            this.updateTime();
         }
         else
         {
            if(this.txt_time != null && this.txt_time.parent != null)
            {
               this.txt_time.parent.removeChild(this.txt_time);
            }
            if(this.bmp_time != null && this.bmp_time.parent != null)
            {
               this.bmp_time.parent.removeChild(this.bmp_time);
            }
            _loc2_ = int(this.txt_title.y + this.txt_title.height);
            this.txt_message.y = int(_loc2_ + (this._height - _loc2_ - this.PADDING - this.txt_message.height) * 0.5) - 4 - this._bottomPadding;
         }
      }
      
      private function updateTime(param1:TimerEvent = null) : void
      {
         this.txt_time.text = DateTimeUtils.secondsToString(this._timer.getSecondsRemaining(),true,true);
         var _loc2_:int = 8;
         var _loc3_:int = this.bmp_time.width + this.txt_time.width + _loc2_;
         this.bmp_time.x = int((this._width - _loc3_) * 0.5);
         this.txt_time.x = int(this.bmp_time.x + this.bmp_time.width + _loc2_);
      }
   }
}

