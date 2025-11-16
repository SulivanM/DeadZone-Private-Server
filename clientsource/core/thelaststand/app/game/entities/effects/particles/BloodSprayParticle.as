package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   
   public class BloodSprayParticle extends ParticleEffect
   {
      
      private var _paticle:ParticlePrototype;
      
      private var _atlas:TextureAtlas;
      
      private var _life:Number = 0.2;
      
      public var sprayDirection:Vector3D;
      
      public var sprayPosition:Vector3D;
      
      public var sprayRotation:Number = 0;
      
      public var sprayScale:Number = 1;
      
      public var spraySpeed:Number = 0;
      
      public var frame:int = 0;
      
      public function BloodSprayParticle(param1:TextureAtlas, param2:Number = 1)
      {
         super();
         this._atlas = param1;
         this._life = param2;
         this._paticle = new ParticlePrototype(128,128,this._atlas,true,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         this._paticle.addKey(0,0,0.75,0.75,1,1,1,1);
         this._paticle.addKey(this._life * 0.5,0,0.75,0.75,1,1,1,1);
         this._paticle.addKey(this._life,0,1.25,1.25,1,1,1,0);
         this.sprayPosition = new Vector3D();
         this.sprayDirection = new Vector3D();
         addKey(0,this.script);
      }
      
      private function script(param1:Number, param2:Number) : void
      {
         this.sprayPosition.x += this.sprayDirection.x * this.spraySpeed;
         this.sprayPosition.y += this.sprayDirection.y * this.spraySpeed;
         this.sprayPosition.z += this.sprayDirection.z * this.spraySpeed;
         this._paticle.createParticle(this,param2,this.sprayPosition,this.sprayRotation,this.sprayScale,this.sprayScale,1,this.frame);
      }
   }
}

