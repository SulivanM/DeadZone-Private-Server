package thelaststand.engine.objects.actions
{
   import thelaststand.engine.objects.GameEntity;
   
   public interface IEntityAction
   {
      
      function dispose() : void;
      
      function run(param1:GameEntity, param2:Number) : void;
   }
}

