import 'item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const GEMINI_API_KEY="AIzaSyAR422QbUHwHJrNThsfT2bGvdRCBUvK4pY";

//import 'package:whatsapp_share/whatsapp_share.dart';
//import 'package:share_plus/share_plus.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({super.key, 
    required this.isInTabletLayout,
    required this.item,
  });
  final bool isInTabletLayout;
  final Item item;

  @override
  State<ItemDetails> createState() =>
      ItemDetailsState(isInTabletLayout: isInTabletLayout, item: item);
}

class ItemDetailsState extends State<ItemDetails> {
  ItemDetailsState({
    required this.isInTabletLayout,
    required this.item,
  });

  final bool isInTabletLayout;
  final Item item;

  final picker = ImagePicker();

  Future getImage(
    ImageSource img,
    Item item,
  ) async {
    final XFile? pickedFile = await picker.pickImage(source: img);
    item.picture = pickedFile?.path as String;
  }

  Future<void> sendEmailC(Item item) async {
    String html = "<html><body>";
    html +=
        '<head><meta name="viewport" content="width=device-width, initial-scale=1.0"></meta></head>';
    html += '<table style="width:75%;margin:auto;">';
    html += '<tr><td><h1>Thank You</h1></td></tr>';
    html += '<tr><td><p>${item.notes}</p></td></tr>';
    html += '<tr><td><img width="100%" src="cid:guest@photo"></td></tr>';
    html += "</table>";
    html += '</body></html>';
    final Email email = Email(
      body: html,
      subject: 'Thank you',
      recipients: [item.email],
      attachmentPaths: [item.picture],
      isHTML: true,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email).then((a) => item.completed = true);
      platformResponse = 'success';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  /* Future sendWhatsapp(
    Item item,
  ) async {
    await WhatsappShare.shareFile(
        phone: '5626503865', text: item.notes, filePath: [item.picture]);
  }
*/
  Future sendEmail(
    Item item,
  ) async {
    String username = 'mmgg@manikrit.com';
    String password = 'g2Garg01';

    final smtpServer = SmtpServer('mail.manikrit.com',
        port: 587, username: username, password: password);
    File pic = File(item.picture);
    Attachment a = FileAttachment(pic);
    a.cid = "<guest@photo>";
    a.location = Location.inline;
    String html = "<html><body>";
    html +=
        '<head><meta name="viewport" content="width=device-width, initial-scale=1.0"></meta></head>';
    html += '<table style="width:75%;margin:auto;">';
//    html += '<tr><td><h1>Thank You</h1></td></tr>';
    html += '<tr><td><p>${item.notes}</p></td></tr>';
    html += '<tr><td><img width="100%" src="cid:guest@photo"></td></tr>';
    html += "</table>";
    html += '</body></html>';

    // Create our message.
    final message = Message();
    message.from = Address(username, username);
    message.recipients.add(item.email);
//    message.ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com']);
//    message.bccRecipients.add(Address('bccAddress@example.com'));
    message.subject = 'Thank You 😀';
    message.text = item.notes;
    message.html = html;
    message.attachments.add(a);
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
      item.completed = true;
    } on MailerException catch (e) {
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
  
  TextEditingController notesController=TextEditingController(text:"");
  Future<String> genNote() async {
    final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent'),
        // NB: you don't need to fill headers field
        headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-goog-api-key':GEMINI_API_KEY
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {"text": "Write a brief thank you note for my friend Mohan who came to may Krish's third birthday party. Also add appreceation for the gift of a train toy he gave"}
              ]
            }
          ]
        }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Extract and return the generated content from the response
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
        return "Error ${response.statusCode}: ${response.body}";
    }
}
  @override
  Widget build(BuildContext context) {
    final Widget content = Form(
        key: Key(item.name),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              initialValue: item.name,
              onChanged: (text) => {item.name = text},
              decoration: const InputDecoration(
                  labelText: 'Name',
                  errorStyle: TextStyle(fontSize: 10.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(9.0)))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: item.email,
              onChanged: (text) => {item.email = text},
              decoration: const InputDecoration(
                  labelText: 'E-mail',
                  errorStyle: TextStyle(fontSize: 10.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(9.0)))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: item.phone,
              onChanged: (text) => {item.phone = text},
              decoration: const InputDecoration(
                  labelText: 'Phone',
                  errorStyle: TextStyle(fontSize: 10.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(9.0)))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone';
                }
                return null;
              },
            ),
            TextFormField(
              controller: notesController,
              initialValue: item.notes,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              onChanged: (text) => {item.notes = text},
              decoration: const InputDecoration(
                  labelText: 'Note',
                  errorStyle: TextStyle(fontSize: 10.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(9.0)))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone';
                }
                return null;
              },
            ),
            Image.file(
              File(item.picture),
              width: 200.0,
              height: 200.0,
              fit: BoxFit.fitHeight,
            ),
            IconButton(
              iconSize: 30,
              icon: const Icon(
                Icons.image,
                color: Colors.blue,
              ),
              alignment: Alignment.centerRight,
              onPressed: () {
                //onDeleteGuest(guest);
                getImage(ImageSource.gallery, item)
                    .then((value) => setState(() {}));
              },
            ),
            IconButton(
              iconSize: 30,
              icon: const Icon(
                Icons.note_add,
                color: Colors.blue,
              ),
              alignment: Alignment.centerRight,
              onPressed: () {
                    genNote().then((note) {notesController.text=note; setState(() {});});
              },
            ),
          ],
        ));

    if (isInTabletLayout) {
      return Center(child: content);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Center(child: content),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          sendEmailC(item).then((value) => setState(() {}));
          sendEmail(item).then((value) => setState(() {}));
//          sendWhatsapp(item).then((value) => setState(() {}));
        },
        tooltip: 'Add a Guest',
        child: const Icon(Icons.email),
      ),
    );
  }
}
