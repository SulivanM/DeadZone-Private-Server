package alternativa.engine3d.lights
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   
   use namespace alternativa3d;
   
   public class OmniLight extends Light3D
   {
      
      public var attenuationBegin:Number;
      
      public var attenuationEnd:Number;
      
      public function OmniLight(param1:uint, param2:Number, param3:Number)
      {
         super();
         this.alternativa3d::type = alternativa3d::OMNI;
         this.color = param1;
         this.attenuationBegin = param2;
         this.attenuationEnd = param3;
         calculateBoundBox();
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         if(param2 == null)
         {
            if(-this.attenuationEnd < param1.minX)
            {
               param1.minX = -this.attenuationEnd;
            }
            if(this.attenuationEnd > param1.maxX)
            {
               param1.maxX = this.attenuationEnd;
            }
            if(-this.attenuationEnd < param1.minY)
            {
               param1.minY = -this.attenuationEnd;
            }
            if(this.attenuationEnd > param1.maxY)
            {
               param1.maxY = this.attenuationEnd;
            }
            if(-this.attenuationEnd < param1.minZ)
            {
               param1.minZ = -this.attenuationEnd;
            }
            if(this.attenuationEnd > param1.maxZ)
            {
               param1.maxZ = this.attenuationEnd;
            }
         }
      }
      
      override alternativa3d function checkBound(param1:Object3D) : Boolean
      {
         var _loc2_:Number = Math.sqrt(alternativa3d::lightToObjectTransform.a * alternativa3d::lightToObjectTransform.a + alternativa3d::lightToObjectTransform.e * alternativa3d::lightToObjectTransform.e + alternativa3d::lightToObjectTransform.i * alternativa3d::lightToObjectTransform.i);
         _loc2_ += Math.sqrt(alternativa3d::lightToObjectTransform.b * alternativa3d::lightToObjectTransform.b + alternativa3d::lightToObjectTransform.f * alternativa3d::lightToObjectTransform.f + alternativa3d::lightToObjectTransform.j * alternativa3d::lightToObjectTransform.j);
         _loc2_ += Math.sqrt(alternativa3d::lightToObjectTransform.c * alternativa3d::lightToObjectTransform.c + alternativa3d::lightToObjectTransform.g * alternativa3d::lightToObjectTransform.g + alternativa3d::lightToObjectTransform.k * alternativa3d::lightToObjectTransform.k);
         _loc2_ /= 3;
         _loc2_ *= this.attenuationEnd;
         _loc2_ *= _loc2_;
         var _loc3_:Number = 0;
         var _loc4_:BoundBox = param1.boundBox;
         var _loc5_:Number = _loc4_.minX;
         var _loc6_:Number = _loc4_.minY;
         var _loc7_:Number = _loc4_.minZ;
         var _loc8_:Number = _loc4_.maxX;
         var _loc9_:Number = Number(alternativa3d::lightToObjectTransform.d);
         var _loc10_:Number = Number(alternativa3d::lightToObjectTransform.h);
         var _loc11_:Number = Number(alternativa3d::lightToObjectTransform.l);
         var _loc12_:Number = _loc4_.maxY;
         var _loc13_:Number = _loc4_.maxZ;
         if(_loc9_ < _loc5_)
         {
            if(_loc10_ < _loc6_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc6_ - _loc10_) * (_loc6_ - _loc10_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc6_ - _loc10_) * (_loc6_ - _loc10_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc6_ - _loc10_) * (_loc6_ - _loc10_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
            else if(_loc10_ < _loc12_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
            else if(_loc10_ > _loc12_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc12_ - _loc10_) * (_loc12_ - _loc10_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc12_ - _loc10_) * (_loc12_ - _loc10_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc5_ - _loc9_) * (_loc5_ - _loc9_) + (_loc12_ - _loc10_) * (_loc12_ - _loc10_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
         }
         else if(_loc9_ < _loc8_)
         {
            if(_loc10_ < _loc6_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc6_ - _loc10_) * (_loc6_ - _loc10_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc6_ - _loc10_) * (_loc6_ - _loc10_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc6_ - _loc10_) * (_loc6_ - _loc10_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
            else if(_loc10_ < _loc12_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  return true;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
            else if(_loc10_ > _loc12_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc12_ - _loc10_) * (_loc12_ - _loc10_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc12_ - _loc10_) * (_loc12_ - _loc10_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc12_ - _loc10_) * (_loc12_ - _loc10_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
         }
         else if(_loc9_ > _loc8_)
         {
            if(_loc10_ < _loc6_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc6_ - _loc10_) * (_loc6_ - _loc10_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc6_ - _loc10_) * (_loc6_ - _loc10_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc6_ - _loc10_) * (_loc6_ - _loc10_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
            else if(_loc10_ < _loc12_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
            else if(_loc10_ > _loc12_)
            {
               if(_loc11_ < _loc7_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc12_ - _loc10_) * (_loc12_ - _loc10_) + (_loc7_ - _loc11_) * (_loc7_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc12_ - _loc10_) * (_loc12_ - _loc10_);
                  return _loc3_ < _loc2_;
               }
               if(_loc11_ > _loc13_)
               {
                  _loc3_ = (_loc8_ - _loc9_) * (_loc8_ - _loc9_) + (_loc12_ - _loc10_) * (_loc12_ - _loc10_) + (_loc13_ - _loc11_) * (_loc13_ - _loc11_);
                  return _loc3_ < _loc2_;
               }
            }
         }
         return true;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:OmniLight = new OmniLight(color,this.attenuationBegin,this.attenuationEnd);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

