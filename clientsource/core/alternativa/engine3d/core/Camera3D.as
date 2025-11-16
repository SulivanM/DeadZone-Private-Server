package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage3D;
   import flash.display.StageAlign;
   import flash.display3D.Context3D;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   import flash.utils.getTimer;
   
   use namespace alternativa3d;
   
   public class Camera3D extends Object3D
   {
      
      alternativa3d static var context3DPropertiesPool:Dictionary = new Dictionary(true);
      
      private static const stack:Vector.<int> = new Vector.<int>();
      
      public var view:View;
      
      public var fov:Number = 1.5707963267948966;
      
      public var nearClipping:Number;
      
      public var farClipping:Number;
      
      public var orthographic:Boolean = false;
      
      alternativa3d var focalLength:Number;
      
      alternativa3d var m0:Number;
      
      alternativa3d var m5:Number;
      
      alternativa3d var m10:Number;
      
      alternativa3d var m14:Number;
      
      alternativa3d var correctionX:Number;
      
      alternativa3d var correctionY:Number;
      
      alternativa3d var lights:Vector.<Light3D> = new Vector.<Light3D>();
      
      alternativa3d var lightsLength:int = 0;
      
      alternativa3d var ambient:Vector.<Number> = new Vector.<Number>(4);
      
      alternativa3d var childLights:Vector.<Light3D> = new Vector.<Light3D>();
      
      alternativa3d var frustum:CullingPlane;
      
      alternativa3d var origins:Vector.<Vector3D> = new Vector.<Vector3D>();
      
      alternativa3d var directions:Vector.<Vector3D> = new Vector.<Vector3D>();
      
      alternativa3d var raysLength:int = 0;
      
      alternativa3d var globalMouseHandlingType:uint;
      
      alternativa3d var occluders:Vector.<Occluder> = new Vector.<Occluder>();
      
      alternativa3d var occludersLength:int = 0;
      
      alternativa3d var context3D:Context3D;
      
      alternativa3d var context3DProperties:RendererContext3DProperties;
      
      public var renderer:Renderer = new Renderer();
      
      alternativa3d var numDraws:int;
      
      alternativa3d var numTriangles:int;
      
      public var debug:Boolean = false;
      
      private var debugSet:Object = {};
      
      private var _diagram:Sprite = this.createDiagram();
      
      public var fpsUpdatePeriod:int = 10;
      
      public var timerUpdatePeriod:int = 10;
      
      private var fpsTextField:TextField;
      
      private var frameTextField:TextField;
      
      private var memoryTextField:TextField;
      
      private var drawsTextField:TextField;
      
      private var trianglesTextField:TextField;
      
      private var timerTextField:TextField;
      
      private var graph:Bitmap;
      
      private var rect:Rectangle;
      
      private var _diagramAlign:String = "TR";
      
      private var _diagramHorizontalMargin:Number = 2;
      
      private var _diagramVerticalMargin:Number = 2;
      
      private var fpsUpdateCounter:int;
      
      private var previousFrameTime:int;
      
      private var previousPeriodTime:int;
      
      private var maxMemory:int;
      
      private var timerUpdateCounter:int;
      
      private var methodTimeSum:int;
      
      private var methodTimeCount:int;
      
      private var methodTimer:int;
      
      public function Camera3D(param1:Number, param2:Number)
      {
         super();
         this.nearClipping = param1;
         this.farClipping = param2;
         this.alternativa3d::frustum = new CullingPlane();
         this.alternativa3d::frustum.next = new CullingPlane();
         this.alternativa3d::frustum.next.next = new CullingPlane();
         this.alternativa3d::frustum.next.next.next = new CullingPlane();
         this.alternativa3d::frustum.next.next.next.next = new CullingPlane();
         this.alternativa3d::frustum.next.next.next.next.next = new CullingPlane();
      }
      
      public function render(param1:Stage3D) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Light3D = null;
         var _loc5_:Occluder = null;
         var _loc7_:Object3D = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Occluder = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         if(param1 == null)
         {
            throw new TypeError("Parameter stage3D must be non-null.");
         }
         this.alternativa3d::numDraws = 0;
         this.alternativa3d::numTriangles = 0;
         this.alternativa3d::occludersLength = 0;
         this.alternativa3d::lightsLength = 0;
         this.alternativa3d::ambient[0] = 0;
         this.alternativa3d::ambient[1] = 0;
         this.alternativa3d::ambient[2] = 0;
         this.alternativa3d::ambient[3] = 1;
         var _loc6_:Context3D = param1.context3D;
         if(_loc6_ != this.alternativa3d::context3D)
         {
            if(_loc6_ != null)
            {
               this.alternativa3d::context3DProperties = alternativa3d::context3DPropertiesPool[_loc6_];
               if(this.alternativa3d::context3DProperties == null)
               {
                  this.alternativa3d::context3DProperties = new RendererContext3DProperties();
                  this.alternativa3d::context3DProperties.isConstrained = _loc6_.driverInfo.lastIndexOf("(Baseline Constrained)") >= 0;
                  alternativa3d::context3DPropertiesPool[_loc6_] = this.alternativa3d::context3DProperties;
               }
               this.alternativa3d::context3D = _loc6_;
            }
            else
            {
               this.alternativa3d::context3D = null;
               this.alternativa3d::context3DProperties = null;
            }
         }
         if(this.alternativa3d::context3D != null && this.view != null && this.renderer != null && (this.view.stage != null || this.view.alternativa3d::_canvas != null))
         {
            this.renderer.alternativa3d::camera = this;
            this.alternativa3d::calculateProjection(this.view.alternativa3d::_width,this.view.alternativa3d::_height);
            this.view.alternativa3d::configureContext3D(param1,this.alternativa3d::context3D,this);
            if(alternativa3d::transformChanged)
            {
               alternativa3d::composeTransforms();
            }
            alternativa3d::localToGlobalTransform.copy(alternativa3d::transform);
            alternativa3d::globalToLocalTransform.copy(alternativa3d::inverseTransform);
            _loc7_ = this;
            while(_loc7_.parent != null)
            {
               _loc7_ = _loc7_.parent;
               if(_loc7_.alternativa3d::transformChanged)
               {
                  _loc7_.alternativa3d::composeTransforms();
               }
               alternativa3d::localToGlobalTransform.append(_loc7_.alternativa3d::transform);
               alternativa3d::globalToLocalTransform.prepend(_loc7_.alternativa3d::inverseTransform);
            }
            if(_loc7_.visible)
            {
               _loc7_.alternativa3d::cameraToLocalTransform.combine(_loc7_.alternativa3d::inverseTransform,alternativa3d::localToGlobalTransform);
               _loc7_.alternativa3d::localToCameraTransform.combine(alternativa3d::globalToLocalTransform,_loc7_.alternativa3d::transform);
               this.alternativa3d::globalMouseHandlingType = _loc7_.alternativa3d::mouseHandlingType;
               if(_loc7_.boundBox != null)
               {
                  this.alternativa3d::calculateFrustum(_loc7_.alternativa3d::cameraToLocalTransform);
                  _loc7_.alternativa3d::culling = _loc7_.boundBox.alternativa3d::checkFrustumCulling(this.alternativa3d::frustum,63);
               }
               else
               {
                  _loc7_.alternativa3d::culling = 63;
               }
               if(_loc7_.alternativa3d::culling >= 0)
               {
                  _loc7_.alternativa3d::calculateVisibility(this);
               }
               _loc7_.alternativa3d::calculateChildrenVisibility(this);
               _loc2_ = 0;
               while(_loc2_ < this.alternativa3d::occludersLength)
               {
                  _loc5_ = this.alternativa3d::occluders[_loc2_];
                  _loc5_.alternativa3d::localToCameraTransform.calculateInversion(_loc5_.alternativa3d::cameraToLocalTransform);
                  _loc5_.alternativa3d::transformVertices(this.alternativa3d::correctionX,this.alternativa3d::correctionY);
                  _loc5_.alternativa3d::distance = this.orthographic ? Number(_loc5_.alternativa3d::localToCameraTransform.l) : _loc5_.alternativa3d::localToCameraTransform.d * _loc5_.alternativa3d::localToCameraTransform.d + _loc5_.alternativa3d::localToCameraTransform.h * _loc5_.alternativa3d::localToCameraTransform.h + _loc5_.alternativa3d::localToCameraTransform.l * _loc5_.alternativa3d::localToCameraTransform.l;
                  _loc5_.alternativa3d::enabled = true;
                  _loc2_++;
               }
               if(this.alternativa3d::occludersLength > 1)
               {
                  this.sortOccluders();
               }
               _loc2_ = 0;
               while(_loc2_ < this.alternativa3d::occludersLength)
               {
                  _loc5_ = this.alternativa3d::occluders[_loc2_];
                  if(_loc5_.alternativa3d::enabled)
                  {
                     _loc5_.alternativa3d::calculatePlanes(this);
                     if(_loc5_.alternativa3d::planeList != null)
                     {
                        _loc3_ = _loc2_ + 1;
                        while(_loc3_ < this.alternativa3d::occludersLength)
                        {
                           _loc11_ = this.alternativa3d::occluders[_loc3_];
                           if(_loc11_.alternativa3d::enabled && _loc11_ != _loc5_ && _loc11_.alternativa3d::checkOcclusion(_loc5_,this.alternativa3d::correctionX,this.alternativa3d::correctionY))
                           {
                              _loc11_.alternativa3d::enabled = false;
                           }
                           _loc3_++;
                        }
                     }
                     else
                     {
                        _loc5_.alternativa3d::enabled = false;
                     }
                  }
                  _loc5_.alternativa3d::culling = -1;
                  _loc2_++;
               }
               _loc2_ = 0;
               _loc3_ = 0;
               while(_loc2_ < this.alternativa3d::occludersLength)
               {
                  _loc5_ = this.alternativa3d::occluders[_loc2_];
                  if(_loc5_.alternativa3d::enabled)
                  {
                     _loc5_.alternativa3d::collectDraws(this,null,0,false);
                     if(this.debug && _loc5_.boundBox != null && Boolean(this.alternativa3d::checkInDebug(_loc5_) & Debug.BOUNDS))
                     {
                        Debug.alternativa3d::drawBoundBox(this,_loc5_.boundBox,_loc5_.alternativa3d::localToCameraTransform);
                     }
                     this.alternativa3d::occluders[_loc3_] = _loc5_;
                     _loc3_++;
                  }
                  _loc2_++;
               }
               this.alternativa3d::occludersLength = _loc3_;
               this.alternativa3d::occluders.length = _loc3_;
               _loc2_ = 0;
               _loc3_ = 0;
               while(_loc2_ < this.alternativa3d::lightsLength)
               {
                  _loc4_ = this.alternativa3d::lights[_loc2_];
                  _loc4_.alternativa3d::localToCameraTransform.calculateInversion(_loc4_.alternativa3d::cameraToLocalTransform);
                  if(_loc4_.boundBox == null || this.alternativa3d::occludersLength == 0 || !_loc4_.boundBox.alternativa3d::checkOcclusion(this.alternativa3d::occluders,this.alternativa3d::occludersLength,_loc4_.alternativa3d::localToCameraTransform))
                  {
                     _loc4_.alternativa3d::red = (_loc4_.color >> 16 & 0xFF) * _loc4_.intensity / 255;
                     _loc4_.alternativa3d::green = (_loc4_.color >> 8 & 0xFF) * _loc4_.intensity / 255;
                     _loc4_.alternativa3d::blue = (_loc4_.color & 0xFF) * _loc4_.intensity / 255;
                     _loc4_.alternativa3d::collectDraws(this,null,0,false);
                     if(this.debug && _loc4_.boundBox != null && Boolean(this.alternativa3d::checkInDebug(_loc4_) & Debug.BOUNDS))
                     {
                        Debug.alternativa3d::drawBoundBox(this,_loc4_.boundBox,_loc4_.alternativa3d::localToCameraTransform);
                     }
                     if(_loc4_.shadow != null)
                     {
                        _loc4_.shadow.alternativa3d::process(this);
                     }
                     this.alternativa3d::lights[_loc3_] = _loc4_;
                     _loc3_++;
                  }
                  _loc4_.alternativa3d::culling = -1;
                  _loc2_++;
               }
               this.alternativa3d::lightsLength = _loc3_;
               this.alternativa3d::lights.length = _loc3_;
               if(this.alternativa3d::lightsLength > 0)
               {
                  this.sortLights(0,this.alternativa3d::lightsLength - 1);
               }
               this.view.alternativa3d::calculateRays(this,(this.alternativa3d::globalMouseHandlingType & Object3D.alternativa3d::MOUSE_HANDLING_MOVING) != 0,(this.alternativa3d::globalMouseHandlingType & Object3D.alternativa3d::MOUSE_HANDLING_PRESSING) != 0,(this.alternativa3d::globalMouseHandlingType & Object3D.alternativa3d::MOUSE_HANDLING_WHEEL) != 0,(this.alternativa3d::globalMouseHandlingType & Object3D.alternativa3d::MOUSE_HANDLING_MIDDLE_BUTTON) != 0,(this.alternativa3d::globalMouseHandlingType & Object3D.alternativa3d::MOUSE_HANDLING_RIGHT_BUTTON) != 0);
               _loc2_ = int(this.alternativa3d::origins.length);
               while(_loc2_ < this.view.alternativa3d::raysLength)
               {
                  this.alternativa3d::origins[_loc2_] = new Vector3D();
                  this.alternativa3d::directions[_loc2_] = new Vector3D();
                  _loc2_++;
               }
               this.alternativa3d::raysLength = this.view.alternativa3d::raysLength;
               _loc8_ = (this.view.backgroundColor >> 16 & 0xFF) / 255;
               _loc9_ = (this.view.backgroundColor >> 8 & 0xFF) / 255;
               _loc10_ = (this.view.backgroundColor & 0xFF) / 255;
               if(this.view.alternativa3d::_canvas != null)
               {
                  _loc8_ *= this.view.backgroundAlpha;
                  _loc9_ *= this.view.backgroundAlpha;
                  _loc10_ *= this.view.backgroundAlpha;
               }
               this.alternativa3d::context3D.clear(_loc8_,_loc9_,_loc10_,this.view.backgroundAlpha);
               if(_loc7_.alternativa3d::culling >= 0 && (_loc7_.boundBox == null || this.alternativa3d::occludersLength == 0 || !_loc7_.boundBox.alternativa3d::checkOcclusion(this.alternativa3d::occluders,this.alternativa3d::occludersLength,_loc7_.alternativa3d::localToCameraTransform)))
               {
                  if(this.alternativa3d::globalMouseHandlingType > 0 && _loc7_.boundBox != null)
                  {
                     this.alternativa3d::calculateRays(_loc7_.alternativa3d::cameraToLocalTransform);
                     _loc7_.alternativa3d::listening = _loc7_.boundBox.alternativa3d::checkRays(this.alternativa3d::origins,this.alternativa3d::directions,this.alternativa3d::raysLength);
                  }
                  else
                  {
                     _loc7_.alternativa3d::listening = this.alternativa3d::globalMouseHandlingType > 0;
                  }
                  _loc12_ = int(_loc7_.alternativa3d::_excludedLights.length);
                  if(this.alternativa3d::lightsLength > 0 && _loc7_.alternativa3d::useLights)
                  {
                     _loc13_ = 0;
                     if(_loc7_.boundBox != null)
                     {
                        _loc2_ = 0;
                        while(_loc2_ < this.alternativa3d::lightsLength)
                        {
                           _loc4_ = this.alternativa3d::lights[_loc2_];
                           _loc3_ = 0;
                           while(_loc3_ < _loc12_ && _loc7_.alternativa3d::_excludedLights[_loc3_] != _loc4_)
                           {
                              _loc3_++;
                           }
                           if(_loc3_ >= _loc12_)
                           {
                              _loc4_.alternativa3d::lightToObjectTransform.combine(_loc7_.alternativa3d::cameraToLocalTransform,_loc4_.alternativa3d::localToCameraTransform);
                              if(_loc4_.boundBox == null || _loc4_.alternativa3d::checkBound(_loc7_))
                              {
                                 this.alternativa3d::childLights[_loc13_] = _loc4_;
                                 _loc13_++;
                              }
                           }
                           _loc2_++;
                        }
                     }
                     else
                     {
                        _loc2_ = 0;
                        while(_loc2_ < this.alternativa3d::lightsLength)
                        {
                           _loc4_ = this.alternativa3d::lights[_loc2_];
                           _loc3_ = 0;
                           while(_loc3_ < _loc12_ && _loc7_.alternativa3d::_excludedLights[_loc3_] != _loc4_)
                           {
                              _loc3_++;
                           }
                           if(_loc3_ >= _loc12_)
                           {
                              _loc4_.alternativa3d::lightToObjectTransform.combine(_loc7_.alternativa3d::cameraToLocalTransform,_loc4_.alternativa3d::localToCameraTransform);
                              this.alternativa3d::childLights[_loc13_] = _loc4_;
                              _loc13_++;
                           }
                           _loc2_++;
                        }
                     }
                     _loc7_.alternativa3d::collectDraws(this,this.alternativa3d::childLights,_loc13_,_loc7_.useShadow);
                  }
                  else
                  {
                     _loc7_.alternativa3d::collectDraws(this,null,0,_loc7_.useShadow);
                  }
                  if(this.debug && _loc7_.boundBox != null && Boolean(this.alternativa3d::checkInDebug(_loc7_) & Debug.BOUNDS))
                  {
                     Debug.alternativa3d::drawBoundBox(this,_loc7_.boundBox,_loc7_.alternativa3d::localToCameraTransform);
                  }
               }
               _loc7_.alternativa3d::collectChildrenDraws(this,this.alternativa3d::lights,this.alternativa3d::lightsLength,_loc7_.useShadow);
               this.view.alternativa3d::processMouseEvents(this.alternativa3d::context3D,this);
               this.renderer.alternativa3d::render(this.alternativa3d::context3D);
            }
            if(this.view.alternativa3d::_canvas == null)
            {
               this.alternativa3d::context3D.present();
            }
            else
            {
               this.alternativa3d::context3D.drawToBitmapData(this.view.alternativa3d::_canvas);
               this.alternativa3d::context3D.present();
            }
         }
         this.alternativa3d::lights.length = 0;
         this.alternativa3d::childLights.length = 0;
         this.alternativa3d::occluders.length = 0;
      }
      
      public function setPosition(param1:Number, param2:Number, param3:Number) : void
      {
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public function lookAt(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = param1 - this.x;
         var _loc5_:Number = param2 - this.y;
         var _loc6_:Number = param3 - this.z;
         var _loc7_:Number = Math.atan2(_loc6_,Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_));
         rotationX = _loc7_ - 0.5 * Math.PI;
         rotationY = 0;
         rotationZ = -Math.atan2(_loc4_,_loc5_);
      }
      
      private function sortLights(param1:int, param2:int) : void
      {
         var _loc5_:Light3D = null;
         var _loc9_:Light3D = null;
         var _loc3_:int = param1;
         var _loc4_:int = param2;
         var _loc6_:* = param2 + param1 >> 1;
         var _loc7_:Light3D = this.alternativa3d::lights[_loc6_];
         var _loc8_:int = _loc7_.alternativa3d::type;
         while(true)
         {
            _loc5_ = this.alternativa3d::lights[_loc3_];
            if(_loc5_.alternativa3d::type >= _loc8_)
            {
               while(_loc8_ < (_loc9_ = this.alternativa3d::lights[_loc4_]).alternativa3d::type)
               {
                  _loc4_--;
               }
               if(_loc3_ <= _loc4_)
               {
                  var _loc10_:*;
                  this.alternativa3d::lights[_loc10_ = _loc3_++] = _loc9_;
                  var _loc11_:*;
                  this.alternativa3d::lights[_loc11_ = _loc4_--] = _loc5_;
               }
               if(_loc3_ > _loc4_)
               {
                  break;
               }
            }
            else
            {
               _loc3_++;
            }
         }
         if(param1 < _loc4_)
         {
            this.sortLights(param1,_loc4_);
         }
         if(_loc3_ < param2)
         {
            this.sortLights(_loc3_,param2);
         }
      }
      
      public function projectGlobal(param1:Vector3D, param2:Vector3D = null) : Vector3D
      {
         if(this.view == null)
         {
            throw new Error("It is necessary to have view set.");
         }
         var _loc3_:Number = this.view.alternativa3d::_width * 0.5;
         var _loc4_:Number = this.view.alternativa3d::_height * 0.5;
         var _loc5_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_) / Math.tan(this.fov * 0.5);
         param2 ||= new Vector3D();
         param2 = globalToLocal(param1,param2);
         param2.x = param2.x * _loc5_ / param2.z + _loc3_;
         param2.y = param2.y * _loc5_ / param2.z + _loc4_;
         return param2;
      }
      
      public function calculateRay(param1:Vector3D, param2:Vector3D, param3:Number, param4:Number) : void
      {
         if(this.view == null)
         {
            throw new Error("It is necessary to have view set.");
         }
         var _loc5_:Number = this.view.alternativa3d::_width * 0.5;
         var _loc6_:Number = this.view.alternativa3d::_height * 0.5;
         var _loc7_:Number = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_) / Math.tan(this.fov * 0.5);
         var _loc8_:Number = param3 - _loc5_;
         var _loc9_:Number = param4 - _loc6_;
         var _loc10_:Number = _loc8_ * this.nearClipping / _loc7_;
         var _loc11_:Number = _loc9_ * this.nearClipping / _loc7_;
         var _loc12_:Number = this.nearClipping;
         if(alternativa3d::transformChanged)
         {
            alternativa3d::composeTransforms();
         }
         alternativa3d::trm.copy(alternativa3d::transform);
         var _loc13_:Object3D = this;
         while(_loc13_.parent != null)
         {
            _loc13_ = _loc13_.parent;
            if(_loc13_.alternativa3d::transformChanged)
            {
               _loc13_.alternativa3d::composeTransforms();
            }
            alternativa3d::trm.append(_loc13_.alternativa3d::transform);
         }
         param1.x = alternativa3d::trm.a * _loc10_ + alternativa3d::trm.b * _loc11_ + alternativa3d::trm.c * _loc12_ + alternativa3d::trm.d;
         param1.y = alternativa3d::trm.e * _loc10_ + alternativa3d::trm.f * _loc11_ + alternativa3d::trm.g * _loc12_ + alternativa3d::trm.h;
         param1.z = alternativa3d::trm.i * _loc10_ + alternativa3d::trm.j * _loc11_ + alternativa3d::trm.k * _loc12_ + alternativa3d::trm.l;
         param2.x = alternativa3d::trm.a * _loc8_ + alternativa3d::trm.b * _loc9_ + alternativa3d::trm.c * _loc7_;
         param2.y = alternativa3d::trm.e * _loc8_ + alternativa3d::trm.f * _loc9_ + alternativa3d::trm.g * _loc7_;
         param2.z = alternativa3d::trm.i * _loc8_ + alternativa3d::trm.j * _loc9_ + alternativa3d::trm.k * _loc7_;
         var _loc14_:Number = 1 / Math.sqrt(param2.x * param2.x + param2.y * param2.y + param2.z * param2.z);
         param2.x *= _loc14_;
         param2.y *= _loc14_;
         param2.z *= _loc14_;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Camera3D = new Camera3D(this.nearClipping,this.farClipping);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         super.clonePropertiesFrom(param1);
         var _loc2_:Camera3D = param1 as Camera3D;
         this.fov = _loc2_.fov;
         this.view = _loc2_.view;
         this.nearClipping = _loc2_.nearClipping;
         this.farClipping = _loc2_.farClipping;
         this.orthographic = _loc2_.orthographic;
      }
      
      alternativa3d function calculateProjection(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = param1 * 0.5;
         var _loc4_:Number = param2 * 0.5;
         this.alternativa3d::focalLength = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_) / Math.tan(this.fov * 0.5);
         if(!this.orthographic)
         {
            this.alternativa3d::m0 = this.alternativa3d::focalLength / _loc3_;
            this.alternativa3d::m5 = -this.alternativa3d::focalLength / _loc4_;
            this.alternativa3d::m10 = this.farClipping / (this.farClipping - this.nearClipping);
            this.alternativa3d::m14 = -this.nearClipping * this.alternativa3d::m10;
         }
         else
         {
            this.alternativa3d::m0 = 1 / _loc3_;
            this.alternativa3d::m5 = -1 / _loc4_;
            this.alternativa3d::m10 = 1 / (this.farClipping - this.nearClipping);
            this.alternativa3d::m14 = -this.nearClipping * this.alternativa3d::m10;
         }
         this.alternativa3d::correctionX = _loc3_ / this.alternativa3d::focalLength;
         this.alternativa3d::correctionY = _loc4_ / this.alternativa3d::focalLength;
      }
      
      alternativa3d function calculateFrustum(param1:Transform3D) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc2_:CullingPlane = this.alternativa3d::frustum;
         var _loc3_:CullingPlane = _loc2_.next;
         var _loc4_:CullingPlane = _loc3_.next;
         var _loc5_:CullingPlane = _loc4_.next;
         var _loc6_:CullingPlane = _loc5_.next;
         var _loc7_:CullingPlane = _loc6_.next;
         if(!this.orthographic)
         {
            _loc8_ = param1.a * this.alternativa3d::correctionX;
            _loc9_ = param1.e * this.alternativa3d::correctionX;
            _loc10_ = param1.i * this.alternativa3d::correctionX;
            _loc11_ = param1.b * this.alternativa3d::correctionY;
            _loc12_ = param1.f * this.alternativa3d::correctionY;
            _loc13_ = param1.j * this.alternativa3d::correctionY;
            _loc2_.x = _loc13_ * _loc9_ - _loc12_ * _loc10_;
            _loc2_.y = _loc11_ * _loc10_ - _loc13_ * _loc8_;
            _loc2_.z = _loc12_ * _loc8_ - _loc11_ * _loc9_;
            _loc2_.offset = (param1.d + param1.c * this.nearClipping) * _loc2_.x + (param1.h + param1.g * this.nearClipping) * _loc2_.y + (param1.l + param1.k * this.nearClipping) * _loc2_.z;
            _loc3_.x = -_loc2_.x;
            _loc3_.y = -_loc2_.y;
            _loc3_.z = -_loc2_.z;
            _loc3_.offset = (param1.d + param1.c * this.farClipping) * _loc3_.x + (param1.h + param1.g * this.farClipping) * _loc3_.y + (param1.l + param1.k * this.farClipping) * _loc3_.z;
            _loc14_ = -_loc8_ - _loc11_ + param1.c;
            _loc15_ = -_loc9_ - _loc12_ + param1.g;
            _loc16_ = -_loc10_ - _loc13_ + param1.k;
            _loc17_ = _loc8_ - _loc11_ + param1.c;
            _loc18_ = _loc9_ - _loc12_ + param1.g;
            _loc19_ = _loc10_ - _loc13_ + param1.k;
            _loc6_.x = _loc19_ * _loc15_ - _loc18_ * _loc16_;
            _loc6_.y = _loc17_ * _loc16_ - _loc19_ * _loc14_;
            _loc6_.z = _loc18_ * _loc14_ - _loc17_ * _loc15_;
            _loc6_.offset = param1.d * _loc6_.x + param1.h * _loc6_.y + param1.l * _loc6_.z;
            _loc14_ = _loc17_;
            _loc15_ = _loc18_;
            _loc16_ = _loc19_;
            _loc17_ = _loc8_ + _loc11_ + param1.c;
            _loc18_ = _loc9_ + _loc12_ + param1.g;
            _loc19_ = _loc10_ + _loc13_ + param1.k;
            _loc5_.x = _loc19_ * _loc15_ - _loc18_ * _loc16_;
            _loc5_.y = _loc17_ * _loc16_ - _loc19_ * _loc14_;
            _loc5_.z = _loc18_ * _loc14_ - _loc17_ * _loc15_;
            _loc5_.offset = param1.d * _loc5_.x + param1.h * _loc5_.y + param1.l * _loc5_.z;
            _loc14_ = _loc17_;
            _loc15_ = _loc18_;
            _loc16_ = _loc19_;
            _loc17_ = -_loc8_ + _loc11_ + param1.c;
            _loc18_ = -_loc9_ + _loc12_ + param1.g;
            _loc19_ = -_loc10_ + _loc13_ + param1.k;
            _loc7_.x = _loc19_ * _loc15_ - _loc18_ * _loc16_;
            _loc7_.y = _loc17_ * _loc16_ - _loc19_ * _loc14_;
            _loc7_.z = _loc18_ * _loc14_ - _loc17_ * _loc15_;
            _loc7_.offset = param1.d * _loc7_.x + param1.h * _loc7_.y + param1.l * _loc7_.z;
            _loc14_ = _loc17_;
            _loc15_ = _loc18_;
            _loc16_ = _loc19_;
            _loc17_ = -_loc8_ - _loc11_ + param1.c;
            _loc18_ = -_loc9_ - _loc12_ + param1.g;
            _loc19_ = -_loc10_ - _loc13_ + param1.k;
            _loc4_.x = _loc19_ * _loc15_ - _loc18_ * _loc16_;
            _loc4_.y = _loc17_ * _loc16_ - _loc19_ * _loc14_;
            _loc4_.z = _loc18_ * _loc14_ - _loc17_ * _loc15_;
            _loc4_.offset = param1.d * _loc4_.x + param1.h * _loc4_.y + param1.l * _loc4_.z;
         }
         else
         {
            _loc20_ = this.view.alternativa3d::_width * 0.5;
            _loc21_ = this.view.alternativa3d::_height * 0.5;
            _loc2_.x = param1.j * param1.e - param1.f * param1.i;
            _loc2_.y = param1.b * param1.i - param1.j * param1.a;
            _loc2_.z = param1.f * param1.a - param1.b * param1.e;
            _loc2_.offset = (param1.d + param1.c * this.nearClipping) * _loc2_.x + (param1.h + param1.g * this.nearClipping) * _loc2_.y + (param1.l + param1.k * this.nearClipping) * _loc2_.z;
            _loc3_.x = -_loc2_.x;
            _loc3_.y = -_loc2_.y;
            _loc3_.z = -_loc2_.z;
            _loc3_.offset = (param1.d + param1.c * this.farClipping) * _loc3_.x + (param1.h + param1.g * this.farClipping) * _loc3_.y + (param1.l + param1.k * this.farClipping) * _loc3_.z;
            _loc6_.x = param1.i * param1.g - param1.e * param1.k;
            _loc6_.y = param1.a * param1.k - param1.i * param1.c;
            _loc6_.z = param1.e * param1.c - param1.a * param1.g;
            _loc6_.offset = (param1.d - param1.b * _loc21_) * _loc6_.x + (param1.h - param1.f * _loc21_) * _loc6_.y + (param1.l - param1.j * _loc21_) * _loc6_.z;
            _loc7_.x = -_loc6_.x;
            _loc7_.y = -_loc6_.y;
            _loc7_.z = -_loc6_.z;
            _loc7_.offset = (param1.d + param1.b * _loc21_) * _loc7_.x + (param1.h + param1.f * _loc21_) * _loc7_.y + (param1.l + param1.j * _loc21_) * _loc7_.z;
            _loc4_.x = param1.k * param1.f - param1.g * param1.j;
            _loc4_.y = param1.c * param1.j - param1.k * param1.b;
            _loc4_.z = param1.g * param1.b - param1.c * param1.f;
            _loc4_.offset = (param1.d - param1.a * _loc20_) * _loc4_.x + (param1.h - param1.e * _loc20_) * _loc4_.y + (param1.l - param1.i * _loc20_) * _loc4_.z;
            _loc5_.x = -_loc4_.x;
            _loc5_.y = -_loc4_.y;
            _loc5_.z = -_loc4_.z;
            _loc5_.offset = (param1.d + param1.a * _loc20_) * _loc5_.x + (param1.h + param1.e * _loc20_) * _loc5_.y + (param1.l + param1.i * _loc20_) * _loc5_.z;
         }
      }
      
      alternativa3d function calculateRays(param1:Transform3D) : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Vector3D = null;
         var _loc5_:Vector3D = null;
         var _loc6_:Vector3D = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.alternativa3d::raysLength)
         {
            _loc3_ = this.view.alternativa3d::raysOrigins[_loc2_];
            _loc4_ = this.view.alternativa3d::raysDirections[_loc2_];
            _loc5_ = this.alternativa3d::origins[_loc2_];
            _loc6_ = this.alternativa3d::directions[_loc2_];
            _loc5_.x = param1.a * _loc3_.x + param1.b * _loc3_.y + param1.c * _loc3_.z + param1.d;
            _loc5_.y = param1.e * _loc3_.x + param1.f * _loc3_.y + param1.g * _loc3_.z + param1.h;
            _loc5_.z = param1.i * _loc3_.x + param1.j * _loc3_.y + param1.k * _loc3_.z + param1.l;
            _loc6_.x = param1.a * _loc4_.x + param1.b * _loc4_.y + param1.c * _loc4_.z;
            _loc6_.y = param1.e * _loc4_.x + param1.f * _loc4_.y + param1.g * _loc4_.z;
            _loc6_.z = param1.i * _loc4_.x + param1.j * _loc4_.y + param1.k * _loc4_.z;
            _loc2_++;
         }
      }
      
      private function sortOccluders() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Occluder = null;
         var _loc7_:Number = NaN;
         var _loc8_:Occluder = null;
         var _loc9_:Occluder = null;
         stack[0] = 0;
         stack[1] = this.alternativa3d::occludersLength - 1;
         var _loc1_:int = 2;
         while(_loc1_ > 0)
         {
            _loc1_--;
            _loc2_ = stack[_loc1_];
            _loc3_ = _loc2_;
            _loc1_--;
            _loc5_ = _loc4_ = stack[_loc1_];
            _loc6_ = this.alternativa3d::occluders[_loc2_ + _loc4_ >> 1];
            _loc7_ = Number(_loc6_.alternativa3d::distance);
            while(_loc5_ <= _loc3_)
            {
               _loc8_ = this.alternativa3d::occluders[_loc5_];
               while(_loc8_.alternativa3d::distance < _loc7_)
               {
                  _loc5_++;
                  _loc8_ = this.alternativa3d::occluders[_loc5_];
               }
               _loc9_ = this.alternativa3d::occluders[_loc3_];
               while(_loc9_.alternativa3d::distance > _loc7_)
               {
                  _loc3_--;
                  _loc9_ = this.alternativa3d::occluders[_loc3_];
               }
               if(_loc5_ <= _loc3_)
               {
                  this.alternativa3d::occluders[_loc5_] = _loc9_;
                  this.alternativa3d::occluders[_loc3_] = _loc8_;
                  _loc5_++;
                  _loc3_--;
               }
            }
            if(_loc4_ < _loc3_)
            {
               stack[_loc1_] = _loc4_;
               _loc1_++;
               stack[_loc1_] = _loc3_;
               _loc1_++;
            }
            if(_loc5_ < _loc2_)
            {
               stack[_loc1_] = _loc5_;
               _loc1_++;
               stack[_loc1_] = _loc2_;
               _loc1_++;
            }
         }
      }
      
      public function addToDebug(param1:int, param2:*) : void
      {
         if(!this.debugSet[param1])
         {
            this.debugSet[param1] = new Dictionary();
         }
         this.debugSet[param1][param2] = true;
      }
      
      public function removeFromDebug(param1:int, param2:*) : void
      {
         var _loc3_:* = undefined;
         if(this.debugSet[param1])
         {
            delete this.debugSet[param1][param2];
            var _loc4_:int = 0;
            var _loc5_:* = this.debugSet[param1];
            for(_loc3_ in _loc5_)
            {
            }
            if(!_loc3_)
            {
               delete this.debugSet[param1];
            }
         }
      }
      
      alternativa3d function checkInDebug(param1:Object3D) : int
      {
         var _loc4_:Class = null;
         var _loc2_:* = 0;
         var _loc3_:* = 1;
         while(_loc3_ <= 512)
         {
            if(this.debugSet[_loc3_])
            {
               if(Boolean(this.debugSet[_loc3_][Object3D]) || Boolean(this.debugSet[_loc3_][param1]))
               {
                  _loc2_ |= _loc3_;
               }
               else
               {
                  _loc4_ = getDefinitionByName(getQualifiedClassName(param1)) as Class;
                  while(_loc4_ != Object3D)
                  {
                     if(this.debugSet[_loc3_][_loc4_])
                     {
                        _loc2_ |= _loc3_;
                        break;
                     }
                     _loc4_ = Class(getDefinitionByName(getQualifiedSuperclassName(_loc4_)));
                  }
               }
            }
            _loc3_ <<= 1;
         }
         return _loc2_;
      }
      
      public function startTimer() : void
      {
         this.methodTimer = getTimer();
      }
      
      public function stopTimer() : void
      {
         this.methodTimeSum += getTimer() - this.methodTimer;
         ++this.methodTimeCount;
      }
      
      public function get diagram() : DisplayObject
      {
         return this._diagram;
      }
      
      public function get diagramAlign() : String
      {
         return this._diagramAlign;
      }
      
      public function set diagramAlign(param1:String) : void
      {
         this._diagramAlign = param1;
         this.resizeDiagram();
      }
      
      public function get diagramHorizontalMargin() : Number
      {
         return this._diagramHorizontalMargin;
      }
      
      public function set diagramHorizontalMargin(param1:Number) : void
      {
         this._diagramHorizontalMargin = param1;
         this.resizeDiagram();
      }
      
      public function get diagramVerticalMargin() : Number
      {
         return this._diagramVerticalMargin;
      }
      
      public function set diagramVerticalMargin(param1:Number) : void
      {
         this._diagramVerticalMargin = param1;
         this.resizeDiagram();
      }
      
      private function createDiagram() : Sprite
      {
         var diagram:Sprite = null;
         diagram = new Sprite();
         diagram.mouseEnabled = false;
         diagram.mouseChildren = false;
         this.fpsTextField = new TextField();
         this.fpsTextField.defaultTextFormat = new TextFormat("Tahoma",10,13421772);
         this.fpsTextField.autoSize = TextFieldAutoSize.LEFT;
         this.fpsTextField.text = "FPS:";
         this.fpsTextField.selectable = false;
         this.fpsTextField.x = -3;
         this.fpsTextField.y = -5;
         diagram.addChild(this.fpsTextField);
         this.frameTextField = new TextField();
         this.frameTextField.defaultTextFormat = new TextFormat("Tahoma",10,13421772);
         this.frameTextField.autoSize = TextFieldAutoSize.LEFT;
         this.frameTextField.text = "TME:";
         this.frameTextField.selectable = false;
         this.frameTextField.x = -3;
         this.frameTextField.y = 4;
         diagram.addChild(this.frameTextField);
         this.timerTextField = new TextField();
         this.timerTextField.defaultTextFormat = new TextFormat("Tahoma",10,26367);
         this.timerTextField.autoSize = TextFieldAutoSize.LEFT;
         this.timerTextField.text = "MS:";
         this.timerTextField.selectable = false;
         this.timerTextField.x = -3;
         this.timerTextField.y = 13;
         diagram.addChild(this.timerTextField);
         this.memoryTextField = new TextField();
         this.memoryTextField.defaultTextFormat = new TextFormat("Tahoma",10,13421568);
         this.memoryTextField.autoSize = TextFieldAutoSize.LEFT;
         this.memoryTextField.text = "MEM:";
         this.memoryTextField.selectable = false;
         this.memoryTextField.x = -3;
         this.memoryTextField.y = 22;
         diagram.addChild(this.memoryTextField);
         this.drawsTextField = new TextField();
         this.drawsTextField.defaultTextFormat = new TextFormat("Tahoma",10,52224);
         this.drawsTextField.autoSize = TextFieldAutoSize.LEFT;
         this.drawsTextField.text = "DRW:";
         this.drawsTextField.selectable = false;
         this.drawsTextField.x = -3;
         this.drawsTextField.y = 31;
         diagram.addChild(this.drawsTextField);
         this.trianglesTextField = new TextField();
         this.trianglesTextField.defaultTextFormat = new TextFormat("Tahoma",10,16724736);
         this.trianglesTextField.autoSize = TextFieldAutoSize.LEFT;
         this.trianglesTextField.text = "TRI:";
         this.trianglesTextField.selectable = false;
         this.trianglesTextField.x = -3;
         this.trianglesTextField.y = 40;
         diagram.addChild(this.trianglesTextField);
         diagram.addEventListener(Event.ADDED_TO_STAGE,function():void
         {
            diagram.removeEventListener(Event.ADDED_TO_STAGE,arguments.callee);
            fpsTextField = new TextField();
            fpsTextField.defaultTextFormat = new TextFormat("Tahoma",10,13421772);
            fpsTextField.autoSize = TextFieldAutoSize.RIGHT;
            fpsTextField.text = Number(diagram.stage.frameRate).toFixed(2);
            fpsTextField.selectable = false;
            fpsTextField.x = -3;
            fpsTextField.y = -5;
            fpsTextField.width = 85;
            diagram.addChild(fpsTextField);
            frameTextField = new TextField();
            frameTextField.defaultTextFormat = new TextFormat("Tahoma",10,13421772);
            frameTextField.autoSize = TextFieldAutoSize.RIGHT;
            frameTextField.text = Number(1000 / diagram.stage.frameRate).toFixed(2);
            frameTextField.selectable = false;
            frameTextField.x = -3;
            frameTextField.y = 4;
            frameTextField.width = 85;
            diagram.addChild(frameTextField);
            timerTextField = new TextField();
            timerTextField.defaultTextFormat = new TextFormat("Tahoma",10,26367);
            timerTextField.autoSize = TextFieldAutoSize.RIGHT;
            timerTextField.text = "";
            timerTextField.selectable = false;
            timerTextField.x = -3;
            timerTextField.y = 13;
            timerTextField.width = 85;
            diagram.addChild(timerTextField);
            memoryTextField = new TextField();
            memoryTextField.defaultTextFormat = new TextFormat("Tahoma",10,13421568);
            memoryTextField.autoSize = TextFieldAutoSize.RIGHT;
            memoryTextField.text = bytesToString(System.totalMemory);
            memoryTextField.selectable = false;
            memoryTextField.x = -3;
            memoryTextField.y = 22;
            memoryTextField.width = 85;
            diagram.addChild(memoryTextField);
            drawsTextField = new TextField();
            drawsTextField.defaultTextFormat = new TextFormat("Tahoma",10,52224);
            drawsTextField.autoSize = TextFieldAutoSize.RIGHT;
            drawsTextField.text = "0";
            drawsTextField.selectable = false;
            drawsTextField.x = -3;
            drawsTextField.y = 31;
            drawsTextField.width = 72;
            diagram.addChild(drawsTextField);
            trianglesTextField = new TextField();
            trianglesTextField.defaultTextFormat = new TextFormat("Tahoma",10,16724736);
            trianglesTextField.autoSize = TextFieldAutoSize.RIGHT;
            trianglesTextField.text = "0";
            trianglesTextField.selectable = false;
            trianglesTextField.x = -3;
            trianglesTextField.y = 40;
            trianglesTextField.width = 72;
            diagram.addChild(trianglesTextField);
            graph = new Bitmap(new BitmapData(80,40,true,553648127));
            rect = new Rectangle(0,0,1,40);
            graph.x = 0;
            graph.y = 54;
            diagram.addChild(graph);
            previousPeriodTime = getTimer();
            previousFrameTime = previousPeriodTime;
            fpsUpdateCounter = 0;
            maxMemory = 0;
            timerUpdateCounter = 0;
            methodTimeSum = 0;
            methodTimeCount = 0;
            diagram.stage.addEventListener(Event.ENTER_FRAME,updateDiagram,false,-1000);
            diagram.stage.addEventListener(Event.RESIZE,resizeDiagram,false,-1000);
            resizeDiagram();
         });
         diagram.addEventListener(Event.REMOVED_FROM_STAGE,function():void
         {
            diagram.removeEventListener(Event.REMOVED_FROM_STAGE,arguments.callee);
            diagram.removeChild(fpsTextField);
            diagram.removeChild(frameTextField);
            diagram.removeChild(memoryTextField);
            diagram.removeChild(drawsTextField);
            diagram.removeChild(trianglesTextField);
            diagram.removeChild(timerTextField);
            diagram.removeChild(graph);
            fpsTextField = null;
            frameTextField = null;
            memoryTextField = null;
            drawsTextField = null;
            trianglesTextField = null;
            timerTextField = null;
            graph.bitmapData.dispose();
            graph = null;
            rect = null;
            diagram.stage.removeEventListener(Event.ENTER_FRAME,updateDiagram);
            diagram.stage.removeEventListener(Event.RESIZE,resizeDiagram);
         });
         return diagram;
      }
      
      private function resizeDiagram(param1:Event = null) : void
      {
         var _loc2_:Point = null;
         if(this._diagram.stage != null)
         {
            _loc2_ = this._diagram.parent.globalToLocal(new Point());
            if(this._diagramAlign == StageAlign.TOP_LEFT || this._diagramAlign == StageAlign.LEFT || this._diagramAlign == StageAlign.BOTTOM_LEFT)
            {
               this._diagram.x = Math.round(_loc2_.x + this._diagramHorizontalMargin);
            }
            if(this._diagramAlign == StageAlign.TOP || this._diagramAlign == StageAlign.BOTTOM)
            {
               this._diagram.x = Math.round(_loc2_.x + this._diagram.stage.stageWidth / 2 - this.graph.width / 2);
            }
            if(this._diagramAlign == StageAlign.TOP_RIGHT || this._diagramAlign == StageAlign.RIGHT || this._diagramAlign == StageAlign.BOTTOM_RIGHT)
            {
               this._diagram.x = Math.round(_loc2_.x + this._diagram.stage.stageWidth - this._diagramHorizontalMargin - this.graph.width);
            }
            if(this._diagramAlign == StageAlign.TOP_LEFT || this._diagramAlign == StageAlign.TOP || this._diagramAlign == StageAlign.TOP_RIGHT)
            {
               this._diagram.y = Math.round(_loc2_.y + this._diagramVerticalMargin);
            }
            if(this._diagramAlign == StageAlign.LEFT || this._diagramAlign == StageAlign.RIGHT)
            {
               this._diagram.y = Math.round(_loc2_.y + this._diagram.stage.stageHeight / 2 - (this.graph.y + this.graph.height) / 2);
            }
            if(this._diagramAlign == StageAlign.BOTTOM_LEFT || this._diagramAlign == StageAlign.BOTTOM || this._diagramAlign == StageAlign.BOTTOM_RIGHT)
            {
               this._diagram.y = Math.round(_loc2_.y + this._diagram.stage.stageHeight - this._diagramVerticalMargin - this.graph.y - this.graph.height);
            }
         }
      }
      
      private function updateDiagram(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:int = getTimer();
         var _loc5_:int = this._diagram.stage.frameRate;
         if(++this.fpsUpdateCounter == this.fpsUpdatePeriod)
         {
            _loc2_ = 1000 * this.fpsUpdatePeriod / (_loc4_ - this.previousPeriodTime);
            if(_loc2_ > _loc5_)
            {
               _loc2_ = _loc5_;
            }
            _loc3_ = _loc2_ * 100 % 100;
            this.fpsTextField.text = int(_loc2_) + "." + (_loc3_ >= 10 ? _loc3_.toString() : (_loc3_ > 0 ? "0" + _loc3_ : "00"));
            _loc2_ = 1000 / _loc2_;
            _loc3_ = _loc2_ * 100 % 100;
            this.frameTextField.text = int(_loc2_) + "." + (_loc3_ >= 10 ? _loc3_.toString() : (_loc3_ > 0 ? "0" + _loc3_ : "00"));
            this.previousPeriodTime = _loc4_;
            this.fpsUpdateCounter = 0;
         }
         _loc2_ = 1000 / (_loc4_ - this.previousFrameTime);
         if(_loc2_ > _loc5_)
         {
            _loc2_ = _loc5_;
         }
         this.graph.bitmapData.scroll(1,0);
         this.graph.bitmapData.fillRect(this.rect,553648127);
         this.graph.bitmapData.setPixel32(0,40 * (1 - _loc2_ / _loc5_),4291611852);
         this.previousFrameTime = _loc4_;
         if(++this.timerUpdateCounter == this.timerUpdatePeriod)
         {
            if(this.methodTimeCount > 0)
            {
               _loc2_ = this.methodTimeSum / this.methodTimeCount;
               _loc3_ = _loc2_ * 100 % 100;
               this.timerTextField.text = int(_loc2_) + "." + (_loc3_ >= 10 ? _loc3_.toString() : (_loc3_ > 0 ? "0" + _loc3_ : "00"));
            }
            else
            {
               this.timerTextField.text = "";
            }
            this.timerUpdateCounter = 0;
            this.methodTimeSum = 0;
            this.methodTimeCount = 0;
         }
         var _loc6_:int = int(System.totalMemory);
         _loc2_ = _loc6_ / 1048576;
         _loc3_ = _loc2_ * 100 % 100;
         this.memoryTextField.text = int(_loc2_) + "." + (_loc3_ >= 10 ? _loc3_.toString() : (_loc3_ > 0 ? "0" + _loc3_ : "00"));
         if(_loc6_ > this.maxMemory)
         {
            this.maxMemory = _loc6_;
         }
         this.graph.bitmapData.setPixel32(0,40 * (1 - _loc6_ / this.maxMemory),4291611648);
         this.drawsTextField.text = this.formatInt(this.alternativa3d::numDraws);
         this.trianglesTextField.text = this.formatInt(this.alternativa3d::numTriangles);
      }
      
      private function formatInt(param1:int) : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(param1 < 1000)
         {
            return "" + param1;
         }
         if(param1 < 1000000)
         {
            _loc2_ = param1 % 1000;
            if(_loc2_ < 10)
            {
               _loc3_ = "00" + _loc2_;
            }
            else if(_loc2_ < 100)
            {
               _loc3_ = "0" + _loc2_;
            }
            else
            {
               _loc3_ = "" + _loc2_;
            }
            return int(param1 / 1000) + " " + _loc3_;
         }
         _loc2_ = param1 % 1000000 / 1000;
         if(_loc2_ < 10)
         {
            _loc3_ = "00" + _loc2_;
         }
         else if(_loc2_ < 100)
         {
            _loc3_ = "0" + _loc2_;
         }
         else
         {
            _loc3_ = "" + _loc2_;
         }
         _loc2_ = param1 % 1000;
         if(_loc2_ < 10)
         {
            _loc3_ += " 00" + _loc2_;
         }
         else if(_loc2_ < 100)
         {
            _loc3_ += " 0" + _loc2_;
         }
         else
         {
            _loc3_ += " " + _loc2_;
         }
         return int(param1 / 1000000) + " " + _loc3_;
      }
      
      private function bytesToString(param1:int) : String
      {
         if(param1 < 1024)
         {
            return param1 + "b";
         }
         if(param1 < 10240)
         {
            return (param1 / 1024).toFixed(2) + "kb";
         }
         if(param1 < 102400)
         {
            return (param1 / 1024).toFixed(1) + "kb";
         }
         if(param1 < 1048576)
         {
            return (param1 >> 10) + "kb";
         }
         if(param1 < 10485760)
         {
            return (param1 / 1048576).toFixed(2);
         }
         if(param1 < 104857600)
         {
            return (param1 / 1048576).toFixed(1);
         }
         return String(param1 >> 20);
      }
   }
}

