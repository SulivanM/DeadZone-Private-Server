package com.deadreckoned.threshold.display
{
   import flash.geom.ColorTransform;
   
   public class Color
   {
      
      public static const COMPONENT_ALPHA:uint = 0;
      
      public static const COMPONENT_RED:uint = 1;
      
      public static const COMPONENT_GREEN:uint = 2;
      
      public static const COMPONENT_BLUE:uint = 3;
      
      private var _color:uint = 0;
      
      private var _h:Number = 0;
      
      private var _s:Number = 0;
      
      private var _v:Number = 0;
      
      private var _a:uint = 255;
      
      private var _r:uint;
      
      private var _g:uint;
      
      private var _b:uint;
      
      private var _invalidRGB:Boolean;
      
      private var _invalidHSV:Boolean;
      
      public function Color(... rest)
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         super();
         if(rest.length == 0 || rest[0] == null)
         {
            return;
         }
         if(rest[0] is ColorTransform)
         {
            this.fromColorTransform(ColorTransform(rest[0]));
            return;
         }
         if(rest[0] is String)
         {
            this.fromHex(rest[0]);
            return;
         }
         if(!isNaN(rest[0]) && rest.length == 1)
         {
            this.ARGB = uint(rest[0]);
            this.updateHSVfromRGB();
            return;
         }
         if(rest.length > 1)
         {
            if(rest.length >= 4)
            {
               _loc2_ = this.clamp(uint(rest[0]));
               _loc3_ = this.clamp(uint(rest[1]));
               _loc4_ = this.clamp(uint(rest[2]));
               _loc5_ = this.clamp(uint(rest[3]));
            }
            else
            {
               _loc2_ = 255;
               _loc3_ = this.clamp(uint(rest[0]));
               _loc4_ = this.clamp(uint(rest[1]));
               _loc5_ = this.clamp(uint(rest[2]));
            }
            this.ARGB = _loc2_ << 24 | _loc3_ << 16 | _loc4_ << 8 | _loc5_;
            this.updateHSVfromRGB();
            return;
         }
         throw new Error("Illegal arguments supplied: " + rest);
      }
      
      public static function add(param1:*, param2:*) : Color
      {
         var _loc3_:Vector.<uint> = toComponents(param1);
         var _loc4_:Vector.<uint> = toComponents(param2);
         return new Color(_loc3_[0] + _loc4_[0],_loc3_[1] + _loc4_[1],_loc3_[2] + _loc4_[2],_loc3_[3] + _loc4_[3]);
      }
      
      public static function colorToHex(param1:uint, param2:Boolean = true, param3:Boolean = false) : String
      {
         var _loc4_:String = param1.toString(16);
         while(_loc4_.length < 6)
         {
            _loc4_ = "0" + _loc4_;
         }
         if(param3)
         {
            while(_loc4_.length < 8)
            {
               _loc4_ = "F" + _loc4_;
            }
         }
         return (param2 ? "#" : "") + _loc4_;
      }
      
      public static function fromHSV(param1:Number, param2:Number, param3:Number) : Color
      {
         return new Color().fromHSV(param1,param2,param3);
      }
      
      public static function getAverageBrightness(param1:uint) : Number
      {
         var _loc2_:* = param1 >> 16 & 0xFF;
         var _loc3_:* = param1 >> 8 & 0xFF;
         var _loc4_:* = param1 & 0xFF;
         return (_loc2_ + _loc4_ + _loc3_) / 3 / 255;
      }
      
      public static function hexToColor(param1:String, param2:Boolean = false) : uint
      {
         param1 = param1.replace(/#|0x/ig,"");
         while(param1.length < 6)
         {
            param1 = "0" + param1;
         }
         if(param2)
         {
            while(param1.length < 8)
            {
               param1 = "F" + param1;
            }
         }
         return parseInt(param1,16);
      }
      
      public static function interpolate(param1:*, param2:*, param3:Number) : uint
      {
         if(param3 < 0)
         {
            param3 = 0;
         }
         else if(param3 > 1)
         {
            param3 = 1;
         }
         var _loc4_:Vector.<uint> = toComponents(param1);
         var _loc5_:Vector.<uint> = toComponents(param2);
         var _loc6_:int = _loc5_[0] - _loc4_[0];
         var _loc7_:int = _loc5_[1] - _loc4_[1];
         var _loc8_:int = _loc5_[2] - _loc4_[2];
         var _loc9_:int = _loc5_[3] - _loc4_[3];
         var _loc10_:uint = _loc4_[0] + _loc6_ * param3;
         var _loc11_:uint = _loc4_[1] + _loc7_ * param3;
         var _loc12_:uint = _loc4_[2] + _loc8_ * param3;
         var _loc13_:uint = _loc4_[3] + _loc9_ * param3;
         return _loc10_ << 24 | _loc11_ << 16 | _loc12_ << 8 | _loc13_;
      }
      
      public static function subtract(param1:*, param2:*) : Color
      {
         var _loc3_:Vector.<uint> = toComponents(param1);
         var _loc4_:Vector.<uint> = toComponents(param2);
         return new Color(_loc3_[0] - _loc4_[0],_loc3_[1] - _loc4_[1],_loc3_[2] - _loc4_[2],_loc3_[3] - _loc4_[3]);
      }
      
      public static function toComponents(param1:*) : Vector.<uint>
      {
         var _loc2_:uint = 0;
         var _loc4_:ColorTransform = null;
         if(param1 is Color)
         {
            _loc2_ = uint(Color(param1).ARGB);
         }
         else if(param1 is ColorTransform)
         {
            _loc4_ = ColorTransform(param1);
            _loc2_ = uint(_loc4_.color | uint(255 * _loc4_.alphaMultiplier) << 24);
         }
         else if(param1 is String)
         {
            _loc2_ = hexToColor(String(param1));
         }
         else
         {
            if(isNaN(param1))
            {
               throw new Error("Illegal argument supplied.");
            }
            _loc2_ = uint(param1);
         }
         var _loc3_:Vector.<uint> = new Vector.<uint>(4,true);
         _loc3_[COMPONENT_ALPHA] = _loc2_ >> 24 & 0xFF;
         _loc3_[COMPONENT_RED] = _loc2_ >> 16 & 0xFF;
         _loc3_[COMPONENT_GREEN] = _loc2_ >> 8 & 0xFF;
         _loc3_[COMPONENT_BLUE] = _loc2_ & 0xFF;
         return _loc3_;
      }
      
      public static function scale(param1:uint, param2:Number) : uint
      {
         var _loc3_:uint = (param1 >> 16 & 0xFF) * param2;
         var _loc4_:uint = (param1 >> 8 & 0xFF) * param2;
         var _loc5_:uint = (param1 & 0xFF) * param2;
         if(_loc3_ > 255)
         {
            _loc3_ = 255;
         }
         else if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         if(_loc4_ > 255)
         {
            _loc4_ = 255;
         }
         else if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         if(_loc5_ > 255)
         {
            _loc5_ = 255;
         }
         else if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         return _loc3_ << 16 | _loc4_ << 8 | _loc5_;
      }
      
      public function get a() : uint
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return this._a;
      }
      
      public function set a(param1:uint) : void
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 255)
         {
            param1 = 255;
         }
         this._a = param1;
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidHSV = true;
      }
      
      public function get r() : uint
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return this._r;
      }
      
      public function set r(param1:uint) : void
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 255)
         {
            param1 = 255;
         }
         this._r = param1;
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidHSV = true;
      }
      
      public function get g() : uint
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return this._g;
      }
      
      public function set g(param1:uint) : void
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 255)
         {
            param1 = 255;
         }
         this._g = param1;
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidHSV = true;
      }
      
      public function get b() : uint
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return this._b;
      }
      
      public function set b(param1:uint) : void
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 255)
         {
            param1 = 255;
         }
         this._b = param1;
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidHSV = true;
      }
      
      public function get ARGB() : uint
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return this._color;
      }
      
      public function set ARGB(param1:uint) : void
      {
         this._color = param1;
         this._a = this._color >> 24 & 0xFF;
         this._r = this._color >> 16 & 0xFF;
         this._g = this._color >> 8 & 0xFF;
         this._b = this._color & 0xFF;
         this._invalidHSV = true;
      }
      
      public function get RGB() : uint
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return this._r << 16 | this._g << 8 | this._b;
      }
      
      public function set RGB(param1:uint) : void
      {
         this._color = param1;
         this._a = 255;
         this._r = this._color >> 16 & 0xFF;
         this._g = this._color >> 8 & 0xFF;
         this._b = this._color & 0xFF;
         this._invalidHSV = true;
      }
      
      public function get h() : Number
      {
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         return this._h;
      }
      
      public function set h(param1:Number) : void
      {
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 360)
         {
            param1 = 360;
         }
         this._h = param1;
         this._invalidRGB = true;
      }
      
      public function get s() : Number
      {
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         return this._s;
      }
      
      public function set s(param1:Number) : void
      {
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._s = param1;
         this._invalidRGB = true;
      }
      
      public function get v() : Number
      {
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         return this._v;
      }
      
      public function set v(param1:Number) : void
      {
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._v = param1;
         this._invalidRGB = true;
      }
      
      public function add(param1:*) : Color
      {
         var _loc2_:Vector.<uint> = toComponents(param1);
         this._a = uint(this.clamp(this._a + _loc2_[0]));
         this._r = uint(this.clamp(this._r + _loc2_[1]));
         this._g = uint(this.clamp(this._g + _loc2_[2]));
         this._b = uint(this.clamp(this._b + _loc2_[3]));
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidHSV = true;
         return this;
      }
      
      public function adjustBrightness(param1:Number) : Color
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._v = this.clamp(this._v * param1,0,1);
         this._s = this.clamp(this._s + 1 - param1,0,1);
         this._invalidRGB = true;
         return this;
      }
      
      public function clone() : Color
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return new Color(this._color);
      }
      
      public function equals(param1:Color) : Boolean
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return param1.ARGB == this._color;
      }
      
      public function fromARGB(param1:uint, param2:uint, param3:uint, param4:uint) : Color
      {
         this._a = param1;
         this._r = param2;
         this._g = param3;
         this._b = param4;
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this.updateHSVfromRGB();
         return this;
      }
      
      public function fromColorTransform(param1:ColorTransform) : Color
      {
         var _loc2_:Vector.<uint> = toComponents(param1);
         this._a = _loc2_[0];
         this._r = _loc2_[1];
         this._g = _loc2_[2];
         this._b = _loc2_[3];
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this.updateHSVfromRGB();
         return this;
      }
      
      public function fromRGB(param1:uint, param2:uint, param3:uint) : Color
      {
         this._a = 255;
         this._r = this.clamp(param1);
         this._g = this.clamp(param2);
         this._b = this.clamp(param3);
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this.updateHSVfromRGB();
         return this;
      }
      
      public function fromHSV(param1:Number, param2:Number, param3:Number) : Color
      {
         this._a = 255;
         this._h = this.clamp(param1,0,360);
         this._s = this.clamp(param2,0,1);
         this._v = this.clamp(param3,0,1);
         this.updateRGBfromHSV();
         return this;
      }
      
      public function fromHex(param1:String) : Color
      {
         this.ARGB = hexToColor(param1);
         this.updateHSVfromRGB();
         return this;
      }
      
      public function getAverageBrightness() : Number
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         return (this._r + this._b + this._g) / 3 / 255;
      }
      
      public function getComponent(param1:int) : uint
      {
         if(param1 < COMPONENT_ALPHA || param1 > COMPONENT_BLUE)
         {
            throw new RangeError("Component index is out of range.");
         }
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         switch(param1)
         {
            case COMPONENT_ALPHA:
               return this._a;
            case COMPONENT_RED:
               return this._r;
            case COMPONENT_GREEN:
               return this._g;
            case COMPONENT_BLUE:
               return this._b;
            default:
               return 0;
         }
      }
      
      public function multiply(param1:Number, param2:Boolean = false) : Color
      {
         this._a = param2 ? uint(this.clamp(this._a * param1)) : this._a;
         this._r = this.clamp(this._r * param1);
         this._g = this.clamp(this._g * param1);
         this._b = this.clamp(this._b * param1);
         this._invalidHSV = true;
         return this;
      }
      
      public function random(param1:Boolean = false) : Color
      {
         this._a = param1 ? uint(Math.round(Math.random() * 255)) : this._a;
         this._r = Math.round(Math.random() * 255);
         this._g = Math.round(Math.random() * 255);
         this._b = Math.round(Math.random() * 255);
         this._invalidHSV = true;
         return this;
      }
      
      public function random2(param1:int = 0, param2:int = 255, param3:int = 0, param4:int = 255, param5:int = 0, param6:int = 255) : Color
      {
         this._r = this.clamp(uint(param1 + Math.random() * (param2 - param1)));
         this._g = this.clamp(uint(param3 + Math.random() * (param4 - param3)));
         this._b = this.clamp(uint(param5 + Math.random() * (param6 - param5)));
         this._invalidHSV = true;
         return this;
      }
      
      public function randomComponent(param1:uint, param2:int = 0, param3:int = 255) : Color
      {
         if(param1 < COMPONENT_ALPHA || param1 > COMPONENT_BLUE)
         {
            throw new RangeError("Component index is out of range.");
         }
         var _loc4_:int = this.clamp(uint(param2 + Math.random() * (param3 - param2)));
         switch(param1)
         {
            case COMPONENT_ALPHA:
               this._a = _loc4_;
               break;
            case COMPONENT_RED:
               this._r = _loc4_;
               break;
            case COMPONENT_GREEN:
               this._g = _loc4_;
               break;
            case COMPONENT_BLUE:
               this._b = _loc4_;
         }
         this._invalidHSV = true;
         return this;
      }
      
      public function randomHSV(param1:Boolean = true, param2:Boolean = true, param3:Boolean = true) : Color
      {
         this._h = param1 ? Math.random() * 360 : this._h;
         this._s = param2 ? Math.random() : this._s;
         this._v = param3 ? Math.random() : this._v;
         this._invalidRGB = true;
         return this;
      }
      
      public function randomHue(param1:Number = 0, param2:Number = 360) : Color
      {
         this._h = this.clamp(int(param1 + Math.random() * (param2 - param1)),0,360);
         this._invalidRGB = true;
         return this;
      }
      
      public function subtract(param1:*) : Color
      {
         var _loc2_:Vector.<uint> = toComponents(param1);
         this._a = uint(this.clamp(this._a - _loc2_[0]));
         this._r = uint(this.clamp(this._r - _loc2_[1]));
         this._g = uint(this.clamp(this._g - _loc2_[2]));
         this._b = uint(this.clamp(this._b - _loc2_[3]));
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidHSV = true;
         return this;
      }
      
      public function tint(param1:uint, param2:Number = 1) : Color
      {
         if(param2 < 0)
         {
            param2 = 0;
         }
         else if(param2 > 1)
         {
            param2 = 1;
         }
         this._r = this._r * (1 - param2) + (param1 >> 16 & 0xFF) * param2;
         this._g = this._g * (1 - param2) + (param1 >> 8 & 0xFF) * param2;
         this._b = this._b * (1 - param2) + (param1 & 0xFF) * param2;
         this._invalidHSV = true;
         return this;
      }
      
      public function toColorTransform() : ColorTransform
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.color = this.r << 16 | this.g << 8 | this.b;
         _loc1_.alphaMultiplier = this._a / 255;
         return _loc1_;
      }
      
      public function toHex(param1:Boolean = true) : String
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         var _loc2_:String = this._r.toString(16);
         var _loc3_:String = this._g.toString(16);
         var _loc4_:String = this._b.toString(16);
         if(_loc2_.length < 2)
         {
            _loc2_ = "0" + _loc2_;
         }
         if(_loc3_.length < 2)
         {
            _loc3_ = "0" + _loc3_;
         }
         if(_loc4_.length < 2)
         {
            _loc4_ = "0" + _loc4_;
         }
         return (param1 ? "#" : "") + _loc2_ + _loc3_ + _loc4_;
      }
      
      public function toHex32(param1:Boolean = true) : String
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         var _loc2_:String = this._a.toString(16);
         if(_loc2_.length < 2)
         {
            _loc2_ = "0" + _loc2_;
         }
         return (param1 ? "#" : "") + _loc2_ + this.toHex(false);
      }
      
      public function toString() : String
      {
         if(this._invalidRGB)
         {
            this.updateRGBfromHSV();
         }
         if(this._invalidHSV)
         {
            this.updateHSVfromRGB();
         }
         return "(Color " + this.toHex32() + ", a=" + this._a + ", r=" + this._r + ", g=" + this._g + ", b=" + this._b + ", h=" + this._h + ", s=" + this._s + ", v=" + this._v + ")";
      }
      
      private function clamp(param1:Number, param2:Number = 0, param3:Number = 255) : Number
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 > param3)
         {
            param1 = param3;
         }
         return param1;
      }
      
      private function updateRGBfromHSV() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:Number = this._h;
         var _loc7_:Number = this._s;
         var _loc8_:Number = this._v;
         if(_loc7_ == 0)
         {
            this._r = this._g = this._b = int(_loc8_ * 255);
            this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
            this._invalidRGB = false;
            return;
         }
         if(_loc8_ == 0)
         {
            this._r = this._g = this._b = 0;
            this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
            this._invalidRGB = false;
            return;
         }
         _loc6_ /= 60;
         _loc2_ = int(_loc6_);
         _loc1_ = _loc6_ - _loc2_;
         _loc3_ = 255 * _loc8_ * (1 - _loc7_);
         _loc4_ = 255 * _loc8_ * (1 - _loc7_ * _loc1_);
         _loc5_ = 255 * _loc8_ * (1 - _loc7_ * (1 - _loc1_));
         _loc8_ = uint(_loc8_ * 255);
         switch(_loc2_)
         {
            case 0:
               this._r = _loc8_;
               this._g = _loc5_;
               this._b = _loc3_;
               break;
            case 1:
               this._r = _loc4_;
               this._g = _loc8_;
               this._b = _loc3_;
               break;
            case 2:
               this._r = _loc3_;
               this._g = _loc8_;
               this._b = _loc5_;
               break;
            case 3:
               this._r = _loc3_;
               this._g = _loc4_;
               this._b = _loc8_;
               break;
            case 4:
               this._r = _loc5_;
               this._g = _loc3_;
               this._b = _loc8_;
               break;
            default:
               this._r = _loc8_;
               this._g = _loc3_;
               this._b = _loc4_;
         }
         this._color = this._a << 24 | this._r << 16 | this._g << 8 | this._b;
         this._invalidRGB = false;
      }
      
      private function updateHSVfromRGB() : void
      {
         var _loc1_:Number = this._r / 255;
         var _loc2_:Number = this._g / 255;
         var _loc3_:Number = this._b / 255;
         var _loc4_:Number = Math.min(_loc1_,_loc2_,_loc3_);
         var _loc5_:Number = Math.max(_loc1_,_loc2_,_loc3_);
         var _loc6_:Number = _loc5_ - _loc4_;
         this._v = _loc5_;
         if(_loc5_ != 0)
         {
            this._s = _loc6_ / _loc5_;
            if(_loc1_ == _loc5_)
            {
               this._h = (_loc2_ - _loc3_) / _loc6_;
            }
            else if(_loc2_ == _loc5_)
            {
               this._h = 2 + (_loc3_ - _loc1_) / _loc6_;
            }
            else
            {
               this._h = 4 + (_loc1_ - _loc2_) / _loc6_;
            }
            this._h *= 60;
            if(this._h < 0)
            {
               this._h += 360;
            }
            this._invalidHSV = false;
            return;
         }
         this._s = 0;
         this._h = 0;
      }
   }
}

