package thelaststand.app.display
{
   import flash.events.Event;
   import flash.text.TextField;
   import flash.utils.getTimer;
   
   public class TextFieldTyper
   {
      
      private var _elapsed:Number = 0;
      
      private var _target:TextField;
      
      private var _text:String;
      
      private var _speed:Number;
      
      private var _timeLast:Number;
      
      private var _stringIndex:int;
      
      public function TextFieldTyper(param1:TextField)
      {
         super();
         this._target = param1;
         this._target.text = "";
      }
      
      public function dispose() : void
      {
         this._target.removeEventListener(Event.ENTER_FRAME,this.onUpdate);
         this._target = null;
         this._text = null;
         this._speed = 0;
      }
      
      public function pause() : void
      {
         this._target.removeEventListener(Event.ENTER_FRAME,this.onUpdate);
      }
      
      public function resume(param1:Boolean = false) : void
      {
         if(param1)
         {
            this._stringIndex = 0;
         }
         this._target.addEventListener(Event.ENTER_FRAME,this.onUpdate);
         this._timeLast = getTimer();
         this._elapsed = 0;
      }
      
      public function type(param1:String, param2:Number = 30) : void
      {
         this._text = param1;
         this._speed = param2;
         this._stringIndex = 0;
         this._target.text = " ";
         this._target.addEventListener(Event.ENTER_FRAME,this.onUpdate);
         this._timeLast = getTimer();
         this._elapsed = 0;
         this.onUpdate(null);
      }
      
      private function onUpdate(param1:Event) : void
      {
         if(this._text == null)
         {
            return;
         }
         var _loc2_:Number = getTimer();
         var _loc3_:Number = 1000 / this._speed;
         this._elapsed += _loc2_ - this._timeLast;
         this._timeLast = _loc2_;
         while(this._elapsed >= _loc3_)
         {
            ++this._stringIndex;
            this._target.text = this._text.substr(0,this._stringIndex);
            if(this._stringIndex == this._text.length)
            {
               this._target.removeEventListener(Event.ENTER_FRAME,this.onUpdate);
               return;
            }
            this._elapsed -= _loc3_;
         }
      }
   }
}

