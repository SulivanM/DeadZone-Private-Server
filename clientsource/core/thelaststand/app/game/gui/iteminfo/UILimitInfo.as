package thelaststand.app.game.gui.iteminfo
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UILimitInfo extends UIComponent
   {
      
      private var _height:int = 20;
      
      private var _width:int = 0;
      
      private var _langId:String;
      
      private var _label:String;
      
      private var _limitData:*;
      
      private var _timer:Timer;
      
      private var txt_label:BodyTextField;
      
      public function UILimitInfo(param1:String, param2:* = null)
      {
         super();
         this._langId = param1;
         this._timer = new Timer(500);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
         this.limitData = param2;
         this.txt_label = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_label.maxWidth = this._width;
         addChild(this.txt_label);
      }
      
      public function get languageId() : String
      {
         return this._langId;
      }
      
      public function set languageId(param1:String) : void
      {
         this._langId = param1;
         if(stage != null)
         {
            this.updateLabel();
         }
      }
      
      public function get limitData() : *
      {
         return this._limitData;
      }
      
      public function set limitData(param1:*) : void
      {
         this._limitData = param1;
         if(stage != null)
         {
            this.updateLabel();
         }
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
         this.txt_label.dispose();
         this._timer.stop();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         graphics.beginFill(3342336);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         this.updateLabel();
      }
      
      private function updateLabel() : void
      {
         var _loc1_:Date = null;
         var _loc2_:int = 0;
         if(this._limitData is Date)
         {
            _loc1_ = this._limitData as Date;
            _loc2_ = int((_loc1_.time - Network.getInstance().serverTime) / 1000);
            this._label = Language.getInstance().getString(this._langId,DateTimeUtils.secondsToString(_loc2_,true,true));
            if(!this._timer.running)
            {
               this._timer.reset();
               this._timer.start();
            }
         }
         else if(this._limitData is int)
         {
            this._label = Language.getInstance().getString(this._langId,NumberFormatter.format(this._limitData,0));
            this._timer.stop();
         }
         this.txt_label.text = this._label;
         this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
         this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this.updateLabel();
      }
   }
}

