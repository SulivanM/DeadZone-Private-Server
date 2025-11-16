package thelaststand.app.game.entities.actions
{
   import alternativa.engine3d.core.Object3D;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.actions.IEntityAction;
   
   public class WindmillAction implements IEntityAction
   {
      
      private var _windSpeed:Number = 3;
      
      private var _blades:Object3D;
      
      public function WindmillAction()
      {
         super();
      }
      
      public function dispose() : void
      {
         this._blades = null;
      }
      
      public function run(param1:GameEntity, param2:Number) : void
      {
         var _loc3_:Object3D = null;
         if(this._blades == null)
         {
            _loc3_ = param1.asset.getChildByName("meshEntity");
            if(_loc3_ == null)
            {
               return;
            }
            this._blades = _loc3_.getChildByName("windmill-blades");
         }
         if(this._blades != null)
         {
            this._blades.rotationY += Math.PI * this._windSpeed * param2;
         }
      }
   }
}

