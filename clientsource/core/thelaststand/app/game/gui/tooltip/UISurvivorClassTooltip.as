package thelaststand.app.game.gui.tooltip
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Bitmap;
   import flash.text.AntiAliasType;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponType;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorClassTooltip extends UIComponent
   {
      
      private var _classId:String;
      
      private var txt_description:BodyTextField;
      
      private var txt_weponSpecTitle:BodyTextField;
      
      private var txt_weponSpecBody:BodyTextField;
      
      private var bmp_weaponSpec:Bitmap;
      
      public function UISurvivorClassTooltip()
      {
         super();
         this.txt_description = new BodyTextField({
            "color":16777215,
            "size":13,
            "leading":1,
            "multiline":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_description.width = 240;
         addChild(this.txt_description);
         this.txt_weponSpecTitle = new BodyTextField({
            "color":16777215,
            "size":13,
            "leading":1,
            "multiline":true,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_weponSpecTitle.width = 240;
         this.txt_weponSpecBody = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "leading":1,
            "multiline":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_weponSpecBody.width = 240;
         this.bmp_weaponSpec = new Bitmap(new BmpIconSpecialized());
      }
      
      public function get survivorClassId() : String
      {
         return this._classId;
      }
      
      public function set survivorClassId(param1:String) : void
      {
         this._classId = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_weaponSpec.bitmapData.dispose();
         this.txt_description.dispose();
         this.txt_weponSpecTitle.dispose();
         this.txt_weponSpecBody.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc5_:XML = null;
         var _loc6_:* = null;
         var _loc7_:SurvivorClass = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:uint = 0;
         var _loc13_:String = null;
         var _loc1_:Language = Language.getInstance();
         var _loc2_:String = "<b>" + _loc1_.getString("survivor_classes." + this._classId) + "</b><br/>" + _loc1_.getString("survivor_class_desc_short." + this._classId);
         var _loc3_:Array = [];
         var _loc4_:XMLList = _loc1_.xml.data.survivor_class_specials[this._classId];
         for each(_loc5_ in _loc4_)
         {
            _loc3_.push(_loc5_.toString());
         }
         if(_loc3_.length > 0)
         {
            _loc2_ += "<br/><br/><font color=\'" + Color.colorToHex(Effects.COLOR_GOOD) + "\'>" + _loc3_.join("<br/>") + "</font>";
         }
         this.txt_description.htmlText = _loc2_;
         if(this._classId != SurvivorClass.PLAYER)
         {
            _loc6_ = Math.floor(Number(Config.constant.WEAPON_SPEC - 1) * 100) + "%";
            _loc7_ = Network.getInstance().data.getSurvivorClass(this._classId);
            this.txt_weponSpecTitle.htmlText = _loc1_.getString("srv_assign_weapspec");
            _loc8_ = [];
            _loc9_ = 0;
            while(_loc9_ < _loc7_.weaponClasses.length)
            {
               _loc11_ = _loc7_.weaponClasses[_loc9_].toLowerCase();
               if(_loc11_ != WeaponClass.LAUNCHER)
               {
                  _loc8_.push(_loc1_.getString("weap_class." + _loc11_));
               }
               _loc9_++;
            }
            for each(_loc10_ in WeaponType.getNames())
            {
               _loc12_ = uint(WeaponType[_loc10_]);
               if((_loc7_.weaponTypes & _loc12_) != 0)
               {
                  _loc13_ = _loc10_.toLowerCase();
                  _loc8_.push(_loc1_.getString("weap_type." + _loc10_.toLowerCase()));
               }
            }
            this.txt_weponSpecBody.htmlText = _loc8_.join("<br/>");
            this.bmp_weaponSpec.x = 0;
            this.bmp_weaponSpec.y = int(this.txt_description.y + this.txt_description.height + 10);
            this.txt_weponSpecTitle.x = int(this.bmp_weaponSpec.x + this.bmp_weaponSpec.width + 4);
            this.txt_weponSpecTitle.y = int(this.bmp_weaponSpec.y + (this.bmp_weaponSpec.height - this.txt_weponSpecTitle.height) * 0.5 + 1);
            this.txt_weponSpecBody.x = int(this.txt_weponSpecTitle.x);
            this.txt_weponSpecBody.y = int(this.txt_weponSpecTitle.y + this.txt_weponSpecTitle.height);
            addChild(this.bmp_weaponSpec);
            addChild(this.txt_weponSpecTitle);
            addChild(this.txt_weponSpecBody);
         }
         else
         {
            if(this.txt_weponSpecTitle.parent != null)
            {
               this.txt_weponSpecTitle.parent.removeChild(this.txt_weponSpecTitle);
            }
            if(this.txt_weponSpecBody.parent != null)
            {
               this.txt_weponSpecBody.parent.removeChild(this.txt_weponSpecBody);
            }
         }
      }
   }
}

