package com.deadreckoned.threshold.navigation.rvo
{
   import flash.geom.Vector3D;
   
   public class Obstacle
   {
      
      public var point:Vector3D;
      
      public var unitDir:Vector3D;
      
      public var isConvex:Boolean;
      
      public var id:int;
      
      public var prev:Obstacle;
      
      public var next:Obstacle;
      
      public function Obstacle()
      {
         super();
         throw new Error("Not implemented yet.");
      }
   }
}

