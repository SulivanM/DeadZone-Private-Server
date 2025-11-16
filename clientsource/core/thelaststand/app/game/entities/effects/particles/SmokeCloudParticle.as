package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Quad;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   
   public class SmokeCloudParticle extends ParticleEffect
   {
      
      private var _particle:ParticlePrototype;
      
      private var _scale:Number = 1;
      
      private var _rotation:Number = 0;
      
      private var _position:Vector3D;
      
      private var _direction:Vector3D;
      
      private var _ty:Number = -10;
      
      private var _speed:Number;
      
      public function SmokeCloudParticle(param1:TextureAtlas, param2:Number, param3:Number, param4:Number = 1, param5:Number = 3, param6:Number = 1)
      {
         super();
         this._speed = 0.05;
         var _loc7_:Number = param5 * 0.1;
         var _loc8_:Number = param5 * 0.66;
         var _loc9_:Number = param5;
         var _loc10_:Number = param5 + 2;
         this._particle = new ParticlePrototype(256,256,param1,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         this._particle.addKey(0,0,1.5,1.5,1,1,1,0);
         this._particle.addKey(_loc7_,0,1.6,1.6,1,1,1,param4);
         this._particle.addKey(_loc8_,0,1.7,1.7,1,1,1,param4 * 0.8);
         this._particle.addKey(_loc9_,0,1.8,1.8,1,1,1,param4);
         this._particle.addKey(_loc10_,0,1.9,1.9,1,1,1,0);
         this._scale = Random.float(0.25,1.25);
         this._rotation = Random.float(0,Math.PI * 2);
         this._direction = new Vector3D(Math.cos(this._rotation),Math.sin(this._rotation));
         this._position = new Vector3D(param2 + this._direction.x * 100 * Random.float(-20,20) / 100,param3 + this._direction.y * 100 * Random.float(-20,20) / 100,0);
         this._ty = Random.float(0,50);
         addKey(0,this.script);
      }
      
      private function script(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = param2 / this._particle.lifeTime;
         this._position.z = Quad.easeIn(_loc3_,50,this._ty,1);
         this._rotation += this._speed * 0.005;
         this._particle.createParticle(this,param2,this._position,this._rotation,this._scale,this._scale);
      }
   }
}

