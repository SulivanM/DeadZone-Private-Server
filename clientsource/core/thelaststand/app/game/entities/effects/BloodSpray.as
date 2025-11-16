package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import com.deadreckoned.threshold.data.ObjectPool;
   import flash.geom.Vector3D;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class BloodSpray extends GameEntity
   {
      
      private static var _nextId:int = 0;
      
      public static const pool:ObjectPool = new ObjectPool(BloodSpray,200,0,false);
      
      private var _effect:BloodSprayEffect;
      
      private var _life:Number = 0;
      
      private var _age:Number = 0;
      
      public function BloodSpray()
      {
         super();
         this._effect = new BloodSprayEffect();
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         asset = new Object3D();
         asset.addChild(this._effect);
         addedToScene.add(this.onAddedToScene);
         removedFromScene.add(this.onRemovedFromScene);
      }
      
      public function init(param1:Number, param2:Number, param3:Number, param4:Vector3D, param5:Number = 1, param6:Number = 5) : void
      {
         name = "_bloodSpray" + _nextId++;
         this._effect.init(param4,param5,param6);
         this._age = 0;
         this._life = 0.6;
         transform.position.x = param1;
         transform.position.y = param2;
         transform.position.z = param3;
         updateTransform();
      }
      
      override public function update(param1:Number = 1) : void
      {
         if(scene == null)
         {
            return;
         }
         this._age += param1;
         if(this._age > this._life)
         {
            scene.removeEntity(this);
            return;
         }
      }
      
      private function onAddedToScene(param1:BloodSpray) : void
      {
         var _loc2_:Resource = null;
         for each(_loc2_ in this._effect.resources)
         {
            if(!_loc2_.isUploaded)
            {
               scene.resourceUploadList.push(_loc2_);
            }
         }
         this._effect.play();
      }
      
      private function onRemovedFromScene(param1:BloodSpray) : void
      {
         this._effect.stop();
         pool.put(this);
      }
   }
}

