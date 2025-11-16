package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.gui.UIComponent;
   
   public class UISlider extends UIComponent
   {
      
      private var _width:int = 100;
      
      private var _height:int;
      
      private var _trackHeight:int = 6;
      
      private var _min:Number = 0;
      
      private var _max:Number = 1;
      
      private var _value:Number = 0;
      
      private var _dragging:Boolean;
      
      private var bmp_thumb:Bitmap;
      
      private var mc_thumb:Sprite;
      
      private var mc_track:Sprite;
      
      private var mc_hitArea:Sprite;
      
      public var valueChanged:Signal = new Signal();
      
      public function UISlider()
      {
         super();
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.mc_track = new Sprite();
         addChild(this.mc_track);
         this.mc_thumb = new Sprite();
         addChild(this.mc_thumb);
         this.bmp_thumb = new Bitmap(new BmpVolumeSliderThumb());
         this.bmp_thumb.filters = [new DropShadowFilter(2,45,0,1,6,6,0.75,2)];
         this.bmp_thumb.rotation = 90;
         this.bmp_thumb.y = -(this.bmp_thumb.height * 0.5);
         this.bmp_thumb.x = 8;
         this.mc_thumb.addChild(this.bmp_thumb);
         this._height = this.mc_thumb.height;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
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
      
      public function get min() : Number
      {
         return this._min;
      }
      
      public function set min(param1:Number) : void
      {
         if(param1 > this._max)
         {
            param1 = this._max;
         }
         this._min = param1;
         if(this._value < this._min)
         {
            this._value = this._min;
         }
         this.updateThumbPosition();
      }
      
      public function get max() : Number
      {
         return this._max;
      }
      
      public function set max(param1:Number) : void
      {
         if(param1 < this._min)
         {
            param1 = this._min;
         }
         this._max = param1;
         if(this._value > this._max)
         {
            this._value = this._max;
         }
         this.updateThumbPosition();
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 < this._min)
         {
            param1 = this._min;
         }
         if(param1 > this._max)
         {
            param1 = this._max;
         }
         if(param1 == this._value)
         {
            return;
         }
         this._value = param1;
         this.updateThumbPosition();
         this.valueChanged.dispatch();
      }
      
      override public function dispose() : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         super.dispose();
      }
      
      override protected function draw() : void
      {
         this.mc_hitArea.width = this._width;
         this.mc_hitArea.height = this._height;
         this.mc_track.x = 8;
         this.mc_track.graphics.clear();
         this.mc_track.graphics.beginFill(2434341);
         this.mc_track.graphics.lineStyle(1,7631988,1,true);
         this.mc_track.graphics.drawRect(0,0,int(this._width - this.mc_track.x * 2),this._trackHeight);
         this.mc_track.graphics.endFill();
         this.mc_track.y = int((this._height - this.mc_track.height) * 0.5);
         this.mc_thumb.y = int(this._height * 0.5);
         this.updateThumbPosition();
      }
      
      private function updateThumbPosition() : void
      {
         var _loc1_:Number = (this._value - this._min) / (this._max - this._min);
         this.mc_thumb.x = this.mc_track.x + int(this.mc_track.width * _loc1_);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(!this._dragging)
         {
            return;
         }
         var _loc2_:Number = this.mc_track.mouseX / this.mc_track.width;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         else if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         this._value = this._min + (this._max - this._min) * _loc2_;
         this.updateThumbPosition();
         this.valueChanged.dispatch();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this._dragging = true;
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._dragging = false;
      }
   }
}

