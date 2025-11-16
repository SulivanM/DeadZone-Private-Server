package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   
   public class ActorKnockdownState implements IAIState
   {
      
      private var _agent:AIActorAgent;
      
      private var _direction:Vector3D;
      
      private var _force:Number;
      
      private var _nextPos:Vector3D;
      
      private var _blocked:Boolean;
      
      private var _stunTime:Number = 0;
      
      private var _stunTimeStart:Number = 0;
      
      private var _wasMoving:Boolean = false;
      
      private var _gettingUp:Boolean = false;
      
      public function ActorKnockdownState(param1:AIActorAgent, param2:Vector3D, param3:Number)
      {
         super();
         this._agent = param1;
         this._direction = param2;
         this._direction.normalize();
         this._force = param3;
         this._nextPos = new Vector3D();
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         }
         this._agent = null;
         this._direction = null;
         this._nextPos = null;
      }
      
      public function enter(param1:Number) : void
      {
         var _loc5_:Vector3D = null;
         var _loc6_:Vector3D = null;
         var _loc7_:AIActorAgent = null;
         var _loc8_:Vector3D = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Vector3D = null;
         var _loc14_:Number = NaN;
         this._wasMoving = this._agent.navigator.isMoving;
         this._agent.navigator.stop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.flags |= AIAgentFlags.IMMOVEABLE;
         this._agent.actor.targetForward = null;
         this._stunTime = Math.max(0.5,Math.min(this._force * 0.01,1.25)) + (Math.random() * 2 - 1) * 0.5;
         this._stunTimeStart = param1;
         var _loc2_:Number = 1 / this._agent.navigator.mass * 15;
         this._agent.navigator.velocity.x = this._direction.x * this._force * _loc2_;
         this._agent.navigator.velocity.y = this._direction.y * this._force * _loc2_;
         this._agent.actor.targetForward = new Vector3D(-this._direction.x,-this._direction.y);
         var _loc3_:String = "death-clothesline";
         var _loc4_:Number = this._agent.actor.animatedAsset.getAnimationLength(_loc3_);
         this._agent.actor.animatedAsset.gotoAndPlay(_loc3_,0,false,_loc4_ / this._stunTime);
         if(this._force > 100)
         {
            _loc5_ = this._agent.actor.transform.forward;
            _loc6_ = this._agent.actor.transform.position;
            for each(_loc7_ in this._agent.blackboard.friends)
            {
               if(!(_loc7_ == this._agent || _loc7_.health <= 0))
               {
                  _loc8_ = _loc7_.actor.transform.position;
                  _loc9_ = _loc8_.x - _loc6_.x;
                  _loc10_ = _loc8_.y - _loc6_.y;
                  _loc11_ = _loc9_ * _loc9_ + _loc10_ * _loc10_;
                  _loc12_ = _loc7_.agentData.radius + this._agent.agentData.radius;
                  if(_loc11_ <= _loc12_ * _loc12_)
                  {
                     _loc13_ = _loc7_.entity.transform.forward;
                     _loc14_ = _loc5_.x * _loc13_.x + _loc5_.y * _loc13_.y;
                     if(_loc14_ > 0)
                     {
                        _loc7_.knockback(new Vector3D(_loc9_,_loc10_),this._force * 0.25);
                     }
                  }
               }
            }
         }
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         if(this._wasMoving)
         {
            this._agent.navigator.resume();
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Vector3D = null;
         if(this._gettingUp)
         {
            return;
         }
         if((param2 - this._stunTimeStart) / 1000 >= this._stunTime)
         {
            this.getUp();
            return;
         }
         if(!this._blocked)
         {
            _loc3_ = this._agent.navigator.position;
            _loc4_ = this._agent.navigator.velocity;
            _loc4_.x *= 1 - 1 / (this._agent.navigator.mass * 3);
            _loc4_.y *= 1 - 1 / (this._agent.navigator.mass * 3);
            this._nextPos.x = _loc3_.x + _loc4_.x * param1 * 2;
            this._nextPos.y = _loc3_.y + _loc4_.y * param1 * 2;
            if(!this._agent.actor.scene.map.isReachable(_loc3_.x,_loc3_.y,this._nextPos.x,this._nextPos.y))
            {
               this._blocked = true;
               _loc4_.setTo(0,0,0);
            }
            else
            {
               _loc3_.x += _loc4_.x * param1;
               _loc3_.y += _loc4_.y * param1;
            }
         }
      }
      
      private function getUp() : void
      {
         var velocity:Vector3D;
         var animName:String;
         var self:ActorKnockdownState = null;
         var agent:AIActorAgent = null;
         this._gettingUp = true;
         velocity = this._agent.navigator.velocity;
         velocity.x = velocity.y = velocity.z = 0;
         this._agent.agentData.guardPoint.copyFrom(this._agent.actor.transform.position);
         animName = this._agent.getAnimation("getup");
         this._agent.actor.animatedAsset.gotoAndPlay(animName,0,false,1,0.5);
         self = this;
         agent = this._agent;
         this._agent.actor.animatedAsset.animationCompleted.add(function(param1:String):void
         {
            agent.flags &= ~AIAgentFlags.IMMOVEABLE;
            agent.actor.animatedAsset.animationCompleted.remove(arguments.callee);
            if(agent.stateMachine.state == self)
            {
               agent.actor.animatedAsset.gotoAndPlay(agent.getAnimation("idle"),0,false,1,0.5);
               agent.stateMachine.setState(null);
            }
         });
      }
   }
}

