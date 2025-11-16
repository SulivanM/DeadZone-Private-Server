package thelaststand.app.game.data
{
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import thelaststand.app.game.entities.DeploymentZoneMesh;
   import thelaststand.engine.scenes.Scene;
   
   public class DeploymentZone
   {
      
      private var _rect:Rectangle;
      
      private var _decal:DeploymentZoneMesh;
      
      public function DeploymentZone(param1:Scene, param2:int, param3:int, param4:int, param5:int)
      {
         super();
         this._rect = new Rectangle(param2,param3,param4,param5);
         var _loc6_:Number = param1.map.cellSize;
         var _loc7_:Vector3D = param1.map.getCellCoords(param2,param3);
         this._decal = new DeploymentZoneMesh(this._rect.width * _loc6_,this._rect.height * _loc6_);
         this._decal.x = _loc7_.x - _loc6_ * 0.5;
         this._decal.y = _loc7_.y + _loc6_ * 0.5 - this._rect.height * _loc6_;
      }
      
      public function get decal() : DeploymentZoneMesh
      {
         return this._decal;
      }
      
      public function get rect() : Rectangle
      {
         return this._rect;
      }
      
      public function dispose() : void
      {
         this._rect = null;
         this._decal.dispose();
         this._decal = null;
      }
   }
}

