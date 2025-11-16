package thelaststand.app.game.entities.buildings
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import thelaststand.app.game.logic.ai.AIAgent;
   
   public class FuelGeneratorEntity extends BuildingEntity
   {
      
      public function FuelGeneratorEntity()
      {
         super();
         addedToScene.add(this.onAddedToScene);
         removedFromScene.add(this.onRemovedFromScene);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         addedToScene.remove(this.onAddedToScene);
         removedFromScene.remove(this.onRemovedFromScene);
         if(buildingData != null)
         {
            buildingData.died.remove(this.onDied);
            buildingData.repairCompleted.remove(this.onRepairComplete);
         }
      }
      
      private function onDied(param1:AIAgent, param2:Object) : void
      {
         var dummy:Object = null;
         var shakeAmount:Number = NaN;
         var agent:AIAgent = param1;
         var source:Object = param2;
         if(mesh_building == null)
         {
            return;
         }
         dummy = {"t":1};
         shakeAmount = 5;
         TweenMax.to(dummy,1,{
            "t":0,
            "ease":Quad.easeOut,
            "overwrite":true,
            "onUpdate":function():void
            {
               mesh_building.x = (Math.random() * 2 - 1) * shakeAmount * dummy.t;
               mesh_building.y = (Math.random() * 2 - 1) * shakeAmount * dummy.t;
            },
            "onComplete":function():void
            {
               mesh_building.x = mesh_building.y = 0;
            }
         });
      }
      
      private function onRepairComplete(param1:AIAgent) : void
      {
         var dummy:Object = null;
         var shakeAmount:Number = NaN;
         var agent:AIAgent = param1;
         if(mesh_building == null)
         {
            return;
         }
         dummy = {"t":0};
         shakeAmount = 3;
         TweenMax.to(dummy,1,{
            "t":1,
            "ease":Quad.easeInOut,
            "yoyo":true,
            "repeat":1,
            "overwrite":true,
            "onUpdate":function():void
            {
               mesh_building.x = (Math.random() * 2 - 1) * shakeAmount * dummy.t;
               mesh_building.y = (Math.random() * 2 - 1) * shakeAmount * dummy.t;
            },
            "onComplete":function():void
            {
               mesh_building.x = mesh_building.y = 0;
            }
         });
         if(scene != null)
         {
            buildingData.soundSource.play(buildingData.getSound("restart"));
         }
      }
      
      private function onAddedToScene(param1:FuelGeneratorEntity) : void
      {
         buildingData.died.add(this.onDied);
         buildingData.repairCompleted.add(this.onRepairComplete);
      }
      
      private function onRemovedFromScene(param1:FuelGeneratorEntity) : void
      {
         buildingData.died.remove(this.onDied);
         buildingData.repairCompleted.remove(this.onRepairComplete);
      }
   }
}

