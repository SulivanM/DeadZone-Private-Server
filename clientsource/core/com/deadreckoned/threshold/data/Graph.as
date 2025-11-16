package com.deadreckoned.threshold.data
{
   import com.deadreckoned.threshold.ns.threshold;
   
   use namespace threshold;
   
   public class Graph
   {
      
      private var _nodeList:GraphNode;
      
      private var _size:int;
      
      public function Graph()
      {
         super();
      }
      
      public function get nodeList() : GraphNode
      {
         return this._nodeList;
      }
      
      public function get size() : int
      {
         return this._size;
      }
      
      public function add(param1:GraphNode) : GraphNode
      {
         ++this._size;
         param1.next = this._nodeList;
         if(param1.next != null)
         {
            param1.next.prev = param1;
         }
         this._nodeList = param1;
         return param1;
      }
      
      public function remove(param1:GraphNode) : GraphNode
      {
         this.unlink(param1);
         --this._size;
         if(param1.prev != null)
         {
            param1.prev.next = param1.next;
         }
         if(param1.next != null)
         {
            param1.next.prev = param1.prev;
         }
         if(this._nodeList == param1)
         {
            this._nodeList = param1.next;
         }
         return param1;
      }
      
      public function clear() : void
      {
         var _loc2_:GraphNode = null;
         var _loc3_:GraphEdge = null;
         var _loc4_:GraphEdge = null;
         var _loc1_:GraphNode = this._nodeList;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_.next;
            _loc3_ = _loc1_.edgeList;
            while(_loc3_ != null)
            {
               _loc4_ = _loc3_.next;
               _loc3_.clear();
               _loc3_ = _loc4_;
            }
            _loc1_.clear();
            _loc1_ = _loc2_;
         }
         this._nodeList = null;
         this._size = 0;
      }
      
      public function contains(param1:GraphNode) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:GraphNode = this._nodeList;
         while(_loc3_ != null)
         {
            if(_loc3_ == param1)
            {
               return true;
            }
            param1 = _loc3_;
         }
         return false;
      }
      
      public function addEdge(param1:GraphNode, param2:GraphNode, param3:Boolean = false) : void
      {
         var _loc5_:GraphNode = null;
         var _loc4_:GraphNode = this._nodeList;
         while(_loc4_ != null)
         {
            if(_loc4_ == param1)
            {
               _loc5_ = _loc4_;
               _loc4_ = this._nodeList;
               while(_loc4_ != null)
               {
                  if(_loc4_ == param2)
                  {
                     _loc5_.threshold::addEdge(_loc4_);
                     _loc4_.threshold::addEdge(_loc5_);
                     break;
                  }
                  _loc4_ = _loc4_.next;
               }
               break;
            }
            _loc4_ = _loc4_.next;
         }
      }
      
      public function unlink(param1:GraphNode) : GraphNode
      {
         var _loc2_:GraphEdge = null;
         var _loc4_:GraphNode = null;
         var _loc5_:GraphEdge = null;
         var _loc3_:GraphEdge = param1.edgeList;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.node;
            _loc5_ = _loc4_.edgeList;
            while(_loc5_ != null)
            {
               _loc2_ = _loc5_.next;
               if(_loc5_.node == param1)
               {
                  if(_loc5_.prev != null)
                  {
                     _loc5_.prev.next = _loc2_;
                  }
                  if(_loc2_ != null)
                  {
                     _loc2_.prev = _loc5_.prev;
                  }
                  if(_loc4_.edgeList == _loc5_)
                  {
                     _loc4_.edgeList = _loc2_;
                  }
                  _loc5_.clear();
               }
               _loc5_ = _loc2_;
            }
            _loc2_ = _loc3_.next;
            if(_loc3_.prev != null)
            {
               _loc3_.prev.next = _loc2_;
            }
            if(_loc2_ != null)
            {
               _loc2_.prev = _loc3_.prev;
            }
            if(param1.edgeList == _loc3_)
            {
               param1.edgeList = _loc2_;
            }
            _loc3_.clear();
            _loc3_ = _loc2_;
         }
         param1.edgeList = null;
         return param1;
      }
      
      public function toVector() : Vector.<GraphNode>
      {
         var _loc1_:Vector.<GraphNode> = new Vector.<GraphNode>();
         var _loc2_:GraphNode = this._nodeList;
         while(_loc2_ != null)
         {
            _loc1_.push(_loc2_);
            _loc2_ = _loc2_.next;
         }
         return _loc1_;
      }
   }
}

