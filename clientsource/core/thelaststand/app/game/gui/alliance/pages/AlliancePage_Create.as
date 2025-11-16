package thelaststand.app.game.gui.alliance.pages
{
   import com.adobe.images.JPGEncoder;
   import com.dynamicflash.util.Base64;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerPanelEditor;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.AllianceCreateSuccessDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Create extends Sprite implements IAlliancePage
   {
      
      private static const TRIM_REG:RegExp = /(^\s*|\s*$)/ig;
      
      private static const STIP_SPACE_REG:RegExp = /\s/ig;
      
      private var _dialogue:AllianceDialogue;
      
      private var _bannerEditor:AllianceBannerPanelEditor;
      
      private var mainPanel:Sprite;
      
      private var bmp_titleBar:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var input_name:UIInputField;
      
      private var input_tag:UIInputField;
      
      private var tick_name:Bitmap;
      
      private var tick_tag:Bitmap;
      
      private var bd_tick:BitmapData;
      
      private var bd_cross:BitmapData;
      
      private var txt_errorName:BodyTextField;
      
      private var txt_errorTag:BodyTextField;
      
      private var btn_help:HelpButton;
      
      private var btn_continue:PushButton;
      
      private var btn_buy:PurchasePushButton;
      
      private var defaultContent:DefaultContent;
      
      private var disclaimerContent:DisclaimerContent;
      
      private var autoGenTag:Boolean = true;
      
      private var busyMsg:BusyDialogue;
      
      private var _lang:Language;
      
      private var _allianceBannerTemp:BitmapData;
      
      public function AlliancePage_Create()
      {
         var _loc1_:Number = NaN;
         super();
         this._bannerEditor = new AllianceBannerPanelEditor();
         addChild(this._bannerEditor);
         this._bannerEditor.onReady.dispatch(this.checkContinueStatus);
         this._lang = Language.getInstance();
         _loc1_ = 470;
         var _loc2_:Number = 368;
         this.mainPanel = new Sprite();
         GraphicUtils.drawUIBlock(this.mainPanel.graphics,_loc1_,_loc2_);
         this.mainPanel.x = this._bannerEditor.x + this._bannerEditor.width + 12;
         addChild(this.mainPanel);
         this.bmp_titleBar = new Bitmap(new BmpTopBarBackground(),"always",true);
         this.bmp_titleBar.x = this.bmp_titleBar.y = 5;
         this.bmp_titleBar.width = _loc1_ - this.bmp_titleBar.x * 2;
         this.bmp_titleBar.height = 32;
         this.mainPanel.addChild(this.bmp_titleBar);
         this.bmp_titleBar.filters = [Effects.STROKE];
         this.txt_title = new BodyTextField({
            "text":this._lang.getString("alliance.create_title"),
            "size":20,
            "bold":true,
            "align":TextFormatAlign.CENTER,
            "autoSize":TextFieldAutoSize.CENTER,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.x = this.bmp_titleBar.x;
         this.txt_title.width = this.bmp_titleBar.width;
         this.txt_title.maxWidth = this.txt_title.width;
         this.txt_title.y = this.bmp_titleBar.y + 1;
         this.mainPanel.addChild(this.txt_title);
         this.input_name = new UIInputField({
            "color":16777215,
            "size":20
         });
         this.input_name.textField.addEventListener(Event.CHANGE,this.onNameChanged,false,0,true);
         this.input_name.textField.restrict = "\'a-zA-Z0-9.\\- ";
         this.input_name.textField.maxChars = 22;
         this.input_name.defaultValue = this._lang.getString("alliance.create_name");
         this.input_name.width = 227;
         this.input_name.height = 27;
         this.input_name.x = 10;
         this.input_name.y = 50;
         this.mainPanel.addChild(this.input_name);
         this.input_tag = new UIInputField({
            "color":16777215,
            "size":20
         });
         this.input_tag.textField.addEventListener(Event.CHANGE,this.onTagChanged,false,0,true);
         this.input_tag.textField.restrict = "a-zA-Z0-9.!#$%^&=\\-+*";
         this.input_tag.textField.maxChars = 3;
         this.input_tag.defaultValue = this._lang.getString("alliance.create_tag");
         this.input_tag.width = 143;
         this.input_tag.height = this.input_name.height;
         this.input_tag.x = 285;
         this.input_tag.y = this.input_name.y;
         this.mainPanel.addChild(this.input_tag);
         this.bd_tick = new BmpExitZoneOK();
         this.bd_cross = new BmpExitZoneBad();
         this.tick_name = new Bitmap(this.bd_tick);
         this.tick_name.x = this.input_name.x + this.input_name.width + 6;
         this.tick_name.y = this.input_name.y;
         this.mainPanel.addChild(this.tick_name);
         this.tick_name.visible = false;
         this.tick_tag = new Bitmap(this.bd_cross);
         this.tick_tag.x = this.input_tag.x + this.input_tag.width + 6;
         this.tick_tag.y = this.input_tag.y;
         this.mainPanel.addChild(this.tick_tag);
         this.tick_tag.visible = false;
         this.txt_errorName = new BodyTextField({
            "text":this._lang.getString("alliance.create_name_subtitle"),
            "color":10066329,
            "size":13
         });
         this.txt_errorName.x = this.input_name.x;
         this.txt_errorName.y = this.input_name.y + this.input_name.height + 2;
         this.mainPanel.addChild(this.txt_errorName);
         this.txt_errorTag = new BodyTextField({
            "text":this._lang.getString("alliance.create_tag_subtitle"),
            "color":10066329,
            "size":13
         });
         this.txt_errorTag.x = this.input_tag.x;
         this.txt_errorTag.y = this.txt_errorName.y;
         this.mainPanel.addChild(this.txt_errorTag);
         this.btn_help = new HelpButton("alliance.create_help");
         this.btn_help.x = 0;
         this.btn_help.y = _loc2_ + 5;
         this.mainPanel.addChild(this.btn_help);
         this.btn_continue = new PushButton(this._lang.getString("alliance.create_continue"));
         this.btn_continue.x = _loc1_ - this.btn_continue.width - 5;
         this.btn_continue.y = _loc2_ + 10;
         this.btn_continue.enabled = false;
         this.btn_continue.clicked.add(this.onButtonClicked);
         this.mainPanel.addChild(this.btn_continue);
         var _loc3_:int = int(Network.getInstance().data.costTable.getItemByKey("AllianceCreation").PriceCoins);
         this.btn_buy = new PurchasePushButton(this._lang.getString("alliance.create_buy"),_loc3_,true);
         this.btn_buy.width = 180;
         this.btn_buy.x = _loc1_ - this.btn_buy.width - 5;
         this.btn_buy.y = this.btn_continue.y;
         this.btn_buy.enabled = false;
         this.btn_buy.clicked.add(this.onButtonClicked);
         var _loc4_:TooltipManager = TooltipManager.getInstance();
         _loc4_.add(this.btn_continue,this.getContinueButtonToolTip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         this.defaultContent = new DefaultContent();
         this.defaultContent.x = this.input_name.x;
         this.defaultContent.y = 105;
         this.mainPanel.addChild(this.defaultContent);
         this.disclaimerContent = new DisclaimerContent();
         this.disclaimerContent.x = this.defaultContent.x;
         this.disclaimerContent.y = this.defaultContent.y;
         this.disclaimerContent.onChange.add(this.checkContinueStatus);
         Network.getInstance().onShutdownMissionsLockChange.add(this.onShutdownLocked);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TooltipManager.getInstance().removeAllFromParent(this);
         this._lang = null;
         this._dialogue = null;
         this._bannerEditor.dispose();
         this.bmp_titleBar.bitmapData.dispose();
         this.input_name.dispose();
         this.input_tag.dispose();
         this.txt_errorName.dispose();
         this.txt_errorTag.dispose();
         this.defaultContent.dispose();
         this.disclaimerContent.dispose();
         this.btn_help.dispose();
         if(this.busyMsg)
         {
            this.busyMsg.close();
         }
         this.bd_cross.dispose();
         this.bd_tick.dispose();
         Network.getInstance().onShutdownMissionsLockChange.remove(this.onShutdownLocked);
      }
      
      private function getContinueButtonToolTip() : String
      {
         return Language.getInstance().getString(Network.getInstance().shutdownMissionsLocked ? "tooltip.allianceCreate_shutdown" : "tooltip.allianceCreate");
      }
      
      private function checkContinueStatus() : void
      {
         this.btn_continue.enabled = false;
         if(this._bannerEditor.ready && this.input_name.value.replace(TRIM_REG,"") != "" && this.input_name.value.replace(STIP_SPACE_REG,"").length > 3 && this.input_tag.value.replace(TRIM_REG,"") != "" && this.input_tag.value.replace(STIP_SPACE_REG,"").length > 1)
         {
            this.btn_continue.enabled = true;
         }
         if(Network.getInstance().playerData.getPlayerSurvivor().level < int(Config.constant.ALLIANCE_MIN_CREATE_LEVEL))
         {
            this.btn_continue.enabled = false;
         }
         if(Network.getInstance().shutdownMissionsLocked)
         {
            this.btn_continue.enabled = false;
         }
         this.btn_buy.enabled = this.btn_continue.enabled && this.disclaimerContent.accepted;
      }
      
      private function createAlliance() : void
      {
         var jpeg:JPGEncoder;
         var thumbBase64:String;
         var bytes64:String;
         var data:Object;
         this.tick_name.visible = this.tick_tag.visible = false;
         this.txt_errorName.text = this._lang.getString("alliance.create_name_subtitle") + "!!!!";
         this.txt_errorTag.text = this._lang.getString("alliance.create_tag_subtitle");
         this.txt_errorName.textColor = this.txt_errorTag.textColor = 10066329;
         this.busyMsg = new BusyDialogue(this._lang.getString("alliance.create_busyCreating"),"busy-allianceCreate");
         this.busyMsg.open();
         jpeg = new JPGEncoder(90);
         thumbBase64 = Base64.encodeByteArray(jpeg.encode(this._bannerEditor.generateThumbnail()));
         bytes64 = Base64.encodeByteArray(this._bannerEditor.byteArray);
         data = {
            "name":this.input_name.value.replace(TRIM_REG,""),
            "tag":this.input_tag.value,
            "bannerBytes":bytes64,
            "thumbImage":thumbBase64
         };
         this._allianceBannerTemp = this._bannerEditor.generateBitmap();
         Network.getInstance().startAsyncOp();
         Network.getInstance().save(data,SaveDataMethod.ALLIANCE_CREATE,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            var _loc3_:Network = null;
            var _loc4_:AllianceSystem = null;
            Network.getInstance().completeAsyncOp();
            busyMsg.close();
            busyMsg = null;
            if(stage != null)
            {
               tick_name.visible = tick_tag.visible = true;
               tick_name.bitmapData = param1.nameSuccess ? bd_tick : bd_cross;
               tick_tag.bitmapData = param1.tagSuccess ? bd_tick : bd_cross;
               if(param1.nameSuccess == false)
               {
                  txt_errorName.text = _lang.getString("alliance.create_name_error");
                  txt_errorName.textColor = 13580817;
               }
               if(param1.tagSuccess == false)
               {
                  txt_errorTag.text = _lang.getString("alliance.create_tag_error");
                  txt_errorTag.textColor = 13580817;
               }
            }
            if(!param1.success)
            {
               if(Boolean(param1.nameSuccess) && Boolean(param1.tagSuccess))
               {
                  _loc2_ = new MessageBox(_lang.getString("alliance.create_error"),null,true);
                  _loc2_.open();
               }
            }
            else
            {
               busyMsg = new BusyDialogue(_lang.getString("alliance.create_busyConnecting"),"busy-allianceConnecting");
               busyMsg.open();
               _loc3_ = Network.getInstance();
               _loc3_.playerData.allianceId = param1["allianceId"];
               _loc3_.playerData.allianceTag = param1["allianceTag"];
               _loc4_ = AllianceSystem.getInstance();
               _loc4_.connect();
               _loc4_.connected.addOnce(onAllianceConnected);
               _loc4_.connectionFailed.addOnce(onAllianceConnectionFail);
            }
         });
      }
      
      private function onAllianceConnected() : void
      {
         var _loc1_:AllianceSystem = AllianceSystem.getInstance();
         _loc1_.connected.remove(this.onAllianceConnected);
         _loc1_.connectionFailed.remove(this.onAllianceConnectionFail);
         this.busyMsg.close();
         this.busyMsg = null;
         new AllianceCreateSuccessDialogue(this._allianceBannerTemp).open();
         this._allianceBannerTemp = null;
      }
      
      private function onAllianceConnectionFail() : void
      {
         var _loc1_:AllianceSystem = AllianceSystem.getInstance();
         _loc1_.connected.remove(this.onAllianceConnected);
         _loc1_.connectionFailed.remove(this.onAllianceConnectionFail);
         this.busyMsg.close();
         this.busyMsg = null;
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("alliance.create_connectError"),null,true);
         _loc2_.open();
         this.dialogue.close();
         if(this._allianceBannerTemp)
         {
            this._allianceBannerTemp.dispose();
         }
         this._allianceBannerTemp = null;
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_continue:
               if(this.btn_continue.parent)
               {
                  this.btn_continue.parent.removeChild(this.btn_continue);
               }
               if(this.defaultContent.parent)
               {
                  this.defaultContent.parent.removeChild(this.defaultContent);
               }
               this.mainPanel.addChild(this.disclaimerContent);
               this.mainPanel.addChild(this.btn_buy);
               break;
            case this.btn_buy:
               this.createAlliance();
         }
      }
      
      private function onNameChanged(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         this.checkContinueStatus();
         if(this.input_tag.value == "")
         {
            this.autoGenTag = true;
         }
         if(this.autoGenTag)
         {
            _loc2_ = "";
            _loc3_ = this.input_name.value.replace(TRIM_REG,"");
            if(_loc3_.indexOf(" ") > -1)
            {
               _loc4_ = _loc3_.split(" ");
               for each(_loc5_ in _loc4_)
               {
                  if(_loc5_ != "")
                  {
                     _loc2_ += _loc5_.charAt(0);
                  }
               }
               _loc2_ = _loc2_.substr(0,Math.min(this.input_tag.textField.maxChars,_loc2_.length));
            }
            else
            {
               _loc2_ = _loc3_.substr(0,Math.min(this.input_tag.textField.maxChars,_loc3_.length));
            }
            this.input_tag.value = _loc2_.toUpperCase();
         }
      }
      
      private function onTagChanged(param1:Event) : void
      {
         if(this.input_tag.value.replace(TRIM_REG,"").length == 0)
         {
            this.autoGenTag = true;
         }
         else
         {
            this.autoGenTag = false;
         }
         this.checkContinueStatus();
      }
      
      private function onShutdownLocked(param1:Boolean) : void
      {
         if(!this.btn_continue.parent)
         {
            this.mainPanel.addChild(this.btn_continue);
         }
         if(!this.defaultContent.parent)
         {
            this.mainPanel.addChild(this.defaultContent);
         }
         if(this.disclaimerContent.parent)
         {
            this.mainPanel.removeChild(this.disclaimerContent);
         }
         if(this.btn_buy.parent)
         {
            this.mainPanel.removeChild(this.btn_buy);
         }
         this.checkContinueStatus();
      }
      
      public function get dialogue() : AllianceDialogue
      {
         return this._dialogue;
      }
      
      public function set dialogue(param1:AllianceDialogue) : void
      {
         this._dialogue = param1;
      }
   }
}

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import org.osflash.signals.Signal;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.gui.CheckBox;
import thelaststand.app.gui.UIImage;
import thelaststand.common.lang.Language;

class DefaultContent extends Sprite
{
   
   private var image:UIImage;
   
   private var txt_message:BodyTextField;
   
   public function DefaultContent()
   {
      super();
      graphics.beginFill(1447446,1);
      graphics.drawRect(0,230,450,25);
      this.image = new UIImage(450,226,3618615);
      this.image.x = 0;
      this.image.y = 0;
      this.image.uri = "images/alliances/create_hero.jpg";
      addChild(this.image);
      this.txt_message = new BodyTextField({
         "text":Language.getInstance().getString("alliance.create_requirement"),
         "color":12910592,
         "size":16
      });
      this.txt_message.x = int((this.image.width - this.txt_message.width) * 0.5);
      this.txt_message.y = 255 - this.txt_message.height - 1;
      addChild(this.txt_message);
   }
   
   public function dispose() : void
   {
      this.image.dispose();
      this.txt_message.dispose();
   }
}

class DisclaimerContent extends Sprite
{
   
   public var onChange:Signal;
   
   private var txt_title:BodyTextField;
   
   private var txt_desc:BodyTextField;
   
   private var check_confirm:CheckBox;
   
   private var checkPoints:Vector.<DisclaimerPoint>;
   
   public function DisclaimerContent()
   {
      var _loc6_:DisplayObject = null;
      var _loc7_:DisclaimerPoint = null;
      super();
      this.onChange = new Signal();
      var _loc1_:Language = Language.getInstance();
      var _loc2_:Number = 450;
      var _loc3_:Number = 252;
      graphics.beginFill(1447446,1);
      graphics.drawRect(0,0,_loc2_,_loc3_);
      this.txt_title = new BodyTextField({
         "text":_loc1_.getString("alliance.create_warnTitle"),
         "size":14,
         "color":Effects.COLOR_WARNING,
         "x":12,
         "y":10,
         "wordWrap":true
      });
      this.txt_title.width = _loc2_ - 24;
      addChild(this.txt_title);
      this.txt_desc = new BodyTextField({
         "text":_loc1_.getString("alliance.create_warnDesc"),
         "size":13,
         "color":9079434,
         "x":this.txt_title.x,
         "y":this.txt_title.y + this.txt_title.height,
         "wordWrap":true
      });
      this.txt_desc.width = _loc2_ - 24;
      addChild(this.txt_desc);
      var _loc4_:String = _loc1_.getString("alliance.create_warnPoints");
      var _loc5_:Array = _loc4_.split("*");
      this.checkPoints = new Vector.<DisclaimerPoint>();
      for each(_loc4_ in _loc5_)
      {
         _loc7_ = new DisclaimerPoint(_loc4_);
         _loc7_.x = this.txt_title.x + 20;
         if(_loc6_)
         {
            _loc7_.y = int(_loc6_.y + _loc6_.height + 4);
         }
         else
         {
            _loc7_.y = 74;
         }
         addChild(_loc7_);
         this.checkPoints.push(_loc7_);
         _loc6_ = _loc7_;
      }
      this.check_confirm = new CheckBox({"htmlText":_loc1_.getString("alliance.create_warnCheck")},"right");
      this.check_confirm.x = int((_loc2_ - this.check_confirm.width) * 0.5);
      this.check_confirm.y = _loc3_ - this.check_confirm.height - 10;
      this.check_confirm.changed.add(this.onCheckboxChange);
      addChild(this.check_confirm);
      addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
   }
   
   public function dispose() : void
   {
      var _loc1_:DisclaimerPoint = null;
      removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      this.onChange.removeAll();
      this.txt_title.dispose();
      this.txt_desc.dispose();
      for each(_loc1_ in this.checkPoints)
      {
         _loc1_.dispose();
      }
      if(parent)
      {
         parent.removeChild(this);
      }
   }
   
   private function onRemovedFromStage(param1:Event) : void
   {
      this.check_confirm.selected = false;
      this.onChange.dispatch();
   }
   
   public function get accepted() : Boolean
   {
      return this.check_confirm.selected;
   }
   
   private function onCheckboxChange(param1:CheckBox) : void
   {
      this.onChange.dispatch();
   }
}

class DisclaimerPoint extends Sprite
{
   
   private var txt:BodyTextField;
   
   public function DisclaimerPoint(param1:String)
   {
      super();
      graphics.beginFill(5329233,1);
      graphics.drawRect(0,7,7,7);
      this.txt = new BodyTextField({
         "htmlText":param1,
         "size":13,
         "color":9079434,
         "x":15,
         "width":385,
         "wordWrap":true
      });
      addChild(this.txt);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.txt.dispose();
   }
}
