package thelaststand.app.game.gui.arena
{
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ArenaPageHome extends ArenaDialoguePage
   {
      
      private var mc_newsPanel:Sprite;
      
      private var ui_homeImage:UIImage;
      
      private var txt_title:BodyTextField;
      
      private var txt_news:BodyTextField;
      
      private var ui_rewards:ArenaRewardsView;
      
      public function ArenaPageHome(param1:ArenaSession)
      {
         super(param1);
         this.ui_homeImage = new UIImage(1,1,0,1,false,"images/arena/" + param1.name + "_home.jpg");
         this.ui_homeImage.x = this.ui_homeImage.y = 3;
         this.txt_title = new BodyTextField({
            "color":16760832,
            "size":14,
            "bold":true,
            "multiline":true
         });
         this.txt_news = new BodyTextField({
            "color":16250871,
            "size":14,
            "bold":true,
            "multiline":true
         });
         this.mc_newsPanel = new Sprite();
         this.mc_newsPanel.addChild(this.ui_homeImage);
         this.mc_newsPanel.addChild(this.txt_title);
         this.mc_newsPanel.addChild(this.txt_news);
         addChild(this.mc_newsPanel);
         this.ui_rewards = new ArenaRewardsView();
         this.ui_rewards.setData(param1);
         addChild(this.ui_rewards);
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override protected function draw() : void
      {
         this.ui_rewards.width = width;
         this.ui_rewards.height = 150;
         this.ui_rewards.x = 0;
         this.ui_rewards.y = height - this.ui_rewards.height;
         var _loc1_:int = width;
         var _loc2_:int = this.ui_rewards.y - 5;
         this.mc_newsPanel.graphics.clear();
         GraphicUtils.drawUIBlock(this.mc_newsPanel.graphics,_loc1_,_loc2_);
         this.ui_homeImage.width = int(_loc1_ - this.ui_homeImage.x * 2);
         this.ui_homeImage.height = int(_loc2_ - this.ui_homeImage.y * 2);
         this.txt_title.htmlText = Language.getInstance().getString("arena." + _session.name + ".news_title");
         this.txt_news.htmlText = Language.getInstance().getString("arena." + _session.name + ".news_msg");
         this.txt_title.width = int(_loc1_ * 0.45);
         this.txt_title.x = 10;
         this.txt_title.y = 8;
         this.txt_news.width = int(this.txt_title.width);
         this.txt_news.x = int(this.txt_title.x);
         this.txt_news.y = int(this.txt_title.y + this.txt_title.height + 10);
      }
   }
}

