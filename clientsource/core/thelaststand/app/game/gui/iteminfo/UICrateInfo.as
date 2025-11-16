package thelaststand.app.game.gui.iteminfo
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.geom.Rectangle;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.network.Network;
   
   public class UICrateInfo extends UIGenericItemInfo
   {
      
      private var _crate:CrateItem;
      
      private var bmp_inspect:Bitmap;
      
      private var ui_contents:UICrateContentsTable;
      
      private var txt_contains:BodyTextField;
      
      private var txt_requires:BodyTextField;
      
      public function UICrateInfo()
      {
         super();
         _width = 284;
         txt_desc.width = int(_width - txt_desc.x);
         this.bmp_inspect = new Bitmap(new BmpIconInspect());
         addChild(this.bmp_inspect);
         this.txt_contains = new BodyTextField({
            "color":10724259,
            "size":14
         });
         this.txt_contains.y = int(mc_image.y + mc_image.height + 8);
         this.txt_contains.maxWidth = _width;
         addChild(this.txt_contains);
         this.txt_requires = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":14
         });
         this.txt_requires.maxWidth = _width;
         addChild(this.txt_requires);
         this.ui_contents = new UICrateContentsTable(_width);
         addChild(this.ui_contents);
      }
      
      override public function dispose() : void
      {
         this._crate = null;
         super.dispose();
         txt_desc.dispose();
         this.txt_requires.dispose();
         this.txt_contains.dispose();
         this.bmp_inspect.bitmapData.dispose();
         this.bmp_inspect.bitmapData = null;
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:uint = 0;
         var _loc14_:Boolean = false;
         if(!(param1 is CrateItem))
         {
            throw new Error("Item is not CrateItem");
         }
         this._crate = param1 as CrateItem;
         super.setItem(param1,param2);
         var _loc4_:String = _lang.getString("itm_desc." + _item.type);
         var _loc5_:Boolean = param3 == null || param3.showAction === true;
         if(!_loc5_)
         {
            _loc4_ = _loc4_.replace(/\[.*\]/img,"");
            this.bmp_inspect.visible = false;
         }
         txt_desc.htmlText = _loc4_.replace("%s","     ");
         var _loc6_:Rectangle = txt_desc.getCharBoundaries(_loc4_.indexOf("%s"));
         if(_loc6_ != null)
         {
            this.bmp_inspect.x = int(txt_desc.x + _loc6_.x - this.bmp_inspect.width + 2);
            this.bmp_inspect.y = int(txt_desc.y + _loc6_.y + (_loc6_.height - this.bmp_inspect.height) * 0.5 + 1);
         }
         this.txt_contains.htmlText = _lang.getString("crate_desc_contents");
         this.ui_contents.y = int(this.txt_contains.y + this.txt_contains.height + 8);
         var _loc7_:int = 0;
         while(_loc7_ < this._crate.contents.length)
         {
            param1 = this._crate.contents[_loc7_];
            _loc12_ = param1.getName();
            if(param1.quantifiable && param1.quantity > 1)
            {
               _loc12_ += " x " + NumberFormatter.format(param1.quantity,0);
            }
            if(param1 is EffectItem)
            {
               _loc13_ = new Color(Effects["COLOR_EFFECT_" + EffectItem(param1).effect.group.toUpperCase()]).multiply(2).RGB;
            }
            else
            {
               _loc13_ = uint(Effects["COLOR_" + ItemQualityType.getName(param1.qualityType)]);
            }
            this.ui_contents.addRow(_loc12_,_loc13_);
            _loc7_++;
         }
         this.ui_contents.addRow(_lang.getString("crate_desc_rare"),10724259);
         var _loc8_:String = "";
         var _loc9_:Boolean = false;
         var _loc10_:Vector.<String> = CrateItem.getKeyListForCrate(this._crate);
         for each(_loc11_ in _loc10_)
         {
            _loc14_ = Network.getInstance().playerData.inventory.containsType(_loc11_);
            _loc8_ += "<font color=\'" + (_loc14_ ? Color.colorToHex(Effects.COLOR_GOOD) : Color.colorToHex(Effects.COLOR_WARNING)) + "\'>" + _lang.getString("items." + _loc11_) + "</font> / ";
            if(_loc14_)
            {
               _loc9_ = true;
            }
         }
         _loc8_ = _loc8_.substr(0,_loc8_.length - 3);
         if(!_loc9_)
         {
            this.txt_requires.htmlText = "<font color=\'" + Color.colorToHex(Effects.COLOR_WARNING) + "\'>" + _lang.getString("crate_desc_reqkey",_loc8_) + "</font>";
         }
         else
         {
            this.txt_requires.htmlText = _lang.getString("crate_desc_reqkey",_loc8_);
         }
         this.txt_requires.y = int(this.ui_contents.y + this.ui_contents.height + 12);
         _height = int(this.txt_requires.y + this.txt_requires.height);
      }
   }
}

