package thelaststand.app.game.entities
{
   import com.deadreckoned.threshold.math.Random;
   import com.greensock.easing.Quad;
   import flash.geom.Vector3D;
   import flash.utils.getTimer;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.entities.effects.ExplosionType;
   import thelaststand.app.game.entities.effects.SmokeExplosion;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.data.ThrowTrajectoryData;
   import thelaststand.engine.audio.SoundSource3D;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class GrenadeEntity extends GameEntity
   {
      
      private static var _nextId:int = 0;
      
      private var _item:Gear;
      
      private var _owner:AIAgent;
      
      private var _trajectory:ThrowTrajectoryData;
      
      private var _bezierControl:Vector3D;
      
      private var _model:MeshGroup;
      
      private var _spawnTime:Number;
      
      private var _detonationTime:Number = 0;
      
      private var _exploded:Boolean = false;
      
      private var _damage:Number = 2;
      
      private var _damageVsBuildings:Number = 1;
      
      private var _range:Number;
      
      private var _speed:Number = 3;
      
      private var _travelTime:Number = 0;
      
      private var _velocity:Vector3D;
      
      private var _t:Number = 0;
      
      private var _soundSource:SoundSource3D;
      
      public function GrenadeEntity(param1:AIAgent, param2:Gear, param3:ThrowTrajectoryData)
      {
         super();
         passable = false;
         losVisible = false;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         name = "grenade" + _nextId++;
         this._owner = param1;
         this._item = param2;
         this._trajectory = param3;
         this._soundSource = new SoundSource3D(transform.position,name + "_sound");
         this._detonationTime = param2.attributes.getValue(ItemAttributes.GROUP_GEAR,"dettime") * 1000;
         asset = this._model = new MeshGroup();
         this._model.addChildrenFromResource(param2.xml.mdl.@uri.toString());
         this._model.mouseEnabled = this._model.mouseChildren = false;
         var _loc4_:Number = this._trajectory.target.x - this._trajectory.origin.x;
         var _loc5_:Number = this._trajectory.target.y - this._trajectory.origin.y;
         var _loc6_:Number = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
         _loc4_ /= _loc6_;
         _loc5_ /= _loc6_;
         this._trajectory.target.z += (this._model.boundBox.maxZ - this._model.boundBox.minZ) * 0.5;
         var _loc7_:Boolean = false;
         if(!this._trajectory.obstructed && _loc6_ < ThrowTrajectoryData.ROLL_DISTANCE_THRESHOLD)
         {
            _loc7_ = true;
            this._travelTime = _loc6_ * 2;
            this._trajectory.origin.x += _loc4_ * 100;
            this._trajectory.origin.y += _loc5_ * 100;
            this._trajectory.origin.z = this._trajectory.target.z;
            this._bezierControl = new Vector3D(this._trajectory.origin.x + _loc4_ * _loc6_ * 0.5,this._trajectory.origin.y + _loc5_ * _loc6_ * 0.5,this._trajectory.target.z);
         }
         else
         {
            this._trajectory.target.x -= _loc4_ * _loc6_ * 0.05;
            this._trajectory.target.y -= _loc5_ * _loc6_ * 0.05;
            this._travelTime = _loc6_ * 0.6;
            this._bezierControl = new Vector3D(this._trajectory.origin.x + _loc4_ * _loc6_ * 0.5,this._trajectory.origin.y + _loc5_ * _loc6_ * 0.5,this._trajectory.origin.z + _loc6_ * 0.25);
         }
         this._velocity = new Vector3D(_loc4_ * this._travelTime * (_loc7_ ? 0.1 : 0.8),_loc5_ * this._travelTime * (_loc7_ ? 0.1 : 0.8),-this._bezierControl.z * (_loc7_ ? 0 : 0.25));
         transform.position.copyFrom(this._trajectory.origin);
         transform.lookAt(this._trajectory.target,Vector3D.X_AXIS);
         transform.rotation.appendRotation(90,Vector3D.Z_AXIS);
         addedToScene.addOnce(this.onAddedToScene);
         removedFromScene.addOnce(this.onRemovedFromScene);
      }
      
      override public function dispose() : void
      {
         addedToScene.remove(this.onAddedToScene);
         removedFromScene.remove(this.onRemovedFromScene);
         super.dispose();
         this._soundSource.dispose();
         this._owner = null;
         this._item = null;
         this._trajectory = null;
      }
      
      override public function update(param1:Number = 1) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:* = false;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(this._exploded)
         {
            return;
         }
         var _loc2_:Number = getTimer();
         var _loc3_:Number = _loc2_ - this._spawnTime;
         if(_loc3_ >= this._detonationTime)
         {
            this.explode();
         }
         else
         {
            _loc4_ = _loc3_ / this._travelTime;
            if(_loc4_ > 1)
            {
               _loc4_ = 1;
            }
            _loc5_ = this._bezierControl.z == this._trajectory.target.z;
            if(_loc5_)
            {
               _loc4_ = Quad.easeOut(_loc4_,0,1,1);
            }
            if(_loc4_ >= 1)
            {
               if(this._velocity.x != 0 || this._velocity.y != 0)
               {
                  if(_loc5_)
                  {
                     this._velocity.z = 0;
                  }
                  _loc6_ = transform.position.x + this._velocity.x * param1;
                  _loc7_ = transform.position.y + this._velocity.y * param1;
                  _loc8_ = transform.position.z + this._velocity.z * param1;
                  if(_loc8_ <= this._trajectory.target.z)
                  {
                     _loc8_ = this._trajectory.target.z;
                     this._velocity.x *= 0.8;
                     this._velocity.y *= 0.8;
                     if(!_loc5_)
                     {
                        this._velocity.x += Random.float(-1,1) * (this._velocity.x * 0.1);
                        this._velocity.y += Random.float(-1,1) * (this._velocity.y * 0.1);
                        this._velocity.z *= -0.2;
                        if(this._velocity.z < 4)
                        {
                           this._velocity.z = 0;
                        }
                        if(this._velocity.z > 0)
                        {
                           transform.rotateAround(Vector3D.X_AXIS,0.5);
                           transform.rotateAround(Vector3D.Z_AXIS,0.5);
                           this._soundSource.play(this._item.getSound("land"),{"startTime":20});
                        }
                     }
                  }
                  else
                  {
                     this._velocity.z -= 9.8;
                  }
                  if(!scene.map.isPassable(_loc6_,_loc7_))
                  {
                     this._velocity.x *= -0.25;
                     this._velocity.y *= -0.25;
                     _loc6_ -= this._velocity.x * param1;
                     _loc7_ -= this._velocity.y * param1;
                  }
                  else
                  {
                     this._velocity.x *= 0.95;
                     this._velocity.y *= 0.95;
                  }
                  transform.position.setTo(_loc6_,_loc7_,_loc8_);
                  if(!_loc5_)
                  {
                     transform.rotateAround(Vector3D.X_AXIS,-Math.min(this._velocity.x * 0.001,0.1));
                     transform.rotateAround(Vector3D.Z_AXIS,Math.min(this._velocity.y * 0.001,0.1));
                  }
                  updateTransform(param1);
               }
            }
            else
            {
               _loc6_ = this._trajectory.origin.x + (this._trajectory.target.x - this._trajectory.origin.x) * _loc4_;
               _loc7_ = this._trajectory.origin.y + (this._trajectory.target.y - this._trajectory.origin.y) * _loc4_;
               _loc8_ = (1 - _loc4_) * (1 - _loc4_) * this._trajectory.origin.z + 2 * (1 - _loc4_) * _loc4_ * this._bezierControl.z + _loc4_ * _loc4_ * this._trajectory.target.z;
               transform.position.setTo(_loc6_,_loc7_,_loc8_);
               if(_loc5_)
               {
                  transform.rotation.prependRotation(2,Vector3D.X_AXIS);
               }
               else
               {
                  transform.rotateAround(Vector3D.X_AXIS,0.5);
                  transform.rotateAround(Vector3D.Z_AXIS,0.5);
               }
               updateTransform(param1);
            }
         }
      }
      
      private function explode() : void
      {
         var _loc1_:Vector3D = null;
         var _loc2_:Explosion = null;
         var _loc3_:SmokeExplosion = null;
         this._exploded = true;
         _loc1_ = transform.position;
         switch(this._item.xml.gear.exp.toString())
         {
            case ExplosionType.FRAG:
               _loc2_ = new Explosion(this._owner,_loc1_.x,_loc1_.y,_loc1_.z,this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dmg"),this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dmg_bld"),this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"rng") * 100,this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"vrng") * 100,this._owner.blackboard.allAgents,this._item.getSound("explode"));
               _loc2_.ownerItem = this._item;
               scene.addEntity(_loc2_);
               break;
            case ExplosionType.SMOKE:
               _loc3_ = new SmokeExplosion(_loc1_.x,_loc1_.y,_loc1_.z,this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"rng"),this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dur"));
               scene.addEntity(_loc3_);
         }
         this.dispose();
      }
      
      private function onAddedToScene(param1:GrenadeEntity) : void
      {
         this._spawnTime = getTimer();
         scene.addEntity(this._soundSource);
      }
      
      private function onRemovedFromScene(param1:GrenadeEntity) : void
      {
         scene.removeEntity(this._soundSource);
      }
   }
}

