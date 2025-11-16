package thelaststand.engine.map
{
   import flash.geom.Rectangle;
   
   public class PathfinderOptions
   {
      
      public var allowClosestNodeToGoal:Boolean;
      
      public var trimToFirstTraversalArea:Boolean;
      
      public var nodeFlagMask:uint;
      
      public var edgeFlagMask:uint;
      
      public var maxCost:int;
      
      public var bounds:Rectangle;
      
      public var onStarted:Function;
      
      public function PathfinderOptions()
      {
         super();
         this.reset();
      }
      
      public function reset() : void
      {
         this.allowClosestNodeToGoal = false;
         this.trimToFirstTraversalArea = false;
         this.nodeFlagMask = CellFlag.ALL_NOT_DISABLED;
         this.edgeFlagMask = NavEdgeFlag.ALL_NOT_DISABLED;
         this.maxCost = int.MAX_VALUE;
         this.bounds = null;
         this.onStarted = null;
      }
   }
}

