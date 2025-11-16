package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.game.gui.lists.UIContentList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class TutorialHelpDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _pages:Vector.<Sprite>;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_list:UIContentList;
      
      private var ui_page:UIPagination;
      
      public function TutorialHelpDialogue(param1:String, param2:Vector.<Sprite>)
      {
         super("pvpHelp",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 442;
         _height = 256;
         this._pages = param2;
         addTitle(param1,BaseDialogue.TITLE_COLOR_GREY,-1,new BmpIconHelp());
         this.ui_list = new UIContentList(this._pages[0].width,this._pages[0].height);
         this.ui_list.width = this._pages[0].width;
         this.ui_list.height = this._pages[0].height;
         this.ui_list.content = this._pages;
         this.ui_list.y = 4;
         this.mc_container.addChild(this.ui_list);
         this.ui_page = new UIPagination();
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.changed.add(this.onPageChanged);
         this.ui_page.x = int((_width - _padding * 2 - this.ui_page.width) * 0.5);
         this.ui_page.y = int(_height - _padding * 2 - this.ui_page.height);
         this.mc_container.addChild(this.ui_page);
      }
      
      override public function dispose() : void
      {
         var _loc1_:HelpPage = null;
         super.dispose();
         this.ui_list.dispose();
         this.ui_page.dispose();
         for each(_loc1_ in this._pages)
         {
            _loc1_.dispose();
         }
         this._pages = null;
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
   }
}

