package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.objects.Mesh;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.effects.Confetti;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class StadiumButtonEntity extends BuildingEntity
   {
      
      private var mesh_activated:Mesh;
      
      public function StadiumButtonEntity()
      {
         super();
         flags |= EntityFlags.MULTI_SCAVENGE;
         flags &= ~EntityFlags.EMPTY_CONTAINER;
         flags &= ~GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP;
         flags &= ~GameEntityFlags.IGNORE_TRANSFORMS;
         flags &= ~GameEntityFlags.FORCE_UNPASSABLE;
         addedToScene.add(this.onAddedToScene);
         onScavenged.add(this.onPressed);
         onScavengedCooldownReset.add(this.onReset);
      }
      
      private function onPressed() : void
      {
         if(scene == null)
         {
            return;
         }
         var _loc1_:Number = transform.position.x + centerPoint.x;
         var _loc2_:Number = transform.position.y + centerPoint.y;
         var _loc3_:Confetti = new Confetti(_loc1_,_loc2_);
         scene.addEntity(_loc3_);
         var _loc4_:String = buildingData.getSound("trigger");
         if(_loc4_ != null)
         {
            buildingData.soundSource.play(_loc4_,{
               "minDistance":5000,
               "maxDistance":10000
            });
         }
         if(this.mesh_activated != null)
         {
            this.mesh_activated.visible = true;
         }
      }
      
      private function onReset() : void
      {
         if(this.mesh_activated != null)
         {
            this.mesh_activated.visible = false;
         }
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         buildingData.forceScavengable = true;
      }
      
      override protected function onMeshReady() : void
      {
         super.onMeshReady();
         this.mesh_activated = mesh_building.getChildByName("button-activated") as Mesh;
         if(this.mesh_activated != null)
         {
            this.mesh_activated.visible = false;
         }
      }
   }
}

