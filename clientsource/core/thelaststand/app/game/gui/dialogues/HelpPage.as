package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.utils.StringUtils;
   
   public class HelpPage extends Sprite
   {
      
      private var _width:int = 420;
      
      private var _height:int = 176;
      
      private var ui_image:UIImage;
      
      private var txt_title:BodyTextField;
      
      private var txt_body:BodyTextField;
      
      public function HelpPage(param1:String, param2:String, param3:String)
      {
         super();
         this.ui_image = new UIImage(150,150);
         this.ui_image.x = this.ui_image.y = 12;
         this.ui_image.uri = param1;
         addChild(this.ui_image);
         this.txt_title = new BodyTextField({
            "htmlText":StringUtils.htmlSetDoubleBreakLeading(param2),
            "color":16777215,
            "size":18,
            "bold":true,
            "multiline":true
         });
         this.txt_title.x = int(this.ui_image.x + this.ui_image.width + 12);
         this.txt_title.y = int(this.ui_image.y + 2);
         this.txt_title.width = int(this._width - this.txt_title.x - 12);
         addChild(this.txt_title);
         this.txt_body = new BodyTextField({
            "color":10197915,
            "size":14,
            "multiline":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_body.htmlText = StringUtils.htmlSetDoubleBreakLeading(param3);
         this.txt_body.x = this.txt_title.x;
         this.txt_body.y = int(this.txt_title.y + this.txt_title.height + 4);
         this.txt_body.width = int(this.txt_title.width);
         addChild(this.txt_body);
      }
      
      public function dispose() : void
      {
         this.ui_image.dispose();
         this.txt_title.dispose();
         this.txt_body.dispose();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

