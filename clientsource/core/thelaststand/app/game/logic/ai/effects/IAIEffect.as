package thelaststand.app.game.logic.ai.effects
{
   public interface IAIEffect
   {
      
      function get timeStart() : Number;
      
      function get length() : Number;
      
      function dispose() : void;
      
      function getMultiplierForAttribute(param1:String) : Number;
      
      function start(param1:Number) : void;
      
      function end(param1:Number) : void;
      
      function update(param1:Number, param2:Number) : void;
   }
}

