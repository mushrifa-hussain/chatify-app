import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

export const onConversationCreated = onDocumentCreated("Conversations/{chatID}", async (event) => {
    const snapshot = event.data; //stored entire document
    const chatID = event.params.chatID; //extracted chatID from path
    const data = snapshot?.data(); //extracted data from document
    if (!data) return null;

    const members: string[] = data.members; //array of userIDs
    for (let currentUserID of members) {
        const remainingUserIDs = members.filter((u) => u !== currentUserID); //other members except currentUserID
        for (let m of remainingUserIDs) {
            const _doc = await admin.firestore().collection("Users").doc(m).get(); //read user document to get name, image....
            const userData = _doc.data(); //userData of member 'm'
            if (userData) { 
                await admin.firestore()
                .collection("Users")
                .doc(currentUserID)
                .collection("Conversations")
                .doc(m)
                .set({
                    chatID: chatID,
                    imageUrl: userData.imageUrl || "",
                    name: userData.name || "Unknown",
                    unseenCount: 1,
                    }
                );
            }
        }
    }
    return null;
});

export const onConversationUpdated = onDocumentUpdated("Conversations/{chatId}", async (event) => {
    const data = event.data?.after?.data();
    if (!data || !data.messages || data.messages.length === 0) return null;

    const members: string[] = data.members;
    const lastMessage = data.messages[data.messages.length - 1];

    for (const currentUserID of members) {
        const remainingUserIDs = members.filter((u) => u !== currentUserID);
        for (const u of remainingUserIDs) {
            try {
                await admin.firestore()
                    .collection("Users")
                    .doc(currentUserID)
                    .collection("Conversations")
                    .doc(u)
                    .update({
                        lastMessage: lastMessage.message || "",
                        timestamp: lastMessage.timestamp || Date.now(),
                        type: lastMessage.type || "text",
                        unseenCount: admin.firestore.FieldValue.increment(1),
                    });
            } catch (err) {
                console.log(`Failed to update conversation for ${currentUserID} with ${u}:`, err);
            }
        }
    }

    return null;
});