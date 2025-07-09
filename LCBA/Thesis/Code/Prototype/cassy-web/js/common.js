// miscellaneous
var spaceNode = function() {return document.createTextNode(' ');};
var breakNode = function() {return document.createElement('BR');};

// create a containers for plugin objects
var plugins = [];
var loadedPlugins = [];
var selectedPlugin = undefined;
