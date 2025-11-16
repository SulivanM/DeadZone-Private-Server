package thelaststand.app.game.gui.compound
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.IGUILayer;
   import thelaststand.app.game.gui.UIHUDPanel;
   import thelaststand.app.game.gui.buttons.UIHUDButton;
   import thelaststand.app.game.gui.buttons.UIHUDMapButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class NeighborCompoundGUILayer extends Sprite implements IGUILayer
   {
      
      private var _gui:GameGUI;
      
      private var _lang:Language;
      
      private var _name:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _transitionedOut:Signal;
      
      private var hud_right:UIHUDPanel;
      
      public function NeighborCompoundGUILayer()
      {
         super();
         mouseEnabled = false;
         this._lang = Language.getInstance();
         this._transitionedOut = new Signal(NeighborCompoundGUILayer);
         this.hud_right = new UIHUDPanel(true);
         addChild(this.hud_right);
         var _loc1_:UIHUDButton = this.hud_right.addButton(new UIHUDMapButton("worldmap"));
         _loc1_.clicked.add(this.onHUDButtonClicked);
         var _loc2_:UIHUDButton = this.hud_right.addButton(new UIHUDButton("compound",new Bitmap(new BmpIconHUDReturn())));
         _loc2_.clicked.add(this.onHUDButtonClicked);
         var _loc3_:TooltipManager = TooltipManager.getInstance();
         _loc3_.add(_loc2_,this._lang.getString("tooltip.return_compound"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         _loc3_.add(_loc1_,this._lang.getString("tooltip.worldmap"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.hud_right.dispose();
         this.hud_right = null;
         this._gui = null;
         this._lang = null;
         this._transitionedOut.removeAll();
         this._transitionedOut = null;
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         var _loc3_:int = 960;
         var _loc4_:int = int((this._width - _loc3_) * 0.5);
         this.hud_right.x = int(Math.min(_loc4_ + _loc3_ - 4,this._width - 4) - this.hud_right.width);
         this.hud_right.y = int(this._height - this.hud_right.height - 8);
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         mouseChildren = true;
         var _loc2_:Function = Back.easeOut;
         var _loc3_:Array = [0.75];
         TweenMax.from(this.hud_right,0.25,{
            "delay":param1,
            "y":this._height + 100,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         mouseChildren = false;
         var _loc2_:Function = Back.easeIn;
         var _loc3_:Array = [0.75];
         TweenMax.to(this.hud_right,0.25,{
            "delay":param1,
            "y":this._height + 100,
            "ease":_loc2_,
            "easeParams":_loc3_,
            "onComplete":this._transitionedOut.dispatch,
            "onCompleteParams":[this]
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onHUDButtonClicked(param1:MouseEvent) : void
      {
         switch(UIHUDButton(param1.currentTarget).id)
         {
            case "worldmap":
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.WORLD_MAP));
               break;
            case "compound":
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
               this.transitionOut();
         }
      }
      
      public function get transitionedOut() : Signal
      {
         return this._transitionedOut;
      }
      
      public function get useFullWindow() : Boolean
      {
         return false;
      }
      
      public function get gui() : GameGUI
      {
         return this._gui;
      }
      
      public function set gui(param1:GameGUI) : void
      {
         this._gui = param1;
      }
   }
}

