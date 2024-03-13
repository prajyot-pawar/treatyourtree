import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/db.dart';
import '../../widgets/block/block.dart';
import 'package:hive/hive.dart';

import '../../widgets/block/block_Piece.dart';
import '../../widgets/drawer/drawer.dart';

List<List<BlockType?>> gameBoard = List.generate(
    col,
        (i) => List.generate(
        row,
            (i) => null
    )
);

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  double value=0;
  int row=10;
  int col=15;
  int score=0;

  int highscore=0;

  BlockPieceTYT currentPieceTYT=BlockPieceTYT(type: BlockType.Land);

  bool over=false;

  //reference the hive box
  final highbox = Hive.box("HighScore_db");
  HighScoreDB db = HighScoreDB();


  @override
  void initState() {

    if (highbox.get("SCOREDB") == null){
      db.createInitialData();
      highscore=db.score;
    }

    else {
      db.loadData();
      highscore = db.score;
    }

    super.initState();
    //start game when app starts
    startGame();
  }


  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }

  void startGame(){
    currentPieceTYT.genPieces();

    Duration frameRate=const Duration(milliseconds: 500);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate){
    Timer.periodic(
        frameRate,
            (timer){
          setState(() {
            checkLanding();
            if(gameOver()==true){
              timer.cancel();
              showGameOver();
            }
            currentPieceTYT.pieceMove(Directions.down);
          });
        }
    );
  }

  void showGameOver(){
    showDialog(context: this.context, builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 51, 49, 44),
      content: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 51, 49, 44),
            borderRadius: BorderRadius.circular(10)
        ),

        child:Text("Game Over",style: TextStyle(color: Colors.white,fontSize: 24),),
      ),

      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
          resetGame();
        },
            child: Text("Play Again")
        )
      ],
    ));
  }

  bool collisionDet(Directions direction){

    for(int i=0;i<currentPieceTYT.positions.length;i++){
      int currow =(currentPieceTYT.positions[i]/row).floor();
      int curcol =currentPieceTYT.positions[i]%row;

      if(direction==Directions.left){
        curcol-=1;
      }
      else if(direction==Directions.right){
        curcol+=1;
      }
      else if(direction==Directions.down){
        currow+=1;
      }

      if( currow>14 || curcol<0|| curcol>= row){
        return true;

      }
      if(currow>=0 && curcol>=0){
        if(gameBoard[currow][curcol]!=null){
          return true;
        }
      }

    }
    return false;
  }

  void checkLanding(){
    if(collisionDet(Directions.down)){

      for(int i=0;i<currentPieceTYT.positions.length;i++){
        int currow =(currentPieceTYT.positions[i]/row).floor();
        int curcol =currentPieceTYT.positions[i]%row;
        if(currow>=0 && curcol>=0){
          gameBoard[currow][curcol]=currentPieceTYT.type;
        }
      }
      score+=4;
      newPieceTYT();
    }
  }

  void newPieceTYT(){
    Random rand=Random();
    BlockType randomType=BlockType.values[rand.nextInt(BlockType.values.length)];
    print("this is random type to be drawn $randomType");
    BlockType randoType=BlockType.values[rand.nextInt(BlockType.values.length)];
    currentPieceTYT=BlockPieceTYT(type: randoType);
    currentPieceTYT.genPieces();
    if(gameOver()==true){
      over=true;
    }
  }

  void moveLeft(){
    if(!collisionDet(Directions.left)){
      setState(() {
        currentPieceTYT.pieceMove(Directions.left);
      });
    }
  }
  void resetGame(){
    setState(() {
      if(score>highscore){
        db.score=score;
      }

    });
    db.updateData();
    gameBoard=List.generate(
        col,
            (i) => List.generate(
            row,
                (i) => null
        )
    );
    over=false;
    score=0;
    newPieceTYT();
    startGame();
  }
  void moveRight(){
    if(!collisionDet(Directions.right)){
      setState(() {
        currentPieceTYT.pieceMove(Directions.right);
      });
    }
  }

  bool gameOver(){
    for(int i=0;i<row;i++){
      if(gameBoard[0][i]!=null){
        return true;
      }
    }
    return false;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DrawerPage(),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0,end: value),
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
            builder: (_,double val,__){
              return(
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..setEntry(0, 3, 200*val)
                      ..rotateY(pi/6 * val),

                    //home page begins
                    child:GestureDetector(
                      onTap: (){
                        setState(() {
                          value==1?value=0:value=0;
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Scaffold(
                            backgroundColor: Color.fromRGBO(27, 18, 18, 1),
                            body: SafeArea(
                              child: Column(
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20,top: 25),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              value==0?value=1:value=0;
                                            });
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: Colors.grey[400]
                                              ),
                                              child: Image.asset(
                                                "assets/images/menu.png",
                                                height: 20,
                                                width: 20,
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 25,),

                                  Expanded(
                                    child: GridView.builder(
                                        itemCount: row*col,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: row,
                                        ),
                                        itemBuilder: (context, index) {

                                          int currow =(index /row).floor();
                                          int curcol =index % row;

                                          if(currentPieceTYT.positions.contains(index)){
                                            return Boxes(
                                              color: currentPieceTYT.color,

                                            );
                                          }

                                          else if(gameBoard[currow][curcol]!=null){
                                            final BlockType? tetType=gameBoard[currow][curcol];
                                            return (tetType!=null)? Boxes(
                                              color: typeColors[tetType],
                                              blocktype: tetType,
                                            );
                                          }

                                          else{
                                            return Boxes(
                                              color: const Color.fromARGB(255, 46, 37, 37),

                                            );
                                          }

                                        }
                                    ),
                                  ),



                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                    child: Row(

                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          onPressed: moveLeft,
                                          icon: Icon(Icons.arrow_back_rounded,size: 30,),
                                          color: Colors.white,

                                        ),
                                        IconButton(
                                          onPressed: resetGame,
                                          icon: Icon(Icons.replay_outlined,size: 30,),
                                          color: Colors.white,

                                        ),
                                        IconButton(
                                          onPressed: moveRight,
                                          icon: Icon(Icons.arrow_forward_rounded,size: 30,),
                                          color: Colors.white,

                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),

                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 34, 32, 31),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.red,
                                              width: 2
                                          )
                                      ),
                                      child: Text(
                                        "Score : $score",
                                        style: TextStyle(color: Colors.white,fontSize: 22),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            )

                        ),
                      ),
                    ),
                  )
              );
            },

          ),
        ],

      ),
    );
  }
}
