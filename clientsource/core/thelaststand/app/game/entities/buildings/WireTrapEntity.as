package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.objects.Mesh;
   import com.greensock.easing.Back;
   import thelaststand.app.game.entities.effects.WireTrapDust;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class WireTrapEntity extends BuildingEntity implements ITrapEntity
   {
      
      private var _active:Boolean = false;
      
      private var _dustEffect:WireTrapDust;
      
      private var mesh_wire:Mesh;
      
      public function WireTrapEntity()
      {
         super();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.mesh_wire != null)
         {
            TweenMaxDelta.killTweensOf(this.mesh_wire);
            this.mesh_wire = null;
         }
      }
      
      public function activate() : void
      {
         var _loc1_:Resource = null;
         if(this._active)
         {
            return;
         }
         this._active = true;
         if(this.mesh_wire == null)
         {
            return;
         }
         this._dustEffect = new WireTrapDust();
         this._dustEffect.scaleX = this._dustEffect.scaleY = this._dustEffect.scaleZ = 0.75;
         this._dustEffect.x = centerPoint.x;
         this._dustEffect.y = centerPoint.y;
         this._dustEffect.z = centerPoint.z;
         this._dustEffect.play();
         asset.addChild(this._dustEffect);
         for each(_loc1_ in this._dustEffect.resources)
         {
            if(_loc1_ != null)
            {
               scene.resourceUploadList.push(_loc1_);
            }
         }
         buildingData.soundSource.play(buildingData.getSound("trigger"),{
            "minDistance":5000,
            "maxDistance":10000
         });
         TweenMaxDelta.to(this.mesh_wire,0.08,{
            "z":0,
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
      }
      
      public function deactivate() : void
      {
         TweenMaxDelta.killTweensOf(this.mesh_wire);
         this.mesh_wire.z = -75;
      }
      
      override protected function onMeshReady() : void
      {
         super.onMeshReady();
         this.mesh_wire = mesh_building.getChildByName("wire") as Mesh;
         if(this._active)
         {
            this.mesh_wire.z = 0;
         }
      }
   }
}

