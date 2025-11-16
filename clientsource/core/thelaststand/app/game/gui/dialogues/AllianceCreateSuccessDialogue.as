package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AllianceCreateSuccessDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var mc_container:Sprite;
      
      private var btn_continue:PushButton;
      
      private var txt_desc:BodyTextField;
      
      private var ui_image:UIImage;
      
      private var bannerBMP:Bitmap;
      
      public function AllianceCreateSuccessDialogue(param1:BitmapData)
      {
         var _loc3_:String = null;
         this.mc_container = new Sprite();
         super("alliance-create",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 480;
         _height = 230;
         addTitle(this._lang.getString("alliance.create_successTitle"),Effects.COLOR_GOOD);
         var _loc2_:int = _padding * 0.5;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,234,194,0,_loc2_);
         this.ui_image = new UIImage(230,190);
         this.ui_image.uri = "images/alliances/alliance-created.jpg";
         this.ui_image.x = 2;
         this.ui_image.y = _loc2_ + 2;
         this.mc_container.addChild(this.ui_image);
         this.bannerBMP = new Bitmap(param1,"auto",true);
         this.bannerBMP.scaleX = this.bannerBMP.scaleY = 0.85;
         this.bannerBMP.x = this.ui_image.x + int((this.ui_image.width - this.bannerBMP.width) * 0.5);
         this.bannerBMP.y = this.ui_image.y + int((this.ui_image.height - this.bannerBMP.height) * 0.5);
         this.mc_container.addChild(this.bannerBMP);
         if(AllianceSystem.getInstance().clientMember.joinDate.time > AllianceSystem.getInstance().round.activeTime.time)
         {
            _loc3_ = this._lang.getString("alliance.create_successDesc_enlisting");
         }
         else
         {
            _loc3_ = this._lang.getString("alliance.create_successDesc");
         }
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true,
            "bold":false
         });
         this.txt_desc.htmlText = _loc3_;
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.txt_desc.x = int(this.ui_image.x + this.ui_image.width + 8);
         this.txt_desc.y = int(this.ui_image.y);
         this.txt_desc.width = int(_width - this.txt_desc.x - _padding * 2);
         this.mc_container.addChild(this.txt_desc);
         this.btn_continue = new PushButton(this._lang.getString("alliance.create_continue"));
         this.btn_continue.clicked.add(this.onContinue);
         this.btn_continue.width = 194;
         this.btn_continue.x = int(this.txt_desc.x + (this.txt_desc.width - this.btn_continue.width) * 0.5);
         this.btn_continue.y = int(this.ui_image.y + this.ui_image.height - this.btn_continue.height - 4);
         this.mc_container.addChild(this.btn_continue);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.ui_image.dispose();
         this.txt_desc.dispose();
         this.btn_continue.dispose();
         if(Boolean(this.bannerBMP) && Boolean(this.bannerBMP.bitmapData))
         {
            this.bannerBMP.bitmapData.dispose();
         }
         this.bannerBMP = null;
      }
      
      private function onContinue(param1:MouseEvent) : void
      {
         close();
      }
   }
}

