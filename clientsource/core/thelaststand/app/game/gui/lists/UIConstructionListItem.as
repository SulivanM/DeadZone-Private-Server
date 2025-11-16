package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIConstructionListItem extends UIPagedListItem
   {
      
      private static const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,1,4,4,1,1);
      
      private static const MAXED_OUT_COLOR:ColorMatrix = new ColorMatrix();
      
      private static const UNBUILDABLE_COLOR:ColorMatrix = new ColorMatrix();
      
      MAXED_OUT_COLOR.desaturate();
      MAXED_OUT_COLOR.adjustBrightness(-50);
      UNBUILDABLE_COLOR.colorize(11599872,1);
      
      private const STROKE:GlowFilter = new GlowFilter(5460819,1,4,4,10,1);
      
      private var _imageWidth:int = 80;
      
      private var _imageHeight:int = 80;
      
      private var _borderSize:int = 2;
      
      private var _textAreaHeight:int = 30;
      
      private var _dataXML:XML;
      
      private var mc_textBackground:Sprite;
      
      private var mc_image:UIImage;
      
      private var mc_numBuild:Sprite;
      
      private var txt_label:BodyTextField;
      
      private var txt_numBuilt:BodyTextField;
      
      public function UIConstructionListItem()
      {
         super();
         mouseChildren = false;
         _width = int(this._imageWidth + this._borderSize * 2);
         _height = int(this._textAreaHeight + this._imageHeight);
         this.mc_textBackground = new Sprite();
         this.mc_textBackground.graphics.beginFill(1315860);
         this.mc_textBackground.graphics.drawRect(0,0,_width,this._textAreaHeight + this._borderSize);
         this.mc_textBackground.graphics.endFill();
         this.mc_textBackground.y = 0;
         this.mc_textBackground.alpha = 0;
         addChildAt(this.mc_textBackground,0);
         this.txt_label = new BodyTextField({
            "color":13158600,
            "size":11,
            "align":"center",
            "multiline":true
         });
         this.txt_label.width = _width;
         this.txt_label.height = this._textAreaHeight - 10;
         this.txt_label.text = " ";
         addChild(this.txt_label);
         this.mc_image = new UIImage(this._imageWidth,this._imageHeight);
         this.mc_image.x = this._borderSize;
         this.mc_image.y = int(this.mc_textBackground.y + this.mc_textBackground.height - this._borderSize);
         this.mc_image.filters = [this.STROKE,SHADOW];
         addChild(this.mc_image);
         this.txt_numBuilt = new BodyTextField({
            "color":Effects.COLOR_GOOD,
            "size":12,
            "bold":true
         });
         this.txt_numBuilt.text = "0 / 0";
         this.txt_numBuilt.filters = [Effects.TEXT_SHADOW];
         this.mc_numBuild = new Sprite();
         this.mc_numBuild.addChild(this.txt_numBuilt);
         addChild(this.mc_numBuild);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         TooltipManager.getInstance().add(this.mc_numBuild,Language.getInstance().getString("construct_numbuilt"),new Point(NaN,this.mc_numBuild.height),TooltipDirection.DIRECTION_UP);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this,true);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.mc_image.dispose();
         this.mc_image = null;
         this.txt_label.dispose();
         this.txt_label = null;
         this.txt_numBuilt.dispose();
         this.txt_numBuilt = null;
         this._dataXML = null;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected || !enabled)
         {
            return;
         }
         TweenMax.to(this.mc_image,0.1,{"glowFilter":{"color":11184810}});
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected || !enabled)
         {
            return;
         }
         TweenMax.to(this.mc_image,0.25,{"glowFilter":{"color":5460819}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected || !enabled)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get dataXML() : XML
      {
         return this._dataXML;
      }
      
      public function set dataXML(param1:XML) : void
      {
         this._dataXML = param1;
         id = this._dataXML.@id.toString();
         this.mc_image.uri = this._dataXML.img.@uri.toString();
         this.txt_label.text = Language.getInstance().getString("blds." + this._dataXML.@id.toString()).toUpperCase();
         this.txt_label.y = int(this.mc_textBackground.y + (this.mc_textBackground.height - this.txt_label.height) * 0.5) - 2;
         var _loc2_:int = int(this._dataXML.@max.toString());
         var _loc3_:int = Network.getInstance().playerData.compound.buildings.getNumBuildingsOfType(id);
         var _loc4_:* = _loc3_ >= _loc2_;
         var _loc5_:Boolean = _loc4_ ? false : Network.getInstance().playerData.canBuildBuilding(id,0);
         if(Tutorial.getInstance().active)
         {
            if(!Tutorial.getInstance().isBuildingAllowed(id,Tutorial.getInstance().step == Tutorial.STEP_COMFORT ? 2 : 1))
            {
               _loc5_ = false;
               _loc4_ = true;
            }
         }
         this.txt_numBuilt.textColor = _loc4_ ? 6710886 : (_loc5_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING);
         this.txt_numBuilt.text = _loc3_ + " / " + _loc2_;
         this.mc_numBuild.x = int(_width - this.mc_numBuild.width - 3);
         this.mc_numBuild.y = int(_height - this.mc_numBuild.height);
         this.mc_numBuild.visible = !this._dataXML.hasOwnProperty("@showmax") || this._dataXML.@showmax != "0";
         this.mc_image.filters = _loc4_ ? [this.STROKE,SHADOW,MAXED_OUT_COLOR.filter] : (_loc5_ ? [this.STROKE,SHADOW] : [this.STROKE,SHADOW,UNBUILDABLE_COLOR.filter]);
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         TweenMax.to(this.mc_textBackground,0.15,{"alpha":(selected ? 1 : 0)});
         TweenMax.to(this.mc_image,0.1,{"glowFilter":{"color":(selected ? 16777215 : 5460819)}});
      }
   }
}

