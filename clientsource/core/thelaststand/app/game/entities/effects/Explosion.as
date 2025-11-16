package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import flash.geom.Vector3D;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.DamageType;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.entities.LOSFlags;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.engine.audio.SoundSource3D;
   import thelaststand.engine.logic.LineOfSight;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class Explosion extends GameEntity
   {
      
      private static var _id:int = 0;
      
      private var _owner:AIAgent;
      
      private var _rangexy:Number;
      
      private var _rangez:Number;
      
      private var _damage:Number;
      
      private var _damageVsBuildingMult:Number;
      
      private var _agentList:*;
      
      private var _soundSource:SoundSource3D;
      
      private var _sound:String;
      
      private var _los:LineOfSight;
      
      private var _losOrigin:Vector3D;
      
      private var _losTarget:Vector3D;
      
      private var _tmpVector:Vector3D;
      
      private var _explosion:ExplosionEffect;
      
      public var ownerItem:Item;
      
      public function Explosion(param1:AIAgent, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:*, param10:String)
      {
         var _loc11_:int = 0;
         this._losOrigin = new Vector3D();
         this._losTarget = new Vector3D();
         this._tmpVector = new Vector3D();
         super();
         name = "_explosion" + _id++;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._owner = param1;
         this._damage = param5;
         this._damageVsBuildingMult = param6;
         this._rangexy = param7;
         this._rangez = param8;
         this._agentList = param9;
         this._los = new LineOfSight();
         this._soundSource = new SoundSource3D(transform.position,name + "-sound");
         this._sound = param10;
         this._explosion = new ExplosionEffect();
         this._explosion.scaleX = this._explosion.scaleY = this._explosion.scaleZ = this._rangexy / 100 / 5;
         asset = new Object3D();
         asset.mouseChildren = asset.mouseEnabled = false;
         asset.addChild(this._explosion);
         transform.position.x = param2;
         transform.position.y = param3;
         transform.position.z = param4 + 5;
         updateTransform();
         addedToScene.add(this.onAddedToScene);
      }
      
      public function get owner() : AIAgent
      {
         return this._owner;
      }
      
      override public function dispose() : void
      {
         this._explosion.dispose();
         this._soundSource.dispose();
         this._soundSource = null;
         this.ownerItem = null;
         super.dispose();
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         var _loc2_:Resource = null;
         var _loc3_:Number = NaN;
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc6_:AIAgent = null;
         var _loc7_:* = false;
         var _loc8_:Number = NaN;
         var _loc9_:Vector3D = null;
         var _loc10_:* = false;
         var _loc11_:Building = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Object3D = null;
         if(this._agentList != null)
         {
            _loc3_ = this._rangexy * this._rangexy;
            _loc4_ = this._agentList.concat();
            _loc5_ = _loc4_.length - 1;
            for(; _loc5_ >= 0; _loc5_--)
            {
               _loc6_ = _loc4_[_loc5_];
               if(!(_loc6_ == null || _loc6_.isDisposed || _loc6_.health <= 0))
               {
                  _loc7_ = false;
                  _loc9_ = _loc6_.entity.transform.position;
                  _loc10_ = _loc6_ is Building;
                  if(_loc10_)
                  {
                     _loc11_ = Building(_loc6_);
                     this._tmpVector.x = _loc9_.x - transform.position.x;
                     this._tmpVector.y = _loc9_.y - transform.position.y;
                     this._tmpVector.z = _loc9_.z - transform.position.z;
                     _loc8_ = this._los.sqDistPointAABB(this._tmpVector,_loc6_.entity.asset.boundBox);
                     _loc7_ = _loc8_ < _loc3_;
                  }
                  else
                  {
                     _loc12_ = _loc9_.x - transform.position.x;
                     _loc13_ = _loc9_.y - transform.position.y;
                     _loc8_ = _loc12_ * _loc12_ + _loc13_ * _loc13_;
                     if(_loc8_ < _loc3_)
                     {
                        if(_loc9_.z - transform.position.z <= this._rangez)
                        {
                           _loc7_ = true;
                        }
                     }
                  }
                  if(_loc7_)
                  {
                     if(_loc11_ == null || _loc11_.type != "door")
                     {
                        this._losOrigin.copyFrom(transform.position);
                        this._losTarget.copyFrom(_loc9_);
                        this._losTarget.z += _loc6_.entity.getHeight();
                        _loc16_ = this._los.rayCastHit(scene,scene.container.localToGlobal(this._losOrigin,this._losOrigin),scene.container.localToGlobal(this._losTarget,this._losTarget),LOSFlags.ALL ^ LOSFlags.SMOKE);
                        if(_loc16_ != null && (!_loc10_ || _loc16_ != _loc6_.entity.asset))
                        {
                           continue;
                        }
                     }
                     _loc14_ = 1 - _loc8_ / _loc3_;
                     _loc15_ = this._damage * _loc14_;
                     if(_loc10_)
                     {
                        _loc15_ *= this._damageVsBuildingMult;
                     }
                     else if(_loc6_ is AIActorAgent)
                     {
                        _loc6_.agentData.target = null;
                        AIActorAgent(_loc6_).knockdown(new Vector3D(_loc12_,_loc13_),this._damage * 250 * _loc14_);
                     }
                     _loc15_ = _loc6_.receiveDamage(_loc15_,DamageType.EXPLOSIVE,this);
                  }
               }
            }
         }
         scene.addEntity(this._soundSource);
         for each(_loc2_ in this._explosion.resources)
         {
            scene.resourceUploadList.push(_loc2_);
         }
         this._soundSource.play(this._sound,{
            "minDistance":5000,
            "maxDistance":20000
         });
         this._explosion.play();
         scene.camera.shake(10);
      }
   }
}

