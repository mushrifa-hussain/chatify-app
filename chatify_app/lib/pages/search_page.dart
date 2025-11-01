import 'package:chatify_app/models/contact.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/navigation_service.dart';
import '../pages/conversation_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late String searchText;

  _SearchPageState() {
    searchText = "";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        child: Center(child: _searchPageUI(auth)),
      ),
    );
  }

  Widget _searchPageUI(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _userSearchField(),
          SizedBox(height: 12),
          _usersListView(auth),
        ],
      ),
    );
  }

  Widget _userSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: (input) => {
          setState(() {
            searchText = input;
          }),
        },
      ),
    );
  }

  Widget _usersListView(AuthProvider auth) {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(searchText),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitWanderingCubes(color: Colors.blue, size: 50.0);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No users found",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }
        var usersData = snapshot.data;
        if (usersData != null) {
          usersData.removeWhere((user) => user.id == auth.user!.uid);
        }
        return SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: usersData!.length,
            itemBuilder: (BuildContext context, int index) {
              var userData = usersData[index];
              var isUserActive = false;
              var recepientID = userData.id!;
              final lastSeenText = userData.lastseen != null
                  ? timeago.format(userData.lastseen!.toDate())
                  : "No data";
              if (userData.lastseen != null) {
                isUserActive = userData.lastseen!.toDate().isAfter(
                  DateTime.now().subtract(Duration(minutes: 5)),
                );
              }
              return SizedBox(
                height: 60,
                child: ListTile(
                  title: Text(
                    userData.name ?? "No Name",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => {
                    DBService.instance.createOrGetConversation(
                      auth.user!.uid,
                      recepientID,
                      (String conversationID) async {
                        NavigationService.instance.navigateToRoute(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return ConversationPage(
                                conversationID,
                                userData.id!,
                                userData.image ?? '',
                                userData.name ?? 'No Name',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  },

                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          userData.image ??
                              'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                        ),
                      ),
                    ), //
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isUserActive
                          ? Text(
                              "Active Now",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            )
                          : Text(
                              "Last seen",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                      isUserActive
                          ? Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Text(
                              lastSeenText,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
