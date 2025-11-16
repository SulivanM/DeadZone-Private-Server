package alternativa.engine3d.lights
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   
   use namespace alternativa3d;
   
   public class SpotLight extends Light3D
   {
      
      public var attenuationBegin:Number;
      
      public var attenuationEnd:Number;
      
      public var hotspot:Number;
      
      public var falloff:Number;
      
      public function SpotLight(param1:uint, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super();
         this.alternativa3d::type = alternativa3d::SPOT;
         this.color = param1;
         this.attenuationBegin = param2;
         this.attenuationEnd = param3;
         this.hotspot = param4;
         this.falloff = param5;
         calculateBoundBox();
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         _loc3_ = this.falloff < Math.PI ? Math.sin(this.falloff * 0.5) * this.attenuationEnd : this.attenuationEnd;
         _loc4_ = this.falloff < Math.PI ? 0 : Math.cos(this.falloff * 0.5) * this.attenuationEnd;
         param1.minX = -_loc3_;
         param1.minY = -_loc3_;
         param1.minZ = _loc4_;
         param1.maxX = _loc3_;
         param1.maxY = _loc3_;
         param1.maxZ = this.attenuationEnd;
      }
      
      public function lookAt(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = param1 - this.x;
         var _loc5_:Number = param2 - this.y;
         var _loc6_:Number = param3 - this.z;
         rotationX = Math.atan2(_loc6_,Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_)) - Math.PI / 2;
         rotationY = 0;
         rotationZ = -Math.atan2(_loc4_,_loc5_);
      }
      
      override alternativa3d function checkBound(param1:Object3D) : Boolean
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc2_:Number = boundBox.minX;
         var _loc3_:Number = boundBox.minY;
         var _loc4_:Number = boundBox.minZ;
         var _loc5_:Number = boundBox.maxX;
         var _loc6_:Number = boundBox.maxY;
         var _loc7_:Number = boundBox.maxZ;
         var _loc10_:Number = (_loc5_ - _loc2_) * 0.5;
         var _loc11_:Number = (_loc6_ - _loc3_) * 0.5;
         var _loc12_:Number = (_loc7_ - _loc4_) * 0.5;
         var _loc13_:Number = alternativa3d::lightToObjectTransform.a * _loc10_;
         var _loc14_:Number = alternativa3d::lightToObjectTransform.e * _loc10_;
         var _loc15_:Number = alternativa3d::lightToObjectTransform.i * _loc10_;
         var _loc16_:Number = alternativa3d::lightToObjectTransform.b * _loc11_;
         var _loc17_:Number = alternativa3d::lightToObjectTransform.f * _loc11_;
         var _loc18_:Number = alternativa3d::lightToObjectTransform.j * _loc11_;
         var _loc19_:Number = alternativa3d::lightToObjectTransform.c * _loc12_;
         var _loc20_:Number = alternativa3d::lightToObjectTransform.g * _loc12_;
         var _loc21_:Number = alternativa3d::lightToObjectTransform.k * _loc12_;
         var _loc22_:BoundBox = param1.boundBox;
         var _loc23_:Number = (_loc22_.maxX - _loc22_.minX) * 0.5;
         var _loc24_:Number = (_loc22_.maxY - _loc22_.minY) * 0.5;
         var _loc25_:Number = (_loc22_.maxZ - _loc22_.minZ) * 0.5;
         var _loc26_:Number = alternativa3d::lightToObjectTransform.a * (_loc2_ + _loc10_) + alternativa3d::lightToObjectTransform.b * (_loc3_ + _loc11_) + alternativa3d::lightToObjectTransform.c * (_loc4_ + _loc12_) + alternativa3d::lightToObjectTransform.d - _loc22_.minX - _loc23_;
         var _loc27_:Number = alternativa3d::lightToObjectTransform.e * (_loc2_ + _loc10_) + alternativa3d::lightToObjectTransform.f * (_loc3_ + _loc11_) + alternativa3d::lightToObjectTransform.g * (_loc4_ + _loc12_) + alternativa3d::lightToObjectTransform.h - _loc22_.minY - _loc24_;
         var _loc28_:Number = alternativa3d::lightToObjectTransform.i * (_loc2_ + _loc10_) + alternativa3d::lightToObjectTransform.j * (_loc3_ + _loc11_) + alternativa3d::lightToObjectTransform.k * (_loc4_ + _loc12_) + alternativa3d::lightToObjectTransform.l - _loc22_.minZ - _loc25_;
         _loc8_ = 0;
         if(_loc13_ >= 0)
         {
            _loc8_ += _loc13_;
         }
         else
         {
            _loc8_ -= _loc13_;
         }
         if(_loc16_ >= 0)
         {
            _loc8_ += _loc16_;
         }
         else
         {
            _loc8_ -= _loc16_;
         }
         if(_loc19_ >= 0)
         {
            _loc8_ += _loc19_;
         }
         else
         {
            _loc8_ -= _loc19_;
         }
         _loc8_ += _loc23_;
         if(_loc26_ >= 0)
         {
            _loc8_ -= _loc26_;
         }
         _loc8_ += _loc26_;
         if(_loc8_ <= 0)
         {
            return false;
         }
         _loc8_ = 0;
         if(_loc14_ >= 0)
         {
            _loc8_ += _loc14_;
         }
         else
         {
            _loc8_ -= _loc14_;
         }
         if(_loc17_ >= 0)
         {
            _loc8_ += _loc17_;
         }
         else
         {
            _loc8_ -= _loc17_;
         }
         if(_loc20_ >= 0)
         {
            _loc8_ += _loc20_;
         }
         else
         {
            _loc8_ -= _loc20_;
         }
         _loc8_ += _loc24_;
         if(_loc27_ >= 0)
         {
            _loc8_ -= _loc27_;
         }
         else
         {
            _loc8_ += _loc27_;
         }
         if(_loc8_ <= 0)
         {
            return false;
         }
         _loc8_ = 0;
         if(_loc15_ >= 0)
         {
            _loc8_ += _loc15_;
         }
         else
         {
            _loc8_ -= _loc15_;
         }
         if(_loc18_ >= 0)
         {
            _loc8_ += _loc18_;
         }
         else
         {
            _loc8_ -= _loc18_;
         }
         if(_loc21_ >= 0)
         {
            _loc8_ += _loc21_;
         }
         else
         {
            _loc8_ -= _loc21_;
         }
         _loc8_ += _loc24_;
         if(_loc28_ >= 0)
         {
            _loc8_ -= _loc28_;
         }
         else
         {
            _loc8_ += _loc28_;
         }
         if(_loc8_ <= 0)
         {
            return false;
         }
         _loc8_ = 0;
         _loc9_ = alternativa3d::lightToObjectTransform.a * _loc13_ + alternativa3d::lightToObjectTransform.e * _loc14_ + alternativa3d::lightToObjectTransform.i * _loc15_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.a * _loc16_ + alternativa3d::lightToObjectTransform.e * _loc17_ + alternativa3d::lightToObjectTransform.i * _loc18_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.a * _loc19_ + alternativa3d::lightToObjectTransform.e * _loc20_ + alternativa3d::lightToObjectTransform.i * _loc21_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         if(alternativa3d::lightToObjectTransform.a >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.a * _loc23_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.a * _loc23_;
         }
         if(alternativa3d::lightToObjectTransform.e >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.e * _loc24_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.e * _loc24_;
         }
         if(alternativa3d::lightToObjectTransform.i >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.i * _loc25_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.i * _loc25_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.a * _loc26_ + alternativa3d::lightToObjectTransform.e * _loc27_ + alternativa3d::lightToObjectTransform.i * _loc28_;
         if(_loc9_ >= 0)
         {
            _loc8_ -= _loc9_;
         }
         else
         {
            _loc8_ += _loc9_;
         }
         if(_loc8_ <= 0)
         {
            return false;
         }
         _loc8_ = 0;
         _loc9_ = alternativa3d::lightToObjectTransform.b * _loc13_ + alternativa3d::lightToObjectTransform.f * _loc14_ + alternativa3d::lightToObjectTransform.j * _loc15_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.b * _loc16_ + alternativa3d::lightToObjectTransform.f * _loc17_ + alternativa3d::lightToObjectTransform.j * _loc18_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.b * _loc19_ + alternativa3d::lightToObjectTransform.f * _loc20_ + alternativa3d::lightToObjectTransform.j * _loc21_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         if(alternativa3d::lightToObjectTransform.b >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.b * _loc23_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.b * _loc23_;
         }
         if(alternativa3d::lightToObjectTransform.f >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.f * _loc24_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.f * _loc24_;
         }
         if(alternativa3d::lightToObjectTransform.j >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.j * _loc25_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.j * _loc25_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.b * _loc26_ + alternativa3d::lightToObjectTransform.f * _loc27_ + alternativa3d::lightToObjectTransform.j * _loc28_;
         if(_loc9_ >= 0)
         {
            _loc8_ -= _loc9_;
         }
         _loc8_ += _loc9_;
         if(_loc8_ <= 0)
         {
            return false;
         }
         _loc8_ = 0;
         _loc9_ = alternativa3d::lightToObjectTransform.c * _loc13_ + alternativa3d::lightToObjectTransform.g * _loc14_ + alternativa3d::lightToObjectTransform.k * _loc15_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.c * _loc16_ + alternativa3d::lightToObjectTransform.g * _loc17_ + alternativa3d::lightToObjectTransform.k * _loc18_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.c * _loc19_ + alternativa3d::lightToObjectTransform.g * _loc20_ + alternativa3d::lightToObjectTransform.k * _loc21_;
         if(_loc9_ >= 0)
         {
            _loc8_ += _loc9_;
         }
         else
         {
            _loc8_ -= _loc9_;
         }
         if(alternativa3d::lightToObjectTransform.c >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.c * _loc23_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.c * _loc23_;
         }
         if(alternativa3d::lightToObjectTransform.g >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.g * _loc24_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.g * _loc24_;
         }
         if(alternativa3d::lightToObjectTransform.k >= 0)
         {
            _loc8_ += alternativa3d::lightToObjectTransform.k * _loc25_;
         }
         else
         {
            _loc8_ -= alternativa3d::lightToObjectTransform.k * _loc25_;
         }
         _loc9_ = alternativa3d::lightToObjectTransform.c * _loc26_ + alternativa3d::lightToObjectTransform.g * _loc27_ + alternativa3d::lightToObjectTransform.k * _loc28_;
         if(_loc9_ >= 0)
         {
            _loc8_ -= _loc9_;
         }
         else
         {
            _loc8_ += _loc9_;
         }
         if(_loc8_ <= 0)
         {
            return false;
         }
         return true;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:SpotLight = new SpotLight(color,this.attenuationBegin,this.attenuationEnd,this.hotspot,this.falloff);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

