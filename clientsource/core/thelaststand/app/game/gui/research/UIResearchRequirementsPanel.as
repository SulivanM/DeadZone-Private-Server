package thelaststand.app.game.gui.research
{
   import com.deadreckoned.threshold.display.Color;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.AntiAliasType;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.gui.UIRequirementsChecklist;
   import thelaststand.app.game.gui.dialogues.UIMaterialRequirementIcon;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.XMLUtils;
   import thelaststand.common.lang.Language;
   
   public class UIResearchRequirementsPanel extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _category:String;
      
      private var _group:String;
      
      private var _level:int;
      
      private var _xmlGroup:XML;
      
      private var _xmlLevel:XML;
      
      private var _activeTask:ResearchTask;
      
      private var _componentList:Vector.<UIMaterialRequirementIcon> = new Vector.<UIMaterialRequirementIcon>();
      
      private var _showRequirements:Boolean = true;
      
      private var ui_titlebar:UITitleBar;
      
      private var bmp_separator:Bitmap;
      
      private var bmp_effectBg:Bitmap;
      
      private var bmp_activeBg:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_effect:BodyTextField;
      
      private var txt_materials:BodyTextField;
      
      private var txt_active:BodyTextField;
      
      private var txt_timeReamining:BodyTextField;
      
      private var mc_itemsRequirements:Sprite;
      
      private var ui_requirements:UIRequirementsChecklist;
      
      private var ui_activeImage:UIImage;
      
      public function UIResearchRequirementsPanel()
      {
         super();
         this.bmp_effectBg = new Bitmap(new BmpResearchEffectBg());
         addChild(this.bmp_effectBg);
         this.bmp_activeBg = new Bitmap(new BmpResearchActiveBg());
         addChild(this.bmp_activeBg);
         this.ui_titlebar = new UITitleBar();
         this.ui_titlebar.title = "";
         this.ui_titlebar.height = 28;
         addChild(this.ui_titlebar);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":14935011,
            "size":15,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_title);
         this.txt_desc = new BodyTextField({
            "text":" ",
            "color":11908533,
            "size":14,
            "multiline":true,
            "align":TextFormatAlign.CENTER
         });
         addChild(this.txt_desc);
         this.txt_effect = new BodyTextField({
            "text":" ",
            "color":7258192,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_effect);
         this.txt_materials = new BodyTextField({
            "text":" ",
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_materials.text = Language.getInstance().getString("construct_mat_needed");
         addChild(this.txt_materials);
         this.txt_active = new BodyTextField({
            "text":" ",
            "color":7261167,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_active);
         this.txt_timeReamining = new BodyTextField({
            "text":" ",
            "color":14935011,
            "size":24,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_timeReamining);
         this.bmp_separator = new Bitmap(new BmpDivider());
         addChild(this.bmp_separator);
         this.ui_requirements = new UIRequirementsChecklist();
         addChild(this.ui_requirements);
         this.ui_activeImage = new UIImage(10,10,2372664,1,true);
         addChild(this.ui_activeImage);
         this.mc_itemsRequirements = new Sprite();
         addChild(this.mc_itemsRequirements);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      public function get showRequirements() : Boolean
      {
         return this._showRequirements;
      }
      
      public function set showRequirements(param1:Boolean) : void
      {
         this._showRequirements = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIMaterialRequirementIcon = null;
         super.dispose();
         this._activeTask = null;
         this.txt_title.dispose();
         this.txt_desc.dispose();
         this.txt_effect.dispose();
         this.txt_materials.dispose();
         this.txt_active.dispose();
         this.txt_timeReamining.dispose();
         this.ui_requirements.dispose();
         this.ui_titlebar.dispose();
         this.ui_activeImage.dispose();
         for each(_loc1_ in this._componentList)
         {
            _loc1_.dispose();
         }
         this.bmp_effectBg.bitmapData.dispose();
         this.bmp_separator.bitmapData.dispose();
         this.bmp_activeBg.bitmapData.dispose();
      }
      
      public function setResearch(param1:String, param2:String, param3:int) : void
      {
         var currentTask:ResearchTask = null;
         var category:String = param1;
         var group:String = param2;
         var level:int = param3;
         removeEventListener(Event.ENTER_FRAME,this.updateTaskTimeRemaining);
         this._category = category;
         this._group = group;
         this._level = level;
         this._xmlGroup = ResearchSystem.getCategoryGroupXML(category,group);
         this._xmlLevel = this._xmlGroup.level.(@n == this._level.toString())[0];
         currentTask = Network.getInstance().playerData.researchState.currentTask;
         if(currentTask != null && currentTask.category == this._category && currentTask.group == this._group)
         {
            this._activeTask = currentTask;
            addEventListener(Event.ENTER_FRAME,this.updateTaskTimeRemaining,false,0,true);
         }
         else
         {
            this._activeTask = null;
         }
         invalidate();
      }
      
      private function updateTaskTimeRemaining(param1:Event = null) : void
      {
         if(this._activeTask == null)
         {
            removeEventListener(Event.ENTER_FRAME,this.updateTaskTimeRemaining);
            return;
         }
         this.txt_timeReamining.text = DateTimeUtils.secondsToString(this._activeTask.timeReamining,true,true);
         this.txt_timeReamining.x = int((this._width - this.txt_timeReamining.width) * 0.5);
         this.txt_timeReamining.y = int(this.txt_active.y + this.txt_active.height - 4);
      }
      
      override protected function draw() : void
      {
         var _loc1_:XML = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:ColorMatrix = null;
         var _loc7_:ResearchTask = null;
         var _loc8_:Number = NaN;
         if(this._category == null || this._group == null)
         {
            return;
         }
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.createItemRequirementSlots();
         _loc1_ = ResearchSystem.getCategoryXML(this._category);
         var _loc2_:int = ResearchSystem.getMaxLevel(this._category,this._group);
         var _loc3_:int = Network.getInstance().playerData.researchState.getLevel(this._category,this._group);
         _loc4_ = 3;
         this.ui_titlebar.x = _loc4_;
         this.ui_titlebar.y = _loc4_;
         this.ui_titlebar.width = int(this._width - _loc4_ * 2);
         this.ui_titlebar.color = Color.hexToColor(_loc1_.@color.toString());
         this.txt_title.maxWidth = int(this.ui_titlebar.width - 10);
         this.txt_title.text = ResearchSystem.getCategoryGroupName(this._category,this._group,this._level).toUpperCase();
         this.txt_title.x = int(this.ui_titlebar.x + (this.ui_titlebar.width - this.txt_title.width) / 2);
         this.txt_title.y = int(this.ui_titlebar.y + (this.ui_titlebar.height - this.txt_title.height) / 2);
         this.txt_desc.text = ResearchSystem.getCategoryGroupDescription(this._category,this._group);
         this.txt_desc.x = 8;
         this.txt_desc.y = int(this.ui_titlebar.y + this.ui_titlebar.height + 4);
         this.txt_desc.width = int(this._width - this.txt_desc.x * 2);
         this.bmp_effectBg.width = int(this._width - 10);
         this.bmp_effectBg.x = int((this._width - this.bmp_effectBg.width) * 0.5);
         this.bmp_effectBg.y = 80;
         this.txt_effect.text = ResearchSystem.getCategoryGroupEffectDescription(this._category,this._group,this._level);
         this.txt_effect.x = int((this._width - this.txt_effect.width) * 0.5);
         this.txt_effect.y = int(this.bmp_effectBg.y + (this.bmp_effectBg.height - this.txt_effect.height) * 0.5);
         this.bmp_separator.x = this.bmp_effectBg.x;
         this.bmp_separator.y = int(this.bmp_effectBg.y + this.bmp_effectBg.height + 4);
         this.bmp_separator.width = this.bmp_effectBg.width;
         this.bmp_activeBg.x = int((this._width - this.bmp_activeBg.width) * 0.5);
         this.bmp_activeBg.y = int(this._height - this.bmp_activeBg.height - this.bmp_activeBg.x);
         if(this._showRequirements)
         {
            _loc5_ = -4;
            _loc6_ = new ColorMatrix();
            _loc7_ = Network.getInstance().playerData.researchState.currentTask;
            if(_loc3_ >= _loc2_)
            {
               this.txt_materials.visible = false;
               this.ui_requirements.visible = false;
               this.mc_itemsRequirements.visible = false;
               _loc6_.colorize(8781701);
               this.bmp_activeBg.filters = [_loc6_.filter];
               this.bmp_activeBg.visible = true;
               this.setImagePanel("images/ui/research-complete.jpg");
               this.txt_active.textColor = 7258192;
               this.txt_active.text = Language.getInstance().getString("research_maxlevel");
               this.txt_active.visible = true;
               this.txt_timeReamining.textColor = 9236584;
               this.txt_timeReamining.text = Language.getInstance().getString("research_maxlevel_achieved");
               this.txt_timeReamining.visible = true;
            }
            else if(this._activeTask != null && !this._activeTask.isCompleted)
            {
               this.txt_materials.visible = false;
               this.ui_requirements.visible = false;
               this.mc_itemsRequirements.visible = false;
               _loc6_.colorize(8184575);
               this.bmp_activeBg.filters = [_loc6_.filter];
               this.bmp_activeBg.visible = true;
               this.setImagePanel("images/ui/research-active.jpg");
               this.txt_active.textColor = 7261167;
               this.txt_active.text = Language.getInstance().getString("research_active");
               this.txt_active.visible = true;
               this.txt_timeReamining.textColor = 14935011;
               this.txt_timeReamining.visible = true;
               this.updateTaskTimeRemaining();
            }
            else
            {
               this.txt_active.visible = false;
               this.txt_timeReamining.visible = false;
               this.bmp_activeBg.visible = false;
               this.setImagePanel(null);
               this.txt_materials.x = 8;
               this.txt_materials.y = int(this.bmp_separator.y + 4);
               this.txt_materials.visible = true;
               this.updateItemRequirements();
               this.mc_itemsRequirements.x = 10;
               this.mc_itemsRequirements.y = int(this.txt_materials.y + this.txt_materials.height + 4);
               this.mc_itemsRequirements.visible = true;
               this.updateRequirementsList();
               this.ui_requirements.redraw();
               this.ui_requirements.x = 4;
               this.ui_requirements.y = int(this._height - this.ui_requirements.height - this.ui_requirements.x);
               this.ui_requirements.width = int(this._width - this.ui_requirements.x * 2);
               this.ui_requirements.visible = true;
            }
            _loc8_ = this.txt_active.height + this.txt_timeReamining.height + _loc5_;
            this.txt_active.x = int((this._width - this.txt_active.width) * 0.5);
            this.txt_active.y = int(this.bmp_activeBg.y + (this.bmp_activeBg.height - _loc8_) * 0.5);
            this.txt_timeReamining.x = int((this._width - this.txt_timeReamining.width) * 0.5);
            this.txt_timeReamining.y = int(this.txt_active.y + this.txt_active.height - 4);
         }
         else
         {
            this.txt_materials.visible = false;
            this.ui_requirements.visible = false;
            this.mc_itemsRequirements.visible = false;
            this.bmp_activeBg.visible = false;
            this.txt_active.visible = false;
            this.txt_timeReamining.visible = false;
            this.setImagePanel(null);
         }
      }
      
      private function setImagePanel(param1:String) : void
      {
         this.ui_activeImage.uri = param1;
         if(param1 == null)
         {
            this.ui_activeImage.visible = false;
         }
         else
         {
            this.ui_activeImage.visible = true;
            this.ui_activeImage.maintainAspectRatio = true;
            this.ui_activeImage.x = int(this.bmp_activeBg.x);
            this.ui_activeImage.width = int(this._width - this.ui_activeImage.x * 2);
            this.ui_activeImage.height = int(this.ui_activeImage.width * (118 / 256));
            this.ui_activeImage.y = int(this.bmp_activeBg.y - this.ui_activeImage.height);
         }
      }
      
      private function createItemRequirementSlots() : void
      {
         var item:UIMaterialRequirementIcon = null;
         var len:int = 0;
         var i:int = 0;
         for each(item in this._componentList)
         {
            item.dispose();
         }
         this._componentList.length = 0;
         len = int(this._xmlLevel.req.children().(localName() == "itm" || localName() == "res").length());
         i = 0;
         while(i < len)
         {
            item = new UIMaterialRequirementIcon();
            this.mc_itemsRequirements.addChild(item);
            this._componentList.push(item);
            i++;
         }
      }
      
      private function updateItemRequirements() : void
      {
         var tx:int = 0;
         var ty:int = 0;
         var col:int = 0;
         var numCols:int = 0;
         var reqList:XMLList = null;
         var len:int = 0;
         var i:int = 0;
         var node:XML = null;
         var item:UIMaterialRequirementIcon = null;
         tx = 0;
         ty = 0;
         col = 0;
         numCols = 2;
         reqList = this._xmlLevel.req.children().(localName() == "itm" || localName() == "res");
         len = int(reqList.length());
         i = 0;
         while(i < len)
         {
            node = reqList[i];
            item = this._componentList[i];
            item.x = tx;
            item.y = ty;
            if(i < len)
            {
               item.visible = true;
               item.setMaterial(node.@id.toString(),int(node.toString()));
               if(++col >= numCols || i == len - 1)
               {
                  tx = 0;
                  ty += int(item.height + 4);
                  col = 0;
               }
               else
               {
                  tx += 134;
               }
            }
            else
            {
               item.visible = false;
               item.setMaterial(null,0);
            }
            i++;
         }
      }
      
      private function updateRequirementsList() : void
      {
         var reqList:XMLList = null;
         reqList = this._xmlLevel.req.children().(localName() != "itm" && localName() != "res");
         reqList = XMLUtils.sortXMLList(reqList,function(param1:XML, param2:XML):int
         {
            return int(param1.@lvl) - int(param2.@lvl);
         });
         this.ui_requirements.list = reqList;
      }
   }
}

