package thelaststand.app.game.gui.alliance.pages
{
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   
   public interface IAlliancePage
   {
      
      function dispose() : void;
      
      function get dialogue() : AllianceDialogue;
      
      function set dialogue(param1:AllianceDialogue) : void;
   }
}

