var notify;
notify = function(message) {
  console.log("background script received message");
  var title = browser.i18n.getMessage("notificationTitle");
  browser.notifications.create({
    "type": "basic",
    "iconUrl": browser.extension.getURL("icons/link-48.png"),
    "title": title,
    "message": message.msg
  });
  var views = chrome.extension.getViews({
    type: "popup"
  });
  for (var i = 0; i < views.length; i++) {
    views[i].document.getElementById('x').innerHTML = "My Custom Value";
  }
}
browser.runtime.onMessage.addListener(notify);
