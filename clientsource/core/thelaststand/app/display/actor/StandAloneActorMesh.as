package thelaststand.app.display.actor
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.animation.AnimationController;
   import alternativa.engine3d.animation.AnimationSwitcher;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.engine3d.utils.Object3DUtils;
   import flash.display.BitmapData;
   import flash.external.ExternalInterface;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.HumanAppearance;
   import thelaststand.app.game.data.IActorAppearance;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.MaterialLibrary;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.alternativa.engine3d.primitives.Plane;
   import thelaststand.engine.utils.TextureBuilder;
   
   public class StandAloneActorMesh extends Mesh
   {
      
      private var _flatNorm:BitmapData = MaterialLibrary.createFlatNormal();
      
      private var _currentAnim:AnimationClip;
      
      private var _currentAnimName:String;
      
      private var _shadow:thelaststand.engine.alternativa.engine3d.primitives.Plane;
      
      private var _loader:AssetLoader;
      
      private var _animsByName:Dictionary;
      
      private var _switcher:AnimationSwitcher;
      
      private var _controller:AnimationController;
      
      private var _appearance:IActorAppearance;
      
      public var includeGear:Boolean = true;
      
      public var appearanceChanged:Signal = new Signal();
      
      public function StandAloneActorMesh()
      {
         super();
         this._loader = new AssetLoader();
         this._animsByName = new Dictionary(true);
         this._switcher = new AnimationSwitcher();
         this._controller = new AnimationController();
         this._controller.root = this._switcher;
         boundBox = new BoundBox();
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
      }
      
      public function clear() : void
      {
         var _loc1_:int = 0;
         var _loc2_:alternativa.engine3d.core.Resource = null;
         var _loc3_:AnimationClip = null;
         var _loc4_:Object3D = null;
         var _loc5_:Mesh = null;
         this._loader.loadingCompleted.removeAll();
         this._loader.clear(false);
         for each(_loc2_ in getResources(true))
         {
            _loc2_.dispose();
         }
         _loc1_ = this._switcher.numAnimations() - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = this._switcher.getAnimationAt(_loc1_) as AnimationClip;
            this._switcher.removeAnimation(_loc3_);
            _loc3_.objects.length = 0;
            _loc3_.notifiers.length = 0;
            _loc3_.alternativa3d::_parent = null;
            _loc3_.alternativa3d::controller = null;
            _loc1_--;
         }
         _loc1_ = numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc4_ = getChildAt(_loc1_);
            if(_loc4_ != null)
            {
               removeChild(_loc4_);
               _loc5_ = _loc4_ as Mesh;
               if(_loc5_ != null)
               {
                  _loc5_.geometry = null;
               }
            }
            _loc1_--;
         }
         this._shadow = null;
         this._currentAnim = null;
         this._currentAnimName = null;
         this._appearance = null;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.clear();
         this._loader = null;
         this._animsByName = null;
         this._flatNorm.dispose();
         this._flatNorm = null;
         this._switcher = null;
         this._controller.root = null;
         this._controller = null;
         this._appearance = null;
      }
      
      public function addMesh(param1:String, param2:Boolean = false, param3:Vector.<String> = null) : Object3D
      {
         var _loc8_:Object3D = null;
         var _loc9_:Mesh = null;
         var _loc10_:Object3D = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:ParserMaterial = null;
         var _loc4_:thelaststand.common.resources.Resource = ResourceManager.getInstance().getResource(param1);
         if(_loc4_ == null)
         {
            return new Object3D();
         }
         var _loc5_:ByteArray = _loc4_.getRawData();
         var _loc6_:ParserCollada = new ParserCollada();
         _loc6_.parse(XML(_loc5_.readUTFBytes(_loc5_.length)));
         var _loc7_:Object3D = new Object3D();
         _loc7_.rotationX = Math.PI * 0.5;
         addChild(_loc7_);
         for each(_loc8_ in _loc6_.objects)
         {
            if(_loc8_.name != "EnvironmentAmbientLight")
            {
               if(!(param3 != null && this.importShouldIgnore(_loc8_,param3)))
               {
                  if(_loc8_ is Mesh)
                  {
                     _loc9_ = _loc8_ as Mesh;
                     _loc11_ = _loc8_.numChildren - 1;
                     while(_loc11_ >= 0)
                     {
                        _loc10_ = _loc8_.getChildAt(_loc11_);
                        if(param3 != null && this.importShouldIgnore(_loc10_,param3))
                        {
                           _loc8_.removeChild(_loc10_);
                        }
                        _loc11_--;
                     }
                     if(!param2)
                     {
                        _loc11_ = 0;
                        _loc12_ = _loc9_.numSurfaces;
                        while(_loc11_ < _loc12_)
                        {
                           _loc13_ = _loc9_.getSurface(_loc11_).material as ParserMaterial;
                           if(_loc13_ != null)
                           {
                              _loc9_.getSurface(_loc11_).material = this.getMaterialFromParser(_loc13_);
                           }
                           _loc11_++;
                        }
                     }
                     _loc7_.addChild(_loc9_);
                     _loc9_.calculateBoundBox();
                  }
               }
            }
         }
         return _loc7_;
      }
      
      public function addShadow() : void
      {
         var _loc1_:StandardMaterial = null;
         if(this._shadow == null)
         {
            _loc1_ = this.getMaterial("models/characters/shadow.png");
            _loc1_.alpha = 0.75;
            _loc1_.alphaThreshold = 0.5;
            this._shadow = new thelaststand.engine.alternativa.engine3d.primitives.Plane(100,100,true);
            this._shadow.setMaterialToAllSurfaces(_loc1_);
            this._shadow.rotationX = Math.PI * 0.5;
         }
         addChild(this._shadow);
      }
      
      public function addAnimation(param1:String, param2:AnimationClip) : void
      {
         var _loc3_:AnimationClip = param2.clone();
         _loc3_.attach(this,true);
         this._switcher.addAnimation(_loc3_);
         this._animsByName[param1] = _loc3_;
      }
      
      public function removeObject(param1:Object3D) : void
      {
         var _loc2_:alternativa.engine3d.core.Resource = null;
         if(param1.parent != this)
         {
            return;
         }
         this.removeChild(param1);
         for each(_loc2_ in param1.getResources(true))
         {
            _loc2_.dispose();
         }
      }
      
      public function setAppearance(param1:IActorAppearance) : void
      {
         var appearance:IActorAppearance = param1;
         this._appearance = appearance;
         this._loader.clear();
         this._loader.loadingCompleted.removeAll();
         this._loader.loadingCompleted.addOnce(function():void
         {
            applyAppearance();
         });
         this._loader.loadAssets(this._appearance.getResourceURIs());
      }
      
      public function setAnimation(param1:String, param2:Boolean = true, param3:Number = 1) : void
      {
         var _loc4_:AnimationClip = this._animsByName[param1];
         if(_loc4_ == null)
         {
            return;
         }
         this._currentAnim = this._animsByName[param1];
         this._currentAnimName = param1;
         if(param2)
         {
            this._currentAnim.animated = true;
            this._currentAnim.speed = param3;
            this._currentAnim.loop = true;
            this._currentAnim.time = 0;
         }
         else
         {
            this._currentAnim.animated = false;
            this._currentAnim.time = 0;
         }
         this._switcher.activate(this._currentAnim,0);
      }
      
      public function update() : void
      {
         this._controller.update();
      }
      
      private function applyAppearance() : void
      {
         var _loc1_:Surface = null;
         var _loc4_:AttireData = null;
         var _loc5_:Object3D = null;
         var _loc6_:Mesh = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(this._appearance.data.length);
         for(; _loc2_ < _loc3_; _loc2_++)
         {
            _loc4_ = this._appearance.data[_loc2_];
            if(_loc4_.model == null)
            {
               continue;
            }
            if(!this.includeGear && _loc4_.type == "gear")
            {
               continue;
            }
            _loc5_ = this.addMesh(_loc4_.model);
            if(_loc5_ == null || _loc5_.numChildren == 0)
            {
               continue;
            }
            _loc6_ = _loc5_.getChildAt(0) as Mesh;
            if(_loc6_ == null)
            {
               continue;
            }
            switch(_loc4_.type)
            {
               case "upper":
               case "lower":
                  this.setAppearanceMaterials(_loc6_,_loc4_);
                  break;
               case "hair":
               case "fhair":
                  this.setAppearanceMaterialsForSurface(_loc6_,0,_loc4_);
                  break;
               default:
                  this.setAppearanceMaterials(_loc6_,_loc4_);
            }
         }
         Object3DUtils.calculateHierarchyBoundBox(this,this,boundBox);
         this.appearanceChanged.dispatch();
      }
      
      private function setAppearanceMaterials(param1:Mesh, param2:AttireData) : void
      {
         if(param1 == null || param2 == null)
         {
            return;
         }
         this.setAppearanceMaterialsForSurface(param1,HumanActor.SURFACE_CLOTHING,param2);
         var _loc3_:HumanAppearance = this._appearance as HumanAppearance;
         if(_loc3_ != null && _loc3_.skin.texture != null)
         {
            this.setAppearanceMaterialsForSurface(param1,HumanActor.SURFACE_SKIN,_loc3_.skin);
         }
      }
      
      private function setAppearanceMaterialsForSurface(param1:Mesh, param2:int, param3:AttireData) : void
      {
         var _loc4_:Surface = null;
         var _loc5_:Array = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.numSurfaces > param2)
         {
            _loc4_ = param1.getSurface(param2);
            if(_loc4_ == null)
            {
               return;
            }
            _loc5_ = this._appearance.getOverlays(param3.type);
            _loc4_.material = this.getMaterial(TextureBuilder.buildTexture(param3,_loc5_));
         }
      }
      
      private function getMaterialFromParser(param1:ParserMaterial) : Material
      {
         var _loc2_:String = null;
         var _loc4_:String = null;
         var _loc5_:BitmapTextureResource = null;
         var _loc11_:ExternalTextureResource = null;
         var _loc12_:String = null;
         var _loc3_:Dictionary = new Dictionary(true);
         for(_loc4_ in param1.textures)
         {
            _loc11_ = ExternalTextureResource(param1.textures[_loc4_]);
            _loc12_ = MaterialLibrary.formatColladaURL(_loc11_.url);
            _loc3_[_loc4_] = _loc12_;
         }
         _loc5_ = _loc3_.diffuse ? new BitmapTextureResource(ResourceManager.getInstance().getResource(_loc3_.diffuse).content as BitmapData) : null;
         var _loc6_:BitmapTextureResource = _loc3_.bump ? new BitmapTextureResource(ResourceManager.getInstance().getResource(_loc3_.bump).content as BitmapData) : new BitmapTextureResource(this._flatNorm);
         var _loc7_:BitmapTextureResource = _loc3_.specular ? new BitmapTextureResource(ResourceManager.getInstance().getResource(_loc3_.specular).content as BitmapData) : null;
         var _loc8_:BitmapTextureResource = _loc3_.shininess ? new BitmapTextureResource(ResourceManager.getInstance().getResource(_loc3_.shininess).content as BitmapData) : null;
         var _loc9_:BitmapTextureResource = _loc3_.transparent ? new BitmapTextureResource(ResourceManager.getInstance().getResource(_loc3_.transparent).content as BitmapData) : null;
         var _loc10_:StandardMaterial = new StandardMaterial(_loc5_,_loc6_,_loc7_,_loc8_,_loc9_);
         _loc10_.specularPower = 0;
         _loc10_.opaquePass = true;
         if(_loc9_ != null || _loc3_.diffuse.indexOf(".png") > -1)
         {
            _loc10_.alphaThreshold = 0.9;
            _loc10_.transparentPass = true;
         }
         else
         {
            _loc10_.alphaThreshold = 0;
            _loc10_.transparentPass = false;
         }
         return _loc10_;
      }
      
      private function getMaterial(param1:String) : StandardMaterial
      {
         log("getting material for: " + param1);
         var _loc2_:BitmapTextureResource = new BitmapTextureResource(ResourceManager.getInstance().getResource(param1).content as BitmapData);
         var _loc3_:BitmapTextureResource = new BitmapTextureResource(this._flatNorm);
         var _loc4_:StandardMaterial = new StandardMaterial(_loc2_,_loc3_);
         _loc4_.specularPower = 0;
         _loc4_.opaquePass = true;
         if(_loc4_.opacityMap != null || param1.indexOf(".png") > -1)
         {
            _loc4_.alphaThreshold = 0.9;
            _loc4_.transparentPass = true;
         }
         else
         {
            _loc4_.alphaThreshold = 0;
            _loc4_.transparentPass = false;
         }
         return _loc4_;
      }
      
      private function importShouldIgnore(param1:Object3D, param2:Vector.<String>) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         if(param1.name == null)
         {
            return false;
         }
         var _loc3_:int = 0;
         var _loc4_:int = int(param2.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param2[_loc3_];
            if(_loc5_ == param1.name)
            {
               return true;
            }
            _loc6_ = int(_loc5_.indexOf("%"));
            if(_loc6_ > -1)
            {
               _loc7_ = _loc5_.substring(0,_loc6_);
               if(param1.name.substr(0,_loc7_.length) == _loc7_)
               {
                  return true;
               }
            }
            _loc3_++;
         }
         return false;
      }
      
      public function get currentAnimName() : String
      {
         return this._currentAnimName;
      }
   }
}

