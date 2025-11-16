package thelaststand.app.game.gui.map
{
   import flash.display.BitmapData;
   import flash.utils.getDefinitionByName;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIMapArenaPin extends UIMapAssignmentPin
   {
      
      private static var stadium:BmpIconArena_stadium;
      
      public function UIMapArenaPin(param1:String)
      {
         super(param1);
      }
      
      override protected function getXML() : XML
      {
         return ResourceManager.getInstance().get("xml/arenas.xml").arena.(@id == _id)[0];
      }
      
      override protected function getIcon() : BitmapData
      {
         var _loc1_:Class = getDefinitionByName("BmpIconArena_" + _id) as Class;
         return new _loc1_();
      }
      
      override protected function getName() : String
      {
         return Language.getInstance().getString("arena." + _id + ".name");
      }
   }
}

