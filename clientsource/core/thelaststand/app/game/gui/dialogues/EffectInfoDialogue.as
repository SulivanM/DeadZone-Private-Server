package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class EffectInfoDialogue extends BaseDialogue
   {
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_image:UIImage;
      
      public function EffectInfoDialogue()
      {
         super("effect-info",this.mc_container,true);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         var _loc1_:int = 4;
         var _loc2_:int = 314;
         var _loc3_:int = 240;
         addTitle(Language.getInstance().getString("no_effects_title"),14825014);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc2_ + _loc1_ * 2,_loc3_ + _loc1_ * 2);
         this.ui_image = new UIImage(314,240,0,0,true,"images/ui/no-books.jpg");
         this.ui_image.x = this.ui_image.y = _loc1_;
         this.mc_container.addChild(this.ui_image);
         addButton(Language.getInstance().getString("no_effects_cancel"),true,{"width":153});
         addButton(Language.getInstance().getString("no_effects_ok"),false,{
            "buttonClass":PurchasePushButton,
            "showIcon":false,
            "width":153
         }).clicked.addOnce(this.onClickedOK);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_image.dispose();
      }
      
      private function onClickedOK(param1:MouseEvent) : void
      {
         close();
         var _loc2_:StoreDialogue = new StoreDialogue("effect");
         _loc2_.open();
      }
   }
}

