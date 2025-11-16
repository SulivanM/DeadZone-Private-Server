package thelaststand.app.game.entities.effects
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import flash.geom.Vector3D;
   import thelaststand.app.game.data.DamageType;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.engine.audio.SoundSource3D;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class DirectionalExplosion extends GameEntity
   {
      
      private static var _id:int = 0;
      
      private var _owner:AIAgent;
      
      private var _size:Number;
      
      private var _damage:Number;
      
      private var _direction:Vector3D;
      
      private var _arcCosine:Number;
      
      private var _agentList:Vector.<AIActorAgent>;
      
      private var _soundSource:SoundSource3D;
      
      private var _explosion:ExplosionEffect;
      
      private var _sound:String;
      
      public function DirectionalExplosion(param1:AIAgent, param2:Number, param3:Number, param4:Number, param5:Vector3D, param6:Number, param7:Number, param8:Number, param9:Vector.<AIActorAgent>, param10:String)
      {
         super();
         name = "_dirExplosion" + _id++;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._owner = param1;
         this._size = param8;
         this._damage = param7;
         this._arcCosine = param6;
         this._direction = param5;
         this._direction.normalize();
         this._agentList = param9;
         this._sound = param10;
         this._soundSource = new SoundSource3D(transform.position,name + "-sound");
         this._explosion = new ExplosionEffect(Math.atan2(param5.y,param5.x),param6);
         this._explosion.scaleX = this._explosion.scaleY = this._explosion.scaleZ = this._size / 100 / 5;
         asset = new Object3D();
         asset.addChild(this._explosion);
         transform.position.x = param2;
         transform.position.y = param3;
         transform.position.z = 5;
         updateTransform();
         addedToScene.add(this.onAddedToScene);
      }
      
      override public function dispose() : void
      {
         this._explosion.dispose();
         this._soundSource.dispose();
         this._soundSource = null;
         super.dispose();
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         var _loc2_:Resource = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:AIActorAgent = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(this._agentList != null)
         {
            _loc3_ = this._size * this._size;
            _loc4_ = int(this._agentList.length - 1);
            while(_loc4_ >= 0)
            {
               _loc5_ = this._agentList[_loc4_];
               if(_loc5_.health > 0)
               {
                  _loc6_ = _loc5_.actor.transform.position.x - transform.position.x;
                  _loc7_ = _loc5_.actor.transform.position.y - transform.position.y;
                  _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
                  if(_loc8_ < _loc3_)
                  {
                     _loc8_ = 1 / Math.sqrt(_loc8_);
                     _loc6_ *= _loc8_;
                     _loc7_ *= _loc8_;
                     _loc9_ = _loc6_ * this._direction.x + _loc7_ * this._direction.y;
                     if(!(_loc9_ <= 0 && this._arcCosine > _loc9_))
                     {
                        _loc10_ = 1 - _loc8_ / this._size;
                        _loc11_ = this._damage * _loc10_;
                        _loc5_.agentData.target = null;
                        _loc5_.knockdown(new Vector3D(_loc6_,_loc7_),this._damage * 250 * _loc10_);
                        _loc11_ = _loc5_.receiveDamage(_loc11_,DamageType.EXPLOSIVE,this._owner);
                     }
                  }
               }
               _loc4_--;
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

