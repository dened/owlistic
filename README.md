# Telc Certificate Checker Service

The Telc Certificate Checker Service checks the status of Telc certificates using their public API. Users can submit their certificate details, and the service will automatically check for the certificate status. It notifies users of the results via a Telegram bot. The service supports both automatic periodic checks and manual checks initiated by the user.

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
- [ ] Delete messages
- [ ] Implement `/add_user`, `/show`, `/remove_user` commands
- [ ] Implement `/check_now` command to trigger checks

### Iteration 4: Scheduled Checks
- [ ] Implement scheduler (check users Monday to Friday, 8 AM - 6 PM)
- [ ] Notify users via Telegram on check results

### Iteration 5: Manual Check Request
- [ ] Implement `/check_now` for manual certificate check
- [ ] Notify users of manual check results

### Iteration 6: Database Integration
- [ ] Set up database (via drift)
- [ ] Store and retrieve user data from the database
