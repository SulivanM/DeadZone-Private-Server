package thelaststand.app.game.gui.research
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import flash.utils.getTimer;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIResearchProgressBar extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _padding:int = 3;
      
      private var _researchTask:ResearchTask;
      
      private var _bmdBarFill:BitmapData;
      
      private var _bmpOffset:Number = 0;
      
      private var _bmpMatrix:Matrix = new Matrix();
      
      private var _bmpLastUpdate:Number = 0;
      
      private var mc_bar:Shape;
      
      private var txt_label:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      public function UIResearchProgressBar()
      {
         super();
         this.mc_bar = new Shape();
         addChild(this.mc_bar);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "size":18,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_label);
         this.txt_time = new BodyTextField({
            "color":7261167,
            "size":18,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_time);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get researchTask() : ResearchTask
      {
         return this._researchTask;
      }
      
      public function set researchTask(param1:ResearchTask) : void
      {
         this._researchTask = param1;
         invalidate();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_label.dispose();
         this.txt_time.dispose();
         if(this._bmdBarFill != null)
         {
            this._bmdBarFill.dispose();
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         if(this._researchTask == null)
         {
            this.txt_time.visible = false;
            this.mc_bar.visible = false;
            _loc1_ = int(Config.constant.RESEARCH_TIME_BASE);
            _loc2_ = DateTimeUtils.secondsToString(_loc1_,true,false,true);
            this.txt_label.htmlText = Language.getInstance().getString("research_notinprogress",_loc2_);
         }
         else
         {
            _loc3_ = ResearchSystem.getCategoryName(this._researchTask.category).toUpperCase();
            _loc4_ = ResearchSystem.getCategoryGroupName(this._researchTask.category,this._researchTask.group).toUpperCase();
            this.txt_label.htmlText = Language.getInstance().getString("research_inprogress",_loc3_,_loc4_,this._researchTask.level);
            this.txt_time.visible = true;
            this.mc_bar.visible = true;
            this.drawProgressBar(this._researchTask.progress);
            this.updateTimeRemaining();
         }
         this.txt_label.x = 8;
         this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
      }
      
      private function drawProgressBar(param1:Number) : void
      {
         if(this._bmdBarFill == null)
         {
            this._bmdBarFill = new BmpResearchProgressBg();
         }
         var _loc2_:int = this._width - this._padding * 2;
         var _loc3_:int = this._height - this._padding * 2;
         var _loc4_:int = Math.max(_loc2_ * param1,1);
         this.mc_bar.x = this._padding;
         this.mc_bar.y = this._padding;
         var _loc5_:Number = (getTimer() - this._bmpLastUpdate) / 1000;
         this._bmpLastUpdate = getTimer();
         this._bmpOffset += _loc5_ * 4;
         this._bmpMatrix.createBox(1,1,0,this._bmpOffset,0);
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginBitmapFill(this._bmdBarFill,this._bmpMatrix,true,true);
         this.mc_bar.graphics.drawRect(0,0,_loc4_,_loc3_);
         this.mc_bar.graphics.endFill();
      }
      
      private function updateTimeRemaining() : void
      {
         if(this._researchTask == null)
         {
            this.txt_time.visible = false;
            return;
         }
         this.txt_time.visible = true;
         if(this._researchTask.isCompleted)
         {
            this.txt_time.htmlText = Language.getInstance().getString("research_completed").toUpperCase();
         }
         else
         {
            this.txt_time.htmlText = DateTimeUtils.secondsToString(this._researchTask.timeReamining,true,true);
         }
         this.txt_time.x = int(this._width - this.txt_time.width - 8);
         this.txt_time.y = int((this._height - this.txt_time.height) * 0.5);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._researchTask != null && !this._researchTask.isCompleted)
         {
            this.drawProgressBar(this._researchTask.progress);
            this.updateTimeRemaining();
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
   }
}

