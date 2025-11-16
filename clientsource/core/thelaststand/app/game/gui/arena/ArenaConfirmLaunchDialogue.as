package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class ArenaConfirmLaunchDialogue extends BaseDialogue
   {
      
      private var mc_container:Sprite = new Sprite();
      
      private var txt_message:BodyTextField;
      
      public var onConfirm:Function;
      
      public function ArenaConfirmLaunchDialogue(param1:int)
      {
         super("arena-confirm-launch",this.mc_container,true);
         _width = 345;
         _height = 175;
         _autoSize = false;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         addTitle(Language.getInstance().getString("arena.launchalert_title"),BaseDialogue.TITLE_COLOR_GREY,-1,new BmpIconAlert());
         addButton(Language.getInstance().getString("arena.launchalert_cancel"),true,{
            "width":120,
            "iconBackgroundColor":11871268,
            "icon":new Bitmap(new BmpIconTradeCrossRed())
         });
         addButton(Language.getInstance().getString("arena.launchalert_ok"),true,{
            "buttonClass":PurchasePushButton,
            "cost":param1,
            "width":120
         }).clicked.addOnce(this.onClickOK);
         var _loc2_:int = 8;
         this.txt_message = new BodyTextField({
            "color":16119285,
            "size":14,
            "multiline":true
         });
         this.txt_message.htmlText = Language.getInstance().getString("arena.launchalert_message",NumberFormatter.format(param1,0));
         this.txt_message.width = int(_width - _padding * 2 - _loc2_ * 2);
         this.txt_message.x = _loc2_;
         this.txt_message.y = _loc2_ + 6;
         this.mc_container.addChild(this.txt_message);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_width - _padding * 2,this.txt_message.height + _loc2_ * 2,0,this.txt_message.y - _loc2_);
         _height = this.txt_message.height + _loc2_ * 2 + 80;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_message.dispose();
      }
      
      private function onClickOK(param1:MouseEvent) : void
      {
         if(this.onConfirm != null)
         {
            this.onConfirm();
         }
      }
   }
}

