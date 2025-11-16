package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import flash.utils.getTimer;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.network.Network;
   
   public class SurvivorHealingState implements IAIState
   {
      
      private var _agent:Survivor;
      
      private var _anim:String;
      
      private var _timeStart:Number;
      
      private var _timeHeal:Number;
      
      private var _progress:Number;
      
      private var _healingTarget:Survivor;
      
      private var _healAmount:Number = 0;
      
      private var _healHealthTarget:Number = 1;
      
      private var _startHealth:Number = 0;
      
      private var _damageCooldown:Number = 0;
      
      private var _damageCooldownStart:Number = 0;
      
      private var _targetVector:Vector3D;
      
      private var _healStarted:Boolean = false;
      
      private var _healComplete:Boolean = false;
      
      private var _currentTime:Number;
      
      private var _lastTime:Number;
      
      public var started:Signal;
      
      public var completed:Signal;
      
      public var cancelled:Signal;
      
      public function SurvivorHealingState(param1:Survivor, param2:Survivor = null)
      {
         super();
         this._agent = param1;
         this._healingTarget = param2;
         this._targetVector = new Vector3D();
         this.started = new Signal(Survivor,AIAgent);
         this.completed = new Signal(Survivor,AIAgent,Number);
         this.cancelled = new Signal(Survivor,AIAgent,Number);
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            this.clearHealing();
         }
         this.started.removeAll();
         this.completed.removeAll();
         this.cancelled.removeAll();
         this._agent = null;
         this._healingTarget = null;
      }
      
      public function enter(param1:Number) : void
      {
         var t:Number = param1;
         this._healStarted = false;
         this._healComplete = false;
         this._currentTime = this._lastTime = getTimer();
         this._agent.agentData.clearForcedTarget();
         this._agent.agentData.target = null;
         this._healingTarget.flags |= AIAgentFlags.IS_HEALING_TARGET;
         if(this._healingTarget == this._agent)
         {
            this.startHealing();
         }
         else
         {
            if(this._healingTarget.navigator.isMoving && this._healingTarget.stateMachine.state is ActorScavengeState)
            {
               this._healingTarget.stateMachine.setState(null);
            }
            this._healingTarget.navigator.cancelAndStop();
            this._healingTarget.navigator.mode = RVOAgentMode.STATIC;
            this._healingTarget.navigator.movementStarted.addOnce(this.onNavigationProblem);
            this._agent.navigator.followTarget(this._healingTarget.navigator.position,this._healingTarget.agentData.radius);
            this._agent.navigator.targetUnreachable.addOnce(this.onNavigationProblem);
            this._agent.navigator.targetReached.addOnce(function(param1:NavigatorAgent):void
            {
               startHealing();
            });
         }
      }
      
      public function exit(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this._healingTarget != null)
         {
            if(this._agent.navigator.target == this._healingTarget.navigator.position)
            {
               this._agent.navigator.clearTarget();
            }
         }
         this.started.removeAll();
         this.completed.removeAll();
         this.clearHealing();
         if(!this._healComplete)
         {
            _loc2_ = this._healStarted ? this._healingTarget.health - this._startHealth : 0;
            this.cancelled.dispatch(this._agent,this._healingTarget,_loc2_);
            this.cancelled.removeAll();
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._currentTime = getTimer();
         if(this._healingTarget.health <= 0 || !(this._healingTarget.flags & AIAgentFlags.IS_HEALING_TARGET))
         {
            this.endHealing();
            return;
         }
         this._healingTarget.navigator.stop();
         this._healingTarget.navigator.mode = RVOAgentMode.STATIC;
         if(!this._healStarted || this._agent.navigator.isMoving)
         {
            return;
         }
         if(this._damageCooldown > 0)
         {
            if(this._currentTime - this._damageCooldownStart < this._damageCooldown)
            {
               return;
            }
            this._damageCooldown = 0;
         }
         else if(this._agent.actor.animatedAsset.currentAnimation != this._anim)
         {
            this._agent.actor.animatedAsset.play(this._anim,true,1,0.1);
         }
         if(this._healingTarget != this._agent)
         {
            this._targetVector.x = this._healingTarget.entity.transform.position.x - this._agent.actor.transform.position.x;
            this._targetVector.y = this._healingTarget.entity.transform.position.y - this._agent.actor.transform.position.y;
            this._agent.actor.targetForward = this._targetVector;
         }
         this._healingTarget.health += this._healAmount * ((this._currentTime - this._lastTime) / 1000);
         if(this._healingTarget.health >= this._healHealthTarget)
         {
            this._healComplete = true;
            this.completed.dispatch(this._agent,this._healingTarget,this._healingTarget.health - this._startHealth);
            this.endHealing();
         }
         this._lastTime = this._currentTime;
      }
      
      private function startHealing() : void
      {
         var _loc1_:Number = NaN;
         this._agent.agentData.guardPoint.copyFrom(this._agent.navigator.position);
         if(this._healingTarget == null || !(this._healingTarget.flags & AIAgentFlags.IS_HEALING_TARGET))
         {
            this.endHealing();
            return;
         }
         this._healStarted = true;
         this._healComplete = false;
         this._lastTime = getTimer();
         this._agent.navigator.cancelAndStop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.agentData.stance = AIAgentData.STANCE_CROUCH;
         this._agent.flags |= AIAgentFlags.HEALING;
         this._agent.damageTaken.add(this.onDamageTaken);
         this._healingTarget.flags |= AIAgentFlags.BEING_HEALED;
         this._healingTarget.healingStarted.dispatch(this._healingTarget);
         if(this._healingTarget != this._agent)
         {
            this._healingTarget.navigator.mode = RVOAgentMode.STATIC;
            this._healingTarget.damageTaken.add(this.onDamageTaken);
         }
         this._healAmount = Config.constant.BASE_HEAL_AMOUNT_PER_SECOND * this._agent.getAttribute(Attributes.HEALING);
         if(this._agent.team == AIAgent.TEAM_PLAYER)
         {
            _loc1_ = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("ActionTime"));
            if(_loc1_ > 99)
            {
               _loc1_ = 99;
            }
            this._healAmount -= this._healAmount * (_loc1_ / 100);
         }
         this._healHealthTarget = this._healingTarget.getHealableHealth();
         this._startHealth = this._healingTarget.health;
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(false);
         }
         this._anim = "searching-crouching";
         this._agent.actor.animatedAsset.play(this._anim,true,1,0.25);
         this._agent.actor.targetForward = null;
         this.started.dispatch(this._agent,this._healingTarget);
      }
      
      private function endHealing() : void
      {
         if(this._healingTarget != null)
         {
            this._healingTarget.navigator.mode = RVOAgentMode.GROUP_ONLY;
         }
         this._agent.navigator.cancelAndStop();
         this._agent.actor.targetForward = null;
         this._agent.stateMachine.setState(null);
      }
      
      private function clearHealing() : void
      {
         this._agent.flags &= ~AIAgentFlags.HEALING;
         this._agent.flags &= ~AIAgentFlags.IS_HEALING_TARGET;
         this._agent.navigator.targetUnreachable.remove(this.onNavigationProblem);
         this._agent.damageTaken.remove(this.onDamageTaken);
         if(this._agent.agentData.coverRating <= 0)
         {
            this._agent.agentData.stance = AIAgentData.STANCE_STAND;
         }
         this._agent.agentData.guardPoint.copyFrom(this._agent.navigator.position);
         if(this._healingTarget != null)
         {
            this._healingTarget.agentData.guardPoint.copyFrom(this._healingTarget.navigator.position);
            this._healingTarget.flags &= ~AIAgentFlags.IS_HEALING_TARGET;
            this._healingTarget.flags &= ~AIAgentFlags.BEING_HEALED;
            this._healingTarget.damageTaken.remove(this.onDamageTaken);
            this._healingTarget.navigator.movementStarted.remove(this.onNavigationProblem);
            this._healingTarget.healingCompleted.dispatch(this._healingTarget);
         }
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(true);
         }
      }
      
      private function onDamageTaken(param1:AIAgent, param2:Number, param3:Object, param4:Boolean) : void
      {
         if(param2 <= 0)
         {
            return;
         }
         if(this._damageCooldown <= 0)
         {
            this._agent.actor.animatedAsset.play(this._agent.getAnimation("suppressed"),true,0.03,0.25);
         }
         this._damageCooldown = Number(Config.constant.HEAL_DAMAGE_DELAY) * 1000;
         this._damageCooldownStart = this._currentTime;
      }
      
      private function onNavigationProblem(param1:NavigatorAgent) : void
      {
         this.endHealing();
      }
   }
}

