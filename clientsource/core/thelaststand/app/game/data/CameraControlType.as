package thelaststand.app.game.data
{
   public class CameraControlType
   {
      
      public static const ZOOM_IN:String = "zoomIn";
      
      public static const ZOOM_OUT:String = "zoomOut";
      
      public static const ROTATE:String = "rotate";
      
      public function CameraControlType()
      {
         super();
         throw new Error("CameraControlType cannot be directly instantiated.");
      }
   }
}

