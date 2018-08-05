// create admin plugin object
var adminPlugin = {
    name: 'Administrator Plugin',
    id: 'adminPlugin',
    isEnabled: true,
    hasMenuEntry: false,
    isSelected: false, // disregarded when hasMenuEntry is false
    // create wrappers
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '',
    clientId: 'adminClient'
};


// add task plugin object to plugin collections
plugins.push(adminPlugin);
