package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.animation.keys.NumberTrack;
   import alternativa.engine3d.animation.keys.Track;
   import alternativa.engine3d.animation.keys.TransformTrack;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace collada;
   
   public class DaeNode extends DaeElement
   {
      
      public var scene:DaeVisualScene;
      
      public var parent:DaeNode;
      
      public var skinOrTopmostJoint:Boolean = false;
      
      private var channels:Vector.<DaeChannel>;
      
      private var instanceControllers:Vector.<DaeInstanceController>;
      
      public var nodes:Vector.<DaeNode>;
      
      public var objects:Vector.<DaeObject>;
      
      public var skins:Vector.<DaeObject>;
      
      public function DaeNode(param1:XML, param2:DaeDocument, param3:DaeVisualScene = null, param4:DaeNode = null)
      {
         super(param1,param2);
         this.scene = param3;
         this.parent = param4;
         this.constructNodes();
      }
      
      public function get animName() : String
      {
         var _loc1_:String = this.name;
         return _loc1_ == null ? this.id : _loc1_;
      }
      
      private function constructNodes() : void
      {
         var _loc4_:DaeNode = null;
         var _loc1_:XMLList = data.node;
         var _loc2_:int = int(_loc1_.length());
         this.nodes = new Vector.<DaeNode>(_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = new DaeNode(_loc1_[_loc3_],document,this.scene,this);
            if(_loc4_.id != null)
            {
               document.nodes[_loc4_.id] = _loc4_;
            }
            this.nodes[_loc3_] = _loc4_;
            _loc3_++;
         }
      }
      
      internal function registerInstanceControllers() : void
      {
         var _loc2_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:DaeInstanceController = null;
         var _loc6_:Vector.<DaeNode> = null;
         var _loc7_:int = 0;
         var _loc8_:DaeNode = null;
         var _loc9_:int = 0;
         var _loc1_:XMLList = data.instance_controller;
         var _loc3_:int = int(_loc1_.length());
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.skinOrTopmostJoint = true;
            _loc4_ = _loc1_[_loc2_];
            _loc5_ = new DaeInstanceController(_loc4_,document,this);
            if(_loc5_.parse())
            {
               _loc6_ = _loc5_.topmostJoints;
               _loc7_ = int(_loc6_.length);
               if(_loc7_ > 0)
               {
                  _loc8_ = _loc6_[0];
                  _loc8_.addInstanceController(_loc5_);
                  _loc9_ = 0;
                  while(_loc9_ < _loc7_)
                  {
                     _loc6_[_loc9_].skinOrTopmostJoint = true;
                     _loc9_++;
                  }
               }
            }
            _loc2_++;
         }
         _loc3_ = int(this.nodes.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.nodes[_loc2_].registerInstanceControllers();
            _loc2_++;
         }
      }
      
      public function addChannel(param1:DaeChannel) : void
      {
         if(this.channels == null)
         {
            this.channels = new Vector.<DaeChannel>();
         }
         this.channels.push(param1);
      }
      
      public function addInstanceController(param1:DaeInstanceController) : void
      {
         if(this.instanceControllers == null)
         {
            this.instanceControllers = new Vector.<DaeInstanceController>();
         }
         this.instanceControllers.push(param1);
      }
      
      override protected function parseImplementation() : Boolean
      {
         this.skins = this.parseSkins();
         this.objects = this.parseObjects();
         return true;
      }
      
      private function parseInstanceMaterials(param1:XML) : Object
      {
         var _loc6_:DaeInstanceMaterial = null;
         var _loc2_:Object = {};
         var _loc3_:XMLList = param1.bind_material.technique_common.instance_material;
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length());
         while(_loc4_ < _loc5_)
         {
            _loc6_ = new DaeInstanceMaterial(_loc3_[_loc4_],document);
            _loc2_[_loc6_.symbol] = _loc6_;
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getNodeBySid(param1:String) : DaeNode
      {
         var _loc5_:int = 0;
         var _loc6_:Vector.<Vector.<DaeNode>> = null;
         var _loc7_:Vector.<DaeNode> = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:DaeNode = null;
         if(param1 == this.sid)
         {
            return this;
         }
         var _loc2_:Vector.<Vector.<DaeNode>> = new Vector.<Vector.<DaeNode>>();
         var _loc3_:Vector.<Vector.<DaeNode>> = new Vector.<Vector.<DaeNode>>();
         _loc2_.push(this.nodes);
         var _loc4_:int = int(_loc2_.length);
         while(_loc4_ > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc7_ = _loc2_[_loc5_];
               _loc8_ = int(_loc7_.length);
               _loc9_ = 0;
               while(_loc9_ < _loc8_)
               {
                  _loc10_ = _loc7_[_loc9_];
                  if(_loc10_.sid == param1)
                  {
                     return _loc10_;
                  }
                  if(_loc10_.nodes.length > 0)
                  {
                     _loc3_.push(_loc10_.nodes);
                  }
                  _loc9_++;
               }
               _loc5_++;
            }
            _loc6_ = _loc2_;
            _loc2_ = _loc3_;
            _loc3_ = _loc6_;
            _loc3_.length = 0;
            _loc4_ = int(_loc2_.length);
         }
         return null;
      }
      
      public function parseSkins() : Vector.<DaeObject>
      {
         var _loc4_:DaeInstanceController = null;
         var _loc5_:DaeObject = null;
         var _loc6_:Skin = null;
         if(this.instanceControllers == null)
         {
            return null;
         }
         var _loc1_:Vector.<DaeObject> = new Vector.<DaeObject>();
         var _loc2_:int = 0;
         var _loc3_:int = int(this.instanceControllers.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this.instanceControllers[_loc2_];
            _loc4_.parse();
            _loc5_ = _loc4_.parseSkin(this.parseInstanceMaterials(_loc4_.data));
            if(_loc5_ != null)
            {
               _loc6_ = Skin(_loc5_.object);
               _loc6_.name = cloneString(_loc4_.node.name);
               _loc1_.push(_loc5_);
            }
            _loc2_++;
         }
         return _loc1_.length > 0 ? _loc1_ : null;
      }
      
      public function parseObjects() : Vector.<DaeObject>
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         var _loc6_:DaeLight = null;
         var _loc7_:DaeGeometry = null;
         var _loc8_:Light3D = null;
         var _loc9_:Matrix3D = null;
         var _loc10_:Mesh = null;
         var _loc1_:Vector.<DaeObject> = new Vector.<DaeObject>();
         var _loc2_:XMLList = data.children();
         _loc3_ = 0;
         _loc4_ = int(_loc2_.length());
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc2_[_loc3_];
            switch(_loc5_.localName())
            {
               case "instance_light":
                  _loc6_ = document.findLight(_loc5_.@url[0]);
                  if(_loc6_ != null)
                  {
                     _loc8_ = _loc6_.parseLight();
                     if(_loc8_ != null)
                     {
                        _loc8_.name = cloneString(name);
                        if(_loc6_.revertDirection)
                        {
                           _loc9_ = new Matrix3D();
                           _loc9_.appendRotation(180,Vector3D.X_AXIS);
                           _loc1_.push(new DaeObject(this.applyTransformations(_loc8_,_loc9_)));
                        }
                        else
                        {
                           _loc1_.push(this.applyAnimation(this.applyTransformations(_loc8_)));
                        }
                     }
                  }
                  else
                  {
                     document.logger.logNotFoundError(_loc5_.@url[0]);
                  }
                  break;
               case "instance_geometry":
                  _loc7_ = document.findGeometry(_loc5_.@url[0]);
                  if(_loc7_ != null)
                  {
                     _loc7_.parse();
                     _loc10_ = _loc7_.parseMesh(this.parseInstanceMaterials(_loc5_));
                     if(_loc10_ != null)
                     {
                        _loc10_.name = cloneString(name);
                        _loc1_.push(this.applyAnimation(this.applyTransformations(_loc10_)));
                     }
                  }
                  else
                  {
                     document.logger.logNotFoundError(_loc5_.@url[0]);
                  }
                  break;
               case "instance_node":
                  document.logger.logInstanceNodeError(_loc5_);
            }
            _loc3_++;
         }
         return _loc1_.length > 0 ? _loc1_ : null;
      }
      
      private function getMatrix(param1:Matrix3D = null) : Matrix3D
      {
         var _loc3_:Array = null;
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc2_:Matrix3D = param1 == null ? new Matrix3D() : param1;
         var _loc4_:XMLList = data.children();
         var _loc5_:int = _loc4_.length() - 1;
         for(; _loc5_ >= 0; _loc5_--)
         {
            _loc6_ = _loc4_[_loc5_];
            _loc7_ = _loc6_.@sid[0];
            if(_loc7_ != null && _loc7_.toString() == "post-rotationY")
            {
               continue;
            }
            switch(_loc6_.localName())
            {
               case "scale":
                  _loc3_ = parseNumbersArray(_loc6_);
                  _loc2_.appendScale(_loc3_[0],_loc3_[1],_loc3_[2]);
                  break;
               case "rotate":
                  _loc3_ = parseNumbersArray(_loc6_);
                  _loc2_.appendRotation(_loc3_[3],new Vector3D(_loc3_[0],_loc3_[1],_loc3_[2]));
                  break;
               case "translate":
                  _loc3_ = parseNumbersArray(_loc6_);
                  _loc2_.appendTranslation(_loc3_[0] * document.unitScaleFactor,_loc3_[1] * document.unitScaleFactor,_loc3_[2] * document.unitScaleFactor);
                  break;
               case "matrix":
                  _loc3_ = parseNumbersArray(_loc6_);
                  _loc2_.append(new Matrix3D(Vector.<Number>([_loc3_[0],_loc3_[4],_loc3_[8],_loc3_[12],_loc3_[1],_loc3_[5],_loc3_[9],_loc3_[13],_loc3_[2],_loc3_[6],_loc3_[10],_loc3_[14],_loc3_[3] * document.unitScaleFactor,_loc3_[7] * document.unitScaleFactor,_loc3_[11] * document.unitScaleFactor,_loc3_[15]])));
                  break;
               case "lookat":
                  break;
               case "skew":
                  document.logger.logSkewError(_loc6_);
            }
         }
         return _loc2_;
      }
      
      public function applyTransformations(param1:Object3D, param2:Matrix3D = null, param3:Matrix3D = null) : Object3D
      {
         var _loc4_:Matrix3D = this.getMatrix(param2);
         if(param3 != null)
         {
            _loc4_.append(param3);
         }
         var _loc5_:Vector.<Vector3D> = _loc4_.decompose();
         var _loc6_:Vector3D = _loc5_[0];
         var _loc7_:Vector3D = _loc5_[1];
         var _loc8_:Vector3D = _loc5_[2];
         param1.x = _loc6_.x;
         param1.y = _loc6_.y;
         param1.z = _loc6_.z;
         param1.rotationX = _loc7_.x;
         param1.rotationY = _loc7_.y;
         param1.rotationZ = _loc7_.z;
         param1.scaleX = _loc8_.x;
         param1.scaleY = _loc8_.y;
         param1.scaleZ = _loc8_.z;
         return param1;
      }
      
      public function applyAnimation(param1:Object3D) : DaeObject
      {
         var _loc2_:AnimationClip = this.parseAnimation(param1);
         if(_loc2_ == null)
         {
            return new DaeObject(param1);
         }
         param1.name = this.animName;
         _loc2_.attach(param1,false);
         return new DaeObject(param1,_loc2_);
      }
      
      public function parseAnimation(param1:Object3D = null) : AnimationClip
      {
         if(this.channels == null || !this.hasTransformationAnimation())
         {
            return null;
         }
         var _loc2_:DaeChannel = this.getChannel(DaeChannel.PARAM_MATRIX);
         if(_loc2_ != null)
         {
            return this.createClip(_loc2_.tracks);
         }
         var _loc3_:AnimationClip = new AnimationClip();
         var _loc4_:Vector.<Vector3D> = param1 != null ? null : this.getMatrix().decompose();
         _loc2_ = this.getChannel(DaeChannel.PARAM_TRANSLATE);
         if(_loc2_ != null)
         {
            this.addTracksToClip(_loc3_,_loc2_.tracks);
         }
         else
         {
            _loc2_ = this.getChannel(DaeChannel.PARAM_TRANSLATE_X);
            if(_loc2_ != null)
            {
               this.addTracksToClip(_loc3_,_loc2_.tracks);
            }
            else
            {
               _loc3_.addTrack(this.createValueStaticTrack("x",param1 == null ? _loc4_[0].x : param1.x));
            }
            _loc2_ = this.getChannel(DaeChannel.PARAM_TRANSLATE_Y);
            if(_loc2_ != null)
            {
               this.addTracksToClip(_loc3_,_loc2_.tracks);
            }
            else
            {
               _loc3_.addTrack(this.createValueStaticTrack("y",param1 == null ? _loc4_[0].y : param1.y));
            }
            _loc2_ = this.getChannel(DaeChannel.PARAM_TRANSLATE_Z);
            if(_loc2_ != null)
            {
               this.addTracksToClip(_loc3_,_loc2_.tracks);
            }
            else
            {
               _loc3_.addTrack(this.createValueStaticTrack("z",param1 == null ? _loc4_[0].z : param1.z));
            }
         }
         _loc2_ = this.getChannel(DaeChannel.PARAM_ROTATION_X);
         if(_loc2_ != null)
         {
            this.addTracksToClip(_loc3_,_loc2_.tracks);
         }
         else
         {
            _loc3_.addTrack(this.createValueStaticTrack("rotationX",param1 == null ? _loc4_[1].x : param1.rotationX));
         }
         _loc2_ = this.getChannel(DaeChannel.PARAM_ROTATION_Y);
         if(_loc2_ != null)
         {
            this.addTracksToClip(_loc3_,_loc2_.tracks);
         }
         else
         {
            _loc3_.addTrack(this.createValueStaticTrack("rotationY",param1 == null ? _loc4_[1].y : param1.rotationY));
         }
         _loc2_ = this.getChannel(DaeChannel.PARAM_ROTATION_Z);
         if(_loc2_ != null)
         {
            this.addTracksToClip(_loc3_,_loc2_.tracks);
         }
         else
         {
            _loc3_.addTrack(this.createValueStaticTrack("rotationZ",param1 == null ? _loc4_[1].z : param1.rotationZ));
         }
         _loc2_ = this.getChannel(DaeChannel.PARAM_SCALE);
         if(_loc2_ != null)
         {
            this.addTracksToClip(_loc3_,_loc2_.tracks);
         }
         else
         {
            _loc2_ = this.getChannel(DaeChannel.PARAM_SCALE_X);
            if(_loc2_ != null)
            {
               this.addTracksToClip(_loc3_,_loc2_.tracks);
            }
            else
            {
               _loc3_.addTrack(this.createValueStaticTrack("scaleX",param1 == null ? _loc4_[2].x : param1.scaleX));
            }
            _loc2_ = this.getChannel(DaeChannel.PARAM_SCALE_Y);
            if(_loc2_ != null)
            {
               this.addTracksToClip(_loc3_,_loc2_.tracks);
            }
            else
            {
               _loc3_.addTrack(this.createValueStaticTrack("scaleY",param1 == null ? _loc4_[2].y : param1.scaleY));
            }
            _loc2_ = this.getChannel(DaeChannel.PARAM_SCALE_Z);
            if(_loc2_ != null)
            {
               this.addTracksToClip(_loc3_,_loc2_.tracks);
            }
            else
            {
               _loc3_.addTrack(this.createValueStaticTrack("scaleZ",param1 == null ? _loc4_[2].z : param1.scaleZ));
            }
         }
         if(_loc3_.numTracks > 0)
         {
            return _loc3_;
         }
         return null;
      }
      
      private function createClip(param1:Vector.<Track>) : AnimationClip
      {
         var _loc2_:AnimationClip = new AnimationClip();
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            _loc2_.addTrack(param1[_loc3_]);
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function addTracksToClip(param1:AnimationClip, param2:Vector.<Track>) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = int(param2.length);
         while(_loc3_ < _loc4_)
         {
            param1.addTrack(param2[_loc3_]);
            _loc3_++;
         }
      }
      
      private function hasTransformationAnimation() : Boolean
      {
         var _loc3_:DaeChannel = null;
         var _loc4_:* = false;
         var _loc1_:int = 0;
         var _loc2_:int = int(this.channels.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this.channels[_loc1_];
            _loc3_.parse();
            _loc4_ = _loc3_.animatedParam == DaeChannel.PARAM_MATRIX;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_TRANSLATE;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_TRANSLATE_X;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_TRANSLATE_Y;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_TRANSLATE_Z;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_ROTATION_X;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_ROTATION_Y;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_ROTATION_Z;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_SCALE;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_SCALE_X;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_SCALE_Y;
            _loc4_ = (_loc4_) || _loc3_.animatedParam == DaeChannel.PARAM_SCALE_Z;
            if(_loc4_)
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
      
      private function getChannel(param1:String) : DaeChannel
      {
         var _loc4_:DaeChannel = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(this.channels.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this.channels[_loc2_];
            _loc4_.parse();
            if(_loc4_.animatedParam == param1)
            {
               return _loc4_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function concatTracks(param1:Vector.<Track>, param2:Vector.<Track>) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            param2.push(param1[_loc3_]);
            _loc3_++;
         }
      }
      
      private function createValueStaticTrack(param1:String, param2:Number) : Track
      {
         var _loc3_:NumberTrack = new NumberTrack(this.animName,param1);
         _loc3_.addKey(0,param2);
         return _loc3_;
      }
      
      public function createStaticTransformTrack() : TransformTrack
      {
         var _loc1_:TransformTrack = new TransformTrack(this.animName);
         _loc1_.addKey(0,this.getMatrix());
         return _loc1_;
      }
      
      public function get layer() : String
      {
         var _loc1_:XML = data.@layer[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
   }
}

