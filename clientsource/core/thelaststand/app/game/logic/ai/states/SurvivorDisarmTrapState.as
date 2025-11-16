package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.engine.map.Path;
   
   public class SurvivorDisarmTrapState implements IAIState
   {
      
      private var _agent:Survivor;
      
      private var _target:Building;
      
      private var _currentTime:Number = 0;
      
      private var _timeDisarming:Number = 0;
      
      private var _timeToDisarm:Number;
      
      private var _timeDisarmingStart:Number;
      
      private var _progress:Number;
      
      private var _targetVector:Vector3D;
      
      private var _disarmSuccess:Boolean;
      
      private var _disarmComplete:Boolean;
      
      private var _disarmStarted:Boolean;
      
      private var _triggered:Boolean;
      
      private var _endProgress:Number;
      
      private var _hasBeenTriggered:Boolean;
      
      public var completed:Signal;
      
      public var cancelled:Signal;
      
      public var started:Signal;
      
      public var triggered:Signal;
      
      public function SurvivorDisarmTrapState(param1:Survivor, param2:Building)
      {
         super();
         this._agent = param1;
         this._target = param2;
         this._targetVector = new Vector3D();
         this.started = new Signal(Survivor,Building);
         this.completed = new Signal(Survivor,Building);
         this.cancelled = new Signal(Survivor,Building);
         this.triggered = new Signal(Survivor,Building);
      }
      
      public function dispose() : void
      {
         if(this._target != null)
         {
            this._target.flags &= ~EntityFlags.TRAP_BEING_DISARMED;
            this._target = null;
         }
         if(this._agent != null)
         {
            this._agent.flags &= ~EntityFlags.DISARMING_TRAP;
            this._agent.navigator.targetUnreachable.remove(this.onNavigationProblem);
         }
         this._agent = null;
         this.started.removeAll();
         this.completed.removeAll();
         this.cancelled.removeAll();
         this.triggered.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         this._currentTime = param1;
         this._target.flags |= EntityFlags.TRAP_BEING_DISARMED;
         this._agent.flags |= EntityFlags.DISARMING_TRAP;
         this._hasBeenTriggered = (this._target.flags & EntityFlags.TRAP_TRIGGERED) != 0;
         this._agent.agentData.clearForcedTarget();
         this._agent.agentData.target = null;
         this._agent.navigator.resume();
         this._agent.navigator.moveToEntity(this._target.buildingEntity);
         this._agent.navigator.targetUnreachable.addOnce(this.onNavigationProblem);
         this._agent.navigator.pathCompleted.addOnce(this.startDisarm);
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.flags &= ~EntityFlags.DISARMING_TRAP;
         this.started.removeAll();
         this.completed.removeAll();
         this.clearDisarm();
         if(!this._disarmComplete)
         {
            if(this._triggered)
            {
               this.triggered.dispatch(this._agent,this._target);
            }
            else
            {
               this.cancelled.dispatch(this._agent,this._target);
            }
         }
         this.triggered.removeAll();
         this.cancelled.removeAll();
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:IAITrapState = null;
         this._currentTime = param2;
         if(this._target == null || this._target.entity.scene == null || this._target.health <= 0)
         {
            this.endDisarm();
            return;
         }
         if(!this._hasBeenTriggered && (this._target.flags & EntityFlags.TRAP_TRIGGERED) != 0)
         {
            this.endDisarm();
            return;
         }
         if(this._agent.navigator.isMoving || !this._disarmStarted || this._disarmComplete || this._triggered)
         {
            return;
         }
         this._targetVector.x = this._target.entity.transform.position.x - this._agent.actor.transform.position.x;
         this._targetVector.y = this._target.entity.transform.position.y - this._agent.actor.transform.position.y;
         this._agent.actor.targetForward = this._targetVector;
         this._timeDisarming = param2 - this._timeDisarmingStart;
         this._progress = this._timeDisarming / this._timeToDisarm;
         if(this._progress < 0)
         {
            this._progress = 0;
         }
         else if(this._progress > 1)
         {
            this._progress = 1;
         }
         if(this._progress >= this._endProgress)
         {
            if(this._disarmSuccess)
            {
               this._disarmComplete = true;
               this._target.flags |= EntityFlags.TRAP_DISARMED;
               this._target.die(this._agent);
               this._agent.soundSource.play("sound/buildings/trap-disarmed.mp3");
               this.completed.dispatch(this._agent,this._target);
               this.endDisarm();
            }
            else
            {
               this._triggered = true;
               _loc3_ = this._target.stateMachine.state as IAITrapState;
               if(_loc3_ != null)
               {
                  _loc3_.trigger();
               }
               this.endDisarm();
            }
         }
      }
      
      private function startDisarm(param1:NavigatorAgent, param2:Path) : void
      {
         this._agent.navigator.cancelAndStop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.agentData.guardPoint.copyFrom(this._agent.navigator.position);
         if(!param2.goalFound || this._target == null || this._target.entity.scene == null || this._target.health <= 0)
         {
            this.endDisarm();
            return;
         }
         this._timeDisarming = 0;
         this._timeToDisarm = this._agent.getTrapDisarmTime(this._target) * 1000;
         this._timeDisarmingStart = this._currentTime;
         this._progress = 0;
         this._disarmSuccess = Math.random() < this._agent.getTrapDisarmChance(this._target);
         this._endProgress = this._disarmSuccess ? 1 : 0.1 + Math.random() * 0.8;
         this._agent.actor.animatedAsset.play("searching-crouching",true);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(false);
         }
         this._disarmStarted = true;
         this.started.dispatch(this._agent,this._target);
      }
      
      private function clearDisarm() : void
      {
         this._target.flags &= ~EntityFlags.TRAP_BEING_DISARMED;
         this._agent.navigator.targetUnreachable.remove(this.onNavigationProblem);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(true);
         }
      }
      
      private function endDisarm() : void
      {
         this._agent.navigator.cancelAndStop();
         this._agent.actor.targetForward = null;
         this._agent.stateMachine.setState(null);
      }
      
      private function onNavigationProblem(param1:NavigatorAgent) : void
      {
         this.endDisarm();
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
   }
}

