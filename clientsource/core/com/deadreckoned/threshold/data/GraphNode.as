package com.deadreckoned.threshold.data
{
   import com.deadreckoned.threshold.ns.threshold;
   
   use namespace threshold;
   
   public class GraphNode
   {
      
      public var next:GraphNode;
      
      public var prev:GraphNode;
      
      public var edgeList:GraphEdge;
      
      public function GraphNode()
      {
         super();
      }
      
      public function clear() : void
      {
         this.next = null;
         this.prev = null;
         this.edgeList = null;
      }
      
      threshold function addEdge(param1:GraphNode, param2:Class = null) : GraphEdge
      {
         var _loc3_:GraphEdge = new (param2 || GraphEdge)(param1);
         _loc3_.next = this.edgeList;
         if(this.edgeList != null)
         {
            this.edgeList.prev = _loc3_;
         }
         this.edgeList = _loc3_;
         return _loc3_;
      }
      
      threshold function removeEdge(param1:GraphNode) : Boolean
      {
         var _loc2_:GraphEdge = this.threshold::getEdge(param1);
         if(_loc2_ != null)
         {
            if(_loc2_.prev != null)
            {
               _loc2_.prev.next = _loc2_.next;
            }
            if(_loc2_.next != null)
            {
               _loc2_.next.prev = _loc2_.prev;
            }
            if(this.edgeList == _loc2_)
            {
               this.edgeList = _loc2_.next;
            }
            return true;
         }
         return false;
      }
      
      threshold function getEdge(param1:GraphNode) : GraphEdge
      {
         var _loc2_:Boolean = false;
         var _loc3_:GraphEdge = this.edgeList;
         while(_loc3_ != null)
         {
            if(_loc3_.node == param1)
            {
               _loc2_ = true;
               break;
            }
            _loc3_ = _loc3_.next;
         }
         return _loc2_ ? _loc3_ : null;
      }
   }
}

