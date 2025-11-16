package thelaststand.app.game.scenes
{
   import flash.geom.Vector3D;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   
   public class HumanSpawnPoint
   {
      
      public var position:Vector3D;
      
      public var building:BuildingEntity;
      
      public var xml:XML;
      
      public function HumanSpawnPoint()
      {
         super();
      }
   }
}

