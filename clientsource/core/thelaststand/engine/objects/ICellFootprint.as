package thelaststand.engine.objects
{
   import flash.geom.Rectangle;
   import thelaststand.engine.map.Cell;
   
   public interface ICellFootprint
   {
      
      function getFootprintRect(param1:int, param2:int, param3:Rectangle = null) : Rectangle;
      
      function getFootprintBufferRect(param1:int, param2:int, param3:Rectangle = null) : Rectangle;
      
      function getBufferCells(param1:Vector.<Cell> = null) : Vector.<Cell>;
   }
}

