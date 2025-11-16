package thelaststand.app.game.map
{
   import com.greensock.TweenMax;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.osflash.signals.Signal;
   import starling.core.Starling;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.events.TouchPhase;
   import thelaststand.app.game.data.CameraControlType;
   import thelaststand.app.game.events.GUIControlEvent;
   import thelaststand.app.game.gui.map.UIMissionAreaNode;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.resources.ResourceManager;
   
   public class WorldMapView extends Sprite
   {
      
      private const ZOOM_LEVELS:Array = [1,0.5];
      
      private var _xml:XML;
      
      private var _stage:Stage;
      
      private var _starling:Starling;
      
      private var _sMap:MapStarlingLayer;
      
      private var _width:int = 300;
      
      private var _height:int = 300;
      
      private var _mapWidth:int;
      
      private var _mapHeight:int;
      
      internal var _viewportBounds:Rectangle = new Rectangle(0,0,300,300);
      
      private var _dragging:Boolean = false;
      
      private var _mousePt:Point = new Point();
      
      private var _lastTarget:Point = new Point();
      
      private var _ptTarget:Point = new Point();
      
      private var _easeFactor:Number = 4;
      
      private var _lastScale:Number = 0;
      
      private var _mouseDownPt:Point = new Point();
      
      private var _scale:Number = 1;
      
      private var _zoomLevel:int;
      
      private var _overlay:MapOverlay;
      
      private var _blockout:Shape;
      
      public var suburbChanged:Signal;
      
      public var neighborClicked:Signal;
      
      public function WorldMapView()
      {
         super();
         this.suburbChanged = new Signal(String,int,Boolean);
         this.neighborClicked = new Signal(RemotePlayerData,Point);
         addEventListener(flash.events.Event.ADDED_TO_STAGE,this.init,false,0,true);
      }
      
      private function init(param1:flash.events.Event = null) : void
      {
         removeEventListener(flash.events.Event.ADDED_TO_STAGE,this.init);
         this._stage = stage;
         this._xml = ResourceManager.getInstance().getResource("map/map.xml").content;
         var _loc2_:XML = this._xml.size[0];
         var _loc3_:int = int(_loc2_.@cols);
         var _loc4_:int = int(_loc2_.@rows);
         var _loc5_:int = int(_loc2_.@width);
         var _loc6_:int = int(_loc2_.@height);
         this._mapWidth = _loc3_ * _loc5_;
         this._mapHeight = _loc4_ * _loc6_;
         this._stage = stage;
         this.createStarlingElements();
         this._overlay = new MapOverlay(this._xml);
         addChild(this._overlay);
         this._overlay.suburbChanged.add(this.onSuburbChanged);
         this._overlay.neighborClicked.add(this.onNeighborClicked);
         this._blockout = new Shape();
         addEventListener(MouseEvent.MOUSE_DOWN,this.startMouseDrag,false,0,true);
         stage.addEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame,false,300,true);
         stage.addEventListener(flash.events.Event.ENTER_FRAME,this.updateMapPosition,false,500,true);
         stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
         stage.addEventListener(GUIControlEvent.CAMERA_CONTROL,this.onCameraControlled,false,0,true);
      }
      
      private function createStarlingElements() : void
      {
         if(this._starling)
         {
            this._sMap.removeEventListeners();
            if(this._sMap)
            {
               this._sMap.dispose();
            }
            this._starling.stop();
            this._starling.dispose();
         }
         var _loc1_:Stage3D = stage.stage3Ds[1];
         if(_loc1_.context3D)
         {
            _loc1_.context3D.clear();
            _loc1_.context3D.present();
            _loc1_.context3D.dispose();
         }
         _loc1_ = null;
         Starling.handleLostContext = true;
         this._starling = new Starling(MapStarlingLayer,stage,null,stage.stage3Ds[0],"auto","baseline");
         this._starling.addEventListener(starling.events.Event.ROOT_CREATED,this.onRootCreated);
         this._starling.start();
      }
      
      private function onRootCreated(param1:starling.events.Event) : void
      {
         this._starling.removeEventListener(starling.events.Event.ROOT_CREATED,this.onRootCreated);
         this._sMap = MapStarlingLayer(this._starling.root);
         this._sMap.init(this._xml);
         this._sMap.addEventListener(TouchEvent.TOUCH,this.onSMapTouch);
         this._sMap.topOffset = this._viewportBounds.top;
         this._overlay.passSuburbsToStarlingMap(this._sMap);
         this._sMap.applyTransform(this._overlay.transform.matrix);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._sMap.removeEventListener(TouchEvent.TOUCH,this.onSMapTouch);
         this._starling.dispose();
         this._starling = null;
         this._overlay.dispose();
         this.suburbChanged.removeAll();
         this.neighborClicked.removeAll();
         removeEventListener(MouseEvent.MOUSE_DOWN,this.startMouseDrag);
         this._stage.removeEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame);
         this._stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         this._stage.removeEventListener(GUIControlEvent.CAMERA_CONTROL,this.onCameraControlled);
         this._stage.removeEventListener(flash.events.Event.EXIT_FRAME,this.updateMapPosition);
         if(this._stage.stage3Ds[1].context3D)
         {
            this._stage.stage3Ds[1].context3D.clear();
            this._stage.stage3Ds[1].context3D.dispose();
         }
      }
      
      public function transitionIn(param1:Number = 0, param2:String = null) : void
      {
         var temp:Point;
         var targetNode:UIMissionAreaNode = null;
         var px:Number = NaN;
         var py:Number = NaN;
         var dummy:Object = null;
         var delay:Number = param1;
         var playerId:String = param2;
         if(playerId != null)
         {
            targetNode = this._overlay.getOtherPlayerNode(playerId);
         }
         if(targetNode == null)
         {
            targetNode = this._overlay.getPlayerNode();
         }
         px = targetNode != null ? targetNode.x + targetNode.width * 0.5 : this._mapWidth * 0.5;
         py = targetNode != null ? targetNode.y + targetNode.height * 0.5 : this._mapHeight * 0.5;
         this.zoom(0.5,px,py,true);
         this.centerOn(px,py,true);
         temp = this._ptTarget.clone();
         this._blockout.x = -this._viewportBounds.x;
         this._blockout.y = -this._viewportBounds.y;
         addChild(this._blockout);
         this.mouseChildren = false;
         dummy = {
            "zoom":this._scale,
            "alpha":1
         };
         TweenMax.to(dummy,0.5,{
            "delay":delay,
            "zoom":1,
            "alpha":0,
            "overwrite":true,
            "onUpdate":function():void
            {
               zoom(dummy.zoom,px,py,true);
               _blockout.alpha = dummy.alpha;
            },
            "onComplete":function():void
            {
               mouseChildren = true;
               _blockout.parent.removeChild(_blockout);
            }
         });
      }
      
      public function transitionOut(param1:Number = 0, param2:Function = null) : void
      {
         var focus:Point = null;
         var dummy:Object = null;
         var delay:Number = param1;
         var onComplete:Function = param2;
         this.mouseChildren = false;
         focus = new Point();
         dummy = {
            "zoom":this._scale,
            "alpha":0
         };
         this._blockout.x = -this._viewportBounds.x;
         this._blockout.y = -this._viewportBounds.y;
         addChild(this._blockout);
         if(this._overlay.selectedNode != null)
         {
            focus.x = this._overlay.selectedNode.x + this._overlay.selectedNode.width * 0.5;
            focus.y = this._overlay.selectedNode.y + this._overlay.selectedNode.height * 0.5;
         }
         else
         {
            focus.x = (this._viewportBounds.x + this._viewportBounds.width * 0.5 - this._overlay.x) / this._scale;
            focus.y = (this._viewportBounds.y + this._viewportBounds.height * 0.5 - this._overlay.y) / this._scale;
         }
         this._overlay.setFilter(null);
         TweenMax.to(dummy,0.4,{
            "delay":delay,
            "zoom":3,
            "alpha":1,
            "overwrite":true,
            "onUpdate":function():void
            {
               zoom(dummy.zoom,focus.x,focus.y,true);
               _blockout.alpha = dummy.alpha;
            },
            "onComplete":onComplete
         });
      }
      
      public function centerOnPlayerNode() : void
      {
         var _loc1_:UIMissionAreaNode = this._overlay.getPlayerNode();
         var _loc2_:Number = _loc1_.x + _loc1_.width * 0.5;
         var _loc3_:Number = _loc1_.y + _loc1_.height * 0.5;
         this.centerOn(_loc2_,_loc3_);
      }
      
      public function hasNodeForPlayer(param1:String) : Boolean
      {
         return this._overlay.hasNodeForPlayer(param1);
      }
      
      public function setFilter(param1:String) : void
      {
         this._overlay.setFilter(param1);
      }
      
      public function updateViewportBounds(param1:int, param2:int, param3:int) : void
      {
         this._viewportBounds.top = param1;
         this._viewportBounds.bottom = param2;
         this._viewportBounds.width = param3;
         if(this._sMap)
         {
            this._sMap.topOffset = param1;
         }
      }
      
      private function centerOn(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         this._ptTarget.x = -param1 * this._scale + this._viewportBounds.width * 0.5;
         this._ptTarget.y = -param2 * this._scale + this._viewportBounds.height * 0.5;
         if(param3)
         {
            this.clampPosition();
            this.applyScalePositionTransforms();
         }
      }
      
      private function clampPosition() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!this._sMap)
         {
            return;
         }
         if(this._mapWidth * this._scale <= this._stage.stageWidth)
         {
            _loc1_ = _loc2_ = this._viewportBounds.x + (this._viewportBounds.width - this._mapWidth * this._scale) * 0.5;
         }
         else
         {
            _loc1_ = this._viewportBounds.x - this._mapWidth * this._scale + this._viewportBounds.width;
            _loc2_ = this._viewportBounds.x;
         }
         if(this._ptTarget.x < _loc1_)
         {
            this._ptTarget.x = _loc1_;
         }
         else if(this._ptTarget.x > _loc2_)
         {
            this._ptTarget.x = _loc2_;
         }
         if(this._mapWidth * this._scale <= this._stage.stageWidth)
         {
            _loc3_ = _loc4_ = this._viewportBounds.y + (this._viewportBounds.height - this._mapHeight * this._scale) * 0.5;
         }
         else
         {
            _loc3_ = this._viewportBounds.y - this._mapHeight * this._scale + this._viewportBounds.height;
            _loc4_ = this._viewportBounds.y;
         }
         if(this._ptTarget.y < _loc3_)
         {
            this._ptTarget.y = _loc3_;
         }
         else if(this._ptTarget.y > _loc4_)
         {
            this._ptTarget.y = _loc4_;
         }
      }
      
      private function zoom(param1:Number, param2:Number, param3:Number, param4:Boolean = false) : void
      {
         var _loc5_:Point = globalToLocal(this._overlay.localToGlobal(new Point(param2,param3)));
         this._scale = param1;
         this._ptTarget.x = _loc5_.x - param2 * param1;
         this._ptTarget.y = _loc5_.y - param3 * param1;
         if(param4)
         {
            this.clampPosition();
            this.applyScalePositionTransforms();
         }
      }
      
      private function setZoomLevel(param1:int, param2:Number = NaN, param3:Number = NaN) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 >= this.ZOOM_LEVELS.length)
         {
            param1 = int(this.ZOOM_LEVELS.length - 1);
         }
         if(param1 == this._zoomLevel)
         {
            return;
         }
         this._zoomLevel = param1;
         var _loc4_:Point = new Point(this._viewportBounds.width * 0.5,this._viewportBounds.height * 0.5);
         _loc4_ = this._overlay.globalToLocal(localToGlobal(_loc4_));
         if(isNaN(param2))
         {
            param2 = _loc4_.x;
         }
         if(isNaN(param3))
         {
            param3 = _loc4_.y;
         }
         this.zoom(this.ZOOM_LEVELS[this._zoomLevel],param2,param3);
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         this._starling.viewPort = new Rectangle(0,0,this._stage.stageWidth,this._stage.stageHeight);
         this._starling.stage.stageWidth = this._stage.stageWidth;
         this._starling.stage.stageHeight = this._stage.stageHeight;
         if(this._overlay)
         {
            this.clampPosition();
            this.applyScalePositionTransforms();
         }
         this._blockout.graphics.clear();
         this._blockout.graphics.beginFill(0);
         this._blockout.graphics.drawRect(0,0,this._stage.stageWidth,this._stage.stageHeight);
      }
      
      private function applyScalePositionTransforms() : void
      {
         if(this._overlay.x == this._ptTarget.x && this._overlay.y == this._ptTarget.y && this._overlay.scaleY == this._scale)
         {
            return;
         }
         this._overlay.x = this._ptTarget.x;
         this._overlay.y = this._ptTarget.y;
         this._overlay.scaleX = this._overlay.scaleY = this._scale;
         this._overlay.updateElementScales(this._scale);
         if(this._sMap)
         {
            this._sMap.applyTransform(this._overlay.transform.matrix);
         }
      }
      
      private function onSMapTouch(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(this._sMap);
         if(_loc2_ == null)
         {
            return;
         }
         if(!this.mouseChildren)
         {
            return;
         }
         switch(_loc2_.phase)
         {
            case TouchPhase.BEGAN:
               dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN,false,false,mouseX,mouseY,null,param1.ctrlKey,false,param1.shiftKey,true));
               break;
            case TouchPhase.ENDED:
               dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP,false,false,mouseX,mouseY,null,param1.ctrlKey,false,param1.shiftKey,true));
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         var _loc2_:int = this._zoomLevel + param1.delta < 0 ? 1 : -1;
         this.setZoomLevel(_loc2_,this._overlay.mouseX,this._overlay.mouseY);
      }
      
      private function onCameraControlled(param1:GUIControlEvent) : void
      {
         switch(param1.controlData as String)
         {
            case CameraControlType.ZOOM_IN:
               this.setZoomLevel(this._zoomLevel - 1);
               break;
            case CameraControlType.ZOOM_OUT:
               this.setZoomLevel(this._zoomLevel + 1);
         }
      }
      
      private function startMouseDrag(param1:MouseEvent) : void
      {
         if(this._dragging)
         {
            return;
         }
         this._dragging = true;
         this._mouseDownPt.x = stage.mouseX;
         this._mouseDownPt.y = stage.mouseY;
         this._mousePt.x = stage.mouseX;
         this._mousePt.y = stage.mouseY;
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.stopMouseDrag,false,0,true);
         this._stage.addEventListener(flash.events.Event.DEACTIVATE,this.stopMouseDrag,false,0,true);
      }
      
      private function stopMouseDrag(param1:flash.events.Event) : void
      {
         if(!this._dragging)
         {
            return;
         }
         this._dragging = false;
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.stopMouseDrag);
         this._stage.removeEventListener(flash.events.Event.DEACTIVATE,this.stopMouseDrag);
      }
      
      private function onEnterFrame(param1:flash.events.Event) : void
      {
         if(this._starling && this._starling.context && this._starling.context.driverInfo == "Disposed")
         {
            this.createStarlingElements();
         }
      }
      
      private function updateMapPosition(param1:flash.events.Event = null) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this._lastTarget.x = this._ptTarget.x;
         this._lastTarget.y = this._ptTarget.y;
         if(this._dragging)
         {
            _loc6_ = this._stage.mouseX - this._mousePt.x;
            _loc7_ = this._stage.mouseY - this._mousePt.y;
            this._ptTarget.x += _loc6_;
            this._ptTarget.y += _loc7_;
            this.clampPosition();
            _loc6_ = stage.mouseX - this._mouseDownPt.x;
            _loc7_ = stage.mouseY - this._mouseDownPt.y;
         }
         this.clampPosition();
         this._mousePt.x = this._stage.mouseX;
         this._mousePt.y = this._stage.mouseY;
         this._lastScale = this._overlay.scaleX;
         var _loc2_:Number = this._overlay.x + (this._ptTarget.x - this._overlay.x) / this._easeFactor;
         var _loc3_:Number = this._overlay.y + (this._ptTarget.y - this._overlay.y) / this._easeFactor;
         if(_loc2_ > this._ptTarget.x - 0.15 && _loc2_ < this._ptTarget.x + 0.15)
         {
            _loc2_ = this._ptTarget.x;
         }
         if(_loc3_ > this._ptTarget.y - 0.15 && _loc3_ < this._ptTarget.y + 0.15)
         {
            _loc3_ = this._ptTarget.y;
         }
         var _loc4_:Number = this._overlay.scaleX + (this._scale - this._overlay.scaleX) / this._easeFactor;
         var _loc5_:Number = this._overlay.scaleY + (this._scale - this._overlay.scaleY) / this._easeFactor;
         if(_loc4_ < this._scale + 0.01 && _loc5_ > this._scale - 0.01)
         {
            _loc4_ = _loc5_ = this._scale;
            if(_loc4_ != this._lastScale)
            {
               _loc2_ = this._ptTarget.x;
               _loc3_ = this._ptTarget.y;
            }
         }
         if(this._lastTarget.x != _loc2_ || this._lastTarget.y != _loc3_ || this._scale != _loc4_)
         {
            this._overlay.scaleX = _loc4_;
            this._overlay.scaleY = _loc5_;
            this._overlay.updateElementScales(_loc4_);
            this._overlay.x = _loc2_;
            this._overlay.y = _loc3_;
            if(this._sMap)
            {
               this._sMap.applyTransform(this._overlay.transform.matrix);
            }
         }
      }
      
      private function onSuburbChanged(param1:String, param2:int, param3:Boolean) : void
      {
         this.suburbChanged.dispatch(param1,param2,param3);
      }
      
      private function onNeighborClicked(param1:RemotePlayerData, param2:Point) : void
      {
         this.neighborClicked.dispatch(param1,param2);
      }
      
      override public function get mouseChildren() : Boolean
      {
         return super.mouseChildren;
      }
      
      override public function set mouseChildren(param1:Boolean) : void
      {
         super.mouseChildren = param1;
         this._overlay.mouseEnabled = param1;
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

