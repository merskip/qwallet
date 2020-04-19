import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

admin.initializeApp();
const auth = admin.auth();

export const callUsers = functions.https.onCall((data, context) => {
    console.debug("Requested users from " + context.auth?.uid ?? "(anonymous)");
    return auth.listUsers().then((userRecords) => {
        const users = userRecords.users.map((user) => {
            return {
                uid: user.uid,
                isAnonymous: user.email === undefined,
                displayName: user.displayName,
                email: user.email
            };
        });
        return JSON.stringify(users);
    }).catch((error) => {
        console.error(error);
        return error;
    });
});