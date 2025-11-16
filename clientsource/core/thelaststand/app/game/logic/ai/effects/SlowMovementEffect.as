package thelaststand.app.game.logic.ai.effects
{
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   
   public class SlowMovementEffect extends DamageOverTimeEffect
   {
      
      private var _agent:AIActorAgent;
      
      private var _multiplier:Number = 0.25;
      
      public function SlowMovementEffect(param1:AIActorAgent, param2:Number, param3:Number = 0, param4:Number = 0)
      {
         super(param1,param3,param4);
         this._agent = param1;
         this._multiplier = param2;
      }
      
      override public function getMultiplierForAttribute(param1:String) : Number
      {
         return param1 == Attributes.MOVEMENT_SPEED ? this._multiplier : 0;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._agent = null;
      }
      
      override public function start(param1:Number) : void
      {
         super.start(param1);
         this._agent.navigator.velocity.x += this._agent.navigator.velocity.x * this._multiplier;
         this._agent.navigator.velocity.y += this._agent.navigator.velocity.y * this._multiplier;
         this._agent.updateMaxSpeed();
      }
      
      override public function end(param1:Number) : void
      {
         this._agent.updateMaxSpeed();
      }
   }
}

