package thelaststand.app.game.gui.loadout
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UIMissionInfo extends Sprite
   {
      
      private static const BMP_GRIME:BitmapData = new BmpDialogueBackground();
      
      private const SECTION_SHADOW:DropShadowFilter;
      
      private const DANGER_COLORS:Array;
      
      private var _missionData:MissionData;
      
      private var _lang:Language;
      
      private var _width:int = 177;
      
      private var _height:int = 375;
      
      private var _totalAmmo:int;
      
      private var bmp_danger:Bitmap;
      
      private var bmp_ammo:Bitmap;
      
      private var btn_addAmmo:PushButton;
      
      private var mc_iconTime:IconTime;
      
      private var mc_ammo_bg:Shape;
      
      private var mc_finds_bg:Shape;
      
      private var mc_success_bg:Shape;
      
      private var mc_time_bg:Shape;
      
      private var mc_grime:Shape;
      
      private var mc_pvpBlocker:Shape;
      
      private var mc_locationImage:UIImage;
      
      private var mc_danger:UITitleBar;
      
      private var txt_location_desc:BodyTextField;
      
      private var txt_success_title:BodyTextField;
      
      private var txt_success_value:BodyTextField;
      
      private var txt_time_title:BodyTextField;
      
      private var txt_time_value:BodyTextField;
      
      private var txt_ammo:BodyTextField;
      
      private var ui_automate:CheckBox;
      
      private var ui_finds:UIMissionPossibleFinds;
      
      private var bd_hazardStripes:BitmapData;
      
      private var hazardStripes:Shape;
      
      public function UIMissionInfo(param1:MissionData)
      {
         var _loc4_:Graphics = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         this.SECTION_SHADOW = new DropShadowFilter(0,0,0,1,10,10,1,1,true);
         this.DANGER_COLORS = [6579300,6579300,8808722,13268507,9770772,15926784];
         super();
         this._lang = Language.getInstance();
         this._missionData = param1;
         this._height = param1.opponent.isPlayer ? 228 : 375;
         graphics.beginFill(7631988);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(2827043);
         graphics.drawRect(1,1,this._width - 2,128);
         graphics.endFill();
         this.mc_grime = new Shape();
         this.mc_grime.alpha = 0.15;
         this.mc_grime.graphics.beginBitmapFill(BMP_GRIME);
         this.mc_grime.graphics.drawRect(1,1,this._width - 2,128);
         this.mc_grime.graphics.endFill();
         this.mc_grime.cacheAsBitmap = true;
         addChild(this.mc_grime);
         this.mc_locationImage = new UIImage(162,80,0,1,true,"images/locations/" + (this._missionData.opponent.isPlayer ? "compound" : this._missionData.type) + ".jpg");
         this.mc_locationImage.x = Math.round((this._width - this.mc_locationImage.width) * 0.5);
         this.mc_locationImage.y = 6;
         this.mc_locationImage.filters = [new GlowFilter(9013641,1,6,6,10,1,true)];
         addChild(this.mc_locationImage);
         if(this._missionData.highActivityIndex > -1)
         {
            this.bd_hazardStripes = new BmpRedHazardTile();
            this.hazardStripes = new Shape();
            _loc4_ = this.hazardStripes.graphics;
            _loc4_.beginFill(15597568,1);
            _loc4_.drawRect(0,0,this.mc_locationImage.width + 4,this.mc_locationImage.height + 4);
            _loc4_.drawRect(1,1,this.mc_locationImage.width + 2,this.mc_locationImage.height + 2);
            _loc4_.beginBitmapFill(this.bd_hazardStripes,null,true,true);
            _loc4_.drawRect(2,2,this.mc_locationImage.width,this.mc_locationImage.height);
            _loc4_.drawRect(5,5,this.mc_locationImage.width - 6,this.mc_locationImage.height - 6);
            _loc4_.endFill();
            this.hazardStripes.x = this.mc_locationImage.x - 2;
            this.hazardStripes.y = this.mc_locationImage.y - 2;
            addChild(this.hazardStripes);
         }
         var _loc2_:int = this._missionData.getDangerLevel();
         this.mc_danger = new UITitleBar({
            "padding":(_loc2_ >= MissionData.DANGER_DANGEROUS ? 30 : 6),
            "font":this._lang.getFontName("body"),
            "bold":true,
            "size":13,
            "color":16777215
         },this.DANGER_COLORS[_loc2_]);
         this.mc_danger.title = this._lang.getString("level",this._missionData.opponent.level + 1);
         this.mc_danger.width = this.mc_locationImage.width - 8;
         this.mc_danger.height = 20;
         this.mc_danger.x = int(this.mc_locationImage.x + 4);
         this.mc_danger.y = int(this.mc_locationImage.y + this.mc_locationImage.height - this.mc_danger.height - 4);
         this.mc_danger.filters = [Effects.STROKE];
         addChild(this.mc_danger);
         if(_loc2_ >= MissionData.DANGER_DANGEROUS)
         {
            this.bmp_danger = new Bitmap(new BmpIconDangerHigh());
            this.bmp_danger.x = Math.round(this.mc_danger.x + (30 - this.bmp_danger.width) * 0.5);
            this.bmp_danger.y = Math.round(this.mc_danger.y + (this.mc_danger.height - this.bmp_danger.height) * 0.5);
            addChild(this.bmp_danger);
         }
         this.txt_location_desc = new BodyTextField({
            "color":11513775,
            "size":12,
            "multiline":true,
            "align":"center"
         });
         this.txt_location_desc.maxWidth = this._width;
         this.txt_location_desc.width = this._width;
         this.txt_location_desc.text = this._missionData.opponent.isPlayer ? this._lang.getString("location_desc.compound",this._missionData.opponent.nickname) : this._lang.getString("location_desc." + this._missionData.type);
         this.txt_location_desc.y = int(this.mc_locationImage.y + this.mc_locationImage.height + (38 - this.txt_location_desc.height) * 0.5);
         addChild(this.txt_location_desc);
         this.mc_time_bg = new Shape();
         this.mc_time_bg.x = 1;
         this.mc_time_bg.graphics.beginFill(2434341);
         this.mc_time_bg.graphics.drawRect(0,0,this._width - 2,48);
         this.mc_time_bg.graphics.endFill();
         this.mc_time_bg.filters = [this.SECTION_SHADOW];
         addChild(this.mc_time_bg);
         var _loc3_:int = 130;
         if(!this._missionData.opponent.isPlayer)
         {
            graphics.beginFill(2827043);
            graphics.drawRect(1,228,this._width - 2,34);
            graphics.endFill();
            this.mc_success_bg = new Shape();
            this.mc_success_bg.x = 1;
            this.mc_success_bg.y = _loc3_;
            this.mc_success_bg.graphics.beginFill(2434341);
            this.mc_success_bg.graphics.drawRect(0,0,this._width - 2,48);
            this.mc_success_bg.graphics.endFill();
            this.mc_success_bg.filters = [this.SECTION_SHADOW];
            addChild(this.mc_success_bg);
            this.txt_success_title = new BodyTextField({
               "color":11513775,
               "size":12,
               "bold":true
            });
            this.txt_success_title.text = this._lang.getString("mission_success").toUpperCase();
            this.txt_success_title.x = int((this._width - this.txt_success_title.width) * 0.5);
            this.txt_success_title.y = int(this.mc_success_bg.y + 2);
            this.txt_success_title.filters = [Effects.TEXT_SHADOW];
            addChild(this.txt_success_title);
            this.txt_success_value = new BodyTextField({
               "color":Effects.COLOR_NEUTRAL,
               "size":16,
               "bold":true
            });
            this.txt_success_value.text = " ";
            this.txt_success_value.x = int((this._width - this.txt_success_value.width) * 0.5);
            this.txt_success_value.y = int(this.txt_success_title.y + this.txt_success_title.height - 1);
            this.txt_success_value.filters = [Effects.TEXT_SHADOW];
            addChild(this.txt_success_value);
            this.mc_time_bg.y = int(this.mc_success_bg.y + this.mc_success_bg.height + 1);
         }
         else
         {
            this.mc_time_bg.y = _loc3_;
         }
         this.txt_time_title = new BodyTextField({
            "color":11513775,
            "size":12,
            "bold":true
         });
         this.txt_time_title.text = this._lang.getString("mission_return").toUpperCase();
         this.txt_time_title.x = int((this._width - this.txt_time_title.width) * 0.5);
         this.txt_time_title.y = int(this.mc_time_bg.y + 2);
         this.txt_time_title.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_time_title);
         this.txt_time_value = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":18,
            "bold":true
         });
         this.txt_time_value.text = " ";
         this.txt_time_value.y = int(this.txt_time_title.y + this.txt_time_title.height) - 2;
         this.txt_time_value.maxWidth = this._width - 40;
         this.txt_time_value.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_time_value);
         this.mc_iconTime = new IconTime();
         this.mc_iconTime.y = int(this.txt_time_value.y + (this.txt_time_value.height - this.mc_iconTime.height) * 0.5) + 2;
         addChild(this.mc_iconTime);
         this.mc_ammo_bg = new Shape();
         this.mc_ammo_bg.x = 1;
         this.mc_ammo_bg.y = int(this.mc_time_bg.y + this.mc_time_bg.height + 1);
         this.mc_ammo_bg.graphics.beginFill(2434341);
         this.mc_ammo_bg.graphics.drawRect(0,0,this._width - 2,48);
         this.mc_ammo_bg.graphics.endFill();
         this.mc_ammo_bg.filters = [this.SECTION_SHADOW];
         addChild(this.mc_ammo_bg);
         this.bmp_ammo = new Bitmap(new BmpIconAmmunition(),"auto",true);
         this.bmp_ammo.width = 26;
         this.bmp_ammo.scaleY = this.bmp_ammo.scaleX;
         this.bmp_ammo.filters = [new GlowFilter(13997568,0.5,6,6,1,1)];
         this.bmp_ammo.y = int(this.mc_ammo_bg.y + (this.mc_ammo_bg.height - this.bmp_ammo.height) * 0.5);
         addChild(this.bmp_ammo);
         this.txt_ammo = new BodyTextField({
            "color":13997568,
            "size":18,
            "bold":true
         });
         this.txt_ammo.text = "0 / 0";
         this.txt_ammo.y = int(this.mc_ammo_bg.y + (this.mc_ammo_bg.height - this.txt_ammo.height) * 0.5);
         addChild(this.txt_ammo);
         this.btn_addAmmo = new PushButton("",new BmpIconAddResource(),-1,null,4226049);
         this.btn_addAmmo.showBorder = false;
         this.btn_addAmmo.clicked.add(this.onClickAddAmmo);
         this.btn_addAmmo.width = this.btn_addAmmo.height = 18;
         this.btn_addAmmo.y = int(this.mc_ammo_bg.y + (this.mc_ammo_bg.height - this.btn_addAmmo.height) * 0.5);
         addChild(this.btn_addAmmo);
         TooltipManager.getInstance().add(this.btn_addAmmo,this._lang.getString("loadout_add_ammo"),new Point(this.btn_addAmmo.width,NaN),TooltipDirection.DIRECTION_LEFT,0.1);
         if(!this._missionData.opponent.isPlayer)
         {
            this.mc_finds_bg = new Shape();
            this.mc_finds_bg.x = 1;
            this.mc_finds_bg.y = int(this.mc_ammo_bg.y + this.mc_ammo_bg.height + 1);
            this.mc_finds_bg.graphics.beginFill(2434341);
            this.mc_finds_bg.graphics.drawRect(0,0,this._width - 2,48);
            this.mc_finds_bg.graphics.endFill();
            this.mc_finds_bg.filters = [this.SECTION_SHADOW];
            addChild(this.mc_finds_bg);
            this.ui_finds = new UIMissionPossibleFinds();
            this.ui_finds.location = this._missionData.type;
            this.ui_finds.x = int(this.mc_finds_bg.x + (this.mc_finds_bg.width - this.ui_finds.width) * 0.5);
            this.ui_finds.y = int(this.mc_finds_bg.y + (this.mc_finds_bg.height - this.ui_finds.height) * 0.5);
            addChild(this.ui_finds);
            _loc5_ = int(this.mc_finds_bg.y + this.mc_finds_bg.height + 1);
            _loc6_ = 48;
            graphics.beginFill(2827043);
            graphics.drawRect(1,_loc5_,this._width - 2,_loc6_);
            graphics.endFill();
            this.mc_grime.graphics.beginBitmapFill(BMP_GRIME);
            this.mc_grime.graphics.drawRect(1,_loc5_,this._width - 2,_loc6_);
            this.mc_grime.graphics.endFill();
            if(this._missionData.canBeAutomated)
            {
               this.ui_automate = new CheckBox();
               this.ui_automate.changed.add(this.onAutomateChanged);
               this.ui_automate.label = this._lang.getString("mission_automate");
               this.ui_automate.selected = this._missionData.automated;
               this.ui_automate.x = int((this._width - this.ui_automate.width) * 0.5);
               this.ui_automate.y = int(_loc5_ + (_loc6_ - this.ui_automate.height) * 0.5);
               addChild(this.ui_automate);
               if(Tutorial.getInstance().active)
               {
                  this.ui_automate.enabled = false;
               }
               else
               {
                  TooltipManager.getInstance().add(this.ui_automate,this._lang.getString("tooltip.automated_mission"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               }
            }
         }
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         this.update();
      }
      
      public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         if(parent)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this._missionData = null;
         if(this.ui_automate != null)
         {
            this.ui_automate.dispose();
         }
         this.ui_automate = null;
         this.txt_time_title.dispose();
         this.txt_time_title = null;
         this.txt_time_value.dispose();
         this.txt_time_value = null;
         this.txt_location_desc.dispose();
         this.txt_location_desc = null;
         if(this.txt_success_title != null)
         {
            this.txt_success_title.dispose();
         }
         this.txt_success_title = null;
         if(this.txt_success_value != null)
         {
            this.txt_success_value.dispose();
         }
         this.txt_success_value = null;
         if(this.mc_danger != null)
         {
            this.mc_danger.dispose();
            this.mc_danger = null;
         }
         this.mc_locationImage.dispose();
         this.mc_locationImage = null;
         this.mc_ammo_bg.filters = [];
         this.bmp_ammo.bitmapData.dispose();
         this.bmp_ammo.bitmapData = null;
         this.btn_addAmmo.dispose();
         this.txt_ammo.dispose();
         if(this.ui_finds != null)
         {
            this.ui_finds.dispose();
            this.mc_finds_bg.filters = [];
         }
         if(this.bmp_danger != null)
         {
            this.bmp_danger.bitmapData.dispose();
            this.bmp_danger.bitmapData = null;
            this.bmp_danger.filters = [];
         }
         if(this.mc_success_bg != null)
         {
            this.mc_success_bg.filters = [];
            this.mc_success_bg = null;
         }
         if(this.mc_time_bg != null)
         {
            this.mc_time_bg.filters = [];
            this.mc_time_bg = null;
         }
         if(this.bd_hazardStripes != null)
         {
            this.bd_hazardStripes.dispose();
         }
         this.bd_hazardStripes = null;
      }
      
      public function update() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         if(!this._missionData.opponent.isPlayer)
         {
            _loc3_ = Number(this._missionData.getSuccessChance().chance);
            _loc4_ = 0;
            if(_loc3_ <= 0.1)
            {
               _loc4_ = 0;
            }
            else if(_loc3_ <= 0.3)
            {
               _loc4_ = 1;
            }
            else if(_loc3_ <= 0.5)
            {
               _loc4_ = 2;
            }
            else if(_loc3_ <= 0.75)
            {
               _loc4_ = 3;
            }
            else if(_loc3_ <= 0.8)
            {
               _loc4_ = 4;
            }
            else if(_loc3_ > 0.8)
            {
               _loc4_ = 5;
            }
            _loc5_ = 0;
            if(_loc4_ <= 1)
            {
               _loc5_ = Effects.COLOR_WARNING;
            }
            else if(_loc4_ == 2)
            {
               _loc5_ = 15442702;
            }
            else if(_loc4_ > 2)
            {
               _loc5_ = Effects.COLOR_GOOD;
            }
            this.txt_success_value.textColor = _loc5_;
            this.txt_success_value.text = this._lang.getString("mission_success_" + _loc4_).toUpperCase();
            this.txt_success_value.x = int((this._width - this.txt_success_value.width) * 0.5);
         }
         var _loc1_:int = this._missionData.isPvPPractice ? 0 : int(MissionData.calculateReturnTime(this._missionData.opponent.level,this._missionData.automated,this._missionData.opponent.isPlayer));
         this.txt_time_value.text = DateTimeUtils.timeDataToString(DateTimeUtils.secondsToTime(_loc1_),false,_loc1_ == 0);
         var _loc2_:int = this.mc_iconTime.width + this.txt_time_value.width + 4;
         this.mc_iconTime.x = int((width - _loc2_) * 0.5);
         this.txt_time_value.x = int((width - _loc2_) * 0.5 + this.mc_iconTime.width + 4);
         this.updateAmmo();
      }
      
      private function updateAmmo() : void
      {
         this._totalAmmo = Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION);
         var _loc1_:int = this._missionData.getTotalAmmoCost();
         this.txt_ammo.text = NumberFormatter.format(_loc1_,0) + " / " + NumberFormatter.format(this._totalAmmo,0);
         this.txt_ammo.textColor = _loc1_ > this._totalAmmo ? Effects.COLOR_WARNING : 13997568;
         var _loc2_:int = this.bmp_ammo.width + 2 + this.txt_ammo.width + 6 + this.btn_addAmmo.width;
         this.bmp_ammo.x = int(this.mc_ammo_bg.x + (this.mc_ammo_bg.width - _loc2_) * 0.5);
         this.txt_ammo.x = int(this.bmp_ammo.x + this.bmp_ammo.width + 2);
         this.btn_addAmmo.x = int(this.txt_ammo.x + this.txt_ammo.width + 6);
      }
      
      private function onAutomateChanged(param1:CheckBox) : void
      {
         this._missionData.automated = param1.selected;
         this.update();
      }
      
      private function onClickAddAmmo(param1:MouseEvent) : void
      {
         var _loc2_:StoreDialogue = new StoreDialogue("resource",GameResources.AMMUNITION);
         _loc2_.open();
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         var _loc3_:int = 0;
         if(param1 == GameResources.AMMUNITION)
         {
            _loc3_ = Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION);
            if(_loc3_ != this._totalAmmo)
            {
               this.updateAmmo();
            }
         }
      }
   }
}

