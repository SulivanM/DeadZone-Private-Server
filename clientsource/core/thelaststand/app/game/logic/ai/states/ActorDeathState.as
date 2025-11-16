package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   
   public class ActorDeathState implements IAIState
   {
      
      private var _agent:AIActorAgent;
      
      private var _blocked:Boolean;
      
      private var _nextPos:Vector3D;
      
      private var _staticDeathAnims:Array;
      
      private var _movingDeathAnims:Array;
      
      private var _minRunSpeed:Number = 200;
      
      public function ActorDeathState(param1:AIActorAgent, param2:Array, param3:Array)
      {
         super();
         this._agent = param1;
         this._nextPos = new Vector3D();
         this._staticDeathAnims = param2;
         this._movingDeathAnims = param3;
      }
      
      public function dispose() : void
      {
         this._agent = null;
         this._nextPos = null;
         this._staticDeathAnims = null;
         this._movingDeathAnims = null;
      }
      
      public function enter(param1:Number) : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = this._agent.navigator.speedSq;
         if(_loc3_ <= this._minRunSpeed * this._minRunSpeed)
         {
            _loc2_ = this._staticDeathAnims[int(Math.random() * this._staticDeathAnims.length)];
         }
         else
         {
            _loc2_ = this._movingDeathAnims[int(Math.random() * this._movingDeathAnims.length)];
         }
         this._agent.actor.animatedAsset.gotoAndPlay(_loc2_);
         this._agent.actor.targetForward = null;
         this._agent.navigator.clearPath();
         this._agent.navigator.clearTarget();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.flags |= AIAgentFlags.IMMOVEABLE;
      }
      
      public function exit(param1:Number) : void
      {
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         if(this._blocked)
         {
            return;
         }
         var _loc3_:Vector3D = this._agent.actor.transform.position;
         var _loc4_:Vector3D = this._agent.navigator.velocity;
         _loc4_.x *= 1 - 1 / this._agent.navigator.mass * 0.5;
         _loc4_.y *= 1 - 1 / this._agent.navigator.mass * 0.5;
         this._nextPos.setTo(_loc3_.x + _loc4_.x * param1,_loc3_.y + _loc4_.y * param1,0);
         if(!this._agent.actor.scene.map.isReachable(_loc3_.x,_loc3_.y,this._nextPos.x,this._nextPos.y))
         {
            this._blocked = true;
            this._agent.navigator.velocity.setTo(0,0,0);
         }
         else
         {
            _loc3_.x += _loc4_.x * param1;
            _loc3_.y += _loc4_.y * param1;
         }
      }
   }
}

