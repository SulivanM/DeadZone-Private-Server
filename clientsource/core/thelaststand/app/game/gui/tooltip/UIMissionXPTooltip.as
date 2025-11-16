package thelaststand.app.game.gui.tooltip
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.common.lang.Language;
   
   public class UIMissionXPTooltip extends Sprite
   {
      
      private var _data:Object;
      
      private var _labels:Vector.<BodyTextField> = new Vector.<BodyTextField>();
      
      private var _values:Vector.<BodyTextField> = new Vector.<BodyTextField>();
      
      private var _fields:Vector.<String> = new <String>["total","kills","bKills","scav","rest","bonus"];
      
      private var txt_outofrange:BodyTextField;
      
      public function UIMissionXPTooltip()
      {
         super();
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         this.draw();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._data = null;
         this.diposeFields();
      }
      
      private function draw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:uint = 0;
         var _loc12_:BodyTextField = null;
         var _loc13_:BodyTextField = null;
         this.diposeFields();
         graphics.clear();
         if(this._data == null)
         {
            return;
         }
         var _loc3_:Boolean = Boolean(this._data.awarded);
         var _loc4_:int = 0;
         while(_loc4_ < this._fields.length)
         {
            _loc9_ = this._fields[_loc4_];
            _loc10_ = _loc3_ ? int(this._data[_loc9_]) : 0;
            _loc11_ = _loc10_ == 0 ? Effects.COLOR_GREYOUT : (_loc10_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
            _loc12_ = new BodyTextField({
               "bold":true,
               "color":_loc11_,
               "size":13,
               "antiAliasType":AntiAliasType.ADVANCED
            });
            _loc13_ = new BodyTextField({
               "bold":true,
               "color":_loc11_,
               "size":13,
               "antiAliasType":AntiAliasType.ADVANCED
            });
            _loc12_.text = Language.getInstance().getString("mission_xp_" + _loc9_);
            _loc13_.text = (_loc10_ < 0 ? "-" : "+") + NumberFormatter.format(Math.abs(_loc10_),0);
            addChild(_loc12_);
            addChild(_loc13_);
            if(_loc12_.width > _loc1_)
            {
               _loc1_ = _loc12_.width;
            }
            if(_loc13_.width > _loc2_)
            {
               _loc2_ = _loc13_.width;
            }
            this._labels.push(_loc12_);
            this._values.push(_loc13_);
            _loc4_++;
         }
         _loc5_ = 0;
         _loc6_ = 0;
         var _loc7_:int = Math.max(_loc1_ + _loc2_ + 40,130);
         var _loc8_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < this._fields.length)
         {
            _loc12_ = this._labels[_loc4_];
            _loc12_.x = _loc5_;
            _loc12_.y = _loc6_;
            _loc13_ = this._values[_loc4_];
            _loc13_.x = _loc7_ - _loc13_.width - _loc5_;
            _loc13_.y = _loc6_;
            _loc6_ += Math.max(_loc12_.height,_loc13_.height) + _loc8_;
            if(_loc4_ == 0)
            {
               _loc6_ += 6 - _loc8_;
               graphics.lineStyle(1,3881787,1,true);
               graphics.moveTo(0,_loc6_);
               graphics.lineTo(_loc7_,_loc6_);
               _loc6_ += 6;
            }
            _loc4_++;
         }
         if(_loc3_ && this.data.outofrange === true)
         {
            _loc6_ += 6 - _loc8_;
            graphics.lineStyle(1,3881787,1,true);
            graphics.moveTo(0,_loc6_);
            graphics.lineTo(_loc7_,_loc6_);
            _loc6_ += 6;
            this.txt_outofrange = new BodyTextField({
               "bold":true,
               "color":Effects.COLOR_WARNING,
               "size":13,
               "antiAliasType":AntiAliasType.ADVANCED,
               "multiline":true,
               "width":_loc7_
            });
            this.txt_outofrange.x = _loc5_;
            this.txt_outofrange.y = _loc6_;
            this.txt_outofrange.text = Language.getInstance().getString("mission_xp_outofrange");
            addChild(this.txt_outofrange);
            _loc6_ += this.txt_outofrange.height + _loc8_;
         }
      }
      
      private function diposeFields() : void
      {
         var _loc1_:BodyTextField = null;
         for each(_loc1_ in this._labels)
         {
            _loc1_.dispose();
         }
         for each(_loc1_ in this._values)
         {
            _loc1_.dispose();
         }
         if(this.txt_outofrange != null)
         {
            this.txt_outofrange.dispose();
            this.txt_outofrange = null;
         }
         this._labels.length = 0;
         this._values.length = 0;
      }
   }
}

