package thelaststand.engine.map
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.events.MouseEvent3D;
   import com.deadreckoned.threshold.core.IDisposable;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.engine.alternativa.engine3d.primitives.SimplePlane;
   
   public class MouseMap implements IDisposable
   {
      
      private var _display:Object3D;
      
      private var _plane:SimplePlane;
      
      private var _cellSize:int;
      
      private var _x:int;
      
      private var _y:int;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _enabled:Boolean = false;
      
      private var _mousePt:Point = new Point();
      
      private var _mouseCell:Point = new Point();
      
      private var _mouseDownCell:Point = new Point();
      
      private var _tmpVector1:Vector3D = new Vector3D();
      
      private var _tmpVector2:Vector3D = new Vector3D();
      
      public var tileClicked:Signal;
      
      public var tileRightClicked:Signal;
      
      public var tileMouseDown:Signal;
      
      public var tileMouseUp:Signal;
      
      public var tileMouseOver:Signal;
      
      public var tileMouseOut:Signal;
      
      public var mouseOut:Signal;
      
      public var mouseOver:Signal;
      
      public function MouseMap(param1:int, param2:int, param3:int, param4:int, param5:int)
      {
         super();
         this._x = param1;
         this._y = param2;
         this._width = param3;
         this._height = param4;
         this._cellSize = param5;
         this._plane = new SimplePlane();
         this._plane.mouseEnabled = this._plane.mouseChildren = false;
         this._plane.scaleX = this._width * this._cellSize;
         this._plane.scaleY = this._height * this._cellSize;
         this._display = this._plane;
         this._display.x = this._x + int(this._cellSize * this._width * 0.5);
         this._display.y = this._y - int(this._cellSize * this._height * 0.5);
         this.mouseOut = new Signal(int,int);
         this.mouseOver = new Signal();
         this.tileMouseOver = new Signal(int,int,int,int);
         this.tileMouseOut = new Signal(int,int,int,int);
         this.tileMouseDown = new Signal(int,int);
         this.tileMouseUp = new Signal(int,int);
         this.tileClicked = new Signal(int,int);
         this.tileRightClicked = new Signal(int,int);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.setEnabledState(param1);
      }
      
      public function get display() : Object3D
      {
         return this._display;
      }
      
      public function get mousePt() : Point
      {
         return this._mousePt;
      }
      
      public function get mouseCell() : Point
      {
         return this._mouseCell;
      }
      
      public function dispose() : void
      {
         if(this._plane.parent != null)
         {
            this._plane.parent.removeChild(this._plane);
         }
         this._plane.geometry = null;
         this.mouseOut.removeAll();
         this.mouseOver.removeAll();
         this.tileMouseOver.removeAll();
         this.tileMouseOut.removeAll();
         this.tileMouseDown.removeAll();
         this.tileMouseUp.removeAll();
         this.tileClicked.removeAll();
         this.tileRightClicked.removeAll();
      }
      
      public function cancelMousePress() : void
      {
         this._mouseDownCell.setTo(-1,-1);
      }
      
      private function setEnabledState(param1:Boolean) : void
      {
         this._enabled = param1;
         this._plane.mouseEnabled = this._enabled;
         if(this._enabled)
         {
            this._mousePt.setTo(-1,-1);
            this._mouseCell.setTo(-1,-1);
            this._display.addEventListener(MouseEvent3D.MOUSE_OUT,this.onMouseOut,false,0,true);
            this._display.addEventListener(MouseEvent3D.MOUSE_OVER,this.onMouseOver,false,0,true);
            this._display.addEventListener(MouseEvent3D.MOUSE_MOVE,this.onMouseMove,false,0,true);
            this._display.addEventListener(MouseEvent3D.MOUSE_DOWN,this.onMouseDown,false,0,true);
            this._display.addEventListener(MouseEvent3D.MOUSE_UP,this.onMouseUp,false,0,true);
            this._display.addEventListener(MouseEvent3D.CLICK,this.onClick,false,0,true);
            this._display.addEventListener(MouseEvent3D.RIGHT_CLICK,this.onRightClick,false,0,true);
            this._display.addEventListener(MouseEvent3D.RIGHT_MOUSE_DOWN,this.onRightMouseDown,false,0,true);
         }
         else
         {
            this._display.removeEventListener(MouseEvent3D.MOUSE_OUT,this.onMouseOut);
            this._display.removeEventListener(MouseEvent3D.MOUSE_OVER,this.onMouseOver);
            this._display.removeEventListener(MouseEvent3D.MOUSE_MOVE,this.onMouseMove);
            this._display.removeEventListener(MouseEvent3D.MOUSE_DOWN,this.onMouseDown);
            this._display.removeEventListener(MouseEvent3D.MOUSE_UP,this.onMouseUp);
            this._display.removeEventListener(MouseEvent3D.CLICK,this.onClick);
            this._display.removeEventListener(MouseEvent3D.RIGHT_CLICK,this.onRightClick);
            this._display.removeEventListener(MouseEvent3D.RIGHT_MOUSE_DOWN,this.onRightMouseDown);
         }
      }
      
      private function onClick(param1:MouseEvent3D) : void
      {
         if(this._mouseDownCell.x != this._mouseCell.x && this._mouseDownCell.y != this._mouseCell.y)
         {
            return;
         }
         if(this._mouseDownCell.x == -1 || this._mouseDownCell.y == -1)
         {
            return;
         }
         this.tileClicked.dispatch(this._mouseCell.x,this._mouseCell.y);
      }
      
      private function onRightClick(param1:MouseEvent3D) : void
      {
         if(this._mouseDownCell.x != this._mouseCell.x && this._mouseDownCell.y != this._mouseCell.y)
         {
            return;
         }
         if(this._mouseDownCell.x == -1 || this._mouseDownCell.y == -1)
         {
            return;
         }
         this.tileRightClicked.dispatch(this._mouseCell.x,this._mouseCell.y);
      }
      
      private function onMouseOver(param1:MouseEvent3D) : void
      {
         this.mouseOver.dispatch();
      }
      
      private function onMouseOut(param1:MouseEvent3D) : void
      {
         this.mouseOut.dispatch(this._mouseCell.x,this._mouseCell.y);
         this._mouseCell.setTo(-1,-1);
      }
      
      private function onMouseDown(param1:MouseEvent3D) : void
      {
         this._mouseDownCell.x = this._mouseCell.x;
         this._mouseDownCell.y = this._mouseCell.y;
         this.tileMouseDown.dispatch(this._mouseCell.x,this._mouseCell.y);
      }
      
      private function onMouseUp(param1:MouseEvent3D) : void
      {
         this.tileMouseUp.dispatch(this._mouseCell.x,this._mouseCell.y);
      }
      
      private function onRightMouseDown(param1:MouseEvent3D) : void
      {
         this._mouseDownCell.x = this._mouseCell.x;
         this._mouseDownCell.y = this._mouseCell.y;
      }
      
      private function onMouseMove(param1:MouseEvent3D) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:Number = this._plane.scaleX * (param1.localX + 0.5);
         var _loc3_:Number = this._plane.scaleY * (param1.localY - 0.5) * -1;
         this._mousePt.x = this._x + _loc2_;
         this._mousePt.y = this._y - _loc3_;
         var _loc4_:int = int(_loc2_ / this._cellSize);
         var _loc5_:int = int(_loc3_ / this._cellSize);
         if(_loc4_ != this._mouseCell.x || _loc5_ != this._mouseCell.y)
         {
            _loc6_ = this._mouseCell.x;
            _loc7_ = this._mouseCell.y;
            this.tileMouseOut.dispatch(_loc6_,_loc7_,_loc4_,_loc5_);
            this._mouseCell.x = _loc4_;
            this._mouseCell.y = _loc5_;
            this.tileMouseOver.dispatch(_loc4_,_loc5_,_loc6_,_loc7_);
         }
      }
   }
}

