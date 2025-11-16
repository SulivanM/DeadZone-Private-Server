package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import flash.utils.getTimer;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIAgentData;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.network.Network;
   import thelaststand.engine.audio.SoundOutput;
   
   public class ActorReloadState implements IAIState
   {
      
      private var _agent:AIActorAgent;
      
      private var _animName:String;
      
      private var _timeStart:Number;
      
      private var _timeEnd:Number;
      
      private var _reloadComplete:Boolean;
      
      private var _reloadSound:SoundOutput;
      
      private var _actionSound:SoundOutput;
      
      private var _getTimerReloadEnd:int;
      
      public function ActorReloadState(param1:AIActorAgent)
      {
         super();
         this._agent = param1;
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            if(this._agent.actor != null && this._agent.actor.animatedAsset != null)
            {
               this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
               this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
            }
            this._agent = null;
         }
      }
      
      public function enter(param1:Number) : void
      {
         var _loc5_:Number = NaN;
         this._agent.navigator.stop();
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         this._agent.agentData.reloading = true;
         this._agent.actor.targetForward = null;
         if(this._agent.agentData.coverRating > 0 || this._agent.agentData.suppressed)
         {
            this._agent.agentData.stance = AIAgentData.STANCE_CROUCH;
         }
         this._animName = this._agent.weapon.reloadAnim + "-reload-" + this._agent.agentData.stance;
         var _loc2_:Number = this._agent.weaponData.reloadTime;
         if(this._agent.team == AIAgent.TEAM_PLAYER)
         {
            _loc5_ = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("ActionTime"));
            _loc2_ += _loc2_ * (_loc5_ / 100);
         }
         if(_loc2_ < 500)
         {
            _loc2_ = 500;
         }
         var _loc3_:Number = this._agent.actor.animatedAsset.getAnimationLength(this._animName) / (_loc2_ / 1000);
         this._timeStart = param1;
         this._timeEnd = this._timeStart + _loc2_;
         this._getTimerReloadEnd = getTimer() + _loc2_;
         this._agent.actor.animatedAsset.gotoAndPlay(this._animName,0,false,_loc3_,0.1);
         this._agent.actor.animatedAsset.animationNotified.addOnce(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.addOnce(this.onAnimationComplete);
         var _loc4_:String = this._agent.weapon.getSound("reload");
         if(_loc4_ != null)
         {
            this._reloadSound = this._agent.soundSource.play(_loc4_);
         }
         this._agent.reloadStarted.dispatch(this._agent);
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.agentData.reloading = false;
         if(this._reloadSound != null)
         {
            this._agent.soundSource.stop(this._reloadSound);
            this._reloadSound = null;
         }
         if(this._actionSound != null)
         {
            this._agent.soundSource.stop(this._actionSound);
            this._actionSound = null;
         }
         this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         if(!this._reloadComplete)
         {
            this._agent.reloadInterrupted.dispatch(this._agent);
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._agent.agentData.reloadProgress = (param2 - this._timeStart) / (this._timeEnd - this._timeStart);
         this._agent.agentData.idleTime += param1;
         if(param2 > this._timeEnd && getTimer() > this._getTimerReloadEnd)
         {
            this.endReload();
            return;
         }
      }
      
      private function endReload() : void
      {
         if(this._reloadComplete)
         {
            return;
         }
         this._reloadComplete = true;
         this._agent.agentData.reloading = false;
         this._agent.weaponData.roundsInMagazine = this._agent.weaponData.capacity;
         this._agent.reloadCompleted.dispatch(this._agent);
         this._agent.stateMachine.setState(null);
      }
      
      private function onAnimationNotify(param1:String, param2:String) : void
      {
         if(param1 != this._animName)
         {
            return;
         }
         if(param2 == "action")
         {
            this._actionSound = this._agent.soundSource.play(this._agent.weapon.getSound("action"));
         }
      }
      
      private function onAnimationComplete(param1:String) : void
      {
         if(param1 != this._animName)
         {
            return;
         }
         this.endReload();
      }
   }
}

