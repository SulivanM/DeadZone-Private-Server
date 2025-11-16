package com.quasimondo.geom
{
   import flash.display.BitmapData;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   
   public class ColorMatrix
   {
      
      public static const COLOR_DEFICIENCY_TYPES:Array = ["Protanopia","Protanomaly","Deuteranopia","Deuteranomaly","Tritanopia","Tritanomaly","Achromatopsia","Achromatomaly"];
      
      private static const LUMA_R:Number = 0.212671;
      
      private static const LUMA_G:Number = 0.71516;
      
      private static const LUMA_B:Number = 0.072169;
      
      private static const LUMA_R2:Number = 0.3086;
      
      private static const LUMA_G2:Number = 0.6094;
      
      private static const LUMA_B2:Number = 0.082;
      
      private static const ONETHIRD:Number = 1 / 3;
      
      private static const IDENTITY:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      private static const RAD:Number = Math.PI / 180;
      
      public var matrix:Array;
      
      private var preHue:ColorMatrix;
      
      private var postHue:ColorMatrix;
      
      private var hueInitialized:Boolean;
      
      public function ColorMatrix(param1:Object = null)
      {
         super();
         if(param1 is ColorMatrix)
         {
            this.matrix = param1.matrix.concat();
         }
         else if(param1 is Array)
         {
            this.matrix = param1.concat();
         }
         else
         {
            this.reset();
         }
      }
      
      public function reset() : void
      {
         this.matrix = IDENTITY.concat();
      }
      
      public function clone() : ColorMatrix
      {
         return new ColorMatrix(this.matrix);
      }
      
      public function invert() : void
      {
         this.concat([-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0]);
      }
      
      public function adjustSaturation(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         _loc2_ = 1 - param1;
         _loc3_ = _loc2_ * LUMA_R;
         _loc4_ = _loc2_ * LUMA_G;
         _loc5_ = _loc2_ * LUMA_B;
         this.concat([_loc3_ + param1,_loc4_,_loc5_,0,0,_loc3_,_loc4_ + param1,_loc5_,0,0,_loc3_,_loc4_,_loc5_ + param1,0,0,0,0,0,1,0]);
      }
      
      public function adjustContrast(param1:Number, param2:Number = NaN, param3:Number = NaN) : void
      {
         if(isNaN(param2))
         {
            param2 = param1;
         }
         if(isNaN(param3))
         {
            param3 = param1;
         }
         param1 += 1;
         param2 += 1;
         param3 += 1;
         this.concat([param1,0,0,0,128 * (1 - param1),0,param2,0,0,128 * (1 - param2),0,0,param3,0,128 * (1 - param3),0,0,0,1,0]);
      }
      
      public function adjustBrightness(param1:Number, param2:Number = NaN, param3:Number = NaN) : void
      {
         if(isNaN(param2))
         {
            param2 = param1;
         }
         if(isNaN(param3))
         {
            param3 = param1;
         }
         this.concat([1,0,0,0,param1,0,1,0,0,param2,0,0,1,0,param3,0,0,0,1,0]);
      }
      
      public function toGreyscale(param1:Number, param2:Number, param3:Number) : void
      {
         this.concat([param1,param2,param3,0,0,param1,param2,param3,0,0,param1,param2,param3,0,0,0,0,0,1,0]);
      }
      
      public function adjustHue(param1:Number) : void
      {
         param1 *= RAD;
         var _loc2_:Number = Math.cos(param1);
         var _loc3_:Number = Math.sin(param1);
         this.concat([LUMA_R + _loc2_ * (1 - LUMA_R) + _loc3_ * -LUMA_R,LUMA_G + _loc2_ * -LUMA_G + _loc3_ * -LUMA_G,LUMA_B + _loc2_ * -LUMA_B + _loc3_ * (1 - LUMA_B),0,0,LUMA_R + _loc2_ * -LUMA_R + _loc3_ * 0.143,LUMA_G + _loc2_ * (1 - LUMA_G) + _loc3_ * 0.14,LUMA_B + _loc2_ * -LUMA_B + _loc3_ * -0.283,0,0,LUMA_R + _loc2_ * -LUMA_R + _loc3_ * -(1 - LUMA_R),LUMA_G + _loc2_ * -LUMA_G + _loc3_ * LUMA_G,LUMA_B + _loc2_ * (1 - LUMA_B) + _loc3_ * LUMA_B,0,0,0,0,0,1,0]);
      }
      
      public function rotateHue(param1:Number) : void
      {
         this.initHue();
         this.concat(this.preHue.matrix);
         this.rotateBlue(param1);
         this.concat(this.postHue.matrix);
      }
      
      public function luminance2Alpha() : void
      {
         this.concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,LUMA_R,LUMA_G,LUMA_B,0,0]);
      }
      
      public function adjustAlphaContrast(param1:Number) : void
      {
         param1 += 1;
         this.concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,param1,128 * (1 - param1)]);
      }
      
      public function colorize(param1:int, param2:Number = 1) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         _loc3_ = (param1 >> 16 & 0xFF) / 255;
         _loc4_ = (param1 >> 8 & 0xFF) / 255;
         _loc5_ = (param1 & 0xFF) / 255;
         _loc6_ = 1 - param2;
         this.concat([_loc6_ + param2 * _loc3_ * LUMA_R,param2 * _loc3_ * LUMA_G,param2 * _loc3_ * LUMA_B,0,0,param2 * _loc4_ * LUMA_R,_loc6_ + param2 * _loc4_ * LUMA_G,param2 * _loc4_ * LUMA_B,0,0,param2 * _loc5_ * LUMA_R,param2 * _loc5_ * LUMA_G,_loc6_ + param2 * _loc5_ * LUMA_B,0,0,0,0,0,1,0]);
      }
      
      public function setChannels(param1:int = 1, param2:int = 2, param3:int = 4, param4:int = 8) : void
      {
         var _loc5_:Number = ((param1 & 1) == 1 ? 1 : 0) + ((param1 & 2) == 2 ? 1 : 0) + ((param1 & 4) == 4 ? 1 : 0) + ((param1 & 8) == 8 ? 1 : 0);
         if(_loc5_ > 0)
         {
            _loc5_ = 1 / _loc5_;
         }
         var _loc6_:Number = ((param2 & 1) == 1 ? 1 : 0) + ((param2 & 2) == 2 ? 1 : 0) + ((param2 & 4) == 4 ? 1 : 0) + ((param2 & 8) == 8 ? 1 : 0);
         if(_loc6_ > 0)
         {
            _loc6_ = 1 / _loc6_;
         }
         var _loc7_:Number = ((param3 & 1) == 1 ? 1 : 0) + ((param3 & 2) == 2 ? 1 : 0) + ((param3 & 4) == 4 ? 1 : 0) + ((param3 & 8) == 8 ? 1 : 0);
         if(_loc7_ > 0)
         {
            _loc7_ = 1 / _loc7_;
         }
         var _loc8_:Number = ((param4 & 1) == 1 ? 1 : 0) + ((param4 & 2) == 2 ? 1 : 0) + ((param4 & 4) == 4 ? 1 : 0) + ((param4 & 8) == 8 ? 1 : 0);
         if(_loc8_ > 0)
         {
            _loc8_ = 1 / _loc8_;
         }
         this.concat([(param1 & 1) == 1 ? _loc5_ : 0,(param1 & 2) == 2 ? _loc5_ : 0,(param1 & 4) == 4 ? _loc5_ : 0,(param1 & 8) == 8 ? _loc5_ : 0,0,(param2 & 1) == 1 ? _loc6_ : 0,(param2 & 2) == 2 ? _loc6_ : 0,(param2 & 4) == 4 ? _loc6_ : 0,(param2 & 8) == 8 ? _loc6_ : 0,0,(param3 & 1) == 1 ? _loc7_ : 0,(param3 & 2) == 2 ? _loc7_ : 0,(param3 & 4) == 4 ? _loc7_ : 0,(param3 & 8) == 8 ? _loc7_ : 0,0,(param4 & 1) == 1 ? _loc8_ : 0,(param4 & 2) == 2 ? _loc8_ : 0,(param4 & 4) == 4 ? _loc8_ : 0,(param4 & 8) == 8 ? _loc8_ : 0,0]);
      }
      
      public function blend(param1:ColorMatrix, param2:Number) : void
      {
         var _loc3_:Number = 1 - param2;
         var _loc4_:int = 0;
         while(_loc4_ < 20)
         {
            this.matrix[_loc4_] = _loc3_ * this.matrix[_loc4_] + param2 * param1.matrix[_loc4_];
            _loc4_++;
         }
      }
      
      public function extrapolate(param1:ColorMatrix, param2:Number) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < 20)
         {
            this.matrix[_loc3_] += (param1.matrix[_loc3_] - this.matrix[_loc3_]) * param2;
            _loc3_++;
         }
      }
      
      public function average(param1:Number = 0.3333333333333333, param2:Number = 0.3333333333333333, param3:Number = 0.3333333333333333) : void
      {
         this.concat([param1,param2,param3,0,0,param1,param2,param3,0,0,param1,param2,param3,0,0,0,0,0,1,0]);
      }
      
      public function threshold(param1:Number, param2:Number = 256) : void
      {
         this.concat([LUMA_R * param2,LUMA_G * param2,LUMA_B * param2,0,-(param2 - 1) * param1,LUMA_R * param2,LUMA_G * param2,LUMA_B * param2,0,-(param2 - 1) * param1,LUMA_R * param2,LUMA_G * param2,LUMA_B * param2,0,-(param2 - 1) * param1,0,0,0,1,0]);
      }
      
      public function threshold_rgb(param1:Number, param2:Number = 256) : void
      {
         this.concat([param2,0,0,0,-(param2 - 1) * param1,0,param2,0,0,-(param2 - 1) * param1,0,0,param2,0,-(param2 - 1) * param1,0,0,0,1,0]);
      }
      
      public function desaturate() : void
      {
         this.concat([LUMA_R,LUMA_G,LUMA_B,0,0,LUMA_R,LUMA_G,LUMA_B,0,0,LUMA_R,LUMA_G,LUMA_B,0,0,0,0,0,1,0]);
      }
      
      public function randomize(param1:Number = 1) : void
      {
         var _loc2_:Number = 1 - param1;
         var _loc3_:Number = _loc2_ + param1 * (Math.random() - Math.random());
         var _loc4_:Number = param1 * (Math.random() - Math.random());
         var _loc5_:Number = param1 * (Math.random() - Math.random());
         var _loc6_:Number = param1 * 255 * (Math.random() - Math.random());
         var _loc7_:Number = param1 * (Math.random() - Math.random());
         var _loc8_:Number = _loc2_ + param1 * (Math.random() - Math.random());
         var _loc9_:Number = param1 * (Math.random() - Math.random());
         var _loc10_:Number = param1 * 255 * (Math.random() - Math.random());
         var _loc11_:Number = param1 * (Math.random() - Math.random());
         var _loc12_:Number = param1 * (Math.random() - Math.random());
         var _loc13_:Number = _loc2_ + param1 * (Math.random() - Math.random());
         var _loc14_:Number = param1 * 255 * (Math.random() - Math.random());
         this.concat([_loc3_,_loc4_,_loc5_,0,_loc6_,_loc7_,_loc8_,_loc9_,0,_loc10_,_loc11_,_loc12_,_loc13_,0,_loc14_,0,0,0,1,0]);
      }
      
      public function setMultiplicators(param1:Number = 1, param2:Number = 1, param3:Number = 1, param4:Number = 1) : void
      {
         var _loc5_:Array = new Array(param1,0,0,0,0,0,param2,0,0,0,0,0,param3,0,0,0,0,0,param4,0);
         this.concat(_loc5_);
      }
      
      public function clearChannels(param1:Boolean = false, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : void
      {
         if(param1)
         {
            this.matrix[0] = this.matrix[1] = this.matrix[2] = this.matrix[3] = this.matrix[4] = 0;
         }
         if(param2)
         {
            this.matrix[5] = this.matrix[6] = this.matrix[7] = this.matrix[8] = this.matrix[9] = 0;
         }
         if(param3)
         {
            this.matrix[10] = this.matrix[11] = this.matrix[12] = this.matrix[13] = this.matrix[14] = 0;
         }
         if(param4)
         {
            this.matrix[15] = this.matrix[16] = this.matrix[17] = this.matrix[18] = this.matrix[19] = 0;
         }
      }
      
      public function thresholdAlpha(param1:Number, param2:Number = 256) : void
      {
         this.concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,param2,-param2 * param1]);
      }
      
      public function averageRGB2Alpha() : void
      {
         this.concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,ONETHIRD,ONETHIRD,ONETHIRD,0,0]);
      }
      
      public function invertAlpha() : void
      {
         this.concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,-1,255]);
      }
      
      public function rgb2Alpha(param1:Number, param2:Number, param3:Number) : void
      {
         this.concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,param1,param2,param3,0,0]);
      }
      
      public function setAlpha(param1:Number) : void
      {
         this.concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,param1,0]);
      }
      
      public function get filter() : ColorMatrixFilter
      {
         return new ColorMatrixFilter(this.matrix);
      }
      
      public function applyFilter(param1:BitmapData) : void
      {
         param1.applyFilter(param1,param1.rect,new Point(),this.filter);
      }
      
      public function concat(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < 4)
         {
            _loc4_ = 0;
            while(_loc4_ < 5)
            {
               _loc2_[int(_loc3_ + _loc4_)] = param1[_loc3_] * this.matrix[_loc4_] + param1[int(_loc3_ + 1)] * this.matrix[int(_loc4_ + 5)] + param1[int(_loc3_ + 2)] * this.matrix[int(_loc4_ + 10)] + param1[int(_loc3_ + 3)] * this.matrix[int(_loc4_ + 15)] + (_loc4_ == 4 ? param1[int(_loc3_ + 4)] : 0);
               _loc4_++;
            }
            _loc3_ += 5;
            _loc5_++;
         }
         this.matrix = _loc2_;
      }
      
      public function rotateRed(param1:Number) : void
      {
         this.rotateColor(param1,2,1);
      }
      
      public function rotateGreen(param1:Number) : void
      {
         this.rotateColor(param1,0,2);
      }
      
      public function rotateBlue(param1:Number) : void
      {
         this.rotateColor(param1,1,0);
      }
      
      public function normalize() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _loc2_ += this.matrix[_loc1_ * 5 + _loc3_] * this.matrix[_loc1_ * 5 + _loc3_];
               _loc3_++;
            }
            _loc2_ = 1 / Math.sqrt(_loc2_);
            if(_loc2_ != 1)
            {
               _loc3_ = 0;
               while(_loc3_ < 4)
               {
                  this.matrix[_loc1_ * 5 + _loc3_] *= _loc2_;
                  _loc3_++;
               }
            }
            _loc1_++;
         }
      }
      
      public function fitRange() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               if(this.matrix[_loc1_ * 5 + _loc4_] < 0)
               {
                  _loc2_ += this.matrix[_loc1_ * 5 + _loc4_];
               }
               else
               {
                  _loc3_ += this.matrix[_loc1_ * 5 + _loc4_];
               }
               _loc4_++;
            }
            _loc5_ = _loc3_ * 255 - _loc2_ * 255;
            _loc6_ = 255 / _loc5_;
            if(_loc6_ != 1)
            {
               _loc4_ = 0;
               while(_loc4_ < 4)
               {
                  this.matrix[_loc1_ * 5 + _loc4_] *= _loc6_;
                  _loc4_++;
               }
            }
            _loc2_ = 0;
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               if(this.matrix[_loc1_ * 5 + _loc4_] < 0)
               {
                  _loc2_ += this.matrix[_loc1_ * 5 + _loc4_];
               }
               else
               {
                  _loc3_ += this.matrix[_loc1_ * 5 + _loc4_];
               }
               _loc4_++;
            }
            _loc7_ = _loc2_ * 255;
            _loc8_ = _loc3_ * 255;
            this.matrix[_loc1_ * 5 + 4] = -(_loc7_ + (_loc8_ - _loc7_) * 0.5 - 127.5);
            _loc1_++;
         }
      }
      
      private function rotateColor(param1:Number, param2:int, param3:int) : void
      {
         param1 *= RAD;
         var _loc4_:Array = IDENTITY.concat();
         _loc4_[param2 + param2 * 5] = _loc4_[param3 + param3 * 5] = Math.cos(param1);
         _loc4_[param3 + param2 * 5] = Math.sin(param1);
         _loc4_[param2 + param3 * 5] = -Math.sin(param1);
         this.concat(_loc4_);
      }
      
      public function shearRed(param1:Number, param2:Number) : void
      {
         this.shearColor(0,1,param1,2,param2);
      }
      
      public function shearGreen(param1:Number, param2:Number) : void
      {
         this.shearColor(1,0,param1,2,param2);
      }
      
      public function shearBlue(param1:Number, param2:Number) : void
      {
         this.shearColor(2,0,param1,1,param2);
      }
      
      private function shearColor(param1:int, param2:int, param3:Number, param4:int, param5:Number) : void
      {
         var _loc6_:Array = IDENTITY.concat();
         _loc6_[param2 + param1 * 5] = param3;
         _loc6_[param4 + param1 * 5] = param5;
         this.concat(_loc6_);
      }
      
      public function applyColorDeficiency(param1:String) : void
      {
         switch(param1)
         {
            case "Protanopia":
               this.concat([0.567,0.433,0,0,0,0.558,0.442,0,0,0,0,0.242,0.758,0,0,0,0,0,1,0]);
               break;
            case "Protanomaly":
               this.concat([0.817,0.183,0,0,0,0.333,0.667,0,0,0,0,0.125,0.875,0,0,0,0,0,1,0]);
               break;
            case "Deuteranopia":
               this.concat([0.625,0.375,0,0,0,0.7,0.3,0,0,0,0,0.3,0.7,0,0,0,0,0,1,0]);
               break;
            case "Deuteranomaly":
               this.concat([0.8,0.2,0,0,0,0.258,0.742,0,0,0,0,0.142,0.858,0,0,0,0,0,1,0]);
               break;
            case "Tritanopia":
               this.concat([0.95,0.05,0,0,0,0,0.433,0.567,0,0,0,0.475,0.525,0,0,0,0,0,1,0]);
               break;
            case "Tritanomaly":
               this.concat([0.967,0.033,0,0,0,0,0.733,0.267,0,0,0,0.183,0.817,0,0,0,0,0,1,0]);
               break;
            case "Achromatopsia":
               this.concat([0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0,0,0,1,0]);
               break;
            case "Achromatomaly":
               this.concat([0.618,0.32,0.062,0,0,0.163,0.775,0.062,0,0,0.163,0.32,0.516,0,0,0,0,0,1,0]);
         }
      }
      
      public function RGB2YUV() : void
      {
         this.concat([0.299,0.587,0.114,0,0,-0.16874,-0.33126,0.5,0,128,0.5,-0.41869,-0.08131,0,128,0,0,0,1,0]);
      }
      
      public function YUV2RGB() : void
      {
         this.concat([1,-0.000007154783816076815,1.4019975662231445,0,-179.45477266423404,1,-0.3441331386566162,-0.7141380310058594,0,135.45870971679688,1,1.7720025777816772,0.00001542569043522235,0,-226.8183044444304,0,0,0,1,0]);
      }
      
      public function RGB2YIQ() : void
      {
         this.concat([0.299,0.587,0.114,0,0,0.595716,-0.274453,-0.321263,0,128,0.211456,-0.522591,-0.311135,0,128,0,0,0,1,0]);
      }
      
      public function autoDesaturate(param1:BitmapData, param2:Boolean = false, param3:Boolean = false, param4:Number = 0.01) : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc5_:Vector.<Vector.<Number>> = param1.histogram(param1.rect);
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         var _loc11_:Boolean = false;
         var _loc12_:Vector.<Number> = _loc5_[0];
         var _loc13_:Vector.<Number> = _loc5_[1];
         var _loc14_:Vector.<Number> = _loc5_[2];
         var _loc15_:int = 0;
         while(_loc15_ < 256)
         {
            _loc6_ += _loc12_[_loc15_] * _loc15_;
            _loc7_ += _loc13_[_loc15_] * _loc15_;
            _loc8_ += _loc14_[_loc15_] * _loc15_;
            _loc15_++;
         }
         var _loc16_:Number = _loc6_ + _loc7_ + _loc8_;
         if(_loc16_ == 0)
         {
            _loc16_ = 3;
            _loc6_ = _loc7_ = _loc8_ = 3;
         }
         _loc6_ /= _loc16_;
         _loc7_ /= _loc16_;
         _loc8_ /= _loc16_;
         var _loc17_:Number = 0;
         if(param2)
         {
            _loc18_ = param1.rect.width * param1.rect.height * param4;
            _loc19_ = 0;
            _loc20_ = 0;
            _loc21_ = 0;
            _loc15_ = 0;
            while(_loc15_ < 256)
            {
               _loc19_ += _loc12_[_loc15_];
               _loc20_ += _loc13_[_loc15_];
               _loc21_ += _loc14_[_loc15_];
               if(_loc19_ > _loc18_ || _loc20_ > _loc18_ || _loc21_ > _loc18_)
               {
                  _loc9_ = _loc15_;
                  break;
               }
               _loc15_++;
            }
            _loc19_ = 0;
            _loc20_ = 0;
            _loc21_ = 0;
            _loc15_ = 256;
            while(--_loc15_ > -1)
            {
               _loc19_ += _loc12_[_loc15_];
               _loc20_ += _loc13_[_loc15_];
               _loc21_ += _loc14_[_loc15_];
               if(_loc19_ > _loc18_ || _loc20_ > _loc18_ || _loc21_ > _loc18_)
               {
                  _loc10_ = _loc15_;
                  break;
               }
            }
            if(_loc10_ - _loc9_ < 255)
            {
               _loc22_ = 256 / (_loc10_ - _loc9_ + 1);
               _loc6_ *= _loc22_;
               _loc7_ *= _loc22_;
               _loc8_ *= _loc22_;
               _loc17_ = -_loc9_;
            }
         }
         _loc22_ = 1 / Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_ + _loc8_ * _loc8_);
         _loc6_ *= _loc22_;
         _loc7_ *= _loc22_;
         _loc8_ *= _loc22_;
         if(!param3)
         {
            this.concat([_loc6_,_loc7_,_loc8_,0,_loc17_,_loc6_,_loc7_,_loc8_,0,_loc17_,_loc6_,_loc7_,_loc8_,0,_loc17_,0,0,0,1,0]);
         }
         else
         {
            this.concat([0,0,0,0,0,0,0,0,0,0,_loc6_,_loc7_,_loc8_,0,_loc17_,0,0,0,1,0]);
         }
      }
      
      public function invertMatrix() : Boolean
      {
         var _loc1_:Matrix3D = new Matrix3D(Vector.<Number>([this.matrix[0],this.matrix[1],this.matrix[2],this.matrix[3],this.matrix[5],this.matrix[6],this.matrix[7],this.matrix[8],this.matrix[10],this.matrix[11],this.matrix[12],this.matrix[13],this.matrix[15],this.matrix[16],this.matrix[17],this.matrix[18]]));
         var _loc2_:Boolean = _loc1_.invert();
         if(!_loc2_)
         {
            return false;
         }
         this.matrix[0] = _loc1_.rawData[0];
         this.matrix[1] = _loc1_.rawData[1];
         this.matrix[2] = _loc1_.rawData[2];
         this.matrix[3] = _loc1_.rawData[3];
         var _loc3_:Number = -(_loc1_.rawData[0] * this.matrix[4] + _loc1_.rawData[1] * this.matrix[9] + _loc1_.rawData[2] * this.matrix[14] + _loc1_.rawData[3] * this.matrix[15]);
         this.matrix[5] = _loc1_.rawData[4];
         this.matrix[6] = _loc1_.rawData[5];
         this.matrix[7] = _loc1_.rawData[6];
         this.matrix[8] = _loc1_.rawData[7];
         var _loc4_:Number = -(_loc1_.rawData[4] * this.matrix[4] + _loc1_.rawData[5] * this.matrix[9] + _loc1_.rawData[6] * this.matrix[14] + _loc1_.rawData[7] * this.matrix[15]);
         this.matrix[10] = _loc1_.rawData[8];
         this.matrix[11] = _loc1_.rawData[9];
         this.matrix[12] = _loc1_.rawData[10];
         this.matrix[13] = _loc1_.rawData[11];
         var _loc5_:Number = -(_loc1_.rawData[8] * this.matrix[4] + _loc1_.rawData[9] * this.matrix[9] + _loc1_.rawData[10] * this.matrix[14] + _loc1_.rawData[11] * this.matrix[15]);
         this.matrix[15] = _loc1_.rawData[12];
         this.matrix[16] = _loc1_.rawData[13];
         this.matrix[17] = _loc1_.rawData[14];
         this.matrix[18] = _loc1_.rawData[15];
         var _loc6_:Number = -(_loc1_.rawData[12] * this.matrix[4] + _loc1_.rawData[13] * this.matrix[9] + _loc1_.rawData[14] * this.matrix[14] + _loc1_.rawData[15] * this.matrix[15]);
         this.matrix[4] = _loc3_;
         this.matrix[9] = _loc4_;
         this.matrix[14] = _loc5_;
         this.matrix[19] = _loc6_;
         return true;
      }
      
      public function applyMatrix(param1:uint) : uint
      {
         var _loc2_:Number = param1 >>> 24 & 0xFF;
         var _loc3_:Number = param1 >>> 16 & 0xFF;
         var _loc4_:Number = param1 >>> 8 & 0xFF;
         var _loc5_:Number = param1 & 0xFF;
         var _loc6_:int = 0.5 + _loc3_ * this.matrix[0] + _loc4_ * this.matrix[1] + _loc5_ * this.matrix[2] + _loc2_ * this.matrix[3] + this.matrix[4];
         var _loc7_:int = 0.5 + _loc3_ * this.matrix[5] + _loc4_ * this.matrix[6] + _loc5_ * this.matrix[7] + _loc2_ * this.matrix[8] + this.matrix[9];
         var _loc8_:int = 0.5 + _loc3_ * this.matrix[10] + _loc4_ * this.matrix[11] + _loc5_ * this.matrix[12] + _loc2_ * this.matrix[13] + this.matrix[14];
         var _loc9_:int = 0.5 + _loc3_ * this.matrix[15] + _loc4_ * this.matrix[16] + _loc5_ * this.matrix[17] + _loc2_ * this.matrix[18] + this.matrix[19];
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         if(_loc9_ > 255)
         {
            _loc9_ = 255;
         }
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         if(_loc6_ > 255)
         {
            _loc6_ = 255;
         }
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         if(_loc7_ > 255)
         {
            _loc7_ = 255;
         }
         if(_loc8_ < 0)
         {
            _loc8_ = 0;
         }
         if(_loc8_ > 255)
         {
            _loc8_ = 255;
         }
         return _loc9_ << 24 | _loc6_ << 16 | _loc7_ << 8 | _loc8_;
      }
      
      public function transformVector(param1:Array) : void
      {
         if(param1.length != 4)
         {
            return;
         }
         var _loc2_:Number = param1[0] * this.matrix[0] + param1[1] * this.matrix[1] + param1[2] * this.matrix[2] + param1[3] * this.matrix[3] + this.matrix[4];
         var _loc3_:Number = param1[0] * this.matrix[5] + param1[1] * this.matrix[6] + param1[2] * this.matrix[7] + param1[3] * this.matrix[8] + this.matrix[9];
         var _loc4_:Number = param1[0] * this.matrix[10] + param1[1] * this.matrix[11] + param1[2] * this.matrix[12] + param1[3] * this.matrix[13] + this.matrix[14];
         var _loc5_:Number = param1[0] * this.matrix[15] + param1[1] * this.matrix[16] + param1[2] * this.matrix[17] + param1[3] * this.matrix[18] + this.matrix[19];
         param1[0] = _loc2_;
         param1[1] = _loc3_;
         param1[2] = _loc4_;
         param1[3] = _loc5_;
      }
      
      private function initHue() : void
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Number = 39.182655;
         if(!this.hueInitialized)
         {
            this.hueInitialized = true;
            this.preHue = new ColorMatrix();
            this.preHue.rotateRed(45);
            this.preHue.rotateGreen(-_loc1_);
            _loc2_ = [LUMA_R2,LUMA_G2,LUMA_B2,1];
            this.preHue.transformVector(_loc2_);
            _loc3_ = _loc2_[0] / _loc2_[2];
            _loc4_ = _loc2_[1] / _loc2_[2];
            this.preHue.shearBlue(_loc3_,_loc4_);
            this.postHue = new ColorMatrix();
            this.postHue.shearBlue(-_loc3_,-_loc4_);
            this.postHue.rotateGreen(_loc1_);
            this.postHue.rotateRed(-45);
         }
      }
      
      public function toString() : String
      {
         return this.matrix.toString();
      }
   }
}

