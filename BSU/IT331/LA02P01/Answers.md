# Flutter Key Widgets - Exploration Module
## Answers

1. __Stateless vs Stateful Widgets__
    * _What is the key difference between these two widgets?_
        The key difference between the two widgets is the changeable state. The first one is static and would only display text that wont necessarily change or respond to user interaction or system revents. On the other hand, the second widget changes the displayed counter once a user presses the Increment button.
    * _What triggers a rebuild in a Stateful widget?_
        User interaction and/or system events can trigger a rebuild in a Stateful widget.
2. __Container Widget__
    * _What does the Container widget do?_
        A Container widget can hold other widgets
    * _What happens when you change the width or color?_
       Changing the width or color properties of the Container widget also changes the Container's appearance.
3. __Scaffold + AppBar + Body + FAB__
    * _What is the purpose of the Scaffold?_
        The Scaffold provides the layout of the user interface.
    * _What do you observe about the app bar and the floating action button?_
        Both the app bar and the floating action button have no position properties but the app bar sticks to the top of the UI layout whereas the floating action button always goes to the lower right corner.
4. __Drawer Widget__
    * _How does the Drawer behave?_
        The Drawer slides out once the drawer button is pressed and slides out of the screen when the UI is touched outside the Drawer.
    * _What widgets are used inside the Drawer?_
        The widgets inside the Drawer include a ListView, a DrawerHeader, ListTiles, Texts, a TextStyle, and a BoxDecoration.
5. __Bottom Navigation Bar__
    * _What happens when you tap on the navigation items?_
        Tapping on the navigation items changes the page displayed.
    * _How could you show different content per tab?_
        You add Center widgets to the pages list to show different content per tab.
6. __MaterialApp Class__
    * _What does MaterialApp provide to the app?_
        MaterialApp provides the app's theme and structure.
    * _What happens if you remove the MaterialApp wrapper?_
        An error message appear, saying that the Scaffold widgets require a Directionality widget ancestor.
