package thelaststand.app.game.scenes
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.ResourceManager;
   
   public class SceneLoader
   {
      
      private var _sceneXML:XML;
      
      private var _setURI:String;
      
      private var _resources:ResourceManager;
      
      private var _assetLoader:AssetLoader;
      
      private var _XMLLoader:AssetLoader;
      
      public var loadCompleted:Signal;
      
      public var data:*;
      
      public function SceneLoader()
      {
         super();
         this._resources = ResourceManager.getInstance();
         this._assetLoader = new AssetLoader();
         this._XMLLoader = new AssetLoader();
         this.loadCompleted = new Signal(SceneLoader);
      }
      
      public static function generateRandomSetObjects(param1:XML, param2:Array = null) : XML
      {
         var node:XML = null;
         var objNode:XML = null;
         var mdlNodes:XMLList = null;
         var texNodes:XMLList = null;
         var nodesById:Dictionary = null;
         var texNode:XML = null;
         var mdlNodeIndex:int = 0;
         var texNodeIndex:int = 0;
         var id:String = null;
         var list:Array = null;
         var inputSetNode:XML = param1;
         var assetList:Array = param2;
         var output:XML = <objects></objects>;
         for each(node in inputSetNode.children())
         {
            objNode = new XML("<" + node.localName() + "/>");
            mdlNodes = node.mdl;
            if(mdlNodes.length() > 0)
            {
               mdlNodeIndex = int(Math.random() * mdlNodes.length());
               objNode.@mdl = mdlNodeIndex;
               if(assetList != null)
               {
                  assetList.push(mdlNodes[mdlNodeIndex].@uri.toString());
               }
            }
            texNodes = node.tex.(!hasOwnProperty("@id"));
            if(texNodes.length() > 0)
            {
               texNodeIndex = int(Math.random() * texNodes.length());
               objNode.@tex = texNodeIndex;
               if(assetList != null)
               {
                  assetList.push(texNodes[texNodeIndex].@uri.toString());
               }
            }
            nodesById = new Dictionary(true);
            for each(texNode in node.tex.(hasOwnProperty("@id")))
            {
               id = texNode.@id.toString();
               list = nodesById[id];
               if(list == null)
               {
                  list = nodesById[id] = [];
               }
               list.push(texNode);
            }
            for(id in nodesById)
            {
               list = nodesById[id];
               texNode = list[int(Math.random() * list.length)];
               objNode.appendChild(XML("<" + id + ">" + texNode.childIndex() + "</" + id + ">"));
            }
            output.appendChild(objNode);
         }
         return output;
      }
      
      public function close(param1:Boolean = false) : void
      {
         if(param1)
         {
            this._assetLoader.purgeLoadedAssets();
         }
         this._assetLoader.clear(param1);
         this._XMLLoader.clear(param1);
         this._sceneXML = null;
      }
      
      public function dispose() : void
      {
         this._XMLLoader.dispose(true);
         this._XMLLoader = null;
         this._assetLoader.purgeLoadedAssets();
         this._assetLoader.dispose(true);
         this._assetLoader = null;
         this._resources = null;
         this._sceneXML = null;
      }
      
      public function load(param1:XML, param2:Array = null) : void
      {
         this._sceneXML = param1;
         this._XMLLoader.clear(true);
         this._assetLoader.clear(true);
         this._assetLoader.loadingCompleted.remove(this.onAllAssetsCompleted);
         var _loc3_:Array = [];
         if(param2 != null)
         {
            this._assetLoader.loadAssets(param2);
         }
         var _loc4_:XML = this._sceneXML.set[0];
         if(_loc4_ != null)
         {
            _loc3_.push("xml/scenes/" + _loc4_.toString() + ".xml");
         }
         var _loc5_:XML = this._sceneXML.structs[0];
         if(_loc5_ != null)
         {
            _loc3_.push("xml/streetstructs.xml");
         }
         this._XMLLoader.loadingCompleted.addOnce(this.loadSceneAssets);
         this._XMLLoader.loadAssets(_loc3_);
      }
      
      private function loadSceneAssets() : void
      {
         var setNode:XML;
         var structsNode:XML;
         var uriList:XMLList;
         var assetList:Array = null;
         var node:XML = null;
         var interiorSet:XML = null;
         var wallNodeIndex:int = 0;
         var floorNodeIndex:int = 0;
         var wallNode:XML = null;
         var floorNode:XML = null;
         var structType:String = null;
         var structSets:XMLList = null;
         assetList = [];
         if(this._sceneXML.scene_mdl.mdl[0] != null)
         {
            assetList.push(this._sceneXML.scene_mdl.mdl.@uri.toString());
         }
         setNode = this._sceneXML.set[0];
         if(setNode != null)
         {
            interiorSet = this._resources.getResource("xml/scenes/" + setNode.toString() + ".xml").content;
            wallNodeIndex = int(Math.random() * interiorSet.walls.tex.length());
            floorNodeIndex = int(Math.random() * interiorSet.floor.tex.length());
            wallNode = interiorSet.walls.tex[wallNodeIndex];
            floorNode = interiorSet.floor.tex[floorNodeIndex];
            setNode.@wallIndex = wallNodeIndex;
            setNode.@floorIndex = floorNodeIndex;
            if(wallNode != null)
            {
               assetList.push(wallNode.@uri.toString());
            }
            if(floorNode != null)
            {
               assetList.push(floorNode.@uri.toString());
            }
            setNode.appendChild(generateRandomSetObjects(interiorSet.objects[0],assetList));
         }
         structsNode = this._sceneXML.structs[0];
         if(structsNode != null)
         {
            structType = this._sceneXML.structs.@type.toString();
            structSets = ResourceManager.getInstance().getResource("xml/streetstructs.xml").content.set.(@type.toString().indexOf(structType) > -1);
            for each(node in structSets.descendants().(hasOwnProperty("@uri")))
            {
               assetList.push(node.@uri.toString());
            }
         }
         if(this._sceneXML.type == "compound")
         {
            for each(node in ResourceManager.getInstance().getResource("xml/buildings.xml").content.item.(@type == "junk"))
            {
               assetList.push(node.mdl.@uri.toString());
            }
         }
         uriList = this._sceneXML.descendants().(hasOwnProperty("@uri"));
         for each(node in uriList)
         {
            assetList.push(node.@uri.toString());
         }
         this._assetLoader.loadingCompleted.addOnce(this.onAllAssetsCompleted);
         this._assetLoader.loadAssets(assetList);
      }
      
      private function onAllAssetsCompleted() : void
      {
         this.loadCompleted.dispatch(this);
      }
      
      public function get sceneXML() : XML
      {
         return this._sceneXML;
      }
   }
}

