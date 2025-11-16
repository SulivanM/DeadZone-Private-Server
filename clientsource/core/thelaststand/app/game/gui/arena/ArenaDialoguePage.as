package thelaststand.app.game.gui.arena
{
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.gui.UIComponent;
   
   public class ArenaDialoguePage extends UIComponent
   {
      
      protected var _session:ArenaSession;
      
      private var _width:int;
      
      private var _height:int;
      
      public function ArenaDialoguePage(param1:ArenaSession)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError("Session cannot be null");
         }
         this._session = param1;
      }
      
      override public function get width() : Number
      {
         return int(this._width);
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = int(param1);
         invalidate();
      }
      
      override public function get height() : Number
      {
         return int(this._height);
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = int(param1);
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}

