package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeDocument
   {
      
      public var scene:DaeVisualScene;
      
      private var data:XML;
      
      public var sources:Object;
      
      internal var arrays:Object;
      
      internal var vertices:Object;
      
      public var geometries:Object;
      
      internal var nodes:Object;
      
      internal var lights:Object;
      
      internal var images:Object;
      
      internal var effects:Object;
      
      public var controllers:Object;
      
      internal var samplers:Object;
      
      public var channels:Vector.<DaeChannel>;
      
      public var materials:Object;
      
      internal var logger:DaeLogger;
      
      public var versionMajor:uint;
      
      public var versionMinor:uint;
      
      public var unitScaleFactor:Number = 1;
      
      public function DaeDocument(param1:XML, param2:Number)
      {
         super();
         this.data = param1;
         var _loc3_:Array = this.data.@version[0].toString().split(/[.,]/);
         this.versionMajor = parseInt(_loc3_[1],10);
         this.versionMinor = parseInt(_loc3_[2],10);
         var _loc4_:Number = parseFloat(this.data.asset[0].unit[0].@meter);
         if(param2 > 0)
         {
            this.unitScaleFactor = _loc4_ / param2;
         }
         else
         {
            this.unitScaleFactor = 1;
         }
         this.logger = new DaeLogger();
         this.constructStructures();
         this.constructScenes();
         this.registerInstanceControllers();
         this.constructAnimations();
      }
      
      private function getLocalID(param1:XML) : String
      {
         var _loc2_:String = param1.toString();
         if(_loc2_.charAt(0) == "#")
         {
            return _loc2_.substr(1);
         }
         this.logger.logExternalError(param1);
         return null;
      }
      
      private function constructStructures() : void
      {
         var _loc1_:XML = null;
         var _loc2_:DaeSource = null;
         var _loc3_:DaeLight = null;
         var _loc4_:DaeImage = null;
         var _loc5_:DaeEffect = null;
         var _loc6_:DaeMaterial = null;
         var _loc7_:DaeGeometry = null;
         var _loc8_:DaeController = null;
         var _loc9_:DaeNode = null;
         this.sources = {};
         this.arrays = {};
         for each(_loc1_ in this.data..source)
         {
            _loc2_ = new DaeSource(_loc1_,this);
            if(_loc2_.id != null)
            {
               this.sources[_loc2_.id] = _loc2_;
            }
         }
         this.lights = {};
         for each(_loc1_ in this.data.library_lights.light)
         {
            _loc3_ = new DaeLight(_loc1_,this);
            if(_loc3_.id != null)
            {
               this.lights[_loc3_.id] = _loc3_;
            }
         }
         this.images = {};
         for each(_loc1_ in this.data.library_images.image)
         {
            _loc4_ = new DaeImage(_loc1_,this);
            if(_loc4_.id != null)
            {
               this.images[_loc4_.id] = _loc4_;
            }
         }
         this.effects = {};
         for each(_loc1_ in this.data.library_effects.effect)
         {
            _loc5_ = new DaeEffect(_loc1_,this);
            if(_loc5_.id != null)
            {
               this.effects[_loc5_.id] = _loc5_;
            }
         }
         this.materials = {};
         for each(_loc1_ in this.data.library_materials.material)
         {
            _loc6_ = new DaeMaterial(_loc1_,this);
            if(_loc6_.id != null)
            {
               this.materials[_loc6_.id] = _loc6_;
            }
         }
         this.geometries = {};
         this.vertices = {};
         for each(_loc1_ in this.data.library_geometries.geometry)
         {
            _loc7_ = new DaeGeometry(_loc1_,this);
            if(_loc7_.id != null)
            {
               this.geometries[_loc7_.id] = _loc7_;
            }
         }
         this.controllers = {};
         for each(_loc1_ in this.data.library_controllers.controller)
         {
            _loc8_ = new DaeController(_loc1_,this);
            if(_loc8_.id != null)
            {
               this.controllers[_loc8_.id] = _loc8_;
            }
         }
         this.nodes = {};
         for each(_loc1_ in this.data.library_nodes.node)
         {
            _loc9_ = new DaeNode(_loc1_,this);
            if(_loc9_.id != null)
            {
               this.nodes[_loc9_.id] = _loc9_;
            }
         }
      }
      
      private function constructScenes() : void
      {
         var _loc3_:XML = null;
         var _loc4_:DaeVisualScene = null;
         var _loc1_:XML = this.data.scene.instance_visual_scene.@url[0];
         var _loc2_:String = this.getLocalID(_loc1_);
         for each(_loc3_ in this.data.library_visual_scenes.visual_scene)
         {
            _loc4_ = new DaeVisualScene(_loc3_,this);
            if(_loc4_.id == _loc2_)
            {
               this.scene = _loc4_;
            }
         }
         if(_loc2_ != null && this.scene == null)
         {
            this.logger.logNotFoundError(_loc1_);
         }
      }
      
      private function registerInstanceControllers() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.scene != null)
         {
            _loc1_ = 0;
            _loc2_ = int(this.scene.nodes.length);
            while(_loc1_ < _loc2_)
            {
               this.scene.nodes[_loc1_].registerInstanceControllers();
               _loc1_++;
            }
         }
      }
      
      private function constructAnimations() : void
      {
         var _loc1_:XML = null;
         var _loc2_:DaeSampler = null;
         var _loc3_:DaeChannel = null;
         var _loc4_:DaeNode = null;
         this.samplers = {};
         for each(_loc1_ in this.data.library_animations..sampler)
         {
            _loc2_ = new DaeSampler(_loc1_,this);
            if(_loc2_.id != null)
            {
               this.samplers[_loc2_.id] = _loc2_;
            }
         }
         for each(_loc1_ in this.data.library_animations..channel)
         {
            _loc3_ = new DaeChannel(_loc1_,this);
            _loc4_ = _loc3_.node;
            if(_loc4_ != null)
            {
               _loc4_.addChannel(_loc3_);
               if(this.channels == null)
               {
                  this.channels = new Vector.<DaeChannel>();
               }
               this.channels.push(_loc3_);
            }
         }
      }
      
      public function findArray(param1:XML) : DaeArray
      {
         return this.arrays[this.getLocalID(param1)];
      }
      
      public function findSource(param1:XML) : DaeSource
      {
         return this.sources[this.getLocalID(param1)];
      }
      
      public function findLight(param1:XML) : DaeLight
      {
         return this.lights[this.getLocalID(param1)];
      }
      
      public function findImage(param1:XML) : DaeImage
      {
         return this.images[this.getLocalID(param1)];
      }
      
      public function findImageByID(param1:String) : DaeImage
      {
         return this.images[param1];
      }
      
      public function findEffect(param1:XML) : DaeEffect
      {
         return this.effects[this.getLocalID(param1)];
      }
      
      public function findMaterial(param1:XML) : DaeMaterial
      {
         return this.materials[this.getLocalID(param1)];
      }
      
      public function findVertices(param1:XML) : DaeVertices
      {
         return this.vertices[this.getLocalID(param1)];
      }
      
      public function findGeometry(param1:XML) : DaeGeometry
      {
         return this.geometries[this.getLocalID(param1)];
      }
      
      public function findNode(param1:XML) : DaeNode
      {
         return this.nodes[this.getLocalID(param1)];
      }
      
      public function findNodeByID(param1:String) : DaeNode
      {
         return this.nodes[param1];
      }
      
      public function findController(param1:XML) : DaeController
      {
         return this.controllers[this.getLocalID(param1)];
      }
      
      public function findSampler(param1:XML) : DaeSampler
      {
         return this.samplers[this.getLocalID(param1)];
      }
   }
}

