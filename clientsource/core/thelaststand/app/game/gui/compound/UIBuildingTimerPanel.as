package thelaststand.app.game.gui.compound
{
   import flash.display.Shape;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.utils.DateTimeUtils;
   
   public class UIBuildingTimerPanel extends UIBuildingJobPanel
   {
      
      private var _time:Object;
      
      private var _message:String;
      
      private var mc_timeBackground:Shape;
      
      private var txt_time:BodyTextField;
      
      private var txt_message:TitleTextField;
      
      public function UIBuildingTimerPanel()
      {
         super(100,120);
         this.mc_timeBackground = new Shape();
         this.mc_timeBackground.graphics.beginFill(2960685);
         this.mc_timeBackground.graphics.drawRect(0,0,86,30);
         this.mc_timeBackground.graphics.endFill();
         this.mc_timeBackground.filters = [new DropShadowFilter(0,0,0,1,6,6,1,1,true),new GlowFilter(6974058,1,1.5,1.5,10,1)];
         this.mc_timeBackground.x = int((width - this.mc_timeBackground.width) * 0.5);
         this.mc_timeBackground.y = 38;
         addChild(this.mc_timeBackground);
         this.txt_time = new BodyTextField({
            "color":16777215,
            "size":18,
            "align":"center",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_time.text = " ";
         this.txt_time.maxWidth = this.mc_timeBackground.width - 4;
         this.txt_time.y = int(this.mc_timeBackground.y + (this.mc_timeBackground.height - this.txt_time.height) * 0.5);
         addChild(this.txt_time);
         this.txt_message = new TitleTextField({
            "color":8421503,
            "size":12,
            "leading":-1,
            "multiline":true,
            "align":"center",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_message.text = " ";
         this.txt_message.width = width;
         addChild(this.txt_message);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_time.dispose();
         this.txt_message.dispose();
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function set message(param1:String) : void
      {
         this._message = param1;
         this.txt_message.htmlText = this._message.toUpperCase();
         var _loc2_:int = height - 10 - (this.mc_timeBackground.y + this.mc_timeBackground.height);
         this.txt_message.y = int(this.mc_timeBackground.y + this.mc_timeBackground.height + (_loc2_ - this.txt_message.height) * 0.5);
      }
      
      public function get time() : Object
      {
         return this._time;
      }
      
      public function set time(param1:Object) : void
      {
         var _loc2_:String = null;
         this._time = param1;
         if(this._time is String)
         {
            _loc2_ = String(this._time);
         }
         else if(!isNaN(Number(this._time)))
         {
            _loc2_ = DateTimeUtils.secondsToString(Number(this._time),true,true,false);
         }
         else
         {
            _loc2_ = DateTimeUtils.timeDataToString(this._time,true);
         }
         this.txt_time.text = _loc2_;
         this.txt_time.x = int(this.mc_timeBackground.x + (this.mc_timeBackground.width - this.txt_time.width) * 0.5);
         this.txt_time.y = int(this.mc_timeBackground.y + (this.mc_timeBackground.height - this.txt_time.height) * 0.5);
      }
   }
}

