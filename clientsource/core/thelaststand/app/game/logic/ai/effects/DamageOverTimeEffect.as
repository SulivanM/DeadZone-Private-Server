package thelaststand.app.game.logic.ai.effects
{
   import thelaststand.app.game.logic.ai.AIAgent;
   
   public class DamageOverTimeEffect extends AbstractAIEffect
   {
      
      protected var _damageType:uint = 0;
      
      protected var _damageTickMultiplier:Number = 1;
      
      protected var _damage:Number;
      
      protected var _time:Number;
      
      protected var _sound:String;
      
      private var _nextTime:Number;
      
      private var _agent:AIAgent;
      
      public function DamageOverTimeEffect(param1:AIAgent, param2:Number = 0, param3:Number = 0)
      {
         super();
         this._agent = param1;
         this._damage = param2;
         this._time = param3;
      }
      
      override public function dispose() : void
      {
         this._agent = null;
      }
      
      override public function start(param1:Number) : void
      {
         super.start(param1);
         this._nextTime = param1 + this._time * 1000;
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         if(param2 < this._nextTime || this._damage <= 0)
         {
            return;
         }
         this._agent.receiveDamage(this._damage,this._damageType,this);
         if(this._sound != null)
         {
            this._agent.soundSource.play(this._sound);
         }
         this._damage *= this._damageTickMultiplier;
         this._nextTime += this._time * 1000;
      }
   }
}

