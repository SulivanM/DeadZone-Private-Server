package thelaststand.app.utils
{
   import flash.display.Graphics;
   
   public class GraphicUtils
   {
      
      public function GraphicUtils()
      {
         super();
         throw new Error("GraphicUtils cannot be directly instantiated.");
      }
      
      public static function drawUIBlock(param1:Graphics, param2:int, param3:int, param4:int = 0, param5:int = 0, param6:int = 2434341, param7:uint = 7631988) : Class
      {
         param1.beginFill(param7);
         param1.drawRect(param4,param5,param2,param3);
         param1.endFill();
         param1.beginFill(param6);
         param1.drawRect(param4 + 1,param5 + 1,param2 - 2,param3 - 2);
         param1.endFill();
         return GraphicUtils;
      }
   }
}

