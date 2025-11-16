package thelaststand.app.game.logic.ai.states
{
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Zombie;
   
   public class ZombieAlertedState implements IAIState
   {
      
      private var _agent:Zombie;
      
      private var _target:Vector3D;
      
      private var _alertAnim:String;
      
      private var _alertTime:Number;
      
      private var _alertStartTime:Number;
      
      private var _targetVector:Vector3D;
      
      public var completed:Signal;
      
      public function ZombieAlertedState(param1:Zombie, param2:Vector3D, param3:Number = 1)
      {
         super();
         this._agent = param1;
         this._target = param2;
         this._alertTime = param3 * 1000;
         this._targetVector = new Vector3D();
         this.completed = new Signal(Zombie);
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            if(this._agent.actor != null && this._agent.actor.animatedAsset != null)
            {
               this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
            }
            this._agent = null;
         }
         this._target = null;
         this.completed.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         this._alertStartTime = param1;
         this._agent.navigator.stop();
         this._agent.actor.targetForward = null;
         this._alertAnim = this._agent.getAnimation("alert");
         if(this._alertAnim != null && this._agent.actor.animatedAsset.gotoAndPlay(this._alertAnim))
         {
            this._alertTime = Number.POSITIVE_INFINITY;
            this._agent.actor.animatedAsset.animationCompleted.addOnce(this.onAnimationComplete);
         }
         else
         {
            this._agent.actor.animatedAsset.gotoAndPlay(this._agent.getAnimation("idle"));
         }
         if(this._agent.alertNoise > 0)
         {
            this._agent.generateNoise(this._agent.alertNoise);
         }
         var _loc2_:String = this._agent.getSound("alert");
         if(_loc2_ != null && !Audio.sound.isPlaying(_loc2_))
         {
            this._agent.soundSource.play(_loc2_);
         }
         this._agent.switchToChase();
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         this._agent.actor.targetForward = null;
         this._agent.navigator.resume();
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         if(param2 - this._alertStartTime >= this._alertTime)
         {
            this.completed.dispatch(this._agent);
            return;
         }
         this._targetVector.x = this._target.x - this._agent.actor.transform.position.x;
         this._targetVector.y = this._target.y - this._agent.actor.transform.position.y;
         this._agent.actor.targetForward = this._targetVector;
      }
      
      private function onAnimationComplete(param1:String) : void
      {
         if(param1 == this._alertAnim)
         {
            this._alertTime = 0;
         }
      }
   }
}

