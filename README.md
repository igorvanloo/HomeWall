# HomeWall

## Table of Content
1. [About Homewall](#about)
2. [Progress](#progress)
    1. [Road Map](#road-map-of-progress)
    2. [Future Updates](#future-updates)


## About Homewall <a name="about"></a>

An app **(in development)** to create your own routes on any wall that you can take a picture of!

I wanted to make this app for the following reasons:
1. I wanted to learn about app development and how to code in Dart and use Flutter
2. The most popular app on the climbing market [Stōkt](https://www.getstokt.com/) has caused me frustration in the past, and it is not free for gyms to use.

## Progress <a name="progress"></a>

### Road Map of Progress

- [ ] Create Login Pages
    - [x] User inferface for Login page
        - [x] Make UI for *Sign In* page
        - [x] Make UI for *Sign Up* page
        - [x] Make UI for *Forgot Password* page
    - [x] Set up FireBase connection
    - [ ] Third Party Login options
        - [ ] Facebook login
        - [ ] Google login
- [ ] Create App Pages
    - [ ] Create *Home* page
        - [x] Create Sign out button
        - [ ] Make UI for Homepage
    - [x] Create *Walls* page
        - [x] Make UI for *Walls* page
        - [x] Create *Add Wall* button
            - [x] Add name for new wall
            - [x] Add Image for new wall
                - [x] Select Image to be uploaded
                - [x] Upload Image to FireBase Storage 
                - [x] Add Wall name and download url to FireBase FireStore Database
        - [x] Display new walls with name and image
    - [ ] Create *routes* page for each wall added
        - [x] Make UI for *routes* page
        - [ ] Create *Add Route* button
            - [x] Add name for route
            - [x] Add grade for route
            - [ ] Create your own route
                - [x] Display correct wall to edit
                - [ ] Add editing option to draw ontop of wal
            - [x] Add route name, downloard url, route grade, sent/un-sent to FireBase FireStore Database
        - [x] Display new routes with name, grade, and if it is sent or not
        - [x] Make route clickable to view route
            - [x] Display correct route image 
            - [x] Add option to update route grade
            - [x] Add button to declare route as sent 

### Future Updates

Instead of having user create routes in app I want to use a REST API to call a python file which performs a holddetector see [HoldDetector.py](https://github.com/igorvanloo/HomeWall/blob/main/python/HoldDetector.py). I have already made a fairly accurate Hold Detector using OpenCV.