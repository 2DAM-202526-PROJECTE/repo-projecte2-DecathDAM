const functions = require("firebase-functions");
const stripe = require("stripe")(functions.config().stripe.secret);

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
    // Verificació d'autenticació (opcional però recomanat)
    // if (!context.auth) {
    //   throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    // }

    const { amount, currency } = data;

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount, // En cèntims (p. ex. 10€ = 1000)
            currency: currency || "eur",
            automatic_payment_methods: {
                enabled: true,
            },
        });

        return {
            clientSecret: paymentIntent.client_secret,
        };
    } catch (error) {
        console.error("Error creating payment intent:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});
