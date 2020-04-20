import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

admin.initializeApp();
const auth = admin.auth();
const db = admin.firestore();

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

export const updateBalance = functions.firestore
    .document('wallets/{walletId}/expenses/{expenseId}')
    .onWrite((change, context) => {

        console.debug("Updating wallet (" + context.params.walletId + ") balance");

        const walletRef = db.collection('wallets').doc(context.params.walletId);
        const expensesRef = walletRef.collection('expenses'); // TODO: Get only from current month

        return db.runTransaction(transaction => {
            transaction.update(walletRef, {
                isBalanceOutdated: true,
            });

            return transaction.get(expensesRef).then(expensesDoc => {

                const totalAmount = expensesDoc.docs
                    .map(expense => expense.get("amount"))
                    .reduce((previous, current) => previous + current, 0);

                console.log("walletId=" + context.params.walletId + " Total amount: ", totalAmount);

                return transaction.update(walletRef, {
                    balance: totalAmount,
                    isBalanceOutdated: false,
                });
            });
        });
    });