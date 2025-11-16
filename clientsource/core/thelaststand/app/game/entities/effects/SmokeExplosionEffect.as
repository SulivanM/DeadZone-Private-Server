package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.effects.TextureAtlas;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import thelaststand.app.game.entities.effects.particles.SmokeCloudParticle;
   import thelaststand.common.resources.ResourceManager;
   
   public class SmokeExplosionEffect extends Object3D implements IEntityEffect
   {
      
      private var _life:Number;
      
      private var _radius:Number;
      
      private var _particles:ParticleSystem;
      
      private var _effects:Vector.<ParticleEffect>;
      
      private var _resources:Vector.<Resource>;
      
      public function SmokeExplosionEffect(param1:Number, param2:Number)
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:SmokeCloudParticle = null;
         super();
         this._life = param1;
         this._radius = param2;
         var _loc3_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-clouddust-white.png");
         this._resources = new <Resource>[_loc3_];
         this._effects = new Vector.<ParticleEffect>();
         this._particles = new ParticleSystem();
         this._particles.z = 100;
         addChild(this._particles);
         var _loc6_:int = -this._radius;
         while(_loc6_ <= this._radius)
         {
            _loc7_ = -this._radius;
            while(_loc7_ <= this._radius)
            {
               _loc8_ = new SmokeCloudParticle(new TextureAtlas(_loc3_),_loc6_ * 100,_loc7_ * 100,0.5,param1,1);
               this._effects.push(_loc8_);
               _loc7_++;
            }
            _loc6_++;
         }
         boundBox = new BoundBox();
         boundBox.minX = boundBox.minY = -(param2 + 0.25) * 100;
         boundBox.maxX = boundBox.maxY = (param2 + 0.25) * 100;
         boundBox.minZ = -300;
         boundBox.maxZ = 300;
      }
      
      public function die() : void
      {
         boundBox.reset();
      }
      
      public function dispose() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this._resources)
         {
            if(_loc1_ is BitmapTextureResource)
            {
               BitmapTextureResource(_loc1_).data = null;
            }
            _loc1_.dispose();
         }
      }
      
      public function play() : void
      {
         var _loc1_:ParticleEffect = null;
         for each(_loc1_ in this._effects)
         {
            this._particles.addEffect(_loc1_);
         }
      }
      
      public function get resources() : Vector.<Resource>
      {
         return this._resources;
      }
   }
}

