package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.lists.UINewsList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   
   public class NewsDialogue extends BaseDialogue
   {
      
      private var bmp_icon:Bitmap;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_list:UINewsList;
      
      private var ui_page:UIPagination;
      
      public function NewsDialogue()
      {
         super("news-dialogue",this.mc_container,true);
         _autoSize = false;
         _width = 448;
         _height = 250;
         addTitle(Language.getInstance().getString("news_title"),BaseDialogue.TITLE_COLOR_RUST);
         this.bmp_icon = new Bitmap(new BmpIconHUDNews(),"auto",true);
         this.bmp_icon.x = _padding - 6;
         this.bmp_icon.y = -2;
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         sprite.addChild(this.bmp_icon);
         this.ui_list = new UINewsList();
         this.ui_list.width = 420;
         this.ui_list.height = 172;
         this.ui_list.y = int(_padding * 0.5);
         this.ui_list.articles = Network.getInstance().data.news;
         this.mc_container.addChild(this.ui_list);
         this.ui_page = new UIPagination();
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.changed.add(this.onPageChanged);
         this.ui_page.x = int(this.ui_list.x + int(this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 12);
         this.mc_container.addChild(this.ui_page);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_list.dispose();
         this.ui_page.dispose();
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon.filters = [];
         this.bmp_icon = null;
      }
      
      override public function open() : void
      {
         super.open();
         txt_title.x = _padding + 38;
      }
      
      override public function close() : void
      {
         Network.getInstance().save(null,SaveDataMethod.NEWS_READ);
         super.close();
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
   }
}

