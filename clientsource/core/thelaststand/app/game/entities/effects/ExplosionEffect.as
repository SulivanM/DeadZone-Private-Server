package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.effects.ParticleEffect;
   import alternativa.engine3d.effects.ParticleSystem;
   import alternativa.engine3d.effects.TextureAtlas;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Quad;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.entities.effects.particles.ExplosionDustCloud;
   import thelaststand.app.game.entities.effects.particles.ExplosionDustShaft;
   import thelaststand.app.game.entities.effects.particles.ExplosionFireball;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.alternativa.engine3d.primitives.Plane;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class ExplosionEffect extends Object3D implements IEntityEffect
   {
      
      private var _resources:Vector.<Resource>;
      
      private var _effects:Vector.<ParticleEffect>;
      
      private var _dustTendrils:Vector.<thelaststand.engine.alternativa.engine3d.primitives.Plane>;
      
      private var _particles:ParticleSystem;
      
      private var _angle:Number;
      
      private var _spreadAngle:Number;
      
      private var light_omni:OmniLight;
      
      private var obj_scorchMark:thelaststand.engine.alternativa.engine3d.primitives.Plane;
      
      public function ExplosionEffect(param1:Number = 0, param2:Number = 6.283185307179586)
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc8_:BitmapTextureResource = null;
         var _loc25_:* = false;
         var _loc26_:Number = NaN;
         var _loc27_:ExplosionDustCloud = null;
         var _loc30_:thelaststand.engine.alternativa.engine3d.primitives.Plane = null;
         super();
         this._angle = param1;
         this._spreadAngle = param2;
         var _loc5_:Number = 1;
         var _loc6_:Number = 1;
         var _loc7_:Number = 1;
         _loc8_ = ResourceManager.getInstance().materials.getBitmapTextureResource("textures/normal-flat");
         var _loc9_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-clouddust.png");
         var _loc10_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-clouddust-white.png");
         var _loc11_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-dirtclods2.png");
         var _loc12_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-dustshaft.png");
         var _loc13_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-dustpillar.png");
         var _loc14_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-fireball.png");
         var _loc15_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-sparks.png");
         var _loc16_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/particle-sparkshaft.png");
         var _loc17_:BitmapTextureResource = ResourceManager.getInstance().materials.getBitmapTextureResource("images/effects/decal-scorchmark.png");
         this._resources = new <Resource>[_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc17_];
         if(!Global.lowFPS && Global.activeMuzzleFlashCount < 2 && Settings.getInstance().dynamicLights)
         {
            this.light_omni = new OmniLight(16775912,0,1000);
            this.light_omni.intensity = 2;
            this.light_omni.z = 50;
            addChild(this.light_omni);
         }
         var _loc18_:StandardMaterial = new StandardMaterial(_loc17_,_loc8_);
         _loc18_.alphaThreshold = 0.9;
         _loc18_.specularPower = 0;
         this.obj_scorchMark = Primitives.PLANE_DOUBLE_SIDED.clone() as thelaststand.engine.alternativa.engine3d.primitives.Plane;
         this.obj_scorchMark.setMaterialToAllSurfaces(_loc18_);
         this.obj_scorchMark.scaleX = this.obj_scorchMark.scaleY = 300;
         this.obj_scorchMark.rotationX = Math.PI;
         this.obj_scorchMark.rotationZ = Math.PI * Math.random() * 2;
         this.obj_scorchMark.z = -1;
         addChild(this.obj_scorchMark);
         var _loc19_:int = 12;
         this._dustTendrils = new Vector.<thelaststand.engine.alternativa.engine3d.primitives.Plane>();
         var _loc20_:StandardMaterial = new StandardMaterial(_loc12_,_loc8_);
         _loc20_.alphaThreshold = 0.9;
         _loc20_.specularPower = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc19_)
         {
            _loc4_ = this._angle + this._spreadAngle * (_loc3_ / _loc19_) + Math.random() * this._spreadAngle * 0.125;
            _loc30_ = Primitives.PLANE_DOUBLE_SIDED.clone() as thelaststand.engine.alternativa.engine3d.primitives.Plane;
            _loc30_.setMaterialToAllSurfaces(_loc20_);
            _loc30_.scaleX = Random.float(50,500);
            _loc30_.scaleY = Random.float(300,800);
            _loc30_.rotationX = Random.float(Math.PI,Math.PI * 0.9);
            _loc30_.rotationZ = _loc4_ - Math.PI * 0.5;
            _loc30_.x = Math.cos(_loc4_) * _loc30_.scaleY * 0.25;
            _loc30_.y = Math.sin(_loc4_) * _loc30_.scaleY * 0.25;
            _loc30_.z = -_loc30_.rotationX * 10;
            if(this.light_omni != null)
            {
               _loc30_.excludeLight(this.light_omni);
            }
            this._dustTendrils.push(_loc30_);
            addChild(_loc30_);
            _loc3_++;
         }
         this._effects = new Vector.<ParticleEffect>();
         this._particles = new ParticleSystem();
         addChild(this._particles);
         var _loc21_:ExplosionFireball = new ExplosionFireball(new TextureAtlas(_loc14_),new TextureAtlas(_loc16_),new TextureAtlas(_loc15_));
         this._effects.push(_loc21_);
         var _loc22_:ExplosionDustShaft = new ExplosionDustShaft(new TextureAtlas(_loc12_),new TextureAtlas(_loc13_),new TextureAtlas(_loc11_),_loc5_,_loc6_,_loc7_);
         this._effects.push(_loc22_);
         var _loc23_:TextureAtlas = new TextureAtlas(_loc9_);
         var _loc24_:TextureAtlas = new TextureAtlas(_loc10_);
         var _loc28_:int = 10;
         _loc3_ = 0;
         while(_loc3_ < _loc28_)
         {
            _loc25_ = Math.random() < 0.25;
            _loc4_ = this._angle + _loc3_ / _loc28_ * this._spreadAngle;
            _loc26_ = Random.float(80,140);
            _loc27_ = new ExplosionDustCloud(_loc25_ ? _loc24_ : _loc23_,_loc4_,_loc26_,_loc25_ ? 0.5 : 1,0.5,3,1,_loc5_,_loc6_,_loc7_);
            this._effects.push(_loc27_);
            _loc3_++;
         }
         var _loc29_:int = 20;
         _loc3_ = 0;
         while(_loc3_ < 20)
         {
            _loc25_ = Math.random() < 0.25;
            _loc4_ = this._angle + _loc3_ / _loc29_ * this._spreadAngle;
            _loc26_ = Random.float(200,400);
            _loc27_ = new ExplosionDustCloud(_loc25_ ? _loc24_ : _loc23_,_loc4_,_loc26_,(_loc25_ ? 0.5 : 1) * 0.25,1,2,1.5,_loc5_,_loc6_,_loc7_);
            this._effects.push(_loc27_);
            _loc3_++;
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this._resources)
         {
            if(_loc1_ is BitmapTextureResource)
            {
               BitmapTextureResource(_loc1_).data = null;
            }
            _loc1_.dispose();
         }
      }
      
      public function play() : void
      {
         var tendril:thelaststand.engine.alternativa.engine3d.primitives.Plane = null;
         var effect:ParticleEffect = null;
         var time:Number = NaN;
         if(this.light_omni != null)
         {
            TweenMaxDelta.to(this.light_omni,0.25,{"intensity":0});
         }
         TweenMaxDelta.from(this.obj_scorchMark,0.15,{
            "delay":0.05,
            "scaleX":0,
            "scaleY":0
         });
         for each(tendril in this._dustTendrils)
         {
            time = 0.05 + Math.random() * 0.25;
            TweenMaxDelta.from(tendril,time,{
               "scaleY":tendril.scaleY * 0.25,
               "ease":Quad.easeOut,
               "onCompleteParams":[tendril],
               "onComplete":function(param1:thelaststand.engine.alternativa.engine3d.primitives.Plane):void
               {
                  if(param1 != null && param1.parent != null)
                  {
                     param1.parent.removeChild(param1);
                  }
               }
            });
            TweenMaxDelta.to(StandardMaterial(tendril.getSurface(0).material),time,{"alpha":0});
         }
         for each(effect in this._effects)
         {
            this._particles.addEffect(effect);
         }
      }
      
      public function get resources() : Vector.<Resource>
      {
         return this._resources;
      }
   }
}

