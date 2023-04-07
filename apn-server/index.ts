import * as dotenv from "dotenv";
import apn from "apn";
dotenv.config();

const options = {
  token: {
    key: "./AuthKey_JSF5F3TY9X.p8",
    keyId: "JSF5F3TY9X",
    teamId: process.env.TEAM_ID ?? "",
  },
  production: false,
};

const apnProvider = new apn.Provider(options);
const deviceToken = process.env.DEVICE_TOKEN ?? "";

// const note = new apn.Notification({
//   alert: "\uD83D\uDCE7 \u2709 You have a new message",
//   topic: "com.ayroblu.CalTodo",
//   expiry: Math.floor(Date.now() / 1000) + 3600, // Expires 1 hour from now.
// });
const note = new apn.Notification({
  // alert: "\uD83D\uDCE7 \u2709 You have a new message",
  topic: "com.ayroblu.CalTodo",
  expiry: Math.floor(Date.now() / 1000) + 3600, // Expires 1 hour from now.
  contentAvailable: 1,
  priority: 5,
  pushType: "background",
  payload: { messageFrom: "John Appleseed" },
  // mutableContent: 1,
  // For background pushes:
  // "content-available": "1",
  // "apns-priority": "5",
  // "apns-push-type": "background",
  // "interruption-level": "time-sensitive",
});

// note.badge = 3;
// note.sound = "ping.aiff";
// note.payload = { messageFrom: "John Appleseed" };

console.log("sending");
apnProvider
  .send(note, deviceToken)
  .then((result) => {
    console.log("result", result);
    process.exit();
    // see documentation for an explanation of result
  })
  .catch(console.error);
