package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.utils.getDefinitionByName;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   
   public class UISurvivorBar extends Sprite
   {
      
      private var _survivors:Vector.<Survivor>;
      
      private var _survivorDisplays:Vector.<UISurvivorBarItem>;
      
      private var _survivorsNotInExitZones:Vector.<Survivor>;
      
      private var _selected:UISurvivorBarItem;
      
      private var _padding:int = 8;
      
      private var _width:int = 10;
      
      private var _height:int = 58;
      
      private var mc_background:Shape;
      
      private var mc_container:Sprite;
      
      private var txt_name:BodyTextField;
      
      private var bmp_classIcon:Bitmap;
      
      public var survivorSelected:Signal;
      
      public var activeGearSelected:Signal;
      
      public var isPvP:Boolean = false;
      
      public function UISurvivorBar()
      {
         super();
         this._survivorDisplays = new Vector.<UISurvivorBarItem>();
         this.mc_background = new Shape();
         addChild(this.mc_background);
         this.mc_container = new Sprite();
         addChild(this.mc_container);
         this.txt_name = new BodyTextField({
            "color":16777215,
            "text":" ",
            "size":13,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_name.alpha = 0;
         this.txt_name.visible = false;
         this.bmp_classIcon = new Bitmap();
         this.bmp_classIcon.alpha = 0;
         this.bmp_classIcon.visible = false;
         this.survivorSelected = new Signal(Survivor);
         this.activeGearSelected = new Signal(Survivor);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._survivors = null;
         this._selected = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._survivorDisplays.length)
         {
            this._survivorDisplays[_loc1_].removeEventListener(MouseEvent.CLICK,this.onClickSurvivor);
            this._survivorDisplays[_loc1_].dispose();
            _loc1_++;
         }
         this._survivorDisplays = null;
         if(this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
            this.bmp_classIcon.bitmapData = null;
         }
      }
      
      public function setExitZoneDisplay(param1:Boolean) : void
      {
         var _loc3_:UISurvivorBarItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._survivorDisplays.length)
         {
            _loc3_ = this._survivorDisplays[_loc2_];
            if(param1)
            {
               _loc3_.exitZoneState = this._survivorsNotInExitZones.indexOf(_loc3_.survivor) > -1 ? UISurvivorBarItem.EXIT_ZONE_STATE_OUT : UISurvivorBarItem.EXIT_ZONE_STATE_IN;
            }
            else
            {
               _loc3_.exitZoneState = UISurvivorBarItem.EXIT_ZONE_STATE_NONE;
            }
            _loc2_++;
         }
      }
      
      public function selectSurvivor(param1:Survivor) : void
      {
         var _loc4_:UISurvivorBarItem = null;
         if(this._selected != null && this._selected.survivor != param1)
         {
            this._selected.selected = false;
         }
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._survivorDisplays.length)
         {
            _loc4_ = this._survivorDisplays[_loc3_];
            if(_loc4_.survivor == param1)
            {
               this._selected = _loc4_;
               this._selected.selected = true;
            }
            if(stage != null)
            {
               TweenMax.to(_loc4_,0.25,{
                  "x":_loc2_,
                  "ease":Cubic.easeOut
               });
            }
            else
            {
               _loc4_.x = _loc2_;
            }
            _loc2_ += _loc4_.width + 10;
            _loc3_++;
         }
         _loc2_ = int(this.mc_background.x + (this.mc_background.width - (_loc2_ - 10)) * 0.5);
         if(stage != null)
         {
            TweenMax.to(this.mc_container,0.25,{
               "x":_loc2_,
               "ease":Cubic.easeOut
            });
         }
         else
         {
            this.mc_container.x = _loc2_;
         }
      }
      
      private function draw() : void
      {
         var _loc4_:Survivor = null;
         var _loc5_:UISurvivorBarItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._survivorDisplays.length)
         {
            this._survivorDisplays[_loc1_].removeEventListener(MouseEvent.CLICK,this.onClickSurvivor);
            this._survivorDisplays[_loc1_].dispose();
            _loc1_++;
         }
         this._survivorDisplays.length = 0;
         var _loc2_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this._survivors.length)
         {
            _loc4_ = this._survivors[_loc1_];
            if(!(_loc4_ == null || _loc4_.activeLoadout == null || _loc4_.activeLoadout.weapon.item == null))
            {
               _loc5_ = new UISurvivorBarItem();
               _loc5_.survivor = _loc4_;
               _loc5_.portraitClicked.add(this.onClickSurvivor);
               _loc5_.weaponClicked.add(this.onClickWeapon);
               _loc5_.gearActiveClicked.add(this.onClickActiveGear);
               _loc5_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverSurvivor,false,0,true);
               _loc5_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutSurvivor,false,0,true);
               _loc5_.x = _loc2_;
               this.mc_container.addChild(_loc5_);
               this._survivorDisplays.push(_loc5_);
               _loc2_ += _loc5_.width + 10;
            }
            _loc1_++;
         }
         this._width = int(this.mc_container.width + 90);
         var _loc3_:Matrix = new Matrix();
         _loc3_.createGradientBox(this._width,this._height);
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginGradientFill("linear",[0,0,0,0],[0,0.5,0.5,0],[0,50,215,255],_loc3_);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.x = -int(this.mc_background.width * 0.5);
         this.mc_container.x = int(this.mc_background.x + (this.mc_background.width - this.mc_container.width) * 0.5);
         this.mc_container.y = int(this.mc_background.y + (this.mc_background.height - 40) * 0.5);
      }
      
      private function onClickSurvivor(param1:UISurvivorBarItem) : void
      {
         if(param1.survivor.health > 0)
         {
            this.survivorSelected.dispatch(param1.survivor);
            Audio.sound.play("sound/interface/int-click.mp3");
         }
         else
         {
            Audio.sound.play("sound/interface/int-error.mp3");
         }
      }
      
      private function onClickWeapon(param1:UISurvivorBarItem) : void
      {
         var _loc2_:Survivor = param1.survivor;
         if(!_loc2_.agentData.reloading && _loc2_.weaponData.roundsInMagazine < _loc2_.weaponData.capacity)
         {
            if(this.isPvP)
            {
               return;
            }
            if(_loc2_.reloadWeapon())
            {
               Tracking.trackEvent("PlayerAction","Reload_Click");
               Audio.sound.play("sound/interface/int-click.mp3");
               return;
            }
         }
         Audio.sound.play("sound/interface/int-error.mp3");
      }
      
      private function onClickActiveGear(param1:UISurvivorBarItem) : void
      {
         this.activeGearSelected.dispatch(param1.survivor);
      }
      
      private function onMouseOverSurvivor(param1:MouseEvent) : void
      {
         var _loc5_:Class = null;
         var _loc2_:UISurvivorBarItem = param1.currentTarget as UISurvivorBarItem;
         if(this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
         }
         if(_loc2_.survivor.classId != SurvivorClass.UNASSIGNED)
         {
            _loc5_ = getDefinitionByName("BmpIconClass_" + _loc2_.survivor.classId) as Class;
            if(_loc5_ != null)
            {
               this.bmp_classIcon.bitmapData = new _loc5_();
            }
         }
         this.txt_name.text = _loc2_.survivor.fullName.toUpperCase();
         this.txt_name.y = int(this.mc_background.y - this.txt_name.height);
         this.bmp_classIcon.y = int(this.txt_name.y + (this.txt_name.height - this.bmp_classIcon.height) * 0.5);
         var _loc3_:int = int(this.mc_container.x + _loc2_.x + (_loc2_.width - this.txt_name.width) * 0.5);
         var _loc4_:int = int(_loc3_ - this.bmp_classIcon.width - 2);
         if(this.txt_name.visible)
         {
            TweenMax.to(this.txt_name,0.25,{
               "x":_loc3_,
               "autoAlpha":1,
               "ease":Cubic.easeOut,
               "overwrite":true
            });
            TweenMax.to(this.bmp_classIcon,0.25,{
               "x":_loc4_,
               "autoAlpha":1,
               "ease":Cubic.easeOut,
               "overwrite":true
            });
         }
         else
         {
            this.txt_name.x = _loc3_;
            this.bmp_classIcon.x = _loc4_;
            TweenMax.to(this.txt_name,0.25,{
               "autoAlpha":1,
               "overwrite":true
            });
            TweenMax.to(this.bmp_classIcon,0.25,{
               "autoAlpha":1,
               "overwrite":true
            });
         }
         if(this.txt_name.parent == null)
         {
            addChild(this.txt_name);
         }
         if(this.bmp_classIcon.parent == null)
         {
            addChild(this.bmp_classIcon);
         }
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOutSurvivor(param1:MouseEvent) : void
      {
         TweenMax.to(this.txt_name,0.25,{
            "delay":0.1,
            "autoAlpha":0
         });
         TweenMax.to(this.bmp_classIcon,0.25,{
            "delay":0.1,
            "autoAlpha":0
         });
      }
      
      public function get survivors() : Vector.<Survivor>
      {
         return this._survivors;
      }
      
      public function set survivors(param1:Vector.<Survivor>) : void
      {
         this._survivors = param1;
         this.draw();
      }
      
      public function get survivorsNotInExitZones() : Vector.<Survivor>
      {
         return this._survivorsNotInExitZones;
      }
      
      public function set survivorsNotInExitZones(param1:Vector.<Survivor>) : void
      {
         this._survivorsNotInExitZones = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

