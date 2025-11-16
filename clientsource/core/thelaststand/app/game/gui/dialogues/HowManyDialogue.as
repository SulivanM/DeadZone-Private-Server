package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldType;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class HowManyDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _textAreaWidth:int = 84;
      
      private var _textAreaHeight:int = 28;
      
      private var _amount:int;
      
      private var _maxAmount:int;
      
      private var _amountDir:int = 0;
      
      private var _timer:Timer;
      
      private var mc_container:Sprite;
      
      private var btn_decrease:PushButton;
      
      private var btn_increase:PushButton;
      
      private var txt_message:BodyTextField;
      
      private var txt_amount:BodyTextField;
      
      public var amountSelected:Signal;
      
      public function HowManyDialogue(param1:String, param2:String, param3:int)
      {
         var tx:int = 0;
         var ty:int = 0;
         var title:String = param1;
         var message:String = param2;
         var maxAmount:int = param3;
         this._lang = Language.getInstance();
         this._maxAmount = this._amount = maxAmount;
         this._timer = new Timer(1000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
         this.amountSelected = new Signal(int);
         this.mc_container = new Sprite();
         super("how-many-dialogue",this.mc_container,true);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         addTitle(title,BaseDialogue.TITLE_COLOR_GREY);
         this.txt_message = new BodyTextField({
            "htmlText":message,
            "color":16777215,
            "size":14,
            "width":280,
            "align":"center",
            "multiline":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_message.y = int(_padding * 0.5);
         this.mc_container.addChild(this.txt_message);
         tx = int((this.txt_message.width - this._textAreaWidth) * 0.5);
         ty = this.txt_message.y + this.txt_message.height + 10;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this._textAreaWidth,28,tx,ty);
         this.txt_amount = new BodyTextField({
            "text":NumberFormatter.format(this._amount,0),
            "color":16777215,
            "size":17,
            "bold":true,
            "autoSize":"none",
            "align":"center",
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_amount.addEventListener(FocusEvent.FOCUS_IN,this.onAmountFocusIn,false,0,true);
         this.txt_amount.addEventListener(FocusEvent.FOCUS_OUT,this.onAmountFocusOut,false,0,true);
         this.txt_amount.type = TextFieldType.INPUT;
         this.txt_amount.selectable = true;
         this.txt_amount.mouseEnabled = true;
         this.txt_amount.width = this._textAreaWidth;
         this.txt_amount.x = tx;
         this.txt_amount.y = int(ty + (this._textAreaHeight - this.txt_amount.height) * 0.5 - 1);
         this.mc_container.addChild(this.txt_amount);
         this.btn_decrease = new PushButton("",new BmpIconButtonPrev());
         this.btn_decrease.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonMouseDown,false,0,true);
         this.btn_decrease.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         this.btn_decrease.width = this.btn_decrease.height;
         this.btn_decrease.x = tx - this.btn_decrease.width - 6;
         this.btn_decrease.y = ty + 2;
         this.mc_container.addChild(this.btn_decrease);
         this.btn_increase = new PushButton("",new BmpIconButtonNext());
         this.btn_increase.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonMouseDown,false,0,true);
         this.btn_increase.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         this.btn_increase.width = this.btn_increase.height;
         this.btn_increase.x = tx + this._textAreaWidth + 6;
         this.btn_increase.y = this.btn_decrease.y;
         this.mc_container.addChild(this.btn_increase);
         addButton(this._lang.getString("howmany_cancel"),true,{"width":100});
         addButton(this._lang.getString("howmany_ok"),false,{"width":100}).clicked.addOnce(function(param1:MouseEvent):void
         {
            amountSelected.dispatch(_amount);
            close();
         });
         this.updateAmount();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimerTick,false);
         this._timer.stop();
         this.amountSelected.removeAll();
         this.btn_decrease.dispose();
         this.btn_decrease = null;
         this.btn_increase.dispose();
         this.btn_increase = null;
         this.txt_message.dispose();
         this.txt_message = null;
         this.txt_amount.dispose();
         this.txt_amount = null;
      }
      
      private function onButtonMouseDown(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_decrease:
               this._amountDir = -1;
               break;
            case this.btn_increase:
               this._amountDir = 1;
         }
         this._timer.delay = 250;
         this._timer.reset();
         this._timer.start();
         this.updateAmount();
      }
      
      private function onButtonMouseUp(param1:MouseEvent) : void
      {
         this._amountDir = 0;
         this._timer.stop();
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this._timer.delay *= 0.9;
         this.updateAmount();
      }
      
      private function updateAmount() : void
      {
         this._amount += 1 * this._amountDir;
         this._amount = Math.max(1,Math.min(this._maxAmount,this._amount));
         this.txt_amount.text = NumberFormatter.format(this._amount,0);
         this.btn_decrease.enabled = this._amount > 1;
         this.btn_increase.enabled = this._amount < this._maxAmount;
      }
      
      private function onAmountFocusIn(param1:FocusEvent) : void
      {
         this.txt_amount.text = this._amount.toString();
         this.txt_amount.restrict = "0-9";
         this.txt_amount.setSelection(0,this.txt_amount.text.length);
      }
      
      private function onAmountFocusOut(param1:FocusEvent) : void
      {
         this._amount = Math.max(1,Math.min(this._maxAmount,int(this.txt_amount.text)));
         this.txt_amount.text = NumberFormatter.format(this._amount,0);
         this.txt_amount.restrict = null;
      }
   }
}

