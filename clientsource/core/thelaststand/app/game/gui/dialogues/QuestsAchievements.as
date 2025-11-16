package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.gui.lists.UIAchievementList;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class QuestsAchievements extends Sprite
   {
      
      private static var _sortType:String = UIAchievementList.SORT_XP;
      
      private var _achievements:Vector.<Quest>;
      
      private var _lang:Language;
      
      private var btn_sortAlpha:PushButton;
      
      private var btn_sortXP:PushButton;
      
      private var bmp_unlocked:Bitmap;
      
      private var txt_unlocked:BodyTextField;
      
      private var ui_list:UIAchievementList;
      
      private var ui_page:UIPagination;
      
      public function QuestsAchievements()
      {
         super();
         this._lang = Language.getInstance();
         this._achievements = QuestSystem.getInstance().getAchievements(true);
         var _loc1_:int = 506;
         var _loc2_:int = -2;
         GraphicUtils.drawUIBlock(graphics,144,30,_loc1_,_loc2_);
         this.bmp_unlocked = new Bitmap(new BmpIconUnlocked());
         this.bmp_unlocked.x = int(_loc1_ - this.bmp_unlocked.width - 4);
         this.bmp_unlocked.y = int(_loc2_ + (30 - this.bmp_unlocked.height) * 0.5);
         addChild(this.bmp_unlocked);
         this.txt_unlocked = new BodyTextField({
            "text":" ",
            "color":11316396,
            "size":16,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.STROKE]
         });
         this.txt_unlocked.maxWidth = 138;
         this.txt_unlocked.x = int(_loc1_ + (144 - this.txt_unlocked.width) * 0.5);
         this.txt_unlocked.y = int(_loc2_ + (30 - this.txt_unlocked.height) * 0.5);
         addChild(this.txt_unlocked);
         this.btn_sortAlpha = new PushButton("",new BmpIconSortAlpha());
         this.btn_sortAlpha.clicked.add(this.onClickSortButton);
         this.btn_sortAlpha.width = this.btn_sortAlpha.height;
         this.btn_sortAlpha.x = int(this.bmp_unlocked.x - this.btn_sortAlpha.width - 20);
         this.btn_sortAlpha.y = 0;
         this.btn_sortAlpha.selected = _sortType == UIAchievementList.SORT_ALPHABETICAL;
         addChild(this.btn_sortAlpha);
         this.btn_sortXP = new PushButton("",new BmpIconSortXP());
         this.btn_sortXP.clicked.add(this.onClickSortButton);
         this.btn_sortXP.width = this.btn_sortXP.height;
         this.btn_sortXP.x = int(this.btn_sortAlpha.x - this.btn_sortXP.width - 12);
         this.btn_sortXP.y = int(this.btn_sortAlpha.y);
         this.btn_sortXP.selected = _sortType == UIAchievementList.SORT_XP;
         addChild(this.btn_sortXP);
         this.ui_list = new UIAchievementList();
         this.ui_list.width = 650;
         this.ui_list.height = 364;
         this.ui_list.y = 32;
         this.ui_list.sort = _sortType;
         this.ui_list.achievements = this._achievements;
         addChild(this.ui_list);
         this.ui_page = new UIPagination(this.ui_list.numPages);
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 10);
         this.ui_page.changed.add(this.onPageChanged);
         addChild(this.ui_page);
         QuestSystem.getInstance().achievementReceived.add(this.onAchievementReceived);
         this.updateCompleteCount();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         QuestSystem.getInstance().achievementReceived.remove(this.onAchievementReceived);
         this._lang = null;
         this._achievements = null;
         this.bmp_unlocked.bitmapData.dispose();
         this.bmp_unlocked.bitmapData = null;
         this.txt_unlocked.dispose();
         this.txt_unlocked = null;
         this.ui_page.dispose();
         this.ui_page = null;
         this.ui_list.dispose();
         this.ui_list = null;
      }
      
      private function updateCompleteCount() : void
      {
         var _loc1_:int = QuestSystem.getInstance().numAchievementsCompleted;
         var _loc2_:int = int(this._achievements.length);
         this.txt_unlocked.text = this._lang.getString("quests_unlocked",NumberFormatter.format(_loc1_,0) + " / " + NumberFormatter.format(_loc2_,0));
         this.txt_unlocked.x = int(506 + (144 - this.txt_unlocked.width) * 0.5);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
      
      private function onAchievementReceived(param1:Quest) : void
      {
         this._achievements = QuestSystem.getInstance().getAchievements(true);
         var _loc2_:int = this.ui_list.currentPage;
         this.ui_list.achievements = this._achievements;
         this.ui_list.gotoPage(_loc2_,false);
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.currentPage = this.ui_list.currentPage;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.updateCompleteCount();
      }
      
      private function onClickSortButton(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_sortAlpha:
               if(this.btn_sortAlpha.selected)
               {
                  return;
               }
               this.btn_sortXP.selected = false;
               this.btn_sortAlpha.selected = true;
               this.ui_list.sort = UIAchievementList.SORT_ALPHABETICAL;
               _sortType = this.ui_list.sort;
               break;
            case this.btn_sortXP:
               if(this.btn_sortXP.selected)
               {
                  return;
               }
               this.btn_sortXP.selected = true;
               this.btn_sortAlpha.selected = false;
               this.ui_list.sort = UIAchievementList.SORT_XP;
               _sortType = this.ui_list.sort;
         }
      }
   }
}

