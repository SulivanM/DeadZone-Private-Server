package thelaststand.app.game.gui
{
   import org.osflash.signals.Signal;
   
   public interface IGUILayer
   {
      
      function get gui() : GameGUI;
      
      function set gui(param1:GameGUI) : void;
      
      function get transitionedOut() : Signal;
      
      function get name() : String;
      
      function set name(param1:String) : void;
      
      function dispose() : void;
      
      function transitionIn(param1:Number = 0) : void;
      
      function transitionOut(param1:Number = 0) : void;
      
      function setSize(param1:int, param2:int) : void;
      
      function get useFullWindow() : Boolean;
   }
}

