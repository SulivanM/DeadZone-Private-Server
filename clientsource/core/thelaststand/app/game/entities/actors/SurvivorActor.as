package thelaststand.app.game.entities.actors
{
   import thelaststand.common.resources.ResourceManager;
   
   public class SurvivorActor extends HumanActor
   {
      
      public function SurvivorActor()
      {
         super();
         _assetAnims.push(ResourceManager.getInstance().animations.getAnimationTable("models/anim/human.anim"));
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}

