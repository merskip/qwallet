import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

admin.initializeApp();
const auth = admin.auth();

export const getUsers = functions.https.onCall((data, context) => {
    console.debug("Requested users from " + context.auth?.uid ?? "(anonymous)");
    return auth.listUsers().then((userRecords) => {
        return userRecords.users.map((user) => ({
            uid: user.uid,
            isAnonymous: user.email === undefined,
            displayName: user.displayName,
            email: user.email
        }));
    }).catch((error) => {
        console.error(error);
        return error;
    });
});
