package thelaststand.app.game.gui.survivor
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.AttributeOptions;
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorSkillDetails extends Sprite
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _rows:Vector.<UISkillsTableRow>;
      
      private var _rowsById:Dictionary;
      
      private var _rowColor:uint = 1447446;
      
      private var _rowHeight:int = 20;
      
      private var mc_details:Sprite;
      
      public function UISurvivorSkillDetails(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._rows = new Vector.<UISkillsTableRow>();
         this.mc_details = new Sprite();
         addChild(this.mc_details);
         this.setSize(param1,param2);
      }
      
      public function dispose() : void
      {
         var _loc1_:UISkillsTableRow = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this._rows)
         {
            _loc1_.dispose();
         }
         this._rows = null;
         this._rowsById = null;
      }
      
      private function disposeCurrentData() : void
      {
         var _loc1_:UISkillsTableRow = null;
         for each(_loc1_ in this._rows)
         {
            if(_loc1_.parent != null)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
         this._rows.length = 0;
         this._rowsById = new Dictionary(true);
      }
      
      public function showSurvivorStats(param1:Survivor, param2:SurvivorLoadout) : void
      {
         var _loc8_:String = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:String = null;
         var _loc16_:UISkillsTableRow = null;
         var _loc17_:Array = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         this.disposeCurrentData();
         var _loc3_:int = 0;
         var _loc4_:Language = Language.getInstance();
         var _loc5_:Array = Attributes.getAttributes();
         _loc5_.sort();
         var _loc6_:int = 0;
         var _loc7_:int = int(_loc5_.length);
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc5_[_loc6_];
            _loc9_ = param1.getAttribute(_loc8_,param2);
            _loc10_ = param1.getAttribute(_loc8_,param2,AttributeOptions.INCLUDE_NONE);
            _loc11_ = param1.getAttribute(_loc8_,false,AttributeOptions.INCLUDE_NONE);
            _loc12_ = param1.getAttribute(_loc8_,false,AttributeOptions.INCLUDE_MORALE);
            _loc13_ = param1.getAttribute(_loc8_,false,AttributeOptions.INCLUDE_INJURIES);
            _loc14_ = param1.getAttribute(_loc8_,false,AttributeOptions.INCLUDE_MORALE | AttributeOptions.INCLUDE_INJURIES);
            _loc15_ = _loc4_.getString("att." + _loc8_).toUpperCase();
            _loc16_ = new UISkillsTableRow(this._width,this._rowHeight,_loc15_,this._rowColor,_loc6_ % 2 == 0 ? 1 : 0);
            _loc16_.attribute = _loc8_;
            _loc16_.y = _loc3_;
            this.mc_details.addChild(_loc16_);
            _loc16_.value = Math.floor(_loc9_ * 10);
            _loc16_.alpha = _loc16_.value == 0 ? 0.4 : 1;
            _loc16_.valueColor = _loc11_ == _loc14_ ? 11908533 : (_loc14_ < _loc11_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
            _loc16_.labelColor = _loc11_ == _loc10_ ? 11908533 : (_loc10_ < _loc11_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
            this._rows.push(_loc16_);
            this._rowsById[_loc8_] = _loc16_;
            _loc3_ += this._rowHeight + 1;
            _loc17_ = [_loc4_.getString("att_desc." + _loc16_.attribute)];
            if(_loc9_ > 0)
            {
               _loc18_ = Math.floor((_loc12_ - _loc11_) / _loc11_ * 100);
               if(_loc18_ != 0)
               {
                  _loc17_.push("<font color=\'" + Color.colorToHex(_loc18_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc4_.getString("tooltip.morale_mod",(_loc18_ < 0 ? "" : "+") + _loc18_) + "</font>");
               }
               _loc19_ = Math.floor((_loc13_ - _loc11_) / _loc11_ * 100);
               if(_loc19_ != 0)
               {
                  _loc17_.push("<font color=\'" + Color.colorToHex(_loc19_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc4_.getString("tooltip.injury_mod",(_loc19_ < 0 ? "" : "+") + _loc19_) + "</font>");
               }
               if(_loc11_ != _loc10_)
               {
                  _loc17_.push((_loc17_.length > 0 ? "<br/>" : "") + param2.getAffectedAttributeDescription(ItemAttributes.GROUP_SURVIVOR,_loc16_.attribute));
               }
            }
            TooltipManager.getInstance().add(_loc16_,_loc17_.join("<br/>"),new Point(_loc16_.width,NaN),TooltipDirection.DIRECTION_LEFT);
            _loc6_++;
         }
      }
      
      public function showSurvivorClassStats(param1:SurvivorClass, param2:int) : void
      {
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:UISkillsTableRow = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         this.disposeCurrentData();
         var _loc3_:int = 0;
         var _loc4_:Language = Language.getInstance();
         var _loc5_:Array = Attributes.getAttributes();
         _loc5_.sort();
         var _loc6_:int = 0;
         var _loc7_:int = int(_loc5_.length);
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc5_[_loc6_];
            _loc9_ = _loc4_.getString("att." + _loc8_).toUpperCase();
            _loc10_ = new UISkillsTableRow(this._width,this._rowHeight,_loc9_,this._rowColor,_loc6_ % 2 == 0 ? 1 : 0);
            _loc10_.attribute = _loc8_;
            _loc10_.y = _loc3_;
            this.mc_details.addChild(_loc10_);
            _loc11_ = Number(param1.baseAttributes[_loc8_]);
            _loc12_ = Number(param1.levelAttributes[_loc8_]);
            _loc13_ = _loc11_ + param2 * _loc12_;
            _loc10_.value = int(_loc13_ * 10);
            _loc10_.alpha = _loc10_.value == 0 ? 0.4 : 1;
            _loc10_.valueColor = _loc10_.labelColor = 11908533;
            TooltipManager.getInstance().add(_loc10_,_loc4_.getString("att_desc." + _loc10_.attribute),new Point(_loc10_.width,NaN),TooltipDirection.DIRECTION_LEFT,0.05);
            this._rows.push(_loc10_);
            this._rowsById[_loc8_] = _loc10_;
            _loc3_ += this._rowHeight + 1;
            _loc6_++;
         }
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
      }
      
      private function onScrollbarChanged(param1:Number) : void
      {
      }
   }
}

