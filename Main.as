package {
	// importing classes
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	// end of importing classes 
	public class Main extends Sprite {
		// class level variables
		private const FIELD_W:uint=9;
		private const FIELD_H:uint=9;
		private const MINES:uint=10;
		private var mineField:Array=new Array  ;
		private var game_container:Sprite=new Sprite  ;
		private var tile:tile_movieclip;
		private var timer:Timer=new Timer(1000);
		private var toolbar:toolbar_mc;
		private var gameOver:Boolean=false;
		private var firstClick:Boolean=true;
		// end of class level variables
		public function Main() {
			// mine field creation
			for (var i:uint=0; i<FIELD_H; i++) {
				mineField[i]=new Array  ;
				for (var j:uint=0; j<FIELD_W; j++) {
					mineField[i].push(0);
				}
			}
			// end of mine field creation
			// tile creation
			addChild(game_container);
			for (i=0; i<FIELD_H; i++) {
				for (j=0; j<FIELD_W; j++) {
					tile=new tile_movieclip  ;
					game_container.addChild(tile);
					tile.gotoAndStop(1);
					tile.nrow=i;
					tile.ncol=j;
					tile.buttonMode=true;
					tile.x=tile.width*j;
					tile.y=tile.height*i;
					tile.addEventListener(MouseEvent.CLICK,onTileClicked);
				}
			}
			// end of tile creation
			// time management and game over
			toolbar=new toolbar_mc  ;
			addChild(toolbar);
			toolbar.y=stage.stageHeight-toolbar.height;
			timer.start();
			timer.addEventListener(TimerEvent.TIMER,onTick);
			// end of time management and game over
		}
		private function onTick(e:TimerEvent):void {
			toolbar.message_text.text="Elapsed time: "+e.target.currentCount+"s";
		}
		private function onTileClicked(e:MouseEvent):void {
			if (! gameOver) {
				var clicked_tile:tile_movieclip=e.currentTarget as tile_movieclip;
				var clickedRow:uint=clicked_tile.nrow;
				var clickedCol:uint=clicked_tile.ncol;
				if (firstClick) {
					firstClick=false;
					// placing mines
					var placedMines:uint=0;
					var randomRow,randomCol:uint;
					while (placedMines<MINES) {
						randomRow=Math.floor(Math.random()*FIELD_H);
						randomCol=Math.floor(Math.random()*FIELD_W);
						if (mineField[randomRow][randomCol]==0) {
							if (randomRow!=clickedRow||randomCol!=clickedCol) {
								mineField[randomRow][randomCol]=9;
								placedMines++;
							}
						}
					}
					// end of placing mines
					// placing digits
					for (var i:uint=0; i<FIELD_H; i++) {
						for (var j:uint=0; j<FIELD_W; j++) {
							if (mineField[i][j]==9) {
								for (var ii:int=-1; ii<=1; ii++) {
									for (var jj:int=-1; jj<=1; jj++) {
										if (ii!=0||jj!=0) {
											if (tileValue(i+ii,j+jj)!=9&&tileValue(i+ii,j+jj)!=-1) {
												mineField[i+ii][j+jj]++;
											}
										}
									}
								}
							}
						}
					}
					var debugString:String;
					trace("My complete and formatted mine field: ");
					for (i=0; i<FIELD_H; i++) {
						debugString="";
						for (j=0; j<FIELD_W; j++) {
							debugString+=mineField[i][j]+" ";
						}
						trace(debugString);
					}
					// end of placing digits
				}
				var clickedValue:uint=mineField[clickedRow][clickedCol];
				if (e.shiftKey) {
					clicked_tile.gotoAndStop(5-clicked_tile.currentFrame);
				} else {
					if (clicked_tile.currentFrame==1) {
						clicked_tile.removeEventListener(MouseEvent.CLICK,onTileClicked);
						clicked_tile.buttonMode=false;
						// emptyTile tile
						if (clickedValue==0) {
							floodFill(clickedRow,clickedCol);
						}
						// end of emptyTile tile
						// numbered tile
						if (clickedValue>0&&clickedValue<9) {
							clicked_tile.gotoAndStop(2);
							clicked_tile.tile_text.text=clickedValue.toString();
						}
						// end of numbered tile
						// mine
						if (clickedValue==9) {
							clicked_tile.gotoAndStop(3);
							timer.removeEventListener(TimerEvent.TIMER,onTick);
							toolbar.message_text.text="BOOOOOOOM!!!";
							gameOver=true;
						}
						// end of mine
					}
				}
			}
		}
		private function tileValue(row,col:uint):int {
			if (mineField[row]==undefined||mineField[row][col]==undefined) {
				return -1;
			} else {
				return mineField[row][col];
			}
		}
		private function floodFill(row,col:uint):void {
			var emptyTile:tile_movieclip;
			emptyTile=game_container.getChildAt(row*FIELD_W+col) as tile_movieclip;
			if (emptyTile.currentFrame==1) {
				emptyTile.removeEventListener(MouseEvent.CLICK,onTileClicked);
				emptyTile.buttonMode=false;
				emptyTile.gotoAndStop(2);
				if (mineField[row][col]>0) {
					emptyTile.tile_text.text=mineField[row][col].toString();
				} else {
					emptyTile.tile_text.text="";
				}
				if (mineField[row][col]==0) {
					for (var ii:int=-1; ii<=1; ii++) {
						for (var jj:int=-1; jj<=1; jj++) {
							if (ii!=0||jj!=0) {
								if (tileValue(row+ii,col+jj)!=9) {
									if (tileValue(row+ii,col+jj)!=-1) {
										floodFill(row+ii,col+jj);
									}
								}

							}
						}
					}
				}
			}
		}
	}
}