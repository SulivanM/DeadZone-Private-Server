package thelaststand.app.game.logic.data
{
   import flash.geom.Vector3D;
   
   public class ThrowTrajectoryData
   {
      
      public static const ROLL_DISTANCE_THRESHOLD:Number = 8 * 100;
      
      public var valid:Boolean = false;
      
      public var obstructed:Boolean = false;
      
      public var origin:Vector3D;
      
      public var target:Vector3D;
      
      public var maxThrowRange:Number = 0;
      
      public var minThrowRange:Number = 0;
      
      public var globalOrigin:Vector3D;
      
      public var globalTarget:Vector3D;
      
      public var localOrigin:Vector3D;
      
      public var localTarget:Vector3D;
      
      public var direction:Vector3D;
      
      public function ThrowTrajectoryData()
      {
         super();
         this.origin = new Vector3D();
         this.target = new Vector3D();
         this.direction = new Vector3D();
         this.localOrigin = new Vector3D();
         this.localTarget = new Vector3D();
         this.globalOrigin = new Vector3D();
         this.globalTarget = new Vector3D();
      }
   }
}

