package thelaststand.app.utils
{
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.display.ModelView;
   import thelaststand.app.display.actor.StandAloneActorMesh;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.animation.AnimationTable;
   
   public class SurvivorPortrait
   {
      
      private static var _view:ModelView;
      
      private static var _queue:Vector.<Object> = new Vector.<Object>();
      
      public static var queueCompleted:Signal = new Signal();
      
      public function SurvivorPortrait()
      {
         super();
         throw new Error("SurvivorPortrait cannot be directly instantiated.");
      }
      
      public static function get queueLength() : int
      {
         return _queue.length;
      }
      
      public static function savePortrait(param1:Survivor, param2:Function = null, param3:int = 64, param4:int = 64) : void
      {
         _queue.push({
            "survivor":param1,
            "onComplete":param2,
            "width":param3,
            "height":param4
         });
         if(_queue.length == 1)
         {
            processNextPortrait();
         }
      }
      
      private static function processNextPortrait() : void
      {
         var width:int = 0;
         var height:int = 0;
         var resources:ResourceManager = null;
         var startRender:Function = null;
         var actorMesh:StandAloneActorMesh = null;
         var survivor:Survivor = _queue[0].survivor;
         var onComplete:Function = _queue[0].onComplete;
         width = int(_queue[0].width);
         height = int(_queue[0].height);
         resources = ResourceManager.getInstance();
         startRender = function(param1:Event = null):void
         {
            _view.removeEventListener(Event.CONTEXT3D_CREATE,arguments.callee);
            render(actorMesh);
         };
         actorMesh = new StandAloneActorMesh();
         actorMesh.appearanceChanged.addOnce(function():void
         {
            var _loc1_:AnimationTable = resources.animations.getAnimationTable("models/anim/human.anim");
            actorMesh.addAnimation("portrait",_loc1_.getAnimationByName("portrait"));
            actorMesh.rotationY = 70 * Math.PI / 180;
            actorMesh.setAnimation("portrait");
            actorMesh.scaleX = actorMesh.scaleY = actorMesh.scaleZ = 1.22;
            actorMesh.update();
            if(_view == null)
            {
               _view = new ModelView(Global.stage.stage3Ds[2],width,height,0,false);
               _view.viewport.antiAlias = 4;
               _view.directionalLight.x = -100;
               _view.directionalLight.y = -100;
               _view.directionalLight.lookAt(0,0,0);
               _view.camera.z = -100;
               _view.camera.rotationX = -40 * Math.PI / 180;
               _view.camera.orthographic = true;
            }
            if(_view.context3D == null || _view.context3D.driverInfo == "dispose")
            {
               _view.addEventListener(Event.CONTEXT3D_CREATE,startRender);
               _view.requestContext();
            }
            else
            {
               startRender();
            }
         });
         actorMesh.includeGear = false;
         actorMesh.setAppearance(survivor.appearance);
      }
      
      private static function render(param1:StandAloneActorMesh) : void
      {
         var _loc2_:Survivor = _queue[0].survivor;
         var _loc3_:Function = _queue[0].onComplete;
         var _loc4_:int = int(_queue[0].width);
         var _loc5_:int = int(_queue[0].height);
         var _loc6_:ResourceManager = ResourceManager.getInstance();
         param1.scaleX = param1.scaleY = param1.scaleZ = 1.35;
         if(_view.context3D)
         {
            _view.context3D.clear(0,0,0,0);
         }
         _view.render();
         _view.addObject(param1);
         _view.camera.y = -297;
         _view.render();
         var _loc7_:BitmapData = new BitmapData(_loc4_,_loc5_,true,0);
         _loc7_.draw(_view);
         _loc7_.applyFilter(_loc7_,_loc7_.rect,new Point(),new GlowFilter(0,0.75,12,12,1,3));
         _loc2_.portraitURI = "images/portraits/survivors/" + _loc2_.id + ".png";
         _loc6_.addResource(_loc7_,_loc2_.portraitURI,"img");
         param1.dispose();
         _queue.shift();
         if(_queue.length == 0)
         {
            _view.dispose();
            _view = null;
            if(_loc3_ != null)
            {
               _loc3_();
            }
            queueCompleted.dispatch();
         }
         else
         {
            _view.clear();
            if(_loc3_ != null)
            {
               _loc3_();
            }
            processNextPortrait();
         }
      }
   }
}

