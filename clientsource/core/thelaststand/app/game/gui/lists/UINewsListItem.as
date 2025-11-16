package thelaststand.app.game.gui.lists
{
   import flash.text.StyleSheet;
   import thelaststand.app.data.NewsArticle;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class UINewsListItem extends UIPagedListItem
   {
      
      private static var STYLESHEET:StyleSheet;
      
      private var _article:NewsArticle;
      
      private var txt_body:BodyTextField;
      
      public function UINewsListItem()
      {
         super();
         if(STYLESHEET == null)
         {
            STYLESHEET = new StyleSheet();
            STYLESHEET.setStyle("title",{
               "fontFamily":Language.getInstance().getFontName("title"),
               "fontSize":18
            });
            STYLESHEET.setStyle("a",{
               "color":"#D14923",
               "textDecoration":"underline"
            });
         }
         _width = 420;
         _height = 178;
         this.txt_body = new BodyTextField({
            "color":12961221,
            "multiline":true,
            "size":14
         });
         this.txt_body.styleSheet = STYLESHEET;
         addChild(this.txt_body);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_body.dispose();
         this._article = null;
      }
      
      public function get article() : NewsArticle
      {
         return this._article;
      }
      
      public function set article(param1:NewsArticle) : void
      {
         this._article = param1;
         this.txt_body.htmlText = StringUtils.htmlSetDoubleBreakLeading(this.article.body);
         var _loc2_:* = this.article.body.indexOf("<img") > -1;
         if(_loc2_)
         {
            this.txt_body.x = 1;
            this.txt_body.y = 1;
         }
         else
         {
            this.txt_body.x = 10;
            this.txt_body.y = 8;
         }
         this.txt_body.width = int(_width - this.txt_body.x - 10);
         this.txt_body.height = int(_height - this.txt_body.y * 2);
      }
   }
}

