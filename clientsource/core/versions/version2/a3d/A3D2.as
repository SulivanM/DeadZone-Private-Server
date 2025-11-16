package versions.version2.a3d
{
   import versions.version2.a3d.animation.A3D2AnimationClip;
   import versions.version2.a3d.animation.A3D2Track;
   import versions.version2.a3d.geometry.A3D2IndexBuffer;
   import versions.version2.a3d.geometry.A3D2VertexBuffer;
   import versions.version2.a3d.materials.A3D2CubeMap;
   import versions.version2.a3d.materials.A3D2Image;
   import versions.version2.a3d.materials.A3D2Map;
   import versions.version2.a3d.materials.A3D2Material;
   import versions.version2.a3d.objects.A3D2AmbientLight;
   import versions.version2.a3d.objects.A3D2Box;
   import versions.version2.a3d.objects.A3D2Decal;
   import versions.version2.a3d.objects.A3D2DirectionalLight;
   import versions.version2.a3d.objects.A3D2Joint;
   import versions.version2.a3d.objects.A3D2Mesh;
   import versions.version2.a3d.objects.A3D2Object;
   import versions.version2.a3d.objects.A3D2OmniLight;
   import versions.version2.a3d.objects.A3D2Skin;
   import versions.version2.a3d.objects.A3D2SpotLight;
   import versions.version2.a3d.objects.A3D2Sprite;
   
   public class A3D2
   {
      
      private var _ambientLights:Vector.<A3D2AmbientLight>;
      
      private var _animationClips:Vector.<A3D2AnimationClip>;
      
      private var _animationTracks:Vector.<A3D2Track>;
      
      private var _boxes:Vector.<A3D2Box>;
      
      private var _cubeMaps:Vector.<A3D2CubeMap>;
      
      private var _decals:Vector.<A3D2Decal>;
      
      private var _directionalLights:Vector.<A3D2DirectionalLight>;
      
      private var _images:Vector.<A3D2Image>;
      
      private var _indexBuffers:Vector.<A3D2IndexBuffer>;
      
      private var _joints:Vector.<A3D2Joint>;
      
      private var _maps:Vector.<A3D2Map>;
      
      private var _materials:Vector.<A3D2Material>;
      
      private var _meshes:Vector.<A3D2Mesh>;
      
      private var _objects:Vector.<A3D2Object>;
      
      private var _omniLights:Vector.<A3D2OmniLight>;
      
      private var _skins:Vector.<A3D2Skin>;
      
      private var _spotLights:Vector.<A3D2SpotLight>;
      
      private var _sprites:Vector.<A3D2Sprite>;
      
      private var _vertexBuffers:Vector.<A3D2VertexBuffer>;
      
      public function A3D2(param1:Vector.<A3D2AmbientLight>, param2:Vector.<A3D2AnimationClip>, param3:Vector.<A3D2Track>, param4:Vector.<A3D2Box>, param5:Vector.<A3D2CubeMap>, param6:Vector.<A3D2Decal>, param7:Vector.<A3D2DirectionalLight>, param8:Vector.<A3D2Image>, param9:Vector.<A3D2IndexBuffer>, param10:Vector.<A3D2Joint>, param11:Vector.<A3D2Map>, param12:Vector.<A3D2Material>, param13:Vector.<A3D2Mesh>, param14:Vector.<A3D2Object>, param15:Vector.<A3D2OmniLight>, param16:Vector.<A3D2Skin>, param17:Vector.<A3D2SpotLight>, param18:Vector.<A3D2Sprite>, param19:Vector.<A3D2VertexBuffer>)
      {
         super();
         this._ambientLights = param1;
         this._animationClips = param2;
         this._animationTracks = param3;
         this._boxes = param4;
         this._cubeMaps = param5;
         this._decals = param6;
         this._directionalLights = param7;
         this._images = param8;
         this._indexBuffers = param9;
         this._joints = param10;
         this._maps = param11;
         this._materials = param12;
         this._meshes = param13;
         this._objects = param14;
         this._omniLights = param15;
         this._skins = param16;
         this._spotLights = param17;
         this._sprites = param18;
         this._vertexBuffers = param19;
      }
      
      public function get ambientLights() : Vector.<A3D2AmbientLight>
      {
         return this._ambientLights;
      }
      
      public function set ambientLights(param1:Vector.<A3D2AmbientLight>) : void
      {
         this._ambientLights = param1;
      }
      
      public function get animationClips() : Vector.<A3D2AnimationClip>
      {
         return this._animationClips;
      }
      
      public function set animationClips(param1:Vector.<A3D2AnimationClip>) : void
      {
         this._animationClips = param1;
      }
      
      public function get animationTracks() : Vector.<A3D2Track>
      {
         return this._animationTracks;
      }
      
      public function set animationTracks(param1:Vector.<A3D2Track>) : void
      {
         this._animationTracks = param1;
      }
      
      public function get boxes() : Vector.<A3D2Box>
      {
         return this._boxes;
      }
      
      public function set boxes(param1:Vector.<A3D2Box>) : void
      {
         this._boxes = param1;
      }
      
      public function get cubeMaps() : Vector.<A3D2CubeMap>
      {
         return this._cubeMaps;
      }
      
      public function set cubeMaps(param1:Vector.<A3D2CubeMap>) : void
      {
         this._cubeMaps = param1;
      }
      
      public function get decals() : Vector.<A3D2Decal>
      {
         return this._decals;
      }
      
      public function set decals(param1:Vector.<A3D2Decal>) : void
      {
         this._decals = param1;
      }
      
      public function get directionalLights() : Vector.<A3D2DirectionalLight>
      {
         return this._directionalLights;
      }
      
      public function set directionalLights(param1:Vector.<A3D2DirectionalLight>) : void
      {
         this._directionalLights = param1;
      }
      
      public function get images() : Vector.<A3D2Image>
      {
         return this._images;
      }
      
      public function set images(param1:Vector.<A3D2Image>) : void
      {
         this._images = param1;
      }
      
      public function get indexBuffers() : Vector.<A3D2IndexBuffer>
      {
         return this._indexBuffers;
      }
      
      public function set indexBuffers(param1:Vector.<A3D2IndexBuffer>) : void
      {
         this._indexBuffers = param1;
      }
      
      public function get joints() : Vector.<A3D2Joint>
      {
         return this._joints;
      }
      
      public function set joints(param1:Vector.<A3D2Joint>) : void
      {
         this._joints = param1;
      }
      
      public function get maps() : Vector.<A3D2Map>
      {
         return this._maps;
      }
      
      public function set maps(param1:Vector.<A3D2Map>) : void
      {
         this._maps = param1;
      }
      
      public function get materials() : Vector.<A3D2Material>
      {
         return this._materials;
      }
      
      public function set materials(param1:Vector.<A3D2Material>) : void
      {
         this._materials = param1;
      }
      
      public function get meshes() : Vector.<A3D2Mesh>
      {
         return this._meshes;
      }
      
      public function set meshes(param1:Vector.<A3D2Mesh>) : void
      {
         this._meshes = param1;
      }
      
      public function get objects() : Vector.<A3D2Object>
      {
         return this._objects;
      }
      
      public function set objects(param1:Vector.<A3D2Object>) : void
      {
         this._objects = param1;
      }
      
      public function get omniLights() : Vector.<A3D2OmniLight>
      {
         return this._omniLights;
      }
      
      public function set omniLights(param1:Vector.<A3D2OmniLight>) : void
      {
         this._omniLights = param1;
      }
      
      public function get skins() : Vector.<A3D2Skin>
      {
         return this._skins;
      }
      
      public function set skins(param1:Vector.<A3D2Skin>) : void
      {
         this._skins = param1;
      }
      
      public function get spotLights() : Vector.<A3D2SpotLight>
      {
         return this._spotLights;
      }
      
      public function set spotLights(param1:Vector.<A3D2SpotLight>) : void
      {
         this._spotLights = param1;
      }
      
      public function get sprites() : Vector.<A3D2Sprite>
      {
         return this._sprites;
      }
      
      public function set sprites(param1:Vector.<A3D2Sprite>) : void
      {
         this._sprites = param1;
      }
      
      public function get vertexBuffers() : Vector.<A3D2VertexBuffer>
      {
         return this._vertexBuffers;
      }
      
      public function set vertexBuffers(param1:Vector.<A3D2VertexBuffer>) : void
      {
         this._vertexBuffers = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2 [";
         _loc1_ += "ambientLights = " + this.ambientLights + " ";
         _loc1_ += "animationClips = " + this.animationClips + " ";
         _loc1_ += "animationTracks = " + this.animationTracks + " ";
         _loc1_ += "boxes = " + this.boxes + " ";
         _loc1_ += "cubeMaps = " + this.cubeMaps + " ";
         _loc1_ += "decals = " + this.decals + " ";
         _loc1_ += "directionalLights = " + this.directionalLights + " ";
         _loc1_ += "images = " + this.images + " ";
         _loc1_ += "indexBuffers = " + this.indexBuffers + " ";
         _loc1_ += "joints = " + this.joints + " ";
         _loc1_ += "maps = " + this.maps + " ";
         _loc1_ += "materials = " + this.materials + " ";
         _loc1_ += "meshes = " + this.meshes + " ";
         _loc1_ += "objects = " + this.objects + " ";
         _loc1_ += "omniLights = " + this.omniLights + " ";
         _loc1_ += "skins = " + this.skins + " ";
         _loc1_ += "spotLights = " + this.spotLights + " ";
         _loc1_ += "sprites = " + this.sprites + " ";
         _loc1_ += "vertexBuffers = " + this.vertexBuffers + " ";
         return _loc1_ + "]";
      }
   }
}

