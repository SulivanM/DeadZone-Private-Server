package thelaststand.app.game.logic.ai.states
{
   import alternativa.engine3d.core.Object3D;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.DamageType;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.LOSFlags;
   import thelaststand.app.game.entities.buildings.ITrapEntity;
   import thelaststand.app.game.entities.effects.BulletTracer;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.engine.geom.LineSegment;
   
   public class TrapGunBarrelState implements IAITrapState
   {
      
      private var _onTriggered:Signal = new Signal(Building);
      
      private var _agent:Building;
      
      private var _worldCenter:Vector3D;
      
      private var _detectionRadius:Number;
      
      private var _triggered:Boolean = false;
      
      private var _triggeredTime:Number = 0;
      
      private var _triggerTime:Number = 0;
      
      private var _lastFireTime:Number;
      
      private var _coverRay:LineSegment;
      
      private var _healthDmgPerShot:Number;
      
      private var _fireRate:Number;
      
      private var _damage:Number;
      
      private var _range:Number;
      
      private var _supRate:Number;
      
      private var _accuracy:Number;
      
      private var _knockbackChance:Number;
      
      private var _currentTime:Number = 0;
      
      private var _tmpVec1:Vector3D = new Vector3D();
      
      private var _tmpVec2:Vector3D = new Vector3D();
      
      private var _tmpVec3:Vector3D = new Vector3D();
      
      private var _tmpVec4:Vector3D = new Vector3D();
      
      public function TrapGunBarrelState(param1:Building)
      {
         super();
         this._agent = param1;
         this._worldCenter = new Vector3D();
         this._coverRay = new LineSegment();
         this._triggerTime = Number(this._agent.getLevelXML().trig_time.toString());
         this._fireRate = Number(this._agent.getLevelXML().rate.toString()) * 1000;
         this._damage = Number(this._agent.getLevelXML().dmg.toString()) / 100;
         this._range = Number(this._agent.getLevelXML().rng.toString()) * 100;
         this._supRate = Number(this._agent.getLevelXML().sup.toString());
         this._accuracy = Number(this._agent.getLevelXML().acc.toString());
         this._knockbackChance = Number(this._agent.getLevelXML().knock.toString());
         this._healthDmgPerShot = Number(this._agent.xml.healthDmgPerShot.toString());
      }
      
      public function get triggered() : Signal
      {
         return this._onTriggered;
      }
      
      public function dispose() : void
      {
         this._agent = null;
         this._onTriggered.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         this._currentTime = param1;
         this._worldCenter.x = this._agent.buildingEntity.transform.position.x + this._agent.buildingEntity.centerPoint.x;
         this._worldCenter.y = this._agent.buildingEntity.transform.position.y + this._agent.buildingEntity.centerPoint.y;
         this._detectionRadius = this._agent.buildingEntity.scene.map.cellSize * Number(this._agent.getLevelXML().detect_rng.toString());
      }
      
      public function exit(param1:Number) : void
      {
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:BulletTracer = null;
         var _loc11_:AIActorAgent = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         this._currentTime = param2;
         if(this._agent.health <= 0)
         {
            return;
         }
         if(this._triggered)
         {
            if(param2 - this._triggeredTime < this._triggerTime)
            {
               return;
            }
            if(param2 - this._lastFireTime < this._fireRate)
            {
               return;
            }
            this._lastFireTime = param2;
            _loc5_ = this._agent.health - this._healthDmgPerShot;
            if(_loc5_ <= 0)
            {
               ITrapEntity(this._agent.buildingEntity).deactivate();
            }
            this._agent.receiveDamage(this._healthDmgPerShot,DamageType.UNKNOWN);
            if(_loc5_ <= 0)
            {
               return;
            }
            if(!Global.lowFPS && Settings.getInstance().bulletTracers && Math.random() < 0.25)
            {
               _loc7_ = this._worldCenter.x + Math.cos(Math.PI * 2 * Math.random()) * this._range;
               _loc8_ = this._worldCenter.y + Math.sin(Math.PI * 2 * Math.random()) * this._range;
               _loc9_ = this._worldCenter.z + this._agent.buildingEntity.getHeight();
               _loc10_ = BulletTracer.pool.get() as BulletTracer;
               if(_loc10_ != null)
               {
                  _loc10_.init(this._worldCenter.x,this._worldCenter.y,_loc9_,_loc7_,_loc8_,_loc9_);
                  this._agent.blackboard.scene.addEntity(_loc10_);
               }
               this._agent.soundSource.play("sound/impacts/ricochet-" + (1 + int(Math.random() * 4)) + ".mp3");
            }
            _loc6_ = this._agent.getSound("fire");
            this._agent.soundSource.play(_loc6_,{
               "minDistance":2000,
               "maxDistance":10000
            });
         }
         var _loc3_:Vector.<AIActorAgent> = this._agent.blackboard.enemies;
         var _loc4_:int = int(_loc3_.length - 1);
         for(; _loc4_ >= 0; _loc4_--)
         {
            _loc11_ = _loc3_[_loc4_];
            if(_loc11_.health > 0)
            {
               _loc12_ = _loc11_.actor.transform.position.x - this._worldCenter.x;
               _loc13_ = _loc11_.actor.transform.position.y - this._worldCenter.y;
               _loc14_ = _loc12_ * _loc12_ + _loc13_ * _loc13_;
               if(this._triggered)
               {
                  if(_loc14_ < this._range * this._range)
                  {
                     this.fireShot(_loc11_);
                  }
               }
               else
               {
                  if(this._agent.flags & EntityFlags.TRAP_DETECTED)
                  {
                     if(_loc11_ is Survivor && Survivor(_loc11_).canDisarmTraps && Boolean(_loc11_.flags & EntityFlags.DISARMING_TRAP))
                     {
                        continue;
                     }
                  }
                  if(_loc14_ < this._detectionRadius * this._detectionRadius)
                  {
                     this.trigger();
                     return;
                  }
               }
            }
         }
      }
      
      private function fireShot(param1:AIActorAgent) : void
      {
         var _loc4_:CoverEntity = null;
         var _loc7_:Object3D = null;
         var _loc8_:Vector3D = null;
         var _loc9_:Vector3D = null;
         var _loc10_:Boolean = false;
         var _loc11_:Number = NaN;
         var _loc2_:Vector3D = param1.actor.transform.position;
         this._tmpVec1.copyFrom(this._agent.entity.transform.position);
         this._tmpVec1.z += this._agent.entity.getHeight();
         this._tmpVec2.copyFrom(_loc2_);
         this._tmpVec2.z += param1.entity.getHeight() + 80;
         if(!param1.navigator.lineOfSight.isPointVisible(this._agent.entity.scene,this._agent.entity.scene.container.localToGlobal(this._tmpVec1,this._tmpVec3),this._agent.entity.scene.container.localToGlobal(this._tmpVec2,this._tmpVec4),LOSFlags.ALL ^ LOSFlags.SMOKE))
         {
            return;
         }
         var _loc3_:int = param1.agentData.coverRating;
         if(_loc3_ > 0)
         {
            param1.agentData.suppressionRating += this._supRate * (1 - Math.min(1,_loc3_ / 100 * Config.constant.COVER_RATING_MULT));
         }
         var _loc5_:Number = this._accuracy;
         if(_loc5_ > 0)
         {
            if(_loc3_ > 0)
            {
               _loc5_ *= 1 - Math.min(1,_loc3_ / 100 * Config.constant.COVER_RATING_MULT);
               if(param1.agentData.stance == AIAgentData.STANCE_CROUCH && param1.agentData.coverEntities != null)
               {
                  _loc7_ = this._agent.blackboard.scene.container;
                  _loc8_ = _loc7_.localToGlobal(this._worldCenter,this._tmpVec1);
                  _loc9_ = _loc7_.localToGlobal(param1.entity.transform.position,this._tmpVec2);
                  _loc8_.z = _loc9_.z = 50;
                  for each(_loc4_ in param1.agentData.coverEntities)
                  {
                     this._coverRay.start = _loc8_;
                     this._coverRay.end = _loc9_;
                     if(this._coverRay.intersectsObject3D(_loc4_.coverArea))
                     {
                        _loc5_ = 0;
                        break;
                     }
                  }
               }
            }
         }
         if(_loc5_ > 0.95)
         {
            _loc5_ = 0.95;
         }
         _loc5_ *= 0.5;
         var _loc6_:Boolean = _loc5_ > 0 ? Math.random() < _loc5_ : false;
         if(_loc6_)
         {
            _loc10_ = false;
            _loc11_ = param1.health - this._damage;
            if(!(param1.stateMachine.state is ActorKnockbackState) && _loc11_ > 0 && Math.random() < this._knockbackChance)
            {
               _loc10_ = AIActorAgent(param1).knockback(new Vector3D(_loc2_.x - this._worldCenter.x,_loc2_.y - this._worldCenter.y,0),this._damage / param1.maxHealth * Config.constant.MAX_KNOCKBACK_FORCE);
            }
            param1.receiveDamage(this._damage,DamageType.PROJECTILE,this._agent);
            if(Math.random() < 0.25)
            {
               param1.soundSource.play("sound/impacts/body-hit1.mp3");
            }
         }
      }
      
      public function trigger() : void
      {
         this._triggered = true;
         this._triggeredTime = this._currentTime;
         this._agent.buildingEntity.asset.visible = true;
         this._agent.flags |= EntityFlags.TRAP_DETECTED | EntityFlags.TRAP_TRIGGERED;
         ITrapEntity(this._agent.buildingEntity).activate();
         this._onTriggered.dispatch(this._agent);
      }
   }
}

