package alternativa.engine3d.materials
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class Material
   {
      
      alternativa3d static const _projectProcedure:Procedure = getPojectProcedure();
      
      public var name:String;
      
      public function Material()
      {
         super();
      }
      
      private static function getPojectProcedure() : Procedure
      {
         var _loc1_:Procedure = new Procedure(["m44 o0, i0, c0"],"projectProcedure");
         _loc1_.assignVariableName(VariableType.CONSTANT,0,"cProjMatrix",4);
         return _loc1_;
      }
      
      alternativa3d function appendPositionTransformProcedure(param1:Procedure, param2:Linker) : String
      {
         param2.declareVariable("tTransformedPosition");
         param2.addProcedure(param1);
         param2.setInputParams(param1,"aPosition");
         param2.setOutputParams(param1,"tTransformedPosition");
         return "tTransformedPosition";
      }
      
      public function getResources(param1:Class = null) : Vector.<Resource>
      {
         var _loc5_:* = undefined;
         var _loc2_:Vector.<Resource> = new Vector.<Resource>();
         var _loc3_:Dictionary = new Dictionary();
         var _loc4_:int = 0;
         this.alternativa3d::fillResources(_loc3_,param1);
         for(_loc5_ in _loc3_)
         {
            var _loc8_:*;
            _loc2_[_loc8_ = _loc4_++] = _loc5_ as Resource;
         }
         return _loc2_;
      }
      
      alternativa3d function fillResources(param1:Dictionary, param2:Class) : void
      {
      }
      
      alternativa3d function collectDraws(param1:Camera3D, param2:Surface, param3:Geometry, param4:Vector.<Light3D>, param5:int, param6:Boolean, param7:int = -1) : void
      {
      }
      
      public function clone() : Material
      {
         var _loc1_:Material = new Material();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      protected function clonePropertiesFrom(param1:Material) : void
      {
         this.name = param1.name;
      }
   }
}

