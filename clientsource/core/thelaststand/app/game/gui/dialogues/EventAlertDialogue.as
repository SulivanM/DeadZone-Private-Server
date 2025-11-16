package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.gui.buttons.AbstractButton;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class EventAlertDialogue extends BaseDialogue
   {
      
      public static const ALIGN_LEFT:String = "left";
      
      public static const ALIGN_CENTER:String = "center";
      
      private var _align:String;
      
      private var _lang:Language = Language.getInstance();
      
      private var bmp_titleIcon:Bitmap;
      
      private var btn_ok:PushButton;
      
      private var mc_container:Sprite = new Sprite();
      
      private var mc_image:UIImage;
      
      private var txt_subtitle:BodyTextField;
      
      private var txt_body:BodyTextField;
      
      public function EventAlertDialogue(param1:String = null, param2:int = 270, param3:int = 152, param4:String = "left", param5:String = "event-alert", param6:Boolean = true)
      {
         super(param5,this.mc_container,param6);
         _autoSize = true;
         _width = int(param2 + 420);
         _padding = 14;
         this._align = param4;
         _buttonAlign = param4 == "left" ? Dialogue.BUTTON_ALIGN_RIGHT : Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = param4 == "left" ? -36 : 0;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,param2 + 6,param3 + 6,0,_padding * 0.5);
         this.mc_image = new UIImage(param2,param3,0,0,true,param1);
         this.mc_image.x = 3;
         this.mc_image.y = int(_padding * 0.5 + 3);
         this.mc_container.addChild(this.mc_image);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.mc_image.dispose();
         if(this.bmp_titleIcon != null)
         {
            this.bmp_titleIcon.bitmapData.dispose();
            this.bmp_titleIcon.bitmapData = null;
         }
         this._lang = null;
      }
      
      override public function addButton(param1:String, param2:Boolean = true, param3:Object = null) : AbstractButton
      {
         param3 ||= {};
         if(!param3.hasOwnProperty("width"))
         {
            param3.width = 120;
         }
         return super.addButton(param1,param2,param3);
      }
      
      public function addShareButton(param1:Object = null) : PushButton
      {
         param1 ||= {};
         param1.buttonClass = PurchasePushButton;
         var _loc2_:PurchasePushButton = this.addButton(this._lang.getString("share"),true,param1) as PurchasePushButton;
         _loc2_.showIcon = false;
         return _loc2_;
      }
      
      public function addSubtitle(param1:String) : void
      {
         this.txt_subtitle = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true
         });
         this.txt_subtitle.text = param1;
         this.txt_subtitle.filters = [Effects.TEXT_SHADOW];
         switch(this._align)
         {
            case ALIGN_LEFT:
               this.txt_subtitle.x = int(this.mc_image.x + this.mc_image.width + 13);
               this.txt_subtitle.y = int(this.mc_image.y - 4);
               break;
            case ALIGN_CENTER:
               this.txt_subtitle.x = int(this.mc_image.x);
               this.txt_subtitle.y = int(this.mc_image.y + this.mc_image.height + 10);
         }
         this.mc_container.addChild(this.txt_subtitle);
      }
      
      public function addBody(param1:String) : void
      {
         this.txt_body = new BodyTextField({
            "color":16777215,
            "size":13,
            "multiline":true
         });
         this.txt_body.htmlText = StringUtils.htmlSetDoubleBreakLeading(param1);
         this.txt_body.width = this._align == ALIGN_CENTER ? this.mc_image.width : (this.txt_subtitle != null ? Math.max(this.txt_subtitle.width,216) : 216);
         this.txt_body.filters = [Effects.TEXT_SHADOW];
         switch(this._align)
         {
            case ALIGN_LEFT:
               this.txt_body.x = int(this.mc_image.x + this.mc_image.width + 13);
               this.txt_body.y = this.txt_subtitle != null ? int(this.txt_subtitle.y + this.txt_subtitle.height + 2) : int(this.mc_image.y - 4);
               break;
            case ALIGN_CENTER:
               this.txt_body.x = int(this.mc_image.x);
               this.txt_body.y = this.txt_subtitle != null ? int(this.txt_subtitle.y + this.txt_subtitle.height + 2) : int(this.mc_image.y + this.mc_image.height + 10);
         }
         this.mc_container.addChild(this.txt_body);
      }
      
      public function addTitleIcon(param1:BitmapData) : void
      {
         this.bmp_titleIcon = new Bitmap(param1,"auto",true);
         this.bmp_titleIcon.height = Math.min(param1.height,46);
         this.bmp_titleIcon.scaleX = this.bmp_titleIcon.scaleY;
         this.bmp_titleIcon.x = _padding - 6;
         this.bmp_titleIcon.y = 2;
         sprite.addChild(this.bmp_titleIcon);
      }
      
      override public function open() : void
      {
         super.open();
         if(this.bmp_titleIcon != null)
         {
            txt_title.x = _padding + this.bmp_titleIcon.width;
         }
      }
   }
}

