package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.collisions.EllipsoidCollider;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.RayIntersectionData;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.resources.Geometry;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class Mesh extends Object3D
   {
      
      public var geometry:Geometry;
      
      alternativa3d var _surfaces:Vector.<Surface> = new Vector.<Surface>();
      
      alternativa3d var _surfacesLength:int = 0;
      
      public function Mesh()
      {
         super();
      }
      
      override public function intersectRay(param1:Vector3D, param2:Vector3D) : RayIntersectionData
      {
         var _loc4_:RayIntersectionData = null;
         var _loc5_:Number = NaN;
         var _loc6_:Surface = null;
         var _loc7_:RayIntersectionData = null;
         var _loc3_:RayIntersectionData = super.intersectRay(param1,param2);
         if(this.geometry != null && (boundBox == null || boundBox.intersectRay(param1,param2)))
         {
            _loc5_ = 1e+22;
            for each(_loc6_ in this.alternativa3d::_surfaces)
            {
               _loc7_ = this.geometry.alternativa3d::intersectRay(param1,param2,_loc6_.indexBegin,_loc6_.numTriangles);
               if(_loc7_ != null && _loc7_.time < _loc5_)
               {
                  _loc4_ = _loc7_;
                  _loc4_.object = this;
                  _loc4_.surface = _loc6_;
                  _loc5_ = _loc7_.time;
               }
            }
         }
         if(_loc3_ != null)
         {
            if(_loc4_ != null)
            {
               return _loc3_.time < _loc4_.time ? _loc3_ : _loc4_;
            }
            return _loc3_;
         }
         return _loc4_;
      }
      
      public function addSurface(param1:Material, param2:uint, param3:uint) : Surface
      {
         var _loc4_:Surface = new Surface();
         _loc4_.alternativa3d::object = this;
         _loc4_.material = param1;
         _loc4_.indexBegin = param2;
         _loc4_.numTriangles = param3;
         var _loc5_:*;
         this.alternativa3d::_surfaces[_loc5_ = this.alternativa3d::_surfacesLength++] = _loc4_;
         return _loc4_;
      }
      
      public function getSurface(param1:int) : Surface
      {
         return this.alternativa3d::_surfaces[param1];
      }
      
      public function get numSurfaces() : int
      {
         return this.alternativa3d::_surfacesLength;
      }
      
      public function setMaterialToAllSurfaces(param1:Material) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.alternativa3d::_surfaces.length)
         {
            this.alternativa3d::_surfaces[_loc2_].material = param1;
            _loc2_++;
         }
      }
      
      override alternativa3d function get useLights() : Boolean
      {
         return true;
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         if(this.geometry != null)
         {
            this.geometry.alternativa3d::updateBoundBox(param1,param2);
         }
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Boolean = false, param3:Class = null) : void
      {
         var _loc5_:Surface = null;
         if(this.geometry != null && (param3 == null || this.geometry is param3))
         {
            param1[this.geometry] = true;
         }
         var _loc4_:int = 0;
         while(_loc4_ < this.alternativa3d::_surfacesLength)
         {
            _loc5_ = this.alternativa3d::_surfaces[_loc4_];
            if(_loc5_.material != null)
            {
               _loc5_.material.alternativa3d::fillResources(param1,param3);
            }
            _loc4_++;
         }
         super.alternativa3d::fillResources(param1,param2,param3);
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc6_:Surface = null;
         var _loc5_:int = 0;
         while(_loc5_ < this.alternativa3d::_surfacesLength)
         {
            _loc6_ = this.alternativa3d::_surfaces[_loc5_];
            if(_loc6_.material != null)
            {
               _loc6_.material.alternativa3d::collectDraws(param1,_loc6_,this.geometry,param2,param3,param4,-1);
            }
            if(alternativa3d::listening)
            {
               param1.view.alternativa3d::addSurfaceToMouseEvents(_loc6_,this.geometry,alternativa3d::transformProcedure);
            }
            _loc5_++;
         }
      }
      
      override alternativa3d function collectGeometry(param1:EllipsoidCollider, param2:Dictionary) : void
      {
         param1.alternativa3d::geometries.push(this.geometry);
         param1.alternativa3d::transforms.push(alternativa3d::localToGlobalTransform);
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Mesh = new Mesh();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         var _loc3_:Surface = null;
         super.clonePropertiesFrom(param1);
         var _loc2_:Mesh = param1 as Mesh;
         this.geometry = _loc2_.geometry;
         this.alternativa3d::_surfacesLength = 0;
         this.alternativa3d::_surfaces.length = 0;
         for each(_loc3_ in _loc2_.alternativa3d::_surfaces)
         {
            this.addSurface(_loc3_.material,_loc3_.indexBegin,_loc3_.numTriangles);
         }
      }
   }
}

