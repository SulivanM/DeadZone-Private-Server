package alternativa.engine3d.core
{
   import alternativa.Alternativa3D;
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.events.MouseEvent3D;
   import alternativa.engine3d.materials.ShaderProgram;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.Geometry;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage3D;
   import flash.display.StageAlign;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.VertexBuffer3D;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   use namespace alternativa3d;
   
   public class View extends Sprite
   {
      
      private static var drawDistanceFragment:Linker;
      
      private static var drawDistanceVertexProcedure:Procedure;
      
      private static const renderEvent:MouseEvent = new MouseEvent("render");
      
      private static const drawUnit:DrawUnit = new DrawUnit();
      
      private static const pixels:Dictionary = new Dictionary();
      
      private static const stack:Vector.<int> = new Vector.<int>();
      
      private static const point:Point = new Point();
      
      private static const scissor:Rectangle = new Rectangle(0,0,1,1);
      
      private static const localCoords:Vector3D = new Vector3D();
      
      private static const branch:Vector.<Object3D> = new Vector.<Object3D>();
      
      private static const overedBranch:Vector.<Object3D> = new Vector.<Object3D>();
      
      private static const changedBranch:Vector.<Object3D> = new Vector.<Object3D>();
      
      private static const functions:Vector.<Function> = new Vector.<Function>();
      
      private static const drawColoredRectConst:Vector.<Number> = Vector.<Number>([0,0,-1,1]);
      
      private static const drawRectColor:Vector.<Number> = new Vector.<Number>(4);
      
      public var backgroundColor:uint;
      
      public var backgroundAlpha:Number;
      
      public var antiAlias:int;
      
      alternativa3d var _width:int;
      
      alternativa3d var _height:int;
      
      alternativa3d var _canvas:BitmapData = null;
      
      private var events:Vector.<MouseEvent>;
      
      private var indices:Vector.<int>;
      
      private var eventsLength:int = 0;
      
      private var surfaces:Vector.<Surface>;
      
      private var geometries:Vector.<Geometry>;
      
      private var procedures:Vector.<Procedure>;
      
      private var surfacesLength:int = 0;
      
      alternativa3d var raysOrigins:Vector.<Vector3D>;
      
      alternativa3d var raysDirections:Vector.<Vector3D>;
      
      private var raysCoefficients:Vector.<Point>;
      
      private var raysSurfaces:Vector.<Vector.<Surface>>;
      
      private var raysDepths:Vector.<Vector.<Number>>;
      
      private var raysIs:Vector.<int>;
      
      private var raysJs:Vector.<int>;
      
      alternativa3d var raysLength:int = 0;
      
      private var lastEvent:MouseEvent;
      
      private var target:Object3D;
      
      private var targetSurface:Surface;
      
      private var targetDepth:Number;
      
      private var pressedTarget:Object3D;
      
      private var pressedMiddleTarget:Object3D;
      
      private var pressedRightTarget:Object3D;
      
      private var clickedTarget:Object3D;
      
      private var overedTarget:Object3D;
      
      private var overedTargetSurface:Surface;
      
      private var altKey:Boolean;
      
      private var ctrlKey:Boolean;
      
      private var shiftKey:Boolean;
      
      private var container:Bitmap;
      
      private var area:Sprite;
      
      private var logo:Logo;
      
      private var bitmap:Bitmap;
      
      private var _logoAlign:String = "BR";
      
      private var _logoHorizontalMargin:Number = 0;
      
      private var _logoVerticalMargin:Number = 0;
      
      private var _renderToBitmap:Boolean;
      
      private var _rightClick3DEnabled:Boolean = false;
      
      public function View(param1:int, param2:int, param3:Boolean = false, param4:uint = 0, param5:Number = 1, param6:int = 0)
      {
         var item:ContextMenuItem;
         var menu:ContextMenu;
         var width:int = param1;
         var height:int = param2;
         var renderToBitmap:Boolean = param3;
         var backgroundColor:uint = param4;
         var backgroundAlpha:Number = param5;
         var antiAlias:int = param6;
         this.events = new Vector.<MouseEvent>();
         this.indices = new Vector.<int>();
         this.surfaces = new Vector.<Surface>();
         this.geometries = new Vector.<Geometry>();
         this.procedures = new Vector.<Procedure>();
         this.alternativa3d::raysOrigins = new Vector.<Vector3D>();
         this.alternativa3d::raysDirections = new Vector.<Vector3D>();
         this.raysCoefficients = new Vector.<Point>();
         this.raysSurfaces = new Vector.<Vector.<Surface>>();
         this.raysDepths = new Vector.<Vector.<Number>>();
         this.raysIs = new Vector.<int>();
         this.raysJs = new Vector.<int>();
         super();
         if(width < 50)
         {
            width = 50;
         }
         if(height < 50)
         {
            height = 50;
         }
         this.alternativa3d::_width = width;
         this.alternativa3d::_height = height;
         this._renderToBitmap = renderToBitmap;
         this.backgroundColor = backgroundColor;
         this.backgroundAlpha = backgroundAlpha;
         this.antiAlias = antiAlias;
         mouseEnabled = true;
         mouseChildren = true;
         doubleClickEnabled = true;
         buttonMode = true;
         useHandCursor = false;
         tabEnabled = false;
         tabChildren = false;
         item = new ContextMenuItem("Powered by Alternativa3D " + Alternativa3D.version);
         item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(param1:ContextMenuEvent):void
         {
            try
            {
               navigateToURL(new URLRequest("http://alternativaplatform.com"),"_blank");
            }
            catch(e:Error)
            {
            }
         });
         menu = new ContextMenu();
         menu.customItems = [item];
         contextMenu = menu;
         this.container = new Bitmap();
         if(renderToBitmap)
         {
            this.createRenderBitmap();
         }
         super.addChild(this.container);
         this.area = new Sprite();
         this.area.graphics.beginFill(16711680);
         this.area.graphics.drawRect(0,0,100,100);
         this.area.mouseEnabled = false;
         this.area.visible = false;
         this.area.width = this.alternativa3d::_width;
         this.area.height = this.alternativa3d::_height;
         hitArea = this.area;
         super.addChild(hitArea);
         this.showLogo();
         if(drawDistanceFragment == null)
         {
            drawDistanceVertexProcedure = Procedure.compileFromArray(["#v0=distance","#c0=transform0","#c1=transform1","#c2=transform2","#c3=coefficient","#c4=projection","dp4 t0.x, i0, c0","dp4 t0.y, i0, c1","dp4 t0.z, i0, c2","mul v0.x, t0.z, c3.z","mov v0.y, i0.x","mov v0.z, i0.x","mov v0.w, i0.x","mul t1.x, t0.x, c4.x","mul t1.y, t0.y, c4.y","mul t0.w, t0.z, c4.z","add t1.z, t0.w, c4.w","mov t3.z, c4.x","div t3.z, t3.z, c4.x","sub t3.z, t3.z, c3.w","mul t1.w, t0.z, t3.z","add t1.w, t1.w, c3.w","mul t0.x, c3.x, t1.w","mul t0.y, c3.y, t1.w","add t1.x, t1.x, t0.x","add t1.y, t1.y, t0.y","mov o0, t1"],"mouseEventsVertex");
            drawDistanceFragment = new Linker(Context3DProgramType.FRAGMENT);
            drawDistanceFragment.addProcedure(new Procedure(["mov t0.z, c0.z","mov t0.w, c0.w","frc t0.y, v0.x","sub t0.x, v0.x, t0.y","mul t0.x, t0.x, c0.x","mov o0, ft0","#v0=distance","#c0=code"],"mouseEventsFragment"));
         }
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouse);
         addEventListener(MouseEvent.CLICK,this.onMouse);
         addEventListener("middleMouseDown",this.onMouse);
         addEventListener("middleClick",this.onMouse);
         addEventListener(MouseEvent.DOUBLE_CLICK,this.onMouse);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouse);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouse);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouse);
         addEventListener(MouseEvent.MOUSE_OUT,this.onLeave);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStage);
      }
      
      public function get rightClick3DEnabled() : Boolean
      {
         return this._rightClick3DEnabled;
      }
      
      public function set rightClick3DEnabled(param1:Boolean) : void
      {
         if(param1 != this._rightClick3DEnabled)
         {
            if(param1)
            {
               addEventListener("rightMouseDown",this.onMouse);
               addEventListener("rightClick",this.onMouse);
            }
            else
            {
               removeEventListener("rightMouseDown",this.onMouse);
               removeEventListener("rightClick",this.onMouse);
            }
            this._rightClick3DEnabled = param1;
         }
      }
      
      private function onMouse(param1:MouseEvent) : void
      {
         var _loc2_:int = this.eventsLength - 1;
         if(this.eventsLength > 0 && param1.type == "mouseMove" && (this.events[_loc2_] as MouseEvent).type == "mouseMove")
         {
            this.events[_loc2_] = param1;
         }
         else
         {
            this.events[this.eventsLength] = param1;
            ++this.eventsLength;
         }
         this.lastEvent = param1;
      }
      
      private function onLeave(param1:MouseEvent) : void
      {
         this.events[this.eventsLength] = param1;
         ++this.eventsLength;
         this.lastEvent = null;
      }
      
      private function createRenderBitmap() : void
      {
         this.alternativa3d::_canvas = new BitmapData(this.alternativa3d::_width,this.alternativa3d::_height,this.backgroundAlpha < 1,this.backgroundColor);
         this.container.bitmapData = this.alternativa3d::_canvas;
         this.container.smoothing = true;
      }
      
      private function onAddToStage(param1:Event) : void
      {
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
      }
      
      private function onRemoveFromStage(param1:Event) : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         this.altKey = false;
         this.ctrlKey = false;
         this.shiftKey = false;
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         this.altKey = param1.altKey;
         this.ctrlKey = param1.ctrlKey;
         this.shiftKey = param1.shiftKey;
         if(this.ctrlKey && this.shiftKey && param1.keyCode == Keyboard.F1 && this.bitmap == null)
         {
            this.bitmap = new Bitmap(Logo.image);
            this.bitmap.x = Math.round((this.alternativa3d::_width - this.bitmap.width) / 2);
            this.bitmap.y = Math.round((this.alternativa3d::_height - this.bitmap.height) / 2);
            super.addChild(this.bitmap);
            setTimeout(this.removeBitmap,2048);
         }
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         this.altKey = param1.altKey;
         this.ctrlKey = param1.ctrlKey;
         this.shiftKey = param1.shiftKey;
      }
      
      private function removeBitmap() : void
      {
         if(this.bitmap != null)
         {
            super.removeChild(this.bitmap);
            this.bitmap = null;
         }
      }
      
      alternativa3d function calculateRays(param1:Camera3D, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean) : void
      {
         var _loc7_:int = 0;
         var _loc8_:MouseEvent = null;
         var _loc12_:Boolean = false;
         var _loc13_:Vector3D = null;
         var _loc14_:Vector3D = null;
         var _loc15_:Point = null;
         if(param2 && this.lastEvent != null)
         {
            _loc12_ = false;
            _loc7_ = 0;
            while(_loc7_ < this.eventsLength)
            {
               _loc8_ = this.events[_loc7_];
               if(_loc8_.type == "mouseMove" || _loc8_.type == "mouseOut")
               {
                  _loc12_ = true;
                  break;
               }
               _loc7_++;
            }
            if(!_loc12_)
            {
               renderEvent.localX = this.lastEvent.localX;
               renderEvent.localY = this.lastEvent.localY;
               renderEvent.ctrlKey = this.ctrlKey;
               renderEvent.altKey = this.altKey;
               renderEvent.shiftKey = this.shiftKey;
               renderEvent.buttonDown = this.lastEvent.buttonDown;
               renderEvent.delta = 0;
               this.events[this.eventsLength] = renderEvent;
               ++this.eventsLength;
            }
         }
         if(!param2)
         {
            this.overedTarget = null;
            this.overedTargetSurface = null;
         }
         if(!param3)
         {
            this.pressedTarget = null;
            this.clickedTarget = null;
         }
         if(!param5)
         {
            this.pressedMiddleTarget = null;
         }
         param6 &&= this._rightClick3DEnabled;
         if(!param6)
         {
            this.pressedRightTarget = null;
         }
         var _loc9_:Number = 1e+22;
         var _loc10_:Number = 1e+22;
         var _loc11_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < this.eventsLength)
         {
            _loc8_ = this.events[_loc7_];
            if(!(!param2 && (_loc8_.type == MouseEvent.MOUSE_MOVE || _loc8_.type == MouseEvent.MOUSE_OVER || _loc8_.type == MouseEvent.MOUSE_OUT)))
            {
               if(!(!param3 && (_loc8_.type == MouseEvent.MOUSE_DOWN || _loc8_.type == MouseEvent.CLICK || _loc8_.type == MouseEvent.DOUBLE_CLICK)))
               {
                  if(!(!param4 && _loc8_.type == MouseEvent.MOUSE_WHEEL))
                  {
                     if(!(!param5 && (_loc8_.type == "middleMouseDown" || _loc8_.type == "middleClick")))
                     {
                        if(!(!param6 && (_loc8_.type == "rightMouseDown" || _loc8_.type == "rightClick")))
                        {
                           if(_loc8_.type != "mouseOut")
                           {
                              if(_loc8_.localX != _loc9_ || _loc8_.localY != _loc10_)
                              {
                                 _loc9_ = _loc8_.localX;
                                 _loc10_ = _loc8_.localY;
                                 if(this.alternativa3d::raysLength < this.alternativa3d::raysOrigins.length)
                                 {
                                    _loc13_ = this.alternativa3d::raysOrigins[this.alternativa3d::raysLength];
                                    _loc14_ = this.alternativa3d::raysDirections[this.alternativa3d::raysLength];
                                    _loc15_ = this.raysCoefficients[this.alternativa3d::raysLength];
                                 }
                                 else
                                 {
                                    _loc13_ = new Vector3D();
                                    _loc14_ = new Vector3D();
                                    _loc15_ = new Point();
                                    this.alternativa3d::raysOrigins[this.alternativa3d::raysLength] = _loc13_;
                                    this.alternativa3d::raysDirections[this.alternativa3d::raysLength] = _loc14_;
                                    this.raysCoefficients[this.alternativa3d::raysLength] = _loc15_;
                                    this.raysSurfaces[this.alternativa3d::raysLength] = new Vector.<Surface>();
                                    this.raysDepths[this.alternativa3d::raysLength] = new Vector.<Number>();
                                 }
                                 if(!param1.orthographic)
                                 {
                                    _loc14_.x = _loc9_ - this.alternativa3d::_width * 0.5;
                                    _loc14_.y = _loc10_ - this.alternativa3d::_height * 0.5;
                                    _loc14_.z = param1.alternativa3d::focalLength;
                                    _loc13_.x = _loc14_.x * param1.nearClipping / param1.alternativa3d::focalLength;
                                    _loc13_.y = _loc14_.y * param1.nearClipping / param1.alternativa3d::focalLength;
                                    _loc13_.z = param1.nearClipping;
                                    _loc14_.normalize();
                                    _loc15_.x = _loc9_ * 2 / this.alternativa3d::_width;
                                    _loc15_.y = _loc10_ * 2 / this.alternativa3d::_height;
                                 }
                                 else
                                 {
                                    _loc14_.x = 0;
                                    _loc14_.y = 0;
                                    _loc14_.z = 1;
                                    _loc13_.x = _loc9_ - this.alternativa3d::_width * 0.5;
                                    _loc13_.y = _loc10_ - this.alternativa3d::_height * 0.5;
                                    _loc13_.z = param1.nearClipping;
                                    _loc15_.x = _loc9_ * 2 / this.alternativa3d::_width;
                                    _loc15_.y = _loc10_ * 2 / this.alternativa3d::_height;
                                 }
                                 ++this.alternativa3d::raysLength;
                              }
                              this.indices[_loc11_] = this.alternativa3d::raysLength - 1;
                           }
                           else
                           {
                              this.indices[_loc11_] = -1;
                           }
                           this.events[_loc11_] = _loc8_;
                           _loc11_++;
                        }
                     }
                  }
               }
            }
            _loc7_++;
         }
         this.eventsLength = _loc11_;
      }
      
      alternativa3d function addSurfaceToMouseEvents(param1:Surface, param2:Geometry, param3:Procedure) : void
      {
         this.surfaces[this.surfacesLength] = param1;
         this.geometries[this.surfacesLength] = param2;
         this.procedures[this.surfacesLength] = param3;
         ++this.surfacesLength;
      }
      
      alternativa3d function configureContext3D(param1:Stage3D, param2:Context3D, param3:Camera3D) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:DisplayObject = null;
         var _loc7_:Point = null;
         var _loc8_:Geometry = null;
         var _loc9_:Linker = null;
         var _loc10_:Linker = null;
         var _loc11_:ShaderProgram = null;
         if(this.alternativa3d::_canvas == null)
         {
            _loc5_ = this.visible;
            _loc6_ = this.parent;
            while(_loc6_ != null)
            {
               _loc5_ &&= _loc6_.visible;
               _loc6_ = _loc6_.parent;
            }
            point.x = 0;
            point.y = 0;
            _loc7_ = localToGlobal(point);
            param1.x = _loc7_.x;
            param1.y = _loc7_.y;
            param1.visible = _loc5_;
         }
         else
         {
            param1.visible = false;
            if(this.alternativa3d::_width != this.alternativa3d::_canvas.width || this.alternativa3d::_height != this.alternativa3d::_canvas.height || this.backgroundAlpha < 1 != this.alternativa3d::_canvas.transparent)
            {
               this.alternativa3d::_canvas.dispose();
               this.createRenderBitmap();
            }
         }
         var _loc4_:RendererContext3DProperties = param3.alternativa3d::context3DProperties;
         if(_loc4_.drawRectGeometry == null)
         {
            _loc8_ = new Geometry(4);
            _loc8_.addVertexStream([VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.TEXCOORDS[0],VertexAttributes.TEXCOORDS[0]]);
            _loc8_.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>([0,0,1,0,1,1,1,1,1,1,0,1]));
            _loc8_.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc8_.indices = Vector.<uint>([0,1,3,2,3,1]);
            _loc8_.upload(param2);
            _loc9_ = new Linker(Context3DProgramType.VERTEX);
            _loc9_.addProcedure(Procedure.compileFromArray(["#a0=a0","#c0=c0","mul t0.x, a0.x, c0.x","mul t0.y, a0.y, c0.y","add o0.x, t0.x, c0.z","add o0.y, t0.y, c0.w","mov o0.z, a0.z","mov o0.w, a0.z"]));
            _loc10_ = new Linker(Context3DProgramType.FRAGMENT);
            _loc10_.addProcedure(Procedure.compileFromArray(["#c0=c0","mov o0, c0"]));
            _loc11_ = new ShaderProgram(_loc9_,_loc10_);
            _loc11_.upload(param2);
            _loc4_.drawRectGeometry = _loc8_;
            _loc4_.drawColoredRectProgram = _loc11_;
         }
         if(this.alternativa3d::_width != _loc4_.backBufferWidth || this.alternativa3d::_height != _loc4_.backBufferHeight || this.antiAlias != _loc4_.backBufferAntiAlias)
         {
            _loc4_.backBufferWidth = this.alternativa3d::_width;
            _loc4_.backBufferHeight = this.alternativa3d::_height;
            _loc4_.backBufferAntiAlias = this.antiAlias;
            param2.configureBackBuffer(this.alternativa3d::_width,this.alternativa3d::_height,this.antiAlias);
         }
      }
      
      alternativa3d function processMouseEvents(param1:Context3D, param2:Camera3D) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Vector.<Surface> = null;
         var _loc5_:Vector.<Number> = null;
         var _loc6_:int = 0;
         var _loc7_:MouseEvent = null;
         var _loc8_:int = 0;
         if(this.eventsLength > 0)
         {
            if(this.surfacesLength > 0)
            {
               this.calculateSurfacesDepths(param1,param2,this.alternativa3d::_width,this.alternativa3d::_height);
               _loc3_ = 0;
               while(_loc3_ < this.alternativa3d::raysLength)
               {
                  _loc4_ = this.raysSurfaces[_loc3_];
                  _loc5_ = this.raysDepths[_loc3_];
                  _loc6_ = int(_loc4_.length);
                  if(_loc6_ > 1)
                  {
                     this.sort(_loc4_,_loc5_,_loc6_);
                  }
                  _loc3_++;
               }
            }
            this.targetDepth = param2.farClipping;
            _loc3_ = 0;
            while(_loc3_ < this.eventsLength)
            {
               _loc7_ = this.events[_loc3_];
               _loc8_ = this.indices[_loc3_];
               switch(_loc7_.type)
               {
                  case "mouseDown":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MOUSE_DOWN,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                     }
                     this.pressedTarget = this.target;
                     break;
                  case "click":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MOUSE_UP,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        if(this.pressedTarget == this.target)
                        {
                           this.clickedTarget = this.target;
                           this.propagateEvent(MouseEvent3D.CLICK,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        }
                     }
                     this.pressedTarget = null;
                     break;
                  case "doubleClick":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MOUSE_UP,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        if(this.pressedTarget == this.target)
                        {
                           this.propagateEvent(this.clickedTarget == this.target && this.target.doubleClickEnabled ? MouseEvent3D.DOUBLE_CLICK : MouseEvent3D.CLICK,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        }
                     }
                     this.clickedTarget = null;
                     this.pressedTarget = null;
                     break;
                  case "middleMouseDown":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MIDDLE_MOUSE_DOWN,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                     }
                     this.pressedMiddleTarget = this.target;
                     break;
                  case "middleClick":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MIDDLE_MOUSE_UP,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        if(this.pressedMiddleTarget == this.target)
                        {
                           this.propagateEvent(MouseEvent3D.MIDDLE_CLICK,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        }
                     }
                     this.pressedMiddleTarget = null;
                     break;
                  case "rightMouseDown":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.RIGHT_MOUSE_DOWN,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                     }
                     this.pressedRightTarget = this.target;
                     break;
                  case "rightClick":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.RIGHT_MOUSE_UP,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        if(this.pressedRightTarget == this.target)
                        {
                           this.propagateEvent(MouseEvent3D.RIGHT_CLICK,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                        }
                     }
                     this.pressedRightTarget = null;
                     break;
                  case "mouseMove":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MOUSE_MOVE,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                     }
                     if(this.overedTarget != this.target)
                     {
                        this.processOverOut(_loc7_,param2);
                     }
                     break;
                  case "mouseWheel":
                     this.defineTarget(_loc8_);
                     if(this.target != null)
                     {
                        this.propagateEvent(MouseEvent3D.MOUSE_WHEEL,_loc7_,param2,this.target,this.targetSurface,this.branchToVector(this.target,branch));
                     }
                     break;
                  case "mouseOut":
                     this.lastEvent = null;
                     this.target = null;
                     this.targetSurface = null;
                     if(this.overedTarget != this.target)
                     {
                        this.processOverOut(_loc7_,param2);
                     }
                     break;
                  case "render":
                     this.defineTarget(_loc8_);
                     if(this.overedTarget != this.target)
                     {
                        this.processOverOut(_loc7_,param2);
                     }
               }
               this.target = null;
               this.targetSurface = null;
               this.targetDepth = param2.farClipping;
               _loc3_++;
            }
         }
         this.surfaces.length = 0;
         this.surfacesLength = 0;
         this.events.length = 0;
         this.eventsLength = 0;
         _loc3_ = 0;
         while(_loc3_ < this.alternativa3d::raysLength)
         {
            this.raysSurfaces[_loc3_].length = 0;
            this.raysDepths[_loc3_].length = 0;
            _loc3_++;
         }
         this.alternativa3d::raysLength = 0;
      }
      
      private function calculateSurfacesDepths(param1:Context3D, param2:Camera3D, param3:int, param4:int) : void
      {
         var _loc7_:Linker = null;
         var _loc8_:Linker = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc21_:Point = null;
         var _loc22_:BitmapData = null;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:* = 0;
         var _loc26_:* = 0;
         var _loc27_:* = 0;
         var _loc28_:int = 0;
         var _loc29_:Vector.<Surface> = null;
         var _loc30_:Vector.<Number> = null;
         param1.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
         param1.setCulling(Context3DTriangleFace.FRONT);
         param1.setTextureAt(0,null);
         param1.setTextureAt(1,null);
         param1.setTextureAt(2,null);
         param1.setTextureAt(3,null);
         param1.setTextureAt(4,null);
         param1.setTextureAt(5,null);
         param1.setTextureAt(6,null);
         param1.setTextureAt(7,null);
         param1.setVertexBufferAt(0,null);
         param1.setVertexBufferAt(1,null);
         param1.setVertexBufferAt(2,null);
         param1.setVertexBufferAt(3,null);
         param1.setVertexBufferAt(4,null);
         param1.setVertexBufferAt(5,null);
         param1.setVertexBufferAt(6,null);
         param1.setVertexBufferAt(7,null);
         var _loc5_:Geometry = param2.alternativa3d::context3DProperties.drawRectGeometry;
         var _loc6_:ShaderProgram = param2.alternativa3d::context3DProperties.drawColoredRectProgram;
         var _loc9_:Number = param2.alternativa3d::m0;
         var _loc10_:Number = param2.alternativa3d::m5;
         var _loc11_:Number = param2.alternativa3d::m10;
         var _loc12_:Number = param2.alternativa3d::m14;
         var _loc13_:Number = 255 / param2.farClipping;
         var _loc14_:Number = 1 / 255;
         var _loc17_:int = 0;
         _loc15_ = 0;
         while(_loc15_ < this.alternativa3d::raysLength)
         {
            _loc21_ = this.raysCoefficients[_loc15_];
            _loc16_ = 0;
            while(_loc16_ < this.surfacesLength)
            {
               if(_loc17_ == 0)
               {
                  drawColoredRectConst[0] = this.alternativa3d::raysLength * this.surfacesLength * 2 / param3;
                  drawColoredRectConst[1] = -2 / param4;
                  param1.setDepthTest(false,Context3DCompareMode.ALWAYS);
                  param1.setProgram(_loc6_.program);
                  param1.setVertexBufferAt(0,_loc5_.alternativa3d::getVertexBuffer(VertexAttributes.POSITION),_loc5_.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
                  param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,drawColoredRectConst);
                  drawRectColor[0] = 0;
                  drawRectColor[1] = 0;
                  drawRectColor[2] = 1;
                  drawRectColor[3] = 1;
                  param1.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,drawRectColor);
                  param1.drawTriangles(_loc5_.alternativa3d::_indexBuffer,0,2);
                  param1.setVertexBufferAt(0,null);
                  param1.setDepthTest(true,Context3DCompareMode.LESS);
               }
               scissor.x = _loc17_;
               param1.setScissorRectangle(scissor);
               this.drawSurface(param1,param2,_loc16_,_loc9_,_loc10_,_loc11_,_loc12_,_loc17_ * 2 / param3 - _loc21_.x,_loc21_.y,_loc13_,_loc14_,param2.orthographic);
               this.raysIs[_loc17_] = _loc15_;
               this.raysJs[_loc17_] = _loc16_;
               if(++_loc17_ >= param3 || _loc15_ >= this.alternativa3d::raysLength - 1 && _loc16_ >= this.surfacesLength - 1)
               {
                  _loc22_ = pixels[_loc17_];
                  if(_loc22_ == null)
                  {
                     _loc22_ = new BitmapData(_loc17_,1,false,255);
                     pixels[_loc17_] = _loc22_;
                  }
                  param1.drawToBitmapData(_loc22_);
                  _loc23_ = 0;
                  while(_loc23_ < _loc17_)
                  {
                     _loc24_ = int(_loc22_.getPixel(_loc23_,0));
                     _loc25_ = _loc24_ >> 16 & 0xFF;
                     _loc26_ = _loc24_ >> 8 & 0xFF;
                     _loc27_ = _loc24_ & 0xFF;
                     if(_loc27_ == 0)
                     {
                        _loc28_ = this.raysIs[_loc23_];
                        _loc29_ = this.raysSurfaces[_loc28_];
                        _loc30_ = this.raysDepths[_loc28_];
                        _loc28_ = this.raysJs[_loc23_];
                        _loc29_.push(this.surfaces[_loc28_]);
                        _loc30_.push((_loc25_ + _loc26_ / 255) / _loc13_);
                     }
                     _loc23_++;
                  }
                  _loc17_ = 0;
               }
               _loc16_++;
            }
            _loc15_++;
         }
         param1.setScissorRectangle(null);
         param1.setDepthTest(true,Context3DCompareMode.ALWAYS);
         param1.setProgram(_loc6_.program);
         param1.setVertexBufferAt(0,_loc5_.alternativa3d::getVertexBuffer(VertexAttributes.POSITION),_loc5_.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
         drawColoredRectConst[0] = this.alternativa3d::raysLength * this.surfacesLength * 2 / param3;
         drawColoredRectConst[1] = -2 / param4;
         param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,drawColoredRectConst);
         var _loc18_:Number = (this.backgroundColor >> 16 & 0xFF) / 255;
         var _loc19_:Number = (this.backgroundColor >> 8 & 0xFF) / 255;
         var _loc20_:Number = (this.backgroundColor & 0xFF) / 255;
         if(this.canvas != null)
         {
            drawRectColor[0] = this.backgroundAlpha * _loc18_;
            drawRectColor[1] = this.backgroundAlpha * _loc19_;
            drawRectColor[2] = this.backgroundAlpha * _loc20_;
         }
         else
         {
            drawRectColor[0] = _loc18_;
            drawRectColor[1] = _loc19_;
            drawRectColor[2] = _loc20_;
         }
         drawRectColor[3] = this.backgroundAlpha;
         param1.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,drawRectColor);
         param1.drawTriangles(_loc5_.alternativa3d::_indexBuffer,0,2);
         param1.setVertexBufferAt(0,null);
      }
      
      private function drawSurface(param1:Context3D, param2:Camera3D, param3:int, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number, param10:Number, param11:Number, param12:Boolean) : void
      {
         var _loc19_:int = 0;
         var _loc20_:Linker = null;
         var _loc21_:String = null;
         var _loc13_:Surface = this.surfaces[param3];
         var _loc14_:Geometry = this.geometries[param3];
         var _loc15_:Procedure = this.procedures[param3];
         var _loc16_:Object3D = _loc13_.alternativa3d::object;
         var _loc17_:ShaderProgram = param2.alternativa3d::context3DProperties.drawDistancePrograms[_loc15_];
         if(_loc17_ == null)
         {
            _loc20_ = new Linker(Context3DProgramType.VERTEX);
            _loc21_ = "position";
            _loc20_.declareVariable(_loc21_,VariableType.ATTRIBUTE);
            if(_loc15_ != null)
            {
               _loc20_.addProcedure(_loc15_);
               _loc20_.declareVariable("localPosition",VariableType.TEMPORARY);
               _loc20_.setInputParams(_loc15_,_loc21_);
               _loc20_.setOutputParams(_loc15_,"localPosition");
               _loc21_ = "localPosition";
            }
            _loc20_.addProcedure(drawDistanceVertexProcedure);
            _loc20_.setInputParams(drawDistanceVertexProcedure,_loc21_);
            _loc17_ = new ShaderProgram(_loc20_,drawDistanceFragment);
            _loc17_.fragmentShader.varyings = _loc17_.vertexShader.varyings;
            _loc17_.upload(param1);
            param2.alternativa3d::context3DProperties.drawDistancePrograms[_loc15_] = _loc17_;
         }
         var _loc18_:VertexBuffer3D = _loc14_.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         if(_loc18_ == null)
         {
            return;
         }
         drawUnit.alternativa3d::vertexBuffersLength = 0;
         drawUnit.alternativa3d::vertexConstantsRegistersCount = 0;
         drawUnit.alternativa3d::fragmentConstantsRegistersCount = 0;
         _loc16_.alternativa3d::setTransformConstants(drawUnit,_loc13_,_loc17_.vertexShader,param2);
         drawUnit.alternativa3d::setVertexConstantsFromTransform(_loc17_.vertexShader.getVariableIndex("transform0"),_loc16_.alternativa3d::localToCameraTransform);
         drawUnit.alternativa3d::setVertexConstantsFromNumbers(_loc17_.vertexShader.getVariableIndex("coefficient"),param8,param9,param10,param12 ? 1 : 0);
         drawUnit.alternativa3d::setVertexConstantsFromNumbers(_loc17_.vertexShader.getVariableIndex("projection"),param4,param5,param6,param7);
         drawUnit.alternativa3d::setFragmentConstantsFromNumbers(_loc17_.fragmentShader.getVariableIndex("code"),param11,0,0,1);
         param1.setProgram(_loc17_.program);
         param1.setVertexBufferAt(0,_loc18_,_loc14_.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
         _loc19_ = 0;
         while(_loc19_ < drawUnit.alternativa3d::vertexBuffersLength)
         {
            param1.setVertexBufferAt(drawUnit.alternativa3d::vertexBuffersIndexes[_loc19_],drawUnit.alternativa3d::vertexBuffers[_loc19_],drawUnit.alternativa3d::vertexBuffersOffsets[_loc19_],drawUnit.alternativa3d::vertexBuffersFormats[_loc19_]);
            _loc19_++;
         }
         param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,drawUnit.alternativa3d::vertexConstants,drawUnit.alternativa3d::vertexConstantsRegistersCount);
         param1.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,drawUnit.alternativa3d::fragmentConstants,drawUnit.alternativa3d::fragmentConstantsRegistersCount);
         param1.drawTriangles(_loc14_.alternativa3d::_indexBuffer,_loc13_.indexBegin,_loc13_.numTriangles);
         param1.setVertexBufferAt(0,null);
         _loc19_ = 0;
         while(_loc19_ < drawUnit.alternativa3d::vertexBuffersLength)
         {
            param1.setVertexBufferAt(drawUnit.alternativa3d::vertexBuffersIndexes[_loc19_],null);
            _loc19_++;
         }
      }
      
      private function sort(param1:Vector.<Surface>, param2:Vector.<Number>, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Surface = null;
         stack[0] = 0;
         stack[1] = param3 - 1;
         var _loc4_:int = 2;
         while(_loc4_ > 0)
         {
            _loc4_--;
            _loc6_ = _loc5_ = stack[_loc4_];
            _loc4_--;
            _loc8_ = _loc7_ = stack[_loc4_];
            _loc9_ = param2[_loc5_ + _loc7_ >> 1];
            while(_loc8_ <= _loc6_)
            {
               _loc10_ = param2[_loc8_];
               while(_loc10_ > _loc9_)
               {
                  _loc8_++;
                  _loc10_ = param2[_loc8_];
               }
               _loc11_ = param2[_loc6_];
               while(_loc11_ < _loc9_)
               {
                  _loc6_--;
                  _loc11_ = param2[_loc6_];
               }
               if(_loc8_ <= _loc6_)
               {
                  param2[_loc8_] = _loc11_;
                  param2[_loc6_] = _loc10_;
                  _loc12_ = param1[_loc8_];
                  param1[_loc8_] = param1[_loc6_];
                  param1[_loc6_] = _loc12_;
                  _loc8_++;
                  _loc6_--;
               }
            }
            if(_loc7_ < _loc6_)
            {
               stack[_loc4_] = _loc7_;
               _loc4_++;
               stack[_loc4_] = _loc6_;
               _loc4_++;
            }
            if(_loc8_ < _loc5_)
            {
               stack[_loc4_] = _loc8_;
               _loc4_++;
               stack[_loc4_] = _loc5_;
               _loc4_++;
            }
         }
      }
      
      private function processOverOut(param1:MouseEvent, param2:Camera3D) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Object3D = null;
         this.branchToVector(this.target,branch);
         this.branchToVector(this.overedTarget,overedBranch);
         var _loc3_:int = int(branch.length);
         var _loc4_:int = int(overedBranch.length);
         if(this.overedTarget != null)
         {
            this.propagateEvent(MouseEvent3D.MOUSE_OUT,param1,param2,this.overedTarget,this.overedTargetSurface,overedBranch,true,this.target);
            _loc5_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc8_ = overedBranch[_loc6_];
               _loc7_ = 0;
               while(_loc7_ < _loc3_)
               {
                  if(_loc8_ == branch[_loc7_])
                  {
                     break;
                  }
                  _loc7_++;
               }
               if(_loc7_ == _loc3_)
               {
                  changedBranch[_loc5_] = _loc8_;
                  _loc5_++;
               }
               _loc6_++;
            }
            if(_loc5_ > 0)
            {
               changedBranch.length = _loc5_;
               this.propagateEvent(MouseEvent3D.ROLL_OUT,param1,param2,this.overedTarget,this.overedTargetSurface,changedBranch,false,this.target);
            }
         }
         if(this.target != null)
         {
            _loc5_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               _loc8_ = branch[_loc6_];
               _loc7_ = 0;
               while(_loc7_ < _loc4_)
               {
                  if(_loc8_ == overedBranch[_loc7_])
                  {
                     break;
                  }
                  _loc7_++;
               }
               if(_loc7_ == _loc4_)
               {
                  changedBranch[_loc5_] = _loc8_;
                  _loc5_++;
               }
               _loc6_++;
            }
            if(_loc5_ > 0)
            {
               changedBranch.length = _loc5_;
               this.propagateEvent(MouseEvent3D.ROLL_OVER,param1,param2,this.target,this.targetSurface,changedBranch,false,this.overedTarget);
            }
            this.propagateEvent(MouseEvent3D.MOUSE_OVER,param1,param2,this.target,this.targetSurface,branch,true,this.overedTarget);
            useHandCursor = this.target.useHandCursor;
         }
         else
         {
            useHandCursor = false;
         }
         Mouse.cursor = Mouse.cursor;
         this.overedTarget = this.target;
         this.overedTargetSurface = this.targetSurface;
      }
      
      private function branchToVector(param1:Object3D, param2:Vector.<Object3D>) : Vector.<Object3D>
      {
         var _loc3_:int = 0;
         while(param1 != null)
         {
            param2[_loc3_] = param1;
            _loc3_++;
            param1 = param1.alternativa3d::_parent;
         }
         param2.length = _loc3_;
         return param2;
      }
      
      private function propagateEvent(param1:String, param2:MouseEvent, param3:Camera3D, param4:Object3D, param5:Surface, param6:Vector.<Object3D>, param7:Boolean = true, param8:Object3D = null) : void
      {
         var _loc10_:Object3D = null;
         var _loc11_:Vector.<Function> = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:MouseEvent3D = null;
         var _loc9_:int = int(param6.length);
         _loc13_ = _loc9_ - 1;
         while(_loc13_ > 0)
         {
            _loc10_ = param6[_loc13_];
            if(_loc10_.alternativa3d::captureListeners != null)
            {
               _loc11_ = _loc10_.alternativa3d::captureListeners[param1];
               if(_loc11_ != null)
               {
                  if(_loc15_ == null)
                  {
                     this.calculateLocalCoords(param3,param4.alternativa3d::cameraToLocalTransform,this.targetDepth,param2);
                     _loc15_ = new MouseEvent3D(param1,param7,localCoords.x,localCoords.y,localCoords.z,param8,param2.ctrlKey,param2.altKey,param2.shiftKey,param2.buttonDown,param2.delta);
                     _loc15_.alternativa3d::_target = param4;
                     _loc15_.alternativa3d::_surface = param5;
                  }
                  _loc15_.alternativa3d::_currentTarget = _loc10_;
                  _loc15_.alternativa3d::_eventPhase = 1;
                  _loc12_ = int(_loc11_.length);
                  _loc14_ = 0;
                  while(_loc14_ < _loc12_)
                  {
                     functions[_loc14_] = _loc11_[_loc14_];
                     _loc14_++;
                  }
                  _loc14_ = 0;
                  while(_loc14_ < _loc12_)
                  {
                     (functions[_loc14_] as Function).call(null,_loc15_);
                     if(_loc15_.alternativa3d::stopImmediate)
                     {
                        return;
                     }
                     _loc14_++;
                  }
                  if(_loc15_.alternativa3d::stop)
                  {
                     return;
                  }
               }
            }
            _loc13_--;
         }
         _loc13_ = 0;
         while(_loc13_ < _loc9_)
         {
            _loc10_ = param6[_loc13_];
            if(_loc10_.alternativa3d::bubbleListeners != null)
            {
               _loc11_ = _loc10_.alternativa3d::bubbleListeners[param1];
               if(_loc11_ != null)
               {
                  if(_loc15_ == null)
                  {
                     this.calculateLocalCoords(param3,param4.alternativa3d::cameraToLocalTransform,this.targetDepth,param2);
                     _loc15_ = new MouseEvent3D(param1,param7,localCoords.x,localCoords.y,localCoords.z,param8,param2.ctrlKey,param2.altKey,param2.shiftKey,param2.buttonDown,param2.delta);
                     _loc15_.alternativa3d::_target = param4;
                     _loc15_.alternativa3d::_surface = param5;
                  }
                  _loc15_.alternativa3d::_currentTarget = _loc10_;
                  _loc15_.alternativa3d::_eventPhase = _loc13_ == 0 ? 2 : 3;
                  _loc12_ = int(_loc11_.length);
                  _loc14_ = 0;
                  while(_loc14_ < _loc12_)
                  {
                     functions[_loc14_] = _loc11_[_loc14_];
                     _loc14_++;
                  }
                  _loc14_ = 0;
                  while(_loc14_ < _loc12_)
                  {
                     (functions[_loc14_] as Function).call(null,_loc15_);
                     if(_loc15_.alternativa3d::stopImmediate)
                     {
                        return;
                     }
                     _loc14_++;
                  }
                  if(_loc15_.alternativa3d::stop)
                  {
                     return;
                  }
               }
            }
            _loc13_++;
         }
      }
      
      private function calculateLocalCoords(param1:Camera3D, param2:Transform3D, param3:Number, param4:MouseEvent) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!param1.orthographic)
         {
            _loc5_ = param3 * (param4.localX - this.alternativa3d::_width * 0.5) / param1.alternativa3d::focalLength;
            _loc6_ = param3 * (param4.localY - this.alternativa3d::_height * 0.5) / param1.alternativa3d::focalLength;
         }
         else
         {
            _loc5_ = param4.localX - this.alternativa3d::_width * 0.5;
            _loc6_ = param4.localY - this.alternativa3d::_height * 0.5;
         }
         localCoords.x = param2.a * _loc5_ + param2.b * _loc6_ + param2.c * param3 + param2.d;
         localCoords.y = param2.e * _loc5_ + param2.f * _loc6_ + param2.g * param3 + param2.h;
         localCoords.z = param2.i * _loc5_ + param2.j * _loc6_ + param2.k * param3 + param2.l;
      }
      
      private function defineTarget(param1:int) : void
      {
         var _loc2_:Object3D = null;
         var _loc6_:Surface = null;
         var _loc7_:Number = NaN;
         var _loc8_:Object3D = null;
         var _loc9_:Object3D = null;
         var _loc10_:Object3D = null;
         var _loc3_:Vector.<Surface> = this.raysSurfaces[param1];
         var _loc4_:Vector.<Number> = this.raysDepths[param1];
         var _loc5_:int = int(_loc3_.length - 1);
         while(_loc5_ >= 0)
         {
            _loc6_ = _loc3_[_loc5_];
            _loc7_ = _loc4_[_loc5_];
            _loc8_ = _loc6_.alternativa3d::object;
            _loc9_ = null;
            _loc10_ = _loc8_;
            while(_loc10_ != null)
            {
               if(!_loc10_.mouseChildren)
               {
                  _loc9_ = null;
               }
               if(_loc9_ == null && _loc10_.mouseEnabled)
               {
                  _loc9_ = _loc10_;
               }
               _loc10_ = _loc10_.alternativa3d::_parent;
            }
            if(_loc9_ != null)
            {
               if(this.target != null)
               {
                  _loc10_ = _loc9_;
                  while(_loc10_ != null)
                  {
                     if(_loc10_ == this.target)
                     {
                        _loc2_ = _loc8_;
                        if(this.target != _loc9_)
                        {
                           this.target = _loc9_;
                           this.targetSurface = _loc6_;
                           this.targetDepth = _loc7_;
                        }
                        break;
                     }
                     _loc10_ = _loc10_.alternativa3d::_parent;
                  }
               }
               else
               {
                  _loc2_ = _loc8_;
                  this.target = _loc9_;
                  this.targetSurface = _loc6_;
                  this.targetDepth = _loc7_;
               }
               if(_loc2_ == this.target)
               {
                  break;
               }
            }
            _loc5_--;
         }
      }
      
      public function get renderToBitmap() : Boolean
      {
         return this.alternativa3d::_canvas != null;
      }
      
      public function set renderToBitmap(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.alternativa3d::_canvas == null)
            {
               this.createRenderBitmap();
            }
         }
         else if(this.alternativa3d::_canvas != null)
         {
            this.container.bitmapData = null;
            this.alternativa3d::_canvas.dispose();
            this.alternativa3d::_canvas = null;
         }
      }
      
      public function get canvas() : BitmapData
      {
         return this.alternativa3d::_canvas;
      }
      
      public function showLogo() : void
      {
         if(this.logo == null)
         {
            this.logo = new Logo();
            super.addChild(this.logo);
            this.resizeLogo();
         }
      }
      
      public function hideLogo() : void
      {
         if(this.logo != null)
         {
            super.removeChild(this.logo);
            this.logo = null;
         }
      }
      
      public function get logoAlign() : String
      {
         return this._logoAlign;
      }
      
      public function set logoAlign(param1:String) : void
      {
         this._logoAlign = param1;
         this.resizeLogo();
      }
      
      public function get logoHorizontalMargin() : Number
      {
         return this._logoHorizontalMargin;
      }
      
      public function set logoHorizontalMargin(param1:Number) : void
      {
         this._logoHorizontalMargin = param1;
         this.resizeLogo();
      }
      
      public function get logoVerticalMargin() : Number
      {
         return this._logoVerticalMargin;
      }
      
      public function set logoVerticalMargin(param1:Number) : void
      {
         this._logoVerticalMargin = param1;
         this.resizeLogo();
      }
      
      private function resizeLogo() : void
      {
         if(this.logo != null)
         {
            if(this._logoAlign == StageAlign.TOP_LEFT || this._logoAlign == StageAlign.LEFT || this._logoAlign == StageAlign.BOTTOM_LEFT)
            {
               this.logo.x = Math.round(this._logoHorizontalMargin);
            }
            if(this._logoAlign == StageAlign.TOP || this._logoAlign == StageAlign.BOTTOM)
            {
               this.logo.x = Math.round((this.alternativa3d::_width - this.logo.width) / 2);
            }
            if(this._logoAlign == StageAlign.TOP_RIGHT || this._logoAlign == StageAlign.RIGHT || this._logoAlign == StageAlign.BOTTOM_RIGHT)
            {
               this.logo.x = Math.round(this.alternativa3d::_width - this._logoHorizontalMargin - this.logo.width);
            }
            if(this._logoAlign == StageAlign.TOP_LEFT || this._logoAlign == StageAlign.TOP || this._logoAlign == StageAlign.TOP_RIGHT)
            {
               this.logo.y = Math.round(this._logoVerticalMargin);
            }
            if(this._logoAlign == StageAlign.LEFT || this._logoAlign == StageAlign.RIGHT)
            {
               this.logo.y = Math.round((this.alternativa3d::_height - this.logo.height) / 2);
            }
            if(this._logoAlign == StageAlign.BOTTOM_LEFT || this._logoAlign == StageAlign.BOTTOM || this._logoAlign == StageAlign.BOTTOM_RIGHT)
            {
               this.logo.y = Math.round(this.alternativa3d::_height - this._logoVerticalMargin - this.logo.height);
            }
         }
      }
      
      override public function get width() : Number
      {
         return this.alternativa3d::_width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 < 50)
         {
            param1 = 50;
         }
         this.alternativa3d::_width = param1;
         this.area.width = param1;
         this.resizeLogo();
      }
      
      override public function get height() : Number
      {
         return this.alternativa3d::_height;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 < 50)
         {
            param1 = 50;
         }
         this.alternativa3d::_height = param1;
         this.area.height = param1;
         this.resizeLogo();
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function removeChildren(param1:int = 0, param2:int = 2147483647) : void
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function swapChildren(param1:DisplayObject, param2:DisplayObject) : void
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function swapChildrenAt(param1:int, param2:int) : void
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function get numChildren() : int
      {
         return 0;
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         throw new Error("Unsupported operation.");
      }
      
      override public function contains(param1:DisplayObject) : Boolean
      {
         throw new Error("Unsupported operation.");
      }
   }
}

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.net.navigateToURL;

class Logo extends Sprite
{
   
   public static const image:BitmapData = createBMP();
   
   private static const normal:ColorTransform = new ColorTransform();
   
   private static const highlighted:ColorTransform = new ColorTransform(1.1,1.1,1.1,1);
   
   private var border:int = 5;
   
   public function Logo()
   {
      super();
      graphics.beginFill(16711680,0);
      graphics.drawRect(0,0,image.width + this.border + this.border,image.height + this.border + this.border);
      graphics.drawRect(this.border,this.border,image.width,image.height);
      graphics.beginBitmapFill(image,new Matrix(1,0,0,1,this.border,this.border),false,true);
      graphics.drawRect(this.border,this.border,image.width,image.height);
      tabEnabled = false;
      buttonMode = true;
      useHandCursor = true;
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      addEventListener(MouseEvent.CLICK,this.onClick);
      addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
      addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseMove);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
   }
   
   private static function createBMP() : BitmapData
   {
      var _loc1_:BitmapData = new BitmapData(165,27,true,0);
      _loc1_.setVector(_loc1_.rect,Vector.<uint>([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,134217728,503316480,721420288,503316480,134217728,134217728,503316480,721420288,503316480,134217728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,100663296,419430400,721420288,788529152,536870912,234881024,50331648,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1677721600,503316480,503316480,1677721600,2348810240,1677721600,503316480,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,67108864,301989888,822083584,1677721600,2365587456
      ,2483027968,1996488704,1241513984,536870912,117440512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16777216,167772160,520093696,822083584,905969664,822083584,520093696,301989888,520093696,822083584,905969664,822083584,620756992,620756992,721420288,620756992,620756992,721420288,620756992,620756992,721420288,620756992,620756992,822083584,905969664,822083584,520093696,218103808,234881024,536870912,721420288,620756992,620756992,822083584,905969664,822083584,520093696,301989888,520093696,822083584,1493172224,2768240640,4292467161,2533359616,822083584,822083584,2533359616,4292467161,2768240640,1493172224,822083584,620756992,620756992,721420288,503316480,268435456,503316480,721420288,503316480,134217728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,134217728,620756992,1392508928,2248146944,3514129719,4192520610,4277921461,3886715221,2905283846,1778384896,788529152,234881024,50331648,0,0,0,0,0,0,0,0
      ,0,0,0,0,0,0,0,167772160,822083584,1845493760,2533359616,2734686208,2533359616,1845493760,1325400064,1845493760,2533359616,2734686208,2533359616,2164260864,2164260864,2348810240,2164260864,2164260864,2348810240,2164260864,2164260864,2348810240,2164260864,2164260864,2533359616,2734686208,2533359616,1845493760,1056964608,1107296256,1895825408,2348810240,2164260864,2164260864,2533359616,2734686208,2533359616,1845493760,1325400064,1845493760,2533359616,2952790016,3730463322,4292467161,2734686208,905969664,905969664,2734686208,4292467161,3730463322,2952790016,2533359616,2164260864,2164260864,2348810240,1677721600,989855744,1677721600,2348810240,1677721600,503316480,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16777216,167772160,754974720,1828716544,3022988562,4022445697,4294959283,4294953296,4294953534,4294961056,4226733479,3463135252,2130706432,1224736768,486539264,83886080,0,0,0,0,0,0,0
      ,0,0,0,0,0,0,0,520093696,1845493760,3665591420,4292467161,4292467161,4292467161,3665591420,2650800128,3665591420,4292467161,4292467161,4292467161,3816191606,3355443200,4292467161,3355443200,3355443200,4292467161,3355443200,3355443200,4292467161,3355443200,3816191606,4292467161,4292467161,4292467161,3665591420,2382364672,2415919104,3801125008,4292467161,3355443200,3816191606,4292467161,4292467161,4292467161,3495911263,2650800128,3665591420,4292467161,4292467161,4292467161,4292467161,2533359616,822083584,822083584,2533359616,4292467161,4292467161,4292467161,4292467161,3816191606,3355443200,4292467161,2533359616,1627389952,2533359616,4292467161,2533359616,822083584,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50331648,251658240,889192448,1962934272,3463338042,4260681651,4294955128,4294949388,4294949120,4294948864,4294948864,4294953816,4294960063,3903219779,2701722370,1627389952,620756992,100663296
      ,0,0,0,0,0,0,0,0,0,0,0,0,0,822083584,2533359616,4292467161,3730463322,3187671040,3730463322,4292467161,3456106496,4292467161,3849680245,3221225472,3849680245,4292467161,3640655872,4292467161,3640655872,3640655872,4292467161,3640655872,3640655872,4292467161,3640655872,4292467161,3966923378,3640655872,3966923378,4292467161,3355443200,3918236555,4292467161,3763951961,3539992576,4292467161,3966923378,3640655872,3966923378,4292467161,3456106496,4292467161,3849680245,3221225472,3422552064,3456106496,2348810240,721420288,721420288,2348810240,3456106496,3422552064,3221225472,3849680245,4292467161,3640655872,4292467161,2734686208,1828716544,2734686208,4292467161,2734686208,905969664,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50331648,318767104,1006632960,2080374784,3683940948,4294958002,4294949951,4294946816,4294946048,4294944256,4294944256,4294945536,4294944512,4294944799,4294954914,4123823487
      ,3056010753,1778384896,671088640,117440512,0,0,0,0,0,0,0,0,0,0,0,0,822083584,2533359616,4292467161,3187671040,2734686208,3187671040,4292467161,3640655872,4292467161,3221225472,2801795072,3221225472,4292467161,3640655872,4292467161,3966923378,3640655872,4292467161,3966923378,3640655872,4292467161,3640655872,4292467161,3640655872,4292467161,4292467161,4292467161,3640655872,4292467161,3613154396,2818572288,3221225472,4292467161,3640655872,4292467161,4292467161,4292467161,3640655872,4292467161,3221225472,2801795072,3221225472,4292467161,2533359616,822083584,822083584,2533359616,4292467161,3221225472,2801795072,3221225472,4292467161,3640655872,4292467161,2952790016,2264924160,2952790016,4292467161,2533359616,822083584,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50331648,318767104,1056964608,2147483648,3819605095,4294955172,4294944795,4294943744,4294941184,4294939392,4294940672,4294940160,4294938624
      ,4294941440,4294940672,4294936323,4294815095,4208955271,3208382211,1845493760,721420288,134217728,0,0,0,0,0,0,0,0,0,0,0,721420288,2348810240,3456106496,3405774848,3187671040,3730463322,4292467161,3456106496,4292467161,3849680245,3221225472,3849680245,4292467161,3355443200,3816191606,4292467161,3966923378,3966923378,4292467161,3966923378,4292467161,3640655872,4292467161,3966923378,3640655872,3640655872,3640655872,3640655872,4292467161,2868903936,1996488704,2684354560,4292467161,3966923378,3640655872,3640655872,3539992576,3456106496,4292467161,3849680245,3221225472,3849680245,4292467161,2533359616,822083584,822083584,2533359616,4292467161,3849680245,3221225472,3849680245,4292467161,3456106496,4292467161,3730463322,3187671040,3405774848,3456106496,2348810240,721420288,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16777216,234881024,989855744,2147483648,3836647021,4294952084,4294939916,4294939392
      ,4294936064,4294935808,4294939907,3970992676,3783616794,4260594952,4294933248,4294937088,4294937088,4294865664,4294676569,4243165579,3292924164,1862270976,721420288,134217728,0,0,0,0,0,0,0,0,0,0,822083584,2533359616,4292467161,4292467161,4292467161,4292467161,3665591420,2650800128,3665591420,4292467161,4292467161,4292467161,3665591420,2348810240,2348810240,3665591420,4292467161,3355443200,3816191606,4292467161,4292467161,3355443200,3816191606,4292467161,4292467161,4292467161,3696908890,3355443200,4292467161,2533359616,1325400064,1845493760,3665591420,4292467161,4292467161,4292467161,3665591420,2650800128,3665591420,4292467161,4292467161,4292467161,3665591420,1845493760,520093696,520093696,1845493760,3665591420,4292467161,4292467161,4292467161,3665591420,2650800128,3665591420,4292467161,4292467161,4292467161,4292467161,2533359616,822083584,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,150994944
      ,855638016,2063597568,3785853032,4294949263,4294935301,4294934528,4294931200,4294865408,4294739211,3598869795,2348810240,2248146944,3157861897,4158024716,4294930432,4294934272,4294934016,4294796032,4294604868,4260400774,3309963524,1862270976,704643072,117440512,0,0,0,0,0,0,0,0,0,905969664,2734686208,4292467161,3730463322,2952790016,2533359616,1845493760,1325400064,1845493760,2533359616,2734686208,2533359616,1845493760,1006632960,1006632960,1845493760,2348810240,2164260864,2164260864,2533359616,2533359616,2164260864,2164260864,2533359616,2734686208,2533359616,2164260864,2164260864,2348810240,1677721600,671088640,822083584,1845493760,2533359616,2734686208,2533359616,1845493760,1325400064,1845493760,2533359616,2734686208,2533359616,1845493760,822083584,167772160,167772160,822083584,1845493760,2533359616,2734686208,2533359616,1845493760,1325400064,1845493760,2533359616,2952790016,3730463322,4292467161,2734686208,905969664,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,117440512,738197504,1962934272,3632951638,4294947982,4294931462,4294930176,4294794752,4294662144,4260327185,3378071325,1946157056,922746880,822083584,1677721600,2785937666,3954400527,4294929408,4294931968,4294931712,4294661120,4294469180,4260200571,3208316675,1795162112,620756992,83886080,0,0,0,0,0,0,0,0,822083584,2533359616,4292467161,2768240640,1493172224,822083584,520093696,301989888,520093696,822083584,905969664,822083584,520093696,184549376,184549376,520093696,721420288,620756992,620756992,822083584,822083584,620756992,620756992,822083584,905969664,822083584,620756992,620756992,721420288,503316480,150994944,167772160,520093696,822083584,905969664,822083584,520093696,301989888,520093696,822083584,905969664,822083584,520093696,167772160,16777216,16777216,167772160,520093696,822083584,905969664,822083584,520093696,301989888,520093696,822083584,1493172224,2768240640,4292467161,2533359616,822083584,0,0,0,0,0,0,0,0,0,0
      ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,67108864,620756992,1811939328,3429059385,4294882972,4294796301,4294727936,4294526208,4294325760,4226241553,3242276118,1862270976,738197504,150994944,100663296,520093696,1325400064,2264924160,3768667144,4294928385,4294929408,4294796800,4294460416,4294335293,4225986666,3055813377,1644167168,503316480,50331648,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1677721600,503316480,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1677721600,503316480,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16777216,335544320,1459617792,3005750036,4243500445,4294661403,4294524672,4294258432,4294121728,4259985678,3259118102,1845493760,704643072,134217728,0,0,50331648,335544320,1006632960,2080374784,3751757574,4294794241,4294794240
      ,4294592771,4294323463,4294400588,4123811671,2769158144,1275068416,251658240,0,0,0,0,0,0,0,134217728,503316480,721420288,503316480,134217728,0,0,0,0,134217728,503316480,721420288,503316480,268435456,503316480,721420288,503316480,134217728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,134217728,503316480,721420288,503316480,134217728,0,0,0,0,134217728,503316480,721420288,503316480,134217728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,134217728,503316480,721420288,520093696,167772160,16777216,0,0,0,0,0,0,0,0,134217728,503316480,721420288,520093696,234881024,285212672,570425344,687865856,436207616,117440512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,150994944,922746880,2348810240,4056321414,4294197820,4294119936,4294056448,4293921536,4293991688,3394978333,1879048192,704643072,117440512,0,0,0,0,33554432,268435456,1023410176,2248146944,3869450497,4293927168,4293661957,4293331976,4293330946,4293609799,3936365867,2181038080,822083584,134217728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,503316480
      ,1677721600,2348810240,1744830464,1140850688,1744830464,2348810240,1744830464,637534208,67108864,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1744830464,637534208,67108864,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1811939328,771751936,150994944,0,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1811939328,1040187392,1207959552,1979711488,2248146944,1509949440,436207616,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50331648,620756992,1879048192,3649264467,4294272360,4293853184,4293920000,4293920000,4293918720,3649195041,1979711488,754974720,134217728,0,0,0,0,0,67108864,335544320,1023410176,2080374784,3036676096,4088070144,4292476928,4292608000,4292739072,4292804608,4293347915,3581022738,1879048192,654311424,83886080,0,0,0,0,0,0,0,0,50331648,201326592,335544320,201326592,50331648,0,822083584,2533359616,4294967295,3261885548,2080374784,2768240640,4294967295,3261885548,1258291200,234881024,117440512,402653184
      ,671088640,687865856,469762048,184549376,33554432,0,83886080,318767104,419430400,352321536,469762048,620756992,620756992,520093696,335544320,150994944,50331648,0,0,50331648,201326592,335544320,201326592,50331648,0,822083584,2533359616,4294967295,3295439980,1610612736,872415232,520093696,318767104,301989888,167772160,33554432,0,33554432,167772160,301989888,167772160,33554432,50331648,201326592,335544320,201326592,50331648,0,0,0,50331648,184549376,469762048,704643072,704643072,469762048,184549376,855638016,2533359616,4294809856,3566287616,1493172224,335544320,0,0,50331648,234881024,402653184,234881024,50331648,0,822083584,2550136832,4294809856,3583064832,2147483648,2382364672,3921236224,4209802240,2181038080,687865856,184549376,469762048,704643072,704643072,469762048,184549376,50331648,50331648,234881024,520093696,671088640,704643072,822083584,889192448,771751936,721420288,805306368,771751936,520093696,234881024,50331648,0,0,0,0,268435456,1358954496,3023117852,4260334217,4293854213,4293919488
      ,4293921024,4293853184,4055516443,2348810240,939524096,150994944,0,0,0,0,33554432,201326592,671088640,1442840576,2264924160,3513790764,3356295425,3473866752,4207017984,4292673536,4292804608,4292870144,4292937479,4276240705,3174499075,1610612736,419430400,0,0,0,0,0,0,0,83886080,452984832,1157627904,1577058304,1174405120,486539264,83886080,905969664,2734686208,4294967295,3479528805,2533359616,3087007744,4294967295,3429394536,1543503872,520093696,754974720,1610612736,2248146944,2298478592,1845493760,1107296256,385875968,150994944,587202560,1409286144,1644167168,1442840576,1761607680,2147483648,2147483648,1962934272,1593835520,1040187392,385875968,50331648,83886080,452984832,1157627904,1577058304,1174405120,486539264,234881024,1191182336,2868903936,4294967295,3630326370,2734686208,2432696320,1962934272,1526726656,1392508928,822083584,167772160,0,167772160,822083584,1392508928,1073741824,436207616,503316480,1157627904,1577058304,1174405120,486539264,83886080,0,83886080,452984832,1140850688,1845493760
      ,2315255808,2315255808,1845493760,1140850688,1375731712,2818572288,4294804480,3666292992,1744830464,419430400,0,100663296,520093696,1275068416,1694498816,1291845632,536870912,234881024,1191182336,2868903936,4294804480,3783471360,2952790016,3768006912,4294606336,3681495040,2130706432,1023410176,1140850688,1845493760,2315255808,2315255808,1845493760,1140850688,469762048,335544320,1006632960,1879048192,2248146944,2298478592,2533359616,2667577344,2449473536,2332033024,2499805184,2449473536,1962934272,1191182336,419430400,50331648,0,0,83886080,754974720,2181038080,3971250292,4293995053,4293853184,4293855488,4293591040,4208406034,2938050314,1426063360,335544320,16777216,0,0,50331648,234881024,620756992,1207959552,2013265920,3107396370,4055000155,4293554803,4003672881,3221225472,3544186880,4292673536,4292804608,4292870144,4292870144,4293006099,4122616354,2600796160,1023410176,134217728,0,0,0,0,0,67108864,520093696,1560281088,2685209869,3768886436,2736133654,1644167168,603979776,1006632960,2734686208
      ,4294967295,3630326370,2952790016,3630326370,4294967295,3429394536,1711276032,1191182336,1979711488,3531768450,4140814287,4140945873,3801519766,2584349194,1493172224,1006632960,1728053248,3380576127,3769610159,2734686208,3752175013,4022386880,4022386880,3886721706,3513806960,2739028546,1140850688,285212672,520093696,1560281088,2685209869,3768886436,2736133654,1644167168,1107296256,1996488704,3579994722,4294967295,3780992349,3456106496,4294967295,3596837731,3173130786,3600916897,1828716544,553648128,50331648,553648128,1828716544,3600916897,2620009002,1509949440,1694498816,2685209869,3768886436,2736133654,1644167168,603979776,150994944,503316480,1543503872,2889486848,3767873792,4175254272,4175254272,3767873792,2889486848,2399141888,3120562176,4294798592,3632408576,1694498816,402653184,83886080,587202560,1644167168,2786133248,3870512384,2870872320,1711276032,1140850688,2013265920,3682543616,4294798592,3866764800,3456106496,4294798592,4054399232,3338665984,2516582400,2097152000,2889486848,3767873792
      ,4175254272,4175254272,3767873792,2889486848,1660944384,1275068416,2097152000,3836689152,4192360448,3422552064,4294798592,4294798592,4192360448,3970513152,4294798592,4192360448,3903601152,2788757760,1174405120,234881024,0,0,335544320,1493172224,3259970090,4294206305,4293591040,4293263872,4292935936,4292806915,3648730389,1862270976,620756992,117440512,117440512,285212672,553648128,922746880,1392508928,2063597568,2938704652,3834466116,4276189301,4292948534,4293067009,4293740360,3732214294,3187671040,3918004480,4293132288,4293066752,4292935680,4292870144,4293073434,3681683208,1879048192,536870912,33554432,0,0,0,16777216,402653184,1509949440,2869890831,4106733511,4277729528,4157920468,3022135842,1644167168,1392508928,2751463424,4294967295,3730726494,3271557120,4294967295,4294967295,3429394536,2030043136,2147483648,3768820643,4209699562,3832574064,3815599469,4260820726,3970410407,2936999695,2499805184,3464001656,4022189501,3578678862,3355443200,4294967295,3747569503,3426828609,3426828609,4004030632
      ,3784347792,1996488704,922746880,1509949440,2869890831,4106733511,4277729528,4157920468,3022135842,2348810240,2768240640,4294967295,4294967295,3847969627,3640655872,4294967295,3847969627,4020084125,4260820726,2888510251,1157627904,335544320,1157627904,2888510251,4260820726,3852772516,2734686208,3004174352,4106733511,4277729528,4157920468,3022135842,1644167168,721420288,1275068416,3058897920,4106697728,4294726912,4020186368,4020186368,4294726912,4106697728,3561427200,3489660928,4294792448,3598458880,1660944384,402653184,452984832,1577058304,2937455616,4158017536,4277752576,4192228608,3090025216,2382364672,2801795072,4294792448,4294792448,3916570368,3640655872,4294792448,4294792448,4294792448,3170893824,3460961024,4106697728,4294726912,4020186368,4020186368,4294726912,4106697728,3259962368,2617245696,3649906432,4277752576,3730839552,3539992576,4294792448,3849592320,3679458560,4277752576,4037094656,3813479168,4277752576,3886493184,1996488704,536870912,0,67108864,788529152,2281701376,4072894821
      ,4293201424,4292870144,4292804608,4292608000,4156898324,2634022912,1392508928,822083584,905969664,1140850688,1476395008,2013265920,2617573888,3292798484,3902098491,4241976422,4292888908,4292806923,4293001216,4293263360,4293525760,4294260515,3510376966,3305308160,4191289856,4293394432,4293066752,4292935680,4293001473,4242215445,2871133184,1191182336,201326592,0,0,0,268435456,1291845632,2701723913,4072652735,4260754933,3782702967,4175355614,4158446812,2870877726,2264924160,3019898880,4294967295,3630326370,2952790016,3305111552,4294967295,3462817382,2399141888,3243660886,4277795321,3764675684,3372220416,3405774848,3780071247,4174829270,3729542220,3456106496,4294967295,3801256594,2885681152,3271557120,4294967295,3546506083,2298478592,2348810240,3648616825,4294967295,2818572288,2097152000,2701723913,4072652735,4260754933,3782702967,4175355614,4158446812,3289979161,3137339392,3456106496,4294967295,3847969627,3640655872,4294967295,3780992349,3645064003,4226674157,3767833748,1996488704,1174405120
      ,1996488704,3767833748,4243385580,3712107074,3473278470,4072652735,4260754933,3782702967,4175355614,4158446812,2870877726,1711276032,1811939328,3685360896,4124521216,3410759424,2920416000,2920416000,3427536640,4157944576,4105775616,3640655872,4294787072,3564509184,1627389952,637534208,1342177280,2785739264,4106956544,4260773120,3867745792,4209325824,4192286208,3323987200,3137339392,3456106496,4294787072,3899463168,3640655872,4294787072,3798931456,3204448256,3221225472,4055509504,4157944576,3427536640,2920416000,2920416000,3427536640,4157944576,4072286720,3456106496,4294787072,3886162944,2969567232,3305111552,4294787072,3698464768,2952790016,3783794432,4294787072,3640655872,3951172864,4294787072,2550136832,822083584,0,285212672,1426063360,3277007389,4293737023,4293066752,4292870144,4292739072,4241565196,3423471106,2717908992,2197815296,2264924160,2685010432,3005286916,3377536014,3851039012,4139536965,4292959323,4292818747,4292742414,4292804608,4292804608,4292935680,4293725440,4294590464,3954466066
      ,2871071238,2466250752,3445623808,4294119168,4293525504,4293132288,4293001216,4293462024,3835439624,2030043136,654311424,67108864,0,50331648,788529152,2348941826,3851061898,4260886519,3529005144,3120562176,3525452322,4243451373,3902446234,3288926473,3439329280,4294967295,3513017444,2634022912,3137339392,4294967295,3496306021,2583691264,3717567893,4209041632,3489660928,4141406424,4141538010,4124168657,4192461795,3868365458,3523215360,4294967295,3462817382,2499805184,3070230528,4294967295,3429394536,1811939328,1845493760,3446040166,4294967295,3422552064,3221225472,3851061898,4260886519,3529005144,3120562176,3525452322,4243451373,3952580503,3490318858,3539992576,4294967295,3847969627,3640655872,4294967295,3630326370,2952790016,3869483939,4260689140,3123917619,2415919104,3123917619,4260689140,4020084125,3640655872,3968239238,4260886519,3529005144,3120562176,3525452322,4243451373,3902446234,2735475724,2113929216,2600468480,3019898880,2583691264,2063597568,2063597568,2667577344,3714912256,4294781952
      ,3640655872,4294781952,3547336960,1728053248,1191182336,2382495744,3902150144,4277545472,3580038656,3120562176,3559458048,4243531776,3986889472,3490382080,3539992576,4294781952,3882225408,3640655872,4294781952,3614249216,2634022912,2919235584,4294781952,3714912256,2667577344,2063597568,2063597568,2667577344,3714912256,4294781952,3640655872,4294781952,3547336960,2583691264,3120562176,4294781952,3547336960,2566914048,3547336960,4294781952,3640655872,3882225408,4294781952,2734686208,905969664,50331648,687865856,2164260864,4004986156,4293526023,4293132288,4292804608,4292739072,4190049031,3866102791,3816952331,3868467732,4003800346,4156500256,4275644710,4292683559,4292682277,4292679193,4292739073,4292739072,4292608000,4292411392,4292673536,4293661184,4174923273,3446360857,2164260864,1291845632,1191182336,2332033024,4073140736,4294119168,4293525504,4293066752,4293263360,4276230916,3260750080,1392508928,318767104,16777216,184549376,1275068416,3157340465,4274439878,3678486849,3120562176,3289452817
      ,3848232799,4120681628,4291611852,3711251765,3456106496,4291611852,3799348597,2919235584,3288334336,4291611852,3461435729,2499805184,3410446151,4206212533,3778952766,3591574291,3388997632,3305111552,3170893824,3036676096,3372220416,4291611852,3427947090,2415919104,3019898880,4291611852,3427947090,1795162112,1795162112,3427947090,4291611852,3640655872,3760793897,4274439878,3678486849,3120562176,3289452817,3848232799,4120681628,4291611852,3795137845,3640655872,4291611852,3846785353,3640655872,4291611852,3478212945,2399141888,3073322799,4172394929,4121339558,3491832097,4121339558,4172394929,3542690089,3643353385,4274439878,3678486849,3120562176,3289452817,3848232799,4120681628,4291611852,3510188345,2785017856,3582069760,4090368512,3376612608,2920218624,2920218624,3393389824,4123791872,4037807872,3456106496,4294514688,3835038720,2231369728,1862270976,3191800832,4277278208,3696690944,3137339392,3323461888,3883600384,4140044544,4294514688,3813017088,3640655872,4294514688,3865118720,3640655872
      ,4294514688,3496610048,2130706432,2399141888,3954183936,4123791872,3393389824,2920218624,2920218624,3393389824,4123791872,4071296768,3640655872,4294514688,3496610048,2466250752,3053453312,4294514688,3496610048,2466250752,3496610048,4294514688,3640655872,3865118720,4294514688,2734686208,905969664,201326592,1224736768,3023639812,4277017613,4293656576,4293263360,4292870144,4292804608,4292870144,4292871176,4292939794,4292939796,4292873232,4292871689,4292739587,4292804608,4292804608,4292673536,4292542464,4292345856,4292542464,4293133568,4157219336,3665638928,2651785731,1677721600,771751936,251658240,385875968,1526726656,3327729408,4294721792,4294119168,4293591040,4293197824,4293925893,3987551235,2248146944,872415232,134217728,385875968,1677721600,3630721128,4291546059,3813757265,3849088108,4189172145,4154893990,3881063508,4154762404,3781387107,3070230528,3629931612,4257728455,3661512254,3539992576,4291611852,3427947090,2231369728,2769885465,3934158462,4205949361,3847311697,3643419178,3729081669
      ,4037585064,2902458368,3288334336,4291611852,3427947090,2415919104,3019898880,4291611852,3427947090,1795162112,1795162112,3427947090,4291611852,3640655872,3932250465,4291546059,3813757265,3849088108,4189172145,4154893990,3881063508,4154762404,3915275870,3640655872,4291611852,3846785353,3640655872,4291611852,3427947090,1929379840,1946157056,3309980234,4206541498,4274374085,4206541498,3427289160,2835349504,3731187045,4291546059,3813757265,3849088108,4189172145,4154893990,3881063508,4154762404,3865075808,3456106496,4294511104,4088530432,4294380032,3968205824,3968205824,4294380032,4038395392,3158180096,2533359616,3531015424,4260563200,3310682880,2583691264,3665954048,4294445568,3815047936,3867608064,4191881216,4157409024,3899130624,4157277952,3933602816,3640655872,4294511104,3864789504,3640655872,4294511104,3462923264,1778384896,1577058304,2957115648,4038395392,4294380032,3968205824,3968205824,4294380032,4038395392,3493396736,3472883712,4294511104,3462923264,2449473536,3036676096,4294511104
      ,3462923264,2449473536,3462923264,4294511104,3640655872,3864789504,4294511104,2734686208,905969664,436207616,1795162112,3784914178,4294453760,4293985792,4293525504,4293263360,4293066752,4293001216,4292870144,4292870144,4292870144,4292804608,4292739072,4292608000,4292411392,4292411392,4292411392,4292804608,4276096257,4055439621,3462337541,2617967874,1778384896,1006632960,436207616,100663296,0,83886080,822083584,2332033024,4107292928,4294722560,4294251776,4293656576,4293856768,4276101633,3515097344,1342177280,234881024,436207616,1711276032,3817968017,4206673084,4223647679,4019952539,3613812326,3157077293,2869101315,3461238350,4037716650,2516582400,2365587456,3614865014,4104759721,3405774848,4291611852,3260503895,1560281088,1526726656,2703500324,3630786921,4036861341,4240490688,3867575942,2973514812,2231369728,2885681152,4291611852,3260503895,2080374784,2768240640,4291611852,3260503895,1493172224,1493172224,3260503895,4291611852,3372220416,3951922573,4206673084,4223647679,4019952539,3613812326
      ,3157077293,2869101315,3461238350,4087982505,3405774848,4291611852,3662499149,3355443200,4291611852,3260503895,1358954496,872415232,1795162112,3224646708,4257662662,3224646708,2147483648,2147483648,3817968017,4206673084,4223647679,4019952539,3613812326,3157077293,2869101315,3461238350,4104628135,3590324224,4294508544,3815702528,3698589696,4073127936,4073127936,3598123008,2720661504,1543503872,1107296256,1929379840,3616538624,4057071616,2801795072,3870294016,4209246208,4226351104,4022140928,3615162368,3157852160,2869100544,3462266880,4090298368,3405774848,4294508544,3663659008,3355443200,4294508544,3261661184,1325400064,687865856,1476395008,2720661504,3598123008,4073127936,4073127936,3598123008,2720661504,2231369728,2902458368,4294508544,3261661184,2080374784,2768240640,4294508544,3261661184,2080374784,3261661184,4294508544,3355443200,3663659008,4294508544,2533359616,822083584,520093696,1962934272,4022817026,4294132225,4294521600,4294253056,4293920768,4293591296,4293197824,4293132288,4292935680
      ,4292804608,4292804608,4292804608,4292935936,4293135104,4242084099,4072214529,3597801734,3023440387,2231369728,1577058304,956301312,452984832,117440512,16777216,0,0,0,352321536,1627389952,3530502912,4294929408,4294791936,4294592513,4158276864,3444975876,2535986688,1006632960,150994944,234881024,1006632960,1929379840,2449473536,2483027968,2164260864,1694498816,1258291200,1174405120,1610612736,1929379840,1459617792,1124073472,1660944384,2130706432,2264924160,2348810240,1744830464,687865856,436207616,1023410176,1694498816,2197815296,2348810240,1962934272,1224736768,989855744,1761607680,2348810240,1744830464,1140850688,1744830464,2348810240,1744830464,721420288,721420288,1744830464,2348810240,2197815296,2164260864,2449473536,2483027968,2164260864,1694498816,1258291200,1174405120,1610612736,2063597568,2248146944,2348810240,2164260864,2164260864,2348810240,1744830464,637534208,184549376,704643072,1728053248,2281701376,1728053248,939524096,1124073472,1929379840,2449473536,2483027968,2164260864
      ,1694498816,1258291200,1174405120,1610612736,2483027968,3305111552,4294508544,3563126784,2449473536,2214592512,2147483648,1677721600,1023410176,402653184,234881024,788529152,1660944384,1996488704,1828716544,2030043136,2449473536,2483027968,2164260864,1694498816,1258291200,1174405120,1610612736,2063597568,2248146944,2348810240,2164260864,2164260864,2348810240,1744830464,637534208,150994944,402653184,1023410176,1677721600,2147483648,2147483648,1677721600,1023410176,905969664,1744830464,2348810240,1744830464,1140850688,1744830464,2348810240,1744830464,1140850688,1744830464,2348810240,2164260864,2164260864,2348810240,1677721600,503316480,318767104,1375731712,3059226113,3699846145,3869130506,4022230030,4141306627,4226171904,4260378112,4260178176,4259914240,4191428864,4089652224,3936955141,3648853506,3361147392,2887846915,2248146944,1694498816,1191182336,721420288,335544320,83886080,16777216,0,0,0,0,0,117440512,989855744,2585332736,4039860480,3784984577,3226543360,2382364672,1728053248,989855744
      ,318767104,33554432,50331648,234881024,536870912,771751936,788529152,620756992,385875968,167772160,134217728,352321536,520093696,369098752,234881024,436207616,620756992,671088640,721420288,503316480,134217728,33554432,150994944,385875968,637534208,721420288,520093696,234881024,184549376,503316480,721420288,503316480,268435456,503316480,721420288,503316480,134217728,134217728,503316480,721420288,637534208,620756992,771751936,788529152,620756992,385875968,167772160,134217728,352321536,587202560,671088640,721420288,620756992,620756992,721420288,503316480,134217728,0,134217728,469762048,687865856,469762048,167772160,234881024,536870912,771751936,788529152,620756992,385875968,167772160,134217728,352321536,1258291200,2734686208,4294508544,3278503936,1476395008,754974720,620756992,385875968,150994944,33554432,16777216,150994944,436207616,570425344,503316480,587202560,771751936,788529152,620756992,385875968,167772160,134217728,352321536,587202560,671088640,721420288,620756992,620756992,721420288
      ,503316480,134217728,0,33554432,150994944,385875968,620756992,620756992,385875968,150994944,150994944,503316480,721420288,503316480,268435456,503316480,721420288,503316480,268435456,503316480,721420288,620756992,620756992,721420288,503316480,134217728,67108864,503316480,1224736768,1744830464,1979711488,2181038080,2382364672,2533359616,2634022912,2634022912,2600468480,2466250752,2298478592,2046820352,1728053248,1409286144,1073741824,704643072,385875968,167772160,50331648,0,0,0,0,0,0,0,0,16777216,419430400,1342177280,1979711488,1862270976,1342177280,822083584,419430400,150994944,33554432,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,503316480,1677721600,2348810240,1744830464,637534208,67108864,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50331648,234881024,419430400,536870912,637534208,738197504,822083584,855638016,872415232,838860800,788529152
      ,687865856,570425344,419430400,251658240,117440512,33554432,0,0,0,0,0,0,0,0,0,0,0,0,67108864,335544320,536870912,469762048,234881024,50331648,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,134217728,503316480,721420288,503316480,134217728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]));
      return _loc1_;
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      param1.stopPropagation();
   }
   
   private function onClick(param1:MouseEvent) : void
   {
      param1.stopPropagation();
      try
      {
         navigateToURL(new URLRequest("http://alternativaplatform.com"),"_blank");
      }
      catch(e:Error)
      {
      }
   }
   
   private function onDoubleClick(param1:MouseEvent) : void
   {
      param1.stopPropagation();
   }
   
   private function onMouseMove(param1:MouseEvent) : void
   {
      param1.stopPropagation();
      transform.colorTransform = highlighted;
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      param1.stopPropagation();
      transform.colorTransform = normal;
   }
   
   private function onMouseWheel(param1:MouseEvent) : void
   {
      param1.stopPropagation();
   }
}
