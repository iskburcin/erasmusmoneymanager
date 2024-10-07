# Erasmus Student Money Management App

### Aim of the App:
The app helps Erasmus students manage their finances in multiple currencies. It provides a way for students to input their balances, track income and expenses, and convert everything into a base currency using real-time exchange rates. This gives students an accurate overview of their spendable money, helping them manage their budget effectively during their Erasmus period.

### How It Helps:
The app simplifies the process of managing finances for Erasmus students. By allowing them to track expenses and income across multiple currencies, they can avoid currency confusion and plan their budgets better. It helps them focus on their studies and experiences instead of worrying about fluctuating exchange rates and budgeting issues.

### Target Audience:
The app is primarily for Erasmus students but can also be used by any international students or people managing money across multiple currencies.

### Features:
- **Firebase Integration**: Users are registered, and their data is stored in Firebase, including balances, transactions, and profiles.
- **Real-Time Exchange Rates**: The app fetches and updates exchange rates every 1 hour and 10 minutes, ensuring that the user sees accurate conversion data.
- **Multi-Currency Support**: Users can manage balances and transactions in EUR, TRY, and PLN, and switch between these currencies for their calculations.
- **Transaction Management**: Users can add income and expenses, choose categories, and track everything in their account history.
- **Modern UI**: The app features a clean, modern black theme, making it visually appealing and user-friendly.

### Future Improvements:
- **More Efficient API Requests**: Currently, 3 requests are sent to the API. In the future, this will be handled with 1 request, allowing more frequent updates with better accuracy.
- **Transaction Page Optimization**: On the Transaction page, past transactions are re-rendered due to state changes when adding new ones. Optimizing this will reduce unnecessary reloads and improve performance.
- **Customizable Currencies**: In the future, users will be able to track as many currencies as they need, expanding beyond the current 3 fixed currencies.
- **Improved Budget Overview**: Instead of showing daily, weekly, and monthly spendable amounts for only the selected currency, the app will automatically show them for all currencies under relevant headings, reducing user effort.

### To Do:
- Optimize API requests to reduce them from 3 to 1 for more frequent updates.
- Fix the re-render issue on the Transaction page to improve performance.
- Expand currency support so users can track multiple currencies of their choosing.
- Update the homepage to show daily, weekly, and monthly spendable amounts for all currencies under appropriate headings.
