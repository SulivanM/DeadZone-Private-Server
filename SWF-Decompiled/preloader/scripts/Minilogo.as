package
{
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Strong;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.setTimeout;
   import playerio.utils.SWFReader;
   
   public class Minilogo extends MovieClip
   {
      public static var showLogo:Boolean = true;
      
      private var align:String;
      
      private var t:Tween;
      
      private var rect:Rectangle;
      
      public function Minilogo(param1:String = "BC")
      {
         var _loc2_:* = null;
         super();
         this.align = param1;
         this.alpha = 0;
         this.buttonMode = true;
         addEventListener("addedToStage",handleAttach);
         this.addEventListener("mouseDown",handleClick);
         Minilogo.showLogo = false;
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         param1.preventDefault();
         param1.stopImmediatePropagation();
         try
         {
            navigateToURL(new URLRequest("http://playerio.com/?ref=gamelogo"),"_new");
         }
         catch(e:Error)
         {
            trace("Error occurred!");
         }
      }
      
      private function handleResize(param1:Event = null) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.parent)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            if(stage.scaleMode == "noScale")
            {
               switch(stage.align)
               {
                  case "":
                     _loc2_ = -(stage.stageWidth - rect.width) / 2;
                     _loc3_ = -(stage.stageHeight - rect.height) / 2;
                     break;
                  case "T":
                     _loc2_ = -(stage.stageWidth - rect.width) / 2;
               }
            }
            switch(align)
            {
               case "TL":
                  this.x = _loc2_ + 140;
                  this.y = _loc3_ + 45;
                  break;
               case "CL":
                  this.x = _loc2_ + 140;
                  this.y = _loc3_ + stage.stageHeight / 2;
                  break;
               case "BL":
                  this.x = _loc2_ + 140;
                  this.y = _loc3_ + stage.stageHeight - 45;
                  break;
               case "TC":
                  this.x = _loc2_ + stage.stageWidth / 2;
                  this.y = _loc3_ + 45;
                  break;
               case "CC":
                  this.x = _loc2_ + stage.stageWidth / 2;
                  this.y = _loc3_ + stage.stageHeight / 2;
                  break;
               case "TR":
                  this.x = _loc2_ + stage.stageWidth - 140;
                  this.y = _loc3_ + 45;
                  break;
               case "CR":
                  this.x = _loc2_ + stage.stageWidth - 140;
                  this.y = _loc3_ + stage.stageHeight / 2;
                  break;
               case "BR":
                  this.x = _loc2_ + stage.stageWidth - 140;
                  this.y = _loc3_ + stage.stageHeight - 45;
                  break;
               default:
                  this.x = _loc2_ + stage.stageWidth / 2;
                  this.y = _loc3_ + stage.stageHeight - 45;
            }
         }
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         if(stage.getChildAt(stage.numChildren - 1) != this)
         {
            stage.addChild(this);
         }
      }
      
      private function handleAttach(param1:Event) : void
      {
         if((stage.loaderInfo as Object).hasOwnProperty("bytes"))
         {
            rect = new SWFReader((stage.loaderInfo as Object).bytes).dimensions;
         }
         else
         {
            rect = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
         }
         stage.addEventListener("resize",handleResize);
         handleResize();
         t = new Tween(this,"alpha",Strong.easeIn,0,1,0.5,true);
         t.addEventListener("motionFinish",handleCreated);
         t.addEventListener("motionChange",handleTick);
         addEventListener("enterFrame",handleEnterFrame);
      }
      
      private function handleCreated(param1:TweenEvent) : void
      {
         setTimeout(doRemove,3000);
      }
      
      private function handleTick(param1:Event) : void
      {
         this.filters = [new BlurFilter((1 - this.alpha) * 100,(1 - this.alpha) * 10)];
      }
      
      private function doRemove() : void
      {
         t = new Tween(this,"alpha",Strong.easeIn,1,0,0.5,true);
         t.addEventListener("motionChange",handleTick);
         t.addEventListener("motionFinish",kill);
         removeEventListener("enterFrame",handleEnterFrame);
         stage.removeEventListener("resize",handleResize);
      }
      
      private function kill(param1:Event) : void
      {
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
      }
   }
}

