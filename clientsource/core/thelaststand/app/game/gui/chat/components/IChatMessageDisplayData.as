package thelaststand.app.game.gui.chat.components
{
   import thelaststand.app.network.chat.ChatMessageData;
   
   public interface IChatMessageDisplayData
   {
      
      function get messageDisplayType() : String;
      
      function get messageData() : ChatMessageData;
      
      function get display() : IChatMessageDisplay;
      
      function set display(param1:IChatMessageDisplay) : void;
      
      function get nickName() : String;
      
      function get message() : String;
      
      function set message(param1:String) : void;
      
      function get linkData() : Array;
      
      function set linkData(param1:Array) : void;
      
      function get alternate() : Boolean;
      
      function set alternate(param1:Boolean) : void;
      
      function get offset() : uint;
      
      function set offset(param1:uint) : void;
      
      function get rows() : uint;
      
      function set rows(param1:uint) : void;
      
      function dispose() : void;
   }
}

