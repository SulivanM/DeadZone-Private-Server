package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.utils.Object3DUtils;
   import com.exileetiquette.math.SeedRandom;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.objects.GameEntity;
   
   public class StreetStructure extends GameEntity
   {
      
      private static var _buildingSets:XML;
      
      public function StreetStructure(param1:String = null)
      {
         if(!_buildingSets)
         {
            _buildingSets = ResourceManager.getInstance().getResource("xml/streetstructs.xml").content;
         }
         super(param1,new Object3D());
         asset.mouseEnabled = asset.mouseChildren = false;
      }
      
      public function generate(param1:String, param2:Number = 0, param3:int = -1, param4:int = -1) : void
      {
         var setData:XML = null;
         var resources:ResourceManager = null;
         var randomizer:SeedRandom = null;
         var rand:int = 0;
         var texNode:XML = null;
         var texURI:String = null;
         var specURI:String = null;
         var normURI:String = null;
         var mat:StandardMaterial = null;
         var base:Mesh = null;
         var tz:int = 0;
         var bldMinFloors:int = 0;
         var bldMaxFloors:int = 0;
         var numFloors:int = 0;
         var i:int = 0;
         var body:Mesh = null;
         var top:Mesh = null;
         var roof:Mesh = null;
         var setId:String = param1;
         var seed:Number = param2;
         var minFloors:int = param3;
         var maxFloors:int = param4;
         setData = _buildingSets.set.(@id == setId)[0];
         if(!setData)
         {
            return;
         }
         resources = ResourceManager.getInstance();
         randomizer = new SeedRandom(seed);
         rand = randomizer.getIntInRange(0,setData.tex.length());
         texNode = setData.tex[rand];
         texURI = texNode.@uri.toString();
         normURI = "textures/normal-flat";
         if(texNode.hasOwnProperty("spc"))
         {
            specURI = texNode.spc[0].@uri.toString();
         }
         if(texNode.hasOwnProperty("nrm"))
         {
            normURI = texNode.nrm[0].@uri.toString();
         }
         mat = ResourceManager.getInstance().materials.getStandardMaterial(texURI,texURI,normURI,specURI);
         if(specURI)
         {
            mat.specularPower = 1;
         }
         if(setData.base.length() > 0)
         {
            rand = randomizer.getIntInRange(0,setData.base.length());
            base = Mesh(ParserCollada(resources.getResource(setData.base[rand].@uri.toString()).content).objects[0]).clone() as Mesh;
            base.calculateBoundBox();
            base.setMaterialToAllSurfaces(mat);
            base.name = "base";
            asset.addChild(base);
         }
         if(setData.body.length() > 0)
         {
            tz = base.boundBox.maxZ;
            bldMinFloors = Math.max(minFloors,setData.hasOwnProperty("@minfloors") ? int(setData.@minfloors.toString()) : 0);
            bldMaxFloors = int(setData.@maxfloors.toString());
            bldMinFloors = maxFloors == -1 ? bldMinFloors : int(Math.min(bldMinFloors,maxFloors));
            bldMaxFloors = maxFloors == -1 ? bldMaxFloors : int(Math.min(bldMaxFloors,maxFloors));
            numFloors = randomizer.getIntInRange(bldMinFloors,bldMaxFloors);
            i = 0;
            while(i < numFloors)
            {
               rand = randomizer.getIntInRange(0,setData.body.length());
               body = Mesh(ParserCollada(resources.getResource(setData.body[rand].@uri.toString()).content).objects[0]).clone() as Mesh;
               body.calculateBoundBox();
               body.setMaterialToAllSurfaces(mat);
               body.name = "floor" + i;
               body.z = tz;
               asset.addChild(body);
               tz += body.boundBox.maxZ;
               i++;
            }
         }
         if(setData.top.length() > 0)
         {
            rand = randomizer.getIntInRange(0,setData.top.length());
            top = Mesh(ParserCollada(resources.getResource(setData.top[rand].@uri.toString()).content).objects[0]).clone() as Mesh;
            top.calculateBoundBox();
            top.setMaterialToAllSurfaces(mat);
            top.name = "top";
            top.z = tz;
            asset.addChild(top);
            tz += top.boundBox.maxZ;
         }
         if(setData.roof.length() > 0)
         {
            rand = randomizer.getIntInRange(0,setData.roof.length());
            roof = Mesh(ParserCollada(resources.getResource(setData.roof[rand].@uri.toString()).content).objects[0]).clone() as Mesh;
            roof.calculateBoundBox();
            roof.setMaterialToAllSurfaces(mat);
            roof.name = "roof";
            roof.z = tz;
            asset.addChild(roof);
         }
         asset.boundBox = new BoundBox();
         Object3DUtils.calculateHierarchyBoundBox(asset,asset,asset.boundBox);
      }
   }
}

