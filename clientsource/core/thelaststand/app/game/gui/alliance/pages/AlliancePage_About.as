package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   
   public class AlliancePage_About extends Sprite implements IAlliancePage
   {
      
      private var _dialogue:AllianceDialogue;
      
      private var image:UIImage;
      
      public function AlliancePage_About()
      {
         super();
         GraphicUtils.drawUIBlock(graphics,724,400);
         var _loc1_:* = "images/alliances/intro_image.jpg";
         if(Boolean(AllianceSystem.getInstance().serviceNode.hasOwnProperty("@useCustomImg")) && AllianceSystem.getInstance().serviceNode.@useCustomImg == "1")
         {
            _loc1_ = "images/alliances/intro_image_" + Network.getInstance().service + ".jpg";
         }
         this.image = new UIImage(722,398,3618615);
         this.image.x = this.image.y = 1;
         this.image.uri = _loc1_;
         addChild(this.image);
      }
      
      public function dispose() : void
      {
         this._dialogue = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.image.dispose();
      }
      
      public function get dialogue() : AllianceDialogue
      {
         return this._dialogue;
      }
      
      public function set dialogue(param1:AllianceDialogue) : void
      {
         this._dialogue = param1;
      }
   }
}

