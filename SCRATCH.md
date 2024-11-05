#  Scratch

A place to jot down thoughts about efforts in progress, ideas, to-do‘s, etc. 

## Instances

Add instance at login.

Add instance in preferences.

Switch between instances.
- Maintain tokens for each login.
- Re-assign client instanceURL.
- Attempt a request and show login if needed.


So... make a new Instance(Service|Repository).

Store InstanceInfo in UserDefaults.

InstanceService().list() -> [String]
`# ["https://sudonym.net", "https://fosstodon.org"]`
Maybe the return type could be something more interesting like InstanceInfo

Store tokens in Keychain, associated with domain URLs so sign-in work for browser too.
`# Keychain.set(<access-token>, key: "https://sudonym.net")` or however that works.

If not logged in:

Select an instance
Show login screen
Auth
Redirect to Timeline

If logged in:

Select an instance
Validate token

If token good:
Redirect to Timeline

If token bad:
Show login screen
Auth
Redirect to Timeline


