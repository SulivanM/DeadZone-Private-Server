package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.GrenadeEntity;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.game.logic.data.ThrowTrajectoryData;
   
   public class SurvivorThrowState implements IAIState
   {
      
      private static const THROW_ARC_COSINE:Number = Math.cos(10 * Math.PI / 180);
      
      private var _agent:Survivor;
      
      private var _animName:String;
      
      private var _roll:Boolean = false;
      
      private var _item:Gear;
      
      private var _trajectory:ThrowTrajectoryData;
      
      private var _targetForward:Vector3D;
      
      private var _startedThrow:Boolean = false;
      
      private var _completedThrow:Boolean = false;
      
      private var _orgStance:String;
      
      public var thrown:Signal = new Signal();
      
      public function SurvivorThrowState(param1:Survivor, param2:Gear, param3:ThrowTrajectoryData)
      {
         super();
         this._agent = param1;
         this._item = param2;
         this._trajectory = param3;
         this._targetForward = new Vector3D();
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
            if(this._agent.actor != null && this._agent.actor.animatedAsset != null)
            {
               this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
               this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
            }
            this._agent = null;
         }
         this._item = null;
         this._trajectory = null;
         this.thrown.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         this._agent.flags |= AIAgentFlags.IMMOVEABLE;
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.navigator.cancelAndStop();
         this._orgStance = this._agent.agentData.stance;
         _loc2_ = this._trajectory.target.x - this._trajectory.origin.x;
         _loc3_ = this._trajectory.target.y - this._trajectory.origin.y;
         this._targetForward.x = _loc2_;
         this._targetForward.y = _loc3_;
         this._agent.actor.targetForward = this._targetForward;
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         if(!this._completedThrow)
         {
            this.endThrow();
         }
         this.thrown.removeAll();
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(this._startedThrow)
         {
            return;
         }
         _loc3_ = this._trajectory.target.x - this._trajectory.origin.x;
         _loc4_ = this._trajectory.target.y - this._trajectory.origin.y;
         var _loc6_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
         _loc3_ /= _loc6_;
         _loc4_ /= _loc6_;
         this._roll = !this._trajectory.obstructed && _loc6_ < ThrowTrajectoryData.ROLL_DISTANCE_THRESHOLD;
         var _loc7_:Vector3D = this._agent.entity.transform.forward;
         var _loc8_:Number = _loc3_ * -_loc7_.x + _loc4_ * -_loc7_.y;
         if(_loc8_ <= 0 || THROW_ARC_COSINE > _loc8_)
         {
            return;
         }
         this.startThrow();
      }
      
      private function startThrow() : void
      {
         if(this._startedThrow)
         {
            return;
         }
         this._startedThrow = true;
         this._agent.agentData.stance = AIAgentData.STANCE_STAND;
         this._animName = this._roll ? "grenade-fire-close" : "grenade-fire-standing";
         this._agent.actor.animatedAsset.gotoAndPlay(this._animName,0,false,1,0.1);
         this._agent.actor.animatedAsset.animationNotified.addOnce(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.addOnce(this.onAnimationComplete);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(false);
         }
      }
      
      private function endThrow() : void
      {
         this._completedThrow = true;
         this._agent.agentData.stance = this._orgStance;
         this._agent.gotoIdleAnimation(true);
         this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(true);
         }
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         this._agent.navigator.mode = RVOAgentMode.GROUP_ONLY;
      }
      
      private function onAnimationNotify(param1:String, param2:String) : void
      {
         var _loc3_:GrenadeEntity = null;
         if(param1 != this._animName)
         {
            return;
         }
         if(param2 == "magOut")
         {
            this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
            this._trajectory.origin.copyFrom(this._agent.actor.transform.position);
            this._trajectory.origin.z += this._agent.actor.getHeight();
            _loc3_ = new GrenadeEntity(this._agent,this._item,this._trajectory);
            this._agent.actor.scene.addEntity(_loc3_);
            this.thrown.dispatch();
         }
      }
      
      private function onAnimationComplete(param1:String) : void
      {
         if(param1 != this._animName)
         {
            return;
         }
         this.endThrow();
         this._agent.stateMachine.setState(null);
      }
   }
}

