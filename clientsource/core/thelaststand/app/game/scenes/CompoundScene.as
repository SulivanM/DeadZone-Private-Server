package thelaststand.app.game.scenes
{
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import thelaststand.app.core.Global;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.JunkBuilding;
   import thelaststand.app.game.entities.buildings.DoorBuildingEntity;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.materials.InvisibleMaterial;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class CompoundScene extends BaseScene
   {
      
      private const WALL_OPACITY:Number = 0.3;
      
      private var _buildings:BuildingCollection;
      
      private var _indoorAreas:Vector.<Rectangle>;
      
      private var _buildAreas:Vector.<Rectangle>;
      
      private var _noBuildAreas:Vector.<Rectangle>;
      
      private var _doorAreas:Vector.<Rectangle>;
      
      private var mesh_wallS:Mesh;
      
      private var mesh_wallN:Mesh;
      
      private var mesh_wallE:Mesh;
      
      private var mesh_wallShadowCaster:Mesh;
      
      private var _tmpRect:Rectangle = new Rectangle();
      
      public function CompoundScene()
      {
         super();
         addSceneLight();
         this._indoorAreas = new Vector.<Rectangle>();
         this._noBuildAreas = new Vector.<Rectangle>();
         this._buildAreas = new Vector.<Rectangle>();
         this._doorAreas = new Vector.<Rectangle>();
         _noiseVolumeMultiplier = 2;
         animateCamera = false;
         zoom = 2;
         animateCamera = true;
         _totalSearchableEntities = 0;
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(this.mesh_wallE);
         TweenMaxDelta.killTweensOf(this.mesh_wallS);
         TweenMaxDelta.killTweensOf(this.mesh_wallN);
         this.removeBuildings();
         super.dispose();
         this._buildings = null;
         this._indoorAreas = null;
         this._buildAreas = null;
         this._doorAreas = null;
         this.mesh_wallShadowCaster.setMaterialToAllSurfaces(null);
         this.mesh_wallS = this.mesh_wallN = this.mesh_wallE = this.mesh_wallShadowCaster = null;
      }
      
      public function isBuildingInDoorway(param1:Building, param2:int, param3:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Rectangle = null;
         var _loc8_:Boolean = false;
         var _loc6_:Rectangle = param1.buildingEntity.getFootprintBufferRect(param2,param3,this._tmpRect);
         for each(_loc7_ in this._doorAreas)
         {
            _loc8_ = true;
            _loc4_ = _loc6_.left;
            while(_loc4_ <= _loc6_.right)
            {
               _loc5_ = _loc6_.top;
               while(_loc5_ <= _loc6_.bottom)
               {
                  if(!(_loc6_.height > 0 && _loc6_.width > 0 && (_loc4_ <= _loc6_.left || _loc4_ >= _loc6_.right) && (_loc5_ <= _loc6_.top || _loc5_ >= _loc6_.bottom)))
                  {
                     if(_loc7_.contains(_loc4_,_loc5_))
                     {
                        return true;
                     }
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      public function isBuildingFullyInDoorway(param1:Building, param2:int, param3:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Rectangle = null;
         var _loc8_:Boolean = false;
         var _loc6_:Rectangle = param1.buildingEntity.getFootprintBufferRect(param2,param3,this._tmpRect);
         for each(_loc7_ in this._doorAreas)
         {
            _loc8_ = true;
            _loc4_ = _loc6_.left;
            while(_loc4_ <= _loc6_.right)
            {
               _loc5_ = _loc6_.top;
               while(_loc5_ <= _loc6_.bottom)
               {
                  if(!(_loc6_.height > 0 && _loc6_.width > 0 && (_loc4_ <= _loc6_.left || _loc4_ >= _loc6_.right) && (_loc5_ <= _loc6_.top || _loc5_ >= _loc6_.bottom)))
                  {
                     if(!_loc7_.contains(_loc4_,_loc5_))
                     {
                        _loc8_ = false;
                     }
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
            if(_loc8_)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isIndoors(param1:int, param2:int) : Boolean
      {
         var _loc3_:Rectangle = null;
         for each(_loc3_ in this._indoorAreas)
         {
            if(_loc3_.contains(param1,param2))
            {
               return true;
            }
         }
         return false;
      }
      
      public function isInBuildArea(param1:int, param2:int) : Boolean
      {
         var _loc3_:Rectangle = null;
         for each(_loc3_ in this._buildAreas)
         {
            if(!_loc3_.contains(param1,param2))
            {
               return false;
            }
         }
         for each(_loc3_ in this._noBuildAreas)
         {
            if(_loc3_.contains(param1,param2))
            {
               return false;
            }
         }
         return true;
      }
      
      public function getRandomUnoccupiedCellIndoors() : Cell
      {
         var _loc1_:Cell = null;
         var _loc2_:Rectangle = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._indoorAreas.length > 0)
         {
            _loc2_ = this._indoorAreas[int(Math.random() * this._indoorAreas.length)];
            while(_loc1_ == null || !_map.isPassableCell(_loc1_))
            {
               _loc3_ = _loc2_.x + int(Math.random() * _loc2_.width);
               _loc4_ = _loc2_.y + int(Math.random() * _loc2_.height);
               _loc1_ = _map.cellMap.getCell(_loc3_,_loc4_);
            }
         }
         else
         {
            _loc1_ = _map.cellMap.getCell(0,0);
         }
         return _loc1_;
      }
      
      override public function populateFromDescriptor(param1:XML, param2:Number = NaN, param3:Boolean = true) : void
      {
         var _loc4_:XML = null;
         var _loc7_:Mesh = null;
         var _loc8_:Boolean = false;
         super.populateFromDescriptor(param1,param2,param3);
         this.mesh_wallS = Mesh(_sceneModel.getChildByName("wall-S"));
         this.mesh_wallN = Mesh(_sceneModel.getChildByName("wall-N"));
         this.mesh_wallE = Mesh(_sceneModel.getChildByName("wall-E"));
         var _loc5_:InvisibleMaterial = new InvisibleMaterial();
         this.mesh_wallShadowCaster = Mesh(_sceneModel.getChildByName("wall-caster"));
         this.mesh_wallShadowCaster.setMaterialToAllSurfaces(_loc5_);
         this.mesh_wallShadowCaster.mouseChildren = this.mesh_wallShadowCaster.mouseEnabled = false;
         this.setMeshOpacity(this.mesh_wallE,this.WALL_OPACITY);
         this.setMeshOpacity(this.mesh_wallS,this.WALL_OPACITY);
         this.setMeshOpacity(this.mesh_wallN,1);
         var _loc6_:int = 0;
         while(_loc6_ < _sceneModel.numChildren)
         {
            _loc7_ = _sceneModel.getChildAt(_loc6_) as Mesh;
            if(_loc7_ != null)
            {
               _loc8_ = _loc7_.name != null && _loc7_.name.indexOf("los") == 0;
               if(_loc8_)
               {
                  _loc7_.mouseEnabled = _loc7_.mouseChildren = false;
                  _loc7_.calculateBoundBox();
                  if(_loc7_ != null)
                  {
                     _loc7_.setMaterialToAllSurfaces(null);
                  }
                  _losObjects.push(_loc7_);
               }
               else
               {
                  addShadowCaster(_loc7_);
               }
            }
            _loc6_++;
         }
         this._buildAreas.length = 0;
         for each(_loc4_ in _xmlDescriptor.build_area)
         {
            this._buildAreas.push(new Rectangle(int(_loc4_.@x.toString()),int(_loc4_.@y.toString()),int(_loc4_.@width.toString()),int(_loc4_.@height.toString())));
         }
         this._noBuildAreas.length = 0;
         for each(_loc4_ in _xmlDescriptor.no_build_area)
         {
            this._noBuildAreas.push(new Rectangle(int(_loc4_.@x.toString()),int(_loc4_.@y.toString()),int(_loc4_.@width.toString()),int(_loc4_.@height.toString())));
         }
         this._indoorAreas.length = 0;
         for each(_loc4_ in param1.indoor)
         {
            this._indoorAreas.push(new Rectangle(int(_loc4_.@x.toString()),int(_loc4_.@y.toString()),int(_loc4_.@width.toString()),int(_loc4_.@height.toString())));
         }
         this._doorAreas.length = 0;
         for each(_loc4_ in param1.doorway.rect)
         {
            this._doorAreas.push(new Rectangle(int(_loc4_.@x.toString()),int(_loc4_.@y.toString()),int(_loc4_.@width.toString()),int(_loc4_.@height.toString())));
         }
      }
      
      public function addBuildings(param1:BuildingCollection) : void
      {
         var _loc4_:Building = null;
         var _loc5_:Vector3D = null;
         var _loc6_:DoorBuildingEntity = null;
         this.removeBuildings();
         this._buildings = param1;
         if(this._buildings == null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = this._buildings.numBuildings;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this._buildings.getBuilding(_loc2_);
            if(_loc4_ != null)
            {
               _loc4_.entity.name = "bld_" + _loc4_.type + "-" + _loc2_;
               if(_loc4_.scavengable)
               {
                  ++_totalSearchableEntities;
               }
               if(!(_loc4_ is JunkBuilding))
               {
                  _loc5_ = _map.getCellCoords(_loc4_.tileX,_loc4_.tileY);
                  _loc4_.entity.transform.position.copyFrom(_loc5_);
                  if(_loc4_.isDoor)
                  {
                     _loc6_ = DoorBuildingEntity(_loc4_.buildingEntity);
                     if(_loc6_.isOpen)
                     {
                        _loc6_.toggleOpen();
                     }
                  }
                  addEntity(_loc4_.entity);
                  _map.setBufferCells(_loc4_.buildingEntity);
               }
               else
               {
                  addEntity(_loc4_.entity);
               }
            }
            _loc2_++;
         }
      }
      
      public function runPvPBuildingValidation() : void
      {
         var _loc1_:Building = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Vector.<Point> = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Point = null;
         var _loc10_:Boolean = false;
         var _loc11_:Vector3D = null;
         var _loc2_:int = this._buildings.numBuildings - 1;
         for(; _loc2_ >= 0; _loc2_--)
         {
            _loc1_ = this._buildings.getBuilding(_loc2_);
            if(!(_loc1_ is JunkBuilding))
            {
               _loc3_ = Building.getBuildingXML(_loc1_.type).@type.toString();
               if(!(_loc1_.type != "alliance-flag" && _loc3_ != "defence"))
               {
                  _loc4_ = true;
                  if(_loc1_.doorwayOnly)
                  {
                     if(!this.isBuildingFullyInDoorway(_loc1_,_loc1_.tileX,_loc1_.tileY))
                     {
                        _loc4_ = false;
                        continue;
                     }
                  }
                  else if(this.isBuildingInDoorway(_loc1_,_loc1_.tileX,_loc1_.tileY))
                  {
                     _loc4_ = false;
                     continue;
                  }
                  if(_loc4_)
                  {
                     _loc5_ = _loc1_.buildingEntity.getTileCoords();
                     _loc6_ = true;
                     _loc7_ = _loc1_.canBuildIndoors();
                     _loc8_ = _loc1_.canBuildOutdoors();
                     for each(_loc9_ in _loc5_)
                     {
                        if(!this.isInBuildArea(_loc9_.x,_loc9_.y))
                        {
                           _loc4_ = false;
                           break;
                        }
                        _loc10_ = this.isIndoors(_loc9_.x,_loc9_.y);
                        if(_loc7_ && !_loc8_ && !_loc10_ || !_loc7_ && _loc8_ && _loc10_)
                        {
                           _loc4_ = false;
                           break;
                        }
                     }
                  }
                  if(_loc4_)
                  {
                     _loc4_ = _loc1_.buildingEntity.isCurrentPositionValid();
                  }
                  if(!_loc4_)
                  {
                     if(_loc1_.type == "alliance-flag")
                     {
                        _loc1_.tileX = 61;
                        _loc1_.tileY = 50;
                        _loc1_.rotation = 0;
                        map.clearBufferCells(_loc1_.buildingEntity);
                        _loc11_ = map.getCellCoords(_loc1_.tileX,_loc1_.tileY);
                        _loc1_.buildingEntity.transform.position.setTo(_loc11_.x,_loc11_.y,0);
                        _loc1_.buildingEntity.updateTransform();
                        map.updateCellsForEntity(_loc1_.buildingEntity);
                        map.setBufferCells(_loc1_.buildingEntity);
                     }
                     else
                     {
                        this._buildings.removeAt(_loc2_);
                        removeEntity(_loc1_.buildingEntity);
                     }
                  }
               }
            }
         }
      }
      
      private function setMeshOpacity(param1:Mesh, param2:Number) : void
      {
         var i:int;
         var len:int;
         var mtl:StandardMaterial = null;
         var mesh:Mesh = param1;
         var alpha:Number = param2;
         if(!mesh)
         {
            return;
         }
         i = 0;
         len = mesh.numSurfaces;
         while(i < len)
         {
            mtl = mesh.getSurface(i).material as StandardMaterial;
            if(mtl)
            {
               if(alpha < 1)
               {
                  mtl.alphaThreshold = 0.9;
                  mtl.transparentPass = true;
               }
               if(Global.softwareRendering)
               {
                  mtl.alpha = alpha;
                  if(alpha >= 1)
                  {
                     mtl.alphaThreshold = 0;
                     mtl.transparentPass = false;
                  }
               }
               else
               {
                  TweenMaxDelta.to(mtl,0.5,{
                     "alpha":alpha + 0.01,
                     "onComplete":function():void
                     {
                        mtl.alpha = alpha;
                        if(alpha >= 1)
                        {
                           mtl.alphaThreshold = 0;
                           mtl.transparentPass = false;
                        }
                     }
                  });
               }
            }
            i++;
         }
      }
      
      private function removeBuildings() : void
      {
         var _loc3_:Building = null;
         if(this._buildings == null)
         {
            return;
         }
         var _loc1_:int = 0;
         var _loc2_:int = this._buildings.numBuildings;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this._buildings.getBuilding(_loc1_);
            if(!(_loc3_ is JunkBuilding))
            {
               _map.clearBufferCells(_loc3_.buildingEntity);
            }
            removeEntity(_loc3_.buildingEntity);
            _loc1_++;
         }
      }
      
      override public function set rotation(param1:Number) : void
      {
         super.rotation = param1;
         this.setMeshOpacity(this.mesh_wallS,rotation == 0 ? this.WALL_OPACITY : 1);
         this.setMeshOpacity(this.mesh_wallN,rotation == 0 ? 1 : this.WALL_OPACITY);
      }
   }
}

