package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class LongSessionValidationDialogue extends BaseDialogue
   {
      
      private var _numList:Array = ["2","3","4","6","7","8","9"];
      
      private var _charList:Array = ["A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","T","U","V","W","X","Z"];
      
      private var _chars:String = "";
      
      private var _timer:Timer;
      
      private var _trackOpen:Boolean = false;
      
      private var mc_container:Sprite = new Sprite();
      
      private var txt_message:BodyTextField;
      
      private var txt_characters:BodyTextField;
      
      private var input_validation:UIInputField;
      
      public function LongSessionValidationDialogue(param1:Boolean = true)
      {
         super("longSession",this.mc_container,false);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this._trackOpen = param1;
         this._timer = new Timer(15 * 60000,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
         this._chars = "";
         var _loc2_:int = 0;
         while(_loc2_ < 6)
         {
            this._chars += _loc2_ % 2 == 0 ? this._charList[int(Math.random() * this._charList.length)] : this._numList[int(Math.random() * this._numList.length)];
            _loc2_++;
         }
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":14,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_message.text = Language.getInstance().getString("longsession_message");
         this.mc_container.addChild(this.txt_message);
         this.txt_characters = new BodyTextField({
            "color":16777215,
            "size":24,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "letterSpacing":2
         });
         this.txt_characters.text = this._chars.toUpperCase();
         this.txt_characters.x = int((this.txt_message.width - this.txt_characters.width) * 0.5);
         this.txt_characters.y = int(this.txt_message.y + this.txt_message.height + 6);
         this.mc_container.addChild(this.txt_characters);
         this.input_validation = new UIInputField({
            "color":16777215,
            "size":20,
            "bold":true,
            "align":"center"
         });
         this.input_validation.width = this.txt_characters.width + 20;
         this.input_validation.x = int(this.txt_characters.x + (this.txt_characters.width - this.input_validation.width) * 0.5);
         this.input_validation.y = int(this.txt_characters.y + this.txt_characters.height + 6);
         this.input_validation.value = "";
         this.input_validation.textField.maxChars = this._chars.length;
         this.input_validation.textField.restrict = "0-9a-zA-Z";
         this.input_validation.textField.addEventListener(KeyboardEvent.KEY_UP,this.onKeyRelease,false,0,true);
         this.mc_container.addChild(this.input_validation);
         addTitle(Language.getInstance().getString("longsession_title"),BaseDialogue.TITLE_COLOR_GREY);
         addButton(Language.getInstance().getString("longsession_ok"),false,{"width":80}).clicked.add(this.onClickOK);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_message.dispose();
         this.txt_characters.dispose();
         this.input_validation.dispose();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.mc_container.stage.focus = this.input_validation.textField;
         this._timer.start();
         if(this._trackOpen)
         {
            Tracking.trackEvent("Player","LongSessionValidation","Opened");
         }
         Network.getInstance().send("lsv");
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._timer.stop();
      }
      
      private function onClickOK(param1:MouseEvent) : void
      {
         if(this.input_validation.value.toUpperCase() == this._chars.toUpperCase())
         {
            Tracking.trackEvent("Player","LongSessionValidation","Passed");
            Network.getInstance().send("lsv_ok");
            close();
         }
         else
         {
            this.input_validation.value = "";
            Audio.sound.play("sound/interface/int-error.mp3");
         }
      }
      
      private function onKeyRelease(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.onClickOK(null);
         }
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         Tracking.trackEvent("Player","LongSessionValidation","Kicked");
         Global.document.kill();
      }
   }
}

