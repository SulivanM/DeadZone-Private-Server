package thelaststand.app.display
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.Version;
   import thelaststand.app.core.SharedResources;
   import thelaststand.app.gui.UIBusySpinner;
   
   public class LoadingScreen extends Sprite
   {
      
      private var _hasTransitionedIn:Boolean = false;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _typer:TextFieldTyper;
      
      private var _details:String;
      
      private var _message:String;
      
      private var _textHeight:int;
      
      private var bmp_background:Bitmap;
      
      private var bmp_logo:Bitmap;
      
      private var mc_spinner:UIBusySpinner;
      
      private var txt_message:TitleTextField;
      
      private var txt_version:BodyTextField;
      
      private var txt_details:BodyTextField;
      
      private var ui_timeline:TimelineDisplay;
      
      private var mc_noise:NoiseOverlay;
      
      public var transitionedIn:Signal;
      
      public var transitionedOut:Signal;
      
      public function LoadingScreen(param1:BitmapData = null, param2:Boolean = false)
      {
         super();
         this.bmp_background = new Bitmap(param1 != null ? param1 : new BmpFullBackground());
         addChild(this.bmp_background);
         if(param2)
         {
            this.bmp_logo = new Bitmap(SharedResources.logoBitmapInstance);
            addChild(this.bmp_logo);
         }
         this.mc_noise = new NoiseOverlay(this.bmp_background.width,this.bmp_background.height,8,16);
         this.mc_noise.x = this.bmp_background.x;
         this.mc_noise.y = this.bmp_background.y;
         this.mc_noise.blendMode = "multiply";
         this.mc_noise.alpha = 0.2;
         addChild(this.mc_noise);
         this.mc_spinner = new UIBusySpinner(1);
         this.mc_spinner.width = 20;
         this.mc_spinner.scaleY = this.mc_spinner.scaleX;
         this.txt_message = new TitleTextField({
            "text":" ",
            "color":16777215,
            "size":22,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "align":"right",
            "autoSize":"right"
         });
         this._textHeight = this.txt_message.height;
         this.txt_details = new BodyTextField({
            "text":" ",
            "color":6710886,
            "size":13,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "align":"right",
            "autoSize":"right"
         });
         addChild(this.txt_details);
         this.txt_version = new BodyTextField({
            "text":Version.VERSION,
            "color":6710886,
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_version.visible = false;
         addChild(this.txt_version);
         this._typer = new TextFieldTyper(this.txt_message);
         this.transitionedIn = new Signal();
         this.transitionedOut = new Signal();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this.bmp_background.parent != null)
         {
            this.bmp_background.parent.removeChild(this.bmp_background);
         }
         this.bmp_background.bitmapData.dispose();
         this.bmp_background.bitmapData = null;
         this.bmp_background = null;
         if(this.bmp_logo != null)
         {
            this.bmp_logo.bitmapData.dispose();
            this.bmp_logo.bitmapData = null;
            this.bmp_logo = null;
         }
         this.mc_spinner.dispose();
         this.mc_spinner = null;
         this.txt_message.dispose();
         this.txt_message = null;
         this.txt_details.dispose();
         this.txt_details = null;
         this._typer.dispose();
         this._typer = null;
      }
      
      public function updateFont() : void
      {
         this.txt_message.setProperties({
            "font":"AlternateGothic",
            "embedFonts":true
         });
         this.txt_details.setProperties({
            "font":"HelveticaNeueCond",
            "embedFonts":true
         });
         this.txt_version.setProperties({
            "font":"HelveticaNeueCond",
            "embedFonts":true
         });
         this.txt_version.visible = true;
      }
      
      public function transitionIn(param1:Number = 0, param2:Boolean = false) : void
      {
         if(this._hasTransitionedIn)
         {
            this.onTransitionInComplete();
            return;
         }
         this._hasTransitionedIn = true;
         this.bmp_background.alpha = 0;
         this.mc_spinner.alpha = 0;
         this.txt_message.text = " ";
         this.txt_details.text = " ";
         this.setSize(this._width,this._height);
         if(param2)
         {
            if(this.ui_timeline == null)
            {
               this.ui_timeline = new TimelineDisplay();
            }
         }
         else if(this.ui_timeline != null)
         {
            this.ui_timeline.dispose();
            this.ui_timeline = null;
         }
         TweenMax.to(this.bmp_background,0.5,{
            "alpha":1,
            "overwrite":true,
            "onComplete":this.onTransitionInComplete
         });
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         var delay:Number = param1;
         this._hasTransitionedIn = false;
         this.txt_version.visible = false;
         TweenMax.to(this.mc_spinner,0.5,{"alpha":0});
         TweenMax.to(this.txt_message,0.5,{"alpha":0});
         TweenMax.to(this.txt_details,0.5,{"alpha":0});
         TweenMax.to(this.bmp_background,0.5,{
            "alpha":0,
            "overwrite":true,
            "onComplete":function():void
            {
               transitionedOut.dispatch();
               dispose();
            }
         });
         if(this.ui_timeline != null)
         {
            this.ui_timeline.stop();
            TweenMax.to(this.ui_timeline,0.25,{
               "alpha":0,
               "onComplete":function():void
               {
                  ui_timeline.dispose();
                  ui_timeline = null;
               }
            });
         }
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         this.bmp_background.x = int((this._width - this.bmp_background.width) * 0.5);
         this.bmp_background.y = int((this._height - this.bmp_background.height) * 0.5);
         if(this.bmp_logo != null)
         {
            this.bmp_logo.x = this.bmp_background.x;
            this.bmp_logo.y = this.bmp_background.y;
         }
         this.mc_spinner.x = int(Math.min(this._width,int(this.bmp_background.x + this.bmp_background.width)) - 25);
         this.mc_spinner.y = int(Math.min(this._height,int(this.bmp_background.y + this.bmp_background.height)) - 60);
         this.txt_message.x = int(this.mc_spinner.x - 22 - this.txt_message.width);
         this.txt_message.y = int(this.mc_spinner.y - this._textHeight * 0.5 + 2);
         this.txt_details.x = int(this.mc_spinner.x - 18 - this.txt_details.width);
         this.txt_details.y = int(this.txt_message.y + this.txt_message.height - 4);
         this.txt_version.x = Math.max(10,int(this.bmp_background.x + 10));
         this.txt_version.y = int(this.txt_message.y + this.txt_message.height - this.txt_version.height);
         this.mc_noise.x = this.bmp_background.x;
         this.mc_noise.y = this.bmp_background.y;
         if(this.ui_timeline != null)
         {
            this.ui_timeline.setSize(this.bmp_background.width,this.bmp_background.height);
            this.ui_timeline.x = this.bmp_background.x;
            this.ui_timeline.y = this.bmp_background.y;
         }
      }
      
      private function onTransitionInComplete() : void
      {
         addChild(this.mc_spinner);
         addChild(this.txt_message);
         this.txt_version.visible = true;
         TweenMax.to(this.mc_spinner,0.5,{"alpha":1});
         this._typer.type(this._message.toUpperCase(),60);
         this.setSize(this._width,this._height);
         if(this.ui_timeline != null)
         {
            this.ui_timeline.start();
            addChildAt(this.ui_timeline,getChildIndex(this.bmp_background) + 1);
            TweenMax.from(this.ui_timeline,0.5,{"alpha":0});
         }
         this.transitionedIn.dispatch();
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function set message(param1:String) : void
      {
         this._message = param1;
         if(stage != null)
         {
            if(this.mc_spinner.alpha < 1)
            {
               this.mc_spinner.alpha = 1;
            }
            addChild(this.mc_spinner);
            this.txt_message.text = " ";
            this.txt_message.x = int(this.mc_spinner.x - 22);
            this.txt_version.y = int(this.txt_message.y + this.txt_message.height - this.txt_version.height);
            this._typer.type(this._message.toUpperCase(),60);
            addChild(this.txt_message);
         }
      }
      
      public function get details() : String
      {
         return this._details;
      }
      
      public function set details(param1:String) : void
      {
         this._details = param1;
         this.txt_details.text = this._details;
         this.txt_details.y = int(this.txt_message.y + this.txt_message.height - 4);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this._height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this._width,param1);
      }
   }
}

