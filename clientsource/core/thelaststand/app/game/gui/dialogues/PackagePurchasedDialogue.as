package thelaststand.app.game.gui.dialogues
{
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class PackagePurchasedDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var mc_container:Sprite = new Sprite();
      
      private var bmp_titleBg:Bitmap;
      
      private var txt_packTitle:BodyTextField;
      
      private var txt_message:BodyTextField;
      
      private var ui_image:UIImage;
      
      public function PackagePurchasedDialogue(param1:String, param2:String)
      {
         super("package-purchased",this.mc_container);
         this._lang = Language.getInstance();
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = 6;
         addButton(this._lang.getString("buy_item_complete_ok"),true,{"width":100});
         var _loc3_:int = 292;
         var _loc4_:int = 226;
         var _loc5_:int = 4;
         this.bmp_titleBg = new Bitmap(new BmpOffersHeader(),"auto",true);
         this.bmp_titleBg.width = _loc3_;
         this.bmp_titleBg.scaleY = this.bmp_titleBg.scaleX;
         this.bmp_titleBg.x = _loc5_;
         this.bmp_titleBg.y = _loc5_;
         var _loc6_:ColorMatrix = new ColorMatrix();
         _loc6_.colorize(5344038);
         this.bmp_titleBg.filters = [_loc6_.filter];
         this.mc_container.addChild(this.bmp_titleBg);
         this.txt_packTitle = new BodyTextField({
            "color":14548420,
            "size":22,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_packTitle.maxWidth = int(this.bmp_titleBg.width - 10);
         this.txt_packTitle.htmlText = param1.toUpperCase();
         this.txt_packTitle.x = int(this.bmp_titleBg.x + (this.bmp_titleBg.width - this.txt_packTitle.width) * 0.5);
         this.txt_packTitle.y = int(this.bmp_titleBg.y + (this.bmp_titleBg.height - this.txt_packTitle.height) * 0.5);
         this.mc_container.addChild(this.txt_packTitle);
         this.ui_image = new UIImage(_loc3_,_loc4_);
         this.ui_image.uri = "images/ui/buy-package.jpg";
         this.ui_image.x = _loc5_;
         this.ui_image.y = int(this.bmp_titleBg.y + this.bmp_titleBg.height + _loc5_);
         this.mc_container.addChild(this.ui_image);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc3_ + _loc5_ * 2,this.ui_image.y + this.ui_image.height + _loc5_);
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
         this.txt_message.y = int(this.ui_image.y + this.ui_image.height) + 10;
         this.mc_container.addChild(this.txt_message);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_titleBg.bitmapData.dispose();
         this.txt_message.dispose();
         this.ui_image.dispose();
         this.txt_packTitle.dispose();
         this._lang = null;
      }
   }
}

