package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.utils.Object3DUtils;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class JunkBuildingEntity extends BuildingEntity
   {
      
      private var mesh_junk:MeshGroup;
      
      public function JunkBuildingEntity()
      {
         super();
         flags &= ~GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP;
         flags &= ~GameEntityFlags.IGNORE_TRANSFORMS;
         flags &= ~GameEntityFlags.FORCE_UNPASSABLE;
         flags |= EntityFlags.REMOVABLE_JUNK;
      }
      
      override public function dispose() : void
      {
         this.mesh_junk = null;
         super.dispose();
      }
      
      override public function setMesh(param1:String, param2:String = null) : void
      {
         var _loc3_:BoundBox = null;
         if(mesh_hitArea.parent != null)
         {
            mesh_hitArea.parent.removeChild(mesh_hitArea);
         }
         if(this.mesh_junk != null)
         {
            if(scene != null)
            {
               scene.removeShadowCaster(this.mesh_junk);
            }
            if(this.mesh_junk.parent != null)
            {
               this.mesh_junk.parent.removeChild(this.mesh_junk);
            }
         }
         this.mesh_junk = new MeshGroup(param1);
         this.mesh_junk.name = "meshEntity";
         this.mesh_junk.mouseEnabled = this.mesh_junk.mouseChildren = false;
         Object3DUtils.calculateHierarchyBoundBox(this.mesh_junk,this.mesh_junk,this.mesh_junk.boundBox);
         asset.addChildAt(this.mesh_junk,0);
         _loc3_ = this.mesh_junk.boundBox;
         var _loc4_:int = _loc3_.maxX - _loc3_.minX;
         var _loc5_:int = _loc3_.maxY - _loc3_.minY;
         var _loc6_:int = Math.min(_loc3_.maxZ - _loc3_.minZ,MAX_BOUND_HEIGHT);
         mesh_hitArea.scaleX = _loc4_ * 0.75;
         mesh_hitArea.scaleY = _loc5_ * 0.75;
         mesh_hitArea.x = _loc3_.minX + _loc4_ * 0.5;
         mesh_hitArea.y = _loc3_.minY + _loc5_ * 0.5;
         _loc6_ *= 0.75;
         mesh_hitArea.scaleZ = _loc6_;
         mesh_hitArea.z = _loc3_.minZ + _loc6_ * 0.5;
         mesh_hitArea.calculateBoundBox();
         asset.addChild(mesh_hitArea);
         _coverArea = mesh_hitArea;
         asset.boundBox = mesh_hitArea.boundBox;
         if(scene != null)
         {
            scene.addShadowCaster(this.mesh_junk);
         }
         updateTransform();
         assetInvalidated.dispatch(this);
      }
      
      override public function setFootprint(param1:int, param2:int, param3:Boolean = true) : void
      {
      }
   }
}

