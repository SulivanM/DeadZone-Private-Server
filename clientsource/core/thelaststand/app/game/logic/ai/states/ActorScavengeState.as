package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.network.Network;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.objects.GameEntity;
   
   public class ActorScavengeState implements IAIState
   {
      
      private var _agent:AIActorAgent;
      
      private var _searchTarget:GameEntity;
      
      private var _currentTime:Number;
      
      private var _timeSearching:Number = 0;
      
      private var _timeSearchingStart:Number = 0;
      
      private var _timeToSearch:Number;
      
      private var _progress:Number;
      
      private var _targetVector:Vector3D;
      
      private var _scavengeComplete:Boolean;
      
      private var _scavengeStarted:Boolean;
      
      public var completed:Signal;
      
      public var cancelled:Signal;
      
      public var started:Signal;
      
      public function ActorScavengeState(param1:AIActorAgent, param2:GameEntity)
      {
         super();
         this._agent = param1;
         this._searchTarget = param2;
         this._targetVector = new Vector3D();
         this.started = new Signal(AIActorAgent,GameEntity);
         this.completed = new Signal(AIActorAgent,GameEntity,Number,Number);
         this.cancelled = new Signal(AIActorAgent,GameEntity);
      }
      
      public function dispose() : void
      {
         if(this._searchTarget != null)
         {
            this._searchTarget.flags &= ~EntityFlags.BEING_SCAVENGED;
            this._searchTarget = null;
         }
         if(this._agent != null)
         {
            this._agent.navigator.pathCompleted.remove(this.startScavenge);
            this._agent.navigator.targetUnreachable.remove(this.onNavigationProblem);
         }
         this._agent = null;
         this.started.removeAll();
         this.completed.removeAll();
         this.cancelled.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         this._currentTime = param1;
         this._searchTarget.flags |= EntityFlags.BEING_SCAVENGED;
         this._agent.agentData.clearForcedTarget();
         this._agent.agentData.target = null;
         this._agent.navigator.resume();
         this._agent.navigator.moveToEntity(this._searchTarget);
         this._agent.navigator.pathCompleted.addOnce(this.startScavenge);
         this._agent.navigator.targetUnreachable.addOnce(this.onNavigationProblem);
      }
      
      public function exit(param1:Number) : void
      {
         this.started.removeAll();
         this.completed.removeAll();
         this.clearScavenge();
         if(!this._scavengeComplete)
         {
            this.cancelled.dispatch(this._agent,this._searchTarget);
            this.cancelled.removeAll();
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._currentTime = param2;
         if(this._agent.navigator.isMoving || !this._scavengeStarted)
         {
            return;
         }
         if(this._searchTarget != null)
         {
            this._targetVector.x = this._searchTarget.transform.position.x - this._agent.actor.transform.position.x;
            this._targetVector.y = this._searchTarget.transform.position.y - this._agent.actor.transform.position.y;
            this._agent.actor.targetForward = this._targetVector;
            this._timeSearching = param2 - this._timeSearchingStart;
            this._progress = this._timeSearching / this._timeToSearch;
         }
         else
         {
            this._progress = 0;
         }
         if(this._progress < 0)
         {
            this._progress = 0;
         }
         else if(this._progress > 1)
         {
            this._progress = 1;
         }
         if(this._progress >= 1)
         {
            this._scavengeComplete = true;
            this.completed.dispatch(this._agent,this._searchTarget,this._timeToSearch,this._timeSearching);
            this.endScavenge();
         }
      }
      
      private function startScavenge(param1:NavigatorAgent, param2:Path) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Survivor = null;
         var _loc11_:BuildingEntity = null;
         var _loc12_:Number = NaN;
         this._agent.navigator.cancelAndStop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.agentData.guardPoint.copyFrom(this._agent.navigator.position);
         if(!param2.goalFound || this._searchTarget == null || this._searchTarget.scene == null)
         {
            this.endScavenge();
            return;
         }
         var _loc3_:Number = 0;
         var _loc4_:Number = Number(Config.constant.MIN_SCAVENGE_TIME);
         if(this._searchTarget.flags & EntityFlags.EMPTY_CONTAINER)
         {
            _loc3_ = _loc4_;
         }
         else
         {
            _loc8_ = Number(Config.constant.BASE_SCAVENGE_TIME);
            _loc9_ = 1;
            if(this._agent is Survivor)
            {
               _loc10_ = this._agent as Survivor;
               _loc9_ = _loc10_.getAttribute(Attributes.SCAVENGE_SPEED);
            }
            if(this.searchTarget is BuildingEntity)
            {
               _loc11_ = BuildingEntity(this.searchTarget);
               _loc8_ = _loc11_.buildingData.scavengeTime;
               if(_loc11_.buildingData.minScavengeTime > 0)
               {
                  _loc4_ = _loc11_.buildingData.minScavengeTime;
               }
            }
            else if(this.searchTarget.properties.hasOwnProperty("scavengeTime"))
            {
               _loc8_ = Number(this.searchTarget.properties.scavengeTime);
            }
            _loc3_ = Math.max(_loc4_,_loc8_ / _loc9_);
         }
         if(this._agent.team == AIAgent.TEAM_PLAYER)
         {
            _loc12_ = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("ActionTime"));
            _loc3_ += _loc3_ * (_loc12_ / 100);
         }
         if(_loc3_ < _loc4_)
         {
            _loc3_ = _loc4_;
         }
         this._timeSearching = 0;
         this._timeSearchingStart = this._currentTime;
         this._timeToSearch = _loc3_ * 1000;
         this._progress = 0;
         var _loc5_:int = this._searchTarget.asset.z + this._searchTarget.asset.boundBox.minZ + (this._searchTarget.asset.boundBox.maxZ - this._searchTarget.asset.boundBox.minZ);
         var _loc6_:int = this._agent.actor.asset.z + this._agent.actor.getHeight();
         var _loc7_:String = _loc5_ < _loc6_ * 0.75 ? "searching-crouching" : "searching-standing";
         this._agent.actor.animatedAsset.play(_loc7_,true);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(false);
         }
         this._scavengeStarted = true;
         this.started.dispatch(this._agent,this._searchTarget);
      }
      
      private function clearScavenge() : void
      {
         this._searchTarget.flags &= ~EntityFlags.BEING_SCAVENGED;
         this._agent.agentData.guardPoint.copyFrom(this._agent.navigator.position);
         this._agent.navigator.targetUnreachable.remove(this.onNavigationProblem);
         this._agent.navigator.pathCompleted.remove(this.startScavenge);
         this._agent.navigator.mode = RVOAgentMode.GROUP_ONLY;
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(true);
         }
      }
      
      private function endScavenge() : void
      {
         this._agent.navigator.cancelAndStop();
         this._agent.actor.targetForward = null;
         this._agent.stateMachine.setState(null);
      }
      
      private function onNavigationProblem(param1:NavigatorAgent) : void
      {
         this.endScavenge();
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
      
      public function get searchTarget() : GameEntity
      {
         return this._searchTarget;
      }
   }
}

