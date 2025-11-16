package thelaststand.engine.map
{
   import com.deadreckoned.threshold.data.Graph;
   import de.polygonal.ds.Prioritizable;
   import org.osflash.signals.DeluxeSignal;
   
   public class PathfinderJob extends Prioritizable
   {
      
      internal var _cancelled:Boolean = false;
      
      internal var _completed:Boolean = false;
      
      public var graph:Graph;
      
      public var start:Cell;
      
      public var goal:Cell;
      
      public var path:Path;
      
      public var options:PathfinderOptions;
      
      public var data:*;
      
      public var started:DeluxeSignal;
      
      public var completed:DeluxeSignal;
      
      public var cancelled:DeluxeSignal;
      
      public function PathfinderJob()
      {
         super();
         this.started = new DeluxeSignal(this,PathfinderJob);
         this.completed = new DeluxeSignal(this,PathfinderJob);
         this.cancelled = new DeluxeSignal(this,PathfinderJob);
      }
      
      public function reset() : PathfinderJob
      {
         this._completed = false;
         this._cancelled = false;
         this.started.removeAll();
         this.completed.removeAll();
         this.cancelled.removeAll();
         this.graph = null;
         this.start = this.goal = null;
         priority = 0;
         this.path = null;
         this.data = null;
         this.options = null;
         return this;
      }
   }
}

