const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * HTTP Cloud Function to send crowd alert notifications to all users
 * subscribed to a specific area topic.
 * 
 * Called by the Flutter app when crowd detection threshold is met.
 */
exports.sendCrowdAlert = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const { areaId, areaName, message } = data;

  // Validate input
  if (!areaId || !areaName || !message) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: areaId, areaName, message');
  }

  const topic = `area_${areaId}`;

  const notification = {
    notification: {
      title: `Community Alert - ${areaName}`,
      body: message,
    },
    data: {
      type: 'crowd_alert',
      areaId: areaId,
      areaName: areaName,
      message: message,
    },
    topic: topic,
  };

  try {
    const response = await admin.messaging().send(notification);
    console.log(`Crowd alert sent to ${topic}:`, response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending crowd alert:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send notification');
  }
});

/**
 * HTTP Cloud Function to schedule power status check notifications
 * Called when user reports power outage, sends reminder after 30 minutes
 */
exports.schedulePowerCheck = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const { areaId, areaName, userId } = data;

  if (!areaId || !areaName || !userId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  // Schedule notification for 30 minutes later
  const scheduledTime = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 30 * 60 * 1000)
  );

  // Add to Firestore collection for scheduled notifications
  await admin.firestore().collection('scheduledNotifications').add({
    userId: userId,
    areaId: areaId,
    areaName: areaName,
    type: 'power_check',
    scheduledTime: scheduledTime,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, scheduledTime: scheduledTime.toDate().toISOString() };
});
