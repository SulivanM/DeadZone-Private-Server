package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import flash.display3D.Context3DVertexBufferFormat;
   
   use namespace alternativa3d;
   
   public class VertexAttributes
   {
      
      public static const POSITION:uint = 1;
      
      public static const NORMAL:uint = 2;
      
      public static const TANGENT4:uint = 3;
      
      public static const JOINTS:Vector.<uint> = Vector.<uint>([4,5,6,7]);
      
      public static const TEXCOORDS:Vector.<uint> = Vector.<uint>([8,9,10,11,12,13,14,15]);
      
      alternativa3d static const FORMATS:Array = [Context3DVertexBufferFormat.FLOAT_1,Context3DVertexBufferFormat.FLOAT_3,Context3DVertexBufferFormat.FLOAT_3,Context3DVertexBufferFormat.FLOAT_4,Context3DVertexBufferFormat.FLOAT_4,Context3DVertexBufferFormat.FLOAT_4,Context3DVertexBufferFormat.FLOAT_4,Context3DVertexBufferFormat.FLOAT_4,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2,Context3DVertexBufferFormat.FLOAT_2];
      
      public function VertexAttributes()
      {
         super();
      }
      
      public static function getAttributeStride(param1:int) : int
      {
         switch(alternativa3d::FORMATS[param1])
         {
            case Context3DVertexBufferFormat.FLOAT_1:
               return 1;
            case Context3DVertexBufferFormat.FLOAT_2:
               return 2;
            case Context3DVertexBufferFormat.FLOAT_3:
               return 3;
            case Context3DVertexBufferFormat.FLOAT_4:
               return 4;
            default:
               return 0;
         }
      }
   }
}

