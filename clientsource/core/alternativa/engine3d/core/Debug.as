package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.objects.WireFrame;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class Debug
   {
      
      public static const BOUNDS:int = 8;
      
      public static const CONTENT:int = 16;
      
      private static var boundWires:Dictionary = new Dictionary();
      
      public function Debug()
      {
         super();
      }
      
      private static function createBoundWire() : WireFrame
      {
         var _loc1_:WireFrame = new WireFrame();
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(-0.5,-0.5,-0.5,0.5,-0.5,-0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(0.5,-0.5,-0.5,0.5,0.5,-0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(0.5,0.5,-0.5,-0.5,0.5,-0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(-0.5,0.5,-0.5,-0.5,-0.5,-0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(-0.5,-0.5,0.5,0.5,-0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(0.5,-0.5,0.5,0.5,0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(0.5,0.5,0.5,-0.5,0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(-0.5,0.5,0.5,-0.5,-0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(-0.5,-0.5,-0.5,-0.5,-0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(0.5,-0.5,-0.5,0.5,-0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(0.5,0.5,-0.5,0.5,0.5,0.5);
         _loc1_.alternativa3d::geometry.alternativa3d::addLine(-0.5,0.5,-0.5,-0.5,0.5,0.5);
         return _loc1_;
      }
      
      alternativa3d static function drawBoundBox(param1:Camera3D, param2:BoundBox, param3:Transform3D, param4:int = -1) : void
      {
         var _loc5_:WireFrame = boundWires[param1.alternativa3d::context3D];
         if(_loc5_ == null)
         {
            _loc5_ = createBoundWire();
            boundWires[param1.alternativa3d::context3D] = _loc5_;
            _loc5_.alternativa3d::geometry.upload(param1.alternativa3d::context3D);
         }
         _loc5_.color = param4 >= 0 ? uint(param4) : 10092288;
         _loc5_.thickness = 1;
         _loc5_.alternativa3d::transform.compose((param2.minX + param2.maxX) * 0.5,(param2.minY + param2.maxY) * 0.5,(param2.minZ + param2.maxZ) * 0.5,0,0,0,param2.maxX - param2.minX,param2.maxY - param2.minY,param2.maxZ - param2.minZ);
         _loc5_.alternativa3d::localToCameraTransform.combine(param3,_loc5_.alternativa3d::transform);
         _loc5_.alternativa3d::collectDraws(param1,null,0,false);
      }
   }
}

