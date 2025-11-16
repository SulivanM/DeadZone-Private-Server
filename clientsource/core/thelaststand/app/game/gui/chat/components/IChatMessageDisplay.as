package thelaststand.app.game.gui.chat.components
{
   import flash.display.DisplayObjectContainer;
   import flash.events.IEventDispatcher;
   
   public interface IChatMessageDisplay extends IEventDispatcher
   {
      
      function dispose() : void;
      
      function get type() : String;
      
      function populate(param1:IChatMessageDisplayData) : void;
      
      function get messageData() : IChatMessageDisplayData;
      
      function get rows() : uint;
      
      function get width() : Number;
      
      function set width(param1:Number) : void;
      
      function get height() : Number;
      
      function set height(param1:Number) : void;
      
      function get parent() : DisplayObjectContainer;
      
      function get x() : Number;
      
      function set x(param1:Number) : void;
      
      function get y() : Number;
      
      function set y(param1:Number) : void;
   }
}

