package thelaststand.app.game.gui.map
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.bounty.InfectedBountyTaskCondition;
   import thelaststand.app.game.gui.dialogues.BountyOfficeDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UIMapInfectedBountyPin extends Sprite
   {
      
      private var _task:InfectedBountyTask;
      
      private var bmp_icon:Bitmap;
      
      private var txt_progress:BodyTextField;
      
      private var mc_hitArea:Sprite;
      
      public function UIMapInfectedBountyPin()
      {
         super();
         mouseEnabled = true;
         mouseChildren = false;
         this.bmp_icon = new Bitmap(new BmpInfectedBountyMapIcon(),"auto",true);
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         this.bmp_icon.x = -int(this.bmp_icon.width * 0.5);
         this.bmp_icon.y = -int(this.bmp_icon.height * 0.5);
         addChild(this.bmp_icon);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(0,0);
         this.mc_hitArea.graphics.drawRect(0,0,this.bmp_icon.width,this.bmp_icon.height);
         this.mc_hitArea.graphics.endFill();
         this.mc_hitArea.x = this.bmp_icon.x;
         this.mc_hitArea.y = this.bmp_icon.y;
         addChildAt(this.mc_hitArea,0);
         hitArea = this.mc_hitArea;
         this.txt_progress = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true,
            "filters":[Effects.STROKE_MEDIUM]
         });
         this.txt_progress.text = "0 / 0";
         this.txt_progress.mouseEnabled = false;
         addChild(this.txt_progress);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         TooltipManager.getInstance().add(this,this.getTooltip,new Point(NaN,this.bmp_icon.y),TooltipDirection.DIRECTION_DOWN,NaN);
      }
      
      public function get task() : InfectedBountyTask
      {
         return this._task;
      }
      
      public function set task(param1:InfectedBountyTask) : void
      {
         this._task = param1;
      }
      
      public function dispose() : void
      {
         TweenMax.killTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.bmp_icon.bitmapData.dispose();
         this.txt_progress.dispose();
      }
      
      private function getTooltip() : String
      {
         var _loc3_:InfectedBountyTaskCondition = null;
         var _loc4_:* = null;
         var _loc5_:String = null;
         if(this._task == null)
         {
            return "";
         }
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this._task.numConditions)
         {
            _loc3_ = this._task.getCondition(_loc2_);
            _loc4_ = Language.getInstance().getString("bounty.infected_task_kill_short",Language.getInstance().getString("zombie_types." + _loc3_.zombieType));
            _loc5_ = NumberFormatter.format(_loc3_.kills,0) + " / " + NumberFormatter.format(_loc3_.killsRequired,0);
            _loc4_ = _loc4_ + "  " + _loc5_;
            if(_loc3_.isComplete)
            {
               _loc4_ = "<font color=\'#8ED413\'>" + _loc4_ + "</font>";
            }
            _loc1_.push(_loc4_);
            _loc2_++;
         }
         return "<b>" + Language.getInstance().getString("suburbs." + this._task.suburb).toUpperCase() + "</b><br/>" + _loc1_.join("<br/>");
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.txt_progress.text = this._task.numCompletedConditions + " / " + this._task.numConditions;
         this.txt_progress.x = int(-this.txt_progress.width * 0.5);
         this.txt_progress.y = int(this.bmp_icon.y + this.bmp_icon.height + 2);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_icon,0.25,{"transformAroundCenter":{
            "scaleX":1.1,
            "scaleY":1.1
         }});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_icon,0.25,{"transformAroundCenter":{
            "scaleX":1,
            "scaleY":1
         }});
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:BountyOfficeDialogue = new BountyOfficeDialogue(BountyOfficeDialogue.PAGE_INFECTED,this._task.index);
         _loc2_.open();
      }
   }
}

