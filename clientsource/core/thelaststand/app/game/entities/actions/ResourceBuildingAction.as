package thelaststand.app.game.entities.actions
{
   import alternativa.engine3d.core.Object3D;
   import thelaststand.app.game.data.Building;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.actions.IEntityAction;
   
   public class ResourceBuildingAction implements IEntityAction
   {
      
      private var _building:Building;
      
      private var _numStages:int = 0;
      
      private var _stage:int = -1;
      
      public function ResourceBuildingAction(param1:Building, param2:int)
      {
         super();
         this._building = param1;
         this._building.entity.assetInvalidated.add(this.onBuildingEntityInvalidated);
         this._numStages = param2;
      }
      
      public function dispose() : void
      {
         if(this._building.entity != null)
         {
            this._building.entity.assetInvalidated.remove(this.onBuildingEntityInvalidated);
         }
         this._building = null;
      }
      
      public function run(param1:GameEntity, param2:Number) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Object3D = null;
         if(param1 == null || this._building == null || this._building.entity == null)
         {
            return;
         }
         var _loc3_:Object3D = param1.asset.getChildByName("meshEntity");
         if(_loc3_ == null || !this._building.buildingEntity.meshLoaded)
         {
            this._stage = -1;
            return;
         }
         var _loc4_:Number = this._building.resourceValue / this._building.resourceCapacity;
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         else if(_loc4_ > 0.99)
         {
            _loc4_ = 0.99;
         }
         var _loc5_:Number = Math.floor(_loc4_ * this._numStages);
         var _loc6_:Number = this._building.resourceValue > 1 && _loc5_ < 1 ? 1 : _loc5_;
         if(_loc6_ != this._stage)
         {
            this._stage = _loc6_;
            _loc7_ = 0;
            while(_loc7_ < this._numStages)
            {
               _loc8_ = _loc3_.getChildByName("stage-" + _loc7_);
               if(_loc8_ != null)
               {
                  _loc8_.visible = _loc7_ == this._stage;
               }
               _loc7_++;
            }
         }
      }
      
      private function onBuildingEntityInvalidated(param1:GameEntity) : void
      {
         this._stage = -1;
      }
   }
}

