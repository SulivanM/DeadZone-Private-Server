package thelaststand.app.game.gui
{
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   
   public class UIScrollBar extends Sprite
   {
      
      private var _mouseDownY:int;
      
      private var _minValue:Number = 0;
      
      private var _maxValue:Number = 10;
      
      private var _contentHeight:Number = 0;
      
      private var _value:Number = 0;
      
      private var _width:int = 12;
      
      private var _height:int = 100;
      
      private var _scrollHeight:Number = -1;
      
      private var btn_up:ArrowButton;
      
      private var btn_down:ArrowButton;
      
      private var mc_track:Sprite;
      
      private var mc_thumb:Sprite;
      
      private var _stage:Stage;
      
      public var wheelArea:DisplayObject;
      
      public var changed:Signal;
      
      public function UIScrollBar()
      {
         super();
         this.btn_up = new ArrowButton(-1);
         this.btn_up.addEventListener(MouseEvent.MOUSE_DOWN,this.onClickArrow,false,0,true);
         addChild(this.btn_up);
         this.btn_down = new ArrowButton(1);
         this.btn_down.addEventListener(MouseEvent.MOUSE_DOWN,this.onClickArrow,false,0,true);
         addChild(this.btn_down);
         this.mc_track = new Sprite();
         this.mc_track.graphics.beginFill(0,0);
         this.mc_track.graphics.drawRect(0,0,this._width,this._height);
         this.mc_track.graphics.endFill();
         addChildAt(this.mc_track,0);
         this.mc_thumb = new Sprite();
         this.mc_thumb.x = int((this._width - this.mc_thumb.width) * 0.5);
         this.mc_thumb.y = int(this.btn_up.y + this.btn_up.height);
         addChild(this.mc_thumb);
         this.setHeight(this._height);
         this.changed = new Signal(Number);
         this.mc_thumb.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverThumb,false,0,true);
         this.mc_thumb.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutThumb,false,0,true);
         this.mc_thumb.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownThumb,false,0,true);
         this.mc_thumb.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpThumb,false,0,true);
         this.mc_track.addEventListener(MouseEvent.MOUSE_DOWN,this.onTrackMouseDown,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function destroy() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         if(this._stage)
         {
            this._stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         }
         this.changed.removeAll();
      }
      
      private function setHeight(param1:int) : void
      {
         this._height = param1;
         scaleX = scaleY = 1;
         this.btn_down.y = int(this._height - this.btn_down.height);
         this.mc_track.height = this._height;
         this.updateThumb();
      }
      
      private function updateThumb() : void
      {
         if(this._contentHeight <= this.calcHeight)
         {
            mouseEnabled = mouseChildren = false;
            this.mc_thumb.visible = false;
            return;
         }
         mouseEnabled = mouseChildren = true;
         this.mc_thumb.visible = true;
         var _loc1_:int = (this.btn_down.y - (this.btn_up.y + this.btn_up.height)) * (this.calcHeight / this._contentHeight);
         if(_loc1_ < 15)
         {
            _loc1_ = 15;
         }
         this.mc_thumb.graphics.clear();
         this.mc_thumb.graphics.beginFill(0,0);
         this.mc_thumb.graphics.drawRect(0,0,this._width,_loc1_);
         this.mc_thumb.graphics.endFill();
         this.mc_thumb.graphics.beginFill(7500402);
         this.mc_thumb.graphics.drawRect(2,0,8,_loc1_);
         this.mc_thumb.graphics.endFill();
         this.mc_thumb.x = int((this._width - this.mc_thumb.width) * 0.5);
         this.updateThumbPositionFromValue();
      }
      
      private function updateValueFromThumbPosition() : void
      {
         var _loc1_:int = this.btn_up.y + this.btn_up.height;
         var _loc2_:int = this.btn_down.y - this.mc_thumb.height;
         this._value = (this.mc_thumb.y - _loc1_) / (_loc2_ - _loc1_);
         if(this._value < 0)
         {
            this._value = 0;
         }
         else if(this._value > 1)
         {
            this._value = 1;
         }
         this.changed.dispatch(this._value);
      }
      
      private function updateThumbPositionFromValue(param1:Boolean = true) : void
      {
         if(this._value < 0)
         {
            this._value = 0;
         }
         else if(this._value > 1)
         {
            this._value = 1;
         }
         var _loc2_:int = this.btn_up.y + this.btn_up.height;
         var _loc3_:int = this.btn_down.y - this.mc_thumb.height;
         var _loc4_:int = int(_loc2_ + (_loc3_ - _loc2_) * this._value);
         if(_loc4_ < _loc2_)
         {
            _loc4_ = _loc2_;
         }
         else if(_loc4_ > _loc3_)
         {
            _loc4_ = _loc3_;
         }
         this.mc_thumb.y = _loc4_;
         if(param1)
         {
            this.changed.dispatch(this._value);
         }
      }
      
      private function onClickArrow(param1:MouseEvent) : void
      {
         var _loc2_:Number = this.calcHeight / this._contentHeight;
         switch(param1.currentTarget)
         {
            case this.btn_down:
               this._value += _loc2_;
               break;
            case this.btn_up:
               this._value -= _loc2_;
         }
         this.updateThumbPositionFromValue();
         param1.stopPropagation();
      }
      
      private function onMouseOverThumb(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_thumb,0,{
            "colorTransform":{"exposure":1.1},
            "overwrite":true
         });
      }
      
      private function onMouseOutThumb(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_thumb,0.15,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onMouseDownThumb(param1:MouseEvent) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onDrag,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpThumb,false,0,true);
         this._mouseDownY = this.mc_thumb.mouseY;
         this.onDrag(null);
      }
      
      private function onMouseUpThumb(param1:MouseEvent) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onDrag);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpThumb);
      }
      
      private function onDrag(param1:Event = null) : void
      {
         var _loc2_:int = this.btn_up.y + this.btn_up.height;
         var _loc3_:int = this.btn_down.y - this.mc_thumb.height;
         var _loc4_:int = mouseY - this._mouseDownY * this.mc_thumb.scaleY;
         if(_loc4_ < _loc2_)
         {
            _loc4_ = _loc2_;
         }
         else if(_loc4_ > _loc3_)
         {
            _loc4_ = _loc3_;
         }
         this.mc_thumb.y = _loc4_;
         this.updateValueFromThumbPosition();
      }
      
      private function onTrackMouseDown(param1:MouseEvent) : void
      {
         if(!this.mc_thumb.visible)
         {
            return;
         }
         this.mc_thumb.y = mouseY - this.mc_thumb.height * 0.5;
         this.onMouseDownThumb(null);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._stage = stage;
         this._stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         if(mouseX > 0 && mouseX < this._width && mouseY > 0 && mouseY < this._height || this.wheelArea && this.wheelArea.mouseX > 0 && this.wheelArea.mouseX < this.wheelArea.height && this.wheelArea.mouseY > 0 && this.wheelArea.mouseY < this.wheelArea.height)
         {
            this.value += this.calcHeight / this._contentHeight * (param1.delta < 0 ? 1 : -1);
            this.updateThumbPositionFromValue();
         }
      }
      
      public function get contentHeight() : Number
      {
         return this._contentHeight;
      }
      
      public function set contentHeight(param1:Number) : void
      {
         this._contentHeight = param1;
         this.updateThumb();
      }
      
      public function get scrollHeight() : Number
      {
         return this._scrollHeight;
      }
      
      public function set scrollHeight(param1:Number) : void
      {
         this._scrollHeight = param1;
         this.updateThumb();
      }
      
      private function get calcHeight() : Number
      {
         return this._scrollHeight > 0 ? this._scrollHeight : this._height;
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._value = param1;
         this.updateThumbPositionFromValue(false);
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
         this.setHeight(param1);
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Sprite;
import flash.events.MouseEvent;

class ArrowButton extends Sprite
{
   
   private var _width:int = 12;
   
   private var _height:int = 12;
   
   public function ArrowButton(param1:int)
   {
      super();
      graphics.beginFill(16711680,0);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      var _loc2_:int = this._width * 0.5;
      var _loc3_:int = this._height * 0.5;
      var _loc4_:int = 4;
      var _loc5_:int = 3;
      graphics.beginFill(7500402);
      if(param1 == 1)
      {
         graphics.moveTo(_loc2_ - _loc4_,_loc3_ - _loc5_);
         graphics.lineTo(_loc2_,_loc3_ + _loc5_);
         graphics.lineTo(_loc2_ + _loc4_,_loc3_ - _loc5_);
         graphics.lineTo(_loc2_ - _loc4_,_loc3_ - _loc5_);
      }
      else
      {
         graphics.moveTo(_loc2_ - _loc4_,_loc3_ + _loc5_);
         graphics.lineTo(_loc2_,_loc3_ - _loc5_);
         graphics.lineTo(_loc2_ + _loc4_,_loc3_ + _loc5_);
         graphics.lineTo(_loc2_ - _loc4_,_loc3_ + _loc5_);
      }
      graphics.endFill();
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this,0,{
         "colorTransform":{"exposure":1.1},
         "overwrite":true
      });
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this,0.15,{
         "colorTransform":{"exposure":1},
         "overwrite":true
      });
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      TweenMax.to(this,0,{
         "colorTransform":{"exposure":1.25},
         "overwrite":true
      });
      TweenMax.to(this,0.15,{
         "delay":0.01,
         "colorTransform":{"exposure":1}
      });
   }
}
