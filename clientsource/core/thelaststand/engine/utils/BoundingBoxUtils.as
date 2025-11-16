package thelaststand.engine.utils
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.utils.Object3DUtils;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class BoundingBoxUtils
   {
      
      private static var _tmpTrans:Transform3D = new Transform3D();
      
      private static var _tmpVec1:Vector3D = new Vector3D();
      
      private static var _tmpVec2:Vector3D = new Vector3D();
      
      public function BoundingBoxUtils()
      {
         super();
         throw new Error("BoundingBoxUtils cannot be directly instantiated.");
      }
      
      public static function calcBoundingBox(param1:Object3D) : BoundBox
      {
         _tmpTrans.compose(0,0,0,param1.rotationX,param1.rotationY,param1.rotationZ,param1.scaleX,param1.scaleY,param1.scaleZ);
         param1.calculateBoundBox();
         param1.alternativa3d::updateBoundBox(param1.boundBox,_tmpTrans);
         return param1.boundBox;
      }
      
      public static function transformBounds(param1:Object3D, param2:Matrix3D, param3:BoundBox = null) : BoundBox
      {
         param3 ||= new BoundBox();
         param3.reset();
         Object3DUtils.calculateHierarchyBoundBox(param1,param1,param3);
         _tmpVec1.setTo(param3.minX,param3.minY,param3.minZ);
         _tmpVec2.setTo(param3.maxX,param3.maxY,param3.maxZ);
         _tmpVec1 = param2.deltaTransformVector(_tmpVec1);
         _tmpVec2 = param2.deltaTransformVector(_tmpVec2);
         param3.minX = Math.min(_tmpVec1.x,_tmpVec2.x);
         param3.minY = Math.min(_tmpVec1.y,_tmpVec2.y);
         param3.minZ = Math.min(_tmpVec1.z,_tmpVec2.z);
         param3.maxX = Math.max(_tmpVec1.x,_tmpVec2.x);
         param3.maxY = Math.max(_tmpVec1.y,_tmpVec2.y);
         param3.maxZ = Math.max(_tmpVec1.z,_tmpVec2.z);
         return param3;
      }
      
      public static function getLengthOfAxis(param1:Object3D, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!param1.boundBox)
         {
            calcBoundingBox(param1);
         }
         switch(param2)
         {
            case "x":
            case "X":
               _loc3_ = param1.boundBox.minX;
               _loc4_ = param1.boundBox.maxX;
               break;
            case "y":
            case "Y":
               _loc3_ = param1.boundBox.minY;
               _loc4_ = param1.boundBox.maxY;
               break;
            case "z":
            case "Z":
               _loc3_ = param1.boundBox.minZ;
               _loc4_ = param1.boundBox.maxZ;
         }
         if(_loc3_ < 0)
         {
            _loc3_ = -_loc3_;
         }
         if(_loc4_ < 0)
         {
            _loc4_ = -_loc4_;
         }
         return _loc3_ + _loc4_;
      }
   }
}

