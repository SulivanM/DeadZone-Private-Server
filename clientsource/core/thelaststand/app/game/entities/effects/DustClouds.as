package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class DustClouds extends GameEntity
   {
      
      private static var _nextId:int = 0;
      
      private var _effect:DustCloudEffect;
      
      private var _age:Number;
      
      private var _life:Number;
      
      public function DustClouds(param1:Number, param2:Number, param3:Number = 0, param4:int = 10, param5:Number = 200, param6:Number = 400, param7:Number = 1, param8:Number = 3)
      {
         super();
         name = "_dustClouds" + _nextId++;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._effect = new DustCloudEffect(param4,param5,param6,param7,param8);
         this._life = param8 * 2;
         asset = new Object3D();
         asset.addChild(this._effect);
         transform.position.x = param1;
         transform.position.y = param2;
         transform.position.z = param3 + 5;
         updateTransform();
         addedToScene.add(this.onAddedToScene);
      }
      
      override public function update(param1:Number = 1) : void
      {
         this._age += param1;
         if(this._age >= this._life)
         {
            if(scene != null)
            {
               scene.removeEntity(this);
            }
            return;
         }
         super.update(param1);
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         var _loc2_:Resource = null;
         for each(_loc2_ in this._effect.resources)
         {
            scene.resourceUploadList.push(_loc2_);
         }
         this._effect.play();
      }
   }
}

