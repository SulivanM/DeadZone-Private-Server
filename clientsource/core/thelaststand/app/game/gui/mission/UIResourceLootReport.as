package thelaststand.app.game.gui.mission
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.common.lang.Language;
   
   public class UIResourceLootReport extends Sprite
   {
      
      private var _items:Vector.<Sprite>;
      
      private var mc_container:Sprite;
      
      public function UIResourceLootReport(param1:Dictionary, param2:Boolean = false)
      {
         var _loc4_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Sprite = null;
         var _loc9_:String = null;
         var _loc10_:Class = null;
         var _loc11_:Bitmap = null;
         var _loc12_:int = 0;
         var _loc13_:BodyTextField = null;
         super();
         this.mc_container = new Sprite();
         addChild(this.mc_container);
         this._items = new Vector.<Sprite>();
         var _loc3_:Array = GameResources.getResourceList();
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc3_[_loc5_];
            if(!(!param2 && _loc7_ == GameResources.CASH))
            {
               _loc8_ = new Sprite();
               _loc8_.x = _loc4_;
               if(_loc7_ == GameResources.CASH)
               {
                  _loc9_ = "BmpIconFuel";
               }
               else
               {
                  _loc9_ = "BmpIcon" + _loc7_.substr(0,1).toUpperCase() + _loc7_.substr(1);
               }
               _loc10_ = getDefinitionByName(_loc9_) as Class;
               _loc11_ = new Bitmap(new _loc10_(),"auto",true);
               _loc11_.name = "bitmap";
               _loc11_.filters = [Effects.ICON_SHADOW];
               _loc8_.addChild(_loc11_);
               _loc12_ = isNaN(param1[_loc7_]) ? 0 : int(param1[_loc7_]);
               _loc13_ = new BodyTextField({
                  "color":16777215,
                  "size":14,
                  "bold":true
               });
               _loc13_.name = "txt";
               _loc13_.text = Language.getInstance().getString("amount",NumberFormatter.format(_loc12_,0));
               _loc13_.filters = [Effects.STROKE];
               _loc13_.x = int(_loc11_.x + _loc11_.width + 2);
               _loc13_.y = -int(_loc13_.height * 0.5);
               _loc8_.addChild(_loc13_);
               _loc11_.y = int(_loc13_.y + (_loc13_.height - _loc11_.height) * 0.5);
               _loc4_ += int(_loc13_.x + _loc13_.width + 10);
               this.mc_container.addChild(_loc8_);
               this._items.push(_loc8_);
            }
            _loc5_++;
         }
      }
      
      public function dispose() : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Bitmap = null;
         var _loc4_:BodyTextField = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._items.length)
         {
            _loc2_ = this._items[_loc1_];
            TweenMax.killTweensOf(_loc2_);
            _loc3_ = Bitmap(_loc2_.getChildByName("bitmap"));
            _loc3_.bitmapData.dispose();
            _loc3_.bitmapData = null;
            _loc3_.filters = [];
            _loc4_ = BodyTextField(_loc2_.getChildByName("txt"));
            _loc4_.dispose();
            _loc1_++;
         }
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._items.length)
         {
            TweenMax.from(this._items[_loc2_],0.5,{
               "delay":param1 + _loc2_ / 16,
               "alpha":0,
               "y":"10"
            });
            _loc2_++;
         }
      }
   }
}

