package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.math.Random;
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.DamageType;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.entities.effects.BloodSplatDecal;
   import thelaststand.app.game.entities.effects.BloodSpray;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   
   public class ActorMeleeAttackState implements IAIState
   {
      
      private static var dodgeRecorded:Boolean = false;
      
      private var _agent:AIActorAgent;
      
      private var _target:AIAgent;
      
      private var _targetPt:Vector3D;
      
      private var _targetForward:Vector3D;
      
      private var _animName:String;
      
      private var _attackStartTime:Number = 0;
      
      private var _attackDuration:Number = 0;
      
      private var _windUpSpeed:Number = 0;
      
      private var _swingSpeed:Number = 0;
      
      private var _swingRange:Number = 0;
      
      private var _swingMinRange:Number = 0;
      
      private var _coverWaitTime:Number = 0;
      
      private var _coverWaitTimeStart:Number = 0;
      
      private var _attackingBuilding:Boolean;
      
      private var _hitChecked:Boolean = false;
      
      private var _time:Number;
      
      public function ActorMeleeAttackState(param1:AIActorAgent, param2:AIAgent)
      {
         super();
         this._agent = param1;
         this._target = param2;
         this._targetForward = new Vector3D();
         this._attackingBuilding = this._target is Building;
         this._targetPt = new Vector3D();
      }
      
      public function dispose() : void
      {
         if(this._agent != null && this._agent.actor != null && this._agent.actor.animatedAsset != null)
         {
            this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
            this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         }
         this._agent = null;
         this._target = null;
      }
      
      public function enter(param1:Number) : void
      {
         this._time = param1;
         this._agent.navigator.cancelAndStop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.agentData.attacking = true;
         this._agent.getTargetPosition(this._targetPt);
         this._swingRange = this._agent.weaponData.range;
         this._swingMinRange = this._agent.weaponData.minRange;
         if(this._agent.agentData.coverRating > 0)
         {
            this._swingRange = Math.max(this._swingRange,this._agent.entity.scene.map.cellSize * 1.4 * 3);
            if(this._agent.agentData.waitInCover && !this._attackingBuilding && this._agent.idleTime < 1)
            {
               this.startCoverWait();
            }
         }
         if(this._attackingBuilding)
         {
            this._swingRange *= 100;
         }
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         this._agent.actor.targetForward = null;
         this._agent.agentData.attacking = false;
         this._agent.agentData.meleeSwinging = false;
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._time = param2;
         if(this._agent.agentData.target == null || this._target == null || this._target.health <= 0)
         {
            this._agent.agentData.target = null;
            this._agent.agentData.targetNoise = null;
            this._agent.agentData.helpingFriend = false;
            this._agent.agentData.clearForcedTarget();
            this.endAttack();
            return;
         }
         if(this._agent.agentData.meleeSwinging)
         {
            if(this._attackDuration > 0 && (param2 - this._attackStartTime) / 1000 >= this._attackDuration + 0.1)
            {
               if(!this._hitChecked)
               {
                  this.checkHit();
                  this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
                  this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
                  this._agent.agentData.meleeSwinging = false;
                  this._attackDuration = 0;
               }
            }
         }
         if(!this._agent.canAttack())
         {
            return;
         }
         if(this._agent.agentData.target is Survivor)
         {
            if(Survivor(this._agent.agentData.target).mountedBuilding != null)
            {
               return;
            }
         }
         var _loc3_:Number = this._agent.getDistanceToTargetSq();
         if(_loc3_ > this._swingRange * this._swingRange || _loc3_ < this._swingMinRange * this._swingMinRange)
         {
            this.endAttack();
            return;
         }
         if(this._coverWaitTime > 0)
         {
            if(param2 - this._coverWaitTimeStart < this._coverWaitTime)
            {
               return;
            }
            this._coverWaitTime = 0;
         }
         var _loc4_:Vector3D = this._agent.actor.transform.position;
         var _loc5_:Number = this._targetPt.x - _loc4_.x;
         var _loc6_:Number = this._targetPt.y - _loc4_.y;
         this._targetForward.x = _loc5_;
         this._targetForward.y = _loc6_;
         this._agent.actor.targetForward = this._targetForward;
         _loc3_ = 1 / Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         _loc5_ *= _loc3_;
         _loc6_ *= _loc3_;
         var _loc7_:Vector3D = this._agent.entity.transform.forward;
         var _loc8_:Number = _loc5_ * -_loc7_.x + _loc6_ * -_loc7_.y;
         if(_loc8_ <= 0 || this._agent.weaponData.attackArcCosine > _loc8_)
         {
            return;
         }
         this._agent.agentData.meleeSwinging = true;
         this._agent.agentData.lastAttackTime = param2;
         this.playSwingAnimation(param2);
      }
      
      private function playSwingAnimation(param1:Number) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         this._agent.agentData.stance = AIAgentData.STANCE_STAND;
         this._animName = this._agent.weapon.animType + "-" + this._agent.weapon.getMeleeSwing();
         var _loc2_:Number = 1;
         var _loc3_:Number = this._agent.weaponData.fireRate / 1000;
         var _loc4_:Number = this._agent.actor.animatedAsset.getAnimationLength(this._animName);
         if(_loc3_ <= _loc4_)
         {
            _loc2_ = _loc4_ / _loc3_;
            this._windUpSpeed = 1;
            this._swingSpeed = 1;
            this._attackDuration = _loc4_ / _loc2_;
         }
         else
         {
            _loc6_ = this._agent.actor.animatedAsset.getAnimationNotificationTime(this._animName,"swingStart");
            _loc7_ = this._agent.actor.animatedAsset.getAnimationNotificationTime(this._animName,"swingEnd");
            _loc8_ = _loc7_ - _loc6_;
            this._windUpSpeed = (_loc4_ - _loc8_) / (_loc3_ - _loc8_);
            this._swingSpeed = 1;
            _loc9_ = (_loc4_ - _loc8_) / this._windUpSpeed;
            this._attackDuration = _loc9_ + (_loc4_ - _loc9_);
         }
         this._attackStartTime = param1;
         this._agent.actor.animatedAsset.gotoAndPlay(this._animName,0,false,_loc2_,0.1);
         this._agent.actor.animatedAsset.animSpeedMultiplier = this._windUpSpeed;
         this._hitChecked = false;
         this._agent.actor.animatedAsset.animationNotified.add(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.addOnce(this.onAnimationComplete);
         var _loc5_:String = this._agent.weapon.getSound("swing");
         if(_loc5_ != null)
         {
            this._agent.soundSource.play(_loc5_);
         }
         if(Math.random() <= 0.5 && this._agent.weapon.playSwingExertionSound)
         {
            this._agent.soundSource.play(this._agent.getSound("exert"),{"volume":0.5});
         }
      }
      
      private function checkHit() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:uint = 0;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Boolean = false;
         var _loc24_:Vector3D = null;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:BloodSpray = null;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:BloodSplatDecal = null;
         if(this._target == null || this._target.health <= 0)
         {
            return;
         }
         this._hitChecked = true;
         var _loc6_:Vector3D = this._agent.entity.transform.position;
         this._agent.getTargetPosition(this._targetPt);
         _loc1_ = this._targetPt.x - _loc6_.x;
         _loc2_ = this._targetPt.y - _loc6_.y;
         _loc3_ = this._targetPt.z - _loc6_.z;
         _loc4_ = _loc1_ * _loc1_ + _loc2_ * _loc2_ + _loc3_ * _loc3_;
         if(_loc4_ > this._swingRange * this._swingRange || _loc4_ < this._swingMinRange * this._swingMinRange)
         {
            return;
         }
         var _loc7_:Number = 1;
         var _loc8_:WeaponData = this._agent.weaponData;
         var _loc9_:Vector3D = this._agent.entity.transform.forward;
         if(!this._attackingBuilding)
         {
            _loc5_ = _loc1_ * -_loc9_.x + _loc2_ * -_loc9_.y;
            if(_loc5_ <= 0 || this._agent.weaponData.attackArcCosine > _loc5_)
            {
               _loc7_ = 0;
            }
            else
            {
               _loc12_ = _loc8_.accuracy;
               if(_loc12_ >= 0.95)
               {
                  _loc12_ = 1;
               }
               _loc7_ = _loc12_;
            }
         }
         var _loc10_:* = Math.random() < _loc7_;
         var _loc11_:Boolean = false;
         if(_loc10_)
         {
            _loc13_ = !(this._target.stateMachine.state is ActorScavengeState) && !(this._target.flags & AIAgentFlags.HEALING) && this._time - this._target.agentData.lastDodgeTime > Config.constant.DODGE_COOLDOWN * 1000;
            _loc11_ = _loc13_ ? Math.random() < this._target.weaponData.dodgeChance : false;
            if(_loc11_)
            {
               _loc10_ = false;
               this._target.agentData.lastDodgeTime = this._time;
            }
            if(!dodgeRecorded && (Config.constant.DODGE_COOLDOWN < 1 || this._target.weaponData.dodgeChance > 2))
            {
               dodgeRecorded = true;
               Network.getInstance().save({
                  "id":"dodge",
                  "cd":Number(Config.constant.DODGE_COOLDOWN),
                  "dc":this._target.weaponData.dodgeChance
               },SaveDataMethod.AH_EVENT);
            }
         }
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).showMuzzleflash();
         }
         if(_loc10_)
         {
            _loc14_ = false;
            _loc15_ = !this._attackingBuilding && this._agent.agentData.canCauseCriticals ? _loc8_.criticalChance : 0;
            if(_loc15_ > 0)
            {
               if(this._agent.agentData.canCauseBackCriticals)
               {
                  _loc24_ = this._target.entity.transform.forward;
                  _loc5_ = _loc9_.x * _loc24_.x + _loc9_.y * _loc24_.y;
               }
               else
               {
                  _loc5_ = -1;
               }
               _loc14_ = _loc5_ > 0 ? true : Math.random() < _loc15_;
            }
            _loc16_ = _loc8_.damageMin;
            _loc17_ = _loc8_.damageMax;
            _loc18_ = (_loc16_ + (_loc17_ - _loc16_) * Math.random()) * _loc8_.damageMult * (_loc14_ ? 2 : 1);
            if(this._attackingBuilding)
            {
               _loc18_ *= _loc8_.damageMultVsBuilding;
            }
            _loc19_ = _loc8_.isExplosive ? DamageType.EXPLOSIVE : DamageType.MELEE;
            _loc18_ = this._target.receiveDamage(_loc18_,_loc19_,this._agent,_loc14_);
            _loc20_ = this._targetPt.x;
            _loc21_ = this._targetPt.y;
            _loc22_ = this._targetPt.z + this._target.entity.getHeight() * 0.8;
            _loc23_ = false;
            if(this._target.health > 0 && this._target is AIActorAgent && !(this._target.stateMachine.state is ActorKnockbackState))
            {
               if(_loc14_ || Math.random() < _loc8_.knockbackChance)
               {
                  _loc25_ = Math.max(Config.constant.MAX_KNOCKBACK_FORCE * 0.25,_loc18_ / this._target.maxHealth * Config.constant.MAX_KNOCKBACK_FORCE);
                  _loc23_ = AIActorAgent(this._target).knockback(new Vector3D(_loc20_ - this._agent.actor.transform.position.x,_loc21_ - this._agent.actor.transform.position.y,0),_loc25_,_loc18_,_loc19_,this._agent);
                  if((_loc23_) && this._agent.agentData.forcedTarget != null)
                  {
                     this._agent.agentData.target = null;
                  }
               }
               else if(this._target.health > this._target.maxHealth * 0.5)
               {
                  if(Math.random() < _loc8_.knockbackChance * 2)
                  {
                     AIActorAgent(this._target).hurt(this._time);
                  }
               }
            }
            this._target.soundSource.play(this._agent.weapon.getSound("hit"),{
               "minDistance":1000,
               "maxDistance":4000
            });
            if(_loc14_)
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
            if(!this._attackingBuilding && Settings.getInstance().gore)
            {
               _loc1_ = _loc6_.x - _loc20_;
               _loc2_ = _loc6_.y - _loc21_;
               _loc3_ = _loc6_.z + this._agent.entity.getHeight() - _loc22_;
               _loc26_ = 1 / Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_ + _loc3_ * _loc3_);
               _loc1_ *= _loc26_;
               _loc2_ *= _loc26_;
               _loc3_ *= _loc26_;
               _loc27_ = BloodSpray.pool.get() as BloodSpray;
               if(_loc27_ != null)
               {
                  _loc27_.init(_loc20_,_loc21_,_loc22_,new Vector3D(_loc1_,_loc2_,_loc3_),(_loc14_ ? 0.65 : 0.5) * _loc8_.goreMultiplier,6);
                  this._agent.actor.scene.addEntity(_loc27_);
               }
               if(_loc14_ || Math.random() < 0.5)
               {
                  _loc28_ = Math.atan2(_loc2_,_loc1_) - Math.PI * 0.5 + Random.float(-Math.PI * 0.1,Math.PI * 0.1);
                  _loc29_ = Random.float(150,250) * _loc8_.goreMultiplier;
                  _loc30_ = new BloodSplatDecal(_loc20_,_loc21_,5,_loc29_,_loc28_);
                  this._agent.actor.scene.addEntity(_loc30_);
               }
            }
            if(this._target.health <= 0)
            {
               this._agent.killedEnemy.dispatch(this._agent,this._target);
            }
         }
         else if(_loc11_)
         {
            this._target.dodgedAttack.dispatch(this._target);
         }
         else
         {
            this._agent.missedAttack.dispatch(this._agent);
         }
         if(_loc23_ && this._agent.agentData.forcedTarget != null)
         {
            this._agent.agentData.target = null;
            this.endAttack();
         }
      }
      
      private function endAttack() : void
      {
         if(this._agent == null)
         {
            return;
         }
         this._agent.navigator.stop();
         this._agent.stateMachine.setState(null);
      }
      
      private function startCoverWait() : void
      {
         if(!this._agent.agentData.waitInCover)
         {
            this._coverWaitTime = 0;
            return;
         }
         this._coverWaitTime = Config.constant.COVER_FIRE_WAIT_TIME * 0.5 + Math.random() * Config.constant.COVER_FIRE_WAIT_TIME;
         this._agent.agentData.stance = AIAgentData.STANCE_CROUCH;
         this._agent.actor.animatedAsset.gotoAndPlay(this._agent.getAnimation("idle"),0,true,0.05,0.1);
      }
      
      private function onAnimationNotify(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         if(param1 != this._animName)
         {
            return;
         }
         switch(param2)
         {
            case "swingStart":
               this._agent.actor.animatedAsset.animSpeedMultiplier = this._swingSpeed;
               _loc3_ = AIActorAgent(this._agent).getSound("attack");
               if(_loc3_ != null && !Audio.sound.isPlaying(_loc3_))
               {
                  this._agent.soundSource.play(_loc3_);
               }
               if(this._agent.weaponData.noise > 0)
               {
                  this._agent.generateNoise(this._agent.weaponData.noise);
               }
               break;
            case "swingEnd":
               this._agent.actor.animatedAsset.animSpeedMultiplier = this._windUpSpeed;
               this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
               this._attackDuration = 0;
               break;
            case "hit":
               this.checkHit();
         }
      }
      
      private function onAnimationComplete(param1:String) : void
      {
         var _loc2_:Vector3D = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param1 != this._animName)
         {
            return;
         }
         if(!this._hitChecked)
         {
            this.checkHit();
         }
         this._agent.agentData.meleeSwinging = false;
         if(this._agent.agentData.coverRating > 0 && !this._attackingBuilding)
         {
            _loc2_ = this._agent.entity.transform.position;
            _loc3_ = this._targetPt.x - _loc2_.x;
            _loc4_ = this._targetPt.y - _loc2_.y;
            _loc5_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
            _loc6_ = this._agent.weaponData.range;
            if(_loc5_ > _loc6_ * _loc6_)
            {
               this.startCoverWait();
            }
         }
         else
         {
            this.endAttack();
         }
      }
   }
}

