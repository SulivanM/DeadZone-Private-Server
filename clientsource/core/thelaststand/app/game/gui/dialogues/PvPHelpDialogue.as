package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.common.lang.Language;
   
   public class PvPHelpDialogue extends TutorialHelpDialogue
   {
      
      public function PvPHelpDialogue()
      {
         var _loc1_:Language = Language.getInstance();
         super(_loc1_.getString("pvp_help_title"),new <Sprite>[new HelpPage("images/ui/help-interact.jpg",_loc1_.getString("pvp_help_interaction_title"),_loc1_.getString("pvp_help_interaction_msg")),new HelpPage("images/ui/help-suppression.jpg",_loc1_.getString("pvp_help_suppression_title"),_loc1_.getString("pvp_help_suppression_msg")),new HelpPage("images/ui/help-trapspotting.jpg",_loc1_.getString("pvp_help_trapspotting_title"),_loc1_.getString("pvp_help_trapspotting_msg")),new HelpPage("images/ui/help-trapdisarming.jpg",_loc1_.getString("pvp_help_trapdisarming_title"),_loc1_.getString("pvp_help_trapdisarming_msg"))]);
      }
   }
}

