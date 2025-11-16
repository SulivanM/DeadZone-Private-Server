package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.objects.Mesh;
   import com.greensock.easing.Cubic;
   import org.osflash.signals.Signal;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class DoorBuildingEntity extends BuildingEntity
   {
      
      private var _isOpen:Boolean;
      
      private var mesh_door:Mesh;
      
      public var stateChanged:Signal;
      
      public function DoorBuildingEntity()
      {
         super();
         this.stateChanged = new Signal(DoorBuildingEntity);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.mesh_door != null)
         {
            TweenMaxDelta.killTweensOf(this.mesh_door);
            this.mesh_door = null;
         }
      }
      
      public function toggleOpen() : void
      {
         this.setOpenState(!this._isOpen,true);
      }
      
      public function setOpenState(param1:Boolean, param2:Boolean = true) : void
      {
         if(param1 == this._isOpen)
         {
            this.updateFlags();
            return;
         }
         this._isOpen = param1;
         this.updateFlags();
         this.playDoorAnimation(param2 && Boolean(scene));
         if(this._isOpen)
         {
            mesh_hitArea.scaleZ = MAX_BOUND_HEIGHT * 0.5;
            mesh_hitArea.z = 250 + mesh_hitArea.scaleZ * 0.5;
         }
         else
         {
            mesh_hitArea.scaleZ = MAX_BOUND_HEIGHT;
            mesh_hitArea.z = mesh_hitArea.scaleZ * 0.5;
         }
         this.stateChanged.dispatch(this);
      }
      
      private function playDoorAnimation(param1:Boolean = true) : void
      {
         var ty:int;
         var ease:Function = null;
         var time:Number = NaN;
         var snd:String = null;
         var animated:Boolean = param1;
         if(this.mesh_door == null)
         {
            return;
         }
         ty = this._isOpen ? 250 : 0;
         if(animated)
         {
            ease = this._isOpen ? Cubic.easeInOut : Cubic.easeIn;
            time = this._isOpen ? 2 : 1;
            TweenMaxDelta.to(this.mesh_door,time,{
               "z":ty,
               "ease":ease,
               "onUpdate":function():void
               {
                  mesh_door.x = Math.random() * 2 - 1;
               },
               "onComplete":function():void
               {
                  mesh_door.x = 0;
               }
            });
            snd = buildingData.getSound(this._isOpen ? "open" : "close");
            if(snd != null)
            {
               buildingData.soundSource.play(snd);
            }
         }
         else
         {
            this.mesh_door.z = ty;
         }
      }
      
      private function updateFlags() : void
      {
         var _loc1_:Boolean = false;
         _loc1_ = this._isOpen || buildingData.dead;
         if(_loc1_)
         {
            flags |= GameEntityFlags.FORCE_PASSABLE;
            flags &= ~GameEntityFlags.FORCE_UNPASSABLE;
         }
         else
         {
            flags |= GameEntityFlags.FORCE_UNPASSABLE;
            flags &= ~GameEntityFlags.FORCE_PASSABLE;
         }
         buildingData.setTraversalAreaEnabledState(!_loc1_);
         if(scene != null)
         {
            scene.map.updateCellsForEntity(this);
         }
      }
      
      override protected function onMeshReady() : void
      {
         super.onMeshReady();
         this.mesh_door = mesh_building.getChildByName("door") as Mesh;
         this.playDoorAnimation(false);
      }
      
      public function get isOpen() : Boolean
      {
         return this._isOpen;
      }
   }
}

