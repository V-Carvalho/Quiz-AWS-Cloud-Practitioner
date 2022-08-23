import 'package:cloud_firestore/cloud_firestore.dart';


class HomeController {

  List listCourseContent = [];

  Future<List> getCourseContent() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('courseContent').orderBy('id', descending: false).
    get(const GetOptions(source: Source.server));

    // Limpando a lista
    listCourseContent.clear();

    // Percorrendo todos os docs retornados do firebase
    for (var data in snapshot.docs) {
      // Inserindos os docs retornados num array de obj
      listCourseContent.add({
        'id': data['id'],
        'content': data['content'],
      });
    }

    return listCourseContent;
  }

}