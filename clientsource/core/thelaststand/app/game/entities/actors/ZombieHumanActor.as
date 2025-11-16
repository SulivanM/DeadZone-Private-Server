package thelaststand.app.game.entities.actors
{
   import com.exileetiquette.math.MathUtils;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.common.resources.ResourceManager;
   
   public class ZombieHumanActor extends HumanActor
   {
      
      public function ZombieHumanActor()
      {
         super();
         defaultScale = MathUtils.randomBetween(118,127) / 100;
      }
      
      override public function clear() : void
      {
         var _loc1_:AttireData = null;
         if(_appearance != null)
         {
            for each(_loc1_ in _appearance.data)
            {
               if(_loc1_.modifiedTexture)
               {
                  ResourceManager.getInstance().purge(_loc1_.modifiedTextureURI);
               }
            }
         }
         super.clear();
      }
   }
}

