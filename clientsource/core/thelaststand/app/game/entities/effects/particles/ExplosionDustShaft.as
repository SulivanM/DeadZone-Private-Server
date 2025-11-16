package thelaststand.app.game.entities.effects.particles
{
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticlePrototype;
   import alternativa.engine3d.effects.TextureAtlas;
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import flash.display3D.Context3DBlendFactor;
   import flash.geom.Vector3D;
   
   public class ExplosionDustShaft extends ParticleEffect
   {
      
      public function ExplosionDustShaft(param1:TextureAtlas, param2:TextureAtlas, param3:TextureAtlas, param4:Number = 1, param5:Number = 1, param6:Number = 1)
      {
         var c:Number;
         var shaft:ParticlePrototype = null;
         var p1:Vector3D = null;
         var pillar:ParticlePrototype = null;
         var r2:Number = NaN;
         var p2:Vector3D = null;
         var dirt:ParticlePrototype = null;
         var p3:Vector3D = null;
         var p4:Vector3D = null;
         var dustSheetAtlas:TextureAtlas = param1;
         var dustPillarAtlas:TextureAtlas = param2;
         var dirtAtlas:TextureAtlas = param3;
         var lightR:Number = param4;
         var lightG:Number = param5;
         var lightB:Number = param6;
         super();
         shaft = new ParticlePrototype(256,256,dustSheetAtlas,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         shaft.addKey(0,0,3.2,0.2,1 * lightR,1 * lightG,1 * lightB,1);
         shaft.addKey(0.05,0,3,3,1 * lightR,1 * lightG,1 * lightB,1);
         shaft.addKey(0.75,0,3,2,1 * lightR,1 * lightG,1 * lightB,0);
         p1 = new Vector3D(0,0,128);
         addKey(0.03,function(param1:Number, param2:Number):void
         {
            p1.z = Back.easeOut(param2 / dirt.lifeTime,200,100,1);
            shaft.createParticle(this,param2,p1);
         });
         c = Random.float(0.5,1.25);
         pillar = new ParticlePrototype(512,512,dustPillarAtlas,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         pillar.addKey(0,0,1,1,2 * lightR,2 * lightG,2 * lightB,0);
         pillar.addKey(0.15,0,1,1,c * lightR,c * lightG,c * lightB,1);
         pillar.addKey(1,0,1,0.75,c * lightR,c * lightG,c * lightB,0);
         r2 = Random.float(-20,10) * Math.PI / 180;
         p2 = new Vector3D(0,0,256);
         addKey(0.03,function(param1:Number, param2:Number):void
         {
            pillar.createParticle(this,param2,p2,r2);
         });
         dirt = new ParticlePrototype(256,256,dirtAtlas,false,Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         dirt.addKey(0,0,1,1,1 * lightR,1 * lightG,1 * lightB,1);
         dirt.addKey(0.25,0,1.5,1,1 * lightR,1 * lightG,1 * lightB,0.75);
         dirt.addKey(0.75,0,2,2,1 * lightR,1 * lightG,1 * lightB,0);
         p3 = new Vector3D(0,0,128);
         addKey(0.03,function(param1:Number, param2:Number):void
         {
            p3.z = Back.easeOut(param2 / dirt.lifeTime,128,200,1);
            dirt.createParticle(this,param2,p3,Quad.easeOut(param2 / dirt.lifeTime,0,Math.PI * 0.1,1));
         });
         p4 = new Vector3D(0,0,128);
         addKey(0.03,function(param1:Number, param2:Number):void
         {
            p4.z = Back.easeOut(param2 / dirt.lifeTime,128,100,1);
            dirt.createParticle(this,param2,p4,Quad.easeOut(param2 / dirt.lifeTime,0,-Math.PI * 0.1,1),1.25,1);
         });
      }
   }
}

