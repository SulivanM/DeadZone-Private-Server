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
   
   public class DustCloudEffect extends Object3D implements IEntityEffect
   {
      
      private var _diffuse:BitmapTextureResource;
      
      private var _resources:Vector.<Resource>;
      
      private var _effects:Vector.<ParticleEffect>;
      
      private var _particles:ParticleSystem;
      
      public function DustCloudEffect(param1:int = 10, param2:Number = 200, param3:Number = 400, param4:Number = 1, param5:Number = 3)
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:GroundDustCloud = null;
         super();
         this._diffuse = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-clouddust.png");
         this._resources = new <Resource>[this._diffuse];
         this._effects = new Vector.<ParticleEffect>();
         this._particles = new ParticleSystem();
         addChild(this._particles);
         var _loc10_:TextureAtlas = new TextureAtlas(this._diffuse);
         _loc6_ = 0;
         while(_loc6_ < param1)
         {
            _loc7_ = _loc6_ / param1 * Math.PI * 2;
            _loc8_ = Random.float(param2,param3);
            _loc9_ = new GroundDustCloud(_loc10_,_loc7_,_loc8_,1,1,param5,param4,1.2,1.2,1.03);
            this._effects.push(_loc9_);
            _loc6_++;
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

