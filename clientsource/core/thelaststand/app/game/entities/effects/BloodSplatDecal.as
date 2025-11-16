package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Decal;
   import alternativa.engine3d.resources.Geometry;
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Linear;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.alternativa.engine3d.primitives.Plane;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class BloodSplatDecal extends GameEntity
   {
      
      private static var _nextId:int;
      
      private static var _material:StandardMaterial;
      
      private static var _decals:Vector.<BloodSplatDecal> = new Vector.<BloodSplatDecal>();
      
      private static var _geometry:Dictionary = new Dictionary(true);
      
      private var _asset:Decal;
      
      private var _age:Number = 0;
      
      private var _life:Number = 30;
      
      private var _dead:Boolean = false;
      
      public function BloodSplatDecal(param1:Number, param2:Number, param3:Number, param4:Number = 200, param5:Number = NaN)
      {
         super();
         if(_material == null || _material.diffuseMap == null || _material.diffuseMap.isDisposed)
         {
            updateMaterial();
         }
         name = "_bloodDecal" + _nextId++;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._asset = new Decal();
         this._asset.mouseEnabled = this._asset.mouseChildren = false;
         this._asset.geometry = BloodSplatDecal.getGeometry(Random.integer(0,4));
         this._asset.addSurface(_material,0,2);
         asset = this._asset;
         transform.scale.x = param4 + Random.float(-0.25,0.5) * param4;
         transform.scale.y = param4 + Random.float(-0.25,0.5) * param4;
         transform.position.x = param1;
         transform.position.y = param2;
         transform.position.z = param3;
         transform.rotateAround(Vector3D.Z_AXIS,isNaN(param5) ? Math.PI * 2 * Math.random() : param5);
         updateTransform();
         _decals.push(this);
         addedToScene.add(this.onAddedToScene);
      }
      
      private static function updateMaterial() : void
      {
         _material = ResourceManager.getInstance().materials.getStandardMaterial("blood-decal","images/effects/decal-blood.png");
         _material.transparentPass = true;
         _material.alphaThreshold = 0.9;
      }
      
      public static function disposeAll() : void
      {
         var _loc1_:BloodSplatDecal = null;
         if(_material != null)
         {
            _material.diffuseMap = null;
            _material = null;
         }
         for each(_loc1_ in _decals)
         {
            _loc1_.dispose();
         }
         _decals.length = 0;
      }
      
      private static function getGeometry(param1:int) : Geometry
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Geometry = null;
         if(_geometry[param1] == null)
         {
            _loc3_ = 4;
            _loc4_ = param1 / _loc3_;
            _loc5_ = _loc4_ + 1 / _loc3_;
            _loc2_ = new thelaststand.engine.alternativa.engine3d.primitives.Plane(1,1).geometry;
            _loc2_.setAttributeValues(8,new <Number>[_loc4_,0,_loc5_,0,_loc5_,1,_loc4_,1]);
            _geometry[param1] = _loc2_;
         }
         else
         {
            _loc2_ = _geometry[param1];
         }
         return _loc2_;
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(transform);
         if(this._asset != null)
         {
            this._asset.getSurface(0).material = null;
            this._asset.geometry = null;
            this._asset = null;
         }
         addedToScene.remove(this.onAddedToScene);
         super.dispose();
      }
      
      override public function update(param1:Number = 1) : void
      {
         if(this._dead)
         {
            return;
         }
         this._age += param1;
         if(this._age >= this._life)
         {
            this.die();
            return;
         }
      }
      
      private function die() : void
      {
         this._dead = true;
         TweenMaxDelta.to(transform.scale,6,{
            "x":0,
            "y":0,
            "ease":Linear.easeNone,
            "onUpdate":updateTransform,
            "onComplete":this.dispose
         });
      }
      
      private function onAddedToScene(param1:BloodSplatDecal) : void
      {
         TweenMaxDelta.from(transform.scale,0.2,{
            "x":0,
            "y":0,
            "onUpdate":updateTransform
         });
      }
   }
}

