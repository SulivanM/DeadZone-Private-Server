package thelaststand.app.game.gui.dialogues
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.common.lang.Language;
   
   public class BountyFriendAllianceMessageBox extends MessageBox
   {
      
      public var onAccept:Signal;
      
      public function BountyFriendAllianceMessageBox()
      {
         var _lang:Language;
         this.onAccept = new Signal();
         _lang = Language.getInstance();
         super(_lang.getString("bounty.friendAlly_dialogue_body"));
         addTitle(_lang.getString("bounty.friendAlly_dialogue_title"),BaseDialogue.TITLE_COLOR_RUST,-1);
         addButton(_lang.getString("bounty.friendAlly_dialogue_ok"),false,{"backgroundColor":7545099}).clicked.add(function(param1:MouseEvent):void
         {
            onAccept.dispatch();
         });
         addButton(_lang.getString("bounty.friendAlly_dialogue_cancel")).clicked.add(function(param1:MouseEvent):void
         {
            Tracking.trackEvent("Bounty","FriendAlly_Decline_Mission");
         });
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.onAccept.removeAll();
      }
   }
}

