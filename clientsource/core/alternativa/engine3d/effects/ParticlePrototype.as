package alternativa.engine3d.effects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Transform3D;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class ParticlePrototype
   {
      
      public var atlas:TextureAtlas;
      
      private var blendSource:String;
      
      private var blendDestination:String;
      
      private var animated:Boolean;
      
      private var width:Number;
      
      private var height:Number;
      
      private var timeKeys:Vector.<Number> = new Vector.<Number>();
      
      private var rotationKeys:Vector.<Number> = new Vector.<Number>();
      
      private var scaleXKeys:Vector.<Number> = new Vector.<Number>();
      
      private var scaleYKeys:Vector.<Number> = new Vector.<Number>();
      
      private var redKeys:Vector.<Number> = new Vector.<Number>();
      
      private var greenKeys:Vector.<Number> = new Vector.<Number>();
      
      private var blueKeys:Vector.<Number> = new Vector.<Number>();
      
      private var alphaKeys:Vector.<Number> = new Vector.<Number>();
      
      private var keysCount:int = 0;
      
      public function ParticlePrototype(param1:Number, param2:Number, param3:TextureAtlas, param4:Boolean = false, param5:String = "sourceAlpha", param6:String = "oneMinusSourceAlpha")
      {
         super();
         this.width = param1;
         this.height = param2;
         this.atlas = param3;
         this.animated = param4;
         this.blendSource = param5;
         this.blendDestination = param6;
      }
      
      public function addKey(param1:Number, param2:Number = 0, param3:Number = 1, param4:Number = 1, param5:Number = 1, param6:Number = 1, param7:Number = 1, param8:Number = 1) : void
      {
         var _loc9_:int = this.keysCount - 1;
         if(this.keysCount > 0 && param1 <= this.timeKeys[_loc9_])
         {
            throw new Error("Keys must be successively.");
         }
         this.timeKeys[this.keysCount] = param1;
         this.rotationKeys[this.keysCount] = param2;
         this.scaleXKeys[this.keysCount] = param3;
         this.scaleYKeys[this.keysCount] = param4;
         this.redKeys[this.keysCount] = param5;
         this.greenKeys[this.keysCount] = param6;
         this.blueKeys[this.keysCount] = param7;
         this.alphaKeys[this.keysCount] = param8;
         ++this.keysCount;
      }
      
      public function createParticle(param1:ParticleEffect, param2:Number, param3:Vector3D, param4:Number = 0, param5:Number = 1, param6:Number = 1, param7:Number = 1, param8:int = 0) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Transform3D = null;
         var _loc13_:Vector3D = null;
         var _loc14_:Vector3D = null;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:Particle = null;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc9_:int = this.keysCount - 1;
         if(this.atlas.diffuse.alternativa3d::_texture != null && this.keysCount > 1 && param2 >= this.timeKeys[0] && param2 < this.timeKeys[_loc9_])
         {
            _loc9_ = 1;
            while(_loc9_ < this.keysCount)
            {
               if(param2 < this.timeKeys[_loc9_])
               {
                  _loc10_ = param1.alternativa3d::system.alternativa3d::scale;
                  _loc11_ = param1.scale;
                  _loc12_ = param1.alternativa3d::system.alternativa3d::localToCameraTransform;
                  _loc13_ = param1.alternativa3d::system.wind;
                  _loc14_ = param1.alternativa3d::system.gravity;
                  _loc15_ = _loc9_ - 1;
                  _loc16_ = (param2 - this.timeKeys[_loc15_]) / (this.timeKeys[_loc9_] - this.timeKeys[_loc15_]);
                  _loc17_ = param8 + (this.animated ? param2 * this.atlas.fps : 0);
                  if(this.atlas.loop)
                  {
                     _loc17_ %= this.atlas.rangeLength;
                     if(_loc17_ < 0)
                     {
                        _loc17_ += this.atlas.rangeLength;
                     }
                  }
                  else
                  {
                     if(_loc17_ < 0)
                     {
                        _loc17_ = 0;
                     }
                     if(_loc17_ >= this.atlas.rangeLength)
                     {
                        _loc17_ = this.atlas.rangeLength - 1;
                     }
                  }
                  _loc17_ += this.atlas.rangeBegin;
                  _loc18_ = _loc17_ % this.atlas.columnsCount;
                  _loc19_ = _loc17_ / this.atlas.columnsCount;
                  _loc20_ = Particle.create();
                  _loc20_.diffuse = this.atlas.diffuse.alternativa3d::_texture;
                  _loc20_.opacity = this.atlas.opacity != null ? this.atlas.opacity.alternativa3d::_texture : null;
                  _loc20_.blendSource = this.blendSource;
                  _loc20_.blendDestination = this.blendDestination;
                  _loc21_ = param1.alternativa3d::keyPosition.x + param3.x * _loc11_;
                  _loc22_ = param1.alternativa3d::keyPosition.y + param3.y * _loc11_;
                  _loc23_ = param1.alternativa3d::keyPosition.z + param3.z * _loc11_;
                  _loc20_.x = _loc21_ * _loc12_.a + _loc22_ * _loc12_.b + _loc23_ * _loc12_.c + _loc12_.d;
                  _loc20_.y = _loc21_ * _loc12_.e + _loc22_ * _loc12_.f + _loc23_ * _loc12_.g + _loc12_.h;
                  _loc20_.z = _loc21_ * _loc12_.i + _loc22_ * _loc12_.j + _loc23_ * _loc12_.k + _loc12_.l;
                  _loc24_ = this.rotationKeys[_loc15_] + (this.rotationKeys[_loc9_] - this.rotationKeys[_loc15_]) * _loc16_;
                  _loc20_.rotation = param5 * param6 > 0 ? param4 + _loc24_ : param4 - _loc24_;
                  _loc20_.width = _loc10_ * _loc11_ * param5 * this.width * (this.scaleXKeys[_loc15_] + (this.scaleXKeys[_loc9_] - this.scaleXKeys[_loc15_]) * _loc16_);
                  _loc20_.height = _loc10_ * _loc11_ * param6 * this.height * (this.scaleYKeys[_loc15_] + (this.scaleYKeys[_loc9_] - this.scaleYKeys[_loc15_]) * _loc16_);
                  _loc20_.originX = this.atlas.originX;
                  _loc20_.originY = this.atlas.originY;
                  _loc20_.uvScaleX = 1 / this.atlas.columnsCount;
                  _loc20_.uvScaleY = 1 / this.atlas.rowsCount;
                  _loc20_.uvOffsetX = _loc18_ / this.atlas.columnsCount;
                  _loc20_.uvOffsetY = _loc19_ / this.atlas.rowsCount;
                  _loc20_.red = this.redKeys[_loc15_] + (this.redKeys[_loc9_] - this.redKeys[_loc15_]) * _loc16_;
                  _loc20_.green = this.greenKeys[_loc15_] + (this.greenKeys[_loc9_] - this.greenKeys[_loc15_]) * _loc16_;
                  _loc20_.blue = this.blueKeys[_loc15_] + (this.blueKeys[_loc9_] - this.blueKeys[_loc15_]) * _loc16_;
                  _loc20_.alpha = param7 * (this.alphaKeys[_loc15_] + (this.alphaKeys[_loc9_] - this.alphaKeys[_loc15_]) * _loc16_);
                  _loc20_.next = param1.alternativa3d::particleList;
                  param1.alternativa3d::particleList = _loc20_;
                  break;
               }
               _loc9_++;
            }
         }
      }
      
      public function get lifeTime() : Number
      {
         var _loc1_:int = this.keysCount - 1;
         return this.timeKeys[_loc1_];
      }
   }
}

