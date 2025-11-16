package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Back;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   
   public class ConfettiParticle extends ParticleEffect
   {
      
      private var _pos:Vector3D;
      
      private var _dir:Vector3D;
      
      private var _speed:Number;
      
      private var _scaleX:Number;
      
      private var _scaleY:Number;
      
      private var _frame:int;
      
      private var _rot:Number;
      
      private var _confetti:ParticlePrototype;
      
      public function ConfettiParticle(param1:TextureAtlas, param2:Vector3D, param3:Number, param4:Number = 1)
      {
         super();
         this._confetti = new ParticlePrototype(10,10,param1,true,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         this._confetti.addKey(0,0,0.5,0.5,1,1,1,1);
         this._confetti.addKey(0.25 * param4,0,1,1,1,1,1,1);
         this._confetti.addKey(0.5 * param4,0,1.25,1.25,1,1,1,0);
         this._dir = param2;
         this._speed = param3;
         this._pos = new Vector3D();
         this._rot = Math.random() * Math.PI * 2;
         this._scaleX = Random.float(0.5,1);
         this._scaleY = Random.float(0.5,1);
         this._frame = Random.integer(0,param1.columnsCount * param1.rowsCount);
         addKey(0,this.script);
      }
      
      private function script(param1:Number, param2:Number) : void
      {
         this._pos.z = Back.easeOut(param2 / this._confetti.lifeTime,0,this._dir.z * this._speed * 50,1);
         this._pos.x += this._dir.x * this._speed;
         this._pos.y += this._dir.y * this._speed;
         this._rot += this._speed * 0.01;
         this._confetti.createParticle(this,param2,this._pos,this._rot,this._scaleX,this._scaleY,1,this._frame);
      }
   }
}

