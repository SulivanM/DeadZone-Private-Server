package de.polygonal.ds
{
   public interface Collection
   {
      
      function contains(param1:*) : Boolean;
      
      function clear() : void;
      
      function getIterator() : Iterator;
      
      function get size() : int;
      
      function isEmpty() : Boolean;
      
      function toArray() : Array;
   }
}

