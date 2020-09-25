# Some Questions and Answers

## Q1: Change Drawer Icon  

The drawer has default three horizontal bars as default icon. To change it, use *leading* property of *AppBar*.  

```dart
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.accessible),
          onPressed: () => Scaffold.of(context).openDrawer(),   // will open the Widget defined in property 'drawer'
        ),
      ),
      drawer: MyDrawer(),
);
```

## Q2: Detect behaviors on any Widgets  

see *GestureDetector* class. Use *Padding* to constrain child's size.  

## Q3: Limit the number of lines and add ellipsis

```dart
Text(
    'text',
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
),
```

## Q3: Create Transparent Appbar & "Floating" TextField 

The goal is to create a "floating" textfield at the center position of appbar.

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/09/24/0SKloq.jpg" width="300px">
</div>

The steps are as follows:  

- Add a TextField Widget to *AppBar*'s *title* property
- Make a translucent appbar and let the body Widget can go behind the appbar and be visible
- Style the TextField  

### 1. Add a TextField Widget to *AppBar*'s *title* property

```dart
import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyCustomTextField(),  //add custom textfield
      ),
      body: Container(height: 500.0, color: Colors.purple),
    );
  }
}

// definition of custom textfield
class MyCustomTextField extends StatefulWidget {
  @override
  _MyCustomTextFieldState createState() => _MyCustomTextFieldState();
}

class _MyCustomTextFieldState extends State<MyCustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(),
            labelText: 'Search',
        )
      );
  }
}
```

`MyCustomTextField` needs to be a stateful widget since we will manage its focus state later.  

The page now looks like:

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/09/24/0S0W24.jpg" width="300px">
</div>

*Why use enabledBorder instead of border?*  

> see how [Flutter API](https://api.flutter.dev/flutter/material/InputDecoration/border.html) indicates  
>
> If custom BorderSide values are desired for a given state, all four borders – errorBorder, focusedBorder, enabledBorder, disabledBorder – must be set.  

I have tried to set border property at first but found it didn't work.  

I suppose the question to be that `enabledBorder` has a higher priority to display than `border` does -- even I have set `border`, it will use default `enabledBorder`. (Wrong? Help me to correct it!)


### 2. Make a translucent appbar and let the body Widget can go behind the appbar and be visible  

My reference:   
[Fullscreen page with transparent AppBar in Flutter](https://mrflutter.com/fullscreen-page-with-transparent-appbar-in-flutter/)  

You may notice that the appbar seems to have a solid white background. We only want the textfield to be visible -- the surroudings should be transparent.  

We set backgroundcolor of AppBar to `Colors.transparent`.

[How to display body under the AppBar of scaffold widget and not below?](https://stackoverflow.com/questions/50032231/how-to-display-body-under-the-appbar-of-scaffold-widget-and-not-below)

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // add this line
      appBar: AppBar(
        backgroundColor: Colors.transparent,    // add this line
        title: MyCustomTextField(),
      ),
      body: Container(height: 500.0, color: Colors.purple),
    );
  }
```

Now the AppBar looks as:

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/09/24/0S8Dkd.jpg" width="300px">
</div>

Why is there a grey color background? This is because that AppBar has a none-zero elevation, this grey block is its shadow. Thus, we set `elevation` to 0.0.

```dart
appBar: AppBar(
        elevation: 0.0, // add this line
        backgroundColor: Colors.transparent,
        title: MyCustomTextField(),
      ),
```

The shadow was removed!  

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/09/24/0SDuXd.jpg" width="300px">
</div>

### Style the TextField  

Now we can decoration our textfield. The textfield is supposed to be rounded, white border, white backgroundcolor.

```dart
appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Container(
          // height: AppBar().preferredSize.height * 0.8,
          child: Material(
            // elevation: 5,
            borderRadius: BorderRadius.all(Radius.circular(100.0)),
            color: Colors.transparent,
            child: MyCustomTextField(),
          ),
        ),
      ),
```


```dart
@override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
            fillColor: Colors.white,    // change from here ...
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide(
                    color: Colors.white,
                ),
            ),  // to here
        labelText: 'Search',
        )
      );
  }
```

> `fillColor`: The base fill color of the decoration's container color. The decoration's container is the area which is filled if filled is true and bordered per the border.
>
> Thus, property `filled` has to be true. Otherwise, the decoration's container color will not be assigned white.

Additional: [How to Add Drop Shadow to TextFormField In Flutter
](https://stackoverflow.com/questions/54194347/how-to-add-drop-shadow-to-textformfield-in-flutter)

Done!

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/09/24/0SsVQe.jpg" width="300px">
</div>

Want to modify textfield's height? Put `TextField` in a *Container* (as the comment), use `height` property to modify it!  

## Q4: Create a Search Bar Using *ShowSearch()*  

To let it navigate to a new screen with a focused textfield(flutter default search textfield) after we click and try to focus the textfield created in Q3. 

My reference:   
[Focus and text fields](https://flutter.dev/docs/cookbook/forms/focus)  
[Flutter's Search Support (The Boring Flutter Development Show, Ep. 10)](https://www.youtube.com/watch?v=Wm3OiFBZ2xI)

- Create a FocusNode.
- Pass the FocusNode to a TextField.
- Unfocus the TextField when it is tapped and *showSearch()*
- Define *SearchDelegate*

```dart
class MyCustomTextField extends StatefulWidget {
  @override
  _MyCustomTextFieldState createState() => _MyCustomTextFieldState();
}

class _MyCustomTextFieldState extends State<MyCustomTextField> {
  // add from here ...
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }
  // to here

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: myFocusNode,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        labelText: 'Search',
      ),
      
      //add from here ...
      onTap: () {
        showSearch(
          context: context,
          delegate: RecipeSearch(),
        );
        myFocusNode
            .unfocus(); // let this textfield always be the unfocus state -- border unchanged
      },  // to here
    );
  }
}

// add this class
class RecipeSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [    // actions(shown on the right side)
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',    // when click, clear the text in the textfield
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(  // leading in the search bar
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(); // the Widget show below the search bar
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text(query); // the Widget show below the search bar when textfield is changed
  }
}

```
