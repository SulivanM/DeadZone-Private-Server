package thelaststand.app.game.logic.ai.states
{
   import org.osflash.signals.Signal;
   
   public interface IAITrapState extends IAIState
   {
      
      function get triggered() : Signal;
      
      function trigger() : void;
   }
}

