package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.objects.Mesh;
   import com.greensock.easing.Back;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class TrapGunBarrelEntity extends BuildingEntity implements ITrapEntity
   {
      
      private var _active:Boolean;
      
      private var _spinUpComplete:Boolean = false;
      
      private var _spinSpeed:Number = 10;
      
      private var _wheelInactiveY:Number = -75;
      
      private var _numFlashes:int = 6;
      
      private var _muzzleflashes:Vector.<Mesh>;
      
      private var mesh_wheel:Mesh;
      
      public function TrapGunBarrelEntity()
      {
         super();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.mesh_wheel != null)
         {
            TweenMaxDelta.killTweensOf(this.mesh_wheel);
            this.mesh_wheel = null;
         }
         this._muzzleflashes = null;
      }
      
      public function activate() : void
      {
         this._active = true;
         if(this.mesh_wheel == null)
         {
            return;
         }
         TweenMaxDelta.to(this.mesh_wheel,1,{
            "z":0,
            "rotationZ":Math.PI * 20,
            "ease":Back.easeInOut,
            "overwrite":true,
            "onComplete":function():void
            {
               _spinUpComplete = true;
            }
         });
         buildingData.soundSource.play(buildingData.getSound("trigger"),{
            "minDistance":5000,
            "maxDistance":10000
         });
      }
      
      public function deactivate() : void
      {
         this._active = false;
         this._spinUpComplete = false;
         if(this.mesh_wheel == null)
         {
            return;
         }
         TweenMaxDelta.to(this.mesh_wheel,2,{
            "z":this._wheelInactiveY,
            "rotationZ":this.mesh_wheel.rotationZ + Math.PI * 2,
            "overwrite":true,
            "ease":Back.easeOut
         });
         var _loc1_:int = 0;
         while(_loc1_ < this._numFlashes)
         {
            this._muzzleflashes[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      override public function update(param1:Number = 1) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Mesh = null;
         super.update(param1);
         if(this._spinUpComplete)
         {
            if(this.mesh_wheel != null)
            {
               this.mesh_wheel.rotationZ += param1 * this._spinSpeed;
            }
            _loc2_ = int(Math.random() * this._numFlashes);
            _loc3_ = 0;
            while(_loc3_ < this._numFlashes)
            {
               _loc4_ = this._muzzleflashes[_loc3_];
               _loc4_.visible = _loc3_ == _loc2_;
               _loc3_++;
            }
         }
      }
      
      override protected function onMeshReady() : void
      {
         var _loc2_:Mesh = null;
         super.onMeshReady();
         this.mesh_wheel = mesh_building.getChildByName("wheel") as Mesh;
         this._muzzleflashes = new Vector.<Mesh>();
         var _loc1_:int = 1;
         while(_loc1_ <= this._numFlashes)
         {
            _loc2_ = mesh_building.getChildByName("muzzleflash" + _loc1_) as Mesh;
            if(_loc2_ != null)
            {
               _loc2_.visible = false;
               this._muzzleflashes.push(_loc2_);
            }
            _loc1_++;
         }
         if(this._active)
         {
            this.mesh_wheel.z = 0;
         }
      }
   }
}

