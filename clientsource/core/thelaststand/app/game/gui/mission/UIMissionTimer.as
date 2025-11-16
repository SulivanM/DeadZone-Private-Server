package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UIMissionTimer extends Sprite
   {
      
      private var _time:Number = -1;
      
      private var _spacing:int = 2;
      
      private var _warningTime:int = 60;
      
      private var _showWarning:Boolean = true;
      
      private var _warningVisible:Boolean = false;
      
      private var _warningSoundEnabled:Boolean = true;
      
      private var txt_time:BodyTextField;
      
      private var txt_warning:BodyTextField;
      
      private var bmp_icon:Bitmap;
      
      private var _timeUpMessage:String;
      
      private var _warningMessage:String;
      
      private var _defaultMessage:String;
      
      public function UIMissionTimer()
      {
         super();
         this.bmp_icon = new Bitmap(new BmpIconSearchTimer());
         this.bmp_icon.transform.colorTransform = new ColorTransform(0.5,0.5,0.5);
         addChild(this.bmp_icon);
         this.txt_time = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_time.y = int(this.bmp_icon.y + (this.bmp_icon.height - this.txt_time.height) * 0.5);
         addChild(this.txt_time);
         this.txt_warning = new BodyTextField({
            "text":" ",
            "color":Effects.COLOR_WARNING,
            "size":15,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_warning.y = int(this.txt_time.y + this.txt_time.height + 4);
         this._timeUpMessage = Language.getInstance().getString("mission_time_expired");
         this._warningMessage = Language.getInstance().getString("mission_time_warning");
         this._defaultMessage = "";
         this.time = 0;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
         this.txt_time.dispose();
         this.txt_time = null;
         this.killWarning();
         this.txt_warning.dispose();
         this.txt_warning = null;
      }
      
      private function pulseWarningMessage() : void
      {
         if(this._warningVisible)
         {
            return;
         }
         this._warningVisible = true;
         this.txt_warning.alpha = 0;
         this.txt_warning.text = this._warningMessage;
         TweenMax.to(this.txt_warning,1,{
            "alpha":1,
            "ease":Linear.easeNone,
            "yoyo":true,
            "repeat":-1,
            "overwrite":true
         });
         addChild(this.txt_warning);
      }
      
      private function killWarning() : void
      {
         this._warningVisible = false;
         TweenMax.killTweensOf(this.txt_warning);
         if(this.txt_warning.parent != null)
         {
            this.txt_warning.parent.removeChild(this.txt_warning);
         }
      }
      
      private function playWarningSound() : void
      {
         if(!this._warningSoundEnabled)
         {
            return;
         }
         var _loc1_:String = "sound/interface/heart-beat.mp3";
         if(!Audio.sound.isPlaying(_loc1_))
         {
            Audio.sound.play(_loc1_);
         }
      }
      
      public function get timeUpMessage() : String
      {
         return this._timeUpMessage;
      }
      
      public function set timeUpMessage(param1:String) : void
      {
         this._timeUpMessage = param1;
         var _loc2_:Number = this._time;
         this._time = -1;
         this.time = _loc2_;
      }
      
      public function get warningMessage() : String
      {
         return this._warningMessage;
      }
      
      public function set warningMessage(param1:String) : void
      {
         this._warningMessage = param1;
         this._warningVisible = false;
         var _loc2_:Number = this._time;
         this._time = -1;
         this.time = _loc2_;
      }
      
      public function get defaultMessage() : String
      {
         return this._defaultMessage;
      }
      
      public function set defaultMessage(param1:String) : void
      {
         this._defaultMessage = param1;
         var _loc2_:Number = this._time;
         this._time = -1;
         this.time = _loc2_;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function set time(param1:Number) : void
      {
         if(param1 == this._time)
         {
            return;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._time = param1;
         this.txt_time.text = DateTimeUtils.secondsToString(this._time,true,true);
         if(this._time <= 0)
         {
            this.killWarning();
            this.playWarningSound();
            TweenMax.killTweensOf(this.txt_warning);
            this.txt_time.textColor = Effects.COLOR_WARNING;
            this.txt_warning.text = this._timeUpMessage;
            this.txt_warning.alpha = 1;
            addChild(this.txt_warning);
         }
         else if(this._time <= this._warningTime)
         {
            if(this._showWarning)
            {
               this.txt_time.textColor = Effects.COLOR_WARNING;
               this.txt_warning.textColor = Effects.COLOR_WARNING;
               this.txt_warning.text = this._warningMessage;
               this.pulseWarningMessage();
               this.playWarningSound();
            }
            else
            {
               this.killWarning();
               this.txt_time.textColor = 16777215;
            }
         }
         else
         {
            this.killWarning();
            this.txt_time.textColor = 16777215;
            if(this._defaultMessage != "")
            {
               this.txt_warning.textColor = 16777215;
               addChild(this.txt_warning);
               this.txt_warning.text = this._defaultMessage;
            }
         }
         var _loc2_:int = this.bmp_icon.width + this.txt_time.width + this._spacing;
         this.bmp_icon.x = -int(_loc2_ * 0.5);
         this.txt_time.x = int(this.bmp_icon.x + this.bmp_icon.width + this._spacing);
         this.txt_warning.x = -int(this.txt_warning.width * 0.5);
      }
      
      public function get showWarning() : Boolean
      {
         return this._showWarning;
      }
      
      public function set showWarning(param1:Boolean) : void
      {
         this._showWarning = param1;
      }
      
      public function get warningVisible() : Boolean
      {
         return this._time <= this._warningTime;
      }
      
      public function get warningSoundEnabled() : Boolean
      {
         return this._warningSoundEnabled;
      }
      
      public function set warningSoundEnabled(param1:Boolean) : void
      {
         this._warningSoundEnabled = param1;
      }
   }
}

