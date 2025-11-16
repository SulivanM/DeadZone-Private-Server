package thelaststand.app.game.gui.quest
{
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIQuestTrackerItemRow extends Sprite
   {
      
      private var _fields:Vector.<BodyTextField>;
      
      private var _tx:int;
      
      public var spacing:int = 0;
      
      public function UIQuestTrackerItemRow()
      {
         super();
         this._fields = new Vector.<BodyTextField>();
      }
      
      public function addColumn(param1:String, param2:int = -1, param3:uint = 16777215) : int
      {
         var _loc4_:BodyTextField = new BodyTextField({
            "htmlText":param1,
            "color":param3,
            "size":12,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.STROKE]
         });
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.x = this._tx;
         if(param2 < 0)
         {
            _loc4_.multiline = _loc4_.wordWrap = false;
         }
         else
         {
            _loc4_.multiline = _loc4_.wordWrap = true;
            _loc4_.width = param2;
         }
         this._tx += _loc4_.width + 4;
         this._fields.push(_loc4_);
         addChild(_loc4_);
         return this._tx;
      }
      
      public function dispose() : void
      {
         var _loc1_:BodyTextField = null;
         for each(_loc1_ in this._fields)
         {
            _loc1_.dispose();
         }
         this._fields = null;
      }
   }
}

