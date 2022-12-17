class Note{
  int ?id;
  String title;
  String content;
  String color;
  Note({this.id=null, this.title="Note", this.content="Text",this.color="red"});
  Map<String,dynamic>toMap(){
    Map<String,dynamic> data =Map<String,dynamic>();
    if(id!=null){
      data['id']=id;
    }
    data['title']=title;
    data['content']=content;
    data['color']=color;
    return data;
  }
  @override
  String toString() {
    return {
      'id':id,
      'title':title,
      'content':content,
      'color':color,

    }.toString();
  }


}