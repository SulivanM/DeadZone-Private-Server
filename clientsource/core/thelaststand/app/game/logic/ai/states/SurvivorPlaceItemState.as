package thelaststand.app.game.logic.ai.states
{
   import com.deadreckoned.threshold.navigation.rvo.RVOAgentMode;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.GearClass;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.ExplosiveChargeEntity;
   import thelaststand.app.game.entities.actors.HumanActor;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.engine.objects.GameEntity;
   
   public class SurvivorPlaceItemState implements IAIState
   {
      
      private var _agent:Survivor;
      
      private var _animName:String;
      
      private var _item:Gear;
      
      private var _startedAnim:Boolean = false;
      
      private var _completedAnim:Boolean = false;
      
      public var placed:Signal = new Signal(GameEntity);
      
      public function SurvivorPlaceItemState(param1:Survivor, param2:Gear)
      {
         super();
         this._agent = param1;
         this._item = param2;
      }
      
      public function dispose() : void
      {
         if(this._agent != null)
         {
            this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
            if(this._agent.actor != null && this._agent.actor.animatedAsset != null)
            {
               this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
               this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
            }
            this._agent = null;
         }
         this._item = null;
         this.placed.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         this._agent.flags |= AIAgentFlags.IMMOVEABLE;
         this._agent.navigator.mode = RVOAgentMode.STATIC;
         this._agent.navigator.cancelAndStop();
         this._startedAnim = true;
         this._animName = "grenade-fire-close";
         this._agent.actor.animatedAsset.gotoAndPlay(this._animName,0,false,1,0.1);
         this._agent.actor.animatedAsset.animationNotified.addOnce(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.addOnce(this.onAnimationComplete);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(false);
         }
      }
      
      public function exit(param1:Number) : void
      {
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         if(!this._completedAnim)
         {
            this.endPlacement();
         }
         this.placed.removeAll();
      }
      
      public function update(param1:Number, param2:Number) : void
      {
      }
      
      private function endPlacement() : void
      {
         this._completedAnim = true;
         this._agent.gotoIdleAnimation(true);
         this._agent.actor.animatedAsset.animationNotified.remove(this.onAnimationNotify);
         this._agent.actor.animatedAsset.animationCompleted.remove(this.onAnimationComplete);
         if(this._agent.actor is HumanActor)
         {
            HumanActor(this._agent.actor).setPropVisibility(true);
         }
         this._agent.flags &= ~AIAgentFlags.IMMOVEABLE;
         this._agent.navigator.mode = RVOAgentMode.GROUP_ONLY;
      }
      
      private function onAnimationNotify(param1:String, param2:String) : void
      {
         var _loc3_:ExplosiveChargeEntity = null;
         if(param1 != this._animName)
         {
            return;
         }
         if(param2 == "magOut")
         {
            switch(this._item.gearClass)
            {
               case GearClass.EXPLOSIVE_CHARGE:
                  _loc3_ = new ExplosiveChargeEntity(this._agent,this._item);
                  _loc3_.transform.position.copyFrom(this._agent.actor.transform.position);
                  _loc3_.transform.position.x += this._agent.actor.transform.forward.x * -75;
                  _loc3_.transform.position.y += this._agent.actor.transform.forward.y * -75;
                  this._agent.actor.scene.addEntity(_loc3_);
                  this.placed.dispatch(_loc3_);
                  break;
               default:
                  throw new Error("Invalid placement gear item class supplied.");
            }
         }
      }
      
      private function onAnimationComplete(param1:String) : void
      {
         if(param1 != this._animName)
         {
            return;
         }
         this.endPlacement();
         this._agent.stateMachine.setState(null);
      }
   }
}

