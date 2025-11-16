package starling.core
{
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Program3D;
   import flash.errors.IllegalOperationError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Mouse;
   import flash.ui.Multitouch;
   import flash.ui.MultitouchInputMode;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import starling.animation.Juggler;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.KeyboardEvent;
   import starling.events.ResizeEvent;
   import starling.events.TouchPhase;
   import starling.utils.HAlign;
   import starling.utils.VAlign;
   
   public class Starling extends EventDispatcher
   {
      
      private static var sCurrent:Starling;
      
      private static var sHandleLostContext:Boolean;
      
      public static const VERSION:String = "1.2";
      
      private var mStage3D:Stage3D;
      
      private var mStage:starling.display.Stage;
      
      private var mRootClass:Class;
      
      private var mJuggler:Juggler;
      
      private var mStarted:Boolean;
      
      private var mSupport:RenderSupport;
      
      private var mTouchProcessor:TouchProcessor;
      
      private var mAntiAliasing:int;
      
      private var mSimulateMultitouch:Boolean;
      
      private var mEnableErrorChecking:Boolean;
      
      private var mLastFrameTimestamp:Number;
      
      private var mViewPort:Rectangle;
      
      private var mLeftMouseDown:Boolean;
      
      private var mStatsDisplay:StatsDisplay;
      
      private var mShareContext:Boolean;
      
      private var mNativeStage:flash.display.Stage;
      
      private var mNativeOverlay:Sprite;
      
      private var mContext:Context3D;
      
      private var mPrograms:Dictionary;
      
      public function Starling(param1:Class, param2:flash.display.Stage, param3:Rectangle = null, param4:Stage3D = null, param5:String = "auto", param6:String = "baselineConstrained")
      {
         var touchEventType:String = null;
         var requestContext3D:Function = null;
         var rootClass:Class = param1;
         var stage:flash.display.Stage = param2;
         var viewPort:Rectangle = param3;
         var stage3D:Stage3D = param4;
         var renderMode:String = param5;
         var profile:String = param6;
         super();
         if(stage == null)
         {
            throw new ArgumentError("Stage must not be null");
         }
         if(rootClass == null)
         {
            throw new ArgumentError("Root class must not be null");
         }
         if(viewPort == null)
         {
            viewPort = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
         }
         if(stage3D == null)
         {
            stage3D = stage.stage3Ds[0];
         }
         this.makeCurrent();
         this.mRootClass = rootClass;
         this.mViewPort = viewPort;
         this.mStage3D = stage3D;
         this.mStage = new starling.display.Stage(viewPort.width,viewPort.height,stage.color);
         this.mNativeOverlay = new Sprite();
         this.mNativeStage = stage;
         this.mNativeStage.addChild(this.mNativeOverlay);
         this.mTouchProcessor = new TouchProcessor(this.mStage);
         this.mJuggler = new Juggler();
         this.mAntiAliasing = 0;
         this.mSimulateMultitouch = false;
         this.mEnableErrorChecking = false;
         this.mLastFrameTimestamp = getTimer() / 1000;
         this.mPrograms = new Dictionary();
         this.mSupport = new RenderSupport();
         for each(touchEventType in this.touchEventTypes)
         {
            stage.addEventListener(touchEventType,this.onTouch,false,0,true);
         }
         stage.addEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,this.onKey,false,0,true);
         stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,this.onKey,false,0,true);
         stage.addEventListener(flash.events.Event.RESIZE,this.onResize,false,0,true);
         if(Boolean(this.mStage3D.context3D) && this.mStage3D.context3D.driverInfo != "Disposed")
         {
            this.mShareContext = true;
            setTimeout(this.initialize,1);
         }
         else
         {
            this.mShareContext = false;
            this.mStage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextCreated,false,1,true);
            this.mStage3D.addEventListener(ErrorEvent.ERROR,this.onStage3DError,false,1,true);
            try
            {
               requestContext3D = this.mStage3D.requestContext3D;
               if(requestContext3D.length == 1)
               {
                  requestContext3D(renderMode);
               }
               else
               {
                  requestContext3D(renderMode,profile);
               }
            }
            catch(e:Error)
            {
               showFatalError("Context3D error: " + e.message);
            }
         }
      }
      
      public static function get current() : Starling
      {
         return sCurrent;
      }
      
      public static function get context() : Context3D
      {
         return sCurrent ? sCurrent.context : null;
      }
      
      public static function get juggler() : Juggler
      {
         return sCurrent ? sCurrent.juggler : null;
      }
      
      public static function get contentScaleFactor() : Number
      {
         return sCurrent ? sCurrent.contentScaleFactor : 1;
      }
      
      public static function get multitouchEnabled() : Boolean
      {
         return Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
      }
      
      public static function set multitouchEnabled(param1:Boolean) : void
      {
         if(sCurrent)
         {
            throw new IllegalOperationError("\'multitouchEnabled\' must be set before Starling instance is created");
         }
         Multitouch.inputMode = param1 ? MultitouchInputMode.TOUCH_POINT : MultitouchInputMode.NONE;
      }
      
      public static function get handleLostContext() : Boolean
      {
         return sHandleLostContext;
      }
      
      public static function set handleLostContext(param1:Boolean) : void
      {
         if(sCurrent)
         {
            throw new IllegalOperationError("\'handleLostContext\' must be set before Starling instance is created");
         }
         sHandleLostContext = param1;
      }
      
      public function dispose() : void
      {
         var _loc1_:String = null;
         var _loc2_:Program3D = null;
         this.stop();
         this.mNativeStage.removeEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame,false);
         this.mNativeStage.removeEventListener(flash.events.KeyboardEvent.KEY_DOWN,this.onKey,false);
         this.mNativeStage.removeEventListener(flash.events.KeyboardEvent.KEY_UP,this.onKey,false);
         this.mNativeStage.removeEventListener(flash.events.Event.RESIZE,this.onResize,false);
         this.mStage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextCreated,false);
         this.mStage3D.removeEventListener(ErrorEvent.ERROR,this.onStage3DError,false);
         for each(_loc1_ in this.touchEventTypes)
         {
            this.mNativeStage.removeEventListener(_loc1_,this.onTouch,false);
         }
         for each(_loc2_ in this.mPrograms)
         {
            _loc2_.dispose();
         }
         if(Boolean(this.mContext) && !this.mShareContext)
         {
            this.mContext.dispose();
         }
         if(this.mTouchProcessor)
         {
            this.mTouchProcessor.dispose();
         }
         if(this.mSupport)
         {
            this.mSupport.dispose();
         }
         if(this.mStage)
         {
            this.mStage.dispose();
         }
         if(sCurrent == this)
         {
            sCurrent = null;
         }
      }
      
      private function initialize() : void
      {
         this.makeCurrent();
         this.initializeGraphicsAPI();
         this.initializeRoot();
         this.mTouchProcessor.simulateMultitouch = this.mSimulateMultitouch;
         this.mLastFrameTimestamp = getTimer() / 1000;
      }
      
      private function initializeGraphicsAPI() : void
      {
         this.mContext = this.mStage3D.context3D;
         this.mContext.enableErrorChecking = this.mEnableErrorChecking;
         this.mPrograms = new Dictionary();
         this.updateViewPort();
         dispatchEventWith(starling.events.Event.CONTEXT3D_CREATE,false,this.mContext);
      }
      
      private function initializeRoot() : void
      {
         if(this.mStage.numChildren > 0)
         {
            return;
         }
         var _loc1_:DisplayObject = new this.mRootClass();
         if(_loc1_ == null)
         {
            throw new Error("Invalid root class: " + this.mRootClass);
         }
         this.mStage.addChildAt(_loc1_,0);
         dispatchEventWith(starling.events.Event.ROOT_CREATED,false,this.root);
      }
      
      public function nextFrame() : void
      {
         var _loc1_:Number = getTimer() / 1000;
         var _loc2_:Number = _loc1_ - this.mLastFrameTimestamp;
         this.mLastFrameTimestamp = _loc1_;
         this.advanceTime(_loc2_);
         this.render();
      }
      
      public function advanceTime(param1:Number) : void
      {
         this.makeCurrent();
         this.mTouchProcessor.advanceTime(param1);
         this.mStage.advanceTime(param1);
         this.mJuggler.advanceTime(param1);
      }
      
      public function render() : void
      {
         this.makeCurrent();
         this.updateNativeOverlay();
         this.mSupport.nextFrame();
         if(this.mContext == null || this.mContext.driverInfo == "Disposed")
         {
            return;
         }
         if(!this.mShareContext)
         {
            RenderSupport.clear(this.mStage.color,1);
         }
         this.mSupport.setOrthographicProjection(0,0,this.mStage.stageWidth,this.mStage.stageHeight);
         this.mSupport.renderTarget = null;
         this.mStage.render(this.mSupport,1);
         this.mSupport.finishQuadBatch();
         if(this.mStatsDisplay)
         {
            this.mStatsDisplay.drawCount = this.mSupport.drawCount;
         }
         if(!this.mShareContext)
         {
            this.mContext.present();
         }
      }
      
      private function updateViewPort() : void
      {
         if(this.mShareContext)
         {
            return;
         }
         if(Boolean(this.mContext) && this.mContext.driverInfo != "Disposed")
         {
            this.mContext.configureBackBuffer(this.mViewPort.width,this.mViewPort.height,this.mAntiAliasing,false);
         }
         this.mStage3D.x = this.mViewPort.x;
         this.mStage3D.y = this.mViewPort.y;
      }
      
      private function updateNativeOverlay() : void
      {
         this.mNativeOverlay.x = this.mViewPort.x;
         this.mNativeOverlay.y = this.mViewPort.y;
         this.mNativeOverlay.scaleX = this.mViewPort.width / this.mStage.stageWidth;
         this.mNativeOverlay.scaleY = this.mViewPort.height / this.mStage.stageHeight;
      }
      
      private function showFatalError(param1:String) : void
      {
         var _loc2_:TextField = null;
         _loc2_ = new TextField();
         var _loc3_:TextFormat = new TextFormat("Verdana",12,16777215);
         _loc3_.align = TextFormatAlign.CENTER;
         _loc2_.defaultTextFormat = _loc3_;
         _loc2_.wordWrap = true;
         _loc2_.width = this.mStage.stageWidth * 0.75;
         _loc2_.autoSize = TextFieldAutoSize.CENTER;
         _loc2_.text = param1;
         _loc2_.x = (this.mStage.stageWidth - _loc2_.width) / 2;
         _loc2_.y = (this.mStage.stageHeight - _loc2_.height) / 2;
         _loc2_.background = true;
         _loc2_.backgroundColor = 4456448;
         this.nativeOverlay.addChild(_loc2_);
      }
      
      public function makeCurrent() : void
      {
         sCurrent = this;
      }
      
      public function start() : void
      {
         this.mStarted = true;
         this.mLastFrameTimestamp = getTimer() / 1000;
      }
      
      public function stop() : void
      {
         this.mStarted = false;
      }
      
      private function onStage3DError(param1:ErrorEvent) : void
      {
         if(param1.errorID == 3702)
         {
            this.showFatalError("This application is not correctly embedded (wrong wmode value)");
         }
         else
         {
            this.showFatalError("Stage3D error: " + param1.text);
         }
      }
      
      private function onContextCreated(param1:flash.events.Event) : void
      {
         if(!Starling.handleLostContext && Boolean(this.mContext))
         {
            this.showFatalError("Fatal error: The application lost the device context!");
            this.stop();
         }
         else
         {
            this.initialize();
         }
      }
      
      private function onEnterFrame(param1:flash.events.Event) : void
      {
         if(this.mStarted && !this.mShareContext)
         {
            this.nextFrame();
         }
      }
      
      private function onKey(param1:flash.events.KeyboardEvent) : void
      {
         if(!this.mStarted)
         {
            return;
         }
         this.makeCurrent();
         this.mStage.dispatchEvent(new starling.events.KeyboardEvent(param1.type,param1.charCode,param1.keyCode,param1.keyLocation,param1.ctrlKey,param1.altKey,param1.shiftKey));
      }
      
      private function onResize(param1:flash.events.Event) : void
      {
         var _loc2_:flash.display.Stage = param1.target as flash.display.Stage;
         this.mStage.dispatchEvent(new ResizeEvent(flash.events.Event.RESIZE,_loc2_.stageWidth,_loc2_.stageHeight));
      }
      
      private function onTouch(param1:flash.events.Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:MouseEvent = null;
         var _loc7_:TouchEvent = null;
         if(!this.mStarted)
         {
            return;
         }
         if(param1 is MouseEvent)
         {
            _loc6_ = param1 as MouseEvent;
            _loc2_ = _loc6_.stageX;
            _loc3_ = _loc6_.stageY;
            _loc4_ = 0;
            if(param1.type == MouseEvent.MOUSE_DOWN)
            {
               this.mLeftMouseDown = true;
            }
            else if(param1.type == MouseEvent.MOUSE_UP)
            {
               this.mLeftMouseDown = false;
            }
         }
         else
         {
            _loc7_ = param1 as TouchEvent;
            _loc2_ = _loc7_.stageX;
            _loc3_ = _loc7_.stageY;
            _loc4_ = _loc7_.touchPointID;
         }
         switch(param1.type)
         {
            case TouchEvent.TOUCH_BEGIN:
               _loc5_ = TouchPhase.BEGAN;
               break;
            case TouchEvent.TOUCH_MOVE:
               _loc5_ = TouchPhase.MOVED;
               break;
            case TouchEvent.TOUCH_END:
               _loc5_ = TouchPhase.ENDED;
               break;
            case MouseEvent.MOUSE_DOWN:
               _loc5_ = TouchPhase.BEGAN;
               break;
            case MouseEvent.MOUSE_UP:
               _loc5_ = TouchPhase.ENDED;
               break;
            case MouseEvent.MOUSE_MOVE:
               _loc5_ = this.mLeftMouseDown ? TouchPhase.MOVED : TouchPhase.HOVER;
         }
         _loc2_ = this.mStage.stageWidth * (_loc2_ - this.mViewPort.x) / this.mViewPort.width;
         _loc3_ = this.mStage.stageHeight * (_loc3_ - this.mViewPort.y) / this.mViewPort.height;
         this.mTouchProcessor.enqueue(_loc4_,_loc5_,_loc2_,_loc3_);
      }
      
      private function get touchEventTypes() : Array
      {
         return Mouse.supportsCursor || !multitouchEnabled ? [MouseEvent.MOUSE_DOWN,MouseEvent.MOUSE_MOVE,MouseEvent.MOUSE_UP] : [TouchEvent.TOUCH_BEGIN,TouchEvent.TOUCH_MOVE,TouchEvent.TOUCH_END];
      }
      
      public function registerProgram(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         if(param1 in this.mPrograms)
         {
            throw new Error("Another program with this name is already registered");
         }
         var _loc4_:Program3D = this.mContext.createProgram();
         _loc4_.upload(param2,param3);
         this.mPrograms[param1] = _loc4_;
      }
      
      public function deleteProgram(param1:String) : void
      {
         var _loc2_:Program3D = this.getProgram(param1);
         if(_loc2_)
         {
            _loc2_.dispose();
            delete this.mPrograms[param1];
         }
      }
      
      public function getProgram(param1:String) : Program3D
      {
         return this.mPrograms[param1] as Program3D;
      }
      
      public function hasProgram(param1:String) : Boolean
      {
         return param1 in this.mPrograms;
      }
      
      public function get isStarted() : Boolean
      {
         return this.mStarted;
      }
      
      public function get juggler() : Juggler
      {
         return this.mJuggler;
      }
      
      public function get context() : Context3D
      {
         return this.mContext;
      }
      
      public function get simulateMultitouch() : Boolean
      {
         return this.mSimulateMultitouch;
      }
      
      public function set simulateMultitouch(param1:Boolean) : void
      {
         this.mSimulateMultitouch = param1;
         if(this.mContext)
         {
            this.mTouchProcessor.simulateMultitouch = param1;
         }
      }
      
      public function get enableErrorChecking() : Boolean
      {
         return this.mEnableErrorChecking;
      }
      
      public function set enableErrorChecking(param1:Boolean) : void
      {
         this.mEnableErrorChecking = param1;
         if(this.mContext)
         {
            this.mContext.enableErrorChecking = param1;
         }
      }
      
      public function get antiAliasing() : int
      {
         return this.mAntiAliasing;
      }
      
      public function set antiAliasing(param1:int) : void
      {
         this.mAntiAliasing = param1;
         this.updateViewPort();
      }
      
      public function get viewPort() : Rectangle
      {
         return this.mViewPort.clone();
      }
      
      public function set viewPort(param1:Rectangle) : void
      {
         this.mViewPort = param1.clone();
         this.updateViewPort();
      }
      
      public function get contentScaleFactor() : Number
      {
         return this.mViewPort.width / this.mStage.stageWidth;
      }
      
      public function get nativeOverlay() : Sprite
      {
         return this.mNativeOverlay;
      }
      
      public function get showStats() : Boolean
      {
         return Boolean(this.mStatsDisplay) && Boolean(this.mStatsDisplay.parent);
      }
      
      public function set showStats(param1:Boolean) : void
      {
         if(param1 == this.showStats)
         {
            return;
         }
         if(param1)
         {
            if(this.mStatsDisplay)
            {
               this.mStage.addChild(this.mStatsDisplay);
            }
            else
            {
               this.showStatsAt();
            }
         }
         else
         {
            this.mStatsDisplay.removeFromParent();
         }
      }
      
      public function showStatsAt(param1:String = "left", param2:String = "top", param3:Number = 1) : void
      {
         var onRootCreated:Function = null;
         var stageWidth:int = 0;
         var stageHeight:int = 0;
         var hAlign:String = param1;
         var vAlign:String = param2;
         var scale:Number = param3;
         onRootCreated = function():void
         {
            showStatsAt(hAlign,vAlign,scale);
            removeEventListener(starling.events.Event.ROOT_CREATED,onRootCreated);
         };
         if(this.mContext == null)
         {
            addEventListener(starling.events.Event.ROOT_CREATED,onRootCreated);
         }
         else
         {
            if(this.mStatsDisplay == null)
            {
               this.mStatsDisplay = new StatsDisplay();
               this.mStatsDisplay.touchable = false;
               this.mStage.addChild(this.mStatsDisplay);
            }
            stageWidth = this.mStage.stageWidth;
            stageHeight = this.mStage.stageHeight;
            this.mStatsDisplay.scaleX = this.mStatsDisplay.scaleY = scale;
            if(hAlign == HAlign.LEFT)
            {
               this.mStatsDisplay.x = 0;
            }
            else if(hAlign == HAlign.RIGHT)
            {
               this.mStatsDisplay.x = stageWidth - this.mStatsDisplay.width;
            }
            else
            {
               this.mStatsDisplay.x = int((stageWidth - this.mStatsDisplay.width) / 2);
            }
            if(vAlign == VAlign.TOP)
            {
               this.mStatsDisplay.y = 0;
            }
            else if(vAlign == VAlign.BOTTOM)
            {
               this.mStatsDisplay.y = stageHeight - this.mStatsDisplay.height;
            }
            else
            {
               this.mStatsDisplay.y = int((stageHeight - this.mStatsDisplay.height) / 2);
            }
         }
      }
      
      public function get stage() : starling.display.Stage
      {
         return this.mStage;
      }
      
      public function get stage3D() : Stage3D
      {
         return this.mStage3D;
      }
      
      public function get nativeStage() : flash.display.Stage
      {
         return this.mNativeStage;
      }
      
      public function get root() : DisplayObject
      {
         return this.mStage.getChildAt(0);
      }
      
      public function get shareContext() : Boolean
      {
         return this.mShareContext;
      }
      
      public function set shareContext(param1:Boolean) : void
      {
         this.mShareContext = param1;
      }
   }
}

