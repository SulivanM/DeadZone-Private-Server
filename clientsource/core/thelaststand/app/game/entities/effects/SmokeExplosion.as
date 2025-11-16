package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import flash.utils.getTimer;
   import thelaststand.app.game.entities.LOSFlags;
   import thelaststand.engine.audio.SoundSource3D;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class SmokeExplosion extends GameEntity
   {
      
      private static var _id:int = 0;
      
      private var _soundSource:SoundSource3D;
      
      private var _smoke:SmokeExplosionEffect;
      
      private var _radius:int;
      
      private var _life:Number;
      
      private var _startTime:Number;
      
      private var _expired:Boolean = false;
      
      public function SmokeExplosion(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super();
         name = "_smokeExplosion" + _id++;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         losVisible = true;
         this._soundSource = new SoundSource3D(transform.position,name + "_sound");
         this._smoke = new SmokeExplosionEffect(param5,param4);
         this._radius = param4;
         this._life = param5;
         asset = new Object3D();
         asset.userData.losFlags = LOSFlags.SMOKE;
         asset.mouseChildren = asset.mouseEnabled = false;
         asset.addChild(this._smoke);
         transform.position.x = param1;
         transform.position.y = param2;
         transform.position.z = param3;
         updateTransform();
         addedToScene.add(this.onAddedToScene);
      }
      
      override public function dispose() : void
      {
         this._smoke.dispose();
         this._soundSource.dispose();
         this._soundSource = null;
         super.dispose();
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         var _loc2_:Resource = null;
         scene.addEntity(this._soundSource);
         for each(_loc2_ in this._smoke.resources)
         {
            scene.resourceUploadList.push(_loc2_);
         }
         this._startTime = getTimer();
         this._soundSource.play("sound/weapons/grenade-smoke-explode.mp3",{
            "minDistance":5000,
            "maxDistance":20000
         });
         this._smoke.play();
      }
      
      override public function update(param1:Number = 1) : void
      {
         var _loc2_:Number = getTimer();
         var _loc3_:Number = _loc2_ - this._startTime;
         if(this._expired)
         {
            if(_loc3_ > (this._life + 2) * 1000)
            {
               scene.removeEntity(this);
            }
            return;
         }
         asset.boundBox.minX = this._smoke.boundBox.minX;
         asset.boundBox.minY = this._smoke.boundBox.minY;
         asset.boundBox.minZ = this._smoke.boundBox.minZ;
         asset.boundBox.maxX = this._smoke.boundBox.maxX;
         asset.boundBox.maxY = this._smoke.boundBox.maxY;
         asset.boundBox.maxZ = this._smoke.boundBox.maxZ;
         if(_loc3_ > this._life * 1000)
         {
            this._expired = true;
            this._smoke.die();
            return;
         }
      }
   }
}

