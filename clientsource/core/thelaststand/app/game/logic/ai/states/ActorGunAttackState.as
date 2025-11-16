package thelaststand.app.game.logic.ai.states
{
   import alternativa.engine3d.core.Object3D;
   import com.deadreckoned.threshold.math.Random;
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.DamageType;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.data.WeaponFlags;
   import thelaststand.app.game.data.WeaponType;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.entities.effects.BloodSplatDecal;
   import thelaststand.app.game.entities.effects.BloodSpray;
   import thelaststand.app.game.entities.effects.BulletTracer;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.ThreatData;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.engine.geom.LineSegment;
   
   public class ActorGunAttackState implements IAIState
   {
      
      private static var _fireSoundOptions:Object = {"maxDistance":4000};
      
      public static var GunTrackingData:Dictionary = new Dictionary();
      
      public static var fireRateReported:Boolean = false;
      
      private var _agent:AIActorAgent;
      
      private var _target:AIAgent;
      
      private var _targetPt:Vector3D;
      
      private var _targetForward:Vector3D;
      
      private var _animName:String;
      
      private var _ready:Boolean = false;
      
      private var _readyTime:Number;
      
      private var _readyTimeStart:Number;
      
      private var _threatTime:Number;
      
      private var _lastThreatTime:Number;
      
      private var _attackingBuilding:Boolean;
      
      private var _tmpVec1:Vector3D;
      
      private var _tmpVec2:Vector3D;
      
      private var _knockedBack:Boolean;
      
      private var _coverFireCount:uint;
      
      private var _coverFireMax:uint;
      
      private var _coverWaitTime:Number;
      
      private var _coverRay:LineSegment;
      
      private var _threat:ThreatData;
      
      private var _fireSoundOverrides:Array = null;
      
      private var _isTeamActor:Boolean;
      
      public function ActorGunAttackState(param1:AIActorAgent, param2:AIAgent)
      {
         super();
         this._agent = param1;
         this._target = param2;
         this._targetForward = new Vector3D();
         this._coverRay = new LineSegment();
         this._tmpVec1 = new Vector3D();
         this._tmpVec2 = new Vector3D();
         this._isTeamActor = this._agent.team == AIAgent.TEAM_PLAYER;
      }
      
      public function dispose() : void
      {
         this._target = null;
         if(this._agent != null)
         {
            if(this._agent.actor != null && this._agent.actor.animatedAsset != null)
            {
               this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
               this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
            }
            this._agent = null;
         }
         if(this._threat != null)
         {
            this._threat.returnToPool();
            this._threat = null;
         }
      }
      
      public function enter(param1:Number) : void
      {
         this._agent.navigator.stop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.agentData.attacking = true;
         this._agent.agentData.guardPoint.copyFrom(this._agent.navigator.position);
         this._lastThreatTime = param1;
         this._coverFireCount = 0;
         this._coverFireMax = Math.max(1,6 - this._agent.weaponData.fireRate / 1000 * 2);
         this._targetPt = this._agent.getTargetPosition();
         this._readyTime = this._agent.weaponData.readyTime;
         if(this._agent.agentData.coverRating == 0 && this._agent.agentData.suppressionRating > 0 && this._readyTime < 1)
         {
            this._readyTime = 1;
         }
         this._ready = false;
         this._readyTime *= 1000;
         this._readyTimeStart = 0;
         this._threatTime = 0;
         if(this._agent.agentData.waitInCover && this._agent.agentData.coverRating > 0 && this._agent.idleTime < 1)
         {
            this.startCoverWait(0.5);
         }
         if(Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPewPew")) > 0)
         {
            this._fireSoundOverrides = ["sound/weapons/pew-1.mp3","sound/weapons/pew-2.mp3","sound/weapons/pew-3.mp3","sound/weapons/pew-4.mp3","sound/weapons/pew-5.mp3"];
         }
         this._agent.actor.animatedAsset.animationCompleted.add(this.onAnimationComplete);
         this._agent.actor.animatedAsset.animationNotified.add(this.onAnimationNotify);
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.agentData.attacking = false;
         this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         this._agent.navigator.resume();
         if(this._threat != null)
         {
            this._threat.returnToPool();
            this._threat = null;
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc21_:String = null;
         var _loc26_:CoverEntity = null;
         var _loc35_:Number = NaN;
         var _loc36_:AIActorAgent = null;
         var _loc37_:Vector3D = null;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:Object3D = null;
         var _loc43_:Vector3D = null;
         var _loc44_:Vector3D = null;
         var _loc45_:* = false;
         var _loc46_:Number = NaN;
         var _loc47_:Number = NaN;
         var _loc48_:Number = NaN;
         var _loc49_:Number = NaN;
         var _loc50_:uint = 0;
         var _loc51_:Boolean = false;
         var _loc52_:Vector3D = null;
         var _loc53_:Vector3D = null;
         var _loc54_:Number = NaN;
         var _loc55_:* = false;
         var _loc56_:BulletTracer = null;
         var _loc57_:BloodSpray = null;
         var _loc58_:Number = NaN;
         var _loc59_:Number = NaN;
         var _loc60_:BloodSplatDecal = null;
         if(this._target == null || this._target.health <= 0)
         {
            if(!this._agent.autoTarget || !this.getNextTarget())
            {
               this._agent.agentData.target = null;
               this._agent.agentData.targetNoise = null;
               this._agent.agentData.helpingFriend = false;
               this._agent.agentData.clearForcedTarget();
               this._agent.navigator.cancelAndStop();
               this.endAttack();
               return;
            }
         }
         if(this._coverWaitTime > 0)
         {
            this._coverWaitTime -= param1;
            return;
         }
         if(!this._agent.canAttack())
         {
            return;
         }
         if(this._ready && (this._agent.team != AIAgent.TEAM_PLAYER || this._agent.agentData.forcedTarget == null))
         {
            this._threatTime += param2 - this._lastThreatTime;
            if(this._threatTime >= 500)
            {
               if(!this.getNextTarget())
               {
                  return;
               }
               this._threatTime = 0;
            }
            this._lastThreatTime = param2;
         }
         this._attackingBuilding = this._target is Building;
         if(!this._attackingBuilding && !this._agent.canSeeAgent(this._target as AIActorAgent))
         {
            this.endAttack();
            return;
         }
         var _loc3_:Number = 1;
         var _loc4_:Number = 1;
         var _loc5_:Number = this._agent.getDistanceToTargetSq();
         var _loc6_:Number = this._agent.weaponData.minEffectiveRange;
         var _loc7_:Number = this._agent.weaponData.minRange;
         var _loc8_:Number = this._agent.weaponData.range;
         var _loc9_:Vector3D = this._agent.actor.transform.position;
         var _loc10_:Number = 1;
         var _loc11_:* = _loc5_ > this._agent.weaponData.range * this._agent.weaponData.range * 1.02;
         if(_loc5_ < _loc7_ * _loc7_)
         {
            this.endAttack();
            return;
         }
         if(_loc5_ > _loc8_ * _loc8_)
         {
            if(this._agent.agentData.suppressionRating <= this._agent.agentData.suppressionPoints * Config.constant.SUPPRESSED_ATTACK_PERC && (this._agent.agentData.forcedTarget == null || this._threat != null && !this._threat.helpingFriend))
            {
               this.endAttack();
               return;
            }
            _loc10_ = _loc8_ / Math.sqrt(_loc5_);
            _loc3_ = _loc10_ * 0.2;
            _loc4_ = Math.min(_loc10_ * 1.5);
         }
         else if(_loc5_ < _loc6_ * _loc6_)
         {
            _loc3_ = Number(Config.constant.MIN_EFF_ACCURACY_MOD);
         }
         _loc12_ = this._targetPt.x - _loc9_.x;
         _loc13_ = this._targetPt.y - _loc9_.y;
         this._targetForward.x = _loc12_;
         this._targetForward.y = _loc13_;
         this._agent.actor.targetForward = this._targetForward;
         if(!this._ready)
         {
            if(this._readyTimeStart <= 0)
            {
               this.playReadyAnimation();
               this._readyTimeStart = param2;
            }
            if(param2 - this._readyTimeStart < this._readyTime)
            {
               return;
            }
            this._ready = true;
         }
         _loc5_ = 1 / Math.sqrt(_loc12_ * _loc12_ + _loc13_ * _loc13_);
         _loc12_ *= _loc5_;
         _loc13_ *= _loc5_;
         var _loc15_:Vector3D = this._agent.entity.transform.forward;
         var _loc16_:Number = _loc12_ * -_loc15_.x + _loc13_ * -_loc15_.y;
         if(_loc16_ <= 0 || this._agent.weaponData.attackArcCosine > _loc16_)
         {
            return;
         }
         if(!fireRateReported && param2 - this._agent.agentData.lastAttackTime < this._agent.weaponData.fireRate)
         {
            fireRateReported = true;
            Network.getInstance().save({
               "id":"frate",
               "lt":param2 - this._agent.agentData.lastAttackTime,
               "rate":this._agent.weaponData.fireRate
            },SaveDataMethod.AH_EVENT);
         }
         this._agent.agentData.lastAttackTime = param2;
         var _loc17_:Weapon = this._agent.weapon;
         var _loc18_:WeaponData = this._agent.weaponData;
         if(_loc17_.isBurstFire)
         {
            if(this._agent.agentData.burstShotCount == 0)
            {
               this._agent.agentData.burstShotMax = _loc17_.getBurstRate();
               this._agent.agentData.burstWaitTime = this._agent.agentData.lastBurstTime = 0;
            }
            if(++this._agent.agentData.burstShotCount >= this._agent.agentData.burstShotMax)
            {
               this._agent.agentData.burstShotCount = 0;
               this._agent.agentData.burstWaitTime = 250 + 250 * Math.random();
               this._agent.agentData.lastBurstTime = param2;
            }
         }
         else
         {
            this._agent.agentData.burstShotCount = 0;
         }
         var _loc19_:Boolean = Boolean(this._agent.weapon.flags & WeaponFlags.SUPPRESSED);
         var _loc20_:int = this._target.agentData.coverRating;
         this.playFiringAnimation();
         if(this._fireSoundOverrides != null)
         {
            _loc21_ = this._fireSoundOverrides[int(Math.random() * this._fireSoundOverrides.length)];
         }
         else
         {
            _loc21_ = this._agent.weapon.getSound(_loc19_ ? "suppressed_fire" : "fire");
         }
         this._agent.soundSource.play(_loc21_,_fireSoundOptions);
         if(this._agent.weaponData.noise > 0)
         {
            this._agent.generateNoise(this._agent.weaponData.noise);
         }
         var _loc22_:Number = this._agent.weaponData.suppressionRate * _loc4_;
         var _loc23_:Vector.<AIActorAgent> = null;
         if(this._attackingBuilding)
         {
            _loc23_ = this._agent.blackboard.enemies;
         }
         else if(this._target.agentData.canBeSuppressed)
         {
            this._target.applySuppression(_loc22_);
            _loc23_ = this._target.blackboard.friends;
         }
         if(_loc23_ != null)
         {
            _loc35_ = Config.constant.SUPPRESSION_RANGE_RADIUS * 100;
            for each(_loc36_ in _loc23_)
            {
               if(_loc36_ != this._target)
               {
                  _loc37_ = _loc36_.navigator.position;
                  _loc38_ = this._targetPt.x - _loc37_.x;
                  _loc39_ = this._targetPt.y - _loc37_.y;
                  _loc40_ = _loc38_ * _loc38_ + _loc39_ * _loc39_;
                  if(_loc40_ < _loc35_ * _loc35_)
                  {
                     _loc41_ = this._targetPt.z - _loc37_.z;
                     if(_loc41_ < 0)
                     {
                        _loc41_ = -_loc41_;
                     }
                     if(_loc41_ <= 100)
                     {
                        _loc36_.applySuppression(_loc22_);
                     }
                  }
               }
            }
         }
         var _loc24_:ActorGunAttackStateTrackingData = null;
         var _loc25_:Number = this._agent.weaponData.range * this._agent.weaponData.range;
         if(this._isTeamActor)
         {
            _loc24_ = GunTrackingData[this._agent];
            if(_loc24_ == null)
            {
               _loc24_ = new ActorGunAttackStateTrackingData();
               _loc24_.type = this._agent.weapon.type;
               GunTrackingData[this._agent] = _loc24_;
            }
            if(_loc11_ && !this._attackingBuilding)
            {
               ++_loc24_.longRangeShots;
            }
         }
         var _loc27_:Number = _loc18_.accuracy * _loc3_;
         if(_loc27_ > 0 && _loc27_ < 0.01)
         {
            _loc27_ = 0.01;
         }
         if(!this._attackingBuilding)
         {
            if(_loc27_ > 0 && _loc20_ > 0)
            {
               _loc27_ *= 1 - Math.min(1,_loc20_ / 100 * Config.constant.COVER_RATING_MULT);
               if(this._target.agentData.stance == AIAgentData.STANCE_CROUCH && this._target.agentData.coverEntities != null)
               {
                  _loc42_ = this._agent.blackboard.scene.container;
                  _loc43_ = _loc42_.localToGlobal(this._agent.navigator.position,this._tmpVec1);
                  _loc44_ = _loc42_.localToGlobal(this._target.entity.transform.position,this._tmpVec2);
                  _loc43_.z = _loc44_.z = 50;
                  for each(_loc26_ in this._target.agentData.coverEntities)
                  {
                     this._coverRay.start = _loc43_;
                     this._coverRay.end = _loc44_;
                     if(this._coverRay.intersectsObject3D(_loc26_.coverArea))
                     {
                        _loc27_ = 0;
                        break;
                     }
                  }
               }
            }
            if(_loc27_ > 0.95)
            {
               _loc27_ = 0.95;
            }
         }
         var _loc28_:Boolean = _loc27_ > 0 ? Math.random() < _loc27_ : false;
         if(_loc28_)
         {
            _loc45_ = false;
            _loc46_ = !this._attackingBuilding && this._agent.agentData.canCauseCriticals ? _loc18_.criticalChance : 0;
            if(_loc46_ > 0)
            {
               if(this._agent.agentData.canCauseBackCriticals)
               {
                  _loc52_ = this._agent.actor.transform.forward;
                  _loc53_ = this._target.entity.transform.forward;
                  _loc54_ = _loc52_.x * _loc53_.x + _loc52_.y * _loc53_.y;
                  _loc45_ = _loc54_ > 0 || Math.random() < _loc46_;
               }
               else
               {
                  _loc45_ = Math.random() < _loc46_;
               }
            }
            _loc47_ = _loc18_.damageMin;
            _loc48_ = _loc18_.damageMax;
            _loc49_ = (_loc47_ + (_loc48_ - _loc47_) * Math.random()) * _loc18_.damageMult * (_loc45_ ? 2 : 1);
            if(this._attackingBuilding)
            {
               _loc49_ *= Config.constant.PROJECTILE_BUILDING_MULT;
               _loc49_ = _loc49_ * this._agent.weaponData.damageMultVsBuilding;
            }
            _loc49_ *= _loc10_ * _loc10_;
            _loc50_ = _loc18_.isExplosive ? DamageType.EXPLOSIVE : DamageType.PROJECTILE;
            _loc49_ = this._target.receiveDamage(_loc49_,_loc50_,this._agent,_loc45_);
            _loc51_ = false;
            if(!this._attackingBuilding && this._target.health > 0)
            {
               if(!(this._target.stateMachine.state is ActorKnockbackState) && (_loc45_ || Math.random() < _loc18_.knockbackChance))
               {
                  _loc51_ = AIActorAgent(this._target).knockback(new Vector3D(this._targetPt.x - _loc9_.x,this._targetPt.y - _loc9_.y,0),_loc49_ / this._target.maxHealth * Config.constant.MAX_KNOCKBACK_FORCE,_loc17_.weaponClass == WeaponClass.SHOTGUN ? _loc49_ * 0.5 : 0,_loc50_,this._agent);
               }
               else if(this._target.health > this._target.maxHealth * 0.5)
               {
                  if(Math.random() < _loc18_.knockbackChance * 2)
                  {
                     AIActorAgent(this._target).hurt(param2);
                  }
               }
            }
            if(_loc45_)
            {
               this._target.soundSource.play("sound/impacts/critical-hit1.mp3",{
                  "minDistance":4000,
                  "maxDistance":10000
               });
            }
            else if(this._attackingBuilding)
            {
               this._target.soundSource.play(this._agent.weapon.getSound("buildingHit"));
            }
            else if(Math.random() < 0.75)
            {
               this._target.soundSource.play("sound/impacts/body-hit1.mp3");
            }
            if(this._target.health <= 0)
            {
               this._agent.killedEnemy.dispatch(this._agent,this._target);
            }
            if(_loc24_ != null && !this._attackingBuilding)
            {
               if(_loc11_)
               {
                  ++_loc24_.longRangeHits;
               }
            }
         }
         else if(Math.random() < 0.25)
         {
            this._target.soundSource.play(this._agent.weapon.getSound("ricochet"));
         }
         --this._agent.weaponData.roundsInMagazine;
         if(!_loc19_ && Math.random() < 0.8 && this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).showMuzzleflash();
         }
         var _loc29_:Number = _loc9_.x;
         var _loc30_:Number = _loc9_.y;
         var _loc31_:Number = _loc9_.z + this._agent.actor.getHeight();
         var _loc32_:Number = this._targetPt.x;
         var _loc33_:Number = this._targetPt.y;
         var _loc34_:Number = this._targetPt.z + this._target.entity.getHeight() * (0.75 + Math.random() * 0.1);
         if(!Global.lowFPS && Settings.getInstance().bulletTracers && (_loc19_ || !_loc28_ && _loc27_ > 0 || Math.random() < 0.75))
         {
            _loc55_ = false;
            _loc12_ = _loc32_ - _loc29_;
            _loc13_ = _loc33_ - _loc30_;
            _loc5_ = _loc12_ * _loc12_ + _loc13_ * _loc13_;
            if(!_loc28_)
            {
               _loc5_ = Math.sqrt(_loc5_);
               _loc32_ += _loc12_ / _loc5_ * 800 + (Math.random() * 2 - 1) * 50;
               _loc33_ += _loc13_ / _loc5_ * 800 + (Math.random() * 2 - 1) * 50;
               _loc55_ = true;
            }
            else
            {
               _loc55_ = _loc5_ >= 200 * 200;
            }
            if(_loc55_)
            {
               _loc56_ = BulletTracer.pool.get() as BulletTracer;
               if(_loc56_ != null)
               {
                  _loc56_.init(_loc29_,_loc30_,_loc31_,_loc32_,_loc33_,_loc34_);
                  this._agent.actor.scene.addEntity(_loc56_);
               }
            }
         }
         if(_loc28_)
         {
            _loc12_ = _loc32_ - _loc29_;
            _loc13_ = _loc33_ - _loc30_;
            _loc14_ = _loc34_ - _loc31_;
            if(!this._attackingBuilding)
            {
               if(Settings.getInstance().gore)
               {
                  _loc57_ = BloodSpray.pool.get() as BloodSpray;
                  if(_loc57_ != null)
                  {
                     _loc57_.init(_loc32_,_loc33_,_loc34_,new Vector3D(_loc12_,_loc13_,_loc14_),(_loc45_ ? 0.65 : 0.5) * _loc18_.goreMultiplier,8);
                     this._agent.actor.scene.addEntity(_loc57_);
                  }
                  if(_loc45_ || Math.random() < 0.5)
                  {
                     _loc58_ = Math.atan2(_loc13_,_loc12_) - Math.PI * 0.5 + Random.float(-Math.PI * 0.25,Math.PI * 0.25);
                     _loc59_ = Random.float(150,250) * _loc18_.goreMultiplier;
                     _loc60_ = new BloodSplatDecal(_loc32_,_loc33_,5,_loc59_,_loc58_);
                     this._agent.actor.scene.addEntity(_loc60_);
                  }
               }
            }
         }
         if(_loc51_ && this._agent.agentData.forcedTarget != null)
         {
            _loc51_ = false;
            this._agent.agentData.target = null;
            this.endAttack();
         }
         if(this._agent.agentData.coverRating > 0 && !this._attackingBuilding)
         {
            if(++this._coverFireCount >= this._coverFireMax && this._agent.agentData.burstShotCount == 0)
            {
               this.startCoverWait();
            }
         }
      }
      
      private function getNextTarget() : Boolean
      {
         if(this._threat != null)
         {
            this._threat.returnToPool();
         }
         this._threat = this._agent.evalThreats(this._agent.blackboard.enemies);
         if(this._threat == null || this._threat.agent == null || !this._agent.canSeeAgent(this._threat.agent))
         {
            return false;
         }
         if(this._agent.team != AIAgent.TEAM_PLAYER)
         {
            this._agent.agentData.helpingFriend = false;
            this._agent.agentData.clearForcedTarget();
         }
         if(this._threat.agent != this._agent.agentData.target)
         {
            this._target = this._agent.agentData.target = this._threat.agent;
            this._targetPt = this._agent.getTargetPosition();
            this._agent.agentData.helpingFriend = this._threat.helpingFriend;
            if(this._agent.agentData.helpingFriend)
            {
               this._agent.agentData.forceTarget(this._target);
            }
            this._ready = false;
            this._readyTimeStart = 0;
         }
         return true;
      }
      
      private function startCoverWait(param1:Number = 1) : void
      {
         if(!this._agent.agentData.waitInCover)
         {
            this._coverWaitTime = 0;
            this._coverFireCount = 0;
            return;
         }
         this._coverWaitTime = (Config.constant.COVER_FIRE_WAIT_TIME * 0.5 + Math.random() * Config.constant.COVER_FIRE_WAIT_TIME) * param1;
         this._coverFireCount = 0;
         this._agent.agentData.stance = AIAgentData.STANCE_CROUCH;
         this._agent.actor.animatedAsset.gotoAndPlay(this._agent.getAnimation("idle"),0,true,0.05,0.1);
      }
      
      private function endAttack() : void
      {
         if(this._agent == null)
         {
            return;
         }
         this._agent.navigator.cancelAndStop();
         this._agent.stateMachine.setState(null);
      }
      
      private function playReadyAnimation() : void
      {
         this._agent.agentData.stance = AIAgentData.STANCE_STAND;
         var _loc1_:String = this._agent.weapon.animType + "-threat-" + this._agent.agentData.stance;
         this._agent.actor.animatedAsset.gotoAndPlay(_loc1_,0,false,0.25);
      }
      
      private function playFiringAnimation() : void
      {
         this._agent.agentData.stance = AIAgentData.STANCE_STAND;
         this._animName = this._agent.weapon.animType + "-fire-" + this._agent.agentData.stance;
         var _loc1_:Number = 0;
         if(this._agent.weapon.weaponType & WeaponType.AUTO)
         {
            _loc1_ = Math.random() * this._agent.actor.animatedAsset.getAnimationLength(this._animName);
         }
         var _loc2_:Number = this._agent.actor.animatedAsset.currentAnimation != this._animName ? 0.1 : 0;
         this._agent.actor.animatedAsset.gotoAndPlay(this._animName,_loc1_,false,1,_loc2_);
      }
      
      private function onAnimationNotify(param1:String, param2:String) : void
      {
         if(param1 != this._animName)
         {
            return;
         }
         if(param2 == "action")
         {
            this._agent.soundSource.play(this._agent.weapon.getSound("action"));
         }
      }
      
      private function onAnimationComplete(param1:String) : void
      {
         if(param1 != this._animName)
         {
            return;
         }
         if(this._agent.agentData.stance != AIAgentData.STANCE_CROUCH)
         {
            this._agent.actor.animatedAsset.play(this._agent.weapon.animType + "-threat-" + this._agent.agentData.stance,true,0.25);
         }
      }
   }
}

