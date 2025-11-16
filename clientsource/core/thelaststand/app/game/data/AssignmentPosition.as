package thelaststand.app.game.data
{
   import thelaststand.engine.map.Cell;
   
   public class AssignmentPosition
   {
      
      private var _cell:Cell;
      
      private var _height:Number = 0;
      
      private var _locked:Boolean = false;
      
      public function AssignmentPosition(param1:Cell, param2:Number = 0, param3:Boolean = false)
      {
         super();
         this._cell = param1;
         this._height = param2;
         this._locked = param3;
      }
      
      public function get cell() : Cell
      {
         return this._cell;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function get locked() : Boolean
      {
         return this._locked;
      }
   }
}

