package thelaststand.engine.meshes
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.utils.Object3DUtils;
   import thelaststand.app.core.Settings;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.lights.FlickeringOmniLight;
   
   public class MeshGroup extends Object3D
   {
      
      private var _lights:Vector.<Light3D>;
      
      private var _lightsNight:Vector.<Light3D>;
      
      public function MeshGroup(param1:String = null)
      {
         super();
         this._lights = new Vector.<Light3D>();
         this._lightsNight = new Vector.<Light3D>();
         boundBox = new BoundBox();
         if(param1 != null)
         {
            this.addChildrenFromResource(param1);
         }
      }
      
      public static function addChildren(param1:String, param2:Object3D, param3:Boolean = false, param4:Vector.<Object3D> = null) : Object3D
      {
         var _loc5_:ResourceManager = ResourceManager.getInstance();
         var _loc6_:Resource = _loc5_.getResource(param1.toLowerCase());
         if(_loc6_ == null)
         {
            return null;
         }
         var _loc7_:* = _loc6_.content;
         if(_loc7_ is ParserCollada)
         {
            addCollada(param2,ParserCollada(_loc7_),param3,param4);
         }
         return param2;
      }
      
      private static function addCollada(param1:Object3D, param2:ParserCollada, param3:Boolean = false, param4:Vector.<Object3D> = null) : void
      {
         var _loc8_:Object3D = null;
         var _loc9_:Array = null;
         var _loc10_:Mesh = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:ParserMaterial = null;
         var _loc14_:Class = null;
         var _loc15_:Light3D = null;
         var _loc5_:ResourceManager = ResourceManager.getInstance();
         var _loc6_:int = 0;
         var _loc7_:int = int(param2.objects.length);
         while(_loc6_ < _loc7_)
         {
            _loc8_ = param2.objects[_loc6_];
            _loc9_ = _loc8_.name != null ? _loc8_.name.split("_") : [];
            if(_loc8_ is Mesh)
            {
               _loc10_ = _loc8_.clone() as Mesh;
               _loc10_.name = _loc9_[0] == "att" ? _loc9_[0] + "_" + _loc9_[1] : _loc9_[0];
               _loc10_.mouseChildren = _loc10_.mouseEnabled = false;
               _loc10_.visible = true;
               if(!param3)
               {
                  _loc11_ = 0;
                  _loc12_ = _loc10_.numSurfaces;
                  while(_loc11_ < _loc12_)
                  {
                     _loc13_ = Mesh(_loc8_).getSurface(_loc11_).material as ParserMaterial;
                     if(_loc13_)
                     {
                        _loc14_ = _loc9_.indexOf("nl") > -1 ? TextureMaterial : null;
                        _loc10_.getSurface(_loc11_).material = _loc5_.materials.getMaterialFromParser(_loc13_,_loc14_);
                     }
                     _loc11_++;
                  }
               }
               _loc10_.calculateBoundBox();
               param1.addChild(_loc10_);
               if(param4 != null)
               {
                  param4.push(_loc10_);
               }
            }
            else if(_loc8_ is Light3D)
            {
               if(_loc8_.name != "EnvironmentAmbientLight")
               {
                  _loc15_ = _loc8_.clone() as Light3D;
                  if(_loc8_ is OmniLight && _loc8_.name != null && _loc8_.name.indexOf("Flicker") > -1)
                  {
                     _loc15_ = new FlickeringOmniLight(_loc8_ as OmniLight);
                  }
                  param1.addChild(_loc15_);
                  _loc15_.visible = Settings.getInstance().dynamicLights;
                  if(param4 != null)
                  {
                     param4.push(_loc15_);
                  }
               }
            }
            _loc6_++;
         }
         if(!param1.boundBox)
         {
            param1.boundBox = new BoundBox();
         }
         param1.boundBox.reset();
         Object3DUtils.calculateHierarchyBoundBox(param1,param1,param1.boundBox);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.disposeChildren(this);
         this.removeChildren();
         this._lights = null;
         this._lightsNight = null;
      }
      
      override public function removeChildren(param1:int = 0, param2:int = 2147483647) : void
      {
         super.removeChildren(param1,param2);
         this._lightsNight.length = 0;
         this._lights.length = 0;
      }
      
      public function removeObject(param1:Object3D) : void
      {
         var _loc3_:int = 0;
         if(param1 == null)
         {
            return;
         }
         if(contains(param1) && param1.parent != null)
         {
            param1.parent.removeChild(param1);
         }
         var _loc2_:Light3D = param1 as Light3D;
         if(_loc2_ != null)
         {
            _loc3_ = int(this._lights.indexOf(_loc2_));
            if(_loc3_ > -1)
            {
               this._lights.splice(_loc3_,1);
            }
            _loc3_ = int(this._lightsNight.indexOf(_loc2_));
            if(_loc3_ > -1)
            {
               this._lightsNight.splice(_loc3_,1);
            }
         }
      }
      
      public function addChildrenFromResource(param1:String, param2:Boolean = false, param3:Vector.<Object3D> = null) : void
      {
         var _loc4_:Object3D = null;
         var _loc5_:Light3D = null;
         param3 ||= new Vector.<Object3D>();
         MeshGroup.addChildren(param1,this,param2,param3);
         for each(_loc4_ in param3)
         {
            _loc5_ = _loc4_ as Light3D;
            if(_loc5_ != null)
            {
               this._lights.push(_loc5_);
               if(_loc5_.name.indexOf("Night") > -1)
               {
                  this._lightsNight.push(_loc5_);
               }
            }
         }
      }
      
      public function disposeResource() : void
      {
      }
      
      private function disposeChildren(param1:Object3D) : void
      {
         var _loc3_:Object3D = null;
         var _loc4_:Mesh = null;
         var _loc5_:int = 0;
         var _loc6_:Surface = null;
         var _loc7_:TextureMaterial = null;
         var _loc2_:int = param1.numChildren - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = param1.getChildAt(_loc2_);
            param1.removeChildAt(_loc2_);
            _loc4_ = _loc3_ as Mesh;
            if(_loc4_ != null)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.numSurfaces)
               {
                  _loc6_ = _loc4_.getSurface(_loc5_);
                  if(_loc6_.material is TextureMaterial)
                  {
                     _loc7_ = TextureMaterial(_loc6_.material);
                     if(_loc7_.diffuseMap != null)
                     {
                        _loc7_.diffuseMap.dispose();
                     }
                     if(_loc7_.opacityMap != null)
                     {
                        _loc7_.diffuseMap.dispose();
                     }
                  }
                  _loc6_.material = null;
                  _loc6_.alternativa3d::object = null;
                  _loc5_++;
               }
               _loc4_.alternativa3d::_surfaces.length = 0;
               _loc4_.alternativa3d::_surfacesLength = 0;
               _loc4_.userData = null;
               _loc4_.geometry = null;
               _loc4_.boundBox = null;
            }
            this.disposeChildren(_loc3_);
            _loc2_--;
         }
      }
      
      public function get nightLights() : Vector.<Light3D>
      {
         return this._lightsNight;
      }
      
      public function get lights() : Vector.<Light3D>
      {
         return this._lights;
      }
   }
}

