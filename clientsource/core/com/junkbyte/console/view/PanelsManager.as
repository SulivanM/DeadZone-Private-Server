package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class PanelsManager
   {
      
      private var console:Console;
      
      private var _mainPanel:MainPanel;
      
      private var _ruler:Ruler;
      
      private var _chsPanel:ChannelsPanel;
      
      private var _fpsPanel:GraphingPanel;
      
      private var _memPanel:GraphingPanel;
      
      private var _graphsMap:Object = {};
      
      private var _graphPlaced:uint = 0;
      
      private var _tooltipField:TextField;
      
      private var _canDraw:Boolean;
      
      public function PanelsManager(param1:Console)
      {
         super();
         this.console = param1;
         this._mainPanel = new MainPanel(this.console);
         this._tooltipField = this.mainPanel.makeTF("tooltip",true);
         this._tooltipField.mouseEnabled = false;
         this._tooltipField.autoSize = TextFieldAutoSize.CENTER;
         this._tooltipField.multiline = true;
         this.addPanel(this._mainPanel);
      }
      
      public function addPanel(param1:ConsolePanel) : void
      {
         if(this.console.contains(this._tooltipField))
         {
            this.console.addChildAt(param1,this.console.getChildIndex(this._tooltipField));
         }
         else
         {
            this.console.addChild(param1);
         }
         param1.addEventListener(ConsolePanel.DRAGGING_STARTED,this.onPanelStartDragScale,false,0,true);
         param1.addEventListener(ConsolePanel.SCALING_STARTED,this.onPanelStartDragScale,false,0,true);
      }
      
      public function removePanel(param1:String) : void
      {
         var _loc2_:ConsolePanel = this.console.getChildByName(param1) as ConsolePanel;
         if(_loc2_)
         {
            _loc2_.close();
         }
      }
      
      public function getPanel(param1:String) : ConsolePanel
      {
         return this.console.getChildByName(param1) as ConsolePanel;
      }
      
      public function get mainPanel() : MainPanel
      {
         return this._mainPanel;
      }
      
      public function panelExists(param1:String) : Boolean
      {
         return this.console.getChildByName(param1) as ConsolePanel ? true : false;
      }
      
      public function setPanelArea(param1:String, param2:Rectangle) : void
      {
         var _loc3_:ConsolePanel = this.getPanel(param1);
         if(_loc3_)
         {
            _loc3_.x = param2.x;
            _loc3_.y = param2.y;
            if(param2.width)
            {
               _loc3_.width = param2.width;
            }
            if(param2.height)
            {
               _loc3_.height = param2.height;
            }
         }
      }
      
      public function updateMenu() : void
      {
         this._mainPanel.updateMenu();
         var _loc1_:ChannelsPanel = this.getPanel(ChannelsPanel.NAME) as ChannelsPanel;
         if(_loc1_)
         {
            _loc1_.update();
         }
      }
      
      public function update(param1:Boolean, param2:Boolean) : void
      {
         this._canDraw = !param1;
         this._mainPanel.update(!param1 && param2);
         if(!param1)
         {
            if(param2 && this._chsPanel != null)
            {
               this._chsPanel.update();
            }
         }
      }
      
      public function updateGraphs(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:GraphGroup = null;
         var _loc4_:GraphGroup = null;
         var _loc5_:GraphGroup = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:GraphingPanel = null;
         var _loc9_:Rectangle = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         this._graphPlaced = 0;
         for each(_loc5_ in param1)
         {
            if(_loc5_.type == GraphGroup.FPS)
            {
               _loc3_ = _loc5_;
            }
            else if(_loc5_.type == GraphGroup.MEM)
            {
               _loc4_ = _loc5_;
            }
            else
            {
               _loc7_ = _loc5_.name;
               _loc8_ = this._graphsMap[_loc7_] as GraphingPanel;
               if(!_loc8_)
               {
                  _loc9_ = _loc5_.rect;
                  if(_loc9_ == null)
                  {
                     _loc9_ = new Rectangle(NaN,NaN,0,0);
                  }
                  _loc10_ = 100;
                  if(isNaN(_loc9_.x) || isNaN(_loc9_.y))
                  {
                     if(this._mainPanel.width < 150)
                     {
                        _loc10_ = 50;
                     }
                     _loc11_ = Math.floor(this._mainPanel.width / _loc10_) - 1;
                     if(_loc11_ <= 1)
                     {
                        _loc11_ = 2;
                     }
                     _loc12_ = this._graphPlaced % _loc11_;
                     _loc13_ = Math.floor(this._graphPlaced / _loc11_);
                     _loc9_.x = this._mainPanel.x + _loc10_ + _loc12_ * _loc10_;
                     _loc9_.y = this._mainPanel.y + _loc10_ * 0.6 + _loc13_ * _loc10_;
                     ++this._graphPlaced;
                  }
                  if(_loc9_.width <= 0 || isNaN(_loc9_.width))
                  {
                     _loc9_.width = _loc10_;
                  }
                  if(_loc9_.height <= 0 || isNaN(_loc9_.height))
                  {
                     _loc9_.height = _loc10_;
                  }
                  _loc8_ = new GraphingPanel(this.console,_loc9_.width,_loc9_.height);
                  _loc8_.x = _loc9_.x;
                  _loc8_.y = _loc9_.y;
                  _loc8_.name = "graph_" + _loc7_;
                  this._graphsMap[_loc7_] = _loc8_;
                  this.addPanel(_loc8_);
               }
               if(_loc2_ == null)
               {
                  _loc2_ = {};
               }
               _loc2_[_loc7_] = true;
               _loc8_.update(_loc5_,this._canDraw);
            }
         }
         for(_loc6_ in this._graphsMap)
         {
            if(_loc2_ == null || !_loc2_[_loc6_])
            {
               this._graphsMap[_loc6_].close();
               delete this._graphsMap[_loc6_];
            }
         }
         if(_loc3_ != null)
         {
            if(this._fpsPanel == null)
            {
               this._fpsPanel = new GraphingPanel(this.console,80,40,GraphingPanel.FPS);
               this._fpsPanel.name = GraphingPanel.FPS;
               this._fpsPanel.x = this._mainPanel.x + this._mainPanel.width - 160;
               this._fpsPanel.y = this._mainPanel.y + 15;
               this.addPanel(this._fpsPanel);
               this._mainPanel.updateMenu();
            }
            this._fpsPanel.update(_loc3_,this._canDraw);
         }
         else if(this._fpsPanel != null)
         {
            this.removePanel(GraphingPanel.FPS);
            this._fpsPanel = null;
         }
         if(_loc4_ != null)
         {
            if(this._memPanel == null)
            {
               this._memPanel = new GraphingPanel(this.console,80,40,GraphingPanel.MEM);
               this._memPanel.name = GraphingPanel.MEM;
               this._memPanel.x = this._mainPanel.x + this._mainPanel.width - 80;
               this._memPanel.y = this._mainPanel.y + 15;
               this.addPanel(this._memPanel);
               this._mainPanel.updateMenu();
            }
            this._memPanel.update(_loc4_,this._canDraw);
         }
         else if(this._memPanel != null)
         {
            this.removePanel(GraphingPanel.MEM);
            this._memPanel = null;
         }
         this._canDraw = false;
      }
      
      public function removeGraph(param1:GraphGroup) : void
      {
         var _loc2_:GraphingPanel = null;
         if(Boolean(this._fpsPanel) && param1 == this._fpsPanel.group)
         {
            this._fpsPanel.close();
            this._fpsPanel = null;
         }
         else if(Boolean(this._memPanel) && param1 == this._memPanel.group)
         {
            this._memPanel.close();
            this._memPanel = null;
         }
         else
         {
            _loc2_ = this._graphsMap[param1.name];
            if(_loc2_)
            {
               _loc2_.close();
               delete this._graphsMap[param1.name];
            }
         }
      }
      
      public function get displayRoller() : Boolean
      {
         return this.getPanel(RollerPanel.NAME) as RollerPanel ? true : false;
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         var _loc2_:RollerPanel = null;
         if(this.displayRoller != param1)
         {
            if(param1)
            {
               if(this.console.config.displayRollerEnabled)
               {
                  _loc2_ = new RollerPanel(this.console);
                  _loc2_.x = this._mainPanel.x + this._mainPanel.width - 180;
                  _loc2_.y = this._mainPanel.y + 55;
                  this.addPanel(_loc2_);
               }
               else
               {
                  this.console.report("Display roller is disabled in config.",9);
               }
            }
            else
            {
               this.removePanel(RollerPanel.NAME);
            }
            this._mainPanel.updateMenu();
         }
      }
      
      public function get channelsPanel() : Boolean
      {
         return this._chsPanel != null;
      }
      
      public function set channelsPanel(param1:Boolean) : void
      {
         if(this.channelsPanel != param1)
         {
            this.console.logs.cleanChannels();
            if(param1)
            {
               this._chsPanel = new ChannelsPanel(this.console);
               this._chsPanel.x = this._mainPanel.x + this._mainPanel.width - 332;
               this._chsPanel.y = this._mainPanel.y - 2;
               this.addPanel(this._chsPanel);
               this._chsPanel.update();
               this.updateMenu();
            }
            else
            {
               this.removePanel(ChannelsPanel.NAME);
               this._chsPanel = null;
            }
            this.updateMenu();
         }
      }
      
      public function get memoryMonitor() : Boolean
      {
         return this._memPanel != null;
      }
      
      public function get fpsMonitor() : Boolean
      {
         return this._fpsPanel != null;
      }
      
      public function tooltip(param1:String = null, param2:ConsolePanel = null) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Rectangle = null;
         var _loc5_:Rectangle = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(Boolean(param1) && !this.rulerActive)
         {
            _loc3_ = param1.split("::");
            param1 = _loc3_[0];
            if(_loc3_.length > 1)
            {
               param1 += "<br/><low>" + _loc3_[1] + "</low>";
            }
            this.console.addChild(this._tooltipField);
            this._tooltipField.wordWrap = false;
            this._tooltipField.htmlText = "<tt>" + param1 + "</tt>";
            if(this._tooltipField.width > 120)
            {
               this._tooltipField.width = 120;
               this._tooltipField.wordWrap = true;
            }
            this._tooltipField.x = this.console.mouseX - this._tooltipField.width / 2;
            this._tooltipField.y = this.console.mouseY + 20;
            if(param2)
            {
               _loc4_ = this._tooltipField.getBounds(this.console);
               _loc5_ = new Rectangle(param2.x,param2.y,param2.width,param2.height);
               _loc6_ = _loc4_.bottom - _loc5_.bottom;
               if(_loc6_ > 0)
               {
                  if(this._tooltipField.y - _loc6_ > this.console.mouseY + 15)
                  {
                     this._tooltipField.y -= _loc6_;
                  }
                  else if(_loc5_.y < this.console.mouseY - 24 && _loc4_.y > _loc5_.bottom)
                  {
                     this._tooltipField.y = this.console.mouseY - this._tooltipField.height - 15;
                  }
               }
               _loc7_ = _loc4_.left - _loc5_.left;
               _loc8_ = _loc4_.right - _loc5_.right;
               if(_loc7_ < 0)
               {
                  this._tooltipField.x -= _loc7_;
               }
               else if(_loc8_ > 0)
               {
                  this._tooltipField.x -= _loc8_;
               }
            }
         }
         else if(this.console.contains(this._tooltipField))
         {
            this.console.removeChild(this._tooltipField);
         }
      }
      
      public function startRuler() : void
      {
         if(this.rulerActive)
         {
            return;
         }
         this._ruler = new Ruler(this.console);
         this._ruler.addEventListener(Event.COMPLETE,this.onRulerExit,false,0,true);
         this.console.addChild(this._ruler);
         this._mainPanel.updateMenu();
      }
      
      public function get rulerActive() : Boolean
      {
         return Boolean(this._ruler) && this.console.contains(this._ruler) ? true : false;
      }
      
      private function onRulerExit(param1:Event) : void
      {
         if(Boolean(this._ruler) && this.console.contains(this._ruler))
         {
            this.console.removeChild(this._ruler);
         }
         this._ruler = null;
         this._mainPanel.updateMenu();
      }
      
      private function onPanelStartDragScale(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:ConsolePanel = null;
         var _loc2_:ConsolePanel = param1.currentTarget as ConsolePanel;
         if(this.console.config.style.panelSnapping)
         {
            _loc3_ = [0];
            _loc4_ = [0];
            if(this.console.stage)
            {
               _loc3_.push(this.console.stage.stageWidth);
               _loc4_.push(this.console.stage.stageHeight);
            }
            _loc5_ = this.console.numChildren;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = this.console.getChildAt(_loc6_) as ConsolePanel;
               if((Boolean(_loc7_)) && _loc7_.visible)
               {
                  _loc3_.push(_loc7_.x,_loc7_.x + _loc7_.width);
                  _loc4_.push(_loc7_.y,_loc7_.y + _loc7_.height);
               }
               _loc6_++;
            }
            _loc2_.registerSnaps(_loc3_,_loc4_);
         }
      }
   }
}

