// create plugin manager plugin object
var plugManPlugin = {
    name: 'Plugin Manager',
    id: 'plugManPlugin',
    get isEnabled() {
        return true; // always true
    },
    hasMenuEntry: true,
    isSelected: false,
    // create wrappers
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '<div class="pluginClient" id="plugManClient">' +
        '<h1 class="pluginClientHeading">Plugin Manager</h1>' +
        '<div id="plugManClientPluginList">' +
        '<p>No plugins found</p>' +
        '</div>' +
        '</div>',
    clientId: 'plugManClient'
};

// add plugin manager plugin object to plugin collections
plugins.push(plugManPlugin);
