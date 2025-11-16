package thelaststand.app.game.logic.ai.states
{
   import thelaststand.app.game.data.JunkBuilding;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.game.logic.ai.AIStateMachine;
   import thelaststand.app.game.logic.navigation.NavigatorAgent;
   import thelaststand.app.game.scenes.CompoundScene;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.Path;
   import thelaststand.engine.objects.GameEntity;
   
   public class SurvivorCompoundIdleState implements IAIState
   {
      
      private var _buildings:Vector.<BuildingEntity>;
      
      private var _agent:Survivor;
      
      private var _stateMachine:AIStateMachine;
      
      private var _waitTime:Number;
      
      private var _firstUpdate:Boolean;
      
      public function SurvivorCompoundIdleState(param1:Survivor)
      {
         super();
         this._agent = param1;
         this._stateMachine = this._agent.stateMachine;
         this._buildings = new Vector.<BuildingEntity>();
      }
      
      public function dispose() : void
      {
         if(this._buildings != null)
         {
            this._buildings.length = 0;
         }
         this._agent = null;
         this._stateMachine = null;
         this._buildings = null;
      }
      
      public function enter(param1:Number) : void
      {
         var _loc2_:GameEntity = null;
         var _loc3_:BuildingEntity = null;
         this._agent.navigator.stop();
         this._agent.actor.targetForward = null;
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         this._buildings.length = 0;
         this._waitTime = 0;
         if(this._agent.actor.scene != null)
         {
            _loc2_ = this._agent.actor.scene.entityListHead;
            while(_loc2_ != null)
            {
               _loc3_ = _loc2_ as BuildingEntity;
               _loc2_ = _loc2_.next;
               if(!(_loc3_ == null || Boolean(_loc3_.flags & EntityFlags.BEING_MOVED)))
               {
                  if(!(_loc3_.buildingData.destroyable && _loc3_.buildingData.dead))
                  {
                     if(!(_loc3_.buildingData.type == "bed" || _loc3_.buildingData.type == "rally"))
                     {
                        if(!(_loc3_.buildingData.isDoor || _loc3_.buildingData is JunkBuilding))
                        {
                           this._buildings.push(_loc3_);
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function exit(param1:Number) : void
      {
         this._buildings.length = 0;
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:BuildingEntity = null;
         var _loc4_:Cell = null;
         if(this._agent.navigator.isMoving)
         {
            return;
         }
         if(this._waitTime > 0)
         {
            this._waitTime -= param1;
            return;
         }
         if(this._buildings.length > 0)
         {
            _loc3_ = this._buildings[int(Math.random() * this._buildings.length)];
            if(_loc3_ != null)
            {
               this._agent.stateMachine.setState(new ActorScavengeState(this._agent,_loc3_));
               this._waitTime = 100;
               return;
            }
         }
         else
         {
            _loc4_ = CompoundScene(this._agent.actor.scene).getRandomUnoccupiedCellIndoors();
            if(_loc4_ != null)
            {
               this._agent.navigator.moveToCell(_loc4_.x,_loc4_.y);
               this._agent.navigator.pathCompleted.addOnce(this.onPathCompleted);
               return;
            }
         }
         this._waitTime = 5 + Math.random() * 5;
         this._agent.navigator.cancelAndStop();
      }
      
      private function onPathCompleted(param1:NavigatorAgent, param2:Path) : void
      {
         this._waitTime = 2 + Math.random() * 5;
         this._agent.navigator.cancelAndStop();
      }
   }
}

