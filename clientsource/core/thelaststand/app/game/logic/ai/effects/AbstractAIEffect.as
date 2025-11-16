package thelaststand.app.game.logic.ai.effects
{
   public class AbstractAIEffect implements IAIEffect
   {
      
      protected var _timeStart:Number;
      
      protected var _length:Number = -1;
      
      public var owner:*;
      
      public function AbstractAIEffect()
      {
         super();
      }
      
      public function get timeStart() : Number
      {
         return this._timeStart;
      }
      
      public function get length() : Number
      {
         return this._length;
      }
      
      public function getMultiplierForAttribute(param1:String) : Number
      {
         return 1;
      }
      
      public function dispose() : void
      {
      }
      
      public function start(param1:Number) : void
      {
         this._timeStart = param1;
      }
      
      public function end(param1:Number) : void
      {
      }
      
      public function update(param1:Number, param2:Number) : void
      {
      }
   }
}

