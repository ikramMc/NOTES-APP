import 'package:flutter/material.dart';
import 'package:nota/screens/edit_screen.dart';
import 'package:nota/models/notes_database.dart';
import 'package:nota/util/constantes.dart';
class HomePage extends StatefulWidget {
  const HomePage() ;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> notesData;
  List<int> selectedNoteIds = [];
  Future<List<Map<String, dynamic>>> readDatabase() async {
    try {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDataBase();
      List<Map> notesList = await notesDb.getAllNotes();
      await notesDb.closeDatabase();
      List<Map<String, dynamic>> notesData = List<Map<String, dynamic>>.from(notesList);
      notesData.sort((a, b) => (a['title']).compareTo(b['title']));
      return notesData;
    } catch(e) {
      print('Error retrieving notes');
      return [{}];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nota"),actions: [selectedNoteIds.length>0?IconButton(onPressed: ()=>handleDelete(), icon: Icon(Icons.delete,color: Colors.yellow,)):Container(

      )],),
      floatingActionButton: FloatingActionButton(child:Icon(Icons.add) ,onPressed: ()async{var result=await Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPage(['new',{}]))).then((dynamic){setState(() {}
      );});},),
      body: FutureBuilder(
        future:readDatabase(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            notesData=(snapshot.data as List<Map<String,dynamic>>);
            return Stack(
              children: <Widget>[AllNotesList(snapshot.data,
              this.selectedNoteIds,
              afterNavigatorPop,
              handleNoteListLongPress,
                handleNoteListTapAfterSelect,)],
            );
          }
          else
            if(snapshot.hasError){print('Errorr');return Container(); }
            else{
              return Center(child: CircularProgressIndicator(backgroundColor: Colors.redAccent,),);
            }


        }
      ),
    );
  }
  void afterNavigatorPop(){
    setState(() {

    });
  }
  void handleNoteListLongPress(int id){
    setState(() {
      if(selectedNoteIds.contains(id)==false){
        selectedNoteIds.add(id);
      }
    });
  }
  void handleNoteListTapAfterSelect(int id ){
    setState(() {
      if(selectedNoteIds.contains(id)==true)selectedNoteIds.remove(id);
    });
  }
  void handleDelete()async{
    try{
      NotesDatabase ndb=NotesDatabase();
      await ndb.initDataBase();
      for(int id in selectedNoteIds){
        await ndb.deleteNote(id);
      }
      await ndb.closeDatabase();
    }
    catch(e){

    }
    finally{
      setState(() {
        selectedNoteIds=[];
      });
    }
  }
}
class AllNotesList extends StatelessWidget {
  final data;
  final selectedNoteIds;
  final afterNavigatorPop;
  final handleNoteListLongPress;
  final handleNoteListTapAfterSelect;
  const AllNotesList(this.data,this.selectedNoteIds,this.afterNavigatorPop,this.handleNoteListLongPress,this.handleNoteListTapAfterSelect) ;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: data.length,itemBuilder: (context,index){
      dynamic item =data[index];
      return DisplayNote(item,selectedNoteIds,(selectedNoteIds.contains(item['id'])==false?false:true),
      afterNavigatorPop,handleNoteListLongPress,handleNoteListTapAfterSelect
      );
    });
  }
}
class DisplayNote extends StatelessWidget {
  final notesData;
  final selectedNoteIds;
  final selectedNote;
  final callAfterNavigatorPop;
  final handleNoteListLongPress;
  final handleNoteListTapAfterSelect;
  const DisplayNote(this.notesData,this.selectedNoteIds,this.selectedNote,this.callAfterNavigatorPop,this.handleNoteListLongPress,this.handleNoteListTapAfterSelect);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(4),
    child: InkWell(
      onTap: (){
        if(selectedNote==false){
          if(selectedNoteIds.length==0){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPage(['update',notesData]))).then((dynamic value){
              callAfterNavigatorPop();
            });
          }
          else{
            handleNoteListLongPress(notesData['id']);
          }
        }
        else{
          handleNoteListTapAfterSelect(notesData['id']);
        }
      },
      onLongPress: (){
        handleNoteListLongPress(notesData['id']);
      },
      child: Container(
       decoration: BoxDecoration(
         color: Color(NoteColors[notesData['color']]!['l']!),
         borderRadius: BorderRadius.circular(12),
       ),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [Expanded(child: Container(padding:EdgeInsets.all(4),alignment: Alignment.center,decoration: BoxDecoration(color: (selectedNote==false?Color(NoteColors[notesData['color']]!['b']!):Colors.orangeAccent),shape: BoxShape.circle),child: selectedNote==false?
          Text(notesData['title'][0],
          style: TextStyle(
          color: Colors.white,
            fontSize: 21,
          )):Icon(Icons.check,color: Colors.cyanAccent,size: 21,),
          ),),Expanded( child:Column(children: [Text(notesData['title']!=null?notesData['title']:"",
          style: TextStyle(color: Color(NoteColors[notesData['color']]!['b']!)),),SizedBox(height: 3,),Text(notesData['content']!=null?notesData['content']:"",style: TextStyle(),)],) ,flex: 3,)],
        ),
      ),
    ),);
  }
}


