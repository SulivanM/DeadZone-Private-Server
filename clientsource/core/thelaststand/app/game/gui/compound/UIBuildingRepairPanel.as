package thelaststand.app.game.gui.compound
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import flash.utils.Dictionary;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.gui.dialogues.UIMaterialRequirementIcon;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.DictionaryUtils;
   import thelaststand.common.lang.Language;
   
   public class UIBuildingRepairPanel extends UIBuildingJobPanel
   {
      
      private var _building:Building;
      
      private var _time:Object;
      
      private var _message:String;
      
      private var _requirements:Vector.<UIMaterialRequirementIcon>;
      
      private var mc_costContainer:Sprite;
      
      private var mc_costBackground:Shape;
      
      private var mc_time:IconTime;
      
      private var txt_time:BodyTextField;
      
      public function UIBuildingRepairPanel(param1:Building)
      {
         var _loc6_:String = null;
         var _loc7_:UIMaterialRequirementIcon = null;
         this.mc_costContainer = new Sprite();
         this._building = param1;
         this._requirements = new Vector.<UIMaterialRequirementIcon>();
         var _loc2_:int = 0;
         var _loc3_:Dictionary = new Dictionary(true);
         var _loc4_:Dictionary = new Dictionary(true);
         Building.getBuildingRepairResourceItemCost(param1.type,param1.level,_loc3_,_loc4_);
         var _loc5_:Dictionary = DictionaryUtils.merge(_loc3_,_loc4_);
         for(_loc6_ in _loc5_)
         {
            _loc7_ = new UIMaterialRequirementIcon();
            _loc7_.borderColor = 9211020;
            _loc7_.setMaterial(_loc6_,int(_loc5_[_loc6_]));
            _loc7_.y = _loc2_;
            this._requirements.push(_loc7_);
            this.mc_costContainer.addChild(_loc7_);
            _loc2_ += int(_loc7_.height + 4);
         }
         this.mc_costBackground = new Shape();
         this.mc_costBackground.graphics.beginFill(2960685);
         this.mc_costBackground.graphics.drawRect(0,0,this.mc_costContainer.width + 20,this.mc_costContainer.height + 20);
         this.mc_costBackground.graphics.endFill();
         this.mc_costBackground.filters = [new DropShadowFilter(0,0,0,1,6,6,1,1,true),new GlowFilter(6974058,1,1.5,1.5,10,1)];
         this.mc_costBackground.x = 12;
         this.mc_costBackground.y = 38;
         this.mc_costContainer.x = int(this.mc_costBackground.x + 10);
         this.mc_costContainer.y = int(this.mc_costBackground.y + 10);
         super(int(this.mc_costBackground.x + this.mc_costBackground.width + 6),int(this.mc_costBackground.y + this.mc_costBackground.height + 40));
         jobTitle = param1.productionResource != null ? Language.getInstance().getString("bld_control_restockcosts") : Language.getInstance().getString("bld_control_repaircosts");
         addChild(this.mc_costBackground);
         addChild(this.mc_costContainer);
         this.mc_time = new IconTime();
         addChild(this.mc_time);
         this.txt_time = new BodyTextField({
            "text":" ",
            "bold":true,
            "color":16777215,
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_time.maxWidth = 88;
         this.txt_time.y = int(this.mc_costBackground.y + (this.mc_costBackground.height - this.txt_time.height) * 0.5);
         addChild(this.txt_time);
         this.update();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIMaterialRequirementIcon = null;
         super.dispose();
         this.txt_time.dispose();
         for each(_loc1_ in this._requirements)
         {
            _loc1_.dispose();
         }
         this._requirements = null;
         this._building = null;
      }
      
      private function update() : void
      {
         var _loc4_:int = 0;
         var _loc1_:String = DateTimeUtils.secondsToString(Building.getBuildingRepairTime(this._building.type,this._building.level),false);
         this.txt_time.text = _loc1_;
         var _loc2_:int = 4;
         var _loc3_:int = int(this.mc_time.width + this.txt_time.width + _loc2_);
         _loc4_ = int(height - 10 - (this.mc_costBackground.y + this.mc_costBackground.height));
         this.mc_time.x = int(this.mc_costBackground.x + (this.mc_costBackground.width - _loc3_) * 0.5);
         this.mc_time.y = int(this.mc_costBackground.y + this.mc_costBackground.height + (_loc4_ - this.mc_time.height) * 0.5);
         this.txt_time.x = int(this.mc_time.x + this.mc_time.width + _loc2_);
         this.txt_time.y = int(this.mc_costBackground.y + this.mc_costBackground.height + (_loc4_ - this.txt_time.height) * 0.5);
      }
   }
}

