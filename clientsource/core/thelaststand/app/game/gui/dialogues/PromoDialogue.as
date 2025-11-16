package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class PromoDialogue extends BaseDialogue
   {
      
      private var _promoId:String;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_image:UIImage;
      
      public function PromoDialogue(param1:String)
      {
         super("promo",this.mc_container,true);
         addTitle(Language.getInstance().getString("promo." + param1));
         this.ui_image = new UIImage(400,254,0,0,true,"images/promo/" + param1 + ".jpg");
         this.ui_image.x = this.ui_image.y = 4;
         this.mc_container.addChild(this.ui_image);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this.ui_image.width + this.ui_image.x * 2,this.ui_image.height + this.ui_image.y * 2);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         addButton(Language.getInstance().getString("buy_item_complete_ok"),true,{"width":120});
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}

