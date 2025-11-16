package thelaststand.app.game.scenes
{
   public class SceneFactory
   {
      
      public static const TYPE_STREET:String = "street";
      
      public static const TYPE_COMPOUND:String = "compound";
      
      public static const TYPE_INTERIOR:String = "interior";
      
      public static const TYPE_EXTERIOR:String = "exterior";
      
      public static const TYPE_GENERIC:String = "generic";
      
      public function SceneFactory()
      {
         super();
         throw new Error("SceneFactory cannot be directly instantiated.");
      }
      
      public static function getScene(param1:String) : BaseScene
      {
         switch(param1)
         {
            case TYPE_STREET:
               return new StreetScene();
            case TYPE_COMPOUND:
               return new CompoundScene();
            case TYPE_INTERIOR:
               return new InteriorScene();
            case TYPE_EXTERIOR:
               return new ExteriorScene();
            case TYPE_GENERIC:
         }
         return new BaseScene();
      }
      
      public static function getTypeFromScene(param1:BaseScene) : String
      {
         if(param1 is StreetScene)
         {
            return TYPE_STREET;
         }
         if(param1 is CompoundScene)
         {
            return TYPE_COMPOUND;
         }
         if(param1 is InteriorScene)
         {
            return TYPE_INTERIOR;
         }
         if(param1 is ExteriorScene)
         {
            return TYPE_EXTERIOR;
         }
         return TYPE_GENERIC;
      }
   }
}

