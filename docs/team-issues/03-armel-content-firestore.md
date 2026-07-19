## Summary
Own **Firestore persistence** for Community, Government programmes, and Training & Resources.

## Assignee
Armel

## Branch
`feature/armel-firestore-content`

## Tasks
- [ ] Community posts + comments (create/read at minimum)
- [ ] Government programmes list + detail data from Firestore
- [ ] Training resources / paths (seed + read OK)
- [ ] Proper data/domain layers + BLoC wiring (UI screens already exist)
- [ ] Widget tests for community feed and gov list

## Done when
Profile → Community / Government / Training all use Firestore data; widget tests pass.

## Out of scope
Auth (Tifare), Opportunities CRUD (Timothy).

## Dependencies
Use authenticated `userId` from Tifare’s Auth work for posts/comments authorship where needed.

## References
See [CONTRIBUTING.md](../../CONTRIBUTING.md).
