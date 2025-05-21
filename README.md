# FitFormula

## Project Overview

FitFormula is an iOS app designed to help users easily calculate and track various fitness-related metrics. With its user-friendly interface, FitFormula serves as a convenient tool for individuals aiming to maintain a healthy lifestyle by providing accurate calculations and tracking capabilities for their fitness journey.

## Features

- **Calculators:** FitFormula offers a suite of calculators to help users manage their health and fitness:
    - **Calories Calculator:** Estimates daily calorie needs based on factors like age, sex, weight, height, and activity level.
    - **Macros Calculator:** Calculates the optimal macronutrient (protein, carbs, fat) breakdown based on calorie goals and dietary preferences.
    - **Water Intake Calculator:** Recommends daily water intake based on individual factors to ensure proper hydration.
    - **BMI Calculator:** Computes Body Mass Index to help users understand their weight status.
- **Calculation History:** The app keeps a record of all past calculations. Users can easily access and review their previous entries, making it simple to track their journey over time.
- **Statistics View:** Users can visualize their progress and trends for each calculated metric. This feature includes filters to view data by different time ranges (Week, Month, All Time), providing valuable insights into their health and fitness patterns.

## Technologies Used

- **Swift:** The primary programming language used for developing FitFormula, providing robust performance and modern features for iOS app development.
- **SwiftUI:** The framework used for crafting the user interface of FitFormula. SwiftUI allows for a declarative and intuitive way to build responsive and engaging UIs across Apple platforms.
- **SwiftData:** Employed for data persistence within the app. SwiftData enables efficient storage and management of user data, such as calculation history, ensuring a seamless and reliable user experience.

## Project Structure

The FitFormula project is organized as follows:

- **`FitFormula/Models`:** This directory contains the data models for the application. These models define the structure and behavior of the data used within FitFormula, such as `BMICalculatorModel.swift` for BMI calculations and `CalculationHistory.swift` for storing past calculation records.
- **`FitFormula/Views`:** This directory houses the SwiftUI views that make up the user interface of the app. It is further divided into:
    - **`Calculators`:** Contains views specific to each calculator (e.g., Calories, Macros, Water Intake, BMI).
    - **`Statistics`:** Contains views related to displaying user statistics and progress.
- **`FitFormula/Assets.xcassets`:** This is where all the app's assets are stored, including app icons, images used throughout the UI, and custom color definitions.

### Key Files:

- **`FitFormulaApp.swift`:** The main entry point of the application. It sets up the initial app environment and launches the user interface.
- **`MainTabView.swift`:** Manages the primary tab-based navigation for the app, allowing users to switch between different sections like Calculators and Statistics.
- **`FitnessCalculatorView.swift`:** Displays the various calculator options available to the user and provides access to the calculation history.
- **`StatisticsView.swift`:** Responsible for presenting historical data and charts, enabling users to visualize their fitness trends over time.

## Screenshots

(Please add screenshots of the main app views here to showcase the UI. For example: Calculator selection screen, individual calculator views, history view, statistics view with charts.)

## How to Build/Run

To build and run FitFormula on your local machine, you will need Xcode.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/FitFormula.git
    cd FitFormula
    ```
    (Replace `https://github.com/your-username/FitFormula.git` with the actual repository URL if different.)

2.  **Open the project in Xcode:**
    Locate the `FitFormula.xcodeproj` file in the cloned repository and double-click it to open in Xcode.

3.  **Select a target:**
    In Xcode, choose an iOS simulator (e.g., "iPhone 15 Pro") or connect a physical iOS device.

4.  **Run the app:**
    Click the "Run" button (the play icon) in the Xcode toolbar, or select Product > Run from the menu. Xcode will build the app and install it on the selected simulator or device.

## Future Enhancements

Here are some potential ideas for future development of FitFormula:

-   **Additional Calculators:** Introduce more specialized calculators, such as:
    -   Body Fat Percentage Calculator
    -   Ideal Weight Calculator
    -   One-Rep Max (1RM) Calculator for strength training
-   **Customizable Themes:** Allow users to personalize the app's appearance with different themes or color schemes.
-   **Apple HealthKit Integration:** Sync relevant data (e.g., weight, BMI, calorie intake) seamlessly with Apple HealthKit, providing users with a centralized view of their health information.
-   **Goal Setting and Progress Tracking:** Implement features that allow users to set specific fitness goals (e.g., target weight, daily calorie intake) and track their progress towards these goals over time.
-   **User Accounts and Cloud Sync:** Introduce optional user accounts to enable cloud synchronization of calculation history and settings across multiple devices. This would also provide a backup for user data.
-   **Workout Tracking:** Basic logging of workouts or physical activities.
-   **Recipe/Food Database Integration:** Connect with a food database to allow users to easily look up nutritional information for meals.
-   **Educational Content:** Provide tips, articles, or links to resources related to fitness and nutrition.
