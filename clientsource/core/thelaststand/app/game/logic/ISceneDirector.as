package thelaststand.app.game.logic
{
   public interface ISceneDirector
   {
      
      function dispose() : void;
      
      function start(param1:Number, ... rest) : void;
      
      function end() : void;
      
      function update(param1:Number, param2:Number) : void;
   }
}

