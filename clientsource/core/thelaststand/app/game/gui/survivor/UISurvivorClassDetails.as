package thelaststand.app.game.gui.survivor
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorClassDetails extends Sprite
   {
      
      private var _width:int = 414;
      
      private var _height:int = 360;
      
      private var _padding:int = 4;
      
      private var _descAreaWidth:int = 254;
      
      private var _descAreaPadding:int = 14;
      
      private var _class:SurvivorClass;
      
      private var _level:int;
      
      private var _gender:String;
      
      private var _lang:Language;
      
      private var mc_titleBar:Shape;
      
      private var bmp_classIcon:Bitmap;
      
      private var txt_title:TitleTextField;
      
      private var txt_desc:BodyTextField;
      
      private var ui_portrait:UIImage;
      
      private var ui_weapons:UIWeaponSpecializations;
      
      private var ui_attributes:UISurvivorClassSkills;
      
      private var ui_details:UISurvivorSkillDetails;
      
      private var txt_special:BodyTextField;
      
      public function UISurvivorClassDetails()
      {
         super();
         this._lang = Language.getInstance();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height,0,0);
         this.mc_titleBar = new Shape();
         this.mc_titleBar.graphics.beginFill(3881777);
         this.mc_titleBar.graphics.drawRect(0,0,int(this._width - this._padding * 2),36);
         this.mc_titleBar.graphics.endFill();
         this.mc_titleBar.x = this.mc_titleBar.y = this._padding;
         addChild(this.mc_titleBar);
         this.ui_portrait = new UIImage(this._width - this._descAreaWidth - this._descAreaPadding - 1,this._height - 2,0,0,true);
         this.ui_portrait.x = this._width - this.ui_portrait.width - 1;
         this.ui_portrait.y = 1;
         addChild(this.ui_portrait);
         this.bmp_classIcon = new Bitmap();
         addChild(this.bmp_classIcon);
         this.txt_title = new TitleTextField({
            "text":" ",
            "color":16777215,
            "size":24,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_title);
         this.txt_desc = new BodyTextField({
            "color":12500670,
            "size":13,
            "multiline":true
         });
         this.txt_desc.width = this._descAreaWidth;
         this.txt_desc.x = this._descAreaPadding;
         this.txt_desc.y = int(this.mc_titleBar.y + this.mc_titleBar.height + 8);
         addChild(this.txt_desc);
         this.ui_weapons = new UIWeaponSpecializations(this._descAreaWidth);
         this.ui_weapons.x = this._descAreaPadding;
         this.ui_weapons.y = int(this._height - 210);
         addChild(this.ui_weapons);
         this.ui_attributes = new UISurvivorClassSkills(this._descAreaWidth);
         this.ui_attributes.x = this.ui_weapons.x;
         this.ui_attributes.y = int(this.ui_weapons.y + this.ui_weapons.height + 14);
         addChild(this.ui_attributes);
         this.ui_details = new UISurvivorSkillDetails(this._descAreaWidth,int(this._height - this.mc_titleBar.y - this.mc_titleBar.height - this._descAreaPadding));
         this.ui_details.x = this._descAreaPadding;
         this.ui_details.y = int(this.mc_titleBar.y + this.mc_titleBar.height + this._descAreaPadding);
         this.txt_special = new BodyTextField({
            "color":Effects.COLOR_GOOD,
            "size":13,
            "multiline":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_special.x = int(this.ui_details.x + 2);
         this.txt_special.width = int(this.ui_attributes.width - 4);
         addChild(this.txt_special);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
         }
         this.txt_desc.dispose();
         this.txt_title.dispose();
         this.ui_portrait.dispose();
         this.ui_weapons.dispose();
         this.ui_details.dispose();
         this._class = null;
         this._lang = null;
      }
      
      public function showMoreDetails(param1:Boolean) : void
      {
         this.txt_desc.visible = this.ui_weapons.visible = this.ui_attributes.visible = !param1;
         if(param1)
         {
            this.ui_details.showSurvivorClassStats(this._class,this._level);
            this.txt_special.y = int(this.ui_details.y + this.ui_details.height + 6);
            addChild(this.ui_details);
         }
         else
         {
            if(this.ui_details.parent != null)
            {
               this.ui_details.parent.removeChild(this.ui_details);
            }
            this.txt_special.y = int(this.ui_attributes.y + this.ui_attributes.height + 6);
         }
      }
      
      public function setSurvivorClass(param1:SurvivorClass, param2:int, param3:String) : void
      {
         this._class = param1;
         this._level = param2;
         this._gender = param3;
         this.update();
         this.showMoreDetails(false);
      }
      
      private function update() : void
      {
         var _loc4_:XML = null;
         if(this._class == null)
         {
            return;
         }
         if(this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
         }
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.color = SurvivorClass.getClassColor(this._class.id);
         this.mc_titleBar.transform.colorTransform = _loc1_;
         this.ui_portrait.uri = "images/ui/class-" + this._class.id + "-" + this._gender + ".jpg";
         this.bmp_classIcon.bitmapData = SurvivorClass.getClassIcon(this._class.id);
         this.bmp_classIcon.x = int(this.mc_titleBar.x + 8);
         this.bmp_classIcon.y = int(this.mc_titleBar.y + (this.mc_titleBar.height - this.bmp_classIcon.height) * 0.5);
         this.txt_title.text = this._lang.getString("survivor_classes." + this._class.id).toUpperCase();
         this.txt_title.x = int(this.bmp_classIcon.x + this.bmp_classIcon.width + 2);
         this.txt_title.y = int(this.mc_titleBar.y + (this.mc_titleBar.height - this.txt_title.height) * 0.5);
         this.txt_desc.htmlText = this._lang.getString("survivor_class_desc." + this._class.id);
         this.ui_weapons.setSpecialties(this._class.weaponClasses,this._class.weaponTypes);
         this.ui_attributes.setSurvivorClass(this._class,this._level);
         var _loc2_:XMLList = this._lang.xml.data.survivor_class_specials[this._class.id];
         var _loc3_:Array = [];
         for each(_loc4_ in _loc2_)
         {
            _loc3_.push(_loc4_.toString());
         }
         this.txt_special.htmlText = _loc3_.join("<br/>");
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

