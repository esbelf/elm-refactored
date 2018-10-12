'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('uikit/dist/css/uikit.css');
require('uikit/dist/js/uikit.js');
require('./css/uikit-theme.css');
// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var storedState = localStorage.getItem('session');
var startingState = storedState ? JSON.parse(storedState) : null;

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some session
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
  console.log("remove session");
  localStorage.removeItem('session');
});

app.ports.openWindow.subscribe(function(url) {
  window.open(url);
});

// app.ports.expired.subscribe(function(exp) {
//   expDate = new Date(exp);
//   currentTime = Date.now();
//   if( expDate > currentTime ) {
//     return false;
//   }
//   return true;
// });
