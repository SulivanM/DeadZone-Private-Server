package thelaststand.app.game.gui.injury
{
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIMedicalItemSelectHeader extends UIComponent
   {
      
      private var _lang:Language = Language.getInstance();
      
      private var _width:int = 310;
      
      private var _height:int = 54;
      
      private var txt_minRequired:BodyTextField;
      
      private var txt_itemInfo:TitleTextField;
      
      public function UIMedicalItemSelectHeader(param1:String, param2:int)
      {
         super();
         this.txt_minRequired = new BodyTextField({
            "text":this._lang.getString("med_req"),
            "color":14803425,
            "size":13,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_minRequired);
         var _loc3_:String = this._lang.getString("med_class." + param1) + " - " + this._lang.getString("med_grade",param2);
         this.txt_itemInfo = new TitleTextField({
            "text":_loc3_.toUpperCase(),
            "color":12895428,
            "size":23,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_itemInfo);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.txt_itemInfo.dispose();
         this.txt_minRequired.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = -2;
         var _loc2_:int = this.txt_minRequired.height + _loc1_ + this.txt_itemInfo.height;
         this.txt_minRequired.x = 0;
         this.txt_minRequired.y = int((this._height - _loc2_) * 0.5);
         this.txt_itemInfo.x = 0;
         this.txt_itemInfo.y = int(this.txt_minRequired.y + this.txt_minRequired.height + _loc1_);
      }
   }
}

