'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('uikit/dist/css/uikit.css');
require('uikit/dist/js/uikit.js');
require('uikit/dist/js/uikit-icons.js');
require('./css/uikit-theme.css');
// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var storedState = localStorage.getItem('session');
var startingState = storedState ? JSON.parse(storedState) : null;

// .embed() can take an optional second argument.
// This would be an object describing the data we need to start
// a program, i.e. a userID or some session
var app = Elm.Main.embed(mountNode, {
  state: startingState,
  now: Date.now()
});

app.ports.setStorage.subscribe(function(state) {
  localStorage.setItem('session', JSON.stringify(state));
});

app.ports.getStorage.subscribe(function() {
  var storedState = localStorage.getItem('session');
  var startingState = storedState ? JSON.parse(storedState) : null;
  localStorage.setItem('session', JSON.stringify(startingState));
});

app.ports.removeStorage.subscribe(function() {
  localStorage.removeItem('session');
});

app.ports.openWindow.subscribe(function(url) {
  window.open(url);
});

app.ports.fileSelected.subscribe(function(id) {
  var node = document.getElementById(id);
  if(node === null) {
    return;
  }
  // If your file upload field allows multiple files, you might
  // want to consider turning this into a `for` loop.
  var file = node.files[0];
  var reader = new FileReader();

  // FileReader API is event based. Once a file is selected
  // it fires events. We hook into the `onload` event for our reader.
  reader.onload = (function(event) {
    // The event carries the `target`. The `target` is the file
    // that was selected. The result is base64 encoded contents of the file.
    var base64encoded = event.target.result;
    // We build up the `FilePortData` object here that will be passed to our Elm
    // runtime through the `fileContentRead` subscription.
    var portData = {
      contents: base64encoded,
      filename: file.name
    };

    // We call the `fileContentRead` port with the file data
    // which will be sent to our Elm runtime via Subscriptions.
    app.ports.fileContentRead.send(portData);
  });
  // Connect our FileReader with the file that was selected in our `input` node.
  reader.readAsDataURL(file);
})
