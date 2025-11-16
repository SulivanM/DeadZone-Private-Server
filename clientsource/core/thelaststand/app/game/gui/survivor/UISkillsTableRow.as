package thelaststand.app.game.gui.survivor
{
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   
   public class UISkillsTableRow extends Sprite
   {
      
      private var _showModButtons:Boolean;
      
      private var _value:Number = 0;
      
      private var _width:int;
      
      private var _height:int;
      
      private var txt_label:TitleTextField;
      
      private var txt_value:BodyTextField;
      
      public var attribute:String;
      
      public function UISkillsTableRow(param1:int, param2:int, param3:String, param4:int, param5:Number)
      {
         super();
         this._width = param1;
         this._height = param2;
         graphics.beginFill(param4,param5);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         this.txt_label = new TitleTextField({
            "color":11908533,
            "size":16,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_label.text = param3;
         this.txt_label.x = 2;
         this.txt_label.y = -1;
         this.txt_label.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_label);
         this.txt_value = new BodyTextField({
            "color":11908533,
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_value.text = "0";
         this.txt_value.y = this.txt_label.y;
         this.txt_value.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_value);
      }
      
      public function dispose() : void
      {
         this.txt_label.dispose();
         this.txt_label = null;
         this.txt_value.dispose();
         this.txt_value = null;
      }
      
      public function get labelColor() : uint
      {
         return this.txt_label.textColor;
      }
      
      public function set labelColor(param1:uint) : void
      {
         this.txt_label.textColor = param1;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function set value(param1:int) : void
      {
         this._value = param1;
         this.txt_value.text = this._value.toString();
         this.txt_value.x = int(this._width - this.txt_value.width - 2);
      }
      
      public function get valueColor() : uint
      {
         return this.txt_value.textColor;
      }
      
      public function set valueColor(param1:uint) : void
      {
         this.txt_value.textColor = param1;
      }
   }
}

