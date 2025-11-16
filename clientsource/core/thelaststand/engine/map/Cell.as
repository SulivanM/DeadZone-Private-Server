package thelaststand.engine.map
{
   import com.deadreckoned.threshold.data.GraphNode;
   
   public class Cell extends GraphNode
   {
      
      public var x:int;
      
      public var y:int;
      
      public var cost:int = 1;
      
      public var baseCost:int = 1;
      
      public var penaltyCost:int = 0;
      
      public var bufferCount:int = 0;
      
      public var flags:uint = 0;
      
      public var traversalAreaId:uint = 0;
      
      public function Cell(param1:int, param2:int)
      {
         super();
         this.x = param1;
         this.y = param2;
      }
   }
}

