package thelaststand.app.game.gui.raid
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class RaidConfirmLaunchDialogue extends BaseDialogue
   {
      
      private var mc_container:Sprite = new Sprite();
      
      private var txt_message:BodyTextField;
      
      public var onConfirm:Function;
      
      public function RaidConfirmLaunchDialogue()
      {
         super("raid-confirm-launch",this.mc_container,true);
         _width = 345;
         _height = 175;
         _autoSize = false;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         addTitle(Language.getInstance().getString("raid.launchalert_title"),BaseDialogue.TITLE_COLOR_GREY,-1,new BmpIconAlert());
         addButton(Language.getInstance().getString("raid.launchalert_cancel"),true,{
            "width":120,
            "iconBackgroundColor":11871268,
            "icon":new Bitmap(new BmpIconTradeCrossRed())
         });
         addButton(Language.getInstance().getString("raid.launchalert_ok"),true,{
            "width":120,
            "iconBackgroundColor":5280522,
            "icon":new Bitmap(new BmpIconButtonArrow())
         }).clicked.addOnce(this.onClickOK);
         var _loc1_:int = 8;
         this.txt_message = new BodyTextField({
            "color":16119285,
            "size":14,
            "multiline":true
         });
         this.txt_message.htmlText = Language.getInstance().getString("raid.launchalert_message");
         this.txt_message.width = int(_width - _padding * 2 - _loc1_ * 2);
         this.txt_message.x = _loc1_;
         this.txt_message.y = _loc1_ + 6;
         this.mc_container.addChild(this.txt_message);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_width - _padding * 2,this.txt_message.height + _loc1_ * 2,0,this.txt_message.y - _loc1_);
         _height = this.txt_message.height + _loc1_ * 2 + 80;
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

