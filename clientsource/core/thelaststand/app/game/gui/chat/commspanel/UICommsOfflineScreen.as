package thelaststand.app.game.gui.chat.commspanel
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Elastic;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.common.lang.Language;
   
   public class UICommsOfflineScreen extends Sprite
   {
      
      public var onConnect:Signal;
      
      public var onDisconnect:Signal;
      
      private var _chatSystem:ChatSystem;
      
      private var _compactMode:Boolean = false;
      
      private var _enabled:Boolean = true;
      
      private var bg:Bitmap;
      
      private var bd_backgroundNorm:BitmapData;
      
      private var bd_backgroundSmall:BitmapData;
      
      private var _soundWaveContainer:Sprite;
      
      private var _showSoundWave:Boolean = false;
      
      private var _waveHitArea:Sprite;
      
      private var mc_soundwave:MovieClip;
      
      private var frequencyLight:Bitmap;
      
      private var _lampContainer:Sprite;
      
      private var lamp_receiver:Bitmap;
      
      private var lamp_tower:Bitmap;
      
      private var lamp_2way:Bitmap;
      
      private var _connectContainer:Sprite;
      
      private var btn_connect:PushButton;
      
      private var _title:BodyTextField;
      
      private var _showDisconnect:Boolean = false;
      
      private var _language:Language;
      
      private var _lampByBuilding:Dictionary;
      
      private var _buildings:BuildingCollection;
      
      private var _termsCheckbox:TermsCheckBox;
      
      public function UICommsOfflineScreen()
      {
         var _loc3_:BodyTextField = null;
         this.onConnect = new Signal();
         this.onDisconnect = new Signal();
         this._language = Language.getInstance();
         super();
         this._chatSystem = Network.getInstance().chatSystem;
         this._chatSystem.onAllowedChannelsChange.add(this.updateConnectDisplay);
         this.bd_backgroundNorm = new BmpChatOfflineScreenBG();
         this.bg = new Bitmap(this.bd_backgroundNorm);
         addChild(this.bg);
         this._soundWaveContainer = new Sprite();
         addChild(this._soundWaveContainer);
         this._waveHitArea = new Sprite();
         this._waveHitArea.graphics.beginFill(0,0.5);
         this._waveHitArea.graphics.drawRect(0,0,136,108);
         this._waveHitArea.x = 43;
         this._waveHitArea.y = 47;
         this._waveHitArea.alpha = 0;
         this._waveHitArea.addEventListener(MouseEvent.CLICK,this.toggleSoundWave,false,0,true);
         this._soundWaveContainer.addChild(this._waveHitArea);
         this.mc_soundwave = new UIChatSoundwaveMC();
         this.mc_soundwave.x = 111;
         this.mc_soundwave.y = 102;
         this._soundWaveContainer.addChild(this.mc_soundwave);
         this.mc_soundwave.mouseEnabled = this.mc_soundwave.mouseChildren = false;
         this.frequencyLight = new Bitmap(new BmpIndicatorRedLamp());
         this.frequencyLight.x = 32;
         this.frequencyLight.y = 156;
         this._soundWaveContainer.addChild(this.frequencyLight);
         this._title = new BodyTextField({
            "size":13,
            "color":10197915,
            "bold":true
         });
         this._title.text = this._language.getString("chat.offline_title");
         this._title.y = 8;
         addChild(this._title);
         this._lampContainer = new Sprite();
         addChild(this._lampContainer);
         var _loc1_:BodyTextField = new BodyTextField({
            "size":13,
            "color":15856113,
            "bold":true
         });
         _loc1_.text = this._language.getString("chat.offline_equipment_title");
         _loc1_.x = 64 - _loc1_.width * 0.5;
         _loc1_.y = 45;
         _loc1_.filters = [new GlowFilter(0,0.3,5,5,2)];
         this._lampContainer.addChild(_loc1_);
         var _loc2_:GlowFilter = new GlowFilter(0,0.5,6,6,2);
         _loc3_ = new BodyTextField({
            "size":13,
            "color":7105644,
            "bold":true
         });
         _loc3_.text = this._language.getString("chat.offline_equipment_receiver");
         _loc3_.x = 31;
         _loc3_.y = 73;
         _loc3_.filters = [_loc2_];
         this._lampContainer.addChild(_loc3_);
         _loc3_ = new BodyTextField({
            "size":13,
            "color":7105644,
            "bold":true
         });
         _loc3_.text = this._language.getString("chat.offline_equipment_tower");
         _loc3_.x = 31;
         _loc3_.y = 102;
         _loc3_.filters = [_loc2_];
         this._lampContainer.addChild(_loc3_);
         _loc3_ = new BodyTextField({
            "size":13,
            "color":7105644,
            "bold":true
         });
         _loc3_.text = this._language.getString("chat.offline_equipment_2way");
         _loc3_.x = 31;
         _loc3_.y = 131;
         _loc3_.filters = [_loc2_];
         this._lampContainer.addChild(_loc3_);
         this._lampByBuilding = new Dictionary();
         var _loc4_:BitmapData = new BmpIndicatorGreenLamp();
         this.lamp_receiver = new Bitmap(_loc4_);
         this.lamp_receiver.y = 68;
         this._lampContainer.addChild(this.lamp_receiver);
         this._lampByBuilding["comm-radio-receiver"] = this.lamp_receiver;
         this.lamp_tower = new Bitmap(_loc4_);
         this.lamp_tower.y = 96;
         this._lampContainer.addChild(this.lamp_tower);
         this._lampByBuilding["comm-radio-tower"] = this.lamp_tower;
         this.lamp_2way = new Bitmap(new BmpIndicatorYellowLamp());
         this.lamp_2way.y = 125;
         this._lampContainer.addChild(this.lamp_2way);
         this._lampByBuilding["comm-two-way"] = this.lamp_2way;
         this._connectContainer = new Sprite();
         addChild(this._connectContainer);
         this.btn_connect = new PushButton(this._language.getString("chat.offline_network_connectBtn"));
         this.btn_connect.width = 108;
         this.btn_connect.height = 38;
         this.btn_connect.y = 78;
         this._connectContainer.addChild(this.btn_connect);
         this.btn_connect.clicked.add(this.onConnectClick);
         var _loc5_:BodyTextField = new BodyTextField({
            "size":13,
            "color":15856113,
            "bold":true
         });
         _loc5_.text = this._language.getString("chat.offline_network_title");
         _loc5_.x = (this.btn_connect.width - _loc5_.width) * 0.5;
         _loc5_.y = 45;
         _loc5_.filters = [new GlowFilter(0,0.3,5,5,2)];
         this._connectContainer.addChild(_loc5_);
         this._termsCheckbox = new TermsCheckBox(this._language.getString("chat.offline_terms"));
         this._termsCheckbox.x = this.btn_connect.x - 7;
         this._termsCheckbox.y = this.btn_connect.y + this.btn_connect.height + 14;
         this._connectContainer.addChild(this._termsCheckbox);
         this._termsCheckbox.changed.add(this.onTermsCheckboxChange);
         this.compactMode = false;
         this.setShowSoundwave(false);
         this._buildings = Network.getInstance().playerData.compound.buildings;
         this._buildings.buildingAdded.add(this.onBuildingChange);
         this._buildings.buildingRemoved.add(this.onBuildingChange);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.updateConnectDisplay();
         this.updateBuildingLights();
      }
      
      private function toggleSoundWave(param1:MouseEvent) : void
      {
         if(!this._enabled || !this._termsCheckbox.enabled)
         {
            return;
         }
         this.setShowSoundwave(!this._showSoundWave);
      }
      
      private function setShowSoundwave(param1:Boolean) : void
      {
         this._showSoundWave = param1;
         if(this._showSoundWave)
         {
            TweenMax.to(this.mc_soundwave,1,{
               "scaleY":1,
               "ease":Elastic.easeInOut,
               "easeParams":[3]
            });
            TweenMax.to(this.mc_soundwave,0.01,{"autoAlpha":1});
            TweenMax.to(this.frequencyLight,0.05,{"autoAlpha":1});
            Audio.sound.play("sound/interface/int-comms-switch-on.mp3");
         }
         else
         {
            TweenMax.to(this.mc_soundwave,0.78,{
               "scaleY":0,
               "ease":Elastic.easeOut
            });
            TweenMax.to(this.mc_soundwave,0.78,{
               "autoAlpha":0,
               "ease":Linear.easeOut
            });
            TweenMax.to(this.frequencyLight,0.5,{"autoAlpha":0});
            Audio.sound.play("sound/interface/int-comms-switch-off.mp3");
         }
         TweenMax.to(this._waveHitArea,0.8,{"alpha":(this._showSoundWave ? 0 : 1)});
      }
      
      private function onConnectClick(param1:MouseEvent) : void
      {
         if(this._showDisconnect)
         {
            this.onDisconnect.dispatch();
         }
         else
         {
            if(!this._termsCheckbox.selected)
            {
               Audio.sound.play("sound/interface/int-error.mp3");
               this._termsCheckbox.highlight();
               return;
            }
            this.onConnect.dispatch();
         }
      }
      
      private function updateConnectDisplay() : void
      {
         var _loc1_:Boolean = this._enabled && this._chatSystem.isChannelAllowed(ChatSystem.CHANNEL_PUBLIC);
         this.setShowSoundwave(_loc1_);
         var _loc2_:String = this._language.getString(this._showDisconnect ? "chat.offline_network_disconnectBtn" : "chat.offline_network_connectBtn");
         if(!this._enabled)
         {
            _loc2_ = this._language.getString("chat.offline_network_connectBtnOffline");
         }
         this.btn_connect.label = _loc2_;
         this.btn_connect.enabled = _loc1_;
         this._termsCheckbox.enabled = _loc1_ && !this._showDisconnect;
      }
      
      private function onTermsCheckboxChange() : void
      {
         this.updateConnectDisplay();
      }
      
      private function onBuildingChange(param1:Building) : void
      {
         if(!this._lampByBuilding[param1.type])
         {
            return;
         }
         this.updateBuildingLights();
      }
      
      private function updateBuildingLights() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this._lampByBuilding)
         {
            this._lampByBuilding[_loc1_].visible = this._enabled && this.processBuildingStatus(_loc1_);
         }
      }
      
      private function processBuildingStatus(param1:String) : Boolean
      {
         var _loc2_:Vector.<Building> = this._buildings.getBuildingsOfType(param1);
         if(_loc2_.length == 0)
         {
            return false;
         }
         var _loc3_:Building = _loc2_[0];
         if(_loc3_ != null)
         {
            if(!(_loc3_.isUnderConstruction() && Boolean(_loc3_.upgradeTimer)))
            {
               return true;
            }
            _loc3_.upgradeTimer.completed.add(this.handleBuildingTimerComplete);
         }
         return false;
      }
      
      private function handleBuildingTimerComplete(param1:TimerData) : void
      {
         this.updateBuildingLights();
      }
      
      public function get showDisconnect() : Boolean
      {
         return this._showDisconnect;
      }
      
      public function set showDisconnect(param1:Boolean) : void
      {
         this._showDisconnect = param1;
         this.updateConnectDisplay();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseChildren = this._enabled;
         this.updateConnectDisplay();
         this.updateBuildingLights();
      }
      
      public function get compactMode() : Boolean
      {
         return this._compactMode;
      }
      
      public function set compactMode(param1:Boolean) : void
      {
         this._compactMode = param1;
         if(this._compactMode)
         {
            if(!this.bd_backgroundSmall)
            {
               this.bd_backgroundSmall = new BmpChatOfflineScreenBGSmall();
            }
            this.bg.bitmapData = this.bd_backgroundSmall;
            if(this._soundWaveContainer.parent)
            {
               this._soundWaveContainer.parent.removeChild(this._soundWaveContainer);
            }
            this._lampContainer.x = 31;
            this._connectContainer.x = 180;
            this._title.x = 165 - this._title.width * 0.5;
         }
         else
         {
            this.bg.bitmapData = this.bd_backgroundNorm;
            addChild(this._soundWaveContainer);
            this._lampContainer.x = 201;
            this._connectContainer.x = 355;
            this._title.x = 245 - this._title.width * 0.5;
         }
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.filters.DropShadowFilter;
import flash.text.StyleSheet;
import flash.text.TextFieldAutoSize;
import org.osflash.signals.Signal;
import thelaststand.app.audio.Audio;
import thelaststand.app.display.BodyTextField;

class TermsCheckBox extends Sprite
{
   
   private var _checkColor:uint = 7829367;
   
   private var _selected:Boolean;
   
   private var _enabled:Boolean = true;
   
   private var txt_label:BodyTextField;
   
   private var mc_checkContainer:Sprite;
   
   private var mc_border:Shape;
   
   private var mc_checkbox:Shape;
   
   private var mc_check:Sprite;
   
   public var changed:Signal;
   
   public var linkClicked:Signal;
   
   public function TermsCheckBox(param1:String)
   {
      var _loc2_:Number = NaN;
      super();
      this.changed = new Signal();
      this.linkClicked = new Signal(String);
      this.mc_checkContainer = new Sprite();
      addChild(this.mc_checkContainer);
      this.mc_checkContainer.mouseChildren = false;
      _loc2_ = 12;
      var _loc3_:Number = 12;
      this.mc_checkbox = new Shape();
      this.mc_checkbox.filters = [new DropShadowFilter(0,0,0,1,8,8,0.9,1,true)];
      this.mc_checkContainer.addChild(this.mc_checkbox);
      this.mc_checkbox.graphics.clear();
      this.mc_checkbox.graphics.beginFill(0,0);
      this.mc_checkbox.graphics.drawRect(-_loc2_,-_loc3_,_loc2_ * 3,_loc3_ * 3);
      this.mc_checkbox.graphics.beginFill(3552051);
      this.mc_checkbox.graphics.drawRect(0,0,_loc2_,_loc3_);
      this.mc_checkbox.graphics.endFill();
      this.mc_border = new Shape();
      this.mc_checkContainer.addChild(this.mc_border);
      var _loc4_:int = 1;
      this.mc_border.graphics.clear();
      this.mc_border.graphics.beginFill(7829367);
      this.mc_border.graphics.drawRect(0,0,_loc2_,_loc3_);
      this.mc_border.graphics.drawRect(_loc4_,_loc4_,_loc2_ - _loc4_ * 2,_loc3_ - _loc4_ * 2);
      this.mc_border.graphics.endFill();
      this.mc_check = new Sprite();
      this.mc_check.visible = this._selected;
      this.mc_checkContainer.addChild(this.mc_check);
      this.mc_check.graphics.clear();
      this.mc_check.graphics.beginFill(7829367);
      this.mc_check.graphics.drawRect(0,0,Math.round(_loc2_ * 0.5),Math.round(_loc3_ * 0.5));
      this.mc_check.graphics.endFill();
      this.mc_check.x = Math.round((_loc2_ - this.mc_check.width) * 0.5);
      this.mc_check.y = Math.round((_loc3_ - this.mc_check.height) * 0.5);
      this.txt_label = new BodyTextField({
         "color":7895160,
         "size":10,
         "wordWrap":true,
         "autoSize":TextFieldAutoSize.LEFT,
         "multiline":true
      });
      this.txt_label.width = 110;
      var _loc5_:StyleSheet = new StyleSheet();
      _loc5_.parseCSS("a { textDecoration:underline; color: #9a9a9a; }");
      _loc5_.parseCSS("a:hover { textDecoration:underline;, color:#ffffff; }");
      this.txt_label.styleSheet = _loc5_;
      this.txt_label.mouseEnabled = true;
      this.txt_label.x = _loc2_ + 4;
      this.txt_label.y = -2;
      this.txt_label.htmlText = param1;
      addChild(this.txt_label);
      this.mc_checkContainer.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      this.txt_label.addEventListener(TextEvent.LINK,this.onTextLink,false,0,true);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.txt_label.dispose();
      this.txt_label = null;
      this.mc_checkbox.filters = [];
      this.mc_checkbox = null;
      this.changed.removeAll();
      this.linkClicked.removeAll();
      this.mc_checkContainer.removeEventListener(MouseEvent.CLICK,this.onClick);
      this.txt_label.removeEventListener(TextEvent.LINK,this.onTextLink);
   }
   
   public function highlight() : void
   {
      TweenMax.to(this.mc_border,0,{"tint":16711680});
      TweenMax.to(this.txt_label,0,{"tint":16711680});
   }
   
   private function onClick(param1:MouseEvent) : void
   {
      this.selected = !this.selected;
      this.changed.dispatch();
      TweenMax.to(this.mc_border,0,{"tint":null});
      TweenMax.to(this.txt_label,0,{"tint":null});
      Audio.sound.play("sound/interface/int-click.mp3");
   }
   
   private function onTextLink(param1:TextEvent) : void
   {
      Audio.sound.play("sound/interface/int-click.mp3");
      this.linkClicked.dispatch(param1.text);
   }
   
   public function get selected() : Boolean
   {
      return this._selected;
   }
   
   public function set selected(param1:Boolean) : void
   {
      this._selected = param1;
      this.mc_check.visible = this._selected;
   }
   
   public function get enabled() : Boolean
   {
      return this._enabled;
   }
   
   public function set enabled(param1:Boolean) : void
   {
      this._enabled = param1;
      mouseChildren = this._enabled;
      mouseEnabled = this._enabled;
      alpha = this._enabled ? 1 : 0.3;
   }
   
   override public function set width(param1:Number) : void
   {
   }
   
   override public function set height(param1:Number) : void
   {
   }
}
