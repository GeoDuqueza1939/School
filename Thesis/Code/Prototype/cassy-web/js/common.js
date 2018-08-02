// simulate plugin search
function Plugin(name, wrapperElement, isInMenu, isEnabled, isSelected)
{
    this.name = name;
    this.wrapperElement = wrapperElement;
    this.isEnabled = isEnabled;
    this.isInMenu = isInMenu;
    this.isSelected = isSelected;
}

var Plugins = [];

Plugins.push(new Plugin('Tasks', undefined, true, true, true));
Plugins.push(new Plugin('Class Record', undefined, true, true, false));
Plugins.push(new Plugin('Classroom Management', undefined, true, true, false));
Plugins.push(new Plugin('Administrator Plugin', undefined, false, true, false));
Plugins.push(new Plugin('Plugin Manager', undefined, true, true, false));
