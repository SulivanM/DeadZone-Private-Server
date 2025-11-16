package thelaststand.app.game.gui.map
{
   import flash.display.BitmapData;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIMapRaidPin extends UIMapAssignmentPin
   {
      
      public function UIMapRaidPin(param1:String)
      {
         super(param1);
      }
      
      override protected function getXML() : XML
      {
         return ResourceManager.getInstance().get("xml/raids.xml").raid.(@id == _id)[0];
      }
      
      override protected function getIcon() : BitmapData
      {
         return new BmpIconRaid();
      }
      
      override protected function getName() : String
      {
         return Language.getInstance().getString("raid." + _id + ".name");
      }
   }
}

