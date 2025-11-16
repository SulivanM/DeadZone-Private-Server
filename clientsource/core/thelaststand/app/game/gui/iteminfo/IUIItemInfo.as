package thelaststand.app.game.gui.iteminfo
{
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SurvivorLoadout;
   
   public interface IUIItemInfo
   {
      
      function dispose() : void;
      
      function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void;
      
      function get item() : Item;
   }
}

