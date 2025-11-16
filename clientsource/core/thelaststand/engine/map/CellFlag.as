package thelaststand.engine.map
{
   public class CellFlag
   {
      
      public static const NONE:uint = 0;
      
      public static const DISABLED:uint = 1;
      
      public static const FORCE_WAYPOINT:uint = 2;
      
      public static const TRAVERSAL_AREA:uint = 4;
      
      public static const ALL_NOT_DISABLED:uint = 0xFF ^ DISABLED;
      
      public function CellFlag()
      {
         super();
         throw new Error("CellFlag cannot be directly instantiated.");
      }
   }
}

