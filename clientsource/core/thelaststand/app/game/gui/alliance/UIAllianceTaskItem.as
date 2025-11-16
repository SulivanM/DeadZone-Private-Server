package thelaststand.app.game.gui.alliance
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.GradientType;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.alliance.AllianceTask;
   import thelaststand.app.game.gui.UISimpleProgressBar;
   import thelaststand.app.game.gui.dialogues.AllianceTaskContributeDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceTaskItem extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _task:AllianceTask;
      
      private var txt_title:TitleTextField;
      
      private var txt_goal:BodyTextField;
      
      private var txt_tokens:BodyTextField;
      
      private var bmp_tokens:Bitmap;
      
      private var btn_donate:PushButton;
      
      private var ui_image:UIImage;
      
      private var ui_progress:UISimpleProgressBar;
      
      private var _showRequirements:Boolean = true;
      
      public function UIAllianceTaskItem(param1:AllianceTask, param2:int, param3:int)
      {
         super();
         this.task = param1;
         this._width = param2;
         this._height = param3;
         this.ui_image = new UIImage(44,44);
         addChild(this.ui_image);
         this.txt_title = new TitleTextField({
            "color":16777215,
            "size":17,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.text = " ";
         addChild(this.txt_title);
         this.txt_goal = new BodyTextField({
            "color":11579568,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_goal.text = " ";
         addChild(this.txt_goal);
         this.bmp_tokens = new Bitmap(new BmpIconAllianceTokensSmall());
         addChild(this.bmp_tokens);
         this.txt_tokens = new BodyTextField({
            "color":16777215,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_tokens.text = " ";
         addChild(this.txt_tokens);
         this.ui_progress = new UISimpleProgressBar(4878893,2434341,4934475);
         this.ui_progress.width = 90;
         this.ui_progress.height = 6;
         addChild(this.ui_progress);
         TooltipManager.getInstance().add(this,this.getTooltip,new Point(NaN,6),TooltipDirection.DIRECTION_DOWN,0);
      }
      
      public function get task() : AllianceTask
      {
         return this._task;
      }
      
      public function set task(param1:AllianceTask) : void
      {
         if(param1 == this._task)
         {
            return;
         }
         this._task = param1;
         this._task.progressChanged.add(this.onTaskProgressChanged);
         invalidate();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get showRequirements() : Boolean
      {
         return this._showRequirements;
      }
      
      public function set showRequirements(param1:Boolean) : void
      {
         this._showRequirements = param1;
         this.txt_goal.visible = this._showRequirements;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TweenMax.killTweensOf(this);
         TweenMax.killChildTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this);
         this._task.progressChanged.remove(this.onTaskProgressChanged);
         this._task = null;
         this.ui_image.dispose();
         this.ui_progress.dispose();
         this.txt_title.dispose();
         this.txt_goal.dispose();
         this.txt_tokens.dispose();
         if(this.btn_donate != null)
         {
            this.btn_donate.dispose();
         }
      }
      
      override protected function draw() : void
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:uint = 4013373;
         _loc2_ = 4934475;
         if(this._task.isComplete)
         {
            _loc1_ = 3951663;
            _loc2_ = new Color(_loc1_).tint(16777215,0.05).RGB;
         }
         graphics.clear();
         graphics.beginFill(_loc2_);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(_loc1_);
         graphics.drawRect(1,1,this._width - 2,this._height - 2);
         graphics.endFill();
         this.ui_image.y = int((this._height - this.ui_image.height) * 0.5);
         this.ui_image.x = this.ui_image.y;
         this.ui_image.uri = this._task.imageURI;
         this.ui_image.mouseEnabled = false;
         graphics.beginFill(_loc2_);
         graphics.drawRect(this.ui_image.x - 1,this.ui_image.y - 1,this.ui_image.width + 2,this.ui_image.height + 2);
         graphics.endFill();
         _loc3_ = int(this.ui_image.x + this.ui_image.width + 5);
         var _loc4_:int = int(this.ui_image.y);
         var _loc5_:int = int(this._width - _loc3_ - this.ui_image.x);
         _loc6_ = 20;
         var _loc7_:Matrix = new Matrix();
         _loc7_.createGradientBox(_loc5_,_loc6_,0,_loc3_,_loc4_);
         graphics.beginGradientFill(GradientType.LINEAR,[2894892,2894892],[1,0],[100,255],_loc7_);
         graphics.drawRect(_loc3_,_loc4_,_loc5_,_loc6_);
         graphics.endFill();
         var _loc8_:int = _loc5_;
         if(!this._task.isComplete && this._task.goalType == "res")
         {
            if(this.btn_donate == null)
            {
               this.btn_donate = new PushButton(Language.getInstance().getString("alliance.overview_tasks_donate"),null,-1,{
                  "size":11,
                  "bold":true
               });
               this.btn_donate.backgroundColor = 4226049;
               this.btn_donate.showBorder = false;
               this.btn_donate.width = 50;
               this.btn_donate.height = 20;
               this.btn_donate.clicked.add(this.onDonateClicked);
            }
            this.btn_donate.x = int(this._width - this.btn_donate.width - 6);
            this.btn_donate.y = int(_loc4_ + (_loc6_ - this.btn_donate.height) * 0.5);
            if(!AllianceSystem.getInstance().canContributeToRound)
            {
               this.btn_donate.enabled = false;
               TooltipManager.getInstance().add(this.btn_donate,Language.getInstance().getString("alliance.nocontribute"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            }
            else
            {
               TooltipManager.getInstance().remove(this.btn_donate);
            }
            _loc8_ = int(_loc5_ - this.btn_donate.width);
            addChild(this.btn_donate);
         }
         else if(this.btn_donate != null)
         {
            if(this.btn_donate.parent != null)
            {
               this.btn_donate.parent.removeChild(this.btn_donate);
            }
         }
         this.txt_title.text = this._task.getName().toUpperCase();
         this.txt_title.maxWidth = _loc8_;
         this.txt_title.y = int(_loc4_ + (_loc6_ - this.txt_title.height) * 0.5);
         this.txt_title.x = int(_loc3_ + 2);
         this.ui_progress.mouseChildren = this.ui_progress.mouseEnabled = false;
         this.ui_progress.x = int(_loc3_ + 1);
         this.ui_progress.y = int(this.ui_image.y + this.ui_image.height - this.ui_progress.height);
         this.ui_progress.progress = this._task.value / this._task.goal;
         var _loc9_:int = int(this.ui_progress.y - _loc6_ - _loc4_);
         this.txt_goal.text = this._task.isComplete ? Language.getInstance().getString("alliance.overview_tasks_complete") : this._task.getGoalDescription().toUpperCase();
         this.txt_goal.textColor = this._task.isComplete ? 8176182 : 11579568;
         this.txt_goal.maxWidth = int(this.ui_progress.width + 10);
         this.txt_goal.x = int(_loc3_ + 2);
         this.txt_goal.y = int(_loc4_ + _loc6_ + (_loc9_ - this.txt_goal.height) * 0.5);
         var _loc10_:int = 20;
         var _loc11_:int = int(this._width - this.ui_image.x - this.ui_progress.x - this.ui_progress.width);
         var _loc12_:int = int(this._width - this.ui_image.x - _loc11_);
         var _loc13_:int = int(this.ui_image.y + this.ui_image.height - _loc10_);
         var _loc14_:Matrix = new Matrix();
         _loc14_.createGradientBox(_loc11_,_loc10_,0,_loc12_,_loc13_);
         graphics.beginGradientFill(GradientType.LINEAR,[6629661,6629661],[0,1],[0,150],_loc14_);
         graphics.drawRect(_loc12_,_loc13_,_loc11_,_loc10_);
         graphics.endFill();
         this.bmp_tokens.y = int(_loc13_ + (_loc10_ - this.bmp_tokens.height) * 0.5);
         this.bmp_tokens.x = int(_loc12_ + _loc11_ - this.bmp_tokens.width);
         this.txt_tokens.text = "+" + NumberFormatter.format(this._task.tokenReward,0);
         this.txt_tokens.y = int(_loc13_ + (_loc10_ - this.txt_tokens.height) * 0.5);
         this.txt_tokens.x = int(this.bmp_tokens.x - this.txt_tokens.width);
      }
      
      private function getTooltip() : String
      {
         var _loc1_:String = Language.getInstance().getString("alliance.taskprogress",NumberFormatter.format(this._task.value,0) + " / " + NumberFormatter.format(this._task.goal,0));
         return this._task.getDescription() + "<br/><br/>" + _loc1_;
      }
      
      private function onDonateClicked(param1:MouseEvent) : void
      {
         var _loc2_:AllianceTaskContributeDialogue = new AllianceTaskContributeDialogue(this._task);
         _loc2_.open();
      }
      
      private function onTaskProgressChanged(param1:AllianceTask) : void
      {
         this.ui_progress.progress = param1.value / param1.goal;
         if(this._task.isComplete)
         {
            invalidate();
            if(stage != null)
            {
               TweenMax.from(this,1,{"colorTransform":{"exposure":2}});
            }
         }
      }
   }
}

