package thelaststand.engine.objects
{
   public class GameEntityFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const IGNORE_TILEMAP:uint = 1 << 1;
      
      public static const IGNORE_TRANSFORMS:uint = 1 << 2;
      
      public static const USE_FOOTPRINT_FOR_TILEMAP:uint = 1 << 3;
      
      public static const FORCE_UNPASSABLE:uint = 1 << 4;
      
      public static const FORCE_PASSABLE:uint = 1 << 5;
      
      public function GameEntityFlags()
      {
         super();
         throw new Error("GameEntityFlags cannot be directly instantiated.");
      }
   }
}

