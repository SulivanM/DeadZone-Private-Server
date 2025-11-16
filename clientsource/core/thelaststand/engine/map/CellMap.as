package thelaststand.engine.map
{
   import com.deadreckoned.threshold.core.IDisposable;
   import com.deadreckoned.threshold.data.Graph;
   import com.deadreckoned.threshold.ns.threshold;
   import thelaststand.engine.ns.tls;
   
   use namespace tls;
   use namespace threshold;
   
   public class CellMap extends Graph implements IDisposable
   {
      
      private static var _graphConnections:Array = [1,-1,1,0,1,1,0,1];
      
      private var _width:int;
      
      private var _height:int;
      
      tls var _cells:Vector.<Cell>;
      
      public function CellMap()
      {
         super();
      }
      
      public function get width() : int
      {
         return this._width;
      }
      
      public function get height() : int
      {
         return this._height;
      }
      
      public function dispose() : void
      {
         this.tls::_cells = null;
         this._width = this._height = 0;
      }
      
      public function getCell(param1:int, param2:int) : Cell
      {
         if(param1 < 0 || param2 < 0 || param1 >= this._width || param2 >= this._height)
         {
            return null;
         }
         return this.tls::_cells[param1 + param2 * this._width];
      }
      
      public function getCellAt(param1:int) : Cell
      {
         return this.tls::_cells[param1];
      }
      
      public function getCellIndex(param1:int, param2:int) : int
      {
         return param1 + param2 * this._width;
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Cell = null;
         var _loc8_:Cell = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Cell = null;
         var _loc14_:Number = NaN;
         var _loc15_:NavEdge = null;
         this._width = param1;
         this._height = param2;
         var _loc3_:int = this._width * this._height;
         this.tls::_cells = new Vector.<Cell>(_loc3_,true);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc7_ = new Cell(int(_loc4_ % this._width),int(_loc4_ / this._width));
            this.tls::_cells[_loc4_] = _loc7_;
            add(_loc7_);
            _loc4_++;
         }
         var _loc6_:int = int(_graphConnections.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc8_ = this.tls::_cells[_loc4_];
            if(_loc8_.x == 28 && _loc8_.y == 2)
            {
            }
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               _loc9_ = int(_graphConnections[_loc5_ + 0]);
               _loc10_ = int(_graphConnections[_loc5_ + 1]);
               _loc11_ = _loc8_.x + _loc9_;
               _loc12_ = _loc8_.y + _loc10_;
               if(!(_loc11_ < 0 || _loc12_ < 0 || _loc11_ >= this._width || _loc12_ >= this._height))
               {
                  _loc13_ = this.tls::_cells[_loc11_ + _loc12_ * this._width];
                  _loc14_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
                  _loc15_ = NavEdge(_loc8_.threshold::addEdge(_loc13_,NavEdge));
                  _loc15_.length = _loc14_;
                  _loc15_ = NavEdge(_loc13_.threshold::addEdge(_loc8_,NavEdge));
                  _loc15_.length = _loc14_;
               }
               _loc5_ += 2;
            }
            _loc4_++;
         }
      }
   }
}

