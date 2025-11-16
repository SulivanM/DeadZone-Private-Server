package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.RayIntersectionData;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.events.Event3D;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class LOD extends Object3D
   {
      
      alternativa3d var levelList:Object3D;
      
      private var level:Object3D;
      
      public function LOD()
      {
         super();
      }
      
      public function addLevel(param1:Object3D, param2:Number) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter level must be non-null.");
         }
         if(param1 == this)
         {
            throw new ArgumentError("An object cannot be added as a child of itself.");
         }
         var _loc3_:Object3D = alternativa3d::_parent;
         while(_loc3_ != null)
         {
            if(_loc3_ == param1)
            {
               throw new ArgumentError("An object cannot be added as a child to one of it\'s children (or children\'s children, etc.).");
            }
            _loc3_ = _loc3_.alternativa3d::_parent;
         }
         if(param1.alternativa3d::_parent != this)
         {
            if(param1.alternativa3d::_parent != null)
            {
               param1.alternativa3d::_parent.removeChild(param1);
            }
            this.addToLevelList(param1,param2);
            param1.alternativa3d::_parent = this;
            if(param1.willTrigger(Event3D.ADDED))
            {
               param1.dispatchEvent(new Event3D(Event3D.ADDED,true));
            }
         }
         else
         {
            if(alternativa3d::removeFromList(param1) == null)
            {
               this.removeFromLevelList(param1);
            }
            this.addToLevelList(param1,param2);
         }
         return param1;
      }
      
      public function removeLevel(param1:Object3D) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter level must be non-null.");
         }
         if(param1.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         param1 = this.removeFromLevelList(param1);
         if(param1 == null)
         {
            throw new ArgumentError("Cannot remove level.");
         }
         if(param1.willTrigger(Event3D.REMOVED))
         {
            param1.dispatchEvent(new Event3D(Event3D.REMOVED,true));
         }
         param1.alternativa3d::_parent = null;
         return param1;
      }
      
      public function getLevelDistance(param1:Object3D) : Number
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter level must be non-null.");
         }
         if(param1.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         var _loc2_:Object3D = this.alternativa3d::levelList;
         while(_loc2_ != null)
         {
            if(param1 == _loc2_)
            {
               return param1.alternativa3d::distance;
            }
            _loc2_ = _loc2_.alternativa3d::next;
         }
         throw new ArgumentError("Cannot get level distance.");
      }
      
      public function setLevelDistance(param1:Object3D, param2:Number) : void
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter level must be non-null.");
         }
         if(param1.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         param1 = this.removeFromLevelList(param1);
         if(param1 == null)
         {
            throw new ArgumentError("Cannot set level distance.");
         }
         this.addToLevelList(param1,param2);
      }
      
      public function getLevelByDistance(param1:Number) : Object3D
      {
         var _loc2_:Object3D = this.alternativa3d::levelList;
         while(_loc2_ != null)
         {
            if(param1 <= _loc2_.alternativa3d::distance)
            {
               return _loc2_;
            }
            _loc2_ = _loc2_.alternativa3d::next;
         }
         return null;
      }
      
      public function getLevelByName(param1:String) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter name must be non-null.");
         }
         var _loc2_:Object3D = this.alternativa3d::levelList;
         while(_loc2_ != null)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
            _loc2_ = _loc2_.alternativa3d::next;
         }
         return null;
      }
      
      public function getLevels() : Vector.<Object3D>
      {
         var _loc1_:Vector.<Object3D> = new Vector.<Object3D>();
         var _loc2_:int = 0;
         var _loc3_:Object3D = this.alternativa3d::levelList;
         while(_loc3_ != null)
         {
            _loc1_[_loc2_] = _loc3_;
            _loc2_++;
            _loc3_ = _loc3_.alternativa3d::next;
         }
         return _loc1_;
      }
      
      public function get numLevels() : int
      {
         var _loc1_:int = 0;
         var _loc2_:Object3D = this.alternativa3d::levelList;
         while(_loc2_ != null)
         {
            _loc1_++;
            _loc2_ = _loc2_.alternativa3d::next;
         }
         return _loc1_;
      }
      
      override alternativa3d function get useLights() : Boolean
      {
         return true;
      }
      
      override alternativa3d function calculateVisibility(param1:Camera3D) : void
      {
         var _loc2_:Number = Math.sqrt(alternativa3d::localToCameraTransform.d * alternativa3d::localToCameraTransform.d + alternativa3d::localToCameraTransform.h * alternativa3d::localToCameraTransform.h + alternativa3d::localToCameraTransform.l * alternativa3d::localToCameraTransform.l);
         this.level = this.alternativa3d::levelList;
         while(this.level != null)
         {
            if(_loc2_ <= this.level.alternativa3d::distance)
            {
               this.alternativa3d::calculateChildVisibility(this.level,this,param1);
               break;
            }
            this.level = this.level.alternativa3d::next;
         }
      }
      
      alternativa3d function calculateChildVisibility(param1:Object3D, param2:Object3D, param3:Camera3D) : void
      {
         if(param1.alternativa3d::transformChanged)
         {
            param1.alternativa3d::composeTransforms();
         }
         param1.alternativa3d::cameraToLocalTransform.combine(param1.alternativa3d::inverseTransform,param2.alternativa3d::cameraToLocalTransform);
         param1.alternativa3d::localToCameraTransform.combine(param2.alternativa3d::localToCameraTransform,param1.alternativa3d::transform);
         param3.alternativa3d::globalMouseHandlingType |= param1.alternativa3d::mouseHandlingType;
         param1.alternativa3d::culling = param2.alternativa3d::culling;
         if(param1.alternativa3d::culling >= 0)
         {
            param1.alternativa3d::calculateVisibility(param3);
         }
         var _loc4_:Object3D = param1.alternativa3d::childrenList;
         while(_loc4_ != null)
         {
            this.alternativa3d::calculateChildVisibility(_loc4_,param1,param3);
            _loc4_ = _loc4_.alternativa3d::next;
         }
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         if(this.level != null)
         {
            this.alternativa3d::collectChildDraws(this.level,this,param1,param2,param3,param4);
         }
         this.level = null;
      }
      
      alternativa3d function collectChildDraws(param1:Object3D, param2:Object3D, param3:Camera3D, param4:Vector.<Light3D>, param5:int, param6:Boolean) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Light3D = null;
         var _loc12_:int = 0;
         param1.alternativa3d::listening = param2.alternativa3d::listening;
         if(param5 > 0 && param1.alternativa3d::useLights)
         {
            _loc8_ = int(this.alternativa3d::_excludedLights.length);
            _loc9_ = 0;
            _loc10_ = 0;
            while(_loc10_ < param5)
            {
               _loc11_ = param4[_loc10_];
               _loc12_ = 0;
               while(_loc12_ < _loc8_ && this.alternativa3d::_excludedLights[_loc12_] != _loc11_)
               {
                  _loc12_++;
               }
               if(_loc12_ >= _loc8_)
               {
                  _loc11_.alternativa3d::lightToObjectTransform.combine(param1.alternativa3d::cameraToLocalTransform,_loc11_.alternativa3d::localToCameraTransform);
                  param3.alternativa3d::childLights[_loc9_] = _loc11_;
                  _loc9_++;
               }
               _loc10_++;
            }
            param1.alternativa3d::collectDraws(param3,param3.alternativa3d::childLights,_loc9_,param6);
         }
         else
         {
            param1.alternativa3d::collectDraws(param3,null,0,param6);
         }
         var _loc7_:Object3D = param1.alternativa3d::childrenList;
         while(_loc7_ != null)
         {
            this.alternativa3d::collectChildDraws(_loc7_,param1,param3,param4,param5,param6);
            _loc7_ = _loc7_.alternativa3d::next;
         }
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Boolean = false, param3:Class = null) : void
      {
         var _loc4_:Object3D = null;
         if(param2)
         {
            _loc4_ = this.alternativa3d::levelList;
            while(_loc4_ != null)
            {
               _loc4_.alternativa3d::fillResources(param1,param2,param3);
               _loc4_ = _loc4_.alternativa3d::next;
            }
         }
         super.alternativa3d::fillResources(param1,param2,param3);
      }
      
      override public function intersectRay(param1:Vector3D, param2:Vector3D) : RayIntersectionData
      {
         var _loc4_:RayIntersectionData = null;
         var _loc5_:Vector3D = null;
         var _loc6_:Vector3D = null;
         var _loc3_:RayIntersectionData = super.intersectRay(param1,param2);
         if(this.alternativa3d::levelList != null && (boundBox == null || boundBox.intersectRay(param1,param2)))
         {
            if(this.alternativa3d::levelList.alternativa3d::transformChanged)
            {
               this.alternativa3d::levelList.alternativa3d::composeTransforms();
            }
            _loc5_ = new Vector3D();
            _loc6_ = new Vector3D();
            _loc5_.x = this.alternativa3d::levelList.alternativa3d::inverseTransform.a * param1.x + this.alternativa3d::levelList.alternativa3d::inverseTransform.b * param1.y + this.alternativa3d::levelList.alternativa3d::inverseTransform.c * param1.z + this.alternativa3d::levelList.alternativa3d::inverseTransform.d;
            _loc5_.y = this.alternativa3d::levelList.alternativa3d::inverseTransform.e * param1.x + this.alternativa3d::levelList.alternativa3d::inverseTransform.f * param1.y + this.alternativa3d::levelList.alternativa3d::inverseTransform.g * param1.z + this.alternativa3d::levelList.alternativa3d::inverseTransform.h;
            _loc5_.z = this.alternativa3d::levelList.alternativa3d::inverseTransform.i * param1.x + this.alternativa3d::levelList.alternativa3d::inverseTransform.j * param1.y + this.alternativa3d::levelList.alternativa3d::inverseTransform.k * param1.z + this.alternativa3d::levelList.alternativa3d::inverseTransform.l;
            _loc6_.x = this.alternativa3d::levelList.alternativa3d::inverseTransform.a * param2.x + this.alternativa3d::levelList.alternativa3d::inverseTransform.b * param2.y + this.alternativa3d::levelList.alternativa3d::inverseTransform.c * param2.z;
            _loc6_.y = this.alternativa3d::levelList.alternativa3d::inverseTransform.e * param2.x + this.alternativa3d::levelList.alternativa3d::inverseTransform.f * param2.y + this.alternativa3d::levelList.alternativa3d::inverseTransform.g * param2.z;
            _loc6_.z = this.alternativa3d::levelList.alternativa3d::inverseTransform.i * param2.x + this.alternativa3d::levelList.alternativa3d::inverseTransform.j * param2.y + this.alternativa3d::levelList.alternativa3d::inverseTransform.k * param2.z;
            _loc4_ = this.alternativa3d::levelList.intersectRay(_loc5_,_loc6_);
         }
         if(_loc3_ != null)
         {
            if(_loc4_ != null)
            {
               return _loc3_.time < _loc4_.time ? _loc3_ : _loc4_;
            }
            return _loc3_;
         }
         return _loc4_;
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc3_:Object3D = this.alternativa3d::levelList;
         while(_loc3_ != null)
         {
            if(_loc3_.alternativa3d::transformChanged)
            {
               _loc3_.alternativa3d::composeTransforms();
            }
            if(param2 != null)
            {
               _loc3_.alternativa3d::localToCameraTransform.combine(param2,_loc3_.alternativa3d::transform);
            }
            else
            {
               _loc3_.alternativa3d::localToCameraTransform.copy(_loc3_.alternativa3d::transform);
            }
            _loc3_.alternativa3d::updateBoundBox(param1,_loc3_.alternativa3d::localToCameraTransform);
            this.updateBoundBoxChildren(_loc3_,param1);
            _loc3_ = _loc3_.alternativa3d::next;
         }
      }
      
      private function updateBoundBoxChildren(param1:Object3D, param2:BoundBox) : void
      {
         var _loc3_:Object3D = param1.alternativa3d::childrenList;
         while(_loc3_ != null)
         {
            if(_loc3_.alternativa3d::transformChanged)
            {
               _loc3_.alternativa3d::composeTransforms();
            }
            _loc3_.alternativa3d::localToCameraTransform.combine(param1.alternativa3d::localToCameraTransform,_loc3_.alternativa3d::transform);
            _loc3_.alternativa3d::updateBoundBox(param2,_loc3_.alternativa3d::localToCameraTransform);
            this.updateBoundBoxChildren(_loc3_,param2);
            _loc3_ = _loc3_.alternativa3d::next;
         }
      }
      
      private function addToLevelList(param1:Object3D, param2:Number) : void
      {
         param1.alternativa3d::distance = param2;
         var _loc3_:Object3D = null;
         var _loc4_:Object3D = this.alternativa3d::levelList;
         while(_loc4_ != null)
         {
            if(param2 < _loc4_.alternativa3d::distance)
            {
               param1.alternativa3d::next = _loc4_;
               break;
            }
            _loc3_ = _loc4_;
            _loc4_ = _loc4_.alternativa3d::next;
         }
         if(_loc3_ != null)
         {
            _loc3_.alternativa3d::next = param1;
         }
         else
         {
            this.alternativa3d::levelList = param1;
         }
      }
      
      private function removeFromLevelList(param1:Object3D) : Object3D
      {
         var _loc2_:Object3D = null;
         var _loc3_:Object3D = this.alternativa3d::levelList;
         while(_loc3_ != null)
         {
            if(_loc3_ == param1)
            {
               if(_loc2_ != null)
               {
                  _loc2_.alternativa3d::next = _loc3_.alternativa3d::next;
               }
               else
               {
                  this.alternativa3d::levelList = _loc3_.alternativa3d::next;
               }
               _loc3_.alternativa3d::next = null;
               return param1;
            }
            _loc2_ = _loc3_;
            _loc3_ = _loc3_.alternativa3d::next;
         }
         return null;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:LOD = new LOD();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         var _loc4_:Object3D = null;
         var _loc5_:Object3D = null;
         super.clonePropertiesFrom(param1);
         var _loc2_:LOD = param1 as LOD;
         var _loc3_:Object3D = _loc2_.alternativa3d::levelList;
         while(_loc3_ != null)
         {
            _loc5_ = _loc3_.clone();
            if(this.alternativa3d::levelList != null)
            {
               _loc4_.alternativa3d::next = _loc5_;
            }
            else
            {
               this.alternativa3d::levelList = _loc5_;
            }
            _loc4_ = _loc5_;
            _loc5_.alternativa3d::_parent = this;
            _loc5_.alternativa3d::distance = _loc3_.alternativa3d::distance;
            _loc3_ = _loc3_.alternativa3d::next;
         }
      }
   }
}

