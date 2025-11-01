import 'package:chatify_app/models/conversation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/navigation_service.dart';
import '../pages/conversation_page.dart';
import '../models/message.dart';

class RecentConversationsPage extends StatelessWidget {
  const RecentConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        child: auth.user == null
            ? const Center(
                child: Text(
                  "No user logged in",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : _conversationsListViewWidget(auth),
      ),
    );
  }

  Widget _conversationsListViewWidget(AuthProvider auth) {
    return StreamBuilder<List<ConversationSnippet>>(
      stream: DBService.instance.getUserConversations(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitWanderingCubes(color: Colors.blue, size: 50.0);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No conversations yet",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        var data = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            var conversation = data[index];
            return ListTile(
              onTap: () => {
                NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ConversationPage(
                        conversation.chatID!,
                        conversation.id!,
                        conversation.imageUrl ?? '',
                        conversation.name ?? 'No Name',
                      );
                    },
                  ),
                ),
              },
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      conversation.imageUrl ??
                          'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                conversation.name ?? 'No Name',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                conversation.type == null
                    ? "No messages yet"
                    : conversation.type == MessageType.text
                    ? (conversation.lastMessage ?? '')
                    : 'Attachment: Image',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: conversation.timestamp != null
                  ? _listTileTrailingWidgets(conversation.timestamp!)
                  : const SizedBox(), // empty space if no timestamp
            );
          },
        );
      },
    );
  }

  Widget _listTileTrailingWidgets(Timestamp lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Last Message",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 7),
        Text(
          timeago.format(lastMessageTimestamp.toDate()),
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
