package alternativa.engine3d.materials.compiler
{
   public class VariableType
   {
      
      public static const ATTRIBUTE:uint = 0;
      
      public static const CONSTANT:uint = 1;
      
      public static const TEMPORARY:uint = 2;
      
      public static const OUTPUT:uint = 3;
      
      public static const VARYING:uint = 4;
      
      public static const SAMPLER:uint = 5;
      
      public static const DEPTH:uint = 6;
      
      public static const INPUT:uint = 7;
      
      public static const TYPE_NAMES:Vector.<String> = Vector.<String>(["attribute","constant","temporary","output","varying","sampler","depth","input"]);
      
      public function VariableType()
      {
         super();
      }
   }
}

