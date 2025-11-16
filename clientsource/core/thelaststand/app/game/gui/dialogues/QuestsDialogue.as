package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class QuestsDialogue extends BaseDialogue
   {
      
      public static var _previousCategory:String = "tasks";
      
      private var _lang:Language;
      
      private var _selectedCategory:String;
      
      private var _selectedCategoryButton:PushButton;
      
      private var _selectedPage:Sprite;
      
      private var bmp_icon:Bitmap;
      
      private var btn_tasks:PushButton;
      
      private var btn_achievements:PushButton;
      
      private var mc_container:Sprite = new Sprite();
      
      private var mc_tasks:QuestsTasks;
      
      private var mc_achievements:QuestsAchievements;
      
      public function QuestsDialogue(param1:String = null, param2:Object = null)
      {
         super("quests",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 678;
         _height = 468;
         var _loc3_:Quest = param2 as Quest;
         if(_loc3_ != null)
         {
            if(!_loc3_.isAchievement)
            {
               QuestsTasks.previousCategory = "all";
               QuestsTasks.previousQuest = _loc3_.id;
            }
         }
         addTitle(this._lang.getString("quests_title"),BaseDialogue.TITLE_COLOR_GREY);
         this.bmp_icon = new Bitmap(new BmpIconHUDObjectives(),"auto",true);
         this.bmp_icon.x = _padding - 6;
         this.bmp_icon.y = 2;
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         this.bmp_icon.scaleX = this.bmp_icon.scaleY = 0.75;
         sprite.addChild(this.bmp_icon);
         this.btn_tasks = new PushButton(this._lang.getString("quests_tasks"),new BmpIconQuest(),1280197);
         this.btn_tasks.selectedColor = 1386314;
         this.btn_tasks.clicked.add(this.onCategoryButtonClicked);
         this.btn_tasks.width = 139;
         this.btn_tasks.x = 4;
         this.btn_tasks.y = 8;
         this.mc_container.addChild(this.btn_tasks);
         this.btn_achievements = new PushButton(this._lang.getString("quests_achievements"),new BmpIconAchievement(),6918152);
         this.btn_achievements.selectedColor = 3424277;
         this.btn_achievements.clicked.add(this.onCategoryButtonClicked);
         this.btn_achievements.width = this.btn_tasks.width;
         this.btn_achievements.x = int(this.btn_tasks.x + this.btn_tasks.width + 17);
         this.btn_achievements.y = this.btn_tasks.y;
         this.mc_container.addChild(this.btn_achievements);
         this.mc_tasks = new QuestsTasks();
         this.mc_tasks.y = this.btn_tasks.y;
         this.mc_achievements = new QuestsAchievements();
         this.mc_achievements.y = this.mc_tasks.y;
         this.selectCategory(param1 != null ? param1 : _previousCategory);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.btn_tasks.dispose();
         this.btn_tasks = null;
         this.btn_achievements.dispose();
         this.btn_achievements = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon.filters = [];
         this.bmp_icon = null;
         this.mc_tasks.dispose();
         this.mc_tasks = null;
         this.mc_achievements.dispose();
         this.mc_achievements = null;
      }
      
      override public function open() : void
      {
         super.open();
         txt_title.x = _padding + 38;
      }
      
      override public function close() : void
      {
         super.close();
         QuestSystem.getInstance().clearNewFlags();
      }
      
      private function selectCategory(param1:String) : void
      {
         if(param1 == this._selectedCategory)
         {
            return;
         }
         if(this._selectedCategoryButton != null)
         {
            this._selectedCategoryButton.selected = false;
            this._selectedCategoryButton.mouseEnabled = true;
         }
         if(this._selectedPage != null && this._selectedPage.parent != null)
         {
            this._selectedPage.parent.removeChild(this._selectedPage);
         }
         switch(param1)
         {
            case "tasks":
               this._selectedCategoryButton = this.btn_tasks;
               this._selectedPage = this.mc_tasks;
               break;
            case "achievements":
               this._selectedCategoryButton = this.btn_achievements;
               this._selectedPage = this.mc_achievements;
         }
         this._selectedCategoryButton.selected = true;
         this._selectedCategoryButton.mouseEnabled = false;
         this._selectedCategory = param1;
         this.mc_container.addChild(this._selectedPage);
         Tracking.trackPageview("quests/" + this._selectedCategory);
         _previousCategory = param1;
      }
      
      private function onCategoryButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_tasks:
               this.selectCategory("tasks");
               break;
            case this.btn_achievements:
               this.selectCategory("achievements");
         }
      }
   }
}

