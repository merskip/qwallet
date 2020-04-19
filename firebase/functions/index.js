const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const auth = admin.auth();

/**
 * Gets all the users (1000 MAX) from Firebase auth.
 */
const getAllUsers = (data, context) => {
	console.debug("Requested users from " + context.auth.uid);
	return auth.listUsers().then((userRecords) => {
		const users = userRecords.users.map((user) => {
			return {
				uid: user['uid'],
				isAnonymous: user['email'] === undefined,
				displayName: user['displayName'],
				email: user['email']
			};
		});
		return JSON.stringify(users);
	}).catch((error) => {
		console.error(error);
		return error;
	});
};

exports.users = functions.https.onCall(getAllUsers);
