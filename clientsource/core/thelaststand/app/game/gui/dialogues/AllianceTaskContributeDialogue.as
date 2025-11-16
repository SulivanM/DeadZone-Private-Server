package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.alliance.AllianceTask;
   import thelaststand.app.game.gui.UINumberSpinner;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AllianceTaskContributeDialogue extends BaseDialogue
   {
      
      private var _task:AllianceTask;
      
      private var _item:Item;
      
      private var _isBusy:Boolean = false;
      
      private var bmp_arrow:Bitmap;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_taskImage:UIImage;
      
      private var ui_amount:UINumberSpinner;
      
      private var txt_taskTitle:TitleTextField;
      
      private var txt_goal:BodyTextField;
      
      private var ui_progress:UIContributionProgress;
      
      private var ui_itemImage1:UIInventoryListItem;
      
      private var ui_itemImage2:UIInventoryListItem;
      
      private var btn_contribute:PushButton;
      
      public function AllianceTaskContributeDialogue(param1:AllianceTask)
      {
         super("task-contribute",this.mc_container,true);
         this._task = param1;
         _width = 258;
         _height = 280;
         _autoSize = false;
         var _loc2_:Language = Language.getInstance();
         var _loc3_:int = int(_width / 2 - _buttonSpacing - _padding * 0.5 - 2);
         addTitle(_loc2_.getString("alliance.task_contribute_title"),BaseDialogue.TITLE_COLOR_GREY);
         addButton(_loc2_.getString("alliance.task_contribute_cancel"),true,{"width":_loc3_});
         this.btn_contribute = PushButton(addButton(_loc2_.getString("alliance.task_contribute_ok"),false,{
            "backgroundColor":PurchasePushButton.DEFAULT_COLOR,
            "width":_loc3_
         }));
         this.btn_contribute.clicked.add(this.onClickContribute);
         var _loc4_:int = int(_padding * 0.5);
         var _loc5_:int = int(_width - _padding * 2);
         var _loc6_:int = 164;
         var _loc7_:int = 6;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc5_,_loc6_,0,_loc4_);
         var _loc8_:Rectangle = new Rectangle(_loc7_,_loc4_ + _loc7_,int(_loc5_ - _loc7_ * 2),56);
         this.mc_container.graphics.beginFill(4934475);
         this.mc_container.graphics.drawRect(_loc8_.x,_loc8_.y,_loc8_.width,_loc8_.height);
         this.mc_container.graphics.endFill();
         this.mc_container.graphics.beginFill(4013373);
         this.mc_container.graphics.drawRect(_loc8_.x + 1,_loc8_.y + 1,_loc8_.width - 2,_loc8_.height - 2);
         this.mc_container.graphics.endFill();
         this.ui_taskImage = new UIImage(44,44);
         this.ui_taskImage.uri = this._task.imageURI;
         this.ui_taskImage.y = int(_loc8_.y + (_loc8_.height - this.ui_taskImage.height) * 0.5);
         this.ui_taskImage.x = int(_loc8_.x + (_loc8_.height - this.ui_taskImage.height) * 0.5);
         this.mc_container.addChild(this.ui_taskImage);
         var _loc9_:int = 2;
         this.mc_container.graphics.beginFill(6184542);
         this.mc_container.graphics.drawRect(this.ui_taskImage.x - _loc9_,this.ui_taskImage.y - _loc9_,this.ui_taskImage.width + _loc9_ * 2,this.ui_taskImage.height + _loc9_ * 2);
         this.mc_container.graphics.endFill();
         var _loc10_:int = int(this.ui_taskImage.x + this.ui_taskImage.width + 6);
         var _loc11_:int = int(this.ui_taskImage.y);
         var _loc12_:int = int(_loc8_.width - _loc10_);
         var _loc13_:int = 20;
         var _loc14_:Matrix = new Matrix();
         _loc14_.createGradientBox(_loc12_,_loc13_,0,_loc10_,_loc11_);
         this.mc_container.graphics.beginGradientFill(GradientType.LINEAR,[2894892,2894892],[1,0],[100,255],_loc14_);
         this.mc_container.graphics.drawRect(_loc10_,_loc11_,_loc12_,_loc13_);
         this.mc_container.graphics.endFill();
         this.txt_taskTitle = new TitleTextField({
            "color":16777215,
            "size":17,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_taskTitle.text = this._task.getName().toUpperCase();
         this.txt_taskTitle.x = int(_loc10_ + 2);
         this.txt_taskTitle.y = int(_loc11_ + (_loc13_ - this.txt_taskTitle.height) * 0.5);
         this.mc_container.addChild(this.txt_taskTitle);
         this.txt_goal = new BodyTextField({
            "color":16777215,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_goal.text = this._task.getGoalDescription().toUpperCase();
         this.txt_goal.x = int(this.txt_taskTitle.x);
         this.txt_goal.y = int(_loc11_ + _loc13_ + 14 - this.txt_goal.height * 0.5);
         this.txt_goal.maxWidth = int(_loc12_ - 10);
         this.mc_container.addChild(this.txt_goal);
         this.ui_progress = new UIContributionProgress(_loc2_.getString("alliance.task_contribute_total"));
         this.ui_progress.total = this._task.goal;
         this.ui_progress.value = this._task.value;
         this.ui_progress.width = _loc8_.width;
         this.ui_progress.x = _loc8_.x;
         this.ui_progress.y = int(_loc8_.y + _loc8_.height + _loc7_);
         this.mc_container.addChild(this.ui_progress);
         this.ui_amount = new UINumberSpinner();
         this.ui_amount.width = int(_width * 0.6);
         this.ui_amount.minValue = 0;
         this.ui_amount.maxValue = 0;
         this.ui_amount.value = 0;
         this.ui_amount.x = int((_width - this.ui_amount.width) * 0.5 - _padding);
         this.ui_amount.y = int(_loc4_ + _loc6_ + 8);
         this.ui_amount.changed.add(this.onAmountChanged);
         this.mc_container.addChild(this.ui_amount);
         if(this._task.goalType == "res")
         {
            this._item = ItemFactory.createItemFromTypeId(this._task.goalId);
         }
         this.ui_itemImage1 = new UIInventoryListItem(64);
         this.ui_itemImage1.x = int(_loc8_.x);
         this.ui_itemImage1.y = int(this.ui_progress.y + this.ui_progress.height + 8);
         this.ui_itemImage1.itemData = this._item;
         this.ui_itemImage1.image.quantity = 0;
         this.ui_itemImage1.image.showQuantityWhenOne = true;
         this.mc_container.addChild(this.ui_itemImage1);
         this.ui_itemImage2 = new UIInventoryListItem(64);
         this.ui_itemImage2.x = int(_loc8_.x + _loc8_.width - this.ui_itemImage2.width);
         this.ui_itemImage2.y = int(this.ui_itemImage1.y);
         this.ui_itemImage2.itemData = this._item;
         this.ui_itemImage2.image.quantity = 0;
         this.ui_itemImage2.image.showQuantityWhenOne = true;
         this.mc_container.addChild(this.ui_itemImage2);
         this.bmp_arrow = new Bitmap(new BmpBatchRecycleArrow());
         this.bmp_arrow.x = int(this.ui_itemImage1.x + (this.ui_itemImage2.x + this.ui_itemImage2.width - this.ui_itemImage1.x - this.bmp_arrow.width) * 0.5);
         this.bmp_arrow.y = int(this.ui_itemImage1.y + (this.ui_itemImage1.height - this.bmp_arrow.height) * 0.5);
         this.mc_container.addChild(this.bmp_arrow);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._task = null;
         this._item.dispose();
         this.btn_contribute = null;
         this.ui_amount.dispose();
         this.ui_taskImage.dispose();
         this.ui_progress.dispose();
         this.txt_taskTitle.dispose();
         this.txt_goal.dispose();
         this.ui_itemImage1.dispose();
         this.ui_itemImage2.dispose();
         this.bmp_arrow.bitmapData.dispose();
      }
      
      private function getMaxContributionAmount() : int
      {
         if(this._task.goalType == "res")
         {
            return Math.min(Network.getInstance().playerData.compound.resources.getAmount(this._task.goalId),this._task.goal - this._task.value);
         }
         return 0;
      }
      
      private function updateAmountSpinner() : void
      {
         this.ui_amount.maxValue = this.getMaxContributionAmount();
         this.ui_amount.minValue = 0;
         this.btn_contribute.enabled = this.ui_amount.value > 0;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._task.goalType == "res")
         {
            Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceValueChanged);
         }
         this._task.progressChanged.add(this.onTaskProgressChanged);
         this.updateAmountSpinner();
         this.onAmountChanged(this.ui_amount);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         if(this._task.goalType == "res")
         {
            Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceValueChanged);
         }
         this._task.progressChanged.remove(this.onTaskProgressChanged);
      }
      
      private function onClickContribute(param1:MouseEvent) : void
      {
         var lang:Language = null;
         var dlgBusy:BusyDialogue = null;
         var dlgError:MessageBox = null;
         var e:MouseEvent = param1;
         var amount:int = int(this.ui_amount.value);
         if(amount <= 0)
         {
            return;
         }
         lang = Language.getInstance();
         dlgBusy = new BusyDialogue(lang.getString("alliance.task_contribute_busy"));
         dlgBusy.open();
         this._isBusy = true;
         if(!TradeSystem.getInstance().isTradeSystemEnabled)
         {
            dlgError = new MessageBox(lang.getString("alliance.task_contribute_error_msg"));
            dlgError.addTitle(lang.getString("alliance.task_contribute_error_title"),BaseDialogue.TITLE_COLOR_RUST);
            dlgError.addButton(lang.getString("alliance.task_contribute_error_ok"));
            dlgError.open();
            return;
         }
         AllianceSystem.getInstance().contributeToTask(this._task,amount,function(param1:RPCResponse):void
         {
            var _loc2_:MessageBox = null;
            _isBusy = false;
            dlgBusy.close();
            if(!param1.success)
            {
               _loc2_ = new MessageBox(lang.getString("alliance.task_contribute_error_msg"));
               _loc2_.addTitle(lang.getString("alliance.task_contribute_error_title"),BaseDialogue.TITLE_COLOR_RUST);
               _loc2_.addButton(lang.getString("alliance.task_contribute_error_ok"));
               _loc2_.open();
               return;
            }
            close();
         });
      }
      
      private function onAmountChanged(param1:UINumberSpinner) : void
      {
         var _loc2_:int = Network.getInstance().playerData.compound.resources.getAmount(this._task.goalId);
         var _loc3_:int = int(this.ui_amount.value);
         this.ui_itemImage1.image.quantity = _loc2_ - _loc3_;
         this.ui_itemImage2.image.quantity = _loc3_;
         this.ui_progress.contributionValue = _loc3_;
         this.updateAmountSpinner();
      }
      
      private function onResourceValueChanged(param1:String, param2:Number) : void
      {
         if(param1 == this._task.goalId)
         {
            this.updateAmountSpinner();
         }
      }
      
      private function onTaskProgressChanged(param1:AllianceTask) : void
      {
         this.updateAmountSpinner();
         this.ui_progress.total = param1.goal;
         this.ui_progress.value = param1.value;
         this.ui_progress.contributionValue = int(this.ui_amount.value);
         if(param1.isComplete && !this._isBusy)
         {
            close();
         }
      }
   }
}

import com.deadreckoned.threshold.display.Color;
import com.exileetiquette.utils.NumberFormatter;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.gui.UIComponent;

class UIContributionProgress extends UIComponent
{
   
   private var _color:uint;
   
   private var _colorCont:uint;
   
   private var _colorTrack:uint;
   
   private var _width:int = 226;
   
   private var _height:int = 14;
   
   private var _total:int;
   
   private var _value:int;
   
   private var _cValue:int;
   
   private var _label:String;
   
   private var txt_label:BodyTextField;
   
   private var txt_progress:BodyTextField;
   
   public function UIContributionProgress(param1:String = "", param2:uint = 9022063)
   {
      super();
      this._label = param1;
      this.color = param2;
      this.txt_label = new BodyTextField({
         "color":0,
         "alpha":0.75,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_label);
      this.txt_progress = new BodyTextField({
         "color":0,
         "alpha":0.75,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_progress);
   }
   
   public function get color() : uint
   {
      return this._color;
   }
   
   public function set color(param1:uint) : void
   {
      this._color = param1;
      this._colorCont = new Color(this._color).tint(16777215,0.25).RGB;
      this._colorTrack = new Color(this._color).tint(0,0.5).RGB;
      invalidate();
   }
   
   public function get total() : int
   {
      return this._total;
   }
   
   public function set total(param1:int) : void
   {
      this._total = param1;
      invalidate();
   }
   
   public function get value() : Number
   {
      return this._value;
   }
   
   public function set value(param1:Number) : void
   {
      this._value = param1;
      invalidate();
   }
   
   public function get contributionValue() : Number
   {
      return this._cValue;
   }
   
   public function set contributionValue(param1:Number) : void
   {
      this._cValue = param1;
      invalidate();
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
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
      this.txt_progress.dispose();
      this.txt_label.dispose();
   }
   
   override protected function draw() : void
   {
      var _loc1_:Number = this._value / this._total;
      if(_loc1_ < 0)
      {
         _loc1_ = 0;
      }
      else if(_loc1_ > 1)
      {
         _loc1_ = 1;
      }
      var _loc2_:Number = (this._value + this._cValue) / this._total;
      graphics.clear();
      graphics.beginFill(this._colorTrack);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      graphics.beginFill(this._colorCont);
      graphics.drawRect(0,0,this._width * _loc2_,this._height);
      graphics.endFill();
      graphics.beginFill(this._color);
      graphics.drawRect(0,0,this._width * _loc1_,this._height);
      graphics.endFill();
      this.txt_progress.text = NumberFormatter.format(this._value,0) + " / " + NumberFormatter.format(this._total,0);
      this.txt_progress.x = int(this._width - this.txt_progress.width - 2);
      this.txt_progress.y = int((this._height - this.txt_progress.height) * 0.5);
      this.txt_label.text = this._label.toUpperCase();
      this.txt_label.x = 2;
      this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
   }
}
