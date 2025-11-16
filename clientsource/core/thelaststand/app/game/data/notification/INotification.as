package thelaststand.app.game.data.notification
{
   import org.osflash.signals.Signal;
   
   public interface INotification
   {
      
      function get active() : Boolean;
      
      function set active(param1:Boolean) : void;
      
      function get closed() : Signal;
      
      function get data() : *;
      
      function get type() : String;
      
      function open() : void;
   }
}

