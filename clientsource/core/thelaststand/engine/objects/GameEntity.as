package thelaststand.engine.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.events.MouseEvent3D;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.utils.Object3DUtils;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import org.osflash.signals.Signal;
   import thelaststand.engine.animation.IAnimatingObject;
   import thelaststand.engine.geom.Transform;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.actions.IEntityAction;
   import thelaststand.engine.scenes.Scene;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   use namespace alternativa3d;
   
   public class GameEntity
   {
      
      private var _triggers:Dictionary;
      
      private var _actions:Vector.<IEntityAction>;
      
      private var _transTranslate:Transform3D;
      
      private var _transRotScale:Transform3D;
      
      private var _name:String;
      
      private var _asset:Object3D;
      
      private var _castsShadows:Boolean = false;
      
      private var _boundingBox:BoundBox;
      
      private var _transform:Transform;
      
      private var _tmpMat:Vector.<Number>;
      
      public var next:GameEntity;
      
      public var prev:GameEntity;
      
      public var data:Object;
      
      public var passable:Boolean = true;
      
      public var transformChanged:Boolean;
      
      public var boundingBoxMesh:Mesh;
      
      public var losVisible:Boolean = false;
      
      public var flags:uint = 0;
      
      public var tileCost:uint = 0;
      
      public var scene:Scene;
      
      public var addedToScene:Signal;
      
      public var removedFromScene:Signal;
      
      public var assetInvalidated:Signal;
      
      public var nameChanged:Signal;
      
      public var properties:Object = {};
      
      public var assetClicked:Signal;
      
      public var assetMouseOver:Signal;
      
      public var assetMouseOut:Signal;
      
      public var assetMouseDown:Signal;
      
      public var assetRightClicked:Signal;
      
      public var assetRightMouseDown:Signal;
      
      public function GameEntity(param1:String = null, param2:Object3D = null)
      {
         super();
         this._actions = new Vector.<IEntityAction>();
         this._boundingBox = new BoundBox();
         this._transform = new Transform();
         this._tmpMat = new Vector.<Number>(16,true);
         this._transRotScale = new Transform3D();
         this._transTranslate = new Transform3D();
         this.addedToScene = new Signal(GameEntity);
         this.removedFromScene = new Signal(GameEntity);
         this.assetInvalidated = new Signal(GameEntity);
         this.assetClicked = new Signal(GameEntity);
         this.assetMouseOver = new Signal(GameEntity);
         this.assetMouseOut = new Signal(GameEntity);
         this.assetMouseDown = new Signal(GameEntity);
         this.assetRightClicked = new Signal(GameEntity);
         this.assetRightMouseDown = new Signal(GameEntity);
         this.nameChanged = new Signal(GameEntity,String);
         this.name = param1;
         this.asset = param2;
      }
      
      public function dispose() : void
      {
         var _loc1_:IEntityAction = null;
         var _loc2_:Mesh = null;
         var _loc3_:MeshGroup = null;
         if(this.scene != null)
         {
            this.scene.removeEntity(this);
            this.scene = null;
         }
         if(this._asset != null)
         {
            _loc2_ = this._asset as Mesh;
            if(_loc2_ != null)
            {
               _loc2_.geometry = null;
            }
            _loc3_ = this._asset as MeshGroup;
            if(_loc3_ != null)
            {
               _loc3_.dispose();
            }
            TweenMaxDelta.killTweensOf(this._asset);
            this.removeMouseListeners();
            if(this._asset.parent != null)
            {
               this._asset.parent.removeChild(this._asset);
            }
            this._asset = null;
         }
         for each(_loc1_ in this._actions)
         {
            _loc1_.dispose();
         }
         this._actions = null;
         this.addedToScene.removeAll();
         this.removedFromScene.removeAll();
         this.assetClicked.removeAll();
         this.assetInvalidated.removeAll();
         this.assetMouseOver.removeAll();
         this.assetMouseOut.removeAll();
         this.assetRightClicked.removeAll();
         this.assetRightMouseDown.removeAll();
         this.nameChanged.removeAll();
         this.name = null;
         this.next = null;
         this.prev = null;
         this.data = null;
         this._transTranslate = null;
         this._transRotScale = null;
      }
      
      public function addTrigger(param1:uint, param2:String) : void
      {
         if(this._triggers == null)
         {
            this._triggers = new Dictionary();
         }
         var _loc3_:Vector.<String> = this._triggers[param1];
         if(_loc3_ == null)
         {
            _loc3_ = new Vector.<String>();
            _loc3_.push(param2);
            this._triggers[param1] = _loc3_;
         }
         else if(_loc3_.indexOf(param2) == -1)
         {
            _loc3_.push(param2);
         }
      }
      
      public function getTriggers(param1:uint) : Vector.<String>
      {
         if(this._triggers == null)
         {
            return null;
         }
         return this._triggers[param1];
      }
      
      public function getHeight() : Number
      {
         if(this._asset == null)
         {
            return 0;
         }
         return this._asset.boundBox.maxZ - this._asset.boundBox.minZ;
      }
      
      public function getAssetCenter(param1:Vector3D = null) : Vector3D
      {
         param1 ||= new Vector3D();
         if(this._asset == null)
         {
            return param1;
         }
         var _loc2_:Object3D = this._asset.getChildByName("meshEntity") != null ? this._asset.getChildByName("meshEntity") : this._asset;
         if(_loc2_ == null)
         {
            return param1;
         }
         var _loc3_:BoundBox = _loc2_.boundBox;
         if(_loc3_ == null)
         {
            return param1;
         }
         var _loc4_:Number = _loc3_.maxX - _loc3_.minX;
         var _loc5_:Number = _loc3_.maxY - _loc3_.minY;
         var _loc6_:Number = _loc3_.maxZ - _loc3_.minZ;
         param1.x = _loc3_.minX + _loc4_ * 0.5;
         param1.y = _loc3_.minY + _loc5_ * 0.5;
         param1.z = _loc3_.minZ + _loc6_ * 0.5;
         return param1;
      }
      
      public function removeAllActions() : void
      {
         var _loc1_:IEntityAction = null;
         for each(_loc1_ in this._actions)
         {
            _loc1_.dispose();
         }
         this._actions.length = 0;
      }
      
      public function update(param1:Number = 1) : void
      {
         var _loc2_:IAnimatingObject = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.asset != null)
         {
            _loc2_ = this.asset as IAnimatingObject;
            if(_loc2_ != null && this.asset.visible)
            {
               _loc2_.updateAnimation(param1);
            }
            if(!(this.flags & GameEntityFlags.IGNORE_TRANSFORMS))
            {
               this.updateAssetLocalBounds();
            }
         }
         if(this._actions != null)
         {
            _loc3_ = 0;
            _loc4_ = int(this._actions.length);
            while(_loc3_ < _loc4_)
            {
               this._actions[_loc3_].run(this,param1);
               _loc3_++;
            }
         }
      }
      
      public function updateBoundingBox() : void
      {
         this._boundingBox.reset();
         Object3DUtils.calculateHierarchyBoundBox(this.asset,this.asset,this.asset.boundBox);
         Object3DUtils.calculateHierarchyBoundBox(this.asset,this.scene != null ? this.scene.container : this.asset,this._boundingBox);
         if(this.asset.boundBox.minX == 1e+22)
         {
            this.asset.boundBox.minX = this.asset.boundBox.maxX = 0;
            this.asset.boundBox.minY = this.asset.boundBox.maxY = 0;
            this.asset.boundBox.minZ = this.asset.boundBox.maxZ = 0;
         }
         if(this._boundingBox.minX == 1e+22)
         {
            this._boundingBox.minX = this._boundingBox.maxX = 0;
            this._boundingBox.minY = this._boundingBox.maxY = 0;
            this._boundingBox.minZ = this._boundingBox.maxZ = 0;
         }
      }
      
      public function updateTransform(param1:Number = 1) : void
      {
         var _loc2_:Transform3D = null;
         if(this._asset == null)
         {
            return;
         }
         _loc2_ = this._asset.alternativa3d::transform;
         this._asset.alternativa3d::transformChanged = false;
         this._transform.toRawData(true,this._tmpMat);
         _loc2_.a = this._tmpMat[0];
         _loc2_.b = this._tmpMat[1];
         _loc2_.c = this._tmpMat[2];
         _loc2_.e = this._tmpMat[4];
         _loc2_.f = this._tmpMat[5];
         _loc2_.g = this._tmpMat[6];
         _loc2_.i = this._tmpMat[8];
         _loc2_.j = this._tmpMat[9];
         _loc2_.k = this._tmpMat[10];
         _loc2_.d = this._tmpMat[3];
         _loc2_.h = this._tmpMat[7];
         _loc2_.l = this._tmpMat[11];
         this._asset.alternativa3d::inverseTransform.calculateInversion(_loc2_);
      }
      
      public function updateAssetLocalBounds(param1:Boolean = false) : void
      {
         if(this._asset == null)
         {
            return;
         }
         var _loc2_:Boolean = this._transTranslate.d != this._asset.alternativa3d::transform.d || this._transTranslate.h != this._asset.alternativa3d::transform.h || this._transTranslate.l != this._asset.alternativa3d::transform.l;
         var _loc3_:Boolean = this._transRotScale.a != this._asset.alternativa3d::transform.a || this._transRotScale.b != this._asset.alternativa3d::transform.b || this._transRotScale.c != this._asset.alternativa3d::transform.c || this._transRotScale.e != this._asset.alternativa3d::transform.e || this._transRotScale.f != this._asset.alternativa3d::transform.f || this._transRotScale.g != this._asset.alternativa3d::transform.g || this._transRotScale.i != this._asset.alternativa3d::transform.i || this._transRotScale.j != this._asset.alternativa3d::transform.j || this._transRotScale.k != this._asset.alternativa3d::transform.k;
         if(!param1 && !_loc3_)
         {
            if(_loc2_)
            {
               this._transTranslate.copy(this._asset.alternativa3d::transform);
            }
            return;
         }
         this._transTranslate.copy(this._asset.alternativa3d::transform);
         this._transRotScale.copy(this._asset.alternativa3d::transform);
         this._transRotScale.d = this._transRotScale.h = this._transRotScale.l = 0;
         this._asset.calculateBoundBox();
         this._asset.alternativa3d::updateBoundBox(this._asset.boundBox,this._transRotScale);
      }
      
      public function toString() : String
      {
         return "(" + getQualifiedClassName(this) + " " + this.name + ")";
      }
      
      private function onAssetClicked(param1:MouseEvent3D) : void
      {
         this.assetClicked.dispatch(this);
      }
      
      private function onAssetMouseOver(param1:MouseEvent3D) : void
      {
         this.assetMouseOver.dispatch(this);
      }
      
      private function onAssetMouseOut(param1:MouseEvent3D) : void
      {
         this.assetMouseOut.dispatch(this);
      }
      
      private function onAssetMouseDown(param1:MouseEvent3D) : void
      {
         this.assetMouseDown.dispatch(this);
      }
      
      private function onAssetRightMouseDown(param1:MouseEvent3D) : void
      {
         this.assetRightMouseDown.dispatch(this);
      }
      
      private function onAssetRightMouseClicked(param1:MouseEvent3D) : void
      {
         this.assetRightClicked.dispatch(this);
      }
      
      private function addMouseListeners() : void
      {
         this._asset.addEventListener(MouseEvent3D.CLICK,this.onAssetClicked,false,0,true);
         this._asset.addEventListener(MouseEvent3D.MOUSE_OVER,this.onAssetMouseOver,false,0,true);
         this._asset.addEventListener(MouseEvent3D.MOUSE_OUT,this.onAssetMouseOut,false,0,true);
         this._asset.addEventListener(MouseEvent3D.MOUSE_DOWN,this.onAssetMouseDown,false,0,true);
         this._asset.addEventListener(MouseEvent3D.RIGHT_MOUSE_DOWN,this.onAssetRightMouseDown,false,0,true);
         this._asset.addEventListener(MouseEvent3D.RIGHT_CLICK,this.onAssetRightMouseClicked,false,0,true);
      }
      
      private function removeMouseListeners() : void
      {
         this._asset.removeEventListener(MouseEvent3D.CLICK,this.onAssetClicked);
         this._asset.removeEventListener(MouseEvent3D.MOUSE_OVER,this.onAssetMouseOver);
         this._asset.removeEventListener(MouseEvent3D.MOUSE_OUT,this.onAssetMouseOut);
         this._asset.removeEventListener(MouseEvent3D.MOUSE_DOWN,this.onAssetMouseDown);
         this._asset.removeEventListener(MouseEvent3D.RIGHT_MOUSE_DOWN,this.onAssetRightMouseDown);
         this._asset.removeEventListener(MouseEvent3D.RIGHT_CLICK,this.onAssetRightMouseClicked);
      }
      
      public function get actions() : Vector.<IEntityAction>
      {
         return this._actions;
      }
      
      public function get asset() : Object3D
      {
         return this._asset;
      }
      
      public function set asset(param1:Object3D) : void
      {
         if(this._asset)
         {
            this.removeMouseListeners();
            if(this._asset.parent != null)
            {
               this._asset.parent.removeChild(this._asset);
            }
         }
         this._asset = param1;
         if(this._asset == null)
         {
            return;
         }
         this.addMouseListeners();
         this._asset.mouseChildren = false;
         this.assetInvalidated.dispatch(this);
      }
      
      public function get boundingBox() : BoundBox
      {
         return this._boundingBox;
      }
      
      public function get castsShadows() : Boolean
      {
         return this._castsShadows;
      }
      
      public function set castsShadows(param1:Boolean) : void
      {
         this._castsShadows = param1;
         if(this.scene != null)
         {
            if(this._castsShadows)
            {
               this.scene.addShadowCaster(this.asset);
            }
            else
            {
               this.scene.removeShadowCaster(this.asset);
            }
         }
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         if(this._name == param1)
         {
            return;
         }
         var _loc2_:String = this._name;
         this._name = param1;
         this.nameChanged.dispatch(this,_loc2_);
      }
      
      public function get transform() : Transform
      {
         return this._transform;
      }
   }
}

