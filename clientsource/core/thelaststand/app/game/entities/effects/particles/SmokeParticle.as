package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import com.deadreckoned.threshold.math.Random;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   
   public class SmokeParticle extends ParticleEffect
   {
      
      private var _particle:ParticlePrototype;
      
      private var _size:Number = 20;
      
      private var _scale:Number = 1;
      
      private var _rotation:Number = 0;
      
      private var _position:Vector3D;
      
      private var _direction:Vector3D;
      
      private var _ty:Number = -10;
      
      private var _life:Number;
      
      private var _speed:Number;
      
      public var died:Signal = new Signal(SmokeParticle);
      
      public function SmokeParticle(param1:TextureAtlas, param2:Number = 1, param3:Number = 3, param4:Number = 1)
      {
         super();
         this._life = param3 * Random.float(0.75,1.25);
         this._speed = Random.float(0.25,0.5);
         this._particle = new ParticlePrototype(256,256,param1,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         this._particle.addKey(0,0,0.9,0.9,1,1,1,0);
         this._particle.addKey(this._life * 0.1,0,1,1,1,1,1,param2);
         this._particle.addKey(this._life,0,2,2,1,1,1,0);
         this._scale = param4 * Random.float(0.9,1.25);
         this._rotation = Random.float(0,Math.PI * 2);
         this._direction = new Vector3D(Math.cos(this._rotation) * 0.25,Math.sin(this._rotation) * 0.25,90 * Math.PI / 180);
         this._position = new Vector3D();
         setLife(this._life + 1);
         addKey(0,this.script);
      }
      
      private function script(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = param2 / this._particle.lifeTime;
         this._position.x += this._direction.x * this._speed;
         this._position.y += this._direction.y * this._speed;
         this._position.z += this._direction.z * this._speed;
         this._particle.createParticle(this,param2,this._position,this._rotation,this._scale,this._scale);
         if(_loc3_ > 1)
         {
            this.alternativa3d::system = null;
            this._position.setTo(0,0,0);
            this.died.dispatch(this);
         }
      }
   }
}

