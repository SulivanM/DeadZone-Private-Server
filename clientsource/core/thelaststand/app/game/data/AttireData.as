package thelaststand.app.game.data
{
   import thelaststand.common.resources.ResourceManager;
   
   public class AttireData
   {
      
      public var id:String;
      
      public var type:String;
      
      public var model:String;
      
      public var texture:String;
      
      public var tint:Number = NaN;
      
      public var hue:Number = NaN;
      
      public var brightness:Number = NaN;
      
      public var modifiedTextureURI:String;
      
      public var modifiedTexture:Boolean;
      
      public var uniqueTexture:Boolean;
      
      public var overlays:Vector.<AttireOverlay> = new Vector.<AttireOverlay>();
      
      public var children:Vector.<AttireData> = new Vector.<AttireData>();
      
      public var flags:uint = 0;
      
      public function AttireData(param1:String = null)
      {
         super();
         this.type = param1;
      }
      
      public function clone() : AttireData
      {
         var _loc2_:AttireOverlay = null;
         var _loc3_:AttireData = null;
         var _loc1_:AttireData = new AttireData();
         _loc1_.id = this.id;
         _loc1_.type = this.type;
         _loc1_.brightness = this.brightness;
         _loc1_.hue = this.hue;
         _loc1_.model = this.model;
         _loc1_.modifiedTexture = this.modifiedTexture;
         _loc1_.modifiedTextureURI = this.modifiedTextureURI;
         _loc1_.texture = this.texture;
         _loc1_.uniqueTexture = this.uniqueTexture;
         _loc1_.flags = this.flags;
         _loc1_.tint = this.tint;
         for each(_loc2_ in this.overlays)
         {
            _loc1_.overlays.push(_loc2_.clone());
         }
         for each(_loc3_ in this.children)
         {
            _loc1_.children.push(_loc3_.clone());
         }
         return _loc1_;
      }
      
      public function clear() : void
      {
         this.id = null;
         this.model = null;
         this.texture = null;
         this.hue = NaN;
         this.brightness = NaN;
         this.modifiedTexture = false;
         this.modifiedTextureURI = null;
         this.uniqueTexture = false;
         this.tint = NaN;
         this.flags = AttireFlags.NONE;
         this.overlays.length = 0;
         this.children.length = 0;
      }
      
      public function getResourceURIs(param1:Array = null) : Array
      {
         var _loc2_:AttireOverlay = null;
         param1 ||= [];
         if(this.model != null)
         {
            param1.push(this.model);
         }
         if(this.texture != null)
         {
            param1.push(this.texture);
         }
         for each(_loc2_ in this.overlays)
         {
            param1.push(_loc2_.texture);
         }
         return param1;
      }
      
      public function parseXML(param1:XML, param2:String) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         this.clear();
         if(param1 == null)
         {
            return;
         }
         this.id = "@id" in param1 ? param1.@id.toString() : null;
         this.type = "@type" in param1 ? param1.@type.toString() : null;
         this.setFlagsFromXML(param1.flag);
         this.addChildrenFromXML(param1.child,param2);
         for each(_loc3_ in param1.overlay)
         {
            this.overlays.push(new AttireOverlay(_loc3_.@type.toString(),_loc3_.@uri.toString()));
         }
         _loc4_ = param1[param2][0];
         if(!_loc4_)
         {
            this.model = param1.mdl[0] != null ? param1.mdl.@uri.toString() : null;
            this.texture = param1.tex[0] != null ? param1.tex.@uri.toString() : null;
         }
         else
         {
            this.model = _loc4_.mdl[0] != null ? _loc4_.mdl.@uri.toString() : null;
            this.texture = _loc4_.tex[0] != null ? _loc4_.tex.@uri.toString() : null;
            this.setFlagsFromXML(_loc4_.flag);
            this.addChildrenFromXML(_loc4_.child,param2);
            for each(_loc3_ in _loc4_.overlay)
            {
               this.overlays.push(new AttireOverlay(_loc3_.@type.toString(),_loc3_.@uri.toString()));
            }
         }
      }
      
      private function addChildrenFromXML(param1:XMLList, param2:String) : void
      {
         var node:XML = null;
         var childNode:XML = null;
         var child:AttireData = null;
         var childrenList:XMLList = param1;
         var gender:String = param2;
         var xml:XML = ResourceManager.getInstance().get("xml/attire.xml") as XML;
         if(!xml)
         {
            return;
         }
         for each(node in childrenList)
         {
            childNode = xml.item.(@id == node.toString())[0];
            if(childNode != null)
            {
               child = new AttireData();
               child.parseXML(childNode,gender);
               this.children.push(child);
            }
         }
      }
      
      private function setFlagsFromXML(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:uint = 0;
         for each(_loc2_ in param1)
         {
            _loc3_ = uint(AttireFlags[_loc2_.toString().toUpperCase()]);
            if(_loc3_ == 0)
            {
               throw new Error("Invalid attire flag \'" + _loc2_.toString() + "\'");
            }
            this.flags |= _loc3_;
         }
      }
   }
}

