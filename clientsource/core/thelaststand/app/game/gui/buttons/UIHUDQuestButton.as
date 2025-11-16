package thelaststand.app.game.gui.buttons
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.gui.dialogues.QuestsDialogue;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.game.logic.GlobalQuestSystem;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   
   public class UIHUDQuestButton extends UIHUDButton
   {
      
      private var _newQuests:int = 0;
      
      private var _ptNew:Point;
      
      private var _ptUncollected:Point;
      
      private var ui_new:UINotificationCount;
      
      private var ui_uncollected:UINotificationCount;
      
      public function UIHUDQuestButton(param1:String)
      {
         super(param1,new Bitmap(new BmpIconHUDObjectives()));
         this._ptNew = new Point(5,5);
         this._ptUncollected = new Point(0,21);
         this.ui_new = new UINotificationCount();
         this.ui_new.x = this._ptNew.x;
         this.ui_new.y = this._ptNew.y;
         this.ui_new.label = "0";
         this.ui_new.visible = false;
         addChild(this.ui_new);
         var _loc2_:int = QuestSystem.getInstance().numUncollectedQuests;
         this.ui_uncollected = new UINotificationCount(622336);
         this.ui_uncollected.x = this._ptUncollected.x;
         this.ui_uncollected.y = this._ptUncollected.y;
         this.ui_uncollected.label = NumberFormatter.format(_loc2_,0);
         this.ui_uncollected.visible = _loc2_ > 0;
         addChild(this.ui_uncollected);
         GlobalQuestSystem.getInstance().questCollected.add(this.onQuestCompletedOrCollected);
         QuestSystem.getInstance().questStarted.add(this.onQuestStarted);
         QuestSystem.getInstance().questCompleted.add(this.onQuestCompletedOrCollected);
         QuestSystem.getInstance().questCollected.add(this.onQuestCompletedOrCollected);
         DialogueManager.getInstance().dialogueClosed.add(this.onDialogueClosed);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_new.dispose();
         this.ui_uncollected.dispose();
         GlobalQuestSystem.getInstance().questCollected.remove(this.onQuestCompletedOrCollected);
         QuestSystem.getInstance().questStarted.remove(this.onQuestStarted);
         QuestSystem.getInstance().questCompleted.remove(this.onQuestCompletedOrCollected);
         QuestSystem.getInstance().questCollected.remove(this.onQuestCompletedOrCollected);
         DialogueManager.getInstance().dialogueClosed.remove(this.onDialogueClosed);
      }
      
      private function onQuestStarted(param1:Quest) : void
      {
         this.ui_new.label = NumberFormatter.format(++this._newQuests,0);
         this.ui_new.visible = true;
      }
      
      private function onQuestCompletedOrCollected(param1:Quest) : void
      {
         var _loc2_:int = QuestSystem.getInstance().numUncollectedQuests;
         _loc2_ += GlobalQuestSystem.getInstance().numUncollectedQuests;
         this.ui_uncollected.label = NumberFormatter.format(_loc2_,0);
         this.ui_uncollected.visible = _loc2_ > 0;
         this.ui_new.visible = this._newQuests > 0;
      }
      
      private function onDialogueClosed(param1:GenericEvent, param2:Dialogue) : void
      {
         if(param2 is QuestsDialogue)
         {
            this._newQuests = 0;
            this.ui_new.visible = false;
         }
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown || mc_icon == null)
         {
            return;
         }
         super.onMouseOver(param1);
         TweenMax.to(this.ui_new,0.15,{
            "x":this._ptNew.x - 5,
            "y":this._ptNew.y - 7
         });
         TweenMax.to(this.ui_uncollected,0.15,{
            "x":this._ptUncollected.x - 5,
            "y":this._ptUncollected.y - 3
         });
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         super.onMouseOut(param1);
         TweenMax.to(this.ui_new,0.15,{
            "x":this._ptNew.x,
            "y":this._ptNew.y
         });
         TweenMax.to(this.ui_uncollected,0.15,{
            "x":this._ptUncollected.x,
            "y":this._ptUncollected.y
         });
      }
      
      override public function get width() : Number
      {
         return mc_hitArea.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return mc_hitArea.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

