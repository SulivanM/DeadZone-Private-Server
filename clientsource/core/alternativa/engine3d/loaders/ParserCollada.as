package alternativa.engine3d.loaders
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.animation.keys.Track;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.loaders.collada.DaeDocument;
   import alternativa.engine3d.loaders.collada.DaeElement;
   import alternativa.engine3d.loaders.collada.DaeGeometry;
   import alternativa.engine3d.loaders.collada.DaeMaterial;
   import alternativa.engine3d.loaders.collada.DaeNode;
   import alternativa.engine3d.loaders.collada.DaeObject;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   use namespace alternativa3d;
   
   public class ParserCollada extends Parser
   {
      
      public var lights:Vector.<Light3D>;
      
      private var queue:Vector.<QueueElement> = new Vector.<QueueElement>();
      
      private const ASYNC_LIMIT:int = 50;
      
      private const ASYNC_TIMEOUT:int = 1;
      
      public function ParserCollada()
      {
         super();
      }
      
      public static function parseAnimation(param1:XML) : AnimationClip
      {
         var _loc2_:DaeDocument = new DaeDocument(param1,0);
         var _loc3_:AnimationClip = new AnimationClip();
         collectAnimation(_loc3_,_loc2_.scene.nodes);
         return _loc3_.numTracks > 0 ? _loc3_ : null;
      }
      
      private static function collectAnimation(param1:AnimationClip, param2:Vector.<DaeNode>) : void
      {
         var _loc5_:DaeNode = null;
         var _loc6_:AnimationClip = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Track = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(param2.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param2[_loc3_];
            _loc6_ = _loc5_.parseAnimation();
            if(_loc6_ != null)
            {
               _loc7_ = 0;
               _loc8_ = _loc6_.numTracks;
               while(_loc7_ < _loc8_)
               {
                  _loc9_ = _loc6_.getTrackAt(_loc7_);
                  param1.addTrack(_loc9_);
                  _loc7_++;
               }
            }
            else
            {
               param1.addTrack(_loc5_.createStaticTransformTrack());
            }
            collectAnimation(param1,_loc5_.nodes);
            _loc3_++;
         }
      }
      
      override public function clean() : void
      {
         super.clean();
         this.lights = null;
      }
      
      override alternativa3d function init() : void
      {
         super.alternativa3d::init();
         this.lights = new Vector.<Light3D>();
      }
      
      public function parse(param1:XML, param2:String = null, param3:Boolean = false) : void
      {
         this.alternativa3d::init();
         var _loc4_:DaeDocument = new DaeDocument(param1,0);
         if(_loc4_.scene != null)
         {
            this.parseNodes(_loc4_.scene.nodes,null,false);
            this.parseMaterials(_loc4_.materials,param2,param3);
         }
      }
      
      public function parseAsync(param1:Function, param2:XML, param3:String = null, param4:Boolean = false) : void
      {
         var _loc6_:DaeGeometry = null;
         this.alternativa3d::init();
         var _loc5_:DaeDocument = new DaeDocument(param2,0);
         if(_loc5_.scene != null)
         {
            this.parseMaterials(_loc5_.materials,param3,param4);
            this.addNodesToQueue(_loc5_.scene.nodes,null,false);
            this.addElementsToQueue(_loc5_.controllers);
            this.addElementsToQueue(_loc5_.channels);
            this.addElementsToQueue(_loc5_.geometries);
            for each(_loc6_ in _loc5_.geometries)
            {
               this.addElementsToQueue(_loc6_.primitives);
            }
            this.addElementsToQueue(_loc5_.sources);
            this.parseQueuedElements(param1);
         }
      }
      
      private function addObject(param1:DaeObject, param2:Object3D, param3:String) : Object3D
      {
         var _loc4_:Object3D = Object3D(param1.object);
         this.objects.push(_loc4_);
         if(param2 == null)
         {
            this.hierarchy.push(_loc4_);
         }
         else
         {
            param2.addChild(_loc4_);
         }
         if(_loc4_ is Light3D)
         {
            this.lights.push(Light3D(_loc4_));
         }
         if(param1.animation != null)
         {
            this.animations.push(param1.animation);
         }
         if(param3)
         {
            alternativa3d::layersMap[_loc4_] = param3;
         }
         return _loc4_;
      }
      
      private function addObjects(param1:Vector.<DaeObject>, param2:Object3D, param3:String) : Object3D
      {
         var _loc4_:Object3D = this.addObject(param1[0],param2,param3);
         var _loc5_:int = 1;
         var _loc6_:int = int(param1.length);
         while(_loc5_ < _loc6_)
         {
            this.addObject(param1[_loc5_],param2,param3);
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function hasSkinsInChildren(param1:DaeNode) : Boolean
      {
         var _loc5_:DaeNode = null;
         var _loc2_:Vector.<DaeNode> = param1.nodes;
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc2_[_loc3_];
            _loc5_.parse();
            if(_loc5_.skins != null)
            {
               return true;
            }
            if(this.hasSkinsInChildren(_loc5_))
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function parseNodes(param1:Vector.<DaeNode>, param2:Object3D, param3:Boolean = false) : void
      {
         var _loc6_:DaeNode = null;
         var _loc7_:Object3D = null;
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = param1[_loc4_];
            _loc6_.parse();
            _loc7_ = null;
            if(_loc6_.skins != null)
            {
               _loc7_ = this.addObjects(_loc6_.skins,param2,_loc6_.layer);
            }
            else if(!param3 && !_loc6_.skinOrTopmostJoint)
            {
               if(_loc6_.objects != null)
               {
                  _loc7_ = this.addObjects(_loc6_.objects,param2,_loc6_.layer);
               }
               else
               {
                  _loc7_ = new Object3D();
                  _loc7_.name = _loc6_.cloneString(_loc6_.name);
                  this.addObject(_loc6_.applyAnimation(_loc6_.applyTransformations(_loc7_)),param2,_loc6_.layer);
                  _loc7_.calculateBoundBox();
               }
            }
            else if(this.hasSkinsInChildren(_loc6_))
            {
               _loc7_ = new Object3D();
               _loc7_.name = _loc6_.cloneString(_loc6_.name);
               this.addObject(_loc6_.applyAnimation(_loc6_.applyTransformations(_loc7_)),param2,_loc6_.layer);
               this.parseNodes(_loc6_.nodes,_loc7_,param3 || _loc6_.skinOrTopmostJoint);
               _loc7_.calculateBoundBox();
            }
            if(_loc7_ != null)
            {
               this.parseNodes(_loc6_.nodes,_loc7_,param3 || _loc6_.skinOrTopmostJoint);
            }
            _loc4_++;
         }
      }
      
      private function addNodesToQueue(param1:Vector.<DaeNode>, param2:Object3D, param3:Boolean) : void
      {
         var _loc6_:QueueElement = null;
         var _loc4_:int = 0;
         while(_loc4_ < this.queue.length)
         {
            if(this.queue[_loc4_].element is DaeNode)
            {
               break;
            }
            _loc4_++;
         }
         var _loc5_:int = int(param1.length);
         while(_loc5_ > 0)
         {
            _loc6_ = new QueueElement();
            _loc6_.element = param1[_loc5_ - 1];
            _loc6_.parent = param2;
            _loc6_.skinsOnly = param3;
            this.queue.splice(_loc4_,0,_loc6_);
            _loc5_--;
         }
      }
      
      private function addElementsToQueue(param1:Object) : void
      {
         var _loc2_:DaeElement = null;
         var _loc3_:QueueElement = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = new QueueElement();
            _loc3_.element = _loc2_;
            this.queue.unshift(_loc3_);
         }
      }
      
      private function parseQueuedElements(param1:Function) : void
      {
         var _loc3_:QueueElement = null;
         var _loc4_:DaeNode = null;
         var _loc5_:Object3D = null;
         var _loc6_:Boolean = false;
         var _loc7_:Object3D = null;
         var _loc2_:int = getTimer();
         while(this.queue.length != 0)
         {
            _loc3_ = this.queue.shift();
            _loc3_.element.parse();
            if(_loc3_.element is DaeNode)
            {
               _loc4_ = _loc3_.element as DaeNode;
               _loc5_ = _loc3_.parent;
               _loc6_ = _loc3_.skinsOnly;
               _loc7_ = null;
               if(_loc4_.skins != null)
               {
                  _loc7_ = this.addObjects(_loc4_.skins,_loc5_,_loc4_.layer);
               }
               else if(!_loc6_ && !_loc4_.skinOrTopmostJoint)
               {
                  if(_loc4_.objects != null)
                  {
                     _loc7_ = this.addObjects(_loc4_.objects,_loc5_,_loc4_.layer);
                  }
                  else
                  {
                     _loc7_ = new Object3D();
                     _loc7_.name = _loc4_.cloneString(_loc4_.name);
                     this.addObject(_loc4_.applyAnimation(_loc4_.applyTransformations(_loc7_)),_loc5_,_loc4_.layer);
                     _loc7_.calculateBoundBox();
                  }
               }
               else if(this.hasSkinsInChildren(_loc4_))
               {
                  _loc7_ = new Object3D();
                  _loc7_.name = _loc4_.cloneString(_loc4_.name);
                  this.addObject(_loc4_.applyAnimation(_loc4_.applyTransformations(_loc7_)),_loc5_,_loc4_.layer);
                  this.addNodesToQueue(_loc4_.nodes,_loc7_,_loc6_ || _loc4_.skinOrTopmostJoint);
                  _loc7_.calculateBoundBox();
               }
               if(_loc7_ != null)
               {
                  this.addNodesToQueue(_loc4_.nodes,_loc7_,_loc6_ || _loc4_.skinOrTopmostJoint);
               }
            }
            if(getTimer() - _loc2_ >= this.ASYNC_LIMIT)
            {
               setTimeout(this.parseQueuedElements,this.ASYNC_TIMEOUT,param1);
               return;
            }
         }
         setTimeout(param1,this.ASYNC_TIMEOUT,this);
      }
      
      private function trimPath(param1:String) : String
      {
         var _loc2_:int = int(param1.lastIndexOf("/"));
         return _loc2_ < 0 ? param1 : param1.substr(_loc2_ + 1);
      }
      
      private function parseMaterials(param1:Object, param2:String, param3:Boolean) : void
      {
         var _loc4_:ParserMaterial = null;
         var _loc5_:DaeMaterial = null;
         var _loc6_:ExternalTextureResource = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         for each(_loc5_ in param1)
         {
            if(_loc5_.used)
            {
               _loc5_.parse();
               this.materials.push(_loc5_.material);
            }
         }
         if(param3)
         {
            for each(_loc4_ in this.materials)
            {
               for each(_loc6_ in _loc4_.textures)
               {
                  if(_loc6_ != null && _loc6_.url != null)
                  {
                     _loc6_.url = this.trimPath(this.fixURL(_loc6_.url));
                  }
               }
            }
         }
         else
         {
            for each(_loc4_ in this.materials)
            {
               for each(_loc6_ in _loc4_.textures)
               {
                  if(_loc6_ != null && _loc6_.url != null)
                  {
                     _loc6_.url = this.fixURL(_loc6_.url);
                  }
               }
            }
         }
         if(param2 != null)
         {
            param2 = this.fixURL(param2);
            _loc8_ = int(param2.lastIndexOf("/"));
            _loc7_ = _loc8_ < 0 ? "" : param2.substr(0,_loc8_);
            for each(_loc4_ in this.materials)
            {
               for each(_loc6_ in _loc4_.textures)
               {
                  if(_loc6_ != null && _loc6_.url != null)
                  {
                     _loc6_.url = this.resolveURL(_loc6_.url,_loc7_);
                  }
               }
            }
         }
      }
      
      private function fixURL(param1:String) : String
      {
         var _loc2_:int = int(param1.indexOf("://"));
         _loc2_ = _loc2_ < 0 ? 0 : _loc2_ + 3;
         var _loc3_:int = int(param1.indexOf("?",_loc2_));
         _loc3_ = _loc3_ < 0 ? int(param1.indexOf("#",_loc2_)) : _loc3_;
         var _loc4_:String = param1.substring(_loc2_,_loc3_ < 0 ? 2147483647 : _loc3_);
         _loc4_ = _loc4_.replace(/\\/g,"/");
         var _loc5_:int = int(param1.indexOf("file://"));
         if(_loc5_ >= 0)
         {
            if(param1.charAt(_loc2_) == "/")
            {
               return "file://" + _loc4_ + (_loc3_ >= 0 ? param1.substring(_loc3_) : "");
            }
            return "file:///" + _loc4_ + (_loc3_ >= 0 ? param1.substring(_loc3_) : "");
         }
         return param1.substring(0,_loc2_) + _loc4_ + (_loc3_ >= 0 ? param1.substring(_loc3_) : "");
      }
      
      private function mergePath(param1:String, param2:String, param3:Boolean = false) : String
      {
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc4_:Array = param2.split("/");
         var _loc5_:Array = param1.split("/");
         var _loc6_:int = 0;
         var _loc7_:int = int(_loc5_.length);
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc5_[_loc6_];
            if(_loc8_ == "..")
            {
               _loc9_ = _loc4_.pop();
               while(_loc9_ == "." || _loc9_ == "" && _loc9_ != null)
               {
                  _loc9_ = _loc4_.pop();
               }
               if(param3)
               {
                  if(_loc9_ == "..")
                  {
                     _loc4_.push("..","..");
                  }
                  else if(_loc9_ == null)
                  {
                     _loc4_.push("..");
                  }
               }
            }
            else
            {
               _loc4_.push(_loc8_);
            }
            _loc6_++;
         }
         return _loc4_.join("/");
      }
      
      private function resolveURL(param1:String, param2:String) : String
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:String = null;
         if(param2 == "")
         {
            return param1;
         }
         if(param1.charAt(0) == "." && param1.charAt(1) == "/")
         {
            return param2 + param1.substr(1);
         }
         if(param1.charAt(0) == "/")
         {
            return param1;
         }
         if(param1.charAt(0) == "." && param1.charAt(1) == ".")
         {
            _loc5_ = int(param1.indexOf("?"));
            _loc5_ = _loc5_ < 0 ? int(param1.indexOf("#")) : _loc5_;
            if(_loc5_ < 0)
            {
               _loc7_ = "";
               _loc6_ = param1;
            }
            else
            {
               _loc7_ = param1.substring(_loc5_);
               _loc6_ = param1.substring(0,_loc5_);
            }
            _loc9_ = int(param2.indexOf("/"));
            _loc10_ = int(param2.indexOf(":"));
            _loc11_ = int(param2.indexOf("//"));
            if(_loc11_ < 0 || _loc11_ > _loc9_)
            {
               if(_loc10_ >= 0 && _loc10_ < _loc9_)
               {
                  _loc12_ = param2.substring(0,_loc10_ + 1);
                  _loc8_ = param2.substring(_loc10_ + 1);
                  if(_loc8_.charAt(0) == "/")
                  {
                     return _loc12_ + "/" + this.mergePath(_loc6_,_loc8_.substring(1),false) + _loc7_;
                  }
                  return _loc12_ + this.mergePath(_loc6_,_loc8_,false) + _loc7_;
               }
               if(param2.charAt(0) == "/")
               {
                  return "/" + this.mergePath(_loc6_,param2.substring(1),false) + _loc7_;
               }
               return this.mergePath(_loc6_,param2,true) + _loc7_;
            }
            _loc9_ = int(param2.indexOf("/",_loc11_ + 2));
            if(_loc9_ >= 0)
            {
               _loc13_ = param2.substring(0,_loc9_ + 1);
               _loc8_ = param2.substring(_loc9_ + 1);
               return _loc13_ + this.mergePath(_loc6_,_loc8_,false) + _loc7_;
            }
            _loc13_ = param2;
            return _loc13_ + "/" + this.mergePath(_loc6_,"",false);
         }
         var _loc3_:int = int(param1.indexOf(":"));
         var _loc4_:int = int(param1.indexOf("/"));
         if(_loc3_ >= 0 && (_loc3_ < _loc4_ || _loc4_ < 0))
         {
            return param1;
         }
         return param2 + "/" + param1;
      }
      
      public function getAnimationByObject(param1:Object) : AnimationClip
      {
         var _loc2_:AnimationClip = null;
         var _loc3_:Array = null;
         for each(_loc2_ in animations)
         {
            _loc3_ = _loc2_.alternativa3d::_objects;
            if(_loc3_.indexOf(param1) >= 0)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}

import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.loaders.collada.DaeElement;

class QueueElement
{
   
   public var element:DaeElement;
   
   public var parent:Object3D;
   
   public var skinsOnly:Boolean;
   
   public function QueueElement()
   {
      super();
   }
}
