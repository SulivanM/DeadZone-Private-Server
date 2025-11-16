package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.materials.FillMaterial;
   import alternativa.engine3d.objects.Decal;
   import com.deadreckoned.threshold.data.ObjectPool;
   import flash.geom.Vector3D;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class BulletTracer extends GameEntity
   {
      
      private static var TRACER_MATERIAL:FillMaterial = new FillMaterial(16707498);
      
      private static var _id:int = 0;
      
      private static var _tmpVec:Vector3D = new Vector3D();
      
      public static var pool:ObjectPool = new ObjectPool(BulletTracer,200,0,false);
      
      private var _asset:Decal;
      
      private var _age:Number = 0;
      
      private var _life:Number = 0;
      
      public function BulletTracer()
      {
         super();
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._asset = new Decal();
         this._asset.mouseEnabled = this._asset.mouseChildren = false;
         this._asset.geometry = Primitives.SIMPLE_PLANE.geometry;
         this._asset.addSurface(TRACER_MATERIAL,0,2);
         asset = this._asset;
         addedToScene.add(this.onAddedToScene);
         removedFromScene.add(this.onRemovedFromScene);
      }
      
      public function init(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         name = "_tracer" + _id++;
         this._age = 0;
         this._life = 0.05;
         var _loc7_:Number = param4 - param1;
         var _loc8_:Number = param5 - param2;
         var _loc9_:Number = param6 - param3;
         var _loc10_:Number = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_ + _loc9_ * _loc9_);
         var _loc11_:Number = _loc10_ * (0.5 + Math.random() * 0.3);
         transform.scale.x = _loc11_;
         transform.scale.y = 2.5;
         transform.position.x = param4 - _loc11_ * (_loc7_ / _loc11_) * 0.5;
         transform.position.y = param5 - _loc11_ * (_loc8_ / _loc11_) * 0.5;
         transform.position.z = param6 - _loc11_ * (_loc9_ / _loc11_) * 0.5;
         _tmpVec.x = param4;
         _tmpVec.y = param5;
         _tmpVec.z = param6;
         transform.lookAt(_tmpVec,Vector3D.X_AXIS);
         this._asset.visible = true;
         updateTransform();
      }
      
      override public function update(param1:Number = 1) : void
      {
         if(this._asset.visible)
         {
            this._age += param1;
            if(this._age > this._life)
            {
               this._asset.visible = false;
               pool.put(this);
               return;
            }
         }
      }
      
      private function onAddedToScene(param1:BulletTracer) : void
      {
      }
      
      private function onRemovedFromScene(param1:BulletTracer) : void
      {
         pool.put(this);
      }
   }
}

