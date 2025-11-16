package thelaststand.app.display
{
   import com.deadreckoned.threshold.display.Color;
   import com.quasimondo.geom.ColorMatrix;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import thelaststand.app.game.data.ItemQualityType;
   
   public class Effects
   {
      
      public static const ICON_SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,1,6,6,1.1,2);
      
      public static const STROKE:GlowFilter = new GlowFilter(0,1,1.75,1.75,5,1);
      
      public static const STROKE_MEDIUM:GlowFilter = new GlowFilter(0,1,3.5,3.5,5,1);
      
      public static const STROKE_THICK:GlowFilter = new GlowFilter(0,1,6,6,8,1);
      
      public static const TEXT_SHADOW:GlowFilter = new GlowFilter(0,0.75,3,3,1,2);
      
      public static const TEXT_SHADOW_DARK:GlowFilter = new GlowFilter(0,1,5,5,1,2);
      
      public static const GREYSCALE:ColorMatrix = new ColorMatrix();
      
      public static const GLOW_MAGIC_GREY:GlowFilter = new GlowFilter(16777215,0);
      
      public static const GLOW_MAGIC_WHITE:GlowFilter = new GlowFilter(16777215,1,15,15,0.5,1);
      
      public static const GLOW_MAGIC_GREEN:GlowFilter = new GlowFilter(65280,1,12,12,0.45,1);
      
      public static const GLOW_MAGIC_BLUE:GlowFilter = new GlowFilter(52479,1,16,16,0.5,1);
      
      public static const GLOW_MAGIC_PURPLE:GlowFilter = new GlowFilter(13408716,1,10,10,1,1);
      
      public static const GLOW_MAGIC_PREMIUM:GlowFilter = new GlowFilter(16763904,1,17,17,0.55,1);
      
      public static const GLOW_MAGIC_RARE:GlowFilter = new GlowFilter(6919843,1,17,17,0.55,1);
      
      public static const GLOW_MAGIC_UNIQUE:GlowFilter = new GlowFilter(14383667,1,17,17,0.55,1);
      
      public static const GLOW_MAGIC_INFAMOUS:GlowFilter = new GlowFilter(16732584,1,17,17,0.55,1);
      
      public static const COLOR_GOOD:uint = 9883497;
      
      public static const COLOR_NEUTRAL:uint = 15263976;
      
      public static const COLOR_WARNING:uint = 15597568;
      
      public static const COLOR_GREYOUT:uint = 6776679;
      
      public static const COLOR_COVER_LOW:uint = 14942208;
      
      public static const COLOR_COVER_MODERATE:uint = 14980864;
      
      public static const COLOR_COVER_HIGH:uint = 4367168;
      
      public static const COLOR_WHITE:uint = 16777215;
      
      public static const COLOR_GREY:uint = 11908533;
      
      public static const COLOR_GREEN:uint = 3920209;
      
      public static const COLOR_BLUE:uint = 1420273;
      
      public static const COLOR_PURPLE:uint = 12675071;
      
      public static const COLOR_PREMIUM:uint = 16763904;
      
      public static const COLOR_RARE:uint = 5269103;
      
      public static const COLOR_UNIQUE:uint = 11820322;
      
      public static const COLOR_INFAMOUS:uint = 11536904;
      
      public static const COLOR_EFFECT_GENERAL:uint = 1662872;
      
      public static const COLOR_EFFECT_COMBAT:uint = 7872294;
      
      public static const COLOR_EFFECT_WAR:uint = 7872294;
      
      public static const COLOR_EFFECT_MISSION:uint = 4418340;
      
      public static const COLOR_EFFECT_RESOURCE:uint = 6434918;
      
      public static const COLOR_EFFECT_SURVIVAL:uint = 8610363;
      
      public static const COLOR_EFFECT_ALLIANCE:uint = 16763904;
      
      public static const COLOR_EFFECT_MISC:uint = 16026624;
      
      public static const BUTTON_WARNING_RED:uint = 7545099;
      
      public static const BUTTON_GREEN:uint = 4226049;
      
      public static const CT_DEFAULT:ColorTransform = new ColorTransform();
      
      public static const CT_WARNING:ColorTransform = new ColorTransform();
      
      public static const CT_GOOD:ColorTransform = new ColorTransform();
      
      public static const CT_MAGIC_BG_WHITE:ColorTransform = new ColorTransform(1,1,1,1);
      
      public static const CT_MAGIC_BG_GREY:ColorTransform = new ColorTransform(1,1,1,1,-27,-27,-27);
      
      public static const CT_MAGIC_BG_GREEN:ColorTransform = new ColorTransform(1,1,1,1,-35,-16,-26);
      
      public static const CT_MAGIC_BG_BLUE:ColorTransform = new ColorTransform(1,1,1,1,-33,-12,22);
      
      public static const CT_MAGIC_BG_PURPLE:ColorTransform = new ColorTransform(1,1,1,1,27,-9,38);
      
      public static const CT_MAGIC_BG_PREMIUM:ColorTransform = new ColorTransform(1,1,1,1,0,-17,-44);
      
      public static const CT_MAGIC_BG_RARE:ColorTransform = new ColorTransform(1,1,1,1,-29,-8,0);
      
      public static const CT_MAGIC_BG_UNIQUE:ColorTransform = new ColorTransform(1,1,1,1,14,-52,-95);
      
      public static const CT_MAGIC_BG_INFAMOUS:ColorTransform = new ColorTransform(1,1,1,1,25,-255,-255);
      
      public static const CT_EFFECT_BG_GENERAL:ColorTransform = new ColorTransform(1,1,1,1,-76,11,23);
      
      public static const CT_EFFECT_BG_COMBAT:ColorTransform = new ColorTransform(1,1,1,1,-8,-34,-31);
      
      public static const CT_EFFECT_BG_WAR:ColorTransform = new ColorTransform(1,1,1,1,-8,-34,-31);
      
      public static const CT_EFFECT_BG_MISSION:ColorTransform = new ColorTransform(1,1,1,1,-13,5,-20);
      
      public static const CT_EFFECT_BG_RESOURCE:ColorTransform = new ColorTransform(1,1,1,1,12,2,30);
      
      public static const CT_EFFECT_BG_SURVIVAL:ColorTransform = new ColorTransform(1,1,1,1,46,29,9);
      
      public static const CT_EFFECT_BG_ALLIANCE:ColorTransform = new ColorTransform(1,1,1,1,0,-17,-44);
      
      public static const CT_EFFECT_BG_MISC:ColorTransform = new ColorTransform(1,1,1,1,0,-17,-44);
      
      CT_WARNING.color = COLOR_WARNING;
      CT_GOOD.color = COLOR_GOOD;
      GREYSCALE.desaturate();
      GREYSCALE.adjustBrightness(-10);
      
      public function Effects()
      {
         super();
         throw new Error("Effects cannot be directly instantiated.");
      }
      
      public static function stroke(param1:uint, param2:Number) : GlowFilter
      {
         return new GlowFilter(param1,1,param2,param2,5,1);
      }
      
      public static function getQualityTitleColor(param1:uint) : uint
      {
         var _loc2_:String = ItemQualityType.getName(param1);
         var _loc3_:uint = uint(Effects["COLOR_" + _loc2_]);
         switch(param1)
         {
            case ItemQualityType.RARE:
            case ItemQualityType.UNIQUE:
            case ItemQualityType.INFAMOUS:
               _loc3_ = new Color(_loc3_).multiply(2).RGB;
         }
         return _loc3_;
      }
   }
}

