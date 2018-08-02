// simulate plugin loading
var SelectedPlugin;

var menuItems = document.getElementById('menu-items');

while (menuItems.length > 0)
    menuItems.pop();

for (x in Plugins)
{
    if (Plugins[x].isInMenu && Plugins[x].isEnabled)
    {
        var item = document.createElement('LI');
        var itemText = document.createTextNode(Plugins[x].name);
        if (Plugins[x].isSelected)
            SelectedPlugin = Plugins[x];
        
        Plugins[x].wrapperElement = item;
        item.setAttribute('data-plugin', Plugins[x]);
        item.className = 'menu-item';
        if (SelectedPlugin.wrapperElement !== undefined)
            SelectedPlugin.wrapperElement.className = 'menu-item selected';
        
        item.appendChild(itemText);
        menuItems.appendChild(item);
        
        item.addEventListener('mousedown', function(event) {
            var target = event.target || event.srcElement;
            //var id = target.id
            target.className = 'menu-item held';
        });
        
        item.addEventListener('touchstart', function(event) {
            var target = event.target || event.srcElement;
            
            target.className = 'menu-item held';
        });
        
        item.addEventListener('mouseup', function(event) {holdPlugin(event);});
        item.addEventListener('mouseleave', function(event) {holdPlugin(event);});
        item.addEventListener('mouseout', function(event) {holdPlugin(event);});
        item.addEventListener('mouseover', function(event) {holdPlugin(event);});
        item.addEventListener('mousemove', function(event) {holdPlugin(event);});
        item.addEventListener('touchmove', function(event) {holdPlugin(event);});
        item.addEventListener('touchend', function(event) {holdPlugin(event);});
        item.addEventListener('touchcancel', function(event) {holdPlugin(event);});
        
        item.addEventListener('click', function(event) {
            var selected = document.getElementsByClassName('menu-item selected')[0];
            if (selected !== undefined)
                selected.className = 'menu-item';
            
            var target = event.target || event.srcElement;
            
            target.className = 'menu-item selected';
            SelectedPlugin = target.getAttributeNode('data-plugin').value;
        });
    }
}

function holdPlugin(event) {
    var selected = document.getElementsByClassName('menu-item selected')[0];
    if (selected !== undefined)
        SelectedPlugin = selected.getAttributeNode('data-plugin').value;
        
    var held = document.getElementsByClassName('menu-item held')[0];
    if (held !== undefined)
        held.className = 'menu-item';
    
    if (document.getElementsByClassName('menu-item selected').length == 0)
    {
        if (SelectedPlugin.wrapperElement !== undefined)
            SelectedPlugin.wrapperElement.className = 'menu-item selected';
        else
        {
            /*
            */
            //if (SelectedPlugin === undefined)
                var target = event.target || event.srcElement;
          
                target.className = 'menu-item selected';
                SelectedPlugin = target.getAttributeNode('data-plugin').value;
          //alert(SelectedPlugin);
        }
    }
}

