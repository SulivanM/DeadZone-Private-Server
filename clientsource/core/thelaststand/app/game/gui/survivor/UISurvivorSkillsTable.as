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
   
   public class UISurvivorSkillsTable extends Sprite implements IUISkillsTable
   {
      
      private var _survivor:Survivor;
      
      private var _loadout:SurvivorLoadout;
      
      private var _rows:Vector.<UISkillsTableRow>;
      
      private var _rowsById:Dictionary;
      
      private var _rowColor:uint = 1447446;
      
      private var _rowHeight:int = 20;
      
      private var _width:int;
      
      private var _height:int;
      
      public function UISurvivorSkillsTable(param1:int)
      {
         super();
         this._width = param1;
         this._rows = new Vector.<UISkillsTableRow>();
         mouseEnabled = false;
      }
      
      public function dispose() : void
      {
         var _loc1_:UISkillsTableRow = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._survivor = null;
         this._loadout = null;
         for each(_loc1_ in this._rows)
         {
            _loc1_.dispose();
         }
         this._rows = null;
         this._rowsById = null;
      }
      
      public function setSurvivor(param1:Survivor, param2:SurvivorLoadout) : void
      {
         this._survivor = param1;
         this._loadout = param2;
         this.createTable();
         this.updateAttributes();
         this.updateTooltips();
      }
      
      private function createTable() : void
      {
         var _loc2_:UISkillsTableRow = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:UISkillsTableRow = null;
         var _loc1_:Language = Language.getInstance();
         for each(_loc2_ in this._rows)
         {
            if(_loc2_.parent != null)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
         }
         this._rows.length = 0;
         this._rowsById = new Dictionary(true);
         _loc3_ = 0;
         _loc4_ = SurvivorClass.getClassSkills(this._survivor.classId);
         _loc4_.sort();
         _loc4_.unshift(Attributes.HEALTH,Attributes.MOVEMENT_SPEED);
         _loc5_ = 0;
         _loc6_ = int(_loc4_.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc4_[_loc5_];
            _loc8_ = _loc1_.getString("att." + _loc7_).toUpperCase();
            _loc9_ = new UISkillsTableRow(this._width,this._rowHeight,_loc8_,this._rowColor,_loc5_ % 2 == 0 ? 1 : 0);
            _loc9_.attribute = _loc7_;
            _loc9_.y = _loc3_;
            addChild(_loc9_);
            this._rows.push(_loc9_);
            this._rowsById[_loc7_] = _loc9_;
            _loc3_ += this._rowHeight + 1;
            _loc5_++;
         }
         this._height = _loc3_;
      }
      
      private function updateTooltips() : void
      {
         var _loc2_:UISkillsTableRow = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc1_:Language = Language.getInstance();
         for each(_loc2_ in this._rows)
         {
            _loc3_ = _loc2_.attribute;
            _loc4_ = [_loc1_.getString("att_desc." + _loc3_)];
            _loc5_ = this._survivor.getAttribute(_loc3_,false,AttributeOptions.INCLUDE_NONE);
            _loc6_ = this._survivor.getAttribute(_loc3_,false,AttributeOptions.INCLUDE_MORALE);
            _loc7_ = this._survivor.getAttribute(_loc3_,false,AttributeOptions.INCLUDE_INJURIES);
            _loc8_ = Math.floor((_loc6_ - _loc5_) / _loc5_ * 100);
            if(_loc8_ != 0)
            {
               _loc4_.push("<font color=\'" + Color.colorToHex(_loc8_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc1_.getString("tooltip.morale_mod",(_loc8_ < 0 ? "" : "+") + _loc8_) + "</font>");
            }
            _loc9_ = Math.floor((_loc7_ - _loc5_) / _loc5_ * 100);
            if(_loc9_ != 0)
            {
               _loc4_.push("<font color=\'" + Color.colorToHex(_loc9_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc1_.getString("tooltip.injury_mod",(_loc9_ < 0 ? "" : "+") + _loc9_) + "</font>");
            }
            if(this._loadout.isAttributeAffectedByGear(ItemAttributes.GROUP_SURVIVOR,_loc3_))
            {
               _loc4_.push((_loc4_.length > 0 ? "<br/>" : "") + this._loadout.getAffectedAttributeDescription(ItemAttributes.GROUP_SURVIVOR,_loc3_));
            }
            TooltipManager.getInstance().add(_loc2_,_loc4_.join("<br/>"),new Point(_loc2_.width,NaN),TooltipDirection.DIRECTION_LEFT);
         }
      }
      
      private function updateAttributes() : void
      {
         var _loc2_:String = null;
         var _loc3_:UISkillsTableRow = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc1_:Array = Attributes.getAttributes();
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = this._rowsById[_loc2_];
            if(_loc3_ != null)
            {
               _loc4_ = this._survivor.getAttribute(_loc2_,this._loadout);
               _loc5_ = this._survivor.getAttribute(_loc2_,this._loadout,AttributeOptions.INCLUDE_NONE);
               _loc6_ = this._survivor.getAttribute(_loc2_,false,AttributeOptions.INCLUDE_NONE);
               _loc7_ = this._survivor.getAttribute(_loc2_,false,AttributeOptions.INCLUDE_MORALE | AttributeOptions.INCLUDE_INJURIES);
               _loc3_.value = int(_loc4_ * 10);
               _loc3_.alpha = _loc3_.value == 0 ? 0.4 : 1;
               _loc3_.valueColor = _loc6_ == _loc7_ ? 11908533 : (_loc7_ < _loc6_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
               _loc3_.labelColor = _loc6_ == _loc5_ ? 11908533 : (_loc5_ < _loc6_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
            }
         }
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
   }
}

