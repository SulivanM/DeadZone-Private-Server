package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class ItemPurchasedDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var mc_container:Sprite = new Sprite();
      
      private var txt_message:BodyTextField;
      
      private var ui_image:UIImage;
      
      public function ItemPurchasedDialogue(param1:String, param2:String, param3:String, param4:Number = 200, param5:Number = 200, param6:uint = 8113445)
      {
         super("fuel-purchased",this.mc_container);
         this._lang = Language.getInstance();
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = 6;
         addTitle(param1,param6);
         addButton(this._lang.getString("buy_item_complete_ok"),true,{"width":100});
         var _loc7_:int = 0;
         var _loc8_:int = int(_padding * 0.5);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,param4 + 6,param5 + 6,0,_loc8_);
         this.ui_image = new UIImage(param4,param5);
         this.ui_image.uri = param3;
         this.ui_image.x = _loc7_ + 3;
         this.ui_image.y = _loc8_ + 3;
         this.mc_container.addChild(this.ui_image);
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":13,
            "multiline":true,
            "align":TextFormatAlign.CENTER,
            "width":this.ui_image.width,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_message.htmlText = param2;
         this.txt_message.x = int(this.ui_image.x);
         this.txt_message.y = int(this.ui_image.y + this.ui_image.height) + 4;
         this.mc_container.addChild(this.txt_message);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_message.dispose();
         this.ui_image.dispose();
         this._lang = null;
      }
   }
}

