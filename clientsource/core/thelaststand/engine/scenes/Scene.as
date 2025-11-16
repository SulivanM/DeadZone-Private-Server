package thelaststand.engine.scenes
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.shadows.DirectionalLightShadow;
   import alternativa.engine3d.utils.Object3DUtils;
   import com.exileetiquette.math.SeedRandom;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import com.junkbyte.console.Cc;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.logic.EntityTrigger;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.core.OrthoCamera;
   import thelaststand.engine.map.Map;
   import thelaststand.engine.map.MouseMap;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.objects.light.OmniLightEntity;
   
   public class Scene
   {
      
      private const ROTATION_X:Number = -120;
      
      private const ROTATION_Z:Number = -45;
      
      public const ROTATION_STEPS:int = 2;
      
      public const LOS_BOUNDS_VOLUME_THRESHOLD:Number = 8000000;
      
      private var _camera:OrthoCamera;
      
      private var _cameraDummy:Object;
      
      private var _entityListHead:GameEntity;
      
      private var _entityListTail:GameEntity;
      
      private var _entitiesByName:Dictionary;
      
      private var _rotationStep:int;
      
      private var _root:Object3D;
      
      private var _core:Object3D;
      
      private var _scene:Object3D;
      
      private var _zoomStep:int;
      
      private var _shadow:DirectionalLightShadow;
      
      private var _shadowCasters:Vector.<Object3D>;
      
      private var _tmpVec1:Vector3D = new Vector3D();
      
      private var _tmpVec2:Vector3D = new Vector3D();
      
      protected var _losObjects:Vector.<Object3D>;
      
      protected var _zoomSteps:Array = [0.4,0.55,0.8,1];
      
      protected var _rand:SeedRandom;
      
      protected var _sceneModel:SceneModel;
      
      protected var _xmlDescriptor:XML;
      
      protected var _disposed:Boolean;
      
      protected var _map:Map;
      
      private var _mouseMap:MouseMap;
      
      public var animateCamera:Boolean = true;
      
      public var resourceUploadList:Vector.<Resource>;
      
      public function Scene()
      {
         super();
         this.resourceUploadList = new Vector.<Resource>();
         this._rotationStep = 0;
         this._zoomStep = this._zoomSteps.length - 1;
         this._cameraDummy = {
            "rotationX":this.ROTATION_X,
            "rotationZ":this.ROTATION_Z - 90 * this._rotationStep,
            "zoom":this._zoomSteps[this._zoomStep]
         };
         this._entitiesByName = new Dictionary(true);
         this._losObjects = new Vector.<Object3D>();
         this._rand = new SeedRandom();
         this._shadow = new DirectionalLightShadow(10000,10000,-100000,100000,Settings.SHADOWS_HIGH ? 2048 : 512,0.75);
         this._shadow.biasMultiplier = Settings.SHADOWS_HIGH ? 0.9998 : 0.9995;
         this._shadowCasters = new Vector.<Object3D>();
         this._camera = new OrthoCamera();
         this._scene = new Object3D();
         this._core = new Object3D();
         this._core.addChild(this._scene);
         this._root = new Object3D();
         this._root.addChild(this._camera);
         this._root.addChild(this._core);
         this._camera.rotationX = this._cameraDummy.rotationX * Math.PI / 180;
         this._core.rotationZ = this._cameraDummy.rotationZ * Math.PI / 180;
         this._core.scaleX = this._core.scaleY = this._core.scaleZ = this._cameraDummy.zoom;
         this._map = new Map();
         Settings.getInstance().settingChanged.add(this.onSettingChanged);
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
      }
      
      public function addEntity(param1:GameEntity) : GameEntity
      {
         if(Boolean(this._entitiesByName[param1.name]) && this._entitiesByName[param1.name] != param1)
         {
         }
         if(param1.scene == this)
         {
            return null;
         }
         if(param1.scene != null && param1.scene != this)
         {
            param1.scene.removeEntity(param1);
         }
         param1.scene = this;
         param1.prev = this._entityListTail;
         if(this._entityListTail)
         {
            this._entityListTail.next = param1;
         }
         this._entityListTail = param1;
         if(this._entityListHead == null)
         {
            this._entityListHead = param1;
         }
         this._entitiesByName[param1.name] = param1;
         param1.updateTransform();
         param1.transformChanged = true;
         if(param1.castsShadows)
         {
            this.addShadowCaster(param1.asset);
         }
         if(param1.losVisible)
         {
            this._losObjects.push(param1.asset);
         }
         param1.assetInvalidated.add(this.onEntityAssetInvalidated);
         param1.nameChanged.add(this.onEntityNameChanged);
         param1.addedToScene.dispatch(param1);
         this.onEntityAssetInvalidated(param1);
         if(!(param1.flags & GameEntityFlags.IGNORE_TILEMAP))
         {
            if(param1.asset != null && !(param1.flags & GameEntityFlags.IGNORE_TRANSFORMS))
            {
               Object3DUtils.calculateHierarchyBoundBox(param1.asset,param1.asset,param1.asset.boundBox);
            }
            this._map.updateCellsForEntity(param1);
         }
         return param1;
      }
      
      public function updateLOSForEntity(param1:GameEntity) : void
      {
         var _loc2_:int = int(this._losObjects.indexOf(param1.asset));
         if(param1.losVisible)
         {
            if(_loc2_ > -1)
            {
               return;
            }
            this._losObjects.push(param1.asset);
         }
         else if(_loc2_ > -1)
         {
            this._losObjects.splice(_loc2_,1);
         }
      }
      
      public function populateFromDescriptor(param1:XML, param2:Number = 0, param3:Boolean = true) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         this._xmlDescriptor = param1;
         this._losObjects.length = 0;
         if(param3 && this._mouseMap != null)
         {
            this._mouseMap.dispose();
            this._mouseMap = null;
         }
         if(param3 && Boolean(param1.hasOwnProperty("map")))
         {
            _loc4_ = this._xmlDescriptor.map[0];
            this._map.set(int(_loc4_.@x.toString()),int(_loc4_.@y.toString()),int(_loc4_.@width.toString()),int(_loc4_.@height.toString()),this._xmlDescriptor.map.toString().split(" "));
            this._mouseMap = new MouseMap(this._map.position.x,this._map.position.y,this._map.size.x,this._map.size.y,this._map.cellSize);
            this._scene.addChild(this._mouseMap.display);
            this.queueResourcesForUpload(this._mouseMap.display);
         }
         this.populateRandomizedElements(param2);
      }
      
      public function dispose() : void
      {
         var _loc1_:Resource = null;
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         TweenMax.killTweensOf(this._cameraDummy);
         Settings.getInstance().settingChanged.remove(this.onSettingChanged);
         for each(_loc1_ in this._scene.getResources(true))
         {
            _loc1_.dispose();
         }
         if(this._camera.parent != null)
         {
            this._camera.parent.removeChild(this._camera);
         }
         if(this._camera.diagram.parent != null)
         {
            this._camera.diagram.parent.removeChild(this._camera.diagram);
         }
         this._camera.view = null;
         this._camera = null;
         this._cameraDummy = null;
         if(this._scene.parent != null)
         {
            this._scene.parent.removeChild(this._scene);
         }
         if(this._core.parent != null)
         {
            this._core.parent.removeChild(this._core);
         }
         if(this._root.parent != null)
         {
            this._root.parent.removeChild(this._root);
         }
         this._scene = this._core = this._root = null;
         this.removeAllEntities(true);
         this._entitiesByName = null;
         this._entityListHead = null;
         this._entityListTail = null;
         this._map.dispose();
         this._mouseMap.dispose();
         this._losObjects = null;
         this._shadowCasters = null;
         this._shadow.clearCasters();
         this._shadow = null;
         this.resourceUploadList = null;
      }
      
      public function getEntityByName(param1:String) : GameEntity
      {
         return this._entitiesByName[param1];
      }
      
      public function removeAllEntities(param1:Boolean = false) : void
      {
         var _loc3_:GameEntity = null;
         var _loc2_:GameEntity = this._entityListHead;
         while(_loc2_)
         {
            _loc3_ = _loc2_.next;
            _loc2_.next = null;
            _loc2_.scene = null;
            _loc2_.assetInvalidated.remove(this.onEntityAssetInvalidated);
            _loc2_.nameChanged.remove(this.onEntityNameChanged);
            this._entitiesByName[_loc2_.name] = null;
            delete this._entitiesByName[_loc2_.name];
            if(Boolean(_loc2_.asset) && _loc2_.asset.parent == this._scene)
            {
               this._scene.removeChild(_loc2_.asset);
            }
            if(param1)
            {
               _loc2_.dispose();
            }
            _loc2_ = _loc3_;
         }
         this._entityListHead = null;
         this._entityListTail = null;
         this._map.clearEntities();
         this._shadow.clearCasters();
         this._shadowCasters.length = 0;
      }
      
      public function removeEntity(param1:GameEntity) : GameEntity
      {
         var _loc2_:int = 0;
         if(this._disposed)
         {
            return param1;
         }
         if(param1 == null || param1.scene != this)
         {
            return param1;
         }
         if(param1.asset != null && param1.asset.parent == this._scene)
         {
            this._scene.removeChild(param1.asset);
         }
         if(this._entitiesByName[param1.name] == param1)
         {
            this._entitiesByName[param1.name] = null;
            delete this._entitiesByName[param1.name];
         }
         if(this._entityListHead == param1)
         {
            this._entityListHead = param1.next;
         }
         if(this._entityListTail == param1)
         {
            this._entityListTail = param1.prev;
         }
         if(param1.prev != null)
         {
            param1.prev.next = param1.next;
         }
         if(param1.next != null)
         {
            param1.next.prev = param1.prev;
         }
         param1.next = null;
         param1.prev = null;
         param1.nameChanged.remove(this.onEntityNameChanged);
         param1.assetInvalidated.remove(this.onEntityAssetInvalidated);
         param1.removedFromScene.dispatch(param1);
         param1.scene = null;
         if(param1.castsShadows)
         {
            this.removeShadowCaster(param1.asset);
         }
         if(param1.losVisible)
         {
            _loc2_ = int(this._losObjects.indexOf(param1.asset));
            if(_loc2_ > -1)
            {
               this._losObjects.splice(_loc2_,1);
            }
         }
         this._map.removeEntity(param1);
         return param1;
      }
      
      public function removeEntityByName(param1:String) : GameEntity
      {
         var _loc2_:GameEntity = this._entitiesByName[param1];
         return _loc2_ ? this.removeEntity(_loc2_) : null;
      }
      
      public function update(param1:Number) : void
      {
         this._map.pathfinder.executeJobQueue(2);
         var _loc2_:GameEntity = this._entityListHead;
         while(_loc2_ != null)
         {
            _loc2_.update(param1);
            if(!(_loc2_.flags & GameEntityFlags.IGNORE_TILEMAP) && !(_loc2_.flags & GameEntityFlags.IGNORE_TRANSFORMS) && _loc2_.transformChanged)
            {
               this._map.updateCellsForEntity(_loc2_,true);
            }
            _loc2_.transformChanged = false;
            _loc2_ = _loc2_.next;
         }
         if(this._sceneModel)
         {
            this._sceneModel.updateAnimation(param1);
         }
      }
      
      public function getCurrentZoom() : Number
      {
         return this._cameraDummy.zoom;
      }
      
      public function translate(param1:Number, param2:Number, param3:Number) : void
      {
         this._scene.x += param1;
         this._scene.y += param2;
         this._scene.y += param3;
      }
      
      public function translateFrom2D(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = this._core.rotationZ;
         var _loc4_:Number = 1 / this._core.scaleX;
         if(this._rotationStep % 2 != 0)
         {
            param2 *= -1;
            param1 *= -1;
         }
         var _loc5_:Number = Math.cos(_loc3_);
         var _loc6_:Number = Math.sin(_loc3_);
         this._scene.x += (param2 * _loc5_ + param1 * _loc6_) * _loc4_;
         this._scene.y += (param2 * _loc6_ - param1 * _loc5_) * _loc4_;
      }
      
      public function centerOn(param1:Number, param2:Number, param3:Number = 0) : void
      {
         TweenMax.killTweensOf(this._scene);
         this._scene.x = -param1;
         this._scene.y = -param2;
         this._scene.z = -param3;
      }
      
      public function panTo(param1:Number, param2:Number, param3:Number = 0, param4:Number = 0.35, param5:Object = null) : void
      {
         param5 ||= {};
         param5.x = -param1;
         param5.y = -param2;
         param5.z = -param3;
         if(!this.animateCamera)
         {
            param4 = 0;
         }
         if(!param5.ease)
         {
            param5.ease = Quad.easeInOut;
         }
         TweenMax.to(this._scene,param4,param5);
      }
      
      public function getScreenPosition(param1:Number, param2:Number, param3:Number, param4:Point = null) : Point
      {
         return this.sceneToScreen(this._scene,param1,param2,param3,param4);
      }
      
      public function getEntityScreenPosition(param1:GameEntity, param2:Point = null) : Point
      {
         return this.sceneToScreen(this._scene,param1.transform.position.x,param1.transform.position.y,param1.transform.position.z,param2);
      }
      
      public function getEntityScreenPositionByName(param1:String, param2:Point = null) : Point
      {
         var _loc3_:GameEntity = this.getEntityByName(param1);
         return this.sceneToScreen(this._scene,_loc3_.transform.position.x,_loc3_.transform.position.y,_loc3_.transform.position.z,param2);
      }
      
      public function sceneToScreen(param1:Object3D, param2:Number, param3:Number, param4:Number, param5:Point = null) : Point
      {
         this._tmpVec2.setTo(param2,param3,param4);
         this._camera.projectGlobal(param1.localToGlobal(this._tmpVec2,this._tmpVec1),this._tmpVec1);
         param5 ||= new Point();
         param5.setTo(this._tmpVec1.x,this._tmpVec1.y);
         return param5;
      }
      
      private function sceneToScreen2(param1:Object3D, param2:Vector3D, param3:Point = null) : Point
      {
         this._camera.projectGlobal(param1.localToGlobal(param2,this._tmpVec1),this._tmpVec1);
         param3 ||= new Point();
         param3.setTo(this._tmpVec1.x,this._tmpVec1.y);
         return param3;
      }
      
      public function setZoomSteps(param1:Array) : void
      {
         this._zoomSteps = param1;
      }
      
      public function getAllResources() : Vector.<Resource>
      {
         return this._root.getResources(true);
      }
      
      public function addShadowCaster(param1:Object3D) : void
      {
         if(this._shadowCasters.indexOf(param1) > -1)
         {
            return;
         }
         this._shadowCasters.push(param1);
         this.refreshShadowCasters();
      }
      
      public function removeShadowCaster(param1:Object3D) : void
      {
         var _loc2_:int = int(this._shadowCasters.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._shadowCasters.splice(_loc2_,1);
         this.refreshShadowCasters();
      }
      
      public function refreshShadowCasters() : void
      {
         var _loc1_:Object3D = null;
         this._shadow.clearCasters();
         true;
         for each(_loc1_ in this._shadowCasters)
         {
            this._shadow.addCaster(_loc1_);
         }
      }
      
      protected function createEntity(param1:XML) : GameEntity
      {
         var _loc2_:GameEntity = new GameEntity();
         this.addProperties(param1,_loc2_);
         this.addTriggers(param1,_loc2_);
         return _loc2_;
      }
      
      protected function addProperties(param1:XML, param2:GameEntity) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Number = Number(NaN);
         var _loc3_:XMLList = param1.prop;
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = String(_loc4_.@name);
            if(_loc5_ != null)
            {
               _loc6_ = _loc4_.toString();
               _loc7_ = Number(parseFloat(_loc6_));
               param2.properties[_loc5_] = isNaN(_loc7_) ? _loc6_ : _loc7_;
            }
         }
      }
      
      protected function addTriggers(param1:XML, param2:GameEntity) : void
      {
         var _loc4_:XML = null;
         var _loc5_:uint = 0;
         var _loc3_:XMLList = param1.trigger;
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = uint(_loc4_.@type);
            if(_loc5_ > EntityTrigger.None)
            {
               param2.addTrigger(_loc5_,_loc4_.toString());
            }
         }
      }
      
      private function queueResourcesForUpload(param1:Object3D, param2:Boolean = true) : void
      {
         var _loc3_:Resource = null;
         for each(_loc3_ in param1.getResources(param2))
         {
            if(!_loc3_.isUploaded)
            {
               this.resourceUploadList.push(_loc3_);
            }
         }
      }
      
      protected function populateRandomizedElements(param1:Number = 0) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:GameEntity = null;
         var _loc7_:XML = null;
         var _loc8_:XMLList = null;
         var _loc9_:XML = null;
         var _loc10_:String = null;
         var _loc11_:OmniLightEntity = null;
         var _loc12_:Array = null;
         var _loc13_:MeshGroup = null;
         var _loc14_:String = null;
         var _loc15_:Boolean = false;
         var _loc16_:String = null;
         var _loc17_:Object3D = null;
         var _loc18_:Number = Number(NaN);
         var _loc5_:Array = ["x","y","z"];
         if(!this._xmlDescriptor)
         {
            return;
         }
         this._rand.seed = isNaN(param1) ? getTimer() : param1;
         if(Boolean(this._xmlDescriptor.hasOwnProperty("scene_mdl")) && Boolean(this._xmlDescriptor.scene_mdl.hasOwnProperty("mdl")))
         {
            this.setSceneModels(this._xmlDescriptor.scene_mdl.mdl);
         }
         else
         {
            this.setSceneModels(null);
         }
         _loc3_ = 0;
         var _loc6_:XMLList = this._xmlDescriptor.ent.light;
         for each(_loc7_ in _loc6_)
         {
            _loc10_ = _loc7_.hasOwnProperty("@name") ? _loc7_.@name.toString() : "light" + _loc3_++;
            this.removeEntityByName(_loc10_);
            switch(_loc7_.@type.toString())
            {
               case "omni":
                  _loc11_ = new OmniLightEntity();
                  _loc11_.name = _loc10_;
                  _loc11_.light.color = parseInt(String(_loc7_.@color.toString()).substr(1),16);
                  _loc11_.light.intensity = Number(_loc7_.@intensity);
                  OmniLight(_loc11_.light).attenuationBegin = Number(_loc7_.@attstart);
                  OmniLight(_loc11_.light).attenuationEnd = Number(_loc7_.@attend);
                  _loc11_.transform.position.x = Number(_loc7_.@x);
                  _loc11_.transform.position.y = Number(_loc7_.@y);
                  _loc11_.transform.position.z = Number(_loc7_.@z);
                  this.addEntity(_loc11_);
            }
         }
         _loc3_ = 0;
         _loc8_ = this._xmlDescriptor.ent.e;
         for each(_loc9_ in _loc8_)
         {
            _loc14_ = _loc9_.hasOwnProperty("@name") ? _loc9_.@name.toString() : "entity" + _loc3_++;
            _loc15_ = Boolean(_loc9_.hasOwnProperty("@hideable")) && _loc9_.@hideable.toString() == "1" ? this._rand.getRandom() < 0.3 : false;
            this.removeEntityByName(_loc14_);
            if(true)
            {
               if(_loc15_)
               {
                  continue;
               }
            }
            _loc16_ = "";
            if(_loc9_.hasOwnProperty("mdl") && _loc9_.mdl.@uri.length() > 0)
            {
               _loc16_ = _loc9_.mdl.@uri.toString();
            }
            else if(_loc9_.hasOwnProperty("opt") && _loc9_.opt.hasOwnProperty("mdl") && _loc9_.opt.mdl.@uri.length() > 0)
            {
               _loc16_ = _loc9_.opt.mdl.@uri.toString();
            }
            if(!ResourceManager.getInstance().exists(_loc16_))
            {
               Cc.warn("[source was edited before] Resource not found: " + _loc16_);
            }
            else
            {
               _loc13_ = new MeshGroup();
               _loc13_.name = "meshEntity";
               _loc13_.mouseEnabled = _loc13_.mouseChildren = false;
               _loc13_.addChildrenFromResource(_loc16_);
               _loc17_ = new Object3D();
               _loc17_.mouseEnabled = false;
               _loc17_.addChild(_loc13_);
               _loc4_ = this.createEntity(_loc9_);
               _loc4_.name = _loc14_;
               _loc4_.asset = _loc17_;
               _loc4_.passable = _loc9_.hasOwnProperty("@pass") && _loc9_.@pass.toString() == "1" || _loc15_ ? true : false;
               _loc4_.losVisible = _loc9_.hasOwnProperty("@los") ? Boolean(int(_loc9_.@los.toString())) : true;
               _loc4_.castsShadows = _loc9_.hasOwnProperty("@shadow") ? Boolean(int(_loc9_.@shadow.toString())) : true;
               _loc4_.transform.position.x = Number(_loc9_.@x);
               _loc4_.transform.position.y = Number(_loc9_.@y);
               _loc4_.transform.position.z = Number(_loc9_.@z);
               if(!_loc15_)
               {
                  if(_loc9_.hasOwnProperty("s"))
                  {
                     _loc12_ = _loc9_.s.toString().split(" ");
                     _loc18_ = this._rand.getNumInRange(Number(_loc12_[0]),Number(_loc12_[1]));
                     _loc13_.scaleX = _loc13_.scaleY = _loc13_.scaleZ = _loc18_;
                  }
                  else
                  {
                     for each(_loc2_ in _loc5_)
                     {
                        if(_loc9_.hasOwnProperty("s" + _loc2_))
                        {
                           _loc12_ = _loc9_["s" + _loc2_].toString().split(" ");
                           _loc13_["scale" + _loc2_.toUpperCase()] = this._rand.getNumInRange(Number(_loc12_[0]),Number(_loc12_[1]));
                        }
                     }
                  }
                  for each(_loc2_ in _loc5_)
                  {
                     if(_loc9_.hasOwnProperty("r" + _loc2_))
                     {
                        _loc12_ = _loc9_["r" + _loc2_].toString().split(" ");
                        _loc13_["rotation" + _loc2_.toUpperCase()] = this._rand.getNumInRange(Number(_loc12_[0]),Number(_loc12_[1])) * Math.PI / 180;
                     }
                  }
                  for each(_loc2_ in _loc5_)
                  {
                     if(_loc9_.hasOwnProperty("t" + _loc2_))
                     {
                        _loc12_ = _loc9_["t" + _loc2_].toString().split(" ");
                        _loc13_[_loc2_] += this._rand.getNumInRange(Number(_loc12_[0]),Number(_loc12_[1]));
                     }
                  }
               }
               _loc17_.boundBox = new BoundBox();
               Object3DUtils.calculateHierarchyBoundBox(_loc17_,_loc17_,_loc17_.boundBox);
               this.addEntity(_loc4_);
               _loc4_.updateBoundingBox();
            }
         }
      }
      
      protected function setSceneModels(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:Resource = null;
         if(this._sceneModel)
         {
            if(this._sceneModel.parent != null)
            {
               this._sceneModel.parent.removeChild(this._sceneModel);
            }
            for each(_loc3_ in this._sceneModel.getResources(true))
            {
               _loc3_.dispose();
            }
            this._sceneModel = null;
         }
         if(!param1 || param1.length() == 0)
         {
            return;
         }
         this._sceneModel = new SceneModel();
         for each(_loc2_ in param1)
         {
            this._sceneModel.addChildrenFromResource(_loc2_.@uri.toString(),false);
         }
         this._scene.addChild(this._sceneModel);
         this.queueResourcesForUpload(this._sceneModel,true);
      }
      
      private function onEntityAssetInvalidated(param1:GameEntity) : void
      {
         if(!param1.asset)
         {
            return;
         }
         if(param1.asset.parent != this._scene)
         {
            this._scene.addChild(param1.asset);
            param1.updateAssetLocalBounds(true);
            if(!(param1.flags & GameEntityFlags.IGNORE_TILEMAP) && !(param1.flags & GameEntityFlags.IGNORE_TRANSFORMS))
            {
               this._map.updateCellsForEntity(param1);
            }
         }
         this.queueResourcesForUpload(param1.asset);
      }
      
      private function onEntityNameChanged(param1:GameEntity, param2:String) : void
      {
         if(this._entitiesByName == null || param1 == null)
         {
            return;
         }
         if(this._entitiesByName[param2] == param1)
         {
            this._entitiesByName[param2] = null;
            delete this._entitiesByName[param2];
         }
         this._entitiesByName[param1.name] = param1;
      }
      
      private function onSettingChanged(param1:String, param2:Object) : void
      {
         if(param1 == "shadows")
         {
            switch(param2)
            {
               case Settings.SHADOWS_OFF:
                  this._shadow.clearCasters();
                  break;
               case Settings.SHADOWS_HIGH:
                  this._shadow.mapSize = 2048;
                  this._shadow.biasMultiplier = 0.9998;
                  this.refreshShadowCasters();
                  break;
               case Settings.SHADOWS_LOW:
                  this._shadow.mapSize = 512;
                  this._shadow.biasMultiplier = 0.9995;
                  this.refreshShadowCasters();
            }
         }
      }
      
      public function get camera() : OrthoCamera
      {
         return this._camera;
      }
      
      public function get container() : Object3D
      {
         return this._scene;
      }
      
      public function get entityListHead() : GameEntity
      {
         return this._entityListHead;
      }
      
      public function get map() : Map
      {
         return this._map;
      }
      
      public function get mouseMap() : MouseMap
      {
         return this._mouseMap;
      }
      
      public function get sceneModel() : SceneModel
      {
         return this._sceneModel;
      }
      
      public function get shadow() : DirectionalLightShadow
      {
         return this._shadow;
      }
      
      public function get losObjects() : Vector.<Object3D>
      {
         return this._losObjects;
      }
      
      public function get rotation() : Number
      {
         return this._rotationStep;
      }
      
      public function set rotation(param1:Number) : void
      {
         var value:Number = param1;
         if(value < 0)
         {
            value = 0;
         }
         else if(value >= this.ROTATION_STEPS)
         {
            value = this.ROTATION_STEPS - 1;
         }
         if(value == this._rotationStep)
         {
            return;
         }
         this._rotationStep = value;
         TweenMax.to(this._cameraDummy,this.animateCamera ? 0.3 : 0,{
            "shortRotation":{"rotationZ":this.ROTATION_Z - 90 * this._rotationStep},
            "ease":Quad.easeInOut,
            "onUpdate":function():void
            {
               _core.rotationZ = _cameraDummy.rotationZ * Math.PI / 180;
            }
         });
      }
      
      public function get zoom() : int
      {
         return this._zoomStep;
      }
      
      public function set zoom(param1:int) : void
      {
         var value:int = param1;
         if(value < 0)
         {
            value = 0;
         }
         else if(value >= this._zoomSteps.length)
         {
            value = int(this._zoomSteps.length - 1);
         }
         if(value == this._zoomStep)
         {
            return;
         }
         this._zoomStep = value;
         TweenMax.to(this._cameraDummy,this.animateCamera ? 0.3 : 0,{
            "zoom":this._zoomSteps[this._zoomStep],
            "ease":(TweenMax.isTweening(this._cameraDummy) ? Quad.easeOut : Quad.easeInOut),
            "onUpdate":function():void
            {
               _core.scaleX = _core.scaleY = _core.scaleZ = _cameraDummy.zoom;
            }
         });
      }
      
      public function get xmlDescriptor() : XML
      {
         return this._xmlDescriptor;
      }
      
      public function get x() : Number
      {
         return this._scene.x;
      }
      
      public function get y() : Number
      {
         return this._scene.y;
      }
      
      public function get z() : Number
      {
         return this._scene.z;
      }
   }
}

