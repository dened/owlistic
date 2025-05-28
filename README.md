# Owlistic

The Owlistic checks the status of Telc certificates using their public API. Users can submit their certificate details, and the service will automatically check for the certificate status. It notifies users of the results via a Telegram bot. The service supports both automatic periodic checks and manual checks initiated by the user.

---

### Iteration 1: Minimal Functionality
- [x] Set up Telc API request to check certificate status
- [x] Hardcode user data (`nummer`, `birthDate`, `checkDate`)
- [x] Print results (HTTP 200/404)

### Iteration 2: Storing User Data (File Storage)
- [x] Store user data in a `data.json` file
- [x] Implement reading user data from the file

### Iteration 3: Telegram Bot Integration
- [x] Set up Telegram bot
- [x] Message sending
- [x] Delete messages
- [x] Implement a class for processing simple and compound commands in Telegram

### Iteration 4: Scheduled Checks
- [x] Notify users via Telegram on check results

### Iteration 5: Manual Check Request
- [x] Implement `/check_now` for manual certificate check
- [x] Notify users of manual check results

### Iteration 6: Database Integration
- [x] Set up database (via drift)
- [x] Store and retrieve user data from the database
### Iteration 7: Localization
- [ ] Add support for multiple languages in user notifications
- [ ] Implement language selection for users

### Iteration 8: GDPR / DSGVO Compliance
- [ ] Ensure user data is stored securely and encrypted
- [ ] Add functionality to delete user data upon request
- [ ] Update privacy policy to reflect GDPR / DSGVO compliance