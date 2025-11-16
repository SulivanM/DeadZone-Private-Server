package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.effects.TextureAtlas;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import com.deadreckoned.threshold.math.Random;
   import flash.geom.Vector3D;
   import thelaststand.app.game.entities.effects.particles.BloodSprayParticle;
   import thelaststand.common.resources.ResourceManager;
   
   public class BloodSprayEffect extends Object3D implements IEntityEffect
   {
      
      private var _resources:Vector.<Resource>;
      
      private var _diffuse:BitmapTextureResource;
      
      private var _particles:Vector.<BloodSprayParticle>;
      
      private var _particleSys:ParticleSystem;
      
      private var _atlasStatic:TextureAtlas;
      
      private var _atlasTrail:TextureAtlas;
      
      public function BloodSprayEffect()
      {
         var _loc2_:Number = NaN;
         var _loc3_:BloodSprayParticle = null;
         super();
         this._resources = new Vector.<Resource>();
         this.updateResources();
         this._particleSys = new ParticleSystem();
         addChild(this._particleSys);
         this._particles = new Vector.<BloodSprayParticle>();
         this._atlasStatic = new TextureAtlas(this._diffuse,null,4,2,4,1);
         this._atlasTrail = new TextureAtlas(this._diffuse,null,4,2,0,4,30,false,1);
         var _loc1_:int = 0;
         while(_loc1_ < 6)
         {
            _loc2_ = _loc1_ == 0 ? 0.3 : Random.float(0.3,0.6);
            _loc3_ = new BloodSprayParticle(_loc1_ == 0 ? this._atlasTrail : this._atlasStatic,_loc2_);
            this._particles.push(_loc3_);
            _loc1_++;
         }
      }
      
      public function dispose() : void
      {
         removeChildren();
         this._diffuse = null;
         this._resources = null;
         this._atlasTrail.diffuse = null;
         this._atlasTrail = null;
         this._atlasStatic.diffuse = null;
         this._atlasStatic = null;
      }
      
      public function stop() : void
      {
         this._particleSys.stop();
      }
      
      public function play() : void
      {
         this._particleSys.play();
      }
      
      public function init(param1:Vector3D, param2:Number = 1, param3:Number = 5) : void
      {
         var _loc5_:BloodSprayParticle = null;
         if(this._diffuse == null || this._diffuse.isDisposed || !this._diffuse.isUploaded)
         {
            this.updateResources();
         }
         this._particleSys.clear();
         var _loc4_:int = 0;
         for(; _loc4_ < this._particles.length; _loc4_++)
         {
            _loc5_ = this._particles[_loc4_];
            _loc5_.alternativa3d::nextInSystem = null;
            _loc5_.alternativa3d::system = null;
            if(_loc4_ == 0)
            {
               if(Math.random() > 0.8)
               {
                  continue;
               }
               _loc5_.sprayScale = param2 * Random.float(1.75,2.5);
               _loc5_.spraySpeed = 2;
               _loc5_.sprayRotation = Math.atan2(param1.y,param1.x) - Math.PI * 0.5;
            }
            else
            {
               _loc5_.sprayScale = param2 * Random.float(0.5,1.5);
               _loc5_.spraySpeed = Random.float(0,param3);
               _loc5_.sprayRotation = Math.random() * Math.PI * 2;
               _loc5_.frame = Math.random() < 0.5 ? 4 : 5;
            }
            _loc5_.sprayPosition.x = _loc5_.sprayPosition.y = _loc5_.sprayPosition.z = 0;
            _loc5_.sprayDirection.copyFrom(param1);
            if(_loc4_ != 0)
            {
               _loc5_.sprayDirection.x += Random.float(-0.15,0.15);
               _loc5_.sprayDirection.y += Random.float(-0.15,0.15);
               _loc5_.sprayDirection.z += Random.float(-0.15,5);
               if(Math.random() < 0.5)
               {
                  _loc5_.sprayDirection.x *= -1;
                  _loc5_.sprayDirection.z *= -1;
               }
               _loc5_.sprayPosition.x = Math.cos(param1.x) * Random.float(0,10);
               _loc5_.sprayPosition.y = Math.sin(param1.y) * Random.float(0,10);
            }
            _loc5_.sprayDirection.normalize();
            this._particleSys.addEffect(_loc5_);
         }
      }
      
      private function updateResources() : void
      {
         this._diffuse = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particles-blood.png");
         this._resources[0] = this._diffuse;
         if(this._atlasStatic != null)
         {
            this._atlasStatic.diffuse = this._diffuse;
         }
         if(this._atlasTrail != null)
         {
            this._atlasTrail.diffuse = this._diffuse;
         }
      }
      
      public function get resources() : Vector.<Resource>
      {
         return this._resources;
      }
   }
}

