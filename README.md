# ToDoList

A basic to-do items tracking application written in Swift

### Features:

- Multiple categories with individual to-do lists.
- Each list can have multiple to-do entries.
- A to-do entry can be marked as open or closed.
- Open and Closed items are visually separated within a to-do list
- Each entry can have a optional notes.
- Each entry (Category and to-do items) can be swiped to delete. 

### Project Structure:

App uses the MVVM architechture. There are two main components Title and List. 
The overall folder structure is as follows:

```text
ToDoList
├── Title
|   |   # Landing Page that displays all the List titles and can be
|   |   # clicked to navigate to individual list 
│   ├── TitlesViewController.swift      
│   ├── Models
│   ├── ViewModels
│   └── Views
├── List
|   |   # Contains all items under the selected title category with
|   |   # separate sections for open and closed items
│   ├── ListViewController.swift
│   ├── Models
│   ├── ViewModels
│   └── Views
│       ├── DetailedItemViewCell  # editable items cell in table view
│       └── ItemTableViewCell     # non-editable item cell in table view listing
└── Extensions
    ├── Color.swift               # Color sets for Dark and light mode support
    └── View.swift                # For shadows  

```

### Future Work:

- Data persistence integration to Realm
- Theme update for closed items in the to-do list 
- Drag and drop delegate integration 
- Select all and Edit all feature 
