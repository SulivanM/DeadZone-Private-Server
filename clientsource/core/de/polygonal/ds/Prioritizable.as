package de.polygonal.ds
{
   public class Prioritizable
   {
      
      public var priority:int;
      
      public function Prioritizable(param1:int = -1)
      {
         super();
         this.priority = param1;
      }
      
      public function toString() : String
      {
         return "[Prioritizable, priority=" + this.priority + "]";
      }
   }
}

