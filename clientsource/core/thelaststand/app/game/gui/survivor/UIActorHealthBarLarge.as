package thelaststand.app.game.gui.survivor
{
   import thelaststand.app.game.gui.UISimpleProgressBar;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   
   public class UIActorHealthBarLarge extends UISimpleProgressBar
   {
      
      private var _agent:AIActorAgent;
      
      public function UIActorHealthBarLarge(param1:AIActorAgent, param2:uint)
      {
         super(param2);
         mouseEnabled = mouseChildren = false;
         if(param1 != null)
         {
            this.agent = param1;
         }
      }
      
      public function get agent() : AIActorAgent
      {
         return this._agent;
      }
      
      public function set agent(param1:AIActorAgent) : void
      {
         if(param1 == this._agent)
         {
            return;
         }
         if(this._agent != null)
         {
            this._agent.healthChanged.remove(this.onHealthChanged);
         }
         this._agent = param1;
         this._agent.healthChanged.add(this.onHealthChanged);
         this.updateHealth();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._agent != null)
         {
            this._agent.healthChanged.remove(this.onHealthChanged);
            this._agent = null;
         }
      }
      
      private function updateHealth() : void
      {
         var _loc1_:Number = this._agent.maxHealth;
         progress = this._agent.health / _loc1_;
      }
      
      private function onHealthChanged(param1:AIActorAgent) : void
      {
         this.updateHealth();
      }
   }
}

