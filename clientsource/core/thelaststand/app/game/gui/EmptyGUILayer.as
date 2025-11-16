package thelaststand.app.game.gui
{
   import flash.display.Sprite;
   import org.osflash.signals.Signal;
   
   public class EmptyGUILayer extends Sprite implements IGUILayer
   {
      
      private var _gui:GameGUI;
      
      public function EmptyGUILayer()
      {
         super();
         mouseEnabled = false;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._gui = null;
      }
      
      public function setSize(param1:int, param2:int) : void
      {
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
      }
      
      public function get transitionedOut() : Signal
      {
         return null;
      }
      
      public function get useFullWindow() : Boolean
      {
         return true;
      }
      
      public function get gui() : GameGUI
      {
         return this._gui;
      }
      
      public function set gui(param1:GameGUI) : void
      {
         this._gui = param1;
      }
   }
}

