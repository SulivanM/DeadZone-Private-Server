package thelaststand.engine.map
{
   import com.deadreckoned.threshold.data.GraphEdge;
   
   public class NavEdge extends GraphEdge
   {
      
      public var cost:int = 0;
      
      public var flags:uint = 0;
      
      public var length:Number = 0;
      
      public var waypoints:Vector.<int>;
      
      public var traversalAreaId:uint = 0;
      
      public function NavEdge(param1:Cell)
      {
         super(param1);
      }
   }
}

