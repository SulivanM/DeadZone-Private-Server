package thelaststand.app.display
{
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.core.View;
   import alternativa.engine3d.lights.AmbientLight;
   import alternativa.engine3d.lights.DirectionalLight;
   import flash.display.Sprite;
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DRenderMode;
   import flash.events.Event;
   import org.osflash.signals.Signal;
   
   public class ModelView extends Sprite
   {
      
      private var _autoRender:Boolean;
      
      private var _camera:Camera3D;
      
      private var _context3D:Context3D;
      
      private var _container:Object3D;
      
      private var _disposed:Boolean;
      
      private var _viewport:View;
      
      private var _stage3D:Stage3D;
      
      private var _root:Object3D;
      
      private var _resourcesToUpload:Vector.<Resource>;
      
      private var _light_ambient:AmbientLight;
      
      private var _light_dir:DirectionalLight;
      
      public var renderStarted:Signal;
      
      public function ModelView(param1:Stage3D, param2:int, param3:int, param4:uint = 0, param5:Boolean = true)
      {
         super();
         this._autoRender = param5;
         this._viewport = new View(param2,param3,true,param4,(param4 >> 24 & 0xFF) / 255,0);
         this._viewport.hideLogo();
         addChild(this._viewport);
         this._stage3D = param1;
         if(this._autoRender)
         {
            this.requestContext();
         }
         this._camera = new Camera3D(0.1,5000);
         this._camera.z = -200;
         this._camera.view = this._viewport;
         this._container = new Object3D();
         this._root = new Object3D();
         this._root.addChild(this._camera);
         this._root.addChild(this._container);
         this._light_ambient = new AmbientLight(15585719);
         this._light_ambient.intensity = 1;
         this._root.addChild(this._light_ambient);
         this._light_dir = new DirectionalLight(16777215);
         this._light_dir.x = -50;
         this._light_dir.y = -50;
         this._light_dir.lookAt(0,0,0);
         this._root.addChild(this._light_dir);
         this._resourcesToUpload = new Vector.<Resource>();
         this.renderStarted = new Signal();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.renderStarted.removeAll();
         this.clear();
         this._disposed = true;
         if(this._stage3D)
         {
            this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         }
         if(this._context3D != null)
         {
            this._context3D.clear();
            this._context3D.present();
            this._context3D.dispose();
         }
         this._stage3D = null;
         this._context3D = null;
      }
      
      public function clear() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this._container.getResources(true))
         {
            _loc1_.dispose();
         }
         this._container.removeChildren();
         this._resourcesToUpload.length = 0;
         if(this._context3D != null)
         {
            this._context3D.clear();
         }
      }
      
      public function addObject(param1:Object3D) : void
      {
         var _loc2_:Resource = null;
         this._container.addChild(param1);
         for each(_loc2_ in param1.getResources(true))
         {
            this._resourcesToUpload.push(_loc2_);
         }
      }
      
      public function render() : void
      {
         if(this._stage3D == null || this._context3D == null)
         {
            return;
         }
         if(this._resourcesToUpload.length > 0)
         {
            this.uploadResources();
         }
         this.renderStarted.dispatch();
         this._camera.render(this._stage3D);
      }
      
      public function requestContext() : void
      {
         if(this._stage3D == null)
         {
            return;
         }
         this._stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,0,true);
         this._stage3D.requestContext3D(Context3DRenderMode.AUTO);
      }
      
      private function uploadResources() : void
      {
         var _loc1_:Resource = null;
         if(this._disposed || this._context3D == null || this._context3D.driverInfo.toLowerCase() == "disposed")
         {
            return;
         }
         for each(_loc1_ in this._resourcesToUpload)
         {
            _loc1_.upload(this._context3D);
         }
         this._resourcesToUpload.length = 0;
      }
      
      private function onContextCreated(param1:Event) : void
      {
         Stage3D(param1.currentTarget).removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         this._context3D = Stage3D(param1.currentTarget).context3D;
         if(this._disposed)
         {
            this._context3D.dispose();
            this._context3D = null;
            return;
         }
         this.uploadResources();
         if(stage != null && this._autoRender)
         {
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         dispatchEvent(new Event(Event.CONTEXT3D_CREATE));
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._context3D != null && this._autoRender)
         {
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this.render();
      }
      
      public function get container() : Object3D
      {
         return this._container;
      }
      
      public function get camera() : Camera3D
      {
         return this._camera;
      }
      
      public function get ambientLight() : AmbientLight
      {
         return this._light_ambient;
      }
      
      public function get directionalLight() : DirectionalLight
      {
         return this._light_dir;
      }
      
      public function get viewport() : View
      {
         return this._viewport;
      }
      
      public function get context3D() : Context3D
      {
         return this._context3D;
      }
      
      override public function get width() : Number
      {
         return this._viewport.width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._viewport.width = param1;
      }
      
      override public function get height() : Number
      {
         return this._viewport.height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._viewport.height = param1;
      }
   }
}

