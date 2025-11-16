package thelaststand.app.game.gui.survivor
{
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   
   public interface IUISkillsTable
   {
      
      function dispose() : void;
      
      function setSurvivor(param1:Survivor, param2:SurvivorLoadout) : void;
   }
}

