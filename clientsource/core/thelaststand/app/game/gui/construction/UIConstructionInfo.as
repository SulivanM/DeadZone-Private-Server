package thelaststand.app.game.gui.construction
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.text.AntiAliasType;
   import flash.utils.Dictionary;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.CoverData;
   import thelaststand.app.game.gui.UIRequirementsChecklist;
   import thelaststand.app.game.gui.UIStatUpgrade;
   import thelaststand.app.game.gui.dialogues.UIMaterialRequirementIcon;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.XMLUtils;
   import thelaststand.common.lang.Language;
   
   public class UIConstructionInfo extends UIComponent
   {
      
      private const BMP_DIVIDER:BitmapData;
      
      private const NUM_MATERIAL_SLOTS:int = 6;
      
      private const INDENT:int = 20;
      
      private var _lang:Language;
      
      private var _xmlBuilding:XML;
      
      private var _xmlLevel:XML;
      
      private var _xmlLevelPrev:XML;
      
      private var _buildingType:String;
      
      private var _buildingLevel:int;
      
      private var _stats:Vector.<UIStatUpgrade>;
      
      private var _materials:Vector.<UIMaterialRequirementIcon>;
      
      private var _options:int;
      
      private var _width:int;
      
      private var _height:int;
      
      private var bmp_background:Bitmap;
      
      private var bmp_divider1:Bitmap;
      
      private var bmp_divider2:Bitmap;
      
      private var bmp_divider3:Bitmap;
      
      private var mc_iconTime:IconTime;
      
      private var mc_stats:Sprite;
      
      private var ui_requirements:UIRequirementsChecklist;
      
      private var txt_name:TitleTextField;
      
      private var txt_time:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_materials:BodyTextField;
      
      private var txt_levelReq:BodyTextField;
      
      private var bmp_levelReq:Bitmap;
      
      public function UIConstructionInfo(param1:uint = 255)
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:UIMaterialRequirementIcon = null;
         this.BMP_DIVIDER = new BmpDivider();
         this._lang = Language.getInstance();
         super();
         this._options = param1;
         this._materials = new Vector.<UIMaterialRequirementIcon>();
         this._stats = new Vector.<UIStatUpgrade>();
         if(this._options & ConstructionInfoOptions.BUILDING_NAME)
         {
            this._width = 294;
            this._height = 385;
            this.bmp_background = new Bitmap(new BmpConstructionBackground());
            this.bmp_background.x = -11;
            this.bmp_background.y = -9;
            addChild(this.bmp_background);
            this.txt_name = new TitleTextField({
               "color":16777215,
               "size":22,
               "autoSize":"none",
               "align":"center"
            });
            this.txt_name.text = " ";
            this.txt_name.width = this._width;
            addChild(this.txt_name);
         }
         else
         {
            this._width = 294;
            this._height = 355;
            this.bmp_background = new Bitmap(new BmpUpgradeBlueprint());
            this.bmp_background.filters = [new DropShadowFilter(0,45,0,1,5,5,0.4,1)];
            addChild(this.bmp_background);
         }
         this.bmp_divider1 = new Bitmap(this.BMP_DIVIDER);
         addChild(this.bmp_divider1);
         this.bmp_divider2 = new Bitmap(this.BMP_DIVIDER);
         addChild(this.bmp_divider2);
         this.bmp_divider3 = new Bitmap(this.BMP_DIVIDER);
         addChild(this.bmp_divider3);
         this.txt_desc = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":12,
            "multiline":true
         });
         this.txt_desc.width = int(this._width - this.INDENT * 2 + 12);
         this.txt_desc.height = 50;
         addChild(this.txt_desc);
         this.mc_iconTime = new IconTime();
         addChild(this.mc_iconTime);
         this.txt_time = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":18,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_time);
         this.txt_materials = new BodyTextField({
            "text":this._lang.getString("construct_mat_needed"),
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_materials);
         var _loc4_:int = 0;
         while(_loc4_ < this.NUM_MATERIAL_SLOTS)
         {
            _loc5_ = new UIMaterialRequirementIcon();
            addChild(_loc5_);
            this._materials.push(_loc5_);
            _loc4_++;
         }
         this.ui_requirements = new UIRequirementsChecklist();
         this.ui_requirements.width = int(this._width - this.INDENT * 2);
         addChild(this.ui_requirements);
         this.bmp_levelReq = new Bitmap(new BmpIconLevelYellow());
         this.txt_levelReq = new BodyTextField({
            "text":"0",
            "color":16764248,
            "size":18,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.mc_stats = new Sprite();
         addChild(this.mc_stats);
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
         var _loc1_:UIMaterialRequirementIcon = null;
         var _loc2_:UIStatUpgrade = null;
         super.dispose();
         for each(_loc1_ in this._materials)
         {
            _loc1_.dispose();
         }
         for each(_loc2_ in this._stats)
         {
            _loc2_.dispose();
         }
         this.ui_requirements.dispose();
         this.txt_desc.dispose();
         this.txt_time.dispose();
         this.txt_materials.dispose();
         this.txt_levelReq.dispose();
         this.bmp_levelReq.bitmapData.dispose();
         this.bmp_background.bitmapData.dispose();
         this.BMP_DIVIDER.dispose();
         if(this.txt_name != null)
         {
            this.txt_name.dispose();
         }
         this._xmlBuilding = null;
         this._xmlLevel = null;
         this._xmlLevelPrev = null;
         this._lang = null;
      }
      
      public function setBuilding(param1:String, param2:int) : void
      {
         var lvlNode:XML;
         var bldNode:XML = null;
         var type:String = param1;
         var level:int = param2;
         if(type == this._buildingType && level == this._buildingLevel)
         {
            return;
         }
         bldNode = Building.getBuildingXML(type);
         if(bldNode == null)
         {
            throw new Error("No building of type \'" + type + "\' exists.");
         }
         lvlNode = bldNode.lvl.(@n == level.toString())[0];
         if(lvlNode == null)
         {
            throw new Error("Level " + level + " of type \'" + type + "\' does not exist.");
         }
         this._xmlBuilding = bldNode;
         this._xmlLevel = lvlNode;
         this._xmlLevelPrev = bldNode.lvl.(@n == (level - 1).toString())[0];
         this._buildingType = type;
         this._buildingLevel = level;
         invalidate();
      }
      
      override protected function draw() : void
      {
         var timeAreaHeight:int;
         var time:int;
         var timeSpacing:int;
         var timeWidth:int;
         var lvlReqNode:XML;
         var mtlList:XMLList;
         var mtlCount:int;
         var otherReqList:XMLList;
         var i:int = 0;
         var tx:int = 0;
         var ty:int = 0;
         var statAreaHeight:int = 0;
         var lvlReq:int = 0;
         var colorMat:ColorMatrix = null;
         var costResources:Dictionary = null;
         var costItems:Dictionary = null;
         var col:int = 0;
         var icon:UIMaterialRequirementIcon = null;
         var node:XML = null;
         var mtlType:String = null;
         var mtlCost:int = 0;
         this.bmp_divider1.x = 0;
         this.bmp_divider2.x = int(this.bmp_divider1.x);
         this.bmp_divider3.x = int(this.bmp_divider1.x);
         tx = 0;
         ty = 10;
         if(this._options & ConstructionInfoOptions.BUILDING_NAME)
         {
            this.txt_name.text = this._lang.getString("blds." + this._buildingType).toUpperCase();
            this.txt_name.x = int((this._width - this.txt_name.width) * 0.5);
            this.txt_name.y = ty;
            ty += this.txt_name.height + 4;
            this.bmp_divider1.y = 78;
            this.bmp_divider2.y = 118;
            this.bmp_divider3.y = 336;
         }
         else
         {
            this.bmp_divider1.y = 48;
            this.bmp_divider2.y = 88;
            this.bmp_divider3.y = 306;
         }
         this.txt_desc.text = this._lang.getString("bld_desc." + this._buildingType);
         this.txt_desc.x = int((this._width - this.txt_desc.width) * 0.5);
         this.txt_desc.y = ty;
         timeAreaHeight = this.bmp_divider2.y - this.bmp_divider1.y;
         time = int(this._xmlLevel.time.toString());
         this.txt_time.text = time > 0 ? DateTimeUtils.secondsToString(time,true) : this._lang.getString("instant").toUpperCase();
         this.txt_time.y = int(this.bmp_divider1.y + (timeAreaHeight - this.txt_time.height) * 0.5);
         this.mc_iconTime.y = int(this.bmp_divider1.y + (timeAreaHeight - this.mc_iconTime.height) * 0.5 + 1);
         timeSpacing = 4;
         timeWidth = this.mc_iconTime.width + this.txt_time.width + timeSpacing;
         lvlReqNode = this._xmlLevel.req.lvl[0];
         if(lvlReqNode != null)
         {
            lvlReq = int(lvlReqNode.toString());
            if(Network.getInstance().playerData.getPlayerSurvivor().level < lvlReq)
            {
               colorMat = new ColorMatrix();
               colorMat.colorize(Effects.COLOR_WARNING);
               this.bmp_levelReq.filters = [colorMat.filter];
               this.txt_levelReq.textColor = Effects.COLOR_WARNING;
            }
            else
            {
               this.bmp_levelReq.filters = [];
               this.txt_levelReq.textColor = 16764248;
            }
            addChild(this.bmp_levelReq);
            this.txt_levelReq.text = NumberFormatter.format(lvlReq + 1,0);
            addChild(this.txt_levelReq);
            timeWidth += int(this.bmp_levelReq.width + this.txt_levelReq.width + timeSpacing + 20);
         }
         else
         {
            if(this.bmp_levelReq.parent != null)
            {
               this.bmp_levelReq.parent.removeChild(this.bmp_levelReq);
            }
            if(this.txt_levelReq.parent != null)
            {
               this.txt_levelReq.parent.removeChild(this.txt_levelReq);
            }
         }
         this.mc_iconTime.x = int((this.width - timeWidth) * 0.5);
         this.txt_time.x = int((this.width - timeWidth) * 0.5 + this.mc_iconTime.width + timeSpacing);
         if(lvlReqNode != null)
         {
            this.bmp_levelReq.x = int(this.txt_time.x + this.txt_time.width + 20);
            this.bmp_levelReq.y = int(this.mc_iconTime.y + (this.mc_iconTime.height - this.bmp_levelReq.height) * 0.5);
            this.txt_levelReq.x = int(this.bmp_levelReq.x + this.bmp_levelReq.width);
            this.txt_levelReq.y = int(this.txt_time.y);
         }
         ty = this.bmp_divider2.y + 8;
         mtlList = this._xmlBuilding.res.res + this._xmlLevel.req.itm;
         mtlCount = int(mtlList.length());
         if(mtlCount > 0)
         {
            costResources = new Dictionary(true);
            costItems = new Dictionary(true);
            Building.getBuildingUpgradeResourceItemCost(this._buildingType,this._buildingLevel,costResources,costItems);
            this.txt_materials.x = this.INDENT - 3;
            this.txt_materials.y = ty;
            this.txt_materials.visible = true;
            tx = this.INDENT;
            ty = this.txt_materials.y + this.txt_materials.height + 6;
            col = 0;
            i = 0;
            while(i < this.NUM_MATERIAL_SLOTS)
            {
               icon = this._materials[i];
               icon.visible = true;
               icon.borderColor = 11453906;
               icon.x = tx;
               icon.y = ty;
               if(i < mtlCount)
               {
                  node = mtlList[i];
                  mtlType = node.@id.toString();
                  mtlCost = node.localName() == "res" ? int(costResources[mtlType]) : int(costItems[mtlType]);
                  icon.setMaterial(mtlType,mtlCost);
               }
               else
               {
                  icon.setMaterial(null,0);
               }
               if(++col >= 2)
               {
                  tx = this.INDENT;
                  ty += icon.height + 4;
                  col = 0;
               }
               else
               {
                  tx += 128;
               }
               i++;
            }
            ty += 2;
         }
         else
         {
            this.txt_materials.visible = false;
            i = 0;
            while(i < this.NUM_MATERIAL_SLOTS)
            {
               this._materials[i].visible = false;
               i++;
            }
         }
         otherReqList = this._xmlLevel.req.children().(localName() != "itm" && localName() != "res");
         otherReqList = XMLUtils.sortXMLList(otherReqList,function(param1:XML, param2:XML):int
         {
            return int(param1.@lvl) - int(param2.@lvl);
         });
         this.ui_requirements.list = otherReqList;
         this.ui_requirements.x = this.INDENT;
         this.ui_requirements.y = ty;
         this.drawStats();
         statAreaHeight = int(this._height - this.bmp_divider3.y - 3);
         this.mc_stats.x = int((this._width - this.mc_stats.width) * 0.5);
         this.mc_stats.y = Math.round(this.bmp_divider3.y + (statAreaHeight - this.mc_stats.height) * 0.5);
      }
      
      private function drawStats() : void
      {
         var _loc1_:UIStatUpgrade = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:UIStatUpgrade = null;
         var _loc7_:int = 0;
         var _loc8_:UIStatUpgrade = null;
         var _loc9_:int = 0;
         var _loc10_:UIStatUpgrade = null;
         var _loc11_:int = 0;
         var _loc12_:UIStatUpgrade = null;
         for each(_loc1_ in this._stats)
         {
            _loc1_.dispose();
         }
         this._stats.length = 0;
         _loc2_ = 0;
         _loc3_ = 22;
         if(this._xmlLevel.hasOwnProperty("cover"))
         {
            _loc4_ = Building.getBuildingMaxLevel(this._buildingType);
            _loc5_ = int(this._xmlLevel.cover);
            _loc6_ = new UIStatUpgrade(CoverData.getCoverIconLarge(_loc5_));
            _loc6_.x = _loc2_;
            _loc6_.currentValue = 0;
            _loc2_ += _loc6_.width + _loc3_;
            this.mc_stats.addChild(_loc6_);
            this._stats.push(_loc6_);
            TooltipManager.getInstance().add(_loc6_,this._lang.getString("construct_cover_" + CoverData.getCoverLevel(_loc5_).toLowerCase(),_loc9_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         if(this._xmlBuilding.@assignable == "1")
         {
            _loc7_ = int(this._xmlBuilding.assign.length());
            _loc8_ = new UIStatUpgrade(new BmpIconAssignedHUD());
            _loc8_.currentValue = _loc7_;
            _loc8_.x = _loc2_;
            _loc2_ += _loc8_.width + _loc3_;
            this.mc_stats.addChild(_loc8_);
            this._stats.push(_loc8_);
            TooltipManager.getInstance().add(_loc8_,this._lang.getString("construct_assign",_loc7_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         if(this._xmlLevel.hasOwnProperty("comfort"))
         {
            _loc10_ = new UIStatUpgrade(new BmpIconComfort());
            if(this._buildingLevel == 0 || this._xmlLevelPrev == null || !this._xmlLevelPrev.hasOwnProperty("comfort"))
            {
               _loc9_ = int(this._xmlLevel.comfort);
               _loc10_.currentValue = _loc9_;
            }
            else
            {
               _loc9_ = int(this._xmlLevel.comfort);
               _loc10_.currentValue = int(this._xmlLevelPrev.comfort);
               _loc10_.nextValue = _loc9_;
            }
            _loc10_.x = _loc2_;
            _loc2_ += _loc10_.width + _loc3_;
            this.mc_stats.addChild(_loc10_);
            this._stats.push(_loc10_);
            TooltipManager.getInstance().add(_loc10_,this._lang.getString("construct_comfort",_loc9_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         if(this._xmlLevel.hasOwnProperty("security"))
         {
            _loc12_ = new UIStatUpgrade(new BmpIconSecurity());
            if(this._buildingLevel == 0 || this._xmlLevelPrev == null || !this._xmlLevelPrev.hasOwnProperty("security"))
            {
               _loc11_ = int(this._xmlLevel.security);
               _loc12_.currentValue = _loc11_;
            }
            else
            {
               _loc11_ = int(this._xmlLevel.security);
               _loc12_.currentValue = int(this._xmlLevelPrev.security);
               _loc12_.nextValue = _loc11_;
            }
            _loc12_.x = _loc2_;
            _loc2_ += _loc12_.width + _loc3_;
            this.mc_stats.addChild(_loc12_);
            this._stats.push(_loc12_);
            TooltipManager.getInstance().add(_loc12_,this._lang.getString("construct_security",_loc11_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
      }
   }
}

