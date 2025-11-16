package thelaststand.app.game.scenes
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.utils.Object3DUtils;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Global;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.materials.InvisibleMaterial;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class BaseMissionScene extends BaseScene
   {
      
      private const WALL_OPACITY:Number = 0.3;
      
      private const SURFACE_WALL:int = 1;
      
      private const SURFACE_FLOOR:int = 0;
      
      private var _markedWalls:Vector.<GameEntity>;
      
      private var _wallEntities:Vector.<GameEntity>;
      
      private var _wallEntitiesByGroup:Dictionary;
      
      private var _wallCellsXByGroup:Dictionary;
      
      private var _wallCellsY1ByGroup:Dictionary;
      
      private var _wallCellsY2ByGroup:Dictionary;
      
      private var _setXML:XML;
      
      private var mesh_wallS:Mesh;
      
      private var mesh_wallN:Mesh;
      
      private var mesh_wallW:Mesh;
      
      private var mesh_floor:Mesh;
      
      public function BaseMissionScene()
      {
         super();
      }
      
      override public function dispose() : void
      {
         var _loc1_:String = null;
         this._markedWalls = null;
         this._wallEntities = null;
         this._setXML = null;
         for(_loc1_ in this._wallEntitiesByGroup)
         {
            this._wallEntitiesByGroup[_loc1_] = null;
         }
         this._wallEntitiesByGroup = null;
         for(_loc1_ in this._wallCellsXByGroup)
         {
            this._wallCellsXByGroup[_loc1_] = null;
         }
         this._wallCellsXByGroup = null;
         for(_loc1_ in this._wallCellsY1ByGroup)
         {
            this._wallCellsY1ByGroup[_loc1_] = null;
         }
         this._wallCellsY1ByGroup = null;
         for(_loc1_ in this._wallCellsY2ByGroup)
         {
            this._wallCellsY2ByGroup[_loc1_] = null;
         }
         this._wallCellsY2ByGroup = null;
         if(this.mesh_wallS != null)
         {
            this.mesh_wallS.geometry = null;
            this.mesh_wallS = null;
         }
         if(this.mesh_wallN != null)
         {
            this.mesh_wallN.geometry = null;
            this.mesh_wallN = null;
         }
         if(this.mesh_wallW != null)
         {
            this.mesh_wallW.geometry = null;
            this.mesh_wallW = null;
         }
         if(this.mesh_floor != null)
         {
            this.mesh_floor.geometry = null;
            this.mesh_floor = null;
         }
         super.dispose();
      }
      
      public function updateWallOpacity(param1:Vector.<AIAgent>) : void
      {
         var _loc3_:AIAgent = null;
         var _loc4_:Cell = null;
         var _loc5_:int = 0;
         var _loc6_:GameEntity = null;
         var _loc7_:Vector.<Cell> = null;
         var _loc8_:Object = null;
         var _loc9_:Object3D = null;
         var _loc10_:Mesh = null;
         this._markedWalls.length = 0;
         var _loc2_:Dictionary = rotation == 0 ? this._wallCellsY1ByGroup : this._wallCellsY2ByGroup;
         for each(_loc3_ in param1)
         {
            if(_loc3_.agentData.inLOS)
            {
               _loc4_ = _map.getCellAtCoords(_loc3_.entity.transform.position.x,_loc3_.entity.transform.position.y);
               if(_loc4_ != null)
               {
                  for(_loc8_ in this._wallCellsXByGroup)
                  {
                     _loc5_ = int(_loc8_);
                     _loc7_ = this._wallCellsXByGroup[_loc5_];
                     if(_loc7_.indexOf(_loc4_) > -1)
                     {
                        for each(_loc6_ in this._wallEntitiesByGroup[_loc5_])
                        {
                           this._markedWalls.push(_loc6_);
                        }
                        break;
                     }
                  }
                  for(_loc8_ in _loc2_)
                  {
                     _loc5_ = int(_loc8_);
                     _loc7_ = _loc2_[_loc5_];
                     if(_loc7_.indexOf(_loc4_) > -1)
                     {
                        for each(_loc6_ in this._wallEntitiesByGroup[_loc5_])
                        {
                           this._markedWalls.push(_loc6_);
                        }
                        break;
                     }
                  }
               }
            }
         }
         for each(_loc6_ in this._wallEntities)
         {
            _loc9_ = _loc6_.asset.getChildByName("meshEntity");
            if(_loc9_ != null)
            {
               _loc10_ = _loc9_.numChildren > 0 ? _loc9_.getChildAt(0) as Mesh : null;
               if(_loc10_ != null)
               {
                  if(this._markedWalls.indexOf(_loc6_) > -1)
                  {
                     this.setMeshOpacity(_loc10_,this.WALL_OPACITY);
                  }
                  else
                  {
                     this.setMeshOpacity(_loc10_,1);
                  }
               }
            }
         }
      }
      
      override public function populateFromDescriptor(param1:XML, param2:Number = 0, param3:Boolean = true) : void
      {
         var i:int;
         var setNode:XML;
         var wallEntNodes:XMLList;
         var name:String;
         var rzRaw:String;
         var rz:Number;
         var mesh_wallShadowCaster:Mesh = null;
         var wallTexURI:String = null;
         var floorTexURI:String = null;
         var node:XML = null;
         var res:Resource = null;
         var mesh:Mesh = null;
         var setName:String = null;
         var mtlWall:StandardMaterial = null;
         var objectSetId:String = null;
         var entNode:XML = null;
         var ent:GameEntity = null;
         var setObjectNode:XML = null;
         var objectMeshEntity:Object3D = null;
         var childTexNode:XML = null;
         var mdlNode:XML = null;
         var texNode:XML = null;
         var texMtl:StandardMaterial = null;
         var j:int = 0;
         var childMesh:Mesh = null;
         var childId:String = null;
         var index:int = 0;
         var groupId:int = 0;
         var wallEntity:GameEntity = null;
         var wallOpaqueDist:int = 0;
         var wallMeshEntity:Object3D = null;
         var cellListX:Vector.<Cell> = null;
         var cellListY1:Vector.<Cell> = null;
         var cellListY2:Vector.<Cell> = null;
         var occupying:Vector.<Cell> = null;
         var cell:Cell = null;
         var wallMesh:Mesh = null;
         var caster:Mesh = null;
         var t:Cell = null;
         var mtlFloor:StandardMaterial = null;
         var xml:XML = param1;
         var seed:Number = param2;
         var updateMap:Boolean = param3;
         super.populateFromDescriptor(xml,seed,updateMap);
         this.mesh_wallS = Mesh(_sceneModel.getChildByName("wall-S"));
         this.mesh_wallN = Mesh(_sceneModel.getChildByName("wall-N"));
         this.mesh_wallW = Mesh(_sceneModel.getChildByName("wall-W"));
         this.mesh_floor = Mesh(_sceneModel.getChildByName("floor"));
         mesh_wallShadowCaster = _sceneModel.getChildByName("wall-caster") as Mesh;
         if(mesh_wallShadowCaster != null)
         {
            mesh_wallShadowCaster.setMaterialToAllSurfaces(new InvisibleMaterial());
         }
         i = 0;
         while(i < _sceneModel.numChildren)
         {
            mesh = _sceneModel.getChildAt(i) as Mesh;
            if(mesh != null)
            {
               addShadowCaster(mesh);
            }
            i++;
         }
         if(this.mesh_wallS != null)
         {
            this.mesh_wallS.visible = rotation != 0;
         }
         if(this.mesh_wallN != null)
         {
            this.mesh_wallN.visible = rotation == 0;
         }
         this._wallEntitiesByGroup = new Dictionary(true);
         this._wallCellsXByGroup = new Dictionary(true);
         this._wallCellsY1ByGroup = new Dictionary(true);
         this._wallCellsY2ByGroup = new Dictionary(true);
         this._wallEntities = new Vector.<GameEntity>();
         this._markedWalls = new Vector.<GameEntity>();
         setNode = xml.set[0];
         if(setNode != null)
         {
            setName = setNode.children()[0].toString();
            this._setXML = ResourceManager.getInstance().getResource("xml/scenes/" + setName + ".xml").content;
            wallTexURI = this._setXML.walls.tex[int(setNode.@wallIndex)].@uri.toString();
            floorTexURI = this._setXML.floor.tex[int(setNode.@floorIndex)].@uri.toString();
            if(wallTexURI != null)
            {
               mtlWall = ResourceManager.getInstance().materials.getStandardMaterial("interior-wall",wallTexURI);
               if(this.mesh_wallS != null)
               {
                  this.mesh_wallS.getSurface(this.SURFACE_WALL).material = mtlWall;
               }
               if(this.mesh_wallN != null)
               {
                  this.mesh_wallN.getSurface(this.SURFACE_WALL).material = mtlWall;
               }
               if(this.mesh_wallW != null)
               {
                  this.mesh_wallW.getSurface(this.SURFACE_WALL).material = mtlWall;
               }
            }
            for each(node in setNode.objects.children())
            {
               objectSetId = node.localName();
               for each(entNode in xml.ent.e.(Boolean(hasOwnProperty("@setId")) && @setId == objectSetId))
               {
                  ent = getEntityByName(entNode.@name.toString());
                  if(ent != null)
                  {
                     setObjectNode = this._setXML.objects[objectSetId][0];
                     if(setObjectNode != null)
                     {
                        if(node.hasOwnProperty("@mdl"))
                        {
                           mdlNode = setObjectNode.mdl[int(node.@mdl)];
                           MeshGroup(ent.asset).removeChildren();
                           MeshGroup(ent.asset).addChildrenFromResource(mdlNode.@uri.toString());
                        }
                        objectMeshEntity = ent.asset.getChildByName("meshEntity");
                        if(objectMeshEntity != null)
                        {
                           if(node.hasOwnProperty("@tex"))
                           {
                              texNode = setObjectNode.tex[int(node.@tex)];
                              texMtl = ResourceManager.getInstance().materials.getStandardMaterial(objectSetId,texNode.@uri.toString());
                              j = 0;
                              while(j < objectMeshEntity.numChildren)
                              {
                                 childMesh = objectMeshEntity.getChildAt(j) as Mesh;
                                 if(childMesh != null)
                                 {
                                    childMesh.setMaterialToAllSurfaces(texMtl);
                                 }
                                 j++;
                              }
                           }
                           for each(childTexNode in node.children())
                           {
                              childId = childTexNode.localName();
                              index = int(childTexNode.toString());
                              texNode = setObjectNode.tex[index];
                              texMtl = ResourceManager.getInstance().materials.getStandardMaterial(objectSetId,texNode.@uri.toString());
                              j = 0;
                              while(j < objectMeshEntity.numChildren)
                              {
                                 childMesh = objectMeshEntity.getChildAt(j) as Mesh;
                                 if(!(childMesh == null || childMesh.name != childId))
                                 {
                                    childMesh.setMaterialToAllSurfaces(texMtl);
                                 }
                                 j++;
                              }
                           }
                           ent.assetInvalidated.dispatch(ent);
                        }
                     }
                  }
               }
            }
         }
         wallEntNodes = _xmlDescriptor.ent.e.(hasOwnProperty("@wallGroup"));
         for each(node in wallEntNodes)
         {
            groupId = int(node.@wallGroup);
            wallEntity = getEntityByName(node.@name.toString());
            if(wallEntity != null)
            {
               if(this._wallEntitiesByGroup[groupId] == null)
               {
                  this._wallEntitiesByGroup[groupId] = new Vector.<GameEntity>();
               }
               this._wallEntitiesByGroup[groupId].push(wallEntity);
               this._wallEntities.push(wallEntity);
               wallEntity.data = groupId;
               wallEntity.flags &= ~GameEntityFlags.IGNORE_TRANSFORMS;
               Object3DUtils.calculateHierarchyBoundBox(wallEntity.asset,wallEntity.asset,wallEntity.asset.boundBox);
               wallOpaqueDist = 3;
               wallMeshEntity = wallEntity.asset.getChildByName("meshEntity");
               if(wallMeshEntity != null)
               {
                  wallMesh = wallMeshEntity.numChildren > 0 ? wallMeshEntity.getChildAt(0) as Mesh : null;
                  if(wallMesh != null && wallMesh.numSurfaces > this.SURFACE_WALL)
                  {
                     if(wallTexURI != null)
                     {
                        wallMesh.getSurface(this.SURFACE_WALL).material = ResourceManager.getInstance().materials.getStandardMaterial("interior-wall",wallTexURI);
                     }
                     caster = wallMesh.clone() as Mesh;
                     caster.setMaterialToAllSurfaces(new InvisibleMaterial());
                     caster.matrix = wallMesh.matrix;
                     wallMeshEntity.addChild(caster);
                     if(wallMesh.boundBox.maxZ - wallMesh.boundBox.minZ > 350)
                     {
                        wallOpaqueDist = 6;
                     }
                  }
               }
               cellListX = this._wallCellsXByGroup[groupId];
               if(cellListX == null)
               {
                  this._wallCellsXByGroup[groupId] = cellListX = new Vector.<Cell>();
               }
               cellListY1 = this._wallCellsY1ByGroup[groupId];
               if(cellListY1 == null)
               {
                  this._wallCellsY1ByGroup[groupId] = cellListY1 = new Vector.<Cell>();
               }
               cellListY2 = this._wallCellsY2ByGroup[groupId];
               if(cellListY2 == null)
               {
                  this._wallCellsY2ByGroup[groupId] = cellListY2 = new Vector.<Cell>();
               }
               occupying = _map.getCellsEntityIsOccupying(wallEntity);
               for each(cell in occupying)
               {
                  i = 1;
                  while(i <= wallOpaqueDist)
                  {
                     t = _map.cellMap.getCell(cell.x - i,cell.y);
                     if(t != null)
                     {
                        cellListX.push(t);
                     }
                     t = _map.cellMap.getCell(cell.x,cell.y - i);
                     if(t != null)
                     {
                        cellListY1.push(t);
                     }
                     t = _map.cellMap.getCell(cell.x,cell.y + i);
                     if(t != null)
                     {
                        cellListY2.push(t);
                     }
                     i++;
                  }
               }
            }
         }
         if(this.mesh_floor != null && this.mesh_floor.numSurfaces > this.SURFACE_FLOOR)
         {
            if(floorTexURI != null)
            {
               mtlFloor = ResourceManager.getInstance().materials.getStandardMaterial("interior-floor",floorTexURI);
               this.mesh_floor.getSurface(this.SURFACE_FLOOR).material = mtlFloor;
            }
            this.mesh_floor.useShadow = false;
         }
         for each(res in _sceneModel.getResources(true))
         {
            if(!res.isUploaded)
            {
               resourceUploadList.push(res);
            }
         }
         this.rotation = int(Math.random() * ROTATION_STEPS);
         for each(entNode in param1.ent.e)
         {
            name = entNode.@name.toString();
            ent = getEntityByName(name);
            if(ent != null)
            {
               rzRaw = entNode.opt.rz ? entNode.opt.rz.toString() : null;
               if(rzRaw)
               {
                  rz = Number(rzRaw.split(" ")[0]);
                  ent.transform.setRotationEuler(0,0,rz,true);
                  ent.updateTransform();
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
         if(mesh == null)
         {
            return;
         }
         i = 0;
         len = mesh.numSurfaces;
         while(i < len)
         {
            mtl = mesh.getSurface(i).material as StandardMaterial;
            if(!(!mtl || mtl.alpha == alpha))
            {
               if(alpha < 1)
               {
                  mtl.transparentPass = true;
                  mtl.alphaThreshold = 0.9;
               }
               if(Global.softwareRendering)
               {
                  mtl.alpha = alpha;
                  if(alpha >= 1)
                  {
                     mtl.transparentPass = false;
                     mtl.alphaThreshold = 0;
                  }
               }
               else
               {
                  TweenMaxDelta.to(mtl,0.25,{
                     "alpha":alpha + 0.01,
                     "overwrite":true,
                     "onComplete":function(param1:StandardMaterial, param2:Number):void
                     {
                        param1.alpha = param2;
                        if(param2 >= 1)
                        {
                           mtl.transparentPass = false;
                           mtl.alphaThreshold = 0;
                        }
                     },
                     "onCompleteParams":[mtl,alpha]
                  });
               }
            }
            i++;
         }
      }
      
      override public function set rotation(param1:Number) : void
      {
         super.rotation = param1;
         if(this.mesh_wallS != null)
         {
            this.mesh_wallS.visible = rotation != 0;
         }
         if(this.mesh_wallN != null)
         {
            this.mesh_wallN.visible = rotation == 0;
         }
      }
   }
}

