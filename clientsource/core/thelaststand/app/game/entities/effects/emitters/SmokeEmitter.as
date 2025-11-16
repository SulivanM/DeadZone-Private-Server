package thelaststand.app.game.entities.effects.emitters
{
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.effects.TextureAtlas;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import thelaststand.app.game.entities.effects.particles.SmokeParticle;
   import thelaststand.common.resources.ResourceManager;
   
   public class SmokeEmitter extends ParticleSystem
   {
      
      private var _resources:Vector.<Resource>;
      
      private var _pool:Vector.<SmokeParticle>;
      
      private var _poolSize:int;
      
      private var _poolIndex:int;
      
      private var _emissionTime:int = 250;
      
      private var _lastEmissionTime:int;
      
      private var _atlas:TextureAtlas;
      
      private var _diffuse:BitmapTextureResource;
      
      public function SmokeEmitter(param1:int, param2:int = 250)
      {
         super();
         this._resources = new Vector.<Resource>();
         this.updateResources();
         this._atlas = new TextureAtlas(this._diffuse);
         this._emissionTime = param2;
         this._poolSize = param1;
         this.reset();
      }
      
      public function get resources() : Vector.<Resource>
      {
         return this._resources;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeChildren();
         this._diffuse = null;
         this._resources = null;
         this._atlas.diffuse = null;
      }
      
      public function reset() : void
      {
         var _loc2_:SmokeParticle = null;
         clear();
         this._poolIndex = this._poolSize;
         this._pool = new Vector.<SmokeParticle>(this._poolSize,true);
         var _loc1_:int = 0;
         while(_loc1_ < this._poolSize)
         {
            _loc2_ = new SmokeParticle(this._atlas,1,3,0.25);
            _loc2_.died.add(this.onParticleDie);
            this._pool[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      public function update(param1:Number) : void
      {
         if(param1 - this._lastEmissionTime > this._emissionTime)
         {
            this.emit();
         }
      }
      
      private function emit() : void
      {
         if(this._poolIndex <= 0)
         {
            return;
         }
         var _loc1_:SmokeParticle = this._pool[--this._poolIndex];
         if(_loc1_ != null)
         {
            addEffect(_loc1_);
         }
      }
      
      private function onParticleDie(param1:SmokeParticle) : void
      {
         this._pool[this._poolIndex++] = param1;
      }
      
      private function updateResources() : void
      {
         this._diffuse = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-clouddust.png");
         if(this._diffuse == null)
         {
            return;
         }
         this._resources[0] = this._diffuse;
         if(this._atlas != null)
         {
            this._atlas.diffuse = this._diffuse;
         }
      }
   }
}

