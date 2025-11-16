package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import org.osflash.signals.Signal;
   import thelaststand.app.data.CostTable;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskType;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class SpeedUpDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _panelSpacing:int = 14;
      
      private var _panels:Vector.<SpeedUpPanel>;
      
      private var _options:Vector.<Object>;
      
      private var _target:*;
      
      private var mc_container:Sprite;
      
      private var txt_desc:BodyTextField;
      
      public var speedUpSelected:Signal;
      
      public function SpeedUpDialogue(param1:*)
      {
         var numOptions:int;
         var tx:int;
         var i:int;
         var opt:Object = null;
         var panel:SpeedUpPanel = null;
         var target:* = param1;
         this.mc_container = new Sprite();
         super("speed-up-dialogue",this.mc_container,true);
         this.speedUpSelected = new Signal();
         this._target = target;
         _autoSize = false;
         _padding = 14;
         _height = 302;
         this._lang = Language.getInstance();
         this._panels = new Vector.<SpeedUpPanel>();
         this._options = Network.getInstance().data.costTable.getItems("speed_up");
         this._options.sort(function(param1:Object, param2:Object):int
         {
            return param1.order - param2.order;
         });
         addTitle(this.getTitle(),BaseDialogue.TITLE_COLOR_BUY);
         numOptions = int(this._options.length);
         tx = 0;
         i = 0;
         while(i < numOptions)
         {
            opt = this._options[i];
            if(opt.enabled !== false)
            {
               panel = new SpeedUpPanel(opt,this.getImageURI());
               panel.buyClicked.add(this.onOptionSelected);
               panel.x = tx;
               panel.y = _padding - 5;
               tx += panel.width + this._panelSpacing;
               this.mc_container.addChild(panel);
               this._panels.push(panel);
            }
            i++;
         }
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true,
            "multiline":true,
            "align":"center"
         });
         this.txt_desc.htmlText = this.getDesc();
         this.txt_desc.y = int(_height - this.txt_desc.height - _padding * 2);
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.mc_container.addChild(this.txt_desc);
         this.updateButtons();
         this.updatePanelPositions();
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         if(this._target == null || this.getTimeRemaining() <= 3 || this._target is Survivor && Survivor(this._target).state & SurvivorState.ON_ASSIGNMENT)
         {
            close();
            return;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:SpeedUpPanel = null;
         this.mc_container.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         super.dispose();
         this.speedUpSelected.removeAll();
         this._lang = null;
         this._target = null;
         this._panels = null;
         this.txt_desc.dispose();
         this.txt_desc = null;
         for each(_loc1_ in this._panels)
         {
            _loc1_.dispose();
         }
         this._panels = null;
      }
      
      private function getTitle() : String
      {
         var _loc1_:Building = null;
         if(this._target is Building)
         {
            _loc1_ = Building(this._target);
            if(_loc1_.repairTimer != null)
            {
               return this._lang.getString("speed_up_repair_title");
            }
            return _loc1_.isUnderConstruction() ? this._lang.getString("speed_up_construct_title") : this._lang.getString("speed_up_upgrade_title");
         }
         if(this._target is MissionData)
         {
            return this._lang.getString("speed_up_returntime_title");
         }
         if(this._target is Task)
         {
            return this._lang.getString("speed_up_task." + Task(this._target).type + "_title");
         }
         if(this._target is Survivor)
         {
            return this._lang.getString("speed_up_reassign_title").toUpperCase();
         }
         if(this._target is BatchRecycleJob)
         {
            return this._lang.getString("speed_up_batch_recycle_title").toUpperCase();
         }
         return "";
      }
      
      private function getDesc() : String
      {
         var _loc1_:Building = null;
         if(this._target is Building)
         {
            _loc1_ = Building(this._target);
            if(_loc1_.repairTimer != null)
            {
               return this._lang.getString("speed_up_repair_desc");
            }
            return _loc1_.isUnderConstruction() ? this._lang.getString("speed_up_construct_desc") : this._lang.getString("speed_up_upgrade_desc");
         }
         if(this._target is MissionData)
         {
            return this._lang.getString("speed_up_returntime_desc").toUpperCase();
         }
         if(this._target is Task)
         {
            return this._lang.getString("speed_up_task." + Task(this._target).type + "_desc").toUpperCase();
         }
         if(this._target is Survivor)
         {
            return this._lang.getString("speed_up_reassign_desc").toUpperCase();
         }
         if(this._target is BatchRecycleJob)
         {
            return this._lang.getString("speed_up_batch_recycle_desc").toUpperCase();
         }
         return "";
      }
      
      private function getImageURI() : String
      {
         if(this._target is Building)
         {
            return "images/ui/speed-up-building.jpg";
         }
         if(this._target is MissionData)
         {
            if(Network.getInstance().playerData.upgrades.get(PlayerUpgrades.DeathMobileUpgrade))
            {
               return "images/ui/speed-up-mission2.jpg";
            }
            return "images/ui/speed-up-mission.jpg";
         }
         if(this._target is Task)
         {
            switch(Task(this._target).type)
            {
               case TaskType.JUNK_REMOVAL:
                  return "images/ui/speed-up-junk.jpg";
               case TaskType.ITEM_CRAFTING:
                  return "images/ui/speed-up-itemcrafting.jpg";
            }
         }
         if(this._target is Survivor)
         {
            return "images/ui/speed-up-reassign.jpg";
         }
         if(this._target is BatchRecycleJob)
         {
            return "images/ui/speed-up-building.jpg";
         }
         return "";
      }
      
      private function getTimeRemaining() : int
      {
         var _loc1_:TimerData = null;
         var _loc2_:Building = null;
         var _loc3_:Task = null;
         if(this._target is Building)
         {
            _loc2_ = Building(this._target);
            _loc1_ = _loc2_.repairTimer || _loc2_.upgradeTimer;
         }
         else if(this._target is MissionData)
         {
            _loc1_ = MissionData(this._target).returnTimer;
         }
         else if(this._target is Survivor)
         {
            _loc1_ = Survivor(this._target).reassignTimer;
         }
         else if(this._target is BatchRecycleJob)
         {
            _loc1_ = BatchRecycleJob(this._target).timer;
         }
         else if(this._target is Task)
         {
            _loc3_ = Task(this._target);
            return int(_loc3_.length - _loc3_.time);
         }
         return _loc1_ != null ? _loc1_.getSecondsRemaining() : 0;
      }
      
      private function updateButtons() : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:SpeedUpPanel = null;
         var _loc7_:Object = null;
         var _loc8_:* = false;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc1_:Boolean = false;
         var _loc2_:int = this.getTimeRemaining();
         if(_loc2_ <= 3)
         {
            close();
            return;
         }
         var _loc3_:CostTable = Network.getInstance().data.costTable;
         var _loc4_:int = Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH);
         for each(_loc6_ in this._panels)
         {
            if(_loc2_ <= 3)
            {
               _loc6_.enabled = false;
            }
            else
            {
               _loc7_ = _loc6_.option;
               _loc8_ = true;
               _loc9_ = _loc3_.getCostForTime(_loc7_,_loc2_);
               _loc6_.setCost(_loc7_.FreelyGivable === true ? -1 : _loc9_);
               if(_loc7_.hasOwnProperty("maxTime"))
               {
                  _loc10_ = int(_loc7_.maxTime);
                  _loc8_ = _loc2_ <= _loc10_;
               }
               else if(_loc7_.hasOwnProperty("time"))
               {
                  if(this._target is Task)
                  {
                     _loc8_ = false;
                  }
                  else
                  {
                     _loc11_ = int(_loc7_.time);
                     _loc8_ = _loc2_ >= _loc11_;
                  }
               }
               if(!_loc7_.FreelyGivable && _loc1_)
               {
                  _loc8_ = false;
               }
               if(_loc6_.enabled != _loc8_)
               {
                  _loc5_ = true;
               }
               _loc6_.enabled = _loc8_;
               if(_loc8_ && _loc7_.FreelyGivable === true)
               {
                  _loc1_ = true;
               }
            }
         }
         if(_loc1_)
         {
            for each(_loc6_ in this._panels)
            {
               if(!_loc6_.option.FreelyGivable)
               {
                  if(_loc6_.enabled)
                  {
                     _loc5_ = true;
                  }
                  _loc6_.enabled = false;
               }
            }
         }
         if(_loc5_)
         {
            this.updatePanelPositions();
         }
      }
      
      private function updatePanelPositions() : void
      {
         var _loc3_:SpeedUpPanel = null;
         if(this._panels == null)
         {
            return;
         }
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._panels.length)
         {
            _loc3_ = SpeedUpPanel(this._panels[_loc2_]);
            if(!_loc3_.enabled && _loc3_.option.FreelyGivable === true)
            {
               if(_loc3_.parent != null)
               {
                  _loc3_.parent.removeChild(_loc3_);
               }
            }
            else
            {
               this.mc_container.addChild(_loc3_);
               _loc3_.x = _loc1_;
               _loc1_ += _loc3_.width + this._panelSpacing;
            }
            _loc2_++;
         }
         _width = int(_loc1_ - this._panelSpacing + _padding * 2);
         this.txt_desc.scaleX = this.txt_desc.scaleY = 1;
         this.txt_desc.width = _width;
         this.txt_desc.x = int((_width - this.txt_desc.width) * 0.5 - _padding);
         _height = int(280 + this.txt_desc.height);
         this.txt_desc.y = int(_height - this.txt_desc.height - _padding * 2);
         draw();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.mc_container.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this.mc_container.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._target is Task)
         {
            Task(this._target).updateTimer();
         }
         this.updateButtons();
      }
      
      private function onOptionSelected(param1:SpeedUpPanel) : void
      {
         var _loc7_:Building = null;
         if(Network.getInstance().isBusy)
         {
            return;
         }
         var _loc2_:Object = param1.option;
         var _loc3_:* = this._target;
         var _loc4_:int = Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH);
         var _loc5_:int = Network.getInstance().data.costTable.getCostForTime(_loc2_,this.getTimeRemaining());
         if(_loc5_ > _loc4_)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
            return;
         }
         var _loc6_:BusyDialogue = new BusyDialogue(this._lang.getString("purchasing_speedup"),"purchasing-speedup");
         _loc6_.open();
         if(_loc3_ is Building)
         {
            _loc7_ = Building(_loc3_);
            if(_loc7_.repairTimer != null)
            {
               _loc7_.speedUpRepair(_loc2_,this.onSpeedUpComplete);
            }
            else
            {
               _loc7_.speedUpUpgrade(_loc2_,this.onSpeedUpComplete);
            }
         }
         else if(_loc3_ is MissionData)
         {
            MissionData(_loc3_).speedUpReturn(_loc2_,this.onSpeedUpComplete);
         }
         else if(_loc3_ is Task)
         {
            Task(_loc3_).speedUp(_loc2_,this.onSpeedUpComplete);
         }
         else if(_loc3_ is Survivor)
         {
            Survivor(_loc3_).speedUpReassignment(_loc2_,this.onSpeedUpComplete);
         }
         else if(_loc3_ is BatchRecycleJob)
         {
            BatchRecycleJob(_loc3_).speedUp(_loc2_,this.onSpeedUpComplete);
         }
         else
         {
            _loc6_.close();
            close();
         }
      }
      
      private function onSpeedUpComplete() : void
      {
         DialogueManager.getInstance().closeDialogue("purchasing-speedup");
         this.speedUpSelected.dispatch();
         close();
      }
   }
}

import com.greensock.TweenMax;
import com.greensock.easing.Cubic;
import com.quasimondo.geom.ColorMatrix;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import org.osflash.signals.Signal;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.game.gui.buttons.PurchasePushButton;
import thelaststand.app.gui.UIImage;
import thelaststand.app.gui.buttons.PushButton;
import thelaststand.app.utils.GraphicUtils;
import thelaststand.common.lang.Language;

class SpeedUpPanel extends Sprite
{
   
   private const FILTER_GREYSCALE:ColorMatrix;
   
   private var _enabled:Boolean = true;
   
   private var _lang:Language;
   
   private var _option:Object;
   
   private var _width:int = 164;
   
   private var _height:int = 238;
   
   private var _cost:int;
   
   private var btn_buy:PushButton;
   
   private var mc_backer:Shape;
   
   private var mc_image:UIImage;
   
   private var mc_icon:IconTime;
   
   private var txt_label:BodyTextField;
   
   private var txt_maxTime:BodyTextField;
   
   public var buyClicked:Signal;
   
   public function SpeedUpPanel(param1:Object, param2:String)
   {
      var border:int;
      var gradHeight:int;
      var mat:Matrix;
      var isFree:Boolean;
      var w:int;
      var self:SpeedUpPanel = null;
      var maxTime:Number = NaN;
      var option:Object = param1;
      var imageURI:String = param2;
      this.FILTER_GREYSCALE = new ColorMatrix();
      super();
      this.FILTER_GREYSCALE.desaturate();
      mouseEnabled = false;
      this._option = option;
      this._lang = Language.getInstance();
      GraphicUtils.drawUIBlock(graphics,this._width,this._height);
      border = 3;
      this.mc_image = new UIImage(this._width - border * 2,this._height - border * 2,0,0,true,imageURI);
      this.mc_image.x = this.mc_image.y = border;
      addChild(this.mc_image);
      gradHeight = 110;
      mat = new Matrix();
      mat.createGradientBox(this.mc_image.width,gradHeight,-Math.PI * 0.5);
      this.mc_backer = new Shape();
      this.mc_backer.graphics.beginGradientFill("linear",[0,0],[0.7,0],[200,255],mat);
      this.mc_backer.graphics.drawRect(0,0,this.mc_image.width,gradHeight);
      this.mc_backer.graphics.endFill();
      this.mc_backer.x = this.mc_image.x;
      this.mc_backer.y = int(this.mc_image.y + this.mc_image.height - this.mc_backer.height);
      addChild(this.mc_backer);
      self = this;
      isFree = option.FreelyGivable === true;
      this.btn_buy = isFree ? new PushButton("",null,-1,{"bold":true}) : new PurchasePushButton();
      if(!isFree)
      {
         PurchasePushButton(this.btn_buy).iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
      }
      this.btn_buy.width = 118;
      this.btn_buy.height = 24;
      this.btn_buy.x = int((this._width - this.btn_buy.width) * 0.5);
      this.btn_buy.y = int(this._height - this.btn_buy.height - 18);
      this.btn_buy.clicked.add(function(param1:MouseEvent):void
      {
         buyClicked.dispatch(self);
      });
      addChild(this.btn_buy);
      this.mc_icon = new IconTime();
      this.mc_icon.y = int(this.btn_buy.y - 30 - this.mc_icon.height * 0.5);
      addChild(this.mc_icon);
      this.txt_label = new BodyTextField({
         "color":16777215,
         "bold":true,
         "size":18
      });
      this.txt_label.textColor = this._option.FreelyGivable === true ? 11069285 : 16777215;
      this.txt_label.htmlText = this._lang.getString("speed_up_option." + this._option.key);
      this.txt_label.y = Math.round(this.mc_icon.y + (this.mc_icon.height - this.txt_label.height) * 0.5) - 1;
      addChild(this.txt_label);
      w = this.mc_icon.width + this.txt_label.width + 4;
      this.mc_icon.x = int((this._width - w) * 0.5);
      this.txt_label.x = int(this.mc_icon.x + this.mc_icon.width + 4);
      if(this._option.hasOwnProperty("maxTime"))
      {
         maxTime = int(this._option.maxTime / 60);
         this.txt_maxTime = new BodyTextField({
            "color":16777215,
            "bold":true,
            "size":12
         });
         this.txt_maxTime.text = this._lang.getString("speed_up_option.maxTime",maxTime);
         this.txt_maxTime.x = Math.round(this.txt_label.x + (this.txt_label.width - this.txt_maxTime.width) * 0.5);
         this.txt_maxTime.y = int(this.txt_label.y + this.txt_label.height - 8);
         this.txt_maxTime.textColor = this.txt_label.textColor;
         addChild(this.txt_maxTime);
      }
      this.buyClicked = new Signal(SpeedUpPanel);
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
   }
   
   public function dispose() : void
   {
      TweenMax.killChildTweensOf(this);
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this.buyClicked.removeAll();
      this.btn_buy.dispose();
      this.btn_buy = null;
      if(this.txt_maxTime != null)
      {
         this.txt_maxTime.dispose();
         this.txt_maxTime = null;
      }
      this.txt_label.dispose();
      this.txt_label = null;
      this.mc_image.dispose();
      this.mc_image = null;
      this._option = null;
      this._lang = null;
   }
   
   public function setCost(param1:int) : void
   {
      this._cost = param1;
      this.btn_buy.label = this._cost < 0 ? this._lang.getString("free") : null;
      if(this.btn_buy is PurchasePushButton)
      {
         PurchasePushButton(this.btn_buy).showIcon = this._cost >= 0;
         PurchasePushButton(this.btn_buy).cost = this._cost;
      }
   }
   
   public function get option() : Object
   {
      return this._option;
   }
   
   public function get enabled() : Boolean
   {
      return this._enabled;
   }
   
   public function set enabled(param1:Boolean) : void
   {
      this._enabled = param1;
      mouseChildren = this._enabled;
      if(this.btn_buy is PurchasePushButton)
      {
         PurchasePushButton(this.btn_buy).showIcon = this._enabled;
         PurchasePushButton(this.btn_buy).cost = 0;
      }
      if(!this._enabled)
      {
         this.btn_buy.label = this._lang.getString("not_available");
      }
      else
      {
         this.setCost(this._cost);
      }
      this.filters = this._enabled ? [] : [this.FILTER_GREYSCALE.filter];
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      var e:MouseEvent = param1;
      this.btn_buy.highlight(true);
      TweenMax.to(this.mc_image,0.25,{
         "colorMatrixFilter":{
            "contrast":1.4,
            "brightness":1.4
         },
         "overwrite":true,
         "ease":Cubic.easeOut,
         "onComplete":function():void
         {
            TweenMax.to(mc_image,1,{
               "colorMatrixFilter":{
                  "contrast":1.25,
                  "brightness":1.25
               },
               "ease":Cubic.easeInOut
            });
         }
      });
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      if(param1.relatedObject != null && Boolean(contains(param1.relatedObject)))
      {
         return;
      }
      this.btn_buy.highlight(false);
      TweenMax.to(this.mc_image,1,{
         "colorMatrixFilter":{
            "contrast":1,
            "brightness":1,
            "remove":true
         },
         "ease":Cubic.easeOut
      });
   }
}
