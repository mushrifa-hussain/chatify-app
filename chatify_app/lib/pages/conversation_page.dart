import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/conversation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import "package:provider/provider.dart";
import '../providers/auth_provider.dart';
import '../models/message.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

class ConversationPage extends StatefulWidget {
  final String _conversationID;
  final String _receiverID;
  final String _receiverImage;
  final String _receiverName;

  const ConversationPage(
    this._conversationID,
    this._receiverID,
    this._receiverImage,
    this._receiverName, {
    super.key,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  double _height = 0;
  double _width = 0;

  late GlobalKey<FormState> formKey;
  late String messageText;
  late ScrollController _scrollController;
  bool isSelecting = false;
  List<String> selectedMessages = [];

  _ConversationPageState() {
    formKey = GlobalKey<FormState>();
    messageText = "";
    _scrollController = ScrollController();
  }

  void _onMessageLongPress(String messageID) {
    setState(() {
      isSelecting = true;
      selectedMessages.add(messageID);
    });
  }

  void _onMessageTap(String messageID) {
    if (isSelecting) {
      setState(() {
        if (selectedMessages.contains(messageID)) {
          selectedMessages.remove(messageID);
          if (selectedMessages.isEmpty) isSelecting = false;
        } else {
          selectedMessages.add(messageID);
        }
      });
    }
  }

  Future<void> _deleteSelectedMessages() async {
    try {
      final auth = context.read<AuthProvider>();
      await DBService.instance.deleteMessages(
        auth.user!.uid, // current user's UID
        widget._receiverID, // receiver's UID
        widget._conversationID, // conversation ID
        selectedMessages, // list of selected message IDs
      );
      if (mounted) {
        setState(() {
          selectedMessages.clear();
          isSelecting = false;
        });
      }
    } catch (e) {
      throw Exception("Error deleting messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(widget._receiverName),
        centerTitle: true,
        actions: isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelectedMessages,
                ),
              ]
            : [],
      ),

      body: _conversationPageUI(auth),
    );
  }

  Widget _conversationPageUI(AuthProvider auth) {
    return Stack(
      clipBehavior: Clip.none, // replaces overflow: Overflow.visible
      children: [
        _messageListView(auth),
        Align(
          alignment: Alignment.bottomCenter,
          child: _messageField(context, auth),
        ),
      ],
    );
  }

  Widget _messageListView(AuthProvider auth) {
    return SizedBox(
      height: _height * 0.75,
      width: _width,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget._conversationID),
        builder: (BuildContext context, snapshot) {
          Timer(Duration(milliseconds: 50), () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
          });
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWanderingCubes(color: Colors.blue, size: 50.0),
            );
          }

          if (!snapshot.hasData || snapshot.data!.messages == null) {
            return Center(
              child: Text(
                "No messages yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var conversation = snapshot.data!;
          var messages = conversation.messages!;

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: _width * 0.03,
              vertical: _height * 0.02,
            ),
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              var message = messages[index];
              bool isOwnMessage = message.senderID == auth.user!.uid;
              // false here for alignment, adjust as needed
              return _messageListViewChild(isOwnMessage, message);
            },
          );
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: isOwnMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          !isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _width * 0.02),
          message.type == MessageType.text
              ? _textMessageBubble(
                  (message.timestamp?.millisecondsSinceEpoch ?? 0).toString(),
                  isOwnMessage,
                  message.content ?? "",
                  message.timestamp ?? Timestamp.now(),
                )
              : _imageMessageBubble(
                  (message.timestamp?.millisecondsSinceEpoch ?? 0).toString(),
                  isOwnMessage,
                  message.content ?? "",
                  message.timestamp ?? Timestamp.now(),
                ),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double imageRadius = _height * 0.05;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget._receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
    String messageID,
    bool isOwnMessage,
    String message,
    Timestamp timestamp,
  ) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue.shade300, Colors.blue.shade600]
        : [Colors.grey.shade800, Colors.grey.shade600];

    final isSelected = selectedMessages.contains(messageID);

    return GestureDetector(
      onLongPress: () => _onMessageLongPress(messageID),
      onTap: () => _onMessageTap(messageID),
      child: Container(
        width: _width * 0.75,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colorScheme,
            stops: [0.2, 0.9],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: Colors.redAccent, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              timeago.format(timestamp.toDate()),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageMessageBubble(
    String messageID,
    bool isOwnMessage,
    String imageURL,
    Timestamp timestamp,
  ) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue.shade300, Colors.blue.shade600]
        : [Colors.grey.shade800, Colors.grey.shade600];

    final isSelected = selectedMessages.contains(messageID);

    return GestureDetector(
      onLongPress: () => _onMessageLongPress(messageID),
      onTap: () => _onMessageTap(messageID),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colorScheme,
            stops: [0.2, 0.9],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: Colors.red, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _height * 0.3,
              width: _width * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(imageURL),
                ),
                border: isSelected
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
            ),
            Text(
              timeago.format(timestamp.toDate()),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageField(BuildContext context, AuthProvider auth) {
    return Container(
      height: _height * 0.07,
      decoration: BoxDecoration(
        color: Color.fromRGBO(58, 58, 58, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.only(
        left: _width * 0.03,
        right: _width * 0.03,
        bottom: _height * 0.02,
      ),
      child: Form(
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _messageTextField(),
            _sendMessageButton(context, auth),
            _imageMessageButton(context, auth),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _width * 0.55,
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Type a message...",
          hintStyle: TextStyle(color: Colors.white54),
        ),
        validator: (input) {
          if (input == null || input.isEmpty) {
            return "Message cannot be empty";
          }
          return null;
        },
        onChanged: (input) {
          formKey.currentState!.save();
        },
        onSaved: (input) {
          setState(() {
            messageText = input ?? "";
          });
        },
        cursorColor: Colors.white,
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      height: _height * 0.05,
      width: _width * 0.05,
      child: IconButton(
        icon: Icon(Icons.send, color: Colors.white), // Icon
        onPressed: () {
          if (formKey.currentState!.validate()) {
            DBService.instance.sendMessage(
              widget._conversationID,
              Message(
                content: messageText,
                timestamp: Timestamp.now(),
                senderID: auth.user!.uid,
                type: MessageType.text,
              ),
            );
            formKey.currentState!.reset();
            FocusScope.of(context).unfocus(); //hides keyboard
          }
        }, // IconButton
      ), // IconButton
    ); // Container
  }

  Widget _imageMessageButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      height: _height * 0.05,
      width: _height * 0.05,
      child: FloatingActionButton(
        child: Icon(Icons.camera_enhance),
        onPressed: () async {
          var image = await MediaService.instance.getImageFromLibrary();
          if (image != null) {
            var result = await CloudStorageService.instance.uploadMediaImage(
              widget._conversationID,
              image,
            );
            var imageUrl = await result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              widget._conversationID,
              Message(
                content: imageUrl,
                senderID: auth.user!.uid,
                timestamp: Timestamp.now(),
                type: MessageType.image,
              ),
            );
          }
        }, // IconButton
      ), // IconButton
    ); // Container
  }
}
