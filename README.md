StudBudz
A Study Buddy App

StudBudz is a study buddy app designed to help students collaborate and stay organized. The app includes various pages for managing tasks, tracking progress, and interacting with other users.

# Features
- ✅ Create and join study groupsZ
- ✅ Task management and progress tracking
- ✅ Real-time collaboration with other users
- ✅ Personalized study recommendations

#  Setup
1. Clone the Repo
```bash
git clone https://github.com/studbudz/studbudz.git
cd studbudz
flutter pub get
```

2. Get Your IP Address
```bash
Windows: ipconfig → Look for IPv4 Address
macOS: ifconfig → Look for inet under en0
Linux: hostname -I
```
3. Update Config
Edit config.dart with your IP:
```
const String apiUrl = 'http://192.168.X.X:8080'; // Replace with your IP
```
4. Run the App
    1. Create 2 terminals
    2. cd server -> dart run
    3. cd studbudz -> flutter run

flutter run
✅ Troubleshooting

Ensure device and server are on the same network.
Check firewall settings for port 8080.
