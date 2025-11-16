package thelaststand.app.game.gui.survivor
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.Point;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponType;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIWeaponSpecializations extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _images:Vector.<UIImage>;
      
      private var _weaponClasses:Vector.<String>;
      
      private var _weaponTypes:uint;
      
      private var bmp_icon:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var mc_images:Sprite;
      
      public function UIWeaponSpecializations(param1:int)
      {
         super();
         this._width = param1;
         this._height = 80;
         this._images = new Vector.<UIImage>();
         graphics.beginFill(1447446);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         this.bmp_icon = new Bitmap(new BmpIconSpecialized());
         this.bmp_icon.y = 4;
         addChild(this.bmp_icon);
         this.txt_title = new BodyTextField({
            "text":Language.getInstance().getString("srv_assign_weapspec").toUpperCase(),
            "bold":true,
            "color":7895160,
            "size":12
         });
         this.txt_title.y = 2;
         addChild(this.txt_title);
         var _loc2_:int = this.bmp_icon.width + 2 + this.txt_title.width;
         this.bmp_icon.x = int((this._width - _loc2_) * 0.5);
         this.txt_title.x = int(this.bmp_icon.x + this.bmp_icon.width + 2);
         this.mc_images = new Sprite();
         addChildAt(this.mc_images,0);
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIImage = null;
         TooltipManager.getInstance().removeAllFromParent(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
         }
         this.txt_title.dispose();
         for each(_loc1_ in this._images)
         {
            _loc1_.dispose();
         }
      }
      
      public function setSpecialties(param1:Vector.<String>, param2:uint) : void
      {
         this._weaponClasses = param1;
         this._weaponTypes = param2;
         invalidate();
      }
      
      override protected function draw() : void
      {
         var _loc1_:UIImage = null;
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:uint = 0;
         var _loc10_:String = null;
         for each(_loc1_ in this._images)
         {
            _loc1_.dispose();
         }
         this._images.length = 0;
         this.mc_images.scaleY = this.mc_images.scaleX = 1;
         var _loc2_:Language = Language.getInstance();
         _loc3_ = 0;
         _loc4_ = Math.floor(Number(Config.constant.WEAPON_SPEC - 1) * 100) + "%";
         _loc5_ = 0;
         while(_loc5_ < this._weaponClasses.length)
         {
            _loc8_ = this._weaponClasses[_loc5_].toLowerCase();
            if(_loc8_ != WeaponClass.LAUNCHER)
            {
               _loc1_ = new UIImage(58,58,13369344,0);
               _loc1_.uri = "images/ui/weapon-spec-" + _loc8_ + ".jpg";
               _loc1_.x = _loc3_;
               this._images.push(_loc1_);
               this.mc_images.addChild(_loc1_);
               TooltipManager.getInstance().add(_loc1_,_loc2_.getString("weap_spec_desc",_loc2_.getString("weap_class." + _loc8_),_loc4_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               _loc3_ += int(_loc1_.width + 16);
            }
            _loc5_++;
         }
         for each(_loc6_ in WeaponType.getNames())
         {
            _loc9_ = uint(WeaponType[_loc6_]);
            if((this._weaponTypes & _loc9_) != 0)
            {
               _loc10_ = _loc6_.toLowerCase();
               _loc1_ = new UIImage(58,58,13369344,0);
               _loc1_.uri = "images/ui/weapon-spec-" + _loc10_ + ".jpg";
               _loc1_.x = _loc3_;
               this._images.push(_loc1_);
               this.mc_images.addChild(_loc1_);
               TooltipManager.getInstance().add(_loc1_,_loc2_.getString("weap_spec_desc",_loc2_.getString("weap_type." + _loc10_),_loc4_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               _loc3_ += int(_loc1_.width + 16);
            }
         }
         _loc7_ = int(this._width - 16);
         if(this.mc_images.width > _loc7_)
         {
            this.mc_images.width = _loc7_;
            this.mc_images.scaleY = this.mc_images.scaleX;
         }
         this.mc_images.x = int((this._width - this.mc_images.width) * 0.5);
         this.mc_images.y = int(height - this.mc_images.height - 2);
      }
   }
}

