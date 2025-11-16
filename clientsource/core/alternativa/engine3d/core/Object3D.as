package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.collisions.EllipsoidCollider;
   import alternativa.engine3d.core.events.Event3D;
   import alternativa.engine3d.core.events.MouseEvent3D;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.objects.Surface;
   import flash.events.Event;
   import flash.events.EventPhase;
   import flash.events.IEventDispatcher;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   use namespace alternativa3d;
   
   public class Object3D implements IEventDispatcher
   {
      
      private static const MOUSE_MOVE_BIT:uint = 1;
      
      private static const MOUSE_OVER_BIT:uint = 2;
      
      private static const MOUSE_OUT_BIT:uint = 4;
      
      private static const ROLL_OVER_BIT:uint = 8;
      
      private static const ROLL_OUT_BIT:uint = 16;
      
      private static const USE_HAND_CURSOR_BIT:uint = 32;
      
      private static const MOUSE_DOWN_BIT:uint = 64;
      
      private static const MOUSE_UP_BIT:uint = 128;
      
      private static const CLICK_BIT:uint = 256;
      
      private static const DOUBLE_CLICK_BIT:uint = 512;
      
      private static const MOUSE_WHEEL_BIT:uint = 1024;
      
      private static const MIDDLE_CLICK_BIT:uint = 2048;
      
      private static const MIDDLE_MOUSE_DOWN_BIT:uint = 4096;
      
      private static const MIDDLE_MOUSE_UP_BIT:uint = 8192;
      
      private static const RIGHT_CLICK_BIT:uint = 16384;
      
      private static const RIGHT_MOUSE_DOWN_BIT:uint = 32768;
      
      private static const RIGHT_MOUSE_UP_BIT:uint = 65536;
      
      alternativa3d static const MOUSE_HANDLING_MOVING:uint = MOUSE_MOVE_BIT | MOUSE_OVER_BIT | MOUSE_OUT_BIT | ROLL_OVER_BIT | ROLL_OUT_BIT | USE_HAND_CURSOR_BIT;
      
      alternativa3d static const MOUSE_HANDLING_PRESSING:uint = MOUSE_DOWN_BIT | MOUSE_UP_BIT | CLICK_BIT | DOUBLE_CLICK_BIT;
      
      alternativa3d static const MOUSE_HANDLING_WHEEL:uint = MOUSE_WHEEL_BIT;
      
      alternativa3d static const MOUSE_HANDLING_MIDDLE_BUTTON:uint = MIDDLE_CLICK_BIT | MIDDLE_MOUSE_DOWN_BIT | MIDDLE_MOUSE_UP_BIT;
      
      alternativa3d static const MOUSE_HANDLING_RIGHT_BUTTON:uint = RIGHT_CLICK_BIT | RIGHT_MOUSE_DOWN_BIT | RIGHT_MOUSE_UP_BIT;
      
      alternativa3d static const trm:Transform3D = new Transform3D();
      
      public var userData:Object = {};
      
      public var useShadow:Boolean = true;
      
      alternativa3d var _excludedLights:Vector.<Light3D> = new Vector.<Light3D>();
      
      public var name:String;
      
      public var visible:Boolean = true;
      
      public var mouseEnabled:Boolean = true;
      
      public var mouseChildren:Boolean = true;
      
      public var doubleClickEnabled:Boolean = false;
      
      public var boundBox:BoundBox;
      
      alternativa3d var _x:Number = 0;
      
      alternativa3d var _y:Number = 0;
      
      alternativa3d var _z:Number = 0;
      
      alternativa3d var _rotationX:Number = 0;
      
      alternativa3d var _rotationY:Number = 0;
      
      alternativa3d var _rotationZ:Number = 0;
      
      alternativa3d var _scaleX:Number = 1;
      
      alternativa3d var _scaleY:Number = 1;
      
      alternativa3d var _scaleZ:Number = 1;
      
      alternativa3d var _parent:Object3D;
      
      alternativa3d var childrenList:Object3D;
      
      alternativa3d var next:Object3D;
      
      alternativa3d var transform:Transform3D = new Transform3D();
      
      alternativa3d var inverseTransform:Transform3D = new Transform3D();
      
      alternativa3d var transformChanged:Boolean = true;
      
      alternativa3d var cameraToLocalTransform:Transform3D = new Transform3D();
      
      alternativa3d var localToCameraTransform:Transform3D = new Transform3D();
      
      alternativa3d var localToGlobalTransform:Transform3D = new Transform3D();
      
      alternativa3d var globalToLocalTransform:Transform3D = new Transform3D();
      
      alternativa3d var localToLightTransform:Transform3D = new Transform3D();
      
      alternativa3d var lightToLocalTransform:Transform3D = new Transform3D();
      
      alternativa3d var culling:int;
      
      alternativa3d var listening:Boolean;
      
      alternativa3d var mouseHandlingType:uint = 0;
      
      alternativa3d var distance:Number;
      
      alternativa3d var bubbleListeners:Object;
      
      alternativa3d var captureListeners:Object;
      
      alternativa3d var transformProcedure:Procedure;
      
      alternativa3d var deltaTransformProcedure:Procedure;
      
      public function Object3D()
      {
         super();
      }
      
      public function get x() : Number
      {
         return this.alternativa3d::_x;
      }
      
      public function set x(param1:Number) : void
      {
         if(this.alternativa3d::_x != param1)
         {
            this.alternativa3d::_x = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get y() : Number
      {
         return this.alternativa3d::_y;
      }
      
      public function set y(param1:Number) : void
      {
         if(this.alternativa3d::_y != param1)
         {
            this.alternativa3d::_y = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get z() : Number
      {
         return this.alternativa3d::_z;
      }
      
      public function set z(param1:Number) : void
      {
         if(this.alternativa3d::_z != param1)
         {
            this.alternativa3d::_z = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get rotationX() : Number
      {
         return this.alternativa3d::_rotationX;
      }
      
      public function set rotationX(param1:Number) : void
      {
         if(this.alternativa3d::_rotationX != param1)
         {
            this.alternativa3d::_rotationX = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get rotationY() : Number
      {
         return this.alternativa3d::_rotationY;
      }
      
      public function set rotationY(param1:Number) : void
      {
         if(this.alternativa3d::_rotationY != param1)
         {
            this.alternativa3d::_rotationY = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get rotationZ() : Number
      {
         return this.alternativa3d::_rotationZ;
      }
      
      public function set rotationZ(param1:Number) : void
      {
         if(this.alternativa3d::_rotationZ != param1)
         {
            this.alternativa3d::_rotationZ = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get scaleX() : Number
      {
         return this.alternativa3d::_scaleX;
      }
      
      public function set scaleX(param1:Number) : void
      {
         if(this.alternativa3d::_scaleX != param1)
         {
            this.alternativa3d::_scaleX = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get scaleY() : Number
      {
         return this.alternativa3d::_scaleY;
      }
      
      public function set scaleY(param1:Number) : void
      {
         if(this.alternativa3d::_scaleY != param1)
         {
            this.alternativa3d::_scaleY = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get scaleZ() : Number
      {
         return this.alternativa3d::_scaleZ;
      }
      
      public function set scaleZ(param1:Number) : void
      {
         if(this.alternativa3d::_scaleZ != param1)
         {
            this.alternativa3d::_scaleZ = param1;
            this.alternativa3d::transformChanged = true;
         }
      }
      
      public function get matrix() : Matrix3D
      {
         if(this.alternativa3d::transformChanged)
         {
            this.alternativa3d::composeTransforms();
         }
         return new Matrix3D(Vector.<Number>([this.alternativa3d::transform.a,this.alternativa3d::transform.e,this.alternativa3d::transform.i,0,this.alternativa3d::transform.b,this.alternativa3d::transform.f,this.alternativa3d::transform.j,0,this.alternativa3d::transform.c,this.alternativa3d::transform.g,this.alternativa3d::transform.k,0,this.alternativa3d::transform.d,this.alternativa3d::transform.h,this.alternativa3d::transform.l,1]));
      }
      
      public function set matrix(param1:Matrix3D) : void
      {
         var _loc2_:Vector.<Vector3D> = param1.decompose();
         var _loc3_:Vector3D = _loc2_[0];
         var _loc4_:Vector3D = _loc2_[1];
         var _loc5_:Vector3D = _loc2_[2];
         this.alternativa3d::_x = _loc3_.x;
         this.alternativa3d::_y = _loc3_.y;
         this.alternativa3d::_z = _loc3_.z;
         this.alternativa3d::_rotationX = _loc4_.x;
         this.alternativa3d::_rotationY = _loc4_.y;
         this.alternativa3d::_rotationZ = _loc4_.z;
         this.alternativa3d::_scaleX = _loc5_.x;
         this.alternativa3d::_scaleY = _loc5_.y;
         this.alternativa3d::_scaleZ = _loc5_.z;
         this.alternativa3d::transformChanged = true;
      }
      
      public function get useHandCursor() : Boolean
      {
         return (this.alternativa3d::mouseHandlingType & USE_HAND_CURSOR_BIT) != 0;
      }
      
      public function set useHandCursor(param1:Boolean) : void
      {
         if(param1)
         {
            this.alternativa3d::mouseHandlingType |= USE_HAND_CURSOR_BIT;
         }
         else
         {
            this.alternativa3d::mouseHandlingType &= ~USE_HAND_CURSOR_BIT;
         }
      }
      
      public function intersectRay(param1:Vector3D, param2:Vector3D) : RayIntersectionData
      {
         return this.alternativa3d::intersectRayChildren(param1,param2);
      }
      
      alternativa3d function intersectRayChildren(param1:Vector3D, param2:Vector3D) : RayIntersectionData
      {
         var _loc5_:Vector3D = null;
         var _loc6_:Vector3D = null;
         var _loc8_:RayIntersectionData = null;
         var _loc3_:Number = 1e+22;
         var _loc4_:RayIntersectionData = null;
         var _loc7_:Object3D = this.alternativa3d::childrenList;
         while(_loc7_ != null)
         {
            if(_loc7_.alternativa3d::transformChanged)
            {
               _loc7_.alternativa3d::composeTransforms();
            }
            if(_loc5_ == null)
            {
               _loc5_ = new Vector3D();
               _loc6_ = new Vector3D();
            }
            _loc5_.x = _loc7_.alternativa3d::inverseTransform.a * param1.x + _loc7_.alternativa3d::inverseTransform.b * param1.y + _loc7_.alternativa3d::inverseTransform.c * param1.z + _loc7_.alternativa3d::inverseTransform.d;
            _loc5_.y = _loc7_.alternativa3d::inverseTransform.e * param1.x + _loc7_.alternativa3d::inverseTransform.f * param1.y + _loc7_.alternativa3d::inverseTransform.g * param1.z + _loc7_.alternativa3d::inverseTransform.h;
            _loc5_.z = _loc7_.alternativa3d::inverseTransform.i * param1.x + _loc7_.alternativa3d::inverseTransform.j * param1.y + _loc7_.alternativa3d::inverseTransform.k * param1.z + _loc7_.alternativa3d::inverseTransform.l;
            _loc6_.x = _loc7_.alternativa3d::inverseTransform.a * param2.x + _loc7_.alternativa3d::inverseTransform.b * param2.y + _loc7_.alternativa3d::inverseTransform.c * param2.z;
            _loc6_.y = _loc7_.alternativa3d::inverseTransform.e * param2.x + _loc7_.alternativa3d::inverseTransform.f * param2.y + _loc7_.alternativa3d::inverseTransform.g * param2.z;
            _loc6_.z = _loc7_.alternativa3d::inverseTransform.i * param2.x + _loc7_.alternativa3d::inverseTransform.j * param2.y + _loc7_.alternativa3d::inverseTransform.k * param2.z;
            _loc8_ = _loc7_.intersectRay(_loc5_,_loc6_);
            if(_loc8_ != null && _loc8_.time < _loc3_)
            {
               _loc4_ = _loc8_;
               _loc3_ = _loc8_.time;
            }
            _loc7_ = _loc7_.alternativa3d::next;
         }
         return _loc4_;
      }
      
      public function get concatenatedMatrix() : Matrix3D
      {
         if(this.alternativa3d::transformChanged)
         {
            this.alternativa3d::composeTransforms();
         }
         alternativa3d::trm.copy(this.alternativa3d::transform);
         var _loc1_:Object3D = this;
         while(_loc1_.parent != null)
         {
            _loc1_ = _loc1_.parent;
            if(_loc1_.alternativa3d::transformChanged)
            {
               _loc1_.alternativa3d::composeTransforms();
            }
            alternativa3d::trm.append(_loc1_.alternativa3d::transform);
         }
         return new Matrix3D(Vector.<Number>([alternativa3d::trm.a,alternativa3d::trm.e,alternativa3d::trm.i,0,alternativa3d::trm.b,alternativa3d::trm.f,alternativa3d::trm.j,0,alternativa3d::trm.c,alternativa3d::trm.g,alternativa3d::trm.k,0,alternativa3d::trm.d,alternativa3d::trm.h,alternativa3d::trm.l,1]));
      }
      
      public function localToGlobal(param1:Vector3D, param2:Vector3D = null) : Vector3D
      {
         if(this.alternativa3d::transformChanged)
         {
            this.alternativa3d::composeTransforms();
         }
         alternativa3d::trm.copy(this.alternativa3d::transform);
         var _loc3_:Object3D = this;
         while(_loc3_.parent != null)
         {
            _loc3_ = _loc3_.parent;
            if(_loc3_.alternativa3d::transformChanged)
            {
               _loc3_.alternativa3d::composeTransforms();
            }
            alternativa3d::trm.append(_loc3_.alternativa3d::transform);
         }
         param2 ||= new Vector3D();
         var _loc4_:Number = alternativa3d::trm.a * param1.x + alternativa3d::trm.b * param1.y + alternativa3d::trm.c * param1.z + alternativa3d::trm.d;
         var _loc5_:Number = alternativa3d::trm.e * param1.x + alternativa3d::trm.f * param1.y + alternativa3d::trm.g * param1.z + alternativa3d::trm.h;
         var _loc6_:Number = alternativa3d::trm.i * param1.x + alternativa3d::trm.j * param1.y + alternativa3d::trm.k * param1.z + alternativa3d::trm.l;
         param2.setTo(_loc4_,_loc5_,_loc6_);
         return param2;
      }
      
      public function globalToLocal(param1:Vector3D, param2:Vector3D = null) : Vector3D
      {
         if(this.alternativa3d::transformChanged)
         {
            this.alternativa3d::composeTransforms();
         }
         alternativa3d::trm.copy(this.alternativa3d::inverseTransform);
         var _loc3_:Object3D = this;
         while(_loc3_.parent != null)
         {
            _loc3_ = _loc3_.parent;
            if(_loc3_.alternativa3d::transformChanged)
            {
               _loc3_.alternativa3d::composeTransforms();
            }
            alternativa3d::trm.prepend(_loc3_.alternativa3d::inverseTransform);
         }
         param2 ||= new Vector3D();
         var _loc4_:Number = alternativa3d::trm.a * param1.x + alternativa3d::trm.b * param1.y + alternativa3d::trm.c * param1.z + alternativa3d::trm.d;
         var _loc5_:Number = alternativa3d::trm.e * param1.x + alternativa3d::trm.f * param1.y + alternativa3d::trm.g * param1.z + alternativa3d::trm.h;
         var _loc6_:Number = alternativa3d::trm.i * param1.x + alternativa3d::trm.j * param1.y + alternativa3d::trm.k * param1.z + alternativa3d::trm.l;
         param2.setTo(_loc4_,_loc5_,_loc6_);
         return param2;
      }
      
      alternativa3d function get useLights() : Boolean
      {
         return false;
      }
      
      public function calculateBoundBox() : void
      {
         if(this.boundBox != null)
         {
            this.boundBox.reset();
         }
         else
         {
            this.boundBox = new BoundBox();
         }
         this.alternativa3d::updateBoundBox(this.boundBox,null);
      }
      
      alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         var _loc6_:Object = null;
         if(param2 == null)
         {
            throw new TypeError("Parameter listener must be non-null.");
         }
         if(param3)
         {
            if(this.alternativa3d::captureListeners == null)
            {
               this.alternativa3d::captureListeners = {};
            }
            _loc6_ = this.alternativa3d::captureListeners;
         }
         else
         {
            if(this.alternativa3d::bubbleListeners == null)
            {
               this.alternativa3d::bubbleListeners = {};
            }
            _loc6_ = this.alternativa3d::bubbleListeners;
         }
         var _loc7_:Vector.<Function> = _loc6_[param1];
         if(_loc7_ == null)
         {
            _loc7_ = new Vector.<Function>();
            _loc6_[param1] = _loc7_;
            switch(param1)
            {
               case MouseEvent3D.MOUSE_MOVE:
                  this.alternativa3d::mouseHandlingType |= MOUSE_MOVE_BIT;
                  break;
               case MouseEvent3D.MOUSE_OVER:
                  this.alternativa3d::mouseHandlingType |= MOUSE_OVER_BIT;
                  break;
               case MouseEvent3D.MOUSE_OUT:
                  this.alternativa3d::mouseHandlingType |= MOUSE_OUT_BIT;
                  break;
               case MouseEvent3D.ROLL_OVER:
                  this.alternativa3d::mouseHandlingType |= ROLL_OVER_BIT;
                  break;
               case MouseEvent3D.ROLL_OUT:
                  this.alternativa3d::mouseHandlingType |= ROLL_OUT_BIT;
                  break;
               case MouseEvent3D.MOUSE_DOWN:
                  this.alternativa3d::mouseHandlingType |= MOUSE_DOWN_BIT;
                  break;
               case MouseEvent3D.MOUSE_UP:
                  this.alternativa3d::mouseHandlingType |= MOUSE_UP_BIT;
                  break;
               case MouseEvent3D.CLICK:
                  this.alternativa3d::mouseHandlingType |= CLICK_BIT;
                  break;
               case MouseEvent3D.DOUBLE_CLICK:
                  this.alternativa3d::mouseHandlingType |= DOUBLE_CLICK_BIT;
                  break;
               case MouseEvent3D.MOUSE_WHEEL:
                  this.alternativa3d::mouseHandlingType |= MOUSE_WHEEL_BIT;
                  break;
               case MouseEvent3D.MIDDLE_CLICK:
                  this.alternativa3d::mouseHandlingType |= MIDDLE_CLICK_BIT;
                  break;
               case MouseEvent3D.MIDDLE_MOUSE_DOWN:
                  this.alternativa3d::mouseHandlingType |= MIDDLE_MOUSE_DOWN_BIT;
                  break;
               case MouseEvent3D.MIDDLE_MOUSE_UP:
                  this.alternativa3d::mouseHandlingType |= MIDDLE_MOUSE_UP_BIT;
                  break;
               case MouseEvent3D.RIGHT_CLICK:
                  this.alternativa3d::mouseHandlingType |= RIGHT_CLICK_BIT;
                  break;
               case MouseEvent3D.RIGHT_MOUSE_DOWN:
                  this.alternativa3d::mouseHandlingType |= RIGHT_MOUSE_DOWN_BIT;
                  break;
               case MouseEvent3D.RIGHT_MOUSE_UP:
                  this.alternativa3d::mouseHandlingType |= RIGHT_MOUSE_UP_BIT;
            }
         }
         if(_loc7_.indexOf(param2) < 0)
         {
            _loc7_.push(param2);
         }
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc5_:Vector.<Function> = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:* = undefined;
         if(param2 == null)
         {
            throw new TypeError("Parameter listener must be non-null.");
         }
         var _loc4_:Object = param3 ? this.alternativa3d::captureListeners : this.alternativa3d::bubbleListeners;
         if(_loc4_ != null)
         {
            _loc5_ = _loc4_[param1];
            if(_loc5_ != null)
            {
               _loc6_ = int(_loc5_.indexOf(param2));
               if(_loc6_ >= 0)
               {
                  _loc7_ = int(_loc5_.length);
                  _loc8_ = _loc6_ + 1;
                  while(_loc8_ < _loc7_)
                  {
                     _loc5_[_loc6_] = _loc5_[_loc8_];
                     _loc8_++;
                     _loc6_++;
                  }
                  if(_loc7_ > 1)
                  {
                     _loc5_.length = _loc7_ - 1;
                  }
                  else
                  {
                     if(_loc4_ == this.alternativa3d::captureListeners)
                     {
                        _loc9_ = this.alternativa3d::bubbleListeners == null || this.alternativa3d::bubbleListeners[param1] == null;
                     }
                     else
                     {
                        _loc9_ = this.alternativa3d::captureListeners == null || this.alternativa3d::captureListeners[param1] == null;
                     }
                     if(_loc9_)
                     {
                        switch(param1)
                        {
                           case MouseEvent3D.MOUSE_MOVE:
                              this.alternativa3d::mouseHandlingType &= ~MOUSE_MOVE_BIT;
                              break;
                           case MouseEvent3D.MOUSE_OVER:
                              this.alternativa3d::mouseHandlingType &= ~MOUSE_OVER_BIT;
                              break;
                           case MouseEvent3D.MOUSE_OUT:
                              this.alternativa3d::mouseHandlingType &= ~MOUSE_OUT_BIT;
                              break;
                           case MouseEvent3D.ROLL_OVER:
                              this.alternativa3d::mouseHandlingType &= ~ROLL_OVER_BIT;
                              break;
                           case MouseEvent3D.ROLL_OUT:
                              this.alternativa3d::mouseHandlingType &= ~ROLL_OUT_BIT;
                              break;
                           case MouseEvent3D.MOUSE_DOWN:
                              this.alternativa3d::mouseHandlingType &= ~MOUSE_DOWN_BIT;
                              break;
                           case MouseEvent3D.MOUSE_UP:
                              this.alternativa3d::mouseHandlingType &= ~MOUSE_UP_BIT;
                              break;
                           case MouseEvent3D.CLICK:
                              this.alternativa3d::mouseHandlingType &= ~CLICK_BIT;
                              break;
                           case MouseEvent3D.DOUBLE_CLICK:
                              this.alternativa3d::mouseHandlingType &= ~DOUBLE_CLICK_BIT;
                              break;
                           case MouseEvent3D.MOUSE_WHEEL:
                              this.alternativa3d::mouseHandlingType &= ~MOUSE_WHEEL_BIT;
                              break;
                           case MouseEvent3D.MIDDLE_CLICK:
                              this.alternativa3d::mouseHandlingType &= ~MIDDLE_CLICK_BIT;
                              break;
                           case MouseEvent3D.MIDDLE_MOUSE_DOWN:
                              this.alternativa3d::mouseHandlingType &= ~MIDDLE_MOUSE_DOWN_BIT;
                              break;
                           case MouseEvent3D.MIDDLE_MOUSE_UP:
                              this.alternativa3d::mouseHandlingType &= ~MIDDLE_MOUSE_UP_BIT;
                              break;
                           case MouseEvent3D.RIGHT_CLICK:
                              this.alternativa3d::mouseHandlingType &= ~RIGHT_CLICK_BIT;
                              break;
                           case MouseEvent3D.RIGHT_MOUSE_DOWN:
                              this.alternativa3d::mouseHandlingType &= ~RIGHT_MOUSE_DOWN_BIT;
                              break;
                           case MouseEvent3D.RIGHT_MOUSE_UP:
                              this.alternativa3d::mouseHandlingType &= ~RIGHT_MOUSE_UP_BIT;
                        }
                     }
                     delete _loc4_[param1];
                     var _loc11_:int = 0;
                     var _loc12_:* = _loc4_;
                     for(_loc10_ in _loc12_)
                     {
                     }
                     if(!_loc10_)
                     {
                        if(_loc4_ == this.alternativa3d::captureListeners)
                        {
                           this.alternativa3d::captureListeners = null;
                        }
                        else
                        {
                           this.alternativa3d::bubbleListeners = null;
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.alternativa3d::captureListeners != null && Boolean(this.alternativa3d::captureListeners[param1]) || this.alternativa3d::bubbleListeners != null && Boolean(this.alternativa3d::bubbleListeners[param1]);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         var _loc2_:Object3D = this;
         while(_loc2_ != null)
         {
            if(_loc2_.alternativa3d::captureListeners != null && _loc2_.alternativa3d::captureListeners[param1] || _loc2_.alternativa3d::bubbleListeners != null && _loc2_.alternativa3d::bubbleListeners[param1])
            {
               return true;
            }
            _loc2_ = _loc2_.alternativa3d::_parent;
         }
         return false;
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         var _loc5_:Object3D = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Vector.<Function> = null;
         var _loc10_:Vector.<Function> = null;
         if(param1 == null)
         {
            throw new TypeError("Parameter event must be non-null.");
         }
         var _loc2_:Event3D = param1 as Event3D;
         if(_loc2_ != null)
         {
            _loc2_.alternativa3d::_target = this;
         }
         var _loc3_:Vector.<Object3D> = new Vector.<Object3D>();
         var _loc4_:int = 0;
         _loc5_ = this;
         while(_loc5_ != null)
         {
            _loc3_[_loc4_] = _loc5_;
            _loc4_++;
            _loc5_ = _loc5_.alternativa3d::_parent;
         }
         _loc6_ = _loc4_ - 1;
         while(_loc6_ > 0)
         {
            _loc5_ = _loc3_[_loc6_];
            if(_loc2_ != null)
            {
               _loc2_.alternativa3d::_currentTarget = _loc5_;
               _loc2_.alternativa3d::_eventPhase = EventPhase.CAPTURING_PHASE;
            }
            if(_loc5_.alternativa3d::captureListeners != null)
            {
               _loc9_ = _loc5_.alternativa3d::captureListeners[param1.type];
               if(_loc9_ != null)
               {
                  _loc8_ = int(_loc9_.length);
                  _loc10_ = new Vector.<Function>();
                  _loc7_ = 0;
                  while(_loc7_ < _loc8_)
                  {
                     _loc10_[_loc7_] = _loc9_[_loc7_];
                     _loc7_++;
                  }
                  _loc7_ = 0;
                  while(_loc7_ < _loc8_)
                  {
                     (_loc10_[_loc7_] as Function).call(null,param1);
                     _loc7_++;
                  }
               }
            }
            _loc6_--;
         }
         if(_loc2_ != null)
         {
            _loc2_.alternativa3d::_eventPhase = EventPhase.AT_TARGET;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            _loc5_ = _loc3_[_loc6_];
            if(_loc2_ != null)
            {
               _loc2_.alternativa3d::_currentTarget = _loc5_;
               if(_loc6_ > 0)
               {
                  _loc2_.alternativa3d::_eventPhase = EventPhase.BUBBLING_PHASE;
               }
            }
            if(_loc5_.alternativa3d::bubbleListeners != null)
            {
               _loc9_ = _loc5_.alternativa3d::bubbleListeners[param1.type];
               if(_loc9_ != null)
               {
                  _loc8_ = int(_loc9_.length);
                  _loc10_ = new Vector.<Function>();
                  _loc7_ = 0;
                  while(_loc7_ < _loc8_)
                  {
                     _loc10_[_loc7_] = _loc9_[_loc7_];
                     _loc7_++;
                  }
                  _loc7_ = 0;
                  while(_loc7_ < _loc8_)
                  {
                     (_loc10_[_loc7_] as Function).call(null,param1);
                     _loc7_++;
                  }
               }
            }
            if(!param1.bubbles)
            {
               break;
            }
            _loc6_++;
         }
         return true;
      }
      
      public function get parent() : Object3D
      {
         return this.alternativa3d::_parent;
      }
      
      alternativa3d function removeFromParent() : void
      {
         if(this.alternativa3d::_parent != null)
         {
            this.alternativa3d::_parent.alternativa3d::removeFromList(this);
            this.alternativa3d::_parent = null;
         }
      }
      
      public function addChild(param1:Object3D) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1 == this)
         {
            throw new ArgumentError("An object cannot be added as a child of itself.");
         }
         var _loc2_:Object3D = this.alternativa3d::_parent;
         while(_loc2_ != null)
         {
            if(_loc2_ == param1)
            {
               throw new ArgumentError("An object cannot be added as a child to one of it\'s children (or children\'s children, etc.).");
            }
            _loc2_ = _loc2_.alternativa3d::_parent;
         }
         if(param1.alternativa3d::_parent != this)
         {
            if(param1.alternativa3d::_parent != null)
            {
               param1.alternativa3d::_parent.removeChild(param1);
            }
            this.addToList(param1);
            param1.alternativa3d::_parent = this;
            if(param1.willTrigger(Event3D.ADDED))
            {
               param1.dispatchEvent(new Event3D(Event3D.ADDED,true));
            }
         }
         else
         {
            param1 = this.alternativa3d::removeFromList(param1);
            if(param1 == null)
            {
               throw new ArgumentError("Cannot add child.");
            }
            this.addToList(param1);
         }
         return param1;
      }
      
      public function removeChild(param1:Object3D) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         param1 = this.alternativa3d::removeFromList(param1);
         if(param1 == null)
         {
            throw new ArgumentError("Cannot remove child.");
         }
         if(param1.willTrigger(Event3D.REMOVED))
         {
            param1.dispatchEvent(new Event3D(Event3D.REMOVED,true));
         }
         param1.alternativa3d::_parent = null;
         return param1;
      }
      
      public function addChildAt(param1:Object3D, param2:int) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1 == this)
         {
            throw new ArgumentError("An object cannot be added as a child of itself.");
         }
         if(param2 < 0)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         var _loc3_:Object3D = this.alternativa3d::_parent;
         while(_loc3_ != null)
         {
            if(_loc3_ == param1)
            {
               throw new ArgumentError("An object cannot be added as a child to one of it\'s children (or children\'s children, etc.).");
            }
            _loc3_ = _loc3_.alternativa3d::_parent;
         }
         var _loc4_:Object3D = this.alternativa3d::childrenList;
         var _loc5_:int = 0;
         while(_loc5_ < param2)
         {
            if(_loc4_ == null)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            _loc4_ = _loc4_.alternativa3d::next;
            _loc5_++;
         }
         if(param1.alternativa3d::_parent != this)
         {
            if(param1.alternativa3d::_parent != null)
            {
               param1.alternativa3d::_parent.removeChild(param1);
            }
            this.addToList(param1,_loc4_);
            param1.alternativa3d::_parent = this;
            if(param1.willTrigger(Event3D.ADDED))
            {
               param1.dispatchEvent(new Event3D(Event3D.ADDED,true));
            }
         }
         else
         {
            param1 = this.alternativa3d::removeFromList(param1);
            if(param1 == null)
            {
               throw new ArgumentError("Cannot add child.");
            }
            this.addToList(param1,_loc4_);
         }
         return param1;
      }
      
      public function removeChildAt(param1:int) : Object3D
      {
         if(param1 < 0)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         var _loc2_:Object3D = this.alternativa3d::childrenList;
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            if(_loc2_ == null)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            _loc2_ = _loc2_.alternativa3d::next;
            _loc3_++;
         }
         if(_loc2_ == null)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         this.alternativa3d::removeFromList(_loc2_);
         if(_loc2_.willTrigger(Event3D.REMOVED))
         {
            _loc2_.dispatchEvent(new Event3D(Event3D.REMOVED,true));
         }
         _loc2_.alternativa3d::_parent = null;
         return _loc2_;
      }
      
      public function removeChildren(param1:int = 0, param2:int = 2147483647) : void
      {
         var _loc7_:Object3D = null;
         if(param1 < 0)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         if(param2 < param1)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         var _loc3_:int = 0;
         var _loc4_:Object3D = null;
         var _loc5_:Object3D = this.alternativa3d::childrenList;
         while(_loc3_ < param1)
         {
            if(_loc5_ == null)
            {
               if(param2 < 2147483647)
               {
                  throw new RangeError("The supplied index is out of bounds.");
               }
               return;
            }
            _loc4_ = _loc5_;
            _loc5_ = _loc5_.alternativa3d::next;
            _loc3_++;
         }
         if(_loc5_ == null)
         {
            if(param2 < 2147483647)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            return;
         }
         var _loc6_:Object3D = null;
         if(param2 < 2147483647)
         {
            _loc6_ = _loc5_;
            while(_loc3_ <= param2)
            {
               if(_loc6_ == null)
               {
                  throw new RangeError("The supplied index is out of bounds.");
               }
               _loc6_ = _loc6_.alternativa3d::next;
               _loc3_++;
            }
         }
         if(_loc4_ != null)
         {
            _loc4_.alternativa3d::next = _loc6_;
         }
         else
         {
            this.alternativa3d::childrenList = _loc6_;
         }
         while(_loc5_ != _loc6_)
         {
            _loc7_ = _loc5_.alternativa3d::next;
            _loc5_.alternativa3d::next = null;
            if(_loc5_.willTrigger(Event3D.REMOVED))
            {
               _loc5_.dispatchEvent(new Event3D(Event3D.REMOVED,true));
            }
            _loc5_.alternativa3d::_parent = null;
            _loc5_ = _loc7_;
         }
      }
      
      public function getChildAt(param1:int) : Object3D
      {
         if(param1 < 0)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         var _loc2_:Object3D = this.alternativa3d::childrenList;
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            if(_loc2_ == null)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            _loc2_ = _loc2_.alternativa3d::next;
            _loc3_++;
         }
         if(_loc2_ == null)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         return _loc2_;
      }
      
      public function getChildIndex(param1:Object3D) : int
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         var _loc2_:int = 0;
         var _loc3_:Object3D = this.alternativa3d::childrenList;
         while(_loc3_ != null)
         {
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
            _loc2_++;
            _loc3_ = _loc3_.alternativa3d::next;
         }
         throw new ArgumentError("Cannot get child index.");
      }
      
      public function setChildIndex(param1:Object3D, param2:int) : void
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         if(param2 < 0)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         var _loc3_:Object3D = this.alternativa3d::childrenList;
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            if(_loc3_ == null)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            _loc3_ = _loc3_.alternativa3d::next;
            _loc4_++;
         }
         param1 = this.alternativa3d::removeFromList(param1);
         if(param1 == null)
         {
            throw new ArgumentError("Cannot set child index.");
         }
         this.addToList(param1,_loc3_);
      }
      
      public function swapChildren(param1:Object3D, param2:Object3D) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object3D = null;
         var _loc5_:Object3D = null;
         if(param1 == null || param2 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1.alternativa3d::_parent != this || param2.alternativa3d::_parent != this)
         {
            throw new ArgumentError("The supplied Object3D must be a child of the caller.");
         }
         if(param1 != param2)
         {
            if(param1.alternativa3d::next == param2)
            {
               param2 = this.alternativa3d::removeFromList(param2);
               if(param2 == null)
               {
                  throw new ArgumentError("Cannot swap children.");
               }
               this.addToList(param2,param1);
            }
            else if(param2.alternativa3d::next == param1)
            {
               param1 = this.alternativa3d::removeFromList(param1);
               if(param1 == null)
               {
                  throw new ArgumentError("Cannot swap children.");
               }
               this.addToList(param1,param2);
            }
            else
            {
               _loc3_ = 0;
               _loc4_ = this.alternativa3d::childrenList;
               while(_loc4_ != null)
               {
                  if(_loc4_ == param1)
                  {
                     _loc3_++;
                  }
                  if(_loc4_ == param2)
                  {
                     _loc3_++;
                  }
                  if(_loc3_ == 2)
                  {
                     break;
                  }
                  _loc4_ = _loc4_.alternativa3d::next;
               }
               if(_loc3_ < 2)
               {
                  throw new ArgumentError("Cannot swap children.");
               }
               _loc5_ = param1.alternativa3d::next;
               this.alternativa3d::removeFromList(param1);
               this.addToList(param1,param2);
               this.alternativa3d::removeFromList(param2);
               this.addToList(param2,_loc5_);
            }
         }
      }
      
      public function swapChildrenAt(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object3D = null;
         var _loc5_:Object3D = null;
         var _loc6_:Object3D = null;
         if(param1 < 0 || param2 < 0)
         {
            throw new RangeError("The supplied index is out of bounds.");
         }
         if(param1 != param2)
         {
            _loc4_ = this.alternativa3d::childrenList;
            _loc3_ = 0;
            while(_loc3_ < param1)
            {
               if(_loc4_ == null)
               {
                  throw new RangeError("The supplied index is out of bounds.");
               }
               _loc4_ = _loc4_.alternativa3d::next;
               _loc3_++;
            }
            if(_loc4_ == null)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            _loc5_ = this.alternativa3d::childrenList;
            _loc3_ = 0;
            while(_loc3_ < param2)
            {
               if(_loc5_ == null)
               {
                  throw new RangeError("The supplied index is out of bounds.");
               }
               _loc5_ = _loc5_.alternativa3d::next;
               _loc3_++;
            }
            if(_loc5_ == null)
            {
               throw new RangeError("The supplied index is out of bounds.");
            }
            if(_loc4_ != _loc5_)
            {
               if(_loc4_.alternativa3d::next == _loc5_)
               {
                  this.alternativa3d::removeFromList(_loc5_);
                  this.addToList(_loc5_,_loc4_);
               }
               else if(_loc5_.alternativa3d::next == _loc4_)
               {
                  this.alternativa3d::removeFromList(_loc4_);
                  this.addToList(_loc4_,_loc5_);
               }
               else
               {
                  _loc6_ = _loc4_.alternativa3d::next;
                  this.alternativa3d::removeFromList(_loc4_);
                  this.addToList(_loc4_,_loc5_);
                  this.alternativa3d::removeFromList(_loc5_);
                  this.addToList(_loc5_,_loc6_);
               }
            }
         }
      }
      
      public function getChildByName(param1:String) : Object3D
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter name must be non-null.");
         }
         var _loc2_:Object3D = this.alternativa3d::childrenList;
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
      
      public function contains(param1:Object3D) : Boolean
      {
         if(param1 == null)
         {
            throw new TypeError("Parameter child must be non-null.");
         }
         if(param1 == this)
         {
            return true;
         }
         var _loc2_:Object3D = this.alternativa3d::childrenList;
         while(_loc2_ != null)
         {
            if(_loc2_.contains(param1))
            {
               return true;
            }
            _loc2_ = _loc2_.alternativa3d::next;
         }
         return false;
      }
      
      public function get numChildren() : int
      {
         var _loc1_:int = 0;
         var _loc2_:Object3D = this.alternativa3d::childrenList;
         while(_loc2_ != null)
         {
            _loc1_++;
            _loc2_ = _loc2_.alternativa3d::next;
         }
         return _loc1_;
      }
      
      private function addToList(param1:Object3D, param2:Object3D = null) : void
      {
         var _loc3_:Object3D = null;
         param1.alternativa3d::next = param2;
         if(param2 == this.alternativa3d::childrenList)
         {
            this.alternativa3d::childrenList = param1;
         }
         else
         {
            _loc3_ = this.alternativa3d::childrenList;
            while(_loc3_ != null)
            {
               if(_loc3_.alternativa3d::next == param2)
               {
                  _loc3_.alternativa3d::next = param1;
                  break;
               }
               _loc3_ = _loc3_.alternativa3d::next;
            }
         }
      }
      
      alternativa3d function removeFromList(param1:Object3D) : Object3D
      {
         var _loc2_:Object3D = null;
         var _loc3_:Object3D = this.alternativa3d::childrenList;
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
                  this.alternativa3d::childrenList = _loc3_.alternativa3d::next;
               }
               _loc3_.alternativa3d::next = null;
               return param1;
            }
            _loc2_ = _loc3_;
            _loc3_ = _loc3_.alternativa3d::next;
         }
         return null;
      }
      
      public function getResources(param1:Boolean = false, param2:Class = null) : Vector.<Resource>
      {
         var _loc6_:* = undefined;
         var _loc3_:Vector.<Resource> = new Vector.<Resource>();
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:int = 0;
         this.alternativa3d::fillResources(_loc4_,param1,param2);
         for(_loc6_ in _loc4_)
         {
            var _loc9_:*;
            _loc3_[_loc9_ = _loc5_++] = _loc6_ as Resource;
         }
         return _loc3_;
      }
      
      alternativa3d function fillResources(param1:Dictionary, param2:Boolean = false, param3:Class = null) : void
      {
         var _loc4_:Object3D = null;
         if(param2)
         {
            _loc4_ = this.alternativa3d::childrenList;
            while(_loc4_ != null)
            {
               _loc4_.alternativa3d::fillResources(param1,param2,param3);
               _loc4_ = _loc4_.alternativa3d::next;
            }
         }
      }
      
      alternativa3d function composeTransforms() : void
      {
         var _loc1_:Number = Math.cos(this.alternativa3d::_rotationX);
         var _loc2_:Number = Math.sin(this.alternativa3d::_rotationX);
         var _loc3_:Number = Math.cos(this.alternativa3d::_rotationY);
         var _loc4_:Number = Math.sin(this.alternativa3d::_rotationY);
         var _loc5_:Number = Math.cos(this.alternativa3d::_rotationZ);
         var _loc6_:Number = Math.sin(this.alternativa3d::_rotationZ);
         var _loc7_:Number = _loc5_ * _loc4_;
         var _loc8_:Number = _loc6_ * _loc4_;
         var _loc9_:Number = _loc3_ * this.alternativa3d::_scaleX;
         var _loc10_:Number = _loc2_ * this.alternativa3d::_scaleY;
         var _loc11_:Number = _loc1_ * this.alternativa3d::_scaleY;
         var _loc12_:Number = _loc1_ * this.alternativa3d::_scaleZ;
         var _loc13_:Number = _loc2_ * this.alternativa3d::_scaleZ;
         this.alternativa3d::transform.a = _loc5_ * _loc9_;
         this.alternativa3d::transform.b = _loc7_ * _loc10_ - _loc6_ * _loc11_;
         this.alternativa3d::transform.c = _loc7_ * _loc12_ + _loc6_ * _loc13_;
         this.alternativa3d::transform.d = this.alternativa3d::_x;
         this.alternativa3d::transform.e = _loc6_ * _loc9_;
         this.alternativa3d::transform.f = _loc8_ * _loc10_ + _loc5_ * _loc11_;
         this.alternativa3d::transform.g = _loc8_ * _loc12_ - _loc5_ * _loc13_;
         this.alternativa3d::transform.h = this.alternativa3d::_y;
         this.alternativa3d::transform.i = -_loc4_ * this.alternativa3d::_scaleX;
         this.alternativa3d::transform.j = _loc3_ * _loc10_;
         this.alternativa3d::transform.k = _loc3_ * _loc12_;
         this.alternativa3d::transform.l = this.alternativa3d::_z;
         var _loc14_:Number = _loc2_ * _loc4_;
         _loc9_ = _loc3_ / this.alternativa3d::_scaleX;
         _loc11_ = _loc1_ / this.alternativa3d::_scaleY;
         _loc13_ = -_loc2_ / this.alternativa3d::_scaleZ;
         _loc12_ = _loc1_ / this.alternativa3d::_scaleZ;
         this.alternativa3d::inverseTransform.a = _loc5_ * _loc9_;
         this.alternativa3d::inverseTransform.b = _loc6_ * _loc9_;
         this.alternativa3d::inverseTransform.c = -_loc4_ / this.alternativa3d::_scaleX;
         this.alternativa3d::inverseTransform.d = -this.alternativa3d::inverseTransform.a * this.alternativa3d::_x - this.alternativa3d::inverseTransform.b * this.alternativa3d::_y - this.alternativa3d::inverseTransform.c * this.alternativa3d::_z;
         this.alternativa3d::inverseTransform.e = _loc14_ * _loc5_ / this.alternativa3d::_scaleY - _loc6_ * _loc11_;
         this.alternativa3d::inverseTransform.f = _loc5_ * _loc11_ + _loc14_ * _loc6_ / this.alternativa3d::_scaleY;
         this.alternativa3d::inverseTransform.g = _loc2_ * _loc3_ / this.alternativa3d::_scaleY;
         this.alternativa3d::inverseTransform.h = -this.alternativa3d::inverseTransform.e * this.alternativa3d::_x - this.alternativa3d::inverseTransform.f * this.alternativa3d::_y - this.alternativa3d::inverseTransform.g * this.alternativa3d::_z;
         this.alternativa3d::inverseTransform.i = _loc5_ * _loc4_ * _loc12_ - _loc6_ * _loc13_;
         this.alternativa3d::inverseTransform.j = _loc5_ * _loc13_ + _loc4_ * _loc6_ * _loc12_;
         this.alternativa3d::inverseTransform.k = _loc3_ * _loc12_;
         this.alternativa3d::inverseTransform.l = -this.alternativa3d::inverseTransform.i * this.alternativa3d::_x - this.alternativa3d::inverseTransform.j * this.alternativa3d::_y - this.alternativa3d::inverseTransform.k * this.alternativa3d::_z;
         this.alternativa3d::transformChanged = false;
      }
      
      alternativa3d function calculateVisibility(param1:Camera3D) : void
      {
      }
      
      alternativa3d function calculateChildrenVisibility(param1:Camera3D) : void
      {
         var _loc2_:Object3D = this.alternativa3d::childrenList;
         while(_loc2_ != null)
         {
            if(_loc2_.visible)
            {
               if(_loc2_.alternativa3d::transformChanged)
               {
                  _loc2_.alternativa3d::composeTransforms();
               }
               _loc2_.alternativa3d::cameraToLocalTransform.combine(_loc2_.alternativa3d::inverseTransform,this.alternativa3d::cameraToLocalTransform);
               _loc2_.alternativa3d::localToCameraTransform.combine(this.alternativa3d::localToCameraTransform,_loc2_.alternativa3d::transform);
               param1.alternativa3d::globalMouseHandlingType |= _loc2_.alternativa3d::mouseHandlingType;
               if(_loc2_.boundBox != null)
               {
                  param1.alternativa3d::calculateFrustum(_loc2_.alternativa3d::cameraToLocalTransform);
                  _loc2_.alternativa3d::culling = _loc2_.boundBox.alternativa3d::checkFrustumCulling(param1.alternativa3d::frustum,63);
               }
               else
               {
                  _loc2_.alternativa3d::culling = 63;
               }
               if(_loc2_.alternativa3d::culling >= 0)
               {
                  _loc2_.alternativa3d::calculateVisibility(param1);
               }
               if(_loc2_.alternativa3d::childrenList != null)
               {
                  _loc2_.alternativa3d::calculateChildrenVisibility(param1);
               }
            }
            _loc2_ = _loc2_.alternativa3d::next;
         }
      }
      
      alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
      }
      
      alternativa3d function collectChildrenDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Light3D = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:Object3D = this.alternativa3d::childrenList;
         while(_loc7_ != null)
         {
            if(_loc7_.visible)
            {
               if(_loc7_.alternativa3d::culling >= 0 && (_loc7_.boundBox == null || param1.alternativa3d::occludersLength == 0 || !_loc7_.boundBox.alternativa3d::checkOcclusion(param1.alternativa3d::occluders,param1.alternativa3d::occludersLength,_loc7_.alternativa3d::localToCameraTransform)))
               {
                  if(_loc7_.boundBox != null)
                  {
                     param1.alternativa3d::calculateRays(_loc7_.alternativa3d::cameraToLocalTransform);
                     _loc7_.alternativa3d::listening = _loc7_.boundBox.alternativa3d::checkRays(param1.alternativa3d::origins,param1.alternativa3d::directions,param1.alternativa3d::raysLength);
                  }
                  else
                  {
                     _loc7_.alternativa3d::listening = true;
                  }
                  _loc8_ = int(_loc7_.alternativa3d::_excludedLights.length);
                  if(param3 > 0 && _loc7_.alternativa3d::useLights)
                  {
                     _loc9_ = 0;
                     if(_loc7_.boundBox != null)
                     {
                        _loc5_ = 0;
                        while(_loc5_ < param3)
                        {
                           _loc6_ = param2[_loc5_];
                           _loc10_ = 0;
                           while(_loc10_ < _loc8_ && _loc7_.alternativa3d::_excludedLights[_loc10_] != _loc6_)
                           {
                              _loc10_++;
                           }
                           if(_loc10_ >= _loc8_)
                           {
                              _loc6_.alternativa3d::lightToObjectTransform.combine(_loc7_.alternativa3d::cameraToLocalTransform,_loc6_.alternativa3d::localToCameraTransform);
                              if(_loc6_.boundBox == null || _loc6_.alternativa3d::checkBound(_loc7_))
                              {
                                 param1.alternativa3d::childLights[_loc9_] = _loc6_;
                                 _loc9_++;
                              }
                           }
                           _loc5_++;
                        }
                     }
                     else
                     {
                        _loc5_ = 0;
                        while(_loc5_ < param3)
                        {
                           _loc6_ = param2[_loc5_];
                           _loc10_ = 0;
                           while(_loc10_ < _loc8_ && _loc7_.alternativa3d::_excludedLights[_loc10_] != _loc6_)
                           {
                              _loc10_++;
                           }
                           if(_loc10_ >= _loc8_)
                           {
                              _loc6_.alternativa3d::lightToObjectTransform.combine(_loc7_.alternativa3d::cameraToLocalTransform,_loc6_.alternativa3d::localToCameraTransform);
                              param1.alternativa3d::childLights[_loc9_] = _loc6_;
                              _loc9_++;
                           }
                           _loc5_++;
                        }
                     }
                     _loc7_.alternativa3d::collectDraws(param1,param1.alternativa3d::childLights,_loc9_,param4 && _loc7_.useShadow);
                  }
                  else
                  {
                     _loc7_.alternativa3d::collectDraws(param1,null,0,param4 && _loc7_.useShadow);
                  }
                  if(param1.debug && _loc7_.boundBox != null && Boolean(param1.alternativa3d::checkInDebug(_loc7_) & Debug.BOUNDS))
                  {
                     Debug.alternativa3d::drawBoundBox(param1,_loc7_.boundBox,_loc7_.alternativa3d::localToCameraTransform);
                  }
               }
               if(_loc7_.alternativa3d::childrenList != null)
               {
                  _loc7_.alternativa3d::collectChildrenDraws(param1,param2,param3,param4 && _loc7_.useShadow);
               }
            }
            _loc7_ = _loc7_.alternativa3d::next;
         }
      }
      
      alternativa3d function collectGeometry(param1:EllipsoidCollider, param2:Dictionary) : void
      {
      }
      
      alternativa3d function collectChildrenGeometry(param1:EllipsoidCollider, param2:Dictionary) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:Object3D = this.alternativa3d::childrenList;
         while(_loc3_ != null)
         {
            if(param2 == null || !param2[_loc3_])
            {
               if(_loc3_.alternativa3d::transformChanged)
               {
                  _loc3_.alternativa3d::composeTransforms();
               }
               _loc3_.alternativa3d::globalToLocalTransform.combine(_loc3_.alternativa3d::inverseTransform,this.alternativa3d::globalToLocalTransform);
               _loc4_ = true;
               if(_loc3_.boundBox != null)
               {
                  param1.alternativa3d::calculateSphere(_loc3_.alternativa3d::globalToLocalTransform);
                  _loc4_ = _loc3_.boundBox.alternativa3d::checkSphere(param1.alternativa3d::sphere);
               }
               if(_loc4_)
               {
                  _loc3_.alternativa3d::localToGlobalTransform.combine(this.alternativa3d::localToGlobalTransform,_loc3_.alternativa3d::transform);
                  _loc3_.alternativa3d::collectGeometry(param1,param2);
               }
               if(_loc3_.alternativa3d::childrenList != null)
               {
                  _loc3_.alternativa3d::collectChildrenGeometry(param1,param2);
               }
            }
            _loc3_ = _loc3_.alternativa3d::next;
         }
      }
      
      alternativa3d function setTransformConstants(param1:DrawUnit, param2:Surface, param3:Linker, param4:Camera3D) : void
      {
      }
      
      public function excludeLight(param1:Light3D, param2:Boolean = false) : void
      {
         var _loc3_:Object3D = null;
         if(this.alternativa3d::_excludedLights.indexOf(param1) < 0)
         {
            this.alternativa3d::_excludedLights.push(param1);
         }
         if(param2)
         {
            _loc3_ = this.alternativa3d::childrenList;
            while(_loc3_ != null)
            {
               _loc3_.excludeLight(param1,true);
               _loc3_ = _loc3_.alternativa3d::next;
            }
         }
      }
      
      public function get excludedLights() : Vector.<Light3D>
      {
         return this.alternativa3d::_excludedLights.slice();
      }
      
      public function clearExcludedLights(param1:Boolean = false) : void
      {
         var _loc2_:Object3D = null;
         this.alternativa3d::_excludedLights.length = 0;
         if(param1)
         {
            _loc2_ = this.alternativa3d::childrenList;
            while(_loc2_ != null)
            {
               _loc2_.clearExcludedLights(true);
               _loc2_ = _loc2_.alternativa3d::next;
            }
         }
      }
      
      public function clone() : Object3D
      {
         var _loc1_:Object3D = new Object3D();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      protected function clonePropertiesFrom(param1:Object3D) : void
      {
         var _loc3_:Object3D = null;
         var _loc4_:Object3D = null;
         this.userData = param1.userData;
         this.name = param1.name;
         this.visible = param1.visible;
         this.mouseEnabled = param1.mouseEnabled;
         this.mouseChildren = param1.mouseChildren;
         this.doubleClickEnabled = param1.doubleClickEnabled;
         this.useHandCursor = param1.useHandCursor;
         this.boundBox = param1.boundBox ? param1.boundBox.clone() : null;
         this.alternativa3d::_x = param1.alternativa3d::_x;
         this.alternativa3d::_y = param1.alternativa3d::_y;
         this.alternativa3d::_z = param1.alternativa3d::_z;
         this.alternativa3d::_rotationX = param1.alternativa3d::_rotationX;
         this.alternativa3d::_rotationY = param1.alternativa3d::_rotationY;
         this.alternativa3d::_rotationZ = param1.alternativa3d::_rotationZ;
         this.alternativa3d::_scaleX = param1.alternativa3d::_scaleX;
         this.alternativa3d::_scaleY = param1.alternativa3d::_scaleY;
         this.alternativa3d::_scaleZ = param1.alternativa3d::_scaleZ;
         var _loc2_:Object3D = param1.alternativa3d::childrenList;
         while(_loc2_ != null)
         {
            _loc4_ = _loc2_.clone();
            if(this.alternativa3d::childrenList != null)
            {
               _loc3_.alternativa3d::next = _loc4_;
            }
            else
            {
               this.alternativa3d::childrenList = _loc4_;
            }
            _loc3_ = _loc4_;
            _loc4_.alternativa3d::_parent = this;
            _loc2_ = _loc2_.alternativa3d::next;
         }
      }
      
      public function toString() : String
      {
         var _loc1_:String = getQualifiedClassName(this);
         var _loc2_:int = int(_loc1_.indexOf("::"));
         return "[" + (_loc2_ < 0 ? _loc1_ : _loc1_.substr(_loc2_ + 2)) + " " + this.name + "]";
      }
   }
}

