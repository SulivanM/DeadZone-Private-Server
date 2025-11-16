package thelaststand.app.game.map
{
   import flash.display.BitmapData;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Timer;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.textures.Texture;
   import thelaststand.app.core.Global;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class MapStarlingLayer extends Sprite
   {
      
      private static var TEMP_TEXTURE:Texture;
      
      private static var defaultBmd:BitmapData;
      
      private var _offsetContainer:Sprite;
      
      private var _container:Sprite;
      
      private var _bgGrid:BackgroundGrid;
      
      private var _mapTileContainer:Sprite;
      
      private var _suburbOverlay:Sprite;
      
      private var _cols:int;
      
      private var _rows:int;
      
      private var _cellWidth:int;
      
      private var _cellHeight:int;
      
      private var _mapWidth:int;
      
      private var _mapHeight:int;
      
      private var _resouceManager:ResourceManager;
      
      private var _textures_low:Vector.<Texture>;
      
      private var _textures_high:Vector.<Texture>;
      
      private var _tiles:Vector.<Image>;
      
      private var _offsetX:int;
      
      private var offsetY:int;
      
      private var _allowhighResTextures:Boolean = false;
      
      private var _highresRedrawTimer:Timer;
      
      public function MapStarlingLayer()
      {
         super();
         if(TEMP_TEXTURE == null)
         {
            TEMP_TEXTURE = Texture.fromColor(1,1,0);
         }
      }
      
      public function init(param1:XML) : void
      {
         var _loc5_:Image = null;
         var _loc6_:Quad = null;
         var _loc8_:int = 0;
         var _loc2_:XML = param1.size[0];
         this._cols = int(_loc2_.@cols);
         this._rows = int(_loc2_.@rows);
         this._cellWidth = int(_loc2_.@width);
         this._cellHeight = int(_loc2_.@height);
         this._mapWidth = this._cols * this._cellWidth;
         this._mapHeight = this._rows * this._cellHeight;
         this._offsetContainer = new Sprite();
         addChild(this._offsetContainer);
         this._container = new Sprite();
         this._offsetContainer.addChild(this._container);
         this._bgGrid = new BackgroundGrid(this._cols,this._rows,this._cellWidth,this._cellHeight);
         this._container.addChild(this._bgGrid);
         this._mapTileContainer = new Sprite();
         this._container.addChild(this._mapTileContainer);
         this._suburbOverlay = new Sprite();
         this._container.addChild(this._suburbOverlay);
         this._resouceManager = ResourceManager.getInstance("map");
         this._resouceManager.baseURL = ResourceManager.getInstance().baseURL;
         if(Global.stage.loaderInfo.parameters.local != "1")
         {
            this._resouceManager.uriProcessor = Global.processResourceURI;
         }
         this._resouceManager.loadSequentially = false;
         this._resouceManager.resourceLoadCompleted.add(this.onResouceLoadComplete);
         this._resouceManager.queueLoadCompleted.addOnce(this.onLowResQueueComplete);
         var _loc3_:int = this._cols * this._rows;
         this._textures_low = new Vector.<Texture>(_loc3_,true);
         this._textures_high = new Vector.<Texture>(_loc3_,true);
         this._tiles = new Vector.<Image>(_loc3_,true);
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         while(_loc7_ < this._rows)
         {
            _loc8_ = 0;
            while(_loc8_ < this._cols)
            {
               _loc5_ = new Image(TEMP_TEXTURE);
               _loc5_.x = _loc8_ * this._cellWidth;
               _loc5_.y = _loc7_ * this._cellHeight;
               this._tiles[_loc4_] = _loc5_;
               this._mapTileContainer.addChild(_loc5_);
               this._resouceManager.load("map/tiles/low/map_" + _loc4_ + ".jpg",{"data":{
                  "type":"low",
                  "col":_loc8_,
                  "row":_loc7_,
                  "index":_loc4_
               }});
               _loc4_++;
               _loc8_++;
            }
            _loc7_++;
         }
         this._highresRedrawTimer = new Timer(200,1);
         this._highresRedrawTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.calculateHighResImages,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         removeChildren(0,-1,true);
         this._resouceManager.dispose();
         this._highresRedrawTimer.stop();
         this._highresRedrawTimer.removeEventListener(TimerEvent.TIMER,this.calculateHighResImages);
      }
      
      public function applyTransform(param1:Matrix) : void
      {
         this._container.transformationMatrix = param1;
         if(this._allowhighResTextures)
         {
            this._highresRedrawTimer.stop();
            this._highresRedrawTimer.reset();
            this._highresRedrawTimer.start();
         }
      }
      
      public function addSuburbTexture(param1:BitmapData, param2:Number, param3:Number) : Image
      {
         var t:Texture;
         var img:Image;
         var test:int = 0;
         var bd:BitmapData = param1;
         var xPos:Number = param2;
         var yPos:Number = param3;
         try
         {
            test = bd.width;
         }
         catch(e:Error)
         {
            if(defaultBmd == null)
            {
               defaultBmd = new BitmapData(2,2,false,0);
            }
            bd = defaultBmd;
         }
         t = Texture.fromBitmapData(bd);
         img = new Image(t);
         img.x = xPos;
         img.y = yPos;
         this._suburbOverlay.addChild(img);
         this._suburbOverlay.flatten();
         return img;
      }
      
      private function onResouceLoadComplete(param1:Resource) : void
      {
         var _loc2_:Texture = null;
         var _loc3_:Image = null;
         var _loc4_:Object = param1.data;
         switch(_loc4_.type)
         {
            case "high":
            case "low":
               _loc2_ = Texture.fromBitmapData(param1.content);
               BitmapData(param1.content).dispose();
               if(_loc4_.type == "high")
               {
                  this._textures_high[_loc4_.index] = _loc2_;
               }
               else
               {
                  this._textures_low[_loc4_.index] = _loc2_;
               }
               _loc3_ = this._tiles[_loc4_.index];
               _loc3_.texture = _loc2_;
               _loc3_.width = this._cellWidth;
               _loc3_.height = this._cellHeight;
         }
      }
      
      private function onLowResQueueComplete() : void
      {
         this._allowhighResTextures = true;
         this.calculateHighResImages();
      }
      
      private function calculateHighResImages(param1:TimerEvent = null) : void
      {
         var _loc10_:int = 0;
         var _loc11_:* = null;
         var _loc2_:Point = this._container.globalToLocal(localToGlobal(new Point(0,0)));
         var _loc3_:Point = this._container.globalToLocal(localToGlobal(new Point(stage.stageWidth,stage.stageHeight)));
         var _loc4_:int = Math.floor(_loc2_.x / this._cellWidth);
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         var _loc5_:int = Math.floor(_loc2_.y / this._cellHeight);
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         var _loc6_:int = Math.floor(_loc3_.x / this._cellWidth);
         if(_loc6_ > this._cols - 1)
         {
            _loc6_ = this._cols - 1;
         }
         var _loc7_:int = Math.floor(_loc3_.y / this._cellHeight);
         if(_loc7_ > this._rows - 1)
         {
            _loc7_ = this._rows - 1;
         }
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         while(_loc9_ < this._rows)
         {
            _loc10_ = 0;
            while(_loc10_ < this._cols)
            {
               _loc11_ = "map/tiles/high/map_" + _loc8_ + ".jpg";
               if(_loc10_ >= _loc4_ && _loc10_ <= _loc6_ && _loc9_ >= _loc5_ && _loc9_ <= _loc7_)
               {
                  if(this._textures_high[_loc8_])
                  {
                     if(this._tiles[_loc8_].texture != this._textures_high[_loc8_])
                     {
                        this._tiles[_loc8_].texture = this._textures_high[_loc8_];
                     }
                  }
                  else if(this._resouceManager.exists(_loc11_) == false)
                  {
                     this._resouceManager.load(_loc11_,{"data":{
                        "type":"high",
                        "col":_loc10_,
                        "row":_loc9_,
                        "index":_loc8_
                     }});
                  }
               }
               else
               {
                  if(this._textures_high[_loc8_])
                  {
                     this._tiles[_loc8_].texture = this._textures_low[_loc8_];
                     this._textures_high[_loc8_].dispose();
                     this._textures_high[_loc8_] = null;
                  }
                  if(this._resouceManager.exists(_loc11_))
                  {
                     this._resouceManager.purge(_loc11_);
                  }
               }
               _loc8_++;
               _loc10_++;
            }
            _loc9_++;
         }
      }
      
      public function get topOffset() : int
      {
         return this._offsetContainer.y;
      }
      
      public function set topOffset(param1:int) : void
      {
         this._offsetContainer.y = param1;
      }
   }
}

import starling.display.Quad;
import starling.display.Sprite;

class BackgroundGrid extends Sprite
{
   
   public function BackgroundGrid(param1:int, param2:int, param3:int, param4:int)
   {
      super();
      var _loc5_:Quad = new Quad(param1 * param3,param2 * param4,0);
      addChild(_loc5_);
      this.drawGridLines(param1,param2,param3,param4,3026478,4);
      this.drawGridLines(param1,param2,param3,param4,0,2);
      flatten();
   }
   
   private function drawGridLines(param1:int, param2:int, param3:int, param4:int, param5:uint, param6:int, param7:int = 4) : void
   {
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:Quad = null;
      _loc8_ = 0;
      while(_loc8_ < param1)
      {
         _loc9_ = 0;
         while(_loc9_ < param7)
         {
            _loc10_ = new Quad(param6,param2 * param4,param5);
            _loc10_.x = _loc8_ * param3 + _loc9_ * (param3 / param7) - param6 * 0.5;
            addChild(_loc10_);
            _loc9_++;
         }
         _loc8_++;
      }
      _loc8_ = 0;
      while(_loc8_ < param2)
      {
         _loc9_ = 0;
         while(_loc9_ < param7)
         {
            _loc10_ = new Quad(param1 * param4,param6,param5);
            _loc10_.y = _loc8_ * param4 + _loc9_ * (param4 / param7) - param6 * 0.5;
            addChild(_loc10_);
            _loc9_++;
         }
         _loc8_++;
      }
   }
}
