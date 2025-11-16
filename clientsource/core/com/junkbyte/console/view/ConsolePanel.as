package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class ConsolePanel extends Sprite
   {
      
      public static const DRAGGING_STARTED:String = "draggingStarted";
      
      public static const DRAGGING_ENDED:String = "draggingEnded";
      
      public static const SCALING_STARTED:String = "scalingStarted";
      
      public static const SCALING_ENDED:String = "scalingEnded";
      
      public static const VISIBLITY_CHANGED:String = "visibilityChanged";
      
      private static const TEXT_ROLL:String = "TEXT_ROLL";
      
      private var _snaps:Array;
      
      private var _dragOffset:Point;
      
      private var _resizeTxt:TextField;
      
      protected var console:Console;
      
      protected var bg:Sprite;
      
      protected var scaler:Sprite;
      
      protected var txtField:TextField;
      
      protected var minWidth:int = 18;
      
      protected var minHeight:int = 18;
      
      private var _movedFrom:Point;
      
      public var moveable:Boolean = true;
      
      public function ConsolePanel(param1:Console)
      {
         super();
         this.console = param1;
         this.bg = new Sprite();
         this.bg.name = "background";
         addChild(this.bg);
      }
      
      private static function onTextFieldMouseOut(param1:MouseEvent) : void
      {
         TextField(param1.currentTarget).dispatchEvent(new TextEvent(TEXT_ROLL));
      }
      
      private static function onTextFieldMouseMove(param1:MouseEvent) : void
      {
         var url:String;
         var index:int = 0;
         var scrollH:Number = NaN;
         var w:Number = NaN;
         var X:XML = null;
         var txtformat:XML = null;
         var e:MouseEvent = param1;
         var field:TextField = e.currentTarget as TextField;
         if(field.scrollH > 0)
         {
            scrollH = field.scrollH;
            w = field.width;
            field.width = w + scrollH;
            index = field.getCharIndexAtPoint(field.mouseX + scrollH,field.mouseY);
            field.width = w;
            field.scrollH = scrollH;
         }
         else
         {
            index = field.getCharIndexAtPoint(field.mouseX,field.mouseY);
         }
         url = null;
         if(index > 0)
         {
            try
            {
               X = new XML(field.getXMLText(index,index + 1));
               if(X.hasOwnProperty("textformat"))
               {
                  txtformat = X["textformat"][0] as XML;
                  if(txtformat)
                  {
                     url = txtformat.@url;
                  }
               }
            }
            catch(err:Error)
            {
               url = null;
            }
         }
         field.dispatchEvent(new TextEvent(TEXT_ROLL,false,false,url));
      }
      
      protected function get config() : ConsoleConfig
      {
         return this.console.config;
      }
      
      protected function get style() : ConsoleStyle
      {
         return this.console.config.style;
      }
      
      protected function init(param1:Number, param2:Number, param3:Boolean = false, param4:Number = -1, param5:Number = -1, param6:int = -1) : void
      {
         this.bg.graphics.clear();
         this.bg.graphics.beginFill(param4 >= 0 ? uint(param4) : this.style.backgroundColor,param5 >= 0 ? param5 : this.style.backgroundAlpha);
         if(param6 < 0)
         {
            param6 = this.style.roundBorder;
         }
         if(param6 <= 0)
         {
            this.bg.graphics.drawRect(0,0,100,100);
         }
         else
         {
            this.bg.graphics.drawRoundRect(0,0,param6 + 10,param6 + 10,param6,param6);
            this.bg.scale9Grid = new Rectangle(param6 * 0.5,param6 * 0.5,10,10);
         }
         this.scalable = param3;
         this.width = param1;
         this.height = param2;
      }
      
      public function close() : void
      {
         this.stopDragging();
         this.console.panels.tooltip();
         if(parent)
         {
            parent.removeChild(this);
         }
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         dispatchEvent(new Event(VISIBLITY_CHANGED));
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 < this.minWidth)
         {
            param1 = this.minWidth;
         }
         if(this.scaler)
         {
            this.scaler.x = param1;
         }
         this.bg.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 < this.minHeight)
         {
            param1 = this.minHeight;
         }
         if(this.scaler)
         {
            this.scaler.y = param1;
         }
         this.bg.height = param1;
      }
      
      override public function get width() : Number
      {
         return this.bg.width;
      }
      
      override public function get height() : Number
      {
         return this.bg.height;
      }
      
      public function registerSnaps(param1:Array, param2:Array) : void
      {
         this._snaps = [param1,param2];
      }
      
      protected function registerDragger(param1:DisplayObject, param2:Boolean = false) : void
      {
         if(param2)
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDraggerMouseDown);
         }
         else
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onDraggerMouseDown,false,0,true);
         }
      }
      
      private function onDraggerMouseDown(param1:MouseEvent) : void
      {
         if(!stage || !this.moveable)
         {
            return;
         }
         this._resizeTxt = this.makeTF("positioningField",true);
         this._resizeTxt.mouseEnabled = false;
         this._resizeTxt.autoSize = TextFieldAutoSize.LEFT;
         addChild(this._resizeTxt);
         this.updateDragText();
         this._movedFrom = new Point(x,y);
         this._dragOffset = new Point(mouseX,mouseY);
         this._snaps = [[],[]];
         dispatchEvent(new Event(DRAGGING_STARTED));
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onDraggerMouseUp,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onDraggerMouseMove,false,0,true);
      }
      
      private function onDraggerMouseMove(param1:MouseEvent = null) : void
      {
         if(this.style.panelSnapping == 0)
         {
            return;
         }
         var _loc2_:Point = this.returnSnappedFor(parent.mouseX - this._dragOffset.x,parent.mouseY - this._dragOffset.y);
         x = _loc2_.x;
         y = _loc2_.y;
         this.updateDragText();
      }
      
      private function updateDragText() : void
      {
         this._resizeTxt.text = "<low>" + x + "," + y + "</low>";
      }
      
      private function onDraggerMouseUp(param1:MouseEvent) : void
      {
         this.stopDragging();
      }
      
      private function stopDragging() : void
      {
         this._snaps = null;
         if(stage)
         {
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.onDraggerMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDraggerMouseMove);
         }
         if(Boolean(this._resizeTxt) && Boolean(this._resizeTxt.parent))
         {
            this._resizeTxt.parent.removeChild(this._resizeTxt);
         }
         this._resizeTxt = null;
         dispatchEvent(new Event(DRAGGING_ENDED));
      }
      
      public function moveBackSafePosition() : void
      {
         if(this._movedFrom != null)
         {
            if(x + this.width < 10 || stage && stage.stageWidth < x + 10 || y + this.height < 10 || stage && stage.stageHeight < y + 20)
            {
               x = this._movedFrom.x;
               y = this._movedFrom.y;
            }
            this._movedFrom = null;
         }
      }
      
      public function get scalable() : Boolean
      {
         return this.scaler ? true : false;
      }
      
      public function set scalable(param1:Boolean) : void
      {
         var _loc2_:uint = 0;
         if(param1 && !this.scaler)
         {
            _loc2_ = 8 + this.style.controlSize * 0.5;
            this.scaler = new Sprite();
            this.scaler.name = "scaler";
            this.scaler.graphics.beginFill(0,0);
            this.scaler.graphics.drawRect(-_loc2_ * 1.5,-_loc2_ * 1.5,_loc2_ * 1.5,_loc2_ * 1.5);
            this.scaler.graphics.endFill();
            this.scaler.graphics.beginFill(this.style.controlColor,this.style.backgroundAlpha);
            this.scaler.graphics.moveTo(0,0);
            this.scaler.graphics.lineTo(-_loc2_,0);
            this.scaler.graphics.lineTo(0,-_loc2_);
            this.scaler.graphics.endFill();
            this.scaler.buttonMode = true;
            this.scaler.doubleClickEnabled = true;
            this.scaler.addEventListener(MouseEvent.MOUSE_DOWN,this.onScalerMouseDown,false,0,true);
            addChildAt(this.scaler,getChildIndex(this.bg) + 1);
         }
         else if(!param1 && Boolean(this.scaler))
         {
            if(contains(this.scaler))
            {
               removeChild(this.scaler);
            }
            this.scaler = null;
         }
      }
      
      private function onScalerMouseDown(param1:Event) : void
      {
         this._resizeTxt = this.makeTF("resizingField",true);
         this._resizeTxt.mouseEnabled = false;
         this._resizeTxt.autoSize = TextFieldAutoSize.RIGHT;
         this._resizeTxt.x = -4;
         this._resizeTxt.y = -17;
         this.scaler.addChild(this._resizeTxt);
         this.updateScaleText();
         this._dragOffset = new Point(this.scaler.mouseX,this.scaler.mouseY);
         this._snaps = [[],[]];
         this.scaler.stage.addEventListener(MouseEvent.MOUSE_UP,this.onScalerMouseUp,false,0,true);
         this.scaler.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.updateScale,false,0,true);
         dispatchEvent(new Event(SCALING_STARTED));
      }
      
      private function updateScale(param1:Event = null) : void
      {
         var _loc2_:Point = this.returnSnappedFor(x + mouseX - this._dragOffset.x,y + mouseY - this._dragOffset.x);
         _loc2_.x -= x;
         _loc2_.y -= y;
         this.width = _loc2_.x < this.minWidth ? this.minWidth : _loc2_.x;
         this.height = _loc2_.y < this.minHeight ? this.minHeight : _loc2_.y;
         this.updateScaleText();
      }
      
      private function updateScaleText() : void
      {
         this._resizeTxt.text = "<low>" + this.width + "," + this.height + "</low>";
      }
      
      public function stopScaling() : void
      {
         this.onScalerMouseUp(null);
      }
      
      private function onScalerMouseUp(param1:Event) : void
      {
         this.scaler.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScalerMouseUp);
         this.scaler.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.updateScale);
         this.updateScale();
         this._snaps = null;
         if(Boolean(this._resizeTxt) && Boolean(this._resizeTxt.parent))
         {
            this._resizeTxt.parent.removeChild(this._resizeTxt);
         }
         this._resizeTxt = null;
         dispatchEvent(new Event(SCALING_ENDED));
      }
      
      public function makeTF(param1:String, param2:Boolean = false) : TextField
      {
         var _loc3_:TextField = new TextField();
         _loc3_.name = param1;
         _loc3_.styleSheet = this.style.styleSheet;
         if(param2)
         {
            _loc3_.background = true;
            _loc3_.backgroundColor = this.style.backgroundColor;
         }
         return _loc3_;
      }
      
      private function returnSnappedFor(param1:Number, param2:Number) : Point
      {
         return new Point(this.getSnapOf(param1,true),this.getSnapOf(param2,false));
      }
      
      private function getSnapOf(param1:Number, param2:Boolean) : Number
      {
         var _loc6_:Number = NaN;
         var _loc3_:Number = param1 + this.width;
         var _loc4_:Array = this._snaps[param2 ? 0 : 1];
         var _loc5_:int = this.style.panelSnapping;
         for each(_loc6_ in _loc4_)
         {
            if(Math.abs(_loc6_ - param1) < _loc5_)
            {
               return _loc6_;
            }
            if(Math.abs(_loc6_ - _loc3_) < _loc5_)
            {
               return _loc6_ - this.width;
            }
         }
         return param1;
      }
      
      protected function registerTFRoller(param1:TextField, param2:Function, param3:Function = null) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_MOVE,onTextFieldMouseMove,false,0,true);
         param1.addEventListener(MouseEvent.ROLL_OUT,onTextFieldMouseOut,false,0,true);
         param1.addEventListener(TEXT_ROLL,param2,false,0,true);
         if(param3 != null)
         {
            param1.addEventListener(TextEvent.LINK,param3,false,0,true);
         }
      }
   }
}

