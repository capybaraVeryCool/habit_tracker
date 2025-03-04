# Habit Tracker App
A Flutter application for tracking daily habits

## How to set up the local environment

**Step 1:**
   ```bash
   git clone
   cd habit-tracker
   ```

**Step 2:**
   ```bash
   flutter pub get
   ```

**Step 3:**
   ```bash
   flutter run
   ```

## Features Implemented
1. User Authentication

<img src="screenshots/signin.png" alt="signin" width="200px">
<img src="screenshots/signup.png" alt="signup" width="200px">

2. Habit Tracking:
- Add a habit:
   - Name
   - Description
   - Frequency
- Delete a habit
- Mark habit as completed

<img src="screenshots/addhabit.png" alt="addhabit" width="200px">
<img src="screenshots/deletehabit.png" alt="deletehabit" width="200px">


3. Summary of each habit: 
   - Progress of habit
   - Completion rate
   - Current streak
   - Best streak
   - Total days

<img src="screenshots/habitsummary.png" alt="summary" width="200px">

4. Achievement & Gamification
Users will receive certain badges when they reach a total number of XP, streaks, level
<img src="screenshots/achievementpage.png" alt="achievement" width="200px">

5. Profile page
- View:
   - displayed name, email
   - level
   - total XP
   - number of habits
- Toggle light/dark mode

<img src="screenshots/profilepage.png" alt="profile" width="200px">

6. Home page:
- Display
   - Total habits
   - Number of habits completed today
   - Total streaks
   - List of habits

<img src="screenshots/lightmode.png" alt="light" width="200px">
<img src="screenshots/darkmode.png" alt="dark" width="200px">

## Future implementations
1. Habit analytics: 
- Summary of user's key metrics such as number of habits, completion rate, streaks, total XP weekly/monthly/yearly in the form of bar/line/pie charts
2. System notifications:    
- Daily reminders to prompt users to complete their habits.
- Customizable reminder times for each habit.
- (Future) Smart notifications that adjust based on user behavior.
3. Edit habit: allow user to edit the title and description of the habit
4. Calendar view: 
- A heatmap-style calendar to visualize habit consistency.
- Users can tap on a date to view habit logs and stats for that day.

## Challenges encountered
Since this is a recently purchased laptop, I had to install and configure the latest version of Flutter. However, certain dependencies were either deprecated or incompatible with the newest Flutter release. As a result, I had to spend a significant amount of time researching package updates and migration guides or using dependency overrides as temporary fixes.
