package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ConfirmReassignDialogue extends BaseDialogue
   {
      
      private var _survivor:Survivor;
      
      private var _class:SurvivorClass;
      
      private var _lang:Language;
      
      private var mc_content:Sprite = new Sprite();
      
      private var mc_time:TimeDisplay;
      
      private var mc_level:LevelDisplay;
      
      private var ui_image:UIImage;
      
      private var txt_message:BodyTextField;
      
      private var btn_ok:PushButton;
      
      private var btn_buy:PushButton;
      
      public var confirmed:Signal;
      
      public function ConfirmReassignDialogue(param1:Survivor, param2:SurvivorClass)
      {
         super("confirm-reassign",this.mc_content,true);
         this._lang = Language.getInstance();
         this._survivor = param1;
         this._class = param2;
         _autoSize = false;
         _width = 390;
         _height = 207;
         var _loc3_:String = this._lang.getString("survivor_classes." + this._class.id);
         var _loc4_:int = Survivor.getReassignTime(this._survivor);
         var _loc5_:int = int(Config.constant.SURVIVOR_REASSIGN_LEVEL_PENALTY);
         addTitle(this._lang.getString("srv_reassign_confirm_title",param1.fullName),BaseDialogue.TITLE_COLOR_RUST);
         this.ui_image = new UIImage(108,164);
         this.ui_image.x = 1;
         this.ui_image.y = int(_padding * 0.5) + 1;
         this.ui_image.uri = "images/ui/retrain.jpg";
         this.mc_content.addChild(this.ui_image);
         GraphicUtils.drawUIBlock(this.mc_content.graphics,this.ui_image.width + 2,this.ui_image.height + 2,0,int(_padding * 0.5));
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":14,
            "leading":1,
            "multiline":true
         });
         this.txt_message.htmlText = this._lang.getString("srv_reassign_confirm_msg",param1.fullName,_loc3_,_loc5_);
         this.txt_message.filters = [Effects.TEXT_SHADOW];
         this.txt_message.x = int(this.ui_image.x + this.ui_image.width + 8);
         this.txt_message.y = int(_padding * 0.5);
         this.txt_message.width = int(_width - this.txt_message.x - _padding * 2);
         this.mc_content.addChild(this.txt_message);
         var _loc6_:int = int(this.ui_image.x + this.ui_image.width + 8);
         var _loc7_:int = int(this.ui_image.y + 49);
         var _loc8_:int = int(_width - _loc6_ - _padding * 2);
         var _loc9_:int = 34;
         GraphicUtils.drawUIBlock(this.mc_content.graphics,_loc8_,_loc9_,_loc6_,_loc7_);
         this.mc_time = new TimeDisplay(DateTimeUtils.secondsToString(Survivor.getReassignTime(this._survivor)));
         this.mc_time.x = int(_loc6_ + (_loc8_ - this.mc_time.width) * 0.5);
         this.mc_time.y = int(_loc7_ + (_loc9_ - this.mc_time.height) * 0.5 + 4);
         this.mc_content.addChild(this.mc_time);
         _loc7_ += int(_loc9_ + 6);
         GraphicUtils.drawUIBlock(this.mc_content.graphics,_loc8_,_loc9_,_loc6_,_loc7_);
         this.mc_level = new LevelDisplay(this._survivor.level + 1,this._survivor.level + 1 + Config.constant.SURVIVOR_REASSIGN_LEVEL_PENALTY);
         this.mc_level.x = int(_loc6_ + (_loc8_ - this.mc_level.width) * 0.5);
         this.mc_level.y = int(_loc7_ + (_loc9_ - this.mc_level.height) * 0.5 + 6);
         this.mc_content.addChild(this.mc_level);
         this.btn_ok = new PushButton(this._lang.getString("srv_reassign_confirm_ok"));
         this.btn_ok.clicked.addOnce(this.onClickConfirm);
         this.btn_ok.autoSize = true;
         this.btn_ok.x = int(_width - _padding * 2 - this.btn_ok.width);
         this.btn_ok.y = int(_height - _padding * 2 - this.btn_ok.height - 10);
         this.mc_content.addChild(this.btn_ok);
         this.btn_buy = new PurchasePushButton(this._lang.getString("srv_reassign_confirm_buy"),Survivor.getReassignCost(this._survivor),true);
         this.btn_buy.clicked.addOnce(this.onClickBuy);
         this.btn_buy.x = int(_loc6_ + 2);
         this.btn_buy.y = int(this.btn_ok.y);
         this.btn_buy.width = int(_width - this.btn_buy.x - _padding * 2 - this.btn_ok.width - _buttonSpacing);
         this.mc_content.addChild(this.btn_buy);
         this.confirmed = new Signal(Boolean);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._survivor = null;
         this._class = null;
         this._lang = null;
         this.btn_ok.dispose();
         this.btn_buy.dispose();
         this.txt_message.dispose();
         this.mc_time.dispose();
         this.mc_level.dispose();
      }
      
      private function onClickConfirm(param1:MouseEvent) : void
      {
         this.confirmed.dispatch(false);
         close();
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         this.confirmed.dispatch(true);
         close();
      }
   }
}

import flash.display.Bitmap;
import flash.display.Sprite;
import thelaststand.app.display.BodyTextField;

class TimeDisplay extends Sprite
{
   
   private var mc_icon:IconTime;
   
   private var txt_time:BodyTextField;
   
   public function TimeDisplay(param1:String)
   {
      super();
      this.mc_icon = new IconTime();
      addChild(this.mc_icon);
      this.txt_time = new BodyTextField({
         "text":param1,
         "color":16777215,
         "size":18,
         "bold":true
      });
      this.txt_time.x = int(this.mc_icon.x + this.mc_icon.width + 6);
      this.txt_time.y = int(this.mc_icon.y + (this.mc_icon.height - this.txt_time.height) * 0.5 - 2);
      addChild(this.txt_time);
   }
   
   public function dispose() : void
   {
      removeChild(this.mc_icon);
      this.txt_time.dispose();
   }
}

class LevelDisplay extends Sprite
{
   
   private var bmp_icon:Bitmap;
   
   private var bmp_down:Bitmap;
   
   private var txt_currentLevel:BodyTextField;
   
   private var txt_newLevel:BodyTextField;
   
   public function LevelDisplay(param1:int, param2:int)
   {
      super();
      this.bmp_icon = new Bitmap(new BmpIconLevelYellow());
      addChild(this.bmp_icon);
      this.txt_currentLevel = new BodyTextField({
         "text":param1.toString(),
         "color":16777215,
         "size":18,
         "bold":true
      });
      this.txt_currentLevel.x = int(this.bmp_icon.x + this.bmp_icon.width + 6);
      this.txt_currentLevel.y = int(this.bmp_icon.y + (this.bmp_icon.height - this.txt_currentLevel.height) * 0.5 - 1);
      addChild(this.txt_currentLevel);
      this.bmp_down = new Bitmap(new BmpIconArrowDown());
      this.bmp_down.x = int(this.txt_currentLevel.x + this.txt_currentLevel.width + 4);
      this.bmp_down.y = int(this.bmp_icon.y + (this.bmp_icon.height - this.bmp_down.height) * 0.5 - 1);
      addChild(this.bmp_down);
      this.txt_newLevel = new BodyTextField({
         "text":param2.toString(),
         "color":16777215,
         "size":18,
         "bold":true
      });
      this.txt_newLevel.x = int(this.bmp_down.x + this.bmp_down.width + 4);
      this.txt_newLevel.y = int(this.txt_currentLevel.y);
      addChild(this.txt_newLevel);
   }
   
   public function dispose() : void
   {
      this.bmp_icon.bitmapData.dispose();
      this.bmp_icon.bitmapData = null;
      this.bmp_down.bitmapData.dispose();
      this.bmp_down.bitmapData = null;
      this.txt_currentLevel.dispose();
      this.txt_newLevel.dispose();
   }
}
