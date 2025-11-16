package thelaststand.app.game.gui.dialogues
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.buttons.AbstractButton;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class HelpDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var mc_container:Sprite;
      
      private var ui_scroll:UIScrollBar;
      
      private var txt_body:BodyTextField;
      
      private var txtContainer:Sprite;
      
      private var _mask:Shape;
      
      public function HelpDialogue(param1:String)
      {
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         this.mc_container = new Sprite();
         super("HelpDialogue",this.mc_container,true);
         this._lang = Language.getInstance();
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = 6;
         addTitle(this._lang.getString("help_title"),BaseDialogue.TITLE_COLOR_GREY,-1,new BmpIconHelp());
         var _loc2_:AbstractButton = addButton(this._lang.getString("help_close"),true,{"width":150});
         var _loc3_:int = int(_padding * 0.5 + 2);
         _loc4_ = 360;
         this.txtContainer = new Sprite();
         this.txtContainer.y = _loc3_ + 2;
         this.mc_container.addChild(this.txtContainer);
         this.txt_body = new BodyTextField({
            "border":false,
            "width":_loc4_ - 12,
            "color":10066329,
            "wordWrap":true,
            "multiline":true,
            "autoSize":"left"
         });
         this.txt_body.x = 6;
         this.txt_body.htmlText = this._lang.getString(param1);
         this.txt_body.mouseEnabled = true;
         this.txt_body.addEventListener(TextEvent.LINK,this.onLinkClicked,false,0,true);
         this.txtContainer.addChild(this.txt_body);
         var _loc5_:Number = 380;
         _loc6_ = Math.min(Math.max(this.txt_body.height,100),_loc5_);
         var _loc7_:Boolean = false;
         if(this.txt_body.height > _loc5_)
         {
            this.txt_body.width -= 10;
            _loc7_ = true;
         }
         this._mask = new Shape();
         this._mask.graphics.beginFill(16711680,0.5);
         this._mask.graphics.drawRect(0,0,_loc4_,_loc6_);
         this._mask.y = 1;
         this.txtContainer.addChild(this._mask);
         this.txt_body.mask = this._mask;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc4_ + 2,this.txtContainer.y + _loc6_ + 4,-1,_loc3_ - 2);
         this.ui_scroll = new UIScrollBar();
         this.ui_scroll.wheelArea = this._mask;
         this.ui_scroll.x = _loc4_ - this.ui_scroll.width;
         this.ui_scroll.y = _loc3_;
         this.ui_scroll.height = _loc6_;
         this.ui_scroll.contentHeight = this.txt_body.height;
         this.ui_scroll.changed.add(this.onScrollbarChanged);
         if(_loc7_)
         {
            this.mc_container.addChild(this.ui_scroll);
         }
         _autoSize = false;
         _width = _loc4_ + _padding * 2;
         _height = this.txtContainer.y + _loc6_ + _padding * 2 + 56;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.ui_scroll.destroy();
         this.txt_body.dispose();
      }
      
      private function onScrollbarChanged(param1:Number) : void
      {
         this.txt_body.y = -(this.txt_body.height - this._mask.height) * param1;
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         navigateToURL(new URLRequest(param1.text),"_blank");
      }
   }
}

