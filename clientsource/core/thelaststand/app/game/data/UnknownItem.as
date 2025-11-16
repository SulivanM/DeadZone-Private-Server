package thelaststand.app.game.data
{
   public class UnknownItem extends Item
   {
      
      public function UnknownItem()
      {
         super();
      }
      
      override public function getImageURI() : String
      {
         return "images/items/unknown.jpg";
      }
   }
}

