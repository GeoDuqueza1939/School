// assign a variable for the client area
var clientArea = document.getElementById('client-area');

reloadPlugins();

// add plugins to the Menu
taskPlugin.isSelected = true;
createMenuEntries();

// add plugins to the Plugin Manager clientArea
refreshPluginList()

// FUNCTIONS
function reloadPlugins()
{
    for (var x = 0; x < plugins.length; x++)
    {
        if (plugins[x].isEnabled)
        {
            loadedPlugins.push(plugins[x]);
        }
    }

    // reset content if plugins are found and loaded
    if (loadedPlugins.length > 0)
    {
        //clientArea.innerHTML = '';

        var clientDivs = clientArea.children;

        for (var x = 0; x < clientDivs.length; x++)
        {
            if (clientDivs[x] != prefsClient && clientDivs[x] != profileClient)
            {
                clientArea.removeChild(clientDivs[x]);
            }
        }

        // add plugin client content to clientArea
        for (var x = 0; x < loadedPlugins.length; x++)
        {
            clientArea.innerHTML += loadedPlugins[x].clientData;
        }
    }
    else
    {
        clientArea.innerHTML = '<p id="not-found">Sorry, plugins with client content are not found.</p>';
    }
}

function createMenuEntries()
{
    var menuItems = document.getElementById('menu-items');
    menuItems.innerHTML = '';

    //for (var x = 0; x < loadedPlugins.length; x++)
    for (var x = 0; x < plugins.length; x++)
    {
        var plugin = plugins[x];
        if (plugin.isEnabled && plugin.hasMenuEntry)
        {
            createMenuEntry(plugin, x);
        }
    }
}

function createMenuEntry(plugin, pluginIndex)
{
    var menuItems = document.getElementById('menu-items');

    var item = document.createElement('LI'); // create wrapperMenuItem
    item.id = plugin.id;
    item.className = 'menu-item';
    if (plugin.isSelected)
    {
        item.classList.add('selected');
        selectedPlugin = item;
    }
    item.appendChild(document.createTextNode(plugin.name));
    item.setAttribute('data-pluginIndex', pluginIndex);
    menuItems.appendChild(item);
    if (plugin.isSelected)
    {
        document.getElementById(plugin.clientId).classList.add('visible');
    }

    // add events
    item.addEventListener('mousedown', function(event) {
        menuItemHold(getEventTarget(event));
    });

    item.addEventListener('mousemove', function(event) {
        menuItemRelease(getEventTarget(event));
    });

    item.addEventListener('mouseleave', function(event) {
        menuItemRelease(getEventTarget(event));
    });

    item.addEventListener('mouseup', function(event) {
        menuItemRelease(getEventTarget(event));
    });

    item.addEventListener('click', function(event) {
        menuItemClick(getEventTarget(event));
    });
    
    // assign item as wrapper
    plugin.wrapperMenuItem = item;
}

function menuItemRelease(target)
{
    if (target.classList.contains('held'))
    {
        target.classList.remove('held');
    }
}

function menuItemHold(target)
{
    if (!target.classList.contains('held'))
    {
        target.className += ' held';
    }
}

function menuItemClick(target)
{
    if (target.className == 'menu-item')
    {
        document.getElementById(profileMenu.clientId).classList.remove('visible');
        document.getElementById(prefsMenu.clientId).classList.remove('visible');

        selectedPlugin = plugins[document.getElementsByClassName('menu-item selected')[0].getAttribute('data-pluginIndex')];
        selectedPlugin.isSelected = false;
        document.getElementsByClassName('menu-item selected')[0].classList.remove('selected');
        document.getElementsByClassName('pluginClient visible')[0].classList.remove('visible');

        selectedPlugin = plugins[target.getAttribute('data-pluginIndex')];
        selectedPlugin.isSelected = true; // update plugin property
        selectedPlugin.wrapperMenuItem.classList.add('selected'); // show menu entry as selected
        document.getElementById(selectedPlugin.clientId).classList.add('visible'); // show client data

        if (selectedPlugin.id = 'tasksPlugin')
        {
            refreshTaskList();
        }
    }

    document.getElementById('menu').className = 'menu'; // hide menu after click;
}

function refreshPluginList()
{
    var plugManClientPluginList = document.getElementById('plugManClientPluginList');
    if (plugins.length > 0)
    {
        plugManClientPluginList.innerHTML = '<p>Select plugins to load them:</p>';
    }
    else
    {
        plugManClientPluginList.innerHTML = '<p>No plugins found</p>';
    }

    var plugManForm = document.createElement('FORM');
    plugManClientPluginList.appendChild(plugManForm);
    
    for (var x = 0; x < plugins.length; x++)
    {
        var plugin = plugins[x];
        
        var item = document.createElement('INPUT'); // create a checkbox for the plugin
        item.id = 'plugman-' + plugin.id;
        item.setAttribute('name', item.id);
        item.type = 'checkbox';
        item.checked = plugin.isEnabled;
        item.setAttribute('data-pluginIndex', x);

        var itemLabel = document.createElement('LABEL'); // also add a label to the checkbox
        itemLabel.setAttribute('for', item.id);
        itemLabel.appendChild(document.createTextNode(plugin.name));

        // add event
        item.addEventListener('change', function(event) {
            pluginCheckChange(event);
        });

        // add checkbox as wrapper for toggling
        plugin.wrapperPlugManItem = item;

        // disable checkbox if entry is for plugin manager
        if (plugin.id == 'plugManPlugin')
        {
            item.disabled = true;
            itemLabel.disabled = true;
        }

        // add the checkbox and the label to the form
        plugManForm.appendChild(item)
        plugManForm.appendChild(spaceNode());
        plugManForm.appendChild(itemLabel);
        plugManForm.appendChild(breakNode());
    }
}

function pluginCheckChange(event)
{
    var plugCheckBox = getEventTarget(event);
    var pluginIndex = plugCheckBox.getAttribute('data-pluginIndex');
    var plugin = plugins[pluginIndex];

    plugin.isEnabled = plugCheckBox.checked; // update plugin object property from checkbox state

    reloadPlugins();
    refreshPluginList();
    createMenuEntries();
}

function getEventTarget(event)
{
    return event.target || event.srcElement;
}

// Cross-browser class name manipulation
function removeClassName(element, className)
{
    element.className = element.className.replace(new RegExp('\\b' + className + '\\b'), ' ').replace(new RegExp('\\s\\s+'), ' ').trim();
}

function addClassName(element, className)
{
    // only add className if it still does not exist
    if (!containsClassName(element, className))
    {
        element.classList += ' ' + className;
    }
}

function containsClassName(element, className)
{
    return element.className.match(new RegExp('\\b' + className + '\\b'));
}
