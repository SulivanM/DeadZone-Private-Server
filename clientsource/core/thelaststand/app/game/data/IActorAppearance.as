package thelaststand.app.game.data
{
   import org.osflash.signals.Signal;
   
   public interface IActorAppearance
   {
      
      function get changed() : Signal;
      
      function get data() : Vector.<AttireData>;
      
      function clear() : void;
      
      function getResourceURIs() : Array;
      
      function getOverlays(param1:String) : Array;
   }
}

