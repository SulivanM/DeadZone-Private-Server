package thelaststand.app.game.data
{
   public class AmmoType
   {
      
      public static const NONE:uint = 0;
      
      public static const ARROW:uint = 1;
      
      public static const ASSAULT_RIFLE:uint = 2;
      
      public static const BOLT:uint = 4;
      
      public static const LONG_RIFLE:uint = 8;
      
      public static const PISTOL:uint = 16;
      
      public static const SHOTGUN:uint = 32;
      
      public static const SMG:uint = 64;
      
      public function AmmoType()
      {
         super();
         throw new Error("AmmoType cannot be directly instantiated.");
      }
   }
}

