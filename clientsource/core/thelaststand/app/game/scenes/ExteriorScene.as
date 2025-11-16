package thelaststand.app.game.scenes
{
   import thelaststand.app.game.entities.light.SunLight;
   
   public class ExteriorScene extends BaseMissionScene
   {
      
      public function ExteriorScene()
      {
         super();
         addSceneLight(SunLight);
         _noiseVolumeMultiplier = 2;
      }
   }
}

