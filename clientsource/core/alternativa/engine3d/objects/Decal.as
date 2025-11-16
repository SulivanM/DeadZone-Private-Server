package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   
   use namespace alternativa3d;
   
   public class Decal extends Mesh
   {
      
      public static var zBufferPrecision:int = 16;
      
      private static var transformProcedureStatic:Procedure = new Procedure(["dp4 t0.z, i0, c0","div t0.x, c2.z, t0.z","sub t0.x, t0.x, c2.w","div t0.y, c2.z, t0.x","div t0.w, t0.y, t0.z","sub t0.xyz, i0.xyz, c1.xyz","mul t0.xyz, t0.xyz, t0.w","add o0.xyz, c1.xyz, t0.xyz","mov o0.w, i0.w","#c0=cTrm","#c1=cCam","#c2=cProj"],"DecalTransformProcedure");
      
      public function Decal()
      {
         super();
         alternativa3d::transformProcedure = transformProcedureStatic;
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc6_:Surface = null;
         var _loc5_:int = 0;
         while(_loc5_ < alternativa3d::_surfacesLength)
         {
            _loc6_ = alternativa3d::_surfaces[_loc5_];
            if(_loc6_.material != null)
            {
               _loc6_.material.alternativa3d::collectDraws(param1,_loc6_,geometry,param2,param3,param4,Renderer.DECALS);
            }
            if(alternativa3d::listening)
            {
               param1.view.alternativa3d::addSurfaceToMouseEvents(_loc6_,geometry,alternativa3d::transformProcedure);
            }
            _loc5_++;
         }
      }
      
      override alternativa3d function setTransformConstants(param1:DrawUnit, param2:Surface, param3:Linker, param4:Camera3D) : void
      {
         param1.alternativa3d::setVertexConstantsFromNumbers(param3.getVariableIndex("cProj"),0,0,param4.alternativa3d::m14,1 / (1 << zBufferPrecision));
         param1.alternativa3d::setVertexConstantsFromNumbers(param3.getVariableIndex("cCam"),alternativa3d::cameraToLocalTransform.d,alternativa3d::cameraToLocalTransform.h,alternativa3d::cameraToLocalTransform.l);
         param1.alternativa3d::setVertexConstantsFromNumbers(param3.getVariableIndex("cTrm"),alternativa3d::localToCameraTransform.i,alternativa3d::localToCameraTransform.j,alternativa3d::localToCameraTransform.k,alternativa3d::localToCameraTransform.l);
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Decal = new Decal();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         super.clonePropertiesFrom(param1);
      }
   }
}

