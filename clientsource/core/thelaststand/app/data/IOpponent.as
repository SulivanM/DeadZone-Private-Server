package thelaststand.app.data
{
   public interface IOpponent
   {
      
      function get id() : String;
      
      function get level() : int;
      
      function get nickname() : String;
      
      function get isPlayer() : Boolean;
      
      function get imageURI() : String;
   }
}

