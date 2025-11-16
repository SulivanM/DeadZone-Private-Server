package thelaststand.app.game.data
{
   public class AttireFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const NO_HAIR:uint = 1 << 0;
      
      public static const NO_FACIAL_HAIR:uint = 1 << 1;
      
      public static const MOUTH:uint = 1 << 2;
      
      public static const EYES:uint = 1 << 3;
      
      public static const HEAD:uint = 1 << 4;
      
      public static const BACK:uint = 1 << 5;
      
      public static const CHEST:uint = 1 << 6;
      
      public static const NECK:uint = 1 << 7;
      
      public static const WAIST_FRONT:uint = 1 << 8;
      
      public static const WAIST_BACK:uint = 1 << 9;
      
      public static const LEFT_SHOULDER:uint = 1 << 10;
      
      public static const LEFT_UPPER_ARM:uint = 1 << 11;
      
      public static const LEFT_LOWER_ARM:uint = 1 << 12;
      
      public static const LEFT_UPPER_LEG:uint = 1 << 13;
      
      public static const LEFT_LOWER_LEG:uint = 1 << 14;
      
      public static const RIGHT_SHOULDER:uint = 1 << 15;
      
      public static const RIGHT_UPPER_ARM:uint = 1 << 16;
      
      public static const RIGHT_LOWER_ARM:uint = 1 << 17;
      
      public static const RIGHT_UPPER_LEG:uint = 1 << 18;
      
      public static const RIGHT_LOWER_LEG:uint = 1 << 19;
      
      public static const UPPER_BODY:uint = 1 << 20;
      
      public static const LOWER_BODY:uint = 1 << 21;
      
      public static const ALL:uint = 16777215;
      
      public static const CLOTHING:uint = UPPER_BODY | LOWER_BODY;
      
      public static const ACCESSORIES:uint = ALL ^ (UPPER_BODY | LOWER_BODY);
      
      public function AttireFlags()
      {
         super();
         throw new Error("AccessoryFlags cannot be directly instantiated.");
      }
   }
}

