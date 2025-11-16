package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import flash.events.Event;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   
   public class AlliancePage_Overview extends Sprite implements IAlliancePage
   {
      
      private var _dialogue:AllianceDialogue;
      
      private var _padding:int = 9;
      
      private var ui_scores:AlliancePage_Overview_Scores;
      
      private var ui_boosts:AlliancePage_Overview_Boosts;
      
      private var ui_indiRewards:AlliancePage_Overview_IndividualWarRewards;
      
      public function AlliancePage_Overview()
      {
         super();
         var _loc1_:int = 244;
         AllianceSystem.getInstance().connected.add(this.onAllianceSystemConnected);
         this.ui_scores = new AlliancePage_Overview_Scores();
         this.ui_scores.x = _loc1_;
         addChild(this.ui_scores);
         this.ui_boosts = new AlliancePage_Overview_Boosts();
         this.ui_boosts.x = _loc1_;
         this.ui_boosts.y = int(this.ui_scores.y + this.ui_scores.height + this._padding);
         addChild(this.ui_boosts);
         this.ui_indiRewards = new AlliancePage_Overview_IndividualWarRewards();
         this.ui_indiRewards.x = _loc1_;
         this.ui_indiRewards.y = int(this.ui_boosts.y + this.ui_boosts.height + this._padding);
         addChild(this.ui_indiRewards);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function get dialogue() : AllianceDialogue
      {
         return this._dialogue;
      }
      
      public function set dialogue(param1:AllianceDialogue) : void
      {
         this._dialogue = param1;
         if(AllianceSystem.getInstance().isConnected)
         {
            this._dialogue.refreshBanner();
         }
      }
      
      public function dispose() : void
      {
         this._dialogue = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnected);
         this.ui_scores.dispose();
         this.ui_boosts.dispose();
         this.ui_indiRewards.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._dialogue.showBanner();
      }
      
      private function onAllianceSystemConnected() : void
      {
         this._dialogue.refreshBanner();
      }
   }
}

