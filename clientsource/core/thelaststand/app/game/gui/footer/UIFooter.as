package thelaststand.app.game.gui.footer
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.CameraControlType;
   import thelaststand.app.game.events.GUIControlEvent;
   import thelaststand.app.game.gui.UIBarBackground;
   import thelaststand.app.game.gui.broadcast.BroadcastDisplay;
   import thelaststand.app.game.gui.buttons.UIBarButton;
   import thelaststand.app.game.gui.buttons.UIBarToggleButton;
   import thelaststand.app.game.gui.chat.commspanel.UICommsPanel;
   import thelaststand.app.game.gui.dialogues.OptionsDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class UIFooter extends Sprite
   {
      
      private var _allowFullscreen:Boolean = true;
      
      private var _lang:Language;
      
      private var _soundControlTimer:Timer;
      
      private var _overSoundButton:Boolean;
      
      private var _overMusicButton:Boolean;
      
      private var _minimized:Boolean = false;
      
      private var _tasksEnabled:Boolean = false;
      
      private var _stageWidth:int;
      
      private var _width:int;
      
      private var _height:int;
      
      private var mc_background:Shape;
      
      private var mc_activityTicker:BroadcastDisplay;
      
      private var mc_bar:UIBarBackground;
      
      private var mc_soundVolumeSlider:UIVolumeSlider;
      
      private var mc_musicVolumeSlider:UIVolumeSlider;
      
      private var btn_cameraZoomIn:UIBarButton;
      
      private var btn_cameraZoomOut:UIBarButton;
      
      private var btn_cameraRotate:UIBarButton;
      
      private var btn_sound:UIBarToggleButton;
      
      private var btn_music:UIBarToggleButton;
      
      private var btn_minimize:UIMinimizeTab;
      
      private var btn_fullscreen:UIBarButton;
      
      private var btn_options:UIBarButton;
      
      private var ui_tasks:UITaskPanel;
      
      private var ui_chat:UICommsPanel;
      
      private var bar_container:Sprite;
      
      public var minimizedChanged:Signal;
      
      public function UIFooter()
      {
         super();
         this.minimizedChanged = new Signal(Boolean);
         this._lang = Language.getInstance();
         this._soundControlTimer = new Timer(200,1);
         this._soundControlTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onSoundControlOverTimerComplete,false,0,true);
         this.bar_container = new Sprite();
         addChild(this.bar_container);
         this.mc_bar = new UIBarBackground();
         this.mc_bar.width += 4;
         this.mc_bar.height + 1;
         this.bar_container.addChild(this.mc_bar);
         this.btn_cameraZoomIn = new UIBarButton(new Bitmap(new BmpIconCameraZoomIn()));
         this.btn_cameraZoomIn.clicked.add(this.onButtonClicked);
         this.bar_container.addChild(this.btn_cameraZoomIn);
         this.btn_cameraZoomOut = new UIBarButton(new Bitmap(new BmpIconCameraZoomOut()));
         this.btn_cameraZoomOut.clicked.add(this.onButtonClicked);
         this.bar_container.addChild(this.btn_cameraZoomOut);
         this.btn_cameraRotate = new UIBarButton(new Bitmap(new BmpIconCameraRotate()));
         this.btn_cameraRotate.clicked.add(this.onButtonClicked);
         this.bar_container.addChild(this.btn_cameraRotate);
         this.btn_sound = new UIBarToggleButton(new Bitmap(new BmpIconSound()),new Bitmap(new BmpIconSoundOff()));
         this.btn_sound.pressed = Audio.soundMuted || Audio.sound.volume <= 0;
         this.btn_sound.mouseOver.add(this.onSoundControlMouseOver);
         this.btn_sound.mouseOut.add(this.onSoundControlMouseOut);
         this.btn_sound.clicked.add(this.onButtonClicked);
         this.bar_container.addChild(this.btn_sound);
         this.btn_music = new UIBarToggleButton(new Bitmap(new BmpIconMusic()),new Bitmap(new BmpIconMusicOff()));
         this.btn_music.pressed = Audio.musicMuted || Audio.music.volume <= 0;
         this.btn_music.mouseOver.add(this.onSoundControlMouseOver);
         this.btn_music.mouseOut.add(this.onSoundControlMouseOut);
         this.btn_music.clicked.add(this.onButtonClicked);
         this.bar_container.addChild(this.btn_music);
         this.btn_options = new UIBarButton(new Bitmap(new BmpIconSettings()));
         this.btn_options.clicked.add(this.onButtonClicked);
         this.bar_container.addChild(this.btn_options);
         this.btn_fullscreen = new UIBarButton(new Bitmap(new BmpIconFullscreen()));
         this.btn_fullscreen.clicked.add(this.onButtonClicked);
         this.btn_fullscreen.enabled = false;
         this.bar_container.addChild(this.btn_fullscreen);
         this.btn_minimize = new UIMinimizeTab();
         this.btn_minimize.addEventListener(MouseEvent.CLICK,this.onMinimizeClicked,false,0,true);
         this.btn_minimize.visible = false;
         addChildAt(this.btn_minimize,0);
         this.mc_soundVolumeSlider = new UIVolumeSlider();
         this.mc_soundVolumeSlider.volume = Audio.sound.volume;
         this.mc_soundVolumeSlider.changed.add(this.onSoundVolumeChanged);
         this.mc_soundVolumeSlider.mouseOut.add(this.onSoundControlVolumeSliderMouseOut);
         this.mc_musicVolumeSlider = new UIVolumeSlider();
         this.mc_musicVolumeSlider.volume = Audio.music.volume;
         this.mc_musicVolumeSlider.changed.add(this.onMusicVolumeChanged);
         this.mc_musicVolumeSlider.mouseOut.add(this.onSoundControlVolumeSliderMouseOut);
         this.mc_activityTicker = new BroadcastDisplay();
         addChild(this.mc_activityTicker);
         this.ui_chat = new UICommsPanel();
         addChild(this.ui_chat);
         this.ui_tasks = new UITaskPanel();
         addChild(this.ui_tasks);
         this._width = this.mc_bar.width;
         this._height = this.mc_bar.height + this.ui_tasks.height + 4;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(1645601);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,6,6,0.8,1)];
         addChildAt(this.mc_background,0);
         var _loc1_:TooltipManager = TooltipManager.getInstance();
         var _loc2_:Point = new Point(NaN,-10);
         _loc1_.add(this.btn_cameraZoomIn,this._lang.getString("tooltip.camera_zoom_in"),_loc2_,TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_cameraZoomOut,this._lang.getString("tooltip.camera_zoom_out"),_loc2_,TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_cameraRotate,this._lang.getString("tooltip.camera_rotate"),_loc2_,TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_fullscreen,this._lang.getString("tooltip.fullscreen"),_loc2_,TooltipDirection.DIRECTION_DOWN);
         _loc1_.add(this.btn_options,this._lang.getString("tooltip.settings"),_loc2_,TooltipDirection.DIRECTION_DOWN);
         DialogueManager.getInstance().dialogueOpened.add(this.onDialogueOpened);
         DialogueManager.getInstance().dialogueClosed.add(this.onDialogueClosed);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TooltipManager.getInstance().removeAllFromParent(this);
         DialogueManager.getInstance().dialogueOpened.remove(this.onDialogueOpened);
         DialogueManager.getInstance().dialogueClosed.remove(this.onDialogueClosed);
         this._soundControlTimer.stop();
         this._soundControlTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onSoundControlOverTimerComplete);
         this._lang = null;
         this.ui_chat = null;
         this.ui_tasks.dispose();
         this.ui_tasks = null;
         this.mc_activityTicker.dispose();
         this.mc_activityTicker = null;
         this.mc_soundVolumeSlider.dispose();
         this.mc_soundVolumeSlider = null;
         this.mc_musicVolumeSlider.dispose();
         this.mc_musicVolumeSlider = null;
      }
      
      public function hidePanels() : void
      {
         if(this.ui_tasks.parent != null)
         {
            this.ui_tasks.parent.removeChild(this.ui_tasks);
         }
         if(this.ui_chat.parent != null)
         {
            this.ui_chat.parent.removeChild(this.ui_chat);
         }
      }
      
      public function showPanels() : void
      {
         addChild(this.ui_tasks);
         addChild(this.ui_chat);
      }
      
      private function positionElements() : void
      {
         var _loc2_:int = 0;
         this.mc_bar.x = int((this._width - this.mc_bar.width) * 0.5);
         var _loc1_:int = Math.min(this.mc_bar.x + this.mc_bar.width - 20,this._width - 20);
         _loc2_ = 3;
         this.btn_minimize.x = int((this._width - this.btn_minimize.width) * 0.5);
         this.btn_minimize.y = int(this.mc_bar.y - this.btn_minimize.height);
         var _loc3_:int = _loc1_;
         var _loc4_:int = int(this.mc_bar.y + (this.mc_bar.height - this.btn_fullscreen.height) * 0.5);
         if(this.btn_fullscreen.parent != null)
         {
            _loc3_ -= this.btn_fullscreen.width;
            this.btn_fullscreen.x = _loc3_;
            this.btn_fullscreen.y = _loc4_;
         }
         this.btn_options.x = int(_loc3_ - this.btn_music.width - _loc2_);
         this.btn_options.y = _loc4_;
         this.btn_music.x = int(this.btn_options.x - this.btn_music.width - _loc2_);
         this.btn_music.y = _loc4_;
         this.btn_sound.x = int(this.btn_music.x - this.btn_sound.width - _loc2_);
         this.btn_sound.y = _loc4_;
         this.btn_cameraRotate.x = int(this.btn_sound.x - this.btn_cameraRotate.width - 20);
         this.btn_cameraRotate.y = _loc4_;
         this.btn_cameraZoomOut.x = int(this.btn_cameraRotate.x - this.btn_cameraZoomOut.width - _loc2_);
         this.btn_cameraZoomOut.y = _loc4_;
         this.btn_cameraZoomIn.x = int(this.btn_cameraZoomOut.x - this.btn_cameraZoomIn.width - _loc2_);
         this.btn_cameraZoomIn.y = _loc4_;
         this.mc_soundVolumeSlider.x = this.btn_sound.x;
         this.mc_soundVolumeSlider.y = int(this.btn_sound.y - this.mc_soundVolumeSlider.height + 1);
         this.mc_musicVolumeSlider.x = this.btn_music.x;
         this.mc_musicVolumeSlider.y = int(this.btn_music.y - this.mc_musicVolumeSlider.height + 1);
         this.mc_activityTicker.x = Math.max(this.mc_bar.x + 20,20);
         this.mc_activityTicker.y = int(this.mc_bar.y + (this.mc_bar.height - this.mc_activityTicker.height) * 0.5);
         this.mc_activityTicker.width = int(this.btn_cameraZoomIn.x - this.mc_activityTicker.x - 14);
         this.ui_tasks.x = this._width - this.ui_tasks.width - 2;
         this.ui_tasks.y = this._height - this.ui_tasks.height - 2;
         this.ui_chat.x = 2;
         this.ui_chat.y = this.ui_tasks.y;
         this.ui_chat.width = int(this.ui_tasks.x - this.ui_chat.x * 2);
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         var dlgOptions:OptionsDialogue = null;
         var msg:MessageBox = null;
         var e:MouseEvent = param1;
         switch(e.currentTarget)
         {
            case this.btn_cameraRotate:
               dispatchEvent(new GUIControlEvent(GUIControlEvent.CAMERA_CONTROL,true,false,CameraControlType.ROTATE));
               Tracking.trackEvent("Footer","CameraControl","Rotate");
               break;
            case this.btn_cameraZoomIn:
               dispatchEvent(new GUIControlEvent(GUIControlEvent.CAMERA_CONTROL,true,false,CameraControlType.ZOOM_IN));
               Tracking.trackEvent("Footer","CameraControl","ZoomIn");
               break;
            case this.btn_cameraZoomOut:
               dispatchEvent(new GUIControlEvent(GUIControlEvent.CAMERA_CONTROL,true,false,CameraControlType.ZOOM_OUT));
               Tracking.trackEvent("Footer","CameraControl","ZoomOut");
               break;
            case this.btn_fullscreen:
               try
               {
                  stage.displayState = stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN_INTERACTIVE;
                  if(stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
                  {
                     Tracking.trackEvent("Footer","Fullscreen");
                  }
                  break;
               }
               catch(e:Error)
               {
                  msg = new MessageBox(_lang.getString("no_fullscreen_msg"));
                  msg.addButton(_lang.getString("no_fullscreen_ok"));
                  msg.open();
                  break;
               }
               break;
            case this.btn_music:
               Audio.musicMuted = !Audio.musicMuted;
               this.btn_music.pressed = Audio.musicMuted || Audio.music.volume <= 0;
               this.mc_musicVolumeSlider.volume = Audio.music.volume;
               Tracking.trackEvent("Footer",Audio.musicMuted ? "MusicMuted" : "MusicUnmuted");
               break;
            case this.btn_sound:
               Audio.soundMuted = !Audio.soundMuted;
               this.btn_sound.pressed = Audio.soundMuted || Audio.sound.volume <= 0;
               this.mc_soundVolumeSlider.volume = Audio.sound.volume;
               Tracking.trackEvent("Footer",Audio.soundMuted ? "SoundMuted" : "SoundUnmuted");
               break;
            case this.btn_options:
               dlgOptions = new OptionsDialogue();
               dlgOptions.open();
         }
      }
      
      private function setMinimized(param1:Boolean) : void
      {
         this._minimized = param1;
         this.btn_minimize.state = this._minimized ? UIMinimizeTab.STATE_UP : UIMinimizeTab.STATE_DOWN;
         if(!this._minimized)
         {
            this.showPanels();
         }
         this.minimizedChanged.dispatch(this._minimized);
      }
      
      private function hideVolumeControl(param1:UIVolumeSlider) : void
      {
         if(param1.parent != null)
         {
            param1.parent.removeChild(param1);
         }
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onStageVolumeSliderMouseUp);
      }
      
      private function onSoundControlOverTimerComplete(param1:TimerEvent) : void
      {
         if(this._overSoundButton)
         {
            addChild(this.mc_soundVolumeSlider);
            if(this.mc_musicVolumeSlider.parent != null)
            {
               this.mc_musicVolumeSlider.parent.removeChild(this.mc_musicVolumeSlider);
            }
         }
         if(this._overMusicButton)
         {
            addChild(this.mc_musicVolumeSlider);
            if(this.mc_soundVolumeSlider.parent != null)
            {
               this.mc_soundVolumeSlider.parent.removeChild(this.mc_soundVolumeSlider);
            }
         }
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onStageVolumeSliderMouseUp,false,0,true);
      }
      
      private function onSoundControlMouseOver(param1:MouseEvent) : void
      {
         this._overSoundButton = param1.currentTarget == this.btn_sound;
         this._overMusicButton = param1.currentTarget == this.btn_music;
         if(param1.buttonDown)
         {
            return;
         }
         this._soundControlTimer.reset();
         this._soundControlTimer.start();
      }
      
      private function onSoundControlMouseOut(param1:MouseEvent) : void
      {
         this._soundControlTimer.stop();
         switch(param1.target)
         {
            case this.btn_sound:
               this._overSoundButton = false;
               if(param1 != null && (param1.relatedObject == this.mc_soundVolumeSlider || param1.relatedObject == this.mc_musicVolumeSlider))
               {
                  return;
               }
               this.hideVolumeControl(this.mc_soundVolumeSlider);
               break;
            case this.btn_music:
               this._overMusicButton = false;
               if(param1 != null && (param1.relatedObject == this.mc_musicVolumeSlider || param1.relatedObject == this.mc_musicVolumeSlider))
               {
                  return;
               }
               this.hideVolumeControl(this.mc_musicVolumeSlider);
         }
      }
      
      private function onStageVolumeSliderMouseUp(param1:MouseEvent) : void
      {
         if(param1.target == this.mc_soundVolumeSlider || param1.target == this.btn_sound)
         {
            return;
         }
         if(param1.target == this.mc_musicVolumeSlider || param1.target == this.btn_music)
         {
            return;
         }
         if(!this._overSoundButton)
         {
            this.hideVolumeControl(this.mc_soundVolumeSlider);
         }
         if(!this._overMusicButton)
         {
            this.hideVolumeControl(this.mc_musicVolumeSlider);
         }
      }
      
      private function onSoundControlVolumeSliderMouseOut(param1:UIVolumeSlider) : void
      {
         if(!this._overSoundButton || !this._overMusicButton)
         {
            this.hideVolumeControl(param1);
         }
      }
      
      private function onSoundVolumeChanged(param1:Number) : void
      {
         Audio.setSoundVolume(param1);
         if(Audio.soundMuted && param1 > 0)
         {
            Audio.soundMuted = false;
         }
         this.btn_sound.pressed = Audio.soundMuted || Audio.sound.volume <= 0;
      }
      
      private function onMusicVolumeChanged(param1:Number) : void
      {
         Audio.setMusicVolume(param1);
         if(Audio.musicMuted && param1 > 0)
         {
            Audio.musicMuted = false;
         }
         this.btn_music.pressed = Audio.musicMuted || Audio.music.volume <= 0;
      }
      
      private function onMinimizeClicked(param1:MouseEvent) : void
      {
         this.setMinimized(!this._minimized);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._stageWidth = stage.stageWidth;
         stage.addEventListener(Event.RESIZE,this.onStageResized,false,0,true);
         this.onStageResized(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(Event.RESIZE,this.onStageResized);
      }
      
      private function onStageResized(param1:Event) : void
      {
         var _loc2_:int = 1000;
         if(this._stageWidth >= _loc2_ && stage.stageWidth < _loc2_)
         {
            this.setMinimized(false);
         }
         this.btn_minimize.visible = stage.stageWidth > _loc2_;
         this._stageWidth = stage.stageWidth;
      }
      
      private function onDialogueOpened(param1:GenericEvent, param2:Dialogue) : void
      {
         var _loc3_:* = DialogueManager.getInstance().numModalDialoguesOpen <= 0;
         this.bar_container.mouseChildren = this.ui_tasks.mouseChildren = _loc3_;
      }
      
      private function onDialogueClosed(param1:GenericEvent, param2:Dialogue) : void
      {
         var _loc3_:* = DialogueManager.getInstance().numModalDialoguesOpen <= 0;
         this.bar_container.mouseChildren = this.ui_tasks.mouseChildren = _loc3_;
      }
      
      public function get allowFullscreen() : Boolean
      {
         return this._allowFullscreen;
      }
      
      public function set allowFullscreen(param1:Boolean) : void
      {
         this._allowFullscreen = param1;
         if(this._allowFullscreen)
         {
            addChild(this.btn_fullscreen);
            this.btn_fullscreen.enabled = true;
         }
         else if(this.btn_fullscreen.parent != null)
         {
            this.btn_fullscreen.parent.removeChild(this.btn_fullscreen);
            this.btn_fullscreen.enabled = false;
         }
         this.positionElements();
      }
      
      public function get tasksEnabled() : Boolean
      {
         return this._tasksEnabled;
      }
      
      public function set tasksEnabled(param1:Boolean) : void
      {
         this._tasksEnabled = param1;
         this.ui_tasks.enabled = this._tasksEnabled;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 > this.mc_bar.width)
         {
            param1 = this.mc_bar.width;
         }
         this._width = param1;
         this.positionElements();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get minimizedHeight() : Number
      {
         return this.mc_bar.height;
      }
      
      public function get minimized() : Boolean
      {
         return this._minimized;
      }
   }
}

