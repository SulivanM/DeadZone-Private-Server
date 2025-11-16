package thelaststand.app.game.scenes
{
   import thelaststand.app.game.entities.light.IndoorLight;
   
   public class InteriorScene extends BaseMissionScene
   {
      
      private var light_indoor:IndoorLight;
      
      public function InteriorScene()
      {
         super();
         this.light_indoor = addSceneLight(IndoorLight) as IndoorLight;
      }
      
      override public function dispose() : void
      {
         this.light_indoor = null;
         super.dispose();
      }
      
      override public function populateFromDescriptor(param1:XML, param2:Number = NaN, param3:Boolean = true) : void
      {
         super.populateFromDescriptor(param1,param2,param3);
         this.light_indoor.intensity = param1.ambience.hasOwnProperty("intensity") ? Number(param1.ambience.intensity) : 0.3;
         if(param1.ambience.hasOwnProperty("color"))
         {
            this.light_indoor.color = parseInt(String(param1.ambience.color).substr(1),16);
         }
      }
   }
}

