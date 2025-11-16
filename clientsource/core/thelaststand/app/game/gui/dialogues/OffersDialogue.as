package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.game.gui.lists.UIOffersList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.OfferSystem;
   import thelaststand.common.lang.Language;
   
   public class OffersDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _offers:OfferSystem;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_list:UIOffersList;
      
      private var ui_page:UIPagination;
      
      public function OffersDialogue(param1:String = null)
      {
         super("offers",this.mc_container,true);
         this._lang = Language.getInstance();
         addTitle(this._lang.getString("offers_title"),BaseDialogue.TITLE_COLOR_GREY);
         this.ui_list = new UIOffersList();
         this.mc_container.addChild(this.ui_list);
         if(param1 != null)
         {
            this.ui_list.gotoItem(param1);
         }
         this.ui_page = new UIPagination(this.ui_list.numPages,this.ui_list.currentPage);
         this.ui_page.maxDots = 16;
         this.ui_page.x = int((this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.height + 10);
         this.ui_page.changed.add(this.onPageChanged);
         this.mc_container.addChild(this.ui_page);
         _autoSize = false;
         _width = this.ui_list.width + _padding * 2;
         _height = int(this.ui_page.y + this.ui_page.height + _padding * 2);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this._offers = null;
         this.ui_page.dispose();
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
   }
}

