package thelaststand.app.utils
{
   import com.exileetiquette.math.SeedRandom;
   
   public class SceneRandomizer
   {
      
      public function SceneRandomizer()
      {
         super();
      }
      
      public static function generateRandomSceneXML(param1:XML, param2:SeedRandom = null) : XML
      {
         var entParentNode:XML;
         var node:XML = null;
         var sModNode:XML = null;
         var entNode:XML = null;
         var att:XML = null;
         var childNode:XML = null;
         var optNode:XML = null;
         var modelNode:XML = null;
         var child:XML = null;
         var src:XML = param1;
         var rand:SeedRandom = param2;
         var out:XML = <scene></scene>;
         if(rand == null)
         {
            rand = new SeedRandom();
         }
         for each(node in src.children())
         {
            switch(node.localName())
            {
               case "ent":
               case "scene_mdl":
                  break;
               case "sets":
                  if(node.set.length() > 0)
                  {
                     out.appendChild(node.set[0]);
                  }
                  break;
               default:
                  out.appendChild(node);
            }
         }
         node = src.scene_mdl[rand.getIntInRange(0,src.scene_mdl.length())];
         if(node)
         {
            out.appendChild(<scene_mdl></scene_mdl>);
            for each(sModNode in node.mdl)
            {
               out.scene_mdl.appendChild(generateRandomModelData(sModNode,rand));
            }
         }
         entParentNode = <ent></ent>;
         for each(node in src.ent.light)
         {
            entParentNode.appendChild(node.copy());
         }
         for each(node in src.ent.e.(Boolean(hasOwnProperty("opt")) && opt.length() > 0))
         {
            if(true)
            {
               if(node.@junk[0] != null)
               {
                  continue;
               }
            }
            entNode = <e></e>;
            for each(att in node.attributes())
            {
               entNode[att.name()] = att.toString();
            }
            for each(childNode in node.children())
            {
               if(childNode.localName() != "opt")
               {
                  entNode.appendChild(childNode.copy());
               }
            }
            optNode = node.opt[rand.getIntInRange(0,node.opt.length())];
            modelNode = optNode.mdl[rand.getIntInRange(0,optNode.mdl.length())];
            if(modelNode)
            {
               entNode.appendChild(generateRandomModelData(modelNode,rand));
            }
            for each(child in optNode.children())
            {
               switch(child.localName())
               {
                  case "mdl":
                     break;
                  default:
                     entNode.appendChild(child.copy());
               }
            }
            entParentNode.appendChild(entNode);
         }
         out.appendChild(entParentNode);
         return out;
      }
      
      public static function getAssetURIListFromSceneXML(param1:XML) : Array
      {
         var out:Array = null;
         var uriList:XMLList = null;
         var n:XML = null;
         var scene:XML = param1;
         out = [];
         uriList = scene.descendants().(hasOwnProperty("@uri"));
         for each(n in uriList)
         {
            out.push(n.@uri.toString());
         }
         return out;
      }
      
      private static function generateRandomModelData(param1:XML, param2:SeedRandom) : XML
      {
         var out:XML = null;
         var node:XML = null;
         var len:int = 0;
         var i:int = 0;
         var texList:XMLList = null;
         var texIds:Array = null;
         var id:String = null;
         var input:XML = param1;
         var rand:SeedRandom = param2;
         out = <mdl></mdl>;
         for each(node in input.attributes())
         {
            out[node.name()] = node.toString();
         }
         texList = input.tex.(!hasOwnProperty("@id"));
         if(texList.length() > 0)
         {
            node = texList[rand.getIntInRange(0,texList.length())];
            out.appendChild(node.copy());
         }
         texIds = [];
         for each(node in input.tex.(hasOwnProperty("@id")))
         {
            id = node.@id.toString();
            if(texIds.indexOf(id) <= -1)
            {
               texIds.push(id);
            }
         }
         i = 0;
         len = int(texIds.length);
         while(i < len)
         {
            texList = input.tex.(Boolean(hasOwnProperty("@id")) && @id == texIds[i]);
            node = texList[rand.getIntInRange(0,texList.length())];
            out.appendChild(node.copy());
            i++;
         }
         return out;
      }
   }
}

