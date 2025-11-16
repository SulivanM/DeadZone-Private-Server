package thelaststand.app.game.gui.bounty
{
   import flash.display.Sprite;
   import flash.events.Event;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   
   public class BountyInfectedPage extends Sprite
   {
      
      private var _width:int = 765;
      
      private var _height:int = 376;
      
      private var _padding:int = 6;
      
      private var _bounty:InfectedBounty;
      
      private var ui_tasks:UIBountyInfectedTasks;
      
      private var ui_timeRemaining:UIBountyInfectedTimer;
      
      private var ui_reward:UIBountyInfectedReward;
      
      public function BountyInfectedPage()
      {
         super();
         this.ui_tasks = new UIBountyInfectedTasks();
         addChild(this.ui_tasks);
         this.ui_timeRemaining = new UIBountyInfectedTimer();
         this.ui_timeRemaining.width = int(this.ui_tasks.width);
         this.ui_timeRemaining.height = int(this._height - this.ui_tasks.height - this._padding);
         this.ui_timeRemaining.x = int(this.ui_tasks.x);
         this.ui_timeRemaining.y = int(this._height - this.ui_timeRemaining.height);
         addChild(this.ui_timeRemaining);
         this.ui_reward = new UIBountyInfectedReward();
         this.ui_reward.x = int(this.ui_tasks.x + this.ui_tasks.width + this._padding);
         this.ui_reward.y = int(this.ui_tasks.y);
         this.ui_reward.width = int(this._width - this.ui_reward.x);
         this.ui_reward.height = this._height;
         addChild(this.ui_reward);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.ui_tasks.dispose();
         this.ui_reward.dispose();
         this.ui_timeRemaining.dispose();
      }
      
      public function selectTask(param1:int) : void
      {
         this.ui_tasks.selectTask(param1);
      }
      
      private function setBounty(param1:InfectedBounty) : void
      {
         this._bounty = param1;
         this.ui_tasks.bounty = this._bounty;
         this.ui_timeRemaining.bounty = this._bounty;
         this.ui_reward.bounty = this._bounty;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         Network.getInstance().playerData.infectedBountyReceived.add(this.onInfectedBountyReceived);
         this.setBounty(Network.getInstance().playerData.infectedBounty);
         if(this._bounty != null && !this._bounty.isViewed)
         {
            Network.getInstance().save(null,SaveDataMethod.BOUNTY_VIEW);
            this._bounty.isViewed = true;
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         Network.getInstance().playerData.infectedBountyReceived.remove(this.onInfectedBountyReceived);
      }
      
      private function onInfectedBountyReceived(param1:InfectedBounty) : void
      {
         this.setBounty(param1);
      }
   }
}

