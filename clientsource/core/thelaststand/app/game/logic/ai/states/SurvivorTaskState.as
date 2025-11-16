package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.engine.objects.GameEntity;
   
   public class SurvivorTaskState implements IAIState
   {
      
      private var _agent:Survivor;
      
      private var _taskTarget:GameEntity;
      
      private var _targetVector:Vector3D;
      
      public function SurvivorTaskState(param1:Survivor, param2:GameEntity)
      {
         super();
         this._agent = param1;
         this._taskTarget = param2;
         this._targetVector = new Vector3D();
      }
      
      public function dispose() : void
      {
         this._agent = null;
         this._taskTarget = null;
      }
      
      public function enter(param1:Number) : void
      {
         var _loc2_:int = this._taskTarget.transform.position.z + this._taskTarget.getHeight();
         var _loc3_:int = this._agent.actor.asset.z + this._agent.actor.getHeight();
         var _loc4_:String = _loc2_ < _loc3_ * 0.75 ? "searching-crouching" : "searching-standing";
         this._agent.actor.animatedAsset.play(_loc4_,true);
         this._agent.navigator.stop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.actor.targetForward = null;
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._targetVector.x = this._taskTarget.transform.position.x - this._agent.actor.transform.position.x;
         this._targetVector.y = this._taskTarget.transform.position.y - this._agent.actor.transform.position.y;
         this._agent.actor.targetForward = this._targetVector;
      }
   }
}

