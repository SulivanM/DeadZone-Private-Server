package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.game.gui.lists.UIOffersListItem;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class PromoCodeClaimedDialogue extends BaseDialogue
   {
      
      private var _data:Object;
      
      private var mc_container:Sprite;
      
      private var ui_offer:UIOffersListItem;
      
      private var btn_ok:PushButton;
      
      public function PromoCodeClaimedDialogue(param1:Object)
      {
         var _loc2_:int = 0;
         this.mc_container = new Sprite();
         super("codeclaimed-" + param1.key,this.mc_container);
         this._data = param1;
         addTitle(Language.getInstance().getString("promocode_claimed"),BaseDialogue.TITLE_COLOR_GREY);
         _loc2_ = 3;
         var _loc3_:int = _padding * 0.5;
         this.ui_offer = new UIOffersListItem();
         this.ui_offer.x = _loc2_;
         this.ui_offer.y = _loc3_ + _loc2_;
         this.ui_offer.offer = this._data;
         this.mc_container.addChild(this.ui_offer);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this.ui_offer.width + _loc2_ * 2,this.ui_offer.height + _loc2_ * 2,0,_loc3_);
         this.btn_ok = new PushButton(Language.getInstance().getString("promocode_claimed_ok"));
         this.btn_ok.width = 120;
         this.btn_ok.x = int(this.ui_offer.x + (this.ui_offer.width - this.btn_ok.width) * 0.5);
         this.btn_ok.y = int(this.ui_offer.y + this.ui_offer.height - this.btn_ok.height - 8);
         this.btn_ok.clicked.addOnce(this.onClickOK);
         this.mc_container.addChild(this.btn_ok);
         _width = int(this.ui_offer.x + this.ui_offer.width + _loc2_ * 2 + _padding * 2);
         _height = int(this.ui_offer.y + this.ui_offer.height + _loc2_ * 2 + _padding * 2 + 4);
         _autoSize = false;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._data = null;
         this.ui_offer.dispose();
         this.btn_ok.dispose();
      }
      
      private function onClickOK(param1:MouseEvent) : void
      {
         close();
      }
   }
}

