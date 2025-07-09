// create class record plugin object
var classRecordPlugin = {
    name: 'Class Record',
    id: 'classRecordPlugin',
    isEnabled: true,
    hasMenuEntry: true,
    isSelected: false,
    // create wrappers
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '<div class="pluginClient" id="classRecordClient">' +
        '<h1 class="pluginClientHeading">Class Record</h1>' +
        '<div id="classRecordClientSubjectLists">' +
        '<p>No subjects found</p>' +
        '</div>' +
        '<div id="classRecordClientSectionLists">' +
        '<p>No sections found</p>' +
        '</div>' +
        '<div id="classRecordClientStudentRecords">' +
        '<p>No students found</p>' +
        '</div>' +
        '</div>',
    clientId: 'classRecordClient'
};


// add class record plugin object to plugin collections
plugins.push(classRecordPlugin);
