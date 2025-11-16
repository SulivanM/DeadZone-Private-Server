package thelaststand.engine.map
{
   public class TraversalArea
   {
      
      public var id:uint;
      
      public var x:int;
      
      public var y:int;
      
      public var width:int;
      
      public var height:int;
      
      public var nodes:Vector.<Cell> = new Vector.<Cell>();
      
      public var edges:Vector.<NavEdge> = new Vector.<NavEdge>();
      
      public var data:*;
      
      public function TraversalArea()
      {
         super();
      }
   }
}

