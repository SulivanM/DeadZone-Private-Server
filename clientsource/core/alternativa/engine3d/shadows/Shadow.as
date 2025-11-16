package alternativa.engine3d.shadows
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.objects.Surface;
   
   use namespace alternativa3d;
   
   public class Shadow
   {
      
      alternativa3d static const NONE_MODE:int = 0;
      
      alternativa3d static const SIMPLE_MODE:int = 1;
      
      alternativa3d static const PCF_MODE:int = 2;
      
      public var debug:Boolean = false;
      
      alternativa3d var type:int = 0;
      
      alternativa3d var _light:Light3D;
      
      alternativa3d var vertexShadowProcedure:Procedure;
      
      alternativa3d var fragmentShadowProcedure:Procedure;
      
      public function Shadow()
      {
         super();
      }
      
      alternativa3d function process(param1:Camera3D) : void
      {
      }
      
      alternativa3d function setup(param1:DrawUnit, param2:Linker, param3:Linker, param4:Surface) : void
      {
      }
   }
}

