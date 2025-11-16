package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.effects.TextureAtlas;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import com.deadreckoned.threshold.math.Random;
   import flash.geom.Vector3D;
   import thelaststand.app.game.entities.effects.particles.ConfettiParticle;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class Confetti extends GameEntity
   {
      
      private static const BmpConfetti:Class = Confetti_BmpConfetti;
      
      private static var _id:int = 0;
      
      private var _atlas:TextureAtlas;
      
      private var _diffuse:BitmapTextureResource;
      
      private var _resources:Vector.<Resource>;
      
      private var _effects:Vector.<ParticleEffect>;
      
      private var _particles:ParticleSystem;
      
      private var _container:Object3D;
      
      public function Confetti(param1:Number, param2:Number, param3:Number = 5)
      {
         var _loc5_:Vector3D = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         super();
         name = "_confetti" + _id++;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._particles = new ParticleSystem();
         this._container = new Object3D();
         this._container.addChild(this._particles);
         this._diffuse = new BitmapTextureResource(new BmpConfetti().bitmapData);
         this._resources = new <Resource>[this._diffuse];
         this._effects = new Vector.<ParticleEffect>();
         this._atlas = new TextureAtlas(this._diffuse,null,4,4,0,16,20,true);
         var _loc4_:int = 0;
         while(_loc4_ < 40)
         {
            _loc5_ = new Vector3D(Random.float(-1,1),Random.float(-1,1),Random.float(1,0.5));
            _loc5_.normalize();
            _loc6_ = Random.float(1,5);
            _loc7_ = Random.integer(0,16);
            this._effects.push(new ConfettiParticle(this._atlas,_loc5_,_loc6_,Random.float(0.5,1.5)));
            _loc4_++;
         }
         asset = new Object3D();
         asset.addChild(this._container);
         transform.position.x = param1;
         transform.position.y = param2;
         transform.position.z = param3;
         updateTransform();
         addedToScene.add(this.onAddedToScene);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._atlas != null)
         {
            this._atlas.diffuse = null;
         }
         if(this._diffuse != null)
         {
            this._diffuse.data = null;
            this._diffuse.dispose();
         }
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         var _loc2_:ParticleEffect = null;
         var _loc3_:Resource = null;
         for each(_loc2_ in this._effects)
         {
            this._particles.addEffect(_loc2_);
         }
         for each(_loc3_ in this._resources)
         {
            scene.resourceUploadList.push(_loc3_);
         }
         scene.camera.shake(2.5);
      }
   }
}

