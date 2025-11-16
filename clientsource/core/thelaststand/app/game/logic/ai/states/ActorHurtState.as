package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   
   public class ActorHurtState implements IAIState
   {
      
      private var _agent:AIActorAgent;
      
      private var _wasMoving:Boolean = false;
      
      public function ActorHurtState(param1:AIActorAgent)
      {
         super();
         this._agent = param1;
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            if(this._agent.actor != null)
            {
               this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimComplete);
            }
            this._agent = null;
         }
      }
      
      public function enter(param1:Number) : void
      {
         this._wasMoving = this._agent.navigator.isMoving;
         this._agent.navigator.stop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.actor.targetForward = null;
         var _loc2_:String = this._agent.getAnimation("hurt");
         this._agent.actor.animatedAsset.gotoAndPlay(_loc2_,0);
         this._agent.actor.animatedAsset.animationCompleted.addOnce(this.onAnimComplete);
      }
      
      public function exit(param1:Number) : void
      {
         if(this._wasMoving)
         {
            this._agent.navigator.resume();
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
      }
      
      private function onAnimComplete(param1:String) : void
      {
         this._agent.actor.animatedAsset.gotoAndPlay(this._agent.getAnimation("idle"));
         this._agent.stateMachine.setState(null);
      }
   }
}

