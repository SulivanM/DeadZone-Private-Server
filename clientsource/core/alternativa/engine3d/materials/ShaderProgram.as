package alternativa.engine3d.materials
{
   import alternativa.engine3d.materials.compiler.Linker;
   import flash.display3D.Context3D;
   import flash.display3D.Program3D;
   
   public class ShaderProgram
   {
      
      public var program:Program3D;
      
      public var vertexShader:Linker;
      
      public var fragmentShader:Linker;
      
      public var agalVersion:uint;
      
      public function ShaderProgram(param1:Linker, param2:Linker, param3:uint = 1)
      {
         super();
         this.vertexShader = param1;
         this.fragmentShader = param2;
         this.agalVersion = param3;
      }
      
      public function upload(param1:Context3D) : void
      {
         var context3D:Context3D = param1;
         if(this.program != null)
         {
            this.program.dispose();
         }
         if(this.vertexShader != null && this.fragmentShader != null)
         {
            this.vertexShader.link(this.agalVersion);
            this.fragmentShader.link(this.agalVersion);
            this.program = context3D.createProgram();
            try
            {
               this.program.upload(this.vertexShader.data,this.fragmentShader.data);
            }
            catch(e:Error)
            {
               throw e;
            }
         }
         else
         {
            this.program = null;
         }
      }
      
      public function dispose() : void
      {
         if(this.program != null)
         {
            this.program.dispose();
            this.program = null;
         }
      }
   }
}

