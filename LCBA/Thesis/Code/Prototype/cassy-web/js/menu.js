// create settings menu object
var prefsMenu = {
    name: 'Preferences Menu',
    id: 'prefsMenu',
    get isEnabled() { return true; },
    get hasMenuEntry() { return true; },
    isSelected: false,
    // create wrappers
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '<div class="menuClient" id="prefsClient">' +
        '<h1 class="menuClientHeading">Preferences</h1>' +
        '<div id="prefsClientPluginList">' +
        '<p>No settings available yet</p>' +
        '</div>' +
        '</div>',
    clientId: 'prefsClient'
};

// create profile menu object
var profileMenu = {
    name: 'Profile Menu',
    id: 'profileMenu',
    get isEnabled() { return true; },
    get hasMenuEntry() { return true; },
    isSelected: false,
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '<div class="menuClient" id="profileClient">' +
        '<h1 class="menuClientHeading">Profile</h1>' +
        '<div id="profileClientPluginList">' +
        '<p>No profile information yet</p>' +
        '</div>' +
        '</div>',
    clientId: 'profileClient'
};

var prefsMenuItem = document.getElementById('preferences-menu-item');
var profileMenuItem = document.getElementById('profile-menu-item');
var clientArea = document.getElementById('client-area');

clientArea.innerHTML += prefsMenu.clientData;
clientArea.innerHTML += profileMenu.clientData;

prefsMenuItem.addEventListener('click', function() {
    document.getElementById(profileMenu.clientId).classList.remove('visible');
    document.getElementById(prefsMenu.clientId).classList.add('visible');

    document.getElementById('menu').className = 'menu'; // hide menu after click;
});

profileMenuItem.addEventListener('click', function() {
    document.getElementById(prefsMenu.clientId).classList.remove('visible');
    document.getElementById(profileMenu.clientId).classList.add('visible');
    
    document.getElementById('menu').className = 'menu'; // hide menu after click;
});
