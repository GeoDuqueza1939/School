var menuButton = document.getElementById('menu-button');
var menu = document.getElementById('menu');
menuButton.addEventListener('click', function() {
    if (menu.className == 'menu')
    {
        menu.className = 'menu-expanded';
    }
    else
    {
        menu.className = 'menu';
    }
});
