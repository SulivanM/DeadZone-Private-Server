package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import com.deadreckoned.threshold.math.Random;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   
   public class ExplosionFireball extends ParticleEffect
   {
      
      private var _firePosition:Vector3D;
      
      private var _fireY:int = 64;
      
      private var _sparkPosition:Vector3D;
      
      private var _sparkY:int = 128;
      
      private var _shaftPosition:Vector3D;
      
      private var _shaftY:int = 128;
      
      public function ExplosionFireball(param1:TextureAtlas, param2:TextureAtlas, param3:TextureAtlas)
      {
         var fire:ParticlePrototype = null;
         var shaft:ParticlePrototype = null;
         var sparks:ParticlePrototype = null;
         var p0:Vector3D = null;
         var r0:Number = NaN;
         var p1:Vector3D = null;
         var r1:Number = NaN;
         var p2:Vector3D = null;
         var r2:Number = NaN;
         var fireAtlas:TextureAtlas = param1;
         var shaftAtlas:TextureAtlas = param2;
         var sparkAtlas:TextureAtlas = param3;
         super();
         fire = new ParticlePrototype(256,256,fireAtlas,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         fire.addKey(0,0,3.5,3.5,3,3,3,1);
         fire.addKey(0.25,0,1,1,1,1,1,0);
         this._firePosition = new Vector3D();
         addKey(0,function(param1:Number, param2:Number):void
         {
            _firePosition.z = _fireY - _fireY * (param2 / fire.lifeTime);
            fire.createParticle(this,param2,_firePosition);
         });
         shaft = new ParticlePrototype(256,256,shaftAtlas,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         shaft.addKey(0,0,2,1,2,2,2,1);
         shaft.addKey(0.15,0,2.1,1.1,1,1,1,0);
         this._shaftPosition = new Vector3D(0,0,this._shaftY);
         addKey(0,function(param1:Number, param2:Number):void
         {
            shaft.createParticle(this,param2,_shaftPosition);
         });
         sparks = new ParticlePrototype(256,256,sparkAtlas,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         sparks.addKey(0,0,0.75,0.75,2,2,2,1);
         sparks.addKey(0.2,0,1,1,1,1,1,0);
         sparks.addKey(0.6,0,1.25,1.25,0,0,0,0);
         p0 = new Vector3D(Random.float(-150,150),Random.float(-150,150),Random.float(20,80));
         r0 = Math.random() * Math.PI;
         addKey(0,function(param1:Number, param2:Number):void
         {
            sparks.createParticle(this,param2,p0,r0);
         });
         p1 = new Vector3D(Random.float(-150,150),Random.float(-150,150),Random.float(20,80));
         r1 = Math.random() * Math.PI;
         addKey(0.02,function(param1:Number, param2:Number):void
         {
            sparks.createParticle(this,param2,p1,r1);
         });
         p2 = new Vector3D(Random.float(-150,150),Random.float(-150,150),Random.float(20,80));
         r2 = Math.random() * Math.PI;
         addKey(0.03,function(param1:Number, param2:Number):void
         {
            sparks.createParticle(this,param2,p2,r2);
         });
      }
   }
}

