import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:alquran/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class isi{
  final String arab;
  final String arti;
  final int ayat;
  final int juz;
  
  isi({required this.arab, required this.arti, required this.ayat, required this.juz});
}


class surat extends StatefulWidget {
  final String indeks;
  final String nama;
  final String jmlayat;
  final String artinya;
  final String turun;
  final String link;

surat({required this.indeks, required this.nama, required this.jmlayat, required this.artinya, required this.turun, required this.link});

  @override
  State<surat> createState() => _suratState();
}

class _suratState extends State<surat> {
  bool bm = false;
  bool _checkFileExistsSync(String path) {
    return File(path).existsSync();
  }

  Future<List<isi>> getRequest() async {
    String url = "https://quran-api-id.vercel.app/surahs/"+widget.indeks;
    final hasilResponse = await http.get(Uri.parse(url));
    var respon = (jsonDecode(hasilResponse.body))["ayahs"] as List<dynamic>; //corrected

    List<isi> array = [];
    for (var surah_ in respon){
      isi surat = isi(arab: surah_["arab"], arti: surah_["translation"], ayat: surah_["number"]["inSurah"], juz: surah_["meta"]["juz"]);
      array.add(surat);
      
    }
    return array;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Stack(
      children: [
       Positioned(
         bottom: 0,
         right: 0,
         left: 0,
         top: 0,
         child: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        //  toolbarHeight: 40, 
       backgroundColor: Color.fromARGB(255, 57, 114, 99),
      //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
       elevation: 0,
       flexibleSpace: SafeArea(
         child: Container(
           padding: EdgeInsets.only(right: 10, bottom: 0, top: 0, left: 5),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
              SizedBox(width: 55,),
               Expanded(
               child: Padding(
                 padding: const EdgeInsets.only(top: 3),
                 child: Column(
                   children: [
                     Text('"' + widget.artinya + '"', style: GoogleFonts.notoKufiArabic(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(widget.turun + " | ", style: TextStyle(color: Colors.white, fontSize: 14)), Text(widget.jmlayat+" Ayat", style: TextStyle(color: Colors.white, fontSize: 14),),]),
                   ],
                 ),
               )),
               IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: Colors.white,))
             ],
           ),
         ),
       ),
     ),
     ),
    Positioned(
       top: 85,
       bottom: 0,
       left: 0,
       right: 0,
       child: 
       Container(
       clipBehavior: Clip.antiAlias,
       padding: EdgeInsets.only(top: 0, bottom: 65), //daftar surat
       decoration: BoxDecoration(
         color: Colors.white,
         border: Border.all(
           color: Colors.white,
           width: 0,
         ),
         borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
       ), 
      child: (int.parse(widget.indeks) > 1) ? 
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Text(widget.nama, style: GoogleFonts.notoKufiArabic(fontSize: 20, color: Color.fromARGB(255, 180, 149, 102), fontWeight: FontWeight.bold)),
            Text("بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ", style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 24, 128, 94),),)
          ],) : 
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Text(widget.nama, style: GoogleFonts.notoKufiArabic(fontSize: 24, color: Color.fromARGB(255, 180, 149, 102), fontWeight: FontWeight.bold)),
          ],)
      ,
       )
       ),
       Positioned(
        top: 170,
        bottom: 60,
        left: 15,
        right: 15,
      child: Container(
       clipBehavior: Clip.antiAlias,
       //daftar surat
       decoration: BoxDecoration(
         color: Color.fromARGB(255, 241, 241, 241),
         border: Border.all(
           color: Colors.white,
           width: 0,
         ),
         borderRadius: BorderRadius.all(Radius.circular(30)),
       ), 
       child: FutureBuilder(
         future: getRequest(),
         builder: (BuildContext context, AsyncSnapshot surat) {
          if (surat.hasData) {
           return ListView.builder(
            shrinkWrap: true,
            itemCount: surat.data.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 15),
                    leading: Stack(children: [
                      Image.asset('assets/ornamen.png', scale: 11, color: Color.fromARGB(255, 24, 128, 94),),
                      Positioned.fill(top: 12.5, child: Text(surat.data[index].ayat.toString().toFarsi(), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 24, 128, 94),), textAlign: TextAlign.center,))
                    ],),
                    title: Text(surat.data[index].arab, textAlign: TextAlign.end, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 10,),
                        Text(surat.data[index].arti, textAlign: TextAlign.justify,),
                      ],
                    ),
                    onTap: () {
                      surat_terakhir = widget.nama;
                      ayat_terakhir = surat.data[index].ayat.toString();
                      juz_terakhir = surat.data[index].juz.toString();
                      Fluttertoast.showToast(msg: "Ditambahkan terakhir dibaca");
                    },
                  ),
                  Divider(height: 0.1, color: const Color.fromARGB(255, 198, 198, 198),), // Add this line
                ],
              );
            },
          );
          } else if (surat.hasError) {
              return Center(
                child: Text('Error: ${surat.error}'),
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
       )),
       Positioned.fill(
        bottom: 10,
        right: 10,
        left: 10,
         child: Align(
         alignment: Alignment.bottomCenter, 
         child: Container( 
           padding: EdgeInsets.only(right: 10, left: 10),
           height: 40,
           width: double.infinity,
           decoration: BoxDecoration(
             color: Color.fromARGB(255, 24, 128, 94),
           border: 
           Border.all(
             color: Color.fromARGB(255, 226, 226, 226),
             width: 0,
           ),
           borderRadius: BorderRadius.all(Radius.circular(15)),
         ),
         child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          GestureDetector(
            onTap: () async {
              if (_checkFileExistsSync('/storage/emulated/0/Android/data/com.example.alquran/files/${widget.nama}.mp3')){
                      OpenFile.open('/storage/emulated/0/Android/data/com.example.alquran/files/${widget.nama}.mp3');
                    } else {
                      Fluttertoast.showToast(msg: "Belum Di download");
                    }              
            },
            child: Container(child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("DENGARKAN", style: GoogleFonts.notoKufiArabic(color: Colors.white, fontSize: 15),),
                SizedBox(width: 5,),
                Icon(Icons.headphones, color: Colors.white,),
              ],
            ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (_checkFileExistsSync('/storage/emulated/0/Android/data/com.example.alquran/files/${widget.nama}.mp3')){
                      Fluttertoast.showToast(msg: "File Sudah Ada");
                    } else {
                      Fluttertoast.showToast(msg: "Downloading...");
                      final response = await http.get(Uri.parse(widget.link));
                      final Directory? directory = await getExternalStorageDirectory();
                      final File file = File('${directory?.path}/${widget.nama}.mp3');
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
            child: Container(child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("DOWNLOAD", style: GoogleFonts.notoKufiArabic(color: Colors.white, fontSize: 15,),),
                SizedBox(width: 5,),
                Icon(Icons.cloud_download_outlined, color: Colors.white),
              ],
            ),),
          ),
         ],),
          )),
       )
      ]
     ),
     );
  }
}


// nama surat, ayat arab, arti, jumlah ayat, diturunkan/juz, (opsional: nomor ayat)