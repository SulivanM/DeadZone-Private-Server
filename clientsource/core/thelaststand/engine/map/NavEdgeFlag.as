package thelaststand.engine.map
{
   public class NavEdgeFlag
   {
      
      public static const NONE:uint = 0;
      
      public static const DISABLED:uint = 1;
      
      public static const TRAVERSAL_AREA:uint = 2;
      
      public static const ALL_NOT_DISABLED:uint = 0xFF ^ DISABLED;
      
      public function NavEdgeFlag()
      {
         super();
         throw new Error("NavEdgeFlag cannot be directly instantiated.");
      }
   }
}

