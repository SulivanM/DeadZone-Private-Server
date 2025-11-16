package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Quad;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   
   public class ExplosionDustCloud extends ParticleEffect
   {
      
      private var _particle:ParticlePrototype;
      
      private var _size:Number = 20;
      
      private var _scale:Number = 1;
      
      private var _rotation:Number = 0;
      
      private var _position:Vector3D;
      
      private var _direction:Vector3D;
      
      private var _ty:Number = -10;
      
      private var _speed:Number;
      
      public function ExplosionDustCloud(param1:TextureAtlas, param2:Number, param3:Number = 20, param4:Number = 1, param5:Number = 0.5, param6:Number = 3, param7:Number = 1, param8:Number = 1, param9:Number = 1, param10:Number = 1)
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         super();
         this._speed = param5;
         var _loc11_:Number = Random.float(0.5,1.25);
         if(Math.random() < 0.5)
         {
            _loc12_ = _loc13_ = _loc14_ = 10;
         }
         else
         {
            _loc12_ = Random.float(5.5,7);
            _loc13_ = _loc12_ * 0.65;
            _loc14_ = _loc13_ * 0.25;
         }
         var _loc15_:Number = param6 * Random.float(0.025,0.05);
         var _loc16_:Number = param6 * Random.float(0.25,1);
         this._particle = new ParticlePrototype(256,256,param1,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         this._particle.addKey(0,0,0.9,0.9,_loc12_ * param8,_loc13_ * param9,_loc14_ * param10,param4 * 0.25);
         this._particle.addKey(_loc15_,0,1,1,_loc11_ * param8,_loc11_ * param9,_loc11_ * param10,param4);
         this._particle.addKey(_loc16_,Math.PI * 0.01,2.5,2.5,_loc11_ * param8,_loc11_ * param9,_loc11_ * param10,0);
         this._scale = Random.float(75,100) / 100 * param7;
         this._rotation = param2;
         this._direction = new Vector3D(Math.cos(this._rotation),Math.sin(this._rotation));
         this._position = new Vector3D(this._direction.x * param3 * Random.float(20,100) / 100,this._direction.y * param3 * Random.float(20,100) / 100,Random.float(-40,-140));
         this._ty = Random.float(20,150);
         addKey(0,this.script);
      }
      
      private function script(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = param2 / this._particle.lifeTime;
         this._position.x += this._direction.x * this._speed;
         this._position.y += this._direction.y * this._speed;
         this._position.z = Quad.easeOut(_loc3_,64,this._ty,1);
         this._particle.createParticle(this,param2,this._position,this._rotation,this._scale,this._scale);
      }
   }
}

