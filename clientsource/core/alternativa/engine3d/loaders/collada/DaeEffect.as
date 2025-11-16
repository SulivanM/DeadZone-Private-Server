package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.resources.ExternalTextureResource;
   
   use namespace collada;
   
   public class DaeEffect extends DaeElement
   {
      
      public static var commonAlways:Boolean = false;
      
      private var effectParams:Object;
      
      private var commonParams:Object;
      
      private var techniqueParams:Object;
      
      private var diffuse:DaeEffectParam;
      
      private var ambient:DaeEffectParam;
      
      private var transparent:DaeEffectParam;
      
      private var transparency:DaeEffectParam;
      
      private var bump:DaeEffectParam;
      
      private var reflective:DaeEffectParam;
      
      private var emission:DaeEffectParam;
      
      private var specular:DaeEffectParam;
      
      public function DaeEffect(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
         this.constructImages();
      }
      
      private function constructImages() : void
      {
         var _loc2_:XML = null;
         var _loc3_:DaeImage = null;
         var _loc1_:XMLList = data..image;
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = new DaeImage(_loc2_,document);
            if(_loc3_.id != null)
            {
               document.images[_loc3_.id] = _loc3_;
            }
         }
      }
      
      override protected function parseImplementation() : Boolean
      {
         var shader:XML;
         var element:XML = null;
         var param:DaeParam = null;
         var technique:XML = null;
         var bumpXML:XML = null;
         var diffuseXML:XML = null;
         var transparentXML:XML = null;
         var transparencyXML:XML = null;
         var ambientXML:XML = null;
         var reflectiveXML:XML = null;
         var emissionXML:XML = null;
         var specularXML:XML = null;
         this.effectParams = new Object();
         for each(element in data.newparam)
         {
            param = new DaeParam(element,document);
            this.effectParams[param.sid] = param;
         }
         this.commonParams = new Object();
         for each(element in data.profile_COMMON.newparam)
         {
            param = new DaeParam(element,document);
            this.commonParams[param.sid] = param;
         }
         this.techniqueParams = new Object();
         technique = data.profile_COMMON.technique[0];
         if(technique != null)
         {
            for each(element in technique.newparam)
            {
               param = new DaeParam(element,document);
               this.techniqueParams[param.sid] = param;
            }
         }
         shader = data.profile_COMMON.technique.*.(localName() == "constant" || localName() == "lambert" || localName() == "phong" || localName() == "blinn")[0];
         if(shader != null)
         {
            diffuseXML = null;
            if(shader.localName() == "constant")
            {
               diffuseXML = shader.emission[0];
            }
            else
            {
               diffuseXML = shader.diffuse[0];
               emissionXML = shader.emission[0];
               if(emissionXML != null)
               {
                  this.emission = new DaeEffectParam(emissionXML,this);
               }
            }
            if(diffuseXML != null)
            {
               this.diffuse = new DaeEffectParam(diffuseXML,this);
            }
            if(shader.localName() == "phong" || shader.localName() == "blinn")
            {
               specularXML = shader.specular[0];
               if(specularXML != null)
               {
                  this.specular = new DaeEffectParam(specularXML,this);
               }
            }
            transparentXML = shader.transparent[0];
            if(transparentXML != null)
            {
               this.transparent = new DaeEffectParam(transparentXML,this);
            }
            transparencyXML = shader.transparency[0];
            if(transparencyXML != null)
            {
               this.transparency = new DaeEffectParam(transparencyXML,this);
            }
            ambientXML = shader.ambient[0];
            if(ambientXML != null)
            {
               this.ambient = new DaeEffectParam(ambientXML,this);
            }
            reflectiveXML = shader.reflective[0];
            if(reflectiveXML != null)
            {
               this.reflective = new DaeEffectParam(reflectiveXML,this);
            }
         }
         bumpXML = data.profile_COMMON.technique.extra.technique.(Boolean(hasOwnProperty("@profile")) && @profile == "OpenCOLLADA3dsMax").bump[0];
         if(bumpXML != null)
         {
            this.bump = new DaeEffectParam(bumpXML,this);
         }
         return true;
      }
      
      internal function getParam(param1:String, param2:Object) : DaeParam
      {
         var _loc3_:DaeParam = param2[param1];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         _loc3_ = this.techniqueParams[param1];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         _loc3_ = this.commonParams[param1];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         return this.effectParams[param1];
      }
      
      private function float4ToUint(param1:Array, param2:Boolean = true) : uint
      {
         var _loc6_:uint = 0;
         var _loc3_:uint = param1[0] * 255;
         var _loc4_:uint = param1[1] * 255;
         var _loc5_:uint = param1[2] * 255;
         if(param2)
         {
            _loc6_ = param1[3] * 255;
            return _loc6_ << 24 | _loc3_ << 16 | _loc4_ << 8 | _loc5_;
         }
         return _loc3_ << 16 | _loc4_ << 8 | _loc5_;
      }
      
      public function getMaterial(param1:Object) : ParserMaterial
      {
         var _loc2_:ParserMaterial = null;
         if(this.diffuse != null)
         {
            _loc2_ = new ParserMaterial();
            if(this.diffuse)
            {
               this.pushMap(_loc2_,this.diffuse,param1);
            }
            if(this.specular != null)
            {
               this.pushMap(_loc2_,this.specular,param1);
            }
            if(this.emission != null)
            {
               this.pushMap(_loc2_,this.emission,param1);
            }
            if(this.transparency != null)
            {
               _loc2_.transparency = this.transparency.getFloat(param1);
            }
            if(this.transparent != null)
            {
               this.pushMap(_loc2_,this.transparent,param1);
            }
            if(this.bump != null)
            {
               this.pushMap(_loc2_,this.bump,param1);
            }
            if(this.ambient)
            {
               this.pushMap(_loc2_,this.ambient,param1);
            }
            if(this.reflective)
            {
               this.pushMap(_loc2_,this.reflective,param1);
            }
            return _loc2_;
         }
         return null;
      }
      
      private function pushMap(param1:ParserMaterial, param2:DaeEffectParam, param3:Object) : void
      {
         var _loc5_:DaeImage = null;
         var _loc4_:Array = param2.getColor(param3);
         if(_loc4_ != null)
         {
            param1.colors[cloneString(param2.data.localName())] = this.float4ToUint(_loc4_,true);
         }
         else
         {
            _loc5_ = param2.getImage(param3);
            if(_loc5_ != null)
            {
               param1.textures[cloneString(param2.data.localName())] = new ExternalTextureResource(cloneString(_loc5_.init_from));
            }
         }
      }
      
      public function get mainTexCoords() : String
      {
         var _loc1_:String = null;
         _loc1_ = _loc1_ == null && this.diffuse != null ? this.diffuse.texCoord : _loc1_;
         _loc1_ = _loc1_ == null && this.transparent != null ? this.transparent.texCoord : _loc1_;
         _loc1_ = _loc1_ == null && this.bump != null ? this.bump.texCoord : _loc1_;
         _loc1_ = _loc1_ == null && this.emission != null ? this.emission.texCoord : _loc1_;
         return _loc1_ == null && this.specular != null ? this.specular.texCoord : _loc1_;
      }
   }
}

