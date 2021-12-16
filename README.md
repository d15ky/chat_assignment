# ChatAssignment

## Workplan

1. Add user authentication system via phx.gen.auth
- Modify to add username (model, view, controller, changeset)
- Modify to prevent logging in before email is confirmed
- Modify to allow logging in by email or username
- Optionally add ability to change username

2. Add chat liveview
- Add message model (with relation to user)
- Create live chat window and submit field
- Get messages from DB to show in chat window
- Use PubSub to receive, save, and display new messages

3. Add Presence module to show active users
