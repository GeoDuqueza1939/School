// create classroom management plugin object
var classManPlugin = {
    name: 'Classroom Management',
    id: 'classManPlugin',
    isEnabled: true,
    hasMenuEntry: true,
    isSelected: false,
    // create wrappers
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '<div class="pluginClient" id="classManClient">' +
        '<h1 class="pluginClientHeading">Classroom Management</h1>' +
        '<div id="classManClientActivity">' +
        '<p>No activities found</p>' +
        '</div>' +
        '<div id="classManClientRecitation">' +
        '<p>No recitations found</p>' +
        '</div>' +
        '<div id="classManClientSeatPlan">' +
        '<p>No seatplans found</p>' +
        '</div>' +
        '</div>',
    clientId: 'classManClient'
};

// add classroom management plugin object to plugin collections
plugins.push(classManPlugin);
