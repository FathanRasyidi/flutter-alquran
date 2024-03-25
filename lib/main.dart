// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, sort_child_properties_last

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:alquran/splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:alquran/surah.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

main(){
  runApp(MyApp());
}

String? surat_terakhir;
String? ayat_terakhir;
String? juz_terakhir;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splash(), 
    );
  }

}

class Surah {
  final int nomor;
  final String nama;
  final int ayat;
  final String turun;
  final String audio;
  final String deskripsi;
  final String arti;

  Surah({required this.nomor, required this.nama, required this.ayat, required this.turun, required this.audio, required this.deskripsi, required this.arti});
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

extension ToFarsiNumber on String {
  String toFarsi() {
    const Map<String, String> numbers = {
      '0': '۰',
      '1': '۱',
      '2': '۲',
      '3': '۳',
      '4': '۴',
      '5': '۵',
      '6': '۶',
      '7': '۷',
      '8': '۸',
      '9': '۹',
    };

    return replaceAllMapped(
      RegExp('[0-9]'),
      (match) => numbers[this[match.start]]!,
    );
  }
}

class _HomeState extends State<Home> {

  bool _checkFileExistsSync(String path) {
    return File(path).existsSync();
  }
  
  Future<List<Surah>> getRequest() async {
    String url = "https://quran-api-id.vercel.app/surahs/";
    final hasilResponse = await http.get(Uri.parse(url));
    var respon = jsonDecode(hasilResponse.body) as List<dynamic>; //corrected

    List<Surah> array = [];
    for (var surah_ in respon){
      Surah surat = Surah(nomor: surah_["number"], nama: surah_["name"], ayat: surah_["numberOfAyahs"], turun: surah_["revelation"], audio: surah_["audio"], deskripsi: surah_["description"], arti: surah_["translation"]);
      array.add(surat);
    }
    return array;
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.transparent,
   extendBodyBehindAppBar: false, 
   body: 
   Stack(
     children: [
       Positioned(
         bottom: 0,
         right: 0,
         left: 0,
         top: 0,
         child: AppBar(
       backgroundColor: Color.fromARGB(255, 57, 114, 99),
      //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
       elevation: 0,
       flexibleSpace: Container(
         padding: EdgeInsets.only(right: 10, bottom: 0, top: 35, left: 5),
         child: Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             IconButton(onPressed: () {}, icon: Icon(Icons.settings, color: Colors.white, size: 25,)),
             SizedBox(width: 0,),
             IconButton(onPressed: () {}, icon: Icon(Icons.search, color: Colors.white, size: 25,)),
             Expanded(
               child: Padding(
                 padding: const EdgeInsets.only(top: 5),
                 child: Text("القرآن كاريم", style: GoogleFonts.notoKufiArabic(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
               )),
             SizedBox(width: 28,),
             IconButton(onPressed: () {}, icon: Icon(Icons.favorite, color: Colors.white,))
           ],
         ),
       ),
     ),
     ),
     Positioned(
       top: 90,
       bottom: 0,
       left: 0,
       right: 0,
       child: 
       Container(
       clipBehavior: Clip.antiAlias,
       padding: EdgeInsets.only(top: 120, bottom: 65), //daftar surat
       decoration: BoxDecoration(
         color: Color.fromARGB(255, 242, 242, 242),
         border: Border.all(
           color: Colors.white,
           width: 0,
         ),
         borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
       ), 
       child: FutureBuilder(
         future: getRequest(),
         builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData){
           return ListView.builder(
             shrinkWrap: true,
             itemCount: snapshot.data.length,
             itemBuilder: (context, index) => ListTile( 
               leading: Stack(children: [ Image.asset('assets/ornamen.png'),
                 Positioned.fill(top: 17,child: Text(snapshot.data[index].nomor.toString().toFarsi(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 24, 128, 94), ),  textAlign: TextAlign.center,))  
               ],),
               title: Text(snapshot.data[index].nama),
               subtitle: Row(children: [Text(snapshot.data[index].turun + " | ", style: TextStyle(color: Color.fromARGB(255, 218, 180, 124)),), Text(snapshot.data[index].ayat.toString()+" Ayat", style: TextStyle(color: Color.fromARGB(255, 218, 180, 124)),),]),
               contentPadding: EdgeInsets.only(left: 15, right: 15),
               trailing: 
               Wrap(
                 spacing: 0, // space between two icons
                 children: [
                   IconButton(onPressed: () async {
                    if (_checkFileExistsSync('/storage/emulated/0/Android/data/com.example.alquran/files/${snapshot.data[index].nama}.mp3')){
                      OpenFile.open('/storage/emulated/0/Android/data/com.example.alquran/files/${snapshot.data[index].nama}.mp3');
                    } else {
                      Fluttertoast.showToast(msg: "Downloading...");
                      final response = await http.get(Uri.parse(snapshot.data[index].audio));
                      final Directory? directory = await getExternalStorageDirectory();
                      final File file = File('${directory?.path}/${snapshot.data[index].nama}.mp3');
                      if (response.statusCode == 200) {
                        await file.writeAsBytes(response.bodyBytes);
                        print('File downloaded successfully: ${directory?.path}');
                        Fluttertoast.showToast(msg: "Download Completed");
                        setState(() {
                          
                        });
                      } else {
                        Fluttertoast.showToast(msg: "Download failed");
                      }
                    }              
                    }, 
                    icon: 
                    Icon(_checkFileExistsSync('/storage/emulated/0/Android/data/com.example.alquran/files/${snapshot.data[index].nama}.mp3') ? Icons.play_circle_outline_rounded : Icons.cloud_download_outlined, color: Color.fromARGB(255, 161, 161, 161), size: 24,)),
                   IconButton(onPressed: (){
                     {
                     Widget okButton = TextButton(child: Text("OK"),onPressed: () {
                       Navigator.pop(context);
                     },);
   
                     AlertDialog alert = AlertDialog(
                       title: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(snapshot.data[index].nama, style: TextStyle(fontWeight: FontWeight.bold),),
                           Row(
                             children: [
                               Text(snapshot.data[index].turun + " | ", style: TextStyle(color: Color.fromARGB(255, 180, 149, 102), fontSize: 13),),
                               Text(snapshot.data[index].ayat.toString()+" Ayat", style: TextStyle(color: Color.fromARGB(255, 180, 149, 102), fontSize: 13),)
                             ],
                           ), 
                         ],
                       ),
                       content: Scrollbar( 
                         thumbVisibility: true,
                         child: ConstrainedBox(constraints: BoxConstraints(maxHeight: 350), child: SingleChildScrollView(
                           physics: BouncingScrollPhysics(),
                           padding: EdgeInsets.only(right: 20, left: 0),
                           child: Text(snapshot.data[index].deskripsi, textAlign: TextAlign.start, style: GoogleFonts.notoKufiArabic(fontSize: 15),),
                         ),), 
                       ),
                       actions: [okButton],
                     );
   
                     showDialog(context: context, builder: (BuildContext) {
                       return alert;
                       },
                     );
                   }
                   }, icon: Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 161, 161, 161), size: 20,),)
                 ],
               ),
              
               onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
                surat(indeks: '${index+1}', nama: snapshot.data[index].nama, jmlayat: snapshot.data[index].ayat.toString(), artinya: snapshot.data[index].arti, turun: snapshot.data[index].turun, link: snapshot.data[index].audio,))).then((_) {setState(() {
                  
                });});
               },
             ),
           );
          } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color.fromARGB(255, 24, 128, 94),),
                  SizedBox(height: 10,),
                  Text("Ensure you are connected to internet")
                ],
              ),
            );
         }
       ),
     ), 
     ),
     Positioned(
      top: 103,
      left: 13,
      //  width: 387,
       height: 130,
      //  bottom: 610,
      right: 13,
      //  left: 13,
      
       child: 
       Container(
         clipBehavior: Clip.antiAlias,
         decoration: BoxDecoration(
         gradient: LinearGradient(
         begin: Alignment.topCenter,
         end: Alignment.bottomCenter,
         colors: <Color>[Color.fromARGB(255, 228, 228, 228), Color.fromARGB(255, 197, 196, 196)]),
         border: Border.all(
           color: Colors.white,
           width: 0,
         ),
         borderRadius: BorderRadius.all(Radius.circular(30)),
       ), 
       child: Row(
         children: [
           SizedBox(width: 20,),
           SizedBox(height: 120, width: 100, child: Image.asset('assets/ramadan.png', scale: 1,),),
           // SizedBox(width: 100,),
           Expanded(
             child: Container(
               padding: EdgeInsets.only(top: 5, bottom: 5, right: 15),
               child: 
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                       Text("Terakhir Dibaca", style: GoogleFonts.notoKufiArabic(color: Colors.black45), ),
                       SizedBox(width: 5,),
                       Image.asset('assets/al-quran.png', scale: 20, color: Color.fromARGB(255,54, 169, 123),)
                     ],
                   ),
                   SizedBox(height: 6,),
                   (surat_terakhir != null) ? Text(surat_terakhir!, style: GoogleFonts.notoKufiArabic(color: Color.fromARGB(255,54, 169, 123), fontSize: 27,), ) :
                   Text("Terakhir Dibaca", style: GoogleFonts.notoKufiArabic(color: Color.fromARGB(255,54, 169, 123), fontSize: 27), ),
                   Text('------------------------------', style: GoogleFonts.notoKufiArabic(color: Colors.black45,),),
                   (ayat_terakhir != null) ? Text("Ayat " + ayat_terakhir! + "  |  Juz " + juz_terakhir!, style: GoogleFonts.notoKufiArabic(color: Colors.black45, fontWeight: FontWeight.w500),) :
                   Text("Anda belum membaca Quran", style: GoogleFonts.notoKufiArabic(color: Colors.black45,),)
                 ],
               )
             ),
           )
         ],
       ),
       )
     ),
     Align(
       alignment: Alignment.bottomCenter, 
       child: Container( 
         padding: EdgeInsets.only(right: 10, left: 10),
         height: 65,
         width: double.infinity,
         decoration: BoxDecoration(
           color: Colors.white,
         border: 
         Border.all(
           color: Color.fromARGB(255, 226, 226, 226),
           width: 0,
         ),
         borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
       ), 
       child: 
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
           Column( 
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
             Image.asset('assets/menu.png', scale: 15, opacity: AlwaysStoppedAnimation(0.4)),
             Text("Menu", textAlign: TextAlign.center, style: TextStyle(color: Colors.black45))
           ],),
           Column( 
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
             SizedBox(height: 1,),
             Image.asset('assets/bookmark.png', scale: 15, opacity: AlwaysStoppedAnimation(0.4)),
             SizedBox(height: 0,),
             Text("Bookmark", textAlign: TextAlign.center, style: TextStyle(color: Colors.black45))
           ],),
           SizedBox(width: 50,),
           Column( 
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
             SizedBox(height: 0,),
             Image.asset('assets/doa.png', scale: 11, opacity: AlwaysStoppedAnimation(0.4)),
             Text("Doa", textAlign: TextAlign.center, style: TextStyle(color: Colors.black45))
           ],),
           Column( 
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
             Image.asset('assets/mosque.png', scale: 16, opacity: AlwaysStoppedAnimation(0.4),),
             SizedBox(height: 5,),
             Text("Masjid", textAlign: TextAlign.center, style: TextStyle(color: Colors.black45),)
           ],),
         ],
       ),
       ),
     ),
     Positioned(
      bottom: 5, 
      height: 80,
      right: 167,
      left: 167, 
      child: 
       SizedBox(height: 80, width: 80,child: FloatingActionButton(onPressed: (){}, child: Column(
         children: [
           SizedBox(height: 10,),
           Image.asset('assets/quran.png', scale: 12,),
           Text("Quran", style: TextStyle(color: Colors.white),)
         ],
       ),backgroundColor: Color.fromARGB(255, 157, 192, 177), shape: CircleBorder(), )),), 
     ],
     ),
     );  
  }
  
}

// tua #195E59 Color.fromARGB(255,25,94,89)
//muda #35A97A Color.fromARGB(255, 53, 169, 122)