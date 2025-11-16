package thelaststand.common.lang
{
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class Language
   {
      
      private static var _instance:Language;
      
      private var _availableLanguages:Array;
      
      private var _langId:String;
      
      private var _languages:XML;
      
      private var _langXML:XML;
      
      public var defaultLanguage:String = "en";
      
      public function Language(param1:LanguageSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("Language is a Singleton and cannot be directly instantiated. Use Language.getInstance().");
         }
      }
      
      public static function getInstance() : Language
      {
         if(!_instance)
         {
            _instance = new Language(new LanguageSingletonEnforcer());
         }
         return _instance;
      }
      
      public function init() : void
      {
         this._languages = ResourceManager.getInstance().getResource("languages.xml").content;
         this._langId = this.defaultLanguage;
         this._availableLanguages = [];
         var _loc1_:XMLList = this._languages.lang;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length())
         {
            this._availableLanguages.push(_loc1_[_loc2_].@id.toString());
            _loc2_++;
         }
      }
      
      public function getFontName(param1:String, param2:String = "normal") : String
      {
         var fontNode:XML = null;
         var varNode:XML = null;
         var type:String = param1;
         var variation:String = param2;
         if(!this._langXML)
         {
            return "_sans";
         }
         fontNode = this._langXML.styles.type.(@id == type)[0];
         if(fontNode == null)
         {
            return "_sans";
         }
         varNode = fontNode["var"].(@id == variation)[0];
         return varNode != null ? varNode.toString() : "_sans";
      }
      
      public function getEnum(param1:String) : Array
      {
         if(!this._langXML)
         {
            throw new Error("No language file has been loaded.");
         }
         var _loc2_:XML = this._langXML.data[param1][0];
         if(!_loc2_)
         {
            throw new Error("Language enumerator \'" + param1 + "\' does not exist.");
         }
         var _loc3_:Array = [];
         var _loc4_:XMLList = _loc2_.children();
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc4_.length());
         while(_loc5_ < _loc6_)
         {
            _loc3_.push(_loc4_[_loc5_].toString());
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getEnumValue(param1:String, param2:int, ... rest) : String
      {
         if(!this._langXML)
         {
            throw new Error("No language file has been loaded.");
         }
         var _loc4_:XML = this._langXML.data[param1][0];
         if(!_loc4_)
         {
            throw new Error("Language enumerator \'" + param1 + "\' does not exist.");
         }
         var _loc5_:XMLList = _loc4_.children();
         if(param2 >= _loc5_.length())
         {
            return "?";
         }
         var _loc6_:String = _loc5_[param2].toString();
         var _loc7_:int = 0;
         var _loc8_:int = int(rest.length);
         while(_loc7_ < _loc8_)
         {
            _loc6_ = _loc6_.replace(/%s/i,rest[_loc7_]);
            _loc7_++;
         }
         return _loc6_;
      }
      
      public function getLanguageName(param1:String = null) : String
      {
         var node:XML;
         var id:String = param1;
         if(!id)
         {
            id = this._langId;
         }
         node = this._languages.lang.(@id == id)[0];
         if(!node)
         {
            throw new Error("Unknown language \'" + id + "\' supplied.");
         }
         return node.toString();
      }
      
      public function getString(param1:String, ... rest) : String
      {
         var _loc8_:XMLList = null;
         if(!this._langXML)
         {
            throw new Error("No language file has been loaded.");
         }
         var _loc3_:Array = param1.split(".");
         var _loc4_:XML = this._langXML.data[_loc3_[0]][0];
         if(_loc4_ == null)
         {
            return "?";
         }
         var _loc5_:int = 1;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc8_ = _loc4_[_loc3_[_loc5_]];
            if(_loc8_ == null)
            {
               return "?";
            }
            _loc4_ = _loc8_[0];
            if(_loc4_ == null)
            {
               return "?";
            }
            _loc5_++;
         }
         var _loc7_:String = _loc4_.toString();
         if(rest.length > 0)
         {
            _loc5_ = 0;
            _loc6_ = int(rest.length);
            while(_loc5_ < _loc6_)
            {
               _loc7_ = _loc7_.replace(/%s/i,rest[_loc5_]);
               _loc5_++;
            }
         }
         return _loc7_;
      }
      
      public function replaceVars(param1:String, ... rest) : String
      {
         var _loc3_:int = 0;
         var _loc4_:int = int(rest.length);
         while(_loc3_ < _loc4_)
         {
            param1 = param1.replace(/%s/i,rest[_loc3_]);
            _loc3_++;
         }
         return param1;
      }
      
      public function setLanguage(param1:String, param2:Boolean = false) : Boolean
      {
         var node:XML = null;
         var xmlURI:String = null;
         var fntURI:String = null;
         var res:Resource = null;
         var id:String = param1;
         var reload:Boolean = param2;
         node = this._languages.lang.(@id == id)[0];
         if(!node)
         {
            throw new Error("Unknown language \'" + id + "\' supplied.");
         }
         this._langId = id;
         xmlURI = "lang/" + node.@id.toString() + ".xml";
         fntURI = "lang/fonts/" + node.@id.toString() + ".swf";
         res = ResourceManager.getInstance().getResource(xmlURI);
         if(res == null || reload)
         {
            ResourceManager.getInstance().load(xmlURI,{
               "type":ResourceManager.TYPE_GZIP,
               "priority":int.MAX_VALUE,
               "overwrite":reload,
               "onComplete":this.onLanguageFileLoadComplete
            });
            ResourceManager.getInstance().load(fntURI,{
               "priority":int.MAX_VALUE - 1,
               "overwrite":reload
            });
            return false;
         }
         this._langXML = res.content.copy();
         return true;
      }
      
      private function onLanguageFileLoadComplete() : void
      {
         this._langXML = ResourceManager.getInstance().getResource("lang/" + this._langId + ".xml").content;
      }
      
      public function get availableLanguages() : Array
      {
         return this._availableLanguages.concat();
      }
      
      public function get languageId() : String
      {
         return this._langId;
      }
      
      public function get xml() : XML
      {
         return this._langXML;
      }
   }
}

class LanguageSingletonEnforcer
{
   
   public function LanguageSingletonEnforcer()
   {
      super();
   }
}
