package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.effects.TextureAtlas;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import com.deadreckoned.threshold.math.Random;
   import thelaststand.app.game.entities.effects.particles.GroundDustCloud;
   import thelaststand.common.resources.ResourceManager;
   
   public class WireTrapDust extends Object3D
   {
      
      private var _diffuse:BitmapTextureResource;
      
      private var _resources:Vector.<Resource>;
      
      private var _effects:Vector.<ParticleEffect>;
      
      private var _particles:ParticleSystem;
      
      public function WireTrapDust()
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:GroundDustCloud = null;
         super();
         this._diffuse = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-clouddust.png");
         this._resources = new <Resource>[this._diffuse];
         this._effects = new Vector.<ParticleEffect>();
         this._particles = new ParticleSystem();
         addChild(this._particles);
         var _loc5_:int = 10;
         var _loc6_:TextureAtlas = new TextureAtlas(this._diffuse);
         _loc1_ = 0;
         while(_loc1_ < 10)
         {
            _loc2_ = _loc1_ / _loc5_ * Math.PI * 2;
            _loc3_ = Random.float(200,400);
            _loc4_ = new GroundDustCloud(_loc6_,_loc2_,_loc3_,0.5,1);
            this._effects.push(_loc4_);
            _loc1_++;
         }
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._resources = null;
         if(this._diffuse != null)
         {
            this._diffuse.data = null;
            this._diffuse.dispose();
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

