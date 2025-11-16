package com.deadreckoned.threshold.data
{
   public class GraphEdge
   {
      
      public var node:GraphNode;
      
      public var next:GraphEdge;
      
      public var prev:GraphEdge;
      
      public function GraphEdge(param1:GraphNode)
      {
         super();
         this.node = param1;
      }
      
      public function clear() : void
      {
         this.node = null;
         this.next = this.prev = null;
      }
   }
}

