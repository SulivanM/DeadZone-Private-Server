package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   
   public class ActorSuppressedState implements IAIState
   {
      
      private var _agent:AIActorAgent;
      
      public function ActorSuppressedState(param1:AIActorAgent)
      {
         super();
         this._agent = param1;
      }
      
      public function dispose() : void
      {
         this._agent = null;
      }
      
      public function enter(param1:Number) : void
      {
         this._agent.navigator.stop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         var _loc2_:String = this._agent.getAnimation("suppressed");
         this._agent.actor.animatedAsset.gotoAndPlay(_loc2_,0,true,0.03,0.5);
         if(HumanActor(this._agent.actor).obj_handRight != null)
         {
            HumanActor(this._agent.actor).obj_handRight.visible = false;
         }
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.actor.animatedAsset.gotoAndPlay(this._agent.getAnimation("idle"),0,true,0.05,0.1);
         if(HumanActor(this._agent.actor).obj_handRight != null)
         {
            HumanActor(this._agent.actor).obj_handRight.visible = true;
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         if(this._agent.requiresReload() && !(this._agent.flags & AIAgentFlags.RELOAD_DISABLED))
         {
            if(this._agent.reloadWeapon())
            {
               return;
            }
         }
         if(!this._agent.agentData.suppressed)
         {
            this._agent.stateMachine.setState(null);
            return;
         }
      }
   }
}

