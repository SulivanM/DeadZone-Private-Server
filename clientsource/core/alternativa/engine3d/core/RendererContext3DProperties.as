package alternativa.engine3d.core
{
   import alternativa.engine3d.materials.ShaderProgram;
   import alternativa.engine3d.resources.Geometry;
   import flash.display3D.Program3D;
   import flash.utils.Dictionary;
   
   public class RendererContext3DProperties
   {
      
      public var isConstrained:Boolean = false;
      
      public var backBufferWidth:int = -1;
      
      public var backBufferHeight:int = -1;
      
      public var backBufferAntiAlias:int = -1;
      
      public var usedBuffers:uint = 0;
      
      public var usedTextures:uint = 0;
      
      public var program:Program3D;
      
      public var culling:String;
      
      public var blendSource:String;
      
      public var blendDestination:String;
      
      public var drawDistancePrograms:Dictionary = new Dictionary();
      
      public var drawColoredRectProgram:ShaderProgram;
      
      public var drawRectGeometry:Geometry;
      
      public function RendererContext3DProperties()
      {
         super();
      }
   }
}

