package thelaststand.app.game.gui.arena
{
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.utils.GraphicUtils;
   
   public class ArenaPageHelp extends ArenaDialoguePage
   {
      
      private var ui_image:UIImage;
      
      public function ArenaPageHelp(param1:ArenaSession)
      {
         super(param1);
         this.ui_image = new UIImage(1,1,0,1,true,"images/arena/" + param1.name + "_help.jpg");
         addChild(this.ui_image);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_image.dispose();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,width,height);
         this.ui_image.x = this.ui_image.y = 3;
         this.ui_image.width = int(width - this.ui_image.x * 2);
         this.ui_image.height = int(height - this.ui_image.y * 2);
      }
   }
}

