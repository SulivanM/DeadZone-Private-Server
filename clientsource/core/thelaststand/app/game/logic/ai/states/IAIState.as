package thelaststand.app.game.logic.ai.states
{
   public interface IAIState
   {
      
      function dispose() : void;
      
      function enter(param1:Number) : void;
      
      function exit(param1:Number) : void;
      
      function update(param1:Number, param2:Number) : void;
   }
}

