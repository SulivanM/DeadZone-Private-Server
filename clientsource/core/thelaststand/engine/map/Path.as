package thelaststand.engine.map
{
   import flash.geom.Vector3D;
   
   public class Path
   {
      
      public var found:Boolean = false;
      
      public var goalFound:Boolean = false;
      
      public var length:Number = 0;
      
      public var nodes:Vector.<int> = new Vector.<int>();
      
      public var numNodes:int = 0;
      
      public var waypoints:Vector.<int> = new Vector.<int>();
      
      public var numWaypoints:int = 0;
      
      public function Path()
      {
         super();
      }
      
      public function getNode(param1:int, param2:Vector3D = null) : Vector3D
      {
         var _loc3_:int = this.nodes[param1 * 3 + 1];
         var _loc4_:int = this.nodes[param1 * 3 + 2];
         param2 ||= new Vector3D();
         param2.setTo(_loc3_,_loc4_,0);
         return param2;
      }
      
      public function getWaypoint(param1:int, param2:Vector3D = null) : Vector3D
      {
         var _loc3_:int = this.waypoints[param1 * 3 + 1];
         var _loc4_:int = this.waypoints[param1 * 3 + 2];
         param2 ||= new Vector3D();
         param2.setTo(_loc3_,_loc4_,0);
         return param2;
      }
      
      public function getWaypointTraversalAreaId(param1:int) : int
      {
         return this.waypoints[param1 * 3];
      }
   }
}

