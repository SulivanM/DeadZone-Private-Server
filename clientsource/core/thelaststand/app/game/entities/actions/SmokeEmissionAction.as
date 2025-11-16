package thelaststand.app.game.entities.actions
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import flash.utils.getTimer;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.effects.emitters.SmokeEmitter;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.actions.IEntityAction;
   import thelaststand.engine.scenes.Scene;
   
   public class SmokeEmissionAction implements IEntityAction
   {
      
      private var _initialized:Boolean;
      
      private var _emitter:SmokeEmitter;
      
      public function SmokeEmissionAction()
      {
         super();
         this._emitter = new SmokeEmitter(10,300);
      }
      
      public function dispose() : void
      {
         this._emitter.dispose();
      }
      
      public function run(param1:GameEntity, param2:Number) : void
      {
         var _loc3_:Object3D = null;
         var _loc4_:Object3D = null;
         var _loc5_:BuildingEntity = null;
         if(!this._initialized)
         {
            _loc3_ = param1.asset.getChildByName("meshEntity");
            if(_loc3_ == null)
            {
               return;
            }
            _loc4_ = _loc3_.getChildByName("dummySmoke");
            if(_loc4_ == null)
            {
               return;
            }
            _loc4_.parent.addChild(this._emitter);
            this._emitter.x = _loc4_.x;
            this._emitter.y = _loc4_.y;
            this._emitter.z = _loc4_.z;
            param1.removedFromScene.addOnce(this.onRemovedFromScene);
            if(param1.scene != null)
            {
               this.uploadResources(param1.scene);
            }
            else
            {
               param1.addedToScene.addOnce(this.onAddedToScene);
            }
            if(param1 is BuildingEntity)
            {
               _loc5_ = BuildingEntity(param1);
               _loc5_.buildingData.died.add(this.onBuildingDied);
               _loc5_.buildingData.repairCompleted.add(this.onBuildingRepaired);
               this._emitter.visible = !_loc5_.buildingData.dead;
            }
            this._initialized = true;
         }
         else if(this._emitter.visible)
         {
            this._emitter.update(getTimer());
         }
      }
      
      private function uploadResources(param1:Scene) : void
      {
         var _loc2_:Resource = null;
         for each(_loc2_ in this._emitter.resources)
         {
            param1.resourceUploadList.push(_loc2_);
         }
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         this.uploadResources(param1.scene);
      }
      
      private function onRemovedFromScene(param1:GameEntity) : void
      {
         if(param1 is BuildingEntity)
         {
            BuildingEntity(param1).buildingData.died.remove(this.onBuildingDied);
            BuildingEntity(param1).buildingData.repairCompleted.remove(this.onBuildingRepaired);
         }
         if(this._emitter.parent != null)
         {
            this._emitter.parent.removeChild(this._emitter);
         }
         this._initialized = false;
         this._emitter.reset();
      }
      
      private function onBuildingDied(param1:AIAgent, param2:Object) : void
      {
         this._emitter.visible = false;
      }
      
      private function onBuildingRepaired(param1:AIAgent) : void
      {
         this._emitter.visible = true;
         this._emitter.reset();
      }
   }
}

