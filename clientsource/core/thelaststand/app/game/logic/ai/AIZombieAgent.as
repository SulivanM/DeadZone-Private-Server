package thelaststand.app.game.logic.ai
{
   import flash.geom.Vector3D;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   
   public class AIZombieAgent extends AIActorAgent
   {
      
      public var maxPathLength:int;
      
      public function AIZombieAgent()
      {
         super();
         agentData.isZombie = true;
      }
      
      override public function hurt(param1:Number) : void
      {
         if(param1 - agentData.lastHurtTime < Config.constant.ZOMBIE_HURT_COOLDOWN * 1000)
         {
            return;
         }
         super.hurt(param1);
         agentData.lastHurtTime = param1;
      }
      
      override public function receiveDamage(param1:Number, param2:uint, param3:Object = null, param4:Boolean = false) : Number
      {
         var _loc5_:Number = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("DamageVsZombies"));
         param1 += param1 * (_loc5_ / 100);
         return super.receiveDamage(param1,param2,param3,param4);
      }
      
      override public function checkLOSToAgents(param1:Vector.<AIActorAgent>) : void
      {
         var _loc6_:AIAgent = null;
         var _loc7_:Vector3D = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Vector3D = null;
         if(blackboard.scene == null)
         {
            return;
         }
         _tmpVec1.x = actor.transform.position.x;
         _tmpVec1.y = actor.transform.position.y;
         _tmpVec1.z = actor.transform.position.z + actor.getHeight();
         var _loc2_:Number = blackboard.scene.visibilityRating;
         var _loc3_:Number = agentData.visionFOVMinCosine;
         var _loc4_:Number = agentData.visionFOVMaxCosine;
         var _loc5_:Vector3D = actor.transform.forward;
         for each(_loc6_ in param1)
         {
            if(_loc6_ == this || _loc6_.health <= 0)
            {
               blackboard.visibleAgents[_loc6_] = false;
               blackboard.visibleAgentTimes[_loc6_] = 0;
            }
            else
            {
               _loc7_ = _loc6_.entity.transform.position;
               if(agentData.visionRange != Number.POSITIVE_INFINITY)
               {
                  _loc8_ = _loc7_.x - actor.transform.position.x;
                  _loc9_ = _loc7_.y - actor.transform.position.y;
                  _loc10_ = _loc8_ * _loc8_ + _loc9_ * _loc9_;
                  _loc11_ = agentData.visionRange * _loc2_;
                  if(_loc11_ < agentData.visionRangeMin)
                  {
                     _loc11_ = agentData.visionRangeMin;
                  }
                  _loc12_ = _loc11_ * _loc11_;
                  if(_loc10_ > _loc12_)
                  {
                     blackboard.visibleAgents[_loc6_] = false;
                     blackboard.visibleAgentTimes[_loc6_] = 0;
                     continue;
                  }
                  if(!blackboard.visibleAgents[_loc6_])
                  {
                     _loc10_ = Math.sqrt(_loc10_);
                     _loc13_ = _loc10_ / _loc11_;
                     _loc14_ = _loc3_ + (_loc4_ - _loc3_) * _loc13_;
                     _loc10_ = 1 / _loc10_;
                     _loc8_ *= _loc10_;
                     _loc9_ *= _loc10_;
                     _loc15_ = _loc8_ * -_loc5_.x + _loc9_ * -_loc5_.y;
                     if((_loc15_ <= 0 || _loc14_ > _loc15_) && (!agentData.canSeeBehind || _loc10_ > _loc11_ * 0.5))
                     {
                        blackboard.visibleAgents[_loc6_] = false;
                        continue;
                     }
                     _loc16_ = Number(Number(blackboard.visibleAgentTimes[_loc6_]) || 0);
                     _loc16_ = _loc16_ + _deltaTime;
                     blackboard.visibleAgentTimes[_loc6_] = _loc16_;
                     _loc17_ = _loc13_ * 2;
                     if(_loc16_ < _loc17_)
                     {
                        blackboard.visibleAgents[_loc6_] = false;
                        continue;
                     }
                  }
               }
               if(agentData.mustHaveLOSToTarget)
               {
                  _tmpVec2.x = _loc7_.x;
                  _tmpVec2.y = _loc7_.y;
                  _tmpVec2.z = _loc7_.z + _loc6_.entity.getHeight() + 80;
                  if(!navigator.lineOfSight.isPointVisible(actor.scene,actor.asset.parent.localToGlobal(_tmpVec1),actor.asset.parent.localToGlobal(_tmpVec2)))
                  {
                     blackboard.visibleAgents[_loc6_] = false;
                     blackboard.visibleAgentTimes[_loc6_] = 0;
                     continue;
                  }
               }
               _loc6_.agentData.inLOS = true;
               blackboard.visibleAgents[_loc6_] = true;
               if(agentData.mustHaveLOSToTarget)
               {
                  _loc18_ = blackboard.lastKnownAgentPos[_loc6_];
                  if(_loc18_ == null)
                  {
                     _loc18_ = new Vector3D();
                     blackboard.lastKnownAgentPos[_loc6_] = _loc18_;
                  }
                  _loc18_.copyFrom(_loc7_);
               }
               else
               {
                  blackboard.lastKnownAgentPos[_loc6_] = _loc7_;
               }
            }
         }
      }
      
      override public function evalThreats(param1:Vector.<AIActorAgent>, param2:Vector.<Building> = null) : ThreatData
      {
         var _loc3_:ThreatData = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:AIAgent = null;
         var _loc10_:Vector3D = null;
         var _loc11_:Building = null;
         var _loc12_:NoiseSource = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:NoiseSource = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc4_:Vector3D = navigator.position;
         var _loc8_:Number = Number.MAX_VALUE;
         for each(_loc9_ in param1)
         {
            if(!(_loc9_ == this || _loc9_.health <= 0 || _loc9_.team == this.team))
            {
               if(agentData.mustHaveLOSToTarget && !blackboard.visibleAgents[_loc9_])
               {
                  _loc10_ = blackboard.lastKnownAgentPos[_loc9_];
                  if(_loc10_ == null)
                  {
                     continue;
                  }
               }
               else
               {
                  _loc10_ = _loc9_.entity.transform.position;
               }
               _loc5_ = _loc10_.x - _loc4_.x;
               _loc6_ = _loc10_.y - _loc4_.y;
               _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
               if(_loc7_ < _loc8_)
               {
                  _loc8_ = _loc7_;
                  _loc3_ = ThreatData(ThreatData.pool.get()).reset();
                  _loc3_.agent = _loc9_;
                  _loc3_.agentThreatValue = -_loc7_;
                  if(_loc9_ is Survivor)
                  {
                     _loc11_ = Survivor(_loc9_).mountedBuilding;
                     if(_loc11_ != null)
                     {
                        _loc3_.agent = _loc11_;
                     }
                  }
                  if(!agentData.mustHaveLOSToTarget)
                  {
                     blackboard.lastKnownAgentPos[_loc9_] = _loc10_;
                  }
               }
            }
         }
         if(_loc3_ == null)
         {
            _loc13_ = 0;
            _loc14_ = blackboard.scene.noiseVolumeMultiplier;
            for each(_loc15_ in blackboard.scene.noiseSources)
            {
               if(_loc15_.volume > 0)
               {
                  _loc5_ = _loc15_.position.x - _loc4_.x;
                  _loc6_ = _loc15_.position.y - _loc4_.y;
                  _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
                  _loc16_ = _loc15_.volume * blackboard.scene.map.cellSize * _loc14_ * 10;
                  if(_loc7_ <= _loc16_ * _loc16_)
                  {
                     _loc17_ = _loc16_ / Math.sqrt(_loc7_) * _loc15_.volume;
                     if(_loc17_ >= _loc13_)
                     {
                        _loc12_ = _loc15_;
                        _loc13_ = _loc17_;
                     }
                  }
               }
            }
            if(_loc12_ != null)
            {
               _loc3_ = ThreatData(ThreatData.pool.get()).reset();
               _loc3_.agentThreatValue = int.MAX_VALUE;
               _loc3_.noise = _loc15_;
            }
         }
         return _loc3_;
      }
   }
}

