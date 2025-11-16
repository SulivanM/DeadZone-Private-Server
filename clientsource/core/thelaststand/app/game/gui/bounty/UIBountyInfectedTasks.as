package thelaststand.app.game.gui.bounty
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIBountyInfectedTasks extends UIComponent
   {
      
      private static var selectedTaskIndex:int = 0;
      
      private static const maxTasks:int = 3;
      
      private var _taskButtons:Vector.<UIBountyInfectedTaskButton>;
      
      private var _width:int = 440;
      
      private var _height:int = 320;
      
      private var _selectedTaskBtn:UIBountyInfectedTaskButton;
      
      private var _bounty:InfectedBounty;
      
      private var ui_taskConditions:UIBountyInfectedConditionList;
      
      private var ui_titleBar:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      public function UIBountyInfectedTasks()
      {
         var _loc2_:UIBountyInfectedTaskButton = null;
         super();
         this.ui_titleBar = new UITitleBar(null,BaseDialogue.TITLE_COLOR_GREY);
         this.ui_titleBar.height = 32;
         this.ui_titleBar.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "color":16777215,
            "size":21,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.text = Language.getInstance().getString("bounty.infected_bounties").toUpperCase();
         addChild(this.txt_title);
         this._taskButtons = new Vector.<UIBountyInfectedTaskButton>();
         var _loc1_:int = 0;
         while(_loc1_ < maxTasks)
         {
            _loc2_ = new UIBountyInfectedTaskButton();
            _loc2_.clicked.add(this.onBountyTaskClicked);
            this._taskButtons.push(_loc2_);
            addChild(_loc2_);
            _loc1_++;
         }
         this.ui_taskConditions = new UIBountyInfectedConditionList();
         addChild(this.ui_taskConditions);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get bounty() : InfectedBounty
      {
         return this._bounty;
      }
      
      public function set bounty(param1:InfectedBounty) : void
      {
         this._bounty = param1;
         invalidate();
         this.selectTaskByIndex(selectedTaskIndex);
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
      
      override public function dispose() : void
      {
         var _loc1_:UIBountyInfectedTaskButton = null;
         super.dispose();
         this.txt_title.dispose();
         this.ui_titleBar.dispose();
         this.ui_taskConditions.dispose();
         for each(_loc1_ in this._taskButtons)
         {
            _loc1_.dispose();
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function selectTask(param1:int) : void
      {
         this.selectTaskByIndex(param1);
      }
      
      override protected function draw() : void
      {
         var _loc9_:int = 0;
         var _loc10_:UIBountyInfectedTaskButton = null;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         var _loc1_:int = 3;
         this.ui_titleBar.width = int(this._width - _loc1_ * 2);
         this.ui_titleBar.x = _loc1_;
         this.ui_titleBar.y = _loc1_;
         this.txt_title.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         var _loc2_:int = this._taskButtons[0].width;
         var _loc3_:int = this._taskButtons[0].height;
         var _loc4_:int = 8;
         var _loc5_:int = (this._width - _loc4_ * 2 - _loc2_ * this._taskButtons.length) / (this._taskButtons.length - 1);
         var _loc6_:int = _loc4_;
         var _loc7_:int = int(this.ui_titleBar.y + this.ui_titleBar.height + _loc4_);
         var _loc8_:int = 0;
         while(_loc8_ < this._taskButtons.length)
         {
            _loc10_ = this._taskButtons[_loc8_];
            _loc10_.task = _loc8_ < this._bounty.numTasks ? this._bounty.getTask(_loc8_) : null;
            _loc10_.x = _loc6_;
            _loc10_.y = _loc7_;
            _loc6_ += _loc2_ + _loc5_;
            _loc8_++;
         }
         _loc9_ = 10;
         this.ui_taskConditions.width = int(this._width - _loc9_ * 2);
         this.ui_taskConditions.redraw();
         this.ui_taskConditions.x = _loc9_;
         this.ui_taskConditions.y = int(this._height - this.ui_taskConditions.height - _loc9_);
         if(this._bounty.isAbandoned)
         {
            mouseChildren = false;
            mouseEnabled = false;
            filters = [Effects.GREYSCALE.filter];
         }
         else
         {
            mouseChildren = true;
            mouseEnabled = true;
            filters = [];
         }
      }
      
      private function selectTaskByIndex(param1:int) : void
      {
         if(param1 < 0 || param1 >= this._taskButtons.length)
         {
            return;
         }
         if(this._selectedTaskBtn != null)
         {
            this._selectedTaskBtn.selected = false;
            this._selectedTaskBtn = null;
         }
         var _loc2_:UIBountyInfectedTaskButton = this._taskButtons[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this._selectedTaskBtn = _loc2_;
         this._selectedTaskBtn.selected = true;
         selectedTaskIndex = param1;
         this.ui_taskConditions.task = this._bounty != null ? this._bounty.getTask(param1) : null;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.selectTaskByIndex(selectedTaskIndex);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onBountyTaskClicked(param1:MouseEvent) : void
      {
         var _loc2_:UIBountyInfectedTaskButton = UIBountyInfectedTaskButton(param1.currentTarget);
         this.selectTaskByIndex(this._taskButtons.indexOf(_loc2_));
      }
   }
}

