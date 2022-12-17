import 'package:flutter/material.dart';
import 'package:nota/models/notes_database.dart';
import 'package:nota/util/constantes.dart';
import 'package:nota/models/note.dart';
class EditPage extends StatefulWidget {
  final args;
  const EditPage(this.args, {Key? key}) : super(key: key) ;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String title = '';
  String content = '';
  String color = 'red';

  TextEditingController titlectrl = TextEditingController();
  TextEditingController contentctrl = TextEditingController();

  void titleHandler() {
    setState(() {
      title = titlectrl.text.trim();
    });
  }

  void contentHandler() {
    setState(() {
      content = contentctrl.text.trim();
    });
  }

  @override
  void initState() {
    super.initState();
    title=(widget.args[0]=='new'?'':widget.args[1]['title']);
    content=(widget.args[0]=='new'?'':widget.args[1]['content']);
     color=(widget.args[0]=='new'?'red':widget.args[1]['color']);
     titlectrl.text=(widget.args[0]=='new'?'':widget.args[1]['title']);
     contentctrl.text=(widget.args[0]=='new'?'':widget.args[1]['content']);
    titlectrl.addListener(titleHandler);
    contentctrl.addListener(contentHandler);
  }

  @override
  void dispose() {
    titlectrl.dispose();
    contentctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(NoteColors[color]!['l']!),
      appBar: AppBar(backgroundColor: Color(NoteColors[color]!['b']!),
        title: NoteTitleEntry(titlectrl: titlectrl),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,

          ),
          onPressed: (){handleBackButton();},
        ),
        actions: [IconButton(onPressed: () {
          handleColor(context);
        }, icon: const Icon(Icons.color_lens), tooltip: 'color palette',)
        ],),
       body: NoteEntry(textFieldController: contentctrl),
    );
  }

  void handleColor(context) {
    showDialog(context: context,
        builder: (context) => ColorPalette(parentContext: context)).then((
        colorName) {
      if (colorName != null) {
        setState(() {
          color = colorName;
        });
      }
    });
  }

  Future<void> insertDb(Note note) async {
    NotesDatabase db = NotesDatabase();
    await db.initDataBase();
    await db.insertNote(note);
    await db.closeDatabase();
  }
Future<void> updateNote(Note note)async{
    NotesDatabase db=NotesDatabase();
    await db.initDataBase();
    await db.updateNote(note);
    await db.closeDatabase();
}
  void handleBackButton() async {
    if (title.isEmpty) {
      if (content.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      else {
        String tl = content.split('\n')[0];
        if (tl.length > 31) {
          tl = content.substring(0, 10);
        }
        setState(() {
          title = tl;
        });
      }
    }
    if(widget.args[0]=='new'){
    Note nt = Note(
        title: title,
        content: content,
        color: color
    );
    try {
      await insertDb(nt);
    } catch (e) {
      e.toString();
    } finally {
      Navigator.pop(context);
      return;
    }
  }
  else if(widget.args[0]=='update'){
    Note nt =Note(
      id: widget.args[1]['id'],title: title,content: content,color: color
    );
    try{
      await updateNote(nt);
    }
    catch(e){
      e.toString();
    }
    finally{
      Navigator.pop(context);
      return;
    }
    }

  }
}
class ColorPalette extends StatelessWidget {
  var parentContext;
   ColorPalette({Key? key, this.parentContext}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      clipBehavior: Clip.hardEdge,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: MediaQuery.of(context).size.width * 0.02,
          runSpacing: MediaQuery.of(context).size.width * 0.02,
          children: NoteColors.entries.map((entry) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(entry.key),
              child: Container(

                width: MediaQuery.of(context).size.width * 0.12,
                height: MediaQuery.of(context).size.width * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.06),
                  color: Color(entry.value['b']!),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

class NoteTitleEntry extends StatelessWidget {
  var titlectrl;
   NoteTitleEntry( {Key? key, this.titlectrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: titlectrl,
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.all(0),
        counter: null,
        counterText: "",
        hintText: 'Title',
        hintStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
      maxLength: 31,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        height: 1.5,
        color: Colors.black,
      ),
      textCapitalization: TextCapitalization.words,
    );
  }
}
class NoteEntry extends StatelessWidget {
  var textFieldController;
   NoteEntry({Key? key, this.textFieldController}) : super(key: key) ;

  @override

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: textFieldController,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        decoration: null,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 19,
          height: 1.5,
        ),
      ),
    );
  }
}


