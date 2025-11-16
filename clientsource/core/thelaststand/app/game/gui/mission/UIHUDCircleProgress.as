package thelaststand.app.game.gui.mission
{
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.app.gui.UICircleProgress;
   import thelaststand.engine.scenes.Scene;
   
   public class UIHUDCircleProgress extends UICircleProgress
   {
      
      private var _position:Vector3D;
      
      private var _offset:Vector3D;
      
      private var _scene:Scene;
      
      private var mc_progress:UICircleProgress;
      
      public function UIHUDCircleProgress(param1:Scene, param2:Vector3D, param3:Vector3D, param4:uint = 13500416, param5:uint = 4210752, param6:Number = 8)
      {
         super(param4,param5,param6);
         this._scene = param1;
         this._position = param2;
         this._offset = param3;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._position = null;
         this._offset = null;
         this._scene = null;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Point = this._scene.getScreenPosition(this._position.x + this._offset.x,this._position.y + this._offset.y,this._position.z + this._offset.z);
         this.x = int(_loc2_.x);
         this.y = int(_loc2_.y);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
   }
}

