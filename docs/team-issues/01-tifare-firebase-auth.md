## Summary
Own **Firebase Authentication** with two methods and replace the local auth mock.

## Assignee
Tifare

## Branch
`feature/tifare-firebase-auth`

## Tasks
- [ ] Set up FlutterFire / Firebase project for Android, iOS, Web as needed
- [ ] Email/password register + login against Firebase Auth
- [ ] Google Sign-In as second auth method
- [ ] Forgot-password flow
- [ ] Secure logout + session restore on app start
- [ ] Replace `AuthLocalDataSource` mock usage with Firebase-backed repository
- [ ] Auth unit tests

## Done when
Create account, email login, Google login, and logout all work against Firebase; session restores correctly; auth tests pass.

## Out of scope
Opportunities CRUD (Timothy), Community/Gov/Training Firestore (Armel).

## References
See [CONTRIBUTING.md](../../CONTRIBUTING.md).
