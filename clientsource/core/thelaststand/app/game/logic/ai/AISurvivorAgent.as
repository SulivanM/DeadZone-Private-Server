package thelaststand.app.game.logic.ai
{
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.logic.ai.states.ActorScavengeState;
   import thelaststand.app.network.Network;
   
   public class AISurvivorAgent extends AIActorAgent
   {
      
      private var _damgeReceivedAgents:Dictionary = new Dictionary(true);
      
      public var sharedTargetInfo:Dictionary;
      
      public function AISurvivorAgent()
      {
         super();
         agentData.isZombie = false;
         this.damageTaken.add(this.handleDamageTaken);
      }
      
      override public function generateNoise(param1:Number, param2:Number = 1) : void
      {
         var _loc3_:Number = NaN;
         if(team == TEAM_PLAYER)
         {
            _loc3_ = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("Noise"));
            param1 += param1 * (_loc3_ / 100);
         }
         super.generateNoise(param1,param2);
      }
      
      override public function hurt(param1:Number) : void
      {
         if(navigator.isMoving)
         {
            return;
         }
         if(param1 - agentData.lastHurtTime < Config.constant.SURVIVOR_HURT_COOLDOWN * 1000)
         {
            return;
         }
         super.hurt(param1);
         agentData.lastHurtTime = param1;
      }
      
      override public function die(param1:Object) : Boolean
      {
         if(this.sharedTargetInfo != null)
         {
            delete this.sharedTargetInfo[this];
         }
         return super.die(param1);
      }
      
      override public function knockback(param1:Vector3D, param2:Number, param3:Number = 0, param4:uint = 0, param5:Object = null) : Boolean
      {
         if(navigator.isMoving)
         {
            return false;
         }
         return super.knockback(param1,param2,param3,param4,param5);
      }
      
      override public function evalThreats(param1:Vector.<AIActorAgent>, param2:Vector.<Building> = null) : ThreatData
      {
         var _loc5_:AIAgent = null;
         var _loc8_:Vector3D = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc14_:AIAgent = null;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:Boolean = false;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Building = null;
         var _loc22_:int = 0;
         var _loc23_:AIAgent = null;
         var _loc24_:ThreatData = null;
         var _loc25_:AIAgent = null;
         var _loc26_:Number = NaN;
         var _loc3_:Number = _weapon != null && _weaponData != null ? _weaponData.minRange : 0;
         var _loc4_:Number = _weapon != null && _weaponData != null ? _weaponData.range : 0;
         if(agentData.coverRating > 0 && _weaponData.isMelee)
         {
            _loc4_ *= 3;
         }
         var _loc6_:Number = int.MIN_VALUE;
         var _loc7_:Vector3D = _entity.transform.position;
         var _loc12_:int = Config.constant.PVP_FRIEND_HELP_DIST * 100;
         var _loc13_:Number = Config.constant.MELEE_THREAT_DIST * 100;
         if(team == TEAM_PLAYER)
         {
            _loc15_ = 5;
         }
         for each(_loc14_ in param1)
         {
            if(!(_loc14_ == null || _loc14_ == this || _loc14_.health <= 0 || _loc14_.team == this.team))
            {
               if(blackboard.visibleAgents[_loc14_])
               {
                  _loc8_ = _loc14_.entity.transform.position;
                  _loc9_ = _loc8_.x - _loc7_.x;
                  _loc10_ = _loc8_.y - _loc7_.y;
                  _loc11_ = _loc9_ * _loc9_ + _loc10_ * _loc10_;
                  if(_loc11_ >= _loc3_ * _loc3_)
                  {
                     _loc16_ = int.MAX_VALUE - _loc11_;
                     if(!_loc14_.agentData.isZombie)
                     {
                        if(_loc14_.weaponData.isMelee && _loc11_ > _loc13_ * _loc13_)
                        {
                           _loc16_ *= Config.constant.MELEE_THREAT_MOD;
                        }
                        if(_loc14_.agentData.suppressed)
                        {
                           _loc16_ *= Config.constant.SUPPRESSED_THREAT_MOD;
                        }
                        if(_loc14_.team == AIAgent.TEAM_PLAYER)
                        {
                           _loc17_ = _loc14_.stateMachine.state is ActorScavengeState && (_loc14_.stateMachine.state as ActorScavengeState).progress > 0;
                           if(_loc14_.agentData.idleTime >= Config.constant.THREAT_IDLE_TIME)
                           {
                              _loc19_ = 1 - (_loc14_.agentData.idleTime - Config.constant.THREAT_IDLE_TIME) / Config.constant.THREAT_IDLE_DECAY_RATE * Config.constant.THREAT_IDLE_DECAY;
                              if(_loc19_ < Config.constant.THREAT_IDLE_DECAY_MIN)
                              {
                                 _loc19_ = Number(Config.constant.THREAT_IDLE_DECAY_MIN);
                              }
                              _loc16_ *= _loc19_;
                           }
                           if(_loc14_.agentData.target == this)
                           {
                              _loc16_ *= Config.constant.TARGETED_THREAT_MOD;
                              if(_loc14_.agentData.coverRating <= 0)
                              {
                                 _loc16_ *= Config.constant.TARGETED_NO_COVER_THREAT_MOD;
                              }
                           }
                           _loc18_ = _loc4_ * _loc4_;
                           if(_loc11_ < _loc18_)
                           {
                              _loc20_ = this._damgeReceivedAgents[_loc14_] != null ? Number(this._damgeReceivedAgents[_loc14_]) : 0;
                              if(_loc20_ > 0)
                              {
                                 _loc16_ *= 1 + _loc20_ * Config.constant.THREAT_ATTACKER_DAMAGE_MULT;
                              }
                              if(_loc17_)
                              {
                                 _loc16_ *= 3 * (1 - _loc11_ / _loc18_);
                              }
                           }
                           if(!_loc14_.weaponData.isMelee)
                           {
                              if(_loc14_.agentData.target != null && _loc14_.agentData.target is Building)
                              {
                                 _loc21_ = _loc14_.agentData.target as Building;
                                 if(_loc21_.buildingEntity.coveredAgents.indexOf(this.agentData) == -1)
                                 {
                                    _loc16_ *= Config.constant.THREAT_RANDOM_BUILDING_PENALTY;
                                 }
                              }
                           }
                           if(this.sharedTargetInfo != null)
                           {
                              delete this.sharedTargetInfo[this];
                              _loc22_ = 0;
                              for each(_loc23_ in this.sharedTargetInfo)
                              {
                                 if(_loc23_ == _loc14_)
                                 {
                                    _loc22_++;
                                 }
                              }
                              if(_loc22_ >= Config.constant.THREAT_HIVE_TARGET_MAX)
                              {
                                 _loc16_ *= Config.constant.THREAT_HIVE_TARGET_DECAY;
                              }
                           }
                        }
                        if(_loc14_.weaponData.isMelee && _loc14_.agentData.coverRating > 0 && !weaponData.isMelee)
                        {
                           if(_loc14_.team == TEAM_ENEMY)
                           {
                              _loc16_ *= Config.constant.THREAT_COVERED_MELEE_PENATLY_DEFENDER;
                           }
                           else
                           {
                              _loc16_ *= Config.constant.THREAT_COVERED_MELEE_PENATLY_ATTACKER;
                           }
                        }
                     }
                     if(_loc16_ > _loc6_)
                     {
                        _loc5_ = _loc14_;
                        _loc6_ = _loc16_;
                     }
                  }
               }
            }
         }
         if(_loc5_ != null)
         {
            if(this.sharedTargetInfo != null)
            {
               this.sharedTargetInfo[this] = _loc5_;
            }
            _loc24_ = ThreatData(ThreatData.pool.get()).reset();
            _loc24_.agent = _loc5_;
            _loc24_.helpingFriend = false;
            if(this.team != AIAgent.TEAM_PLAYER)
            {
               _loc25_ = _loc5_.agentData.target;
               if(_loc25_ != this && _loc25_ != null && _loc25_.team == this.team && _loc25_.agentData.suppressionRating > _loc25_.agentData.suppressionPoints * Config.constant.SUPPRESSED_ATTACK_PERC)
               {
                  _loc8_ = _loc25_.entity.transform.position;
                  _loc9_ = _loc8_.x - _loc7_.x;
                  _loc10_ = _loc8_.y - _loc7_.y;
                  _loc26_ = _loc9_ * _loc9_ + _loc10_ * _loc10_;
                  _loc24_.helpingFriend = _loc26_ < _loc12_ * _loc12_;
               }
            }
            return _loc24_;
         }
         return null;
      }
      
      private function abs(param1:Number) : Number
      {
         return param1 < 0 ? -param1 : param1;
      }
      
      private function handleDamageTaken(param1:AIAgent, param2:Number, param3:Object, param4:Boolean) : void
      {
         if(!(param3 is AIAgent))
         {
            return;
         }
         var _loc5_:AIAgent = param3 as AIAgent;
         if(this._damgeReceivedAgents[_loc5_] == null)
         {
            this._damgeReceivedAgents[_loc5_] = 0;
         }
         this._damgeReceivedAgents[_loc5_] += param2;
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         super.update(param1,param2);
         for(_loc3_ in this._damgeReceivedAgents)
         {
            _loc4_ = Number(this._damgeReceivedAgents[_loc3_]);
            if(_loc4_ > 0)
            {
               _loc4_ -= param1 * Config.constant.THREAT_ATTACKER_DAMAGE_DECAY;
               if(_loc4_ < 0.001)
               {
                  _loc4_ = 0;
               }
               this._damgeReceivedAgents[_loc3_] = _loc4_;
            }
         }
      }
   }
}

