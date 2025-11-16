package alternativa.engine3d.utils
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   
   use namespace alternativa3d;
   
   public class Object3DUtils
   {
      
      private static const toRootTransform:Transform3D = new Transform3D();
      
      private static const fromRootTransform:Transform3D = new Transform3D();
      
      private static const RAD2DEG:Number = 180 / Math.PI;
      
      private static const DEG2RAD:Number = Math.PI / 180;
      
      public function Object3DUtils()
      {
         super();
      }
      
      public static function toRadians(param1:Number) : Number
      {
         return param1 * DEG2RAD;
      }
      
      public static function toDegrees(param1:Number) : Number
      {
         return param1 * RAD2DEG;
      }
      
      public static function calculateHierarchyBoundBox(param1:Object3D, param2:Object3D = null, param3:BoundBox = null) : BoundBox
      {
         var _loc4_:Object3D = null;
         var _loc5_:Transform3D = null;
         var _loc6_:Object3D = null;
         if(param3 == null)
         {
            param3 = new BoundBox();
         }
         if(param2 != null && param1 != param2)
         {
            _loc5_ = null;
            if(param1.alternativa3d::transformChanged)
            {
               param1.alternativa3d::composeTransforms();
            }
            toRootTransform.copy(param1.alternativa3d::transform);
            _loc6_ = param1;
            while(_loc6_.alternativa3d::_parent != null)
            {
               _loc6_ = _loc6_.alternativa3d::_parent;
               if(_loc6_.alternativa3d::transformChanged)
               {
                  _loc6_.alternativa3d::composeTransforms();
               }
               toRootTransform.append(_loc6_.alternativa3d::transform);
               if(_loc6_ == param2)
               {
                  _loc5_ = toRootTransform;
               }
            }
            _loc4_ = _loc6_;
            if(_loc5_ == null)
            {
               if(param2.alternativa3d::transformChanged)
               {
                  param2.alternativa3d::composeTransforms();
               }
               fromRootTransform.copy(param2.alternativa3d::inverseTransform);
               _loc6_ = param2;
               while(_loc6_.alternativa3d::_parent != null)
               {
                  _loc6_ = _loc6_.alternativa3d::_parent;
                  if(_loc6_.alternativa3d::transformChanged)
                  {
                     _loc6_.alternativa3d::composeTransforms();
                  }
                  fromRootTransform.prepend(_loc6_.alternativa3d::inverseTransform);
               }
               if(_loc4_ != _loc6_)
               {
                  throw new ArgumentError("Object and boundBoxSpace must be located in the same hierarchy.");
               }
               toRootTransform.append(fromRootTransform);
               _loc5_ = toRootTransform;
            }
            alternativa3d::updateBoundBoxHierarchically(param1,param3,_loc5_);
         }
         else
         {
            alternativa3d::updateBoundBoxHierarchically(param1,param3);
         }
         return param3;
      }
      
      alternativa3d static function updateBoundBoxHierarchically(param1:Object3D, param2:BoundBox, param3:Transform3D = null) : void
      {
         param1.alternativa3d::updateBoundBox(param2,param3);
         var _loc4_:Object3D = param1.alternativa3d::childrenList;
         while(_loc4_ != null)
         {
            if(_loc4_.alternativa3d::transformChanged)
            {
               _loc4_.alternativa3d::composeTransforms();
            }
            _loc4_.alternativa3d::localToCameraTransform.copy(_loc4_.alternativa3d::transform);
            if(param3 != null)
            {
               _loc4_.alternativa3d::localToCameraTransform.append(param3);
            }
            alternativa3d::updateBoundBoxHierarchically(_loc4_,param2,_loc4_.alternativa3d::localToCameraTransform);
            _loc4_ = _loc4_.alternativa3d::next;
         }
      }
   }
}

