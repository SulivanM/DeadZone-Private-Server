package thelaststand.app.game.data
{
   public class WeaponClass
   {
      
      public static const ASSAULT_RIFLE:String = "assault_rifle";
      
      public static const BOW:String = "bow";
      
      public static const LAUNCHER:String = "launcher";
      
      public static const LONG_RIFLE:String = "long_rifle";
      
      public static const MELEE:String = "melee";
      
      public static const PISTOL:String = "pistol";
      
      public static const SHOTGUN:String = "shotgun";
      
      public static const SMG:String = "smg";
      
      public static const LMG:String = "lmg";
      
      public static const THROWN:String = "thrown";
      
      public static const HEAVY:String = "heavy";
      
      public function WeaponClass()
      {
         super();
         throw new Error("WeaponClass cannot be directly instantiated.");
      }
      
      public static function getAllTypes() : Array
      {
         return [ASSAULT_RIFLE,BOW,LAUNCHER,LONG_RIFLE,MELEE,PISTOL,SHOTGUN,SMG,THROWN,HEAVY];
      }
   }
}

