# X01 — Borrow-scoped ResolveRef, race-free memory access contract

**Status: DESIGN CANDIDATE / NOT IMPLEMENTED / NOT NATIVE-TESTED.** This closes the *specification gap*, not the actual security gate. Supplements [IAI-v1](aui-compiler-internal-assembly-abi.md) and [integrated sequential test](aui-compiler-x01-integrated-assembly-test.md). Existing `x01_resolve_table` is **test-only and unsafe as a production public lookup**: global leaseCount > 0 is not caller ownership.

## B1. Chosen model: lexical exclusive table lock, scoped borrow

For the initial Windows x64 compiler process, use one internal arena-table mutex with **non-reentrant** scoped operations. All reference acquisition, entry update and retirement use this mutex; lock ordering must never invert. The only supported dereference API is a *callback-scoped* `WithResolvedRef(table, ref, expectedKind, requestedBytes, alignment, callback, userContext)`, which invokes the callback with a temporary native pointer while a borrow pin remains registered. A raw pointer cannot be returned to arbitrary caller code as a durable result. No callback may store the pointer, await, call an arbitrary OS module, recursively enter the arena table, or allocate through a path that reacquires the table lock. These are runtime preconditions requiring explicit proof and conservative interfaces, not magically enforced by Assembly.

The callback receives a read-only borrow for sealed arenas. Mutable arenas require separate owner-exclusive access through the building pass and cannot be resolved by public read-borrow API. A sealed arena cannot become writable by casting its pointer.

## B2. Linearization points and state protocol

- `AcquireReadBorrow`: lock, validate table length/count; index/generation; state SEALED; descriptor kind; committed bounds using subtraction; requested alignment; live allocation and lease. Increment activeBorrowCount under the lock (checked overflow); unlock. The increment is the borrow's linearization point.
- `WithResolvedRef`: execute callback while the borrow is live; handle all return/error/unwind paths; guarantee `ReleaseReadBorrow` exactly once. The callback pointer is valid only for the lexical callback extent. Optional poison/guard checks never replace active borrow bookkeeping.
- `ReleaseReadBorrow`: lock, validate internal token and slot generation, decrement activeBorrowCount; if retire is pending and count reaches zero, wake the retire owner; unlock. User-authored integers cannot act as borrow tokens. A forged/stale/duplicate release is an internal fault, not permission to decrement another borrow.
- `Retire`: lock, set RETIRING, disallow new borrows, wait for activeBorrowCount and all distinct owner leases to reach zero (without holding the mutex while waiting); after all borrowers exit, invalidate slot generation, revoke base/committed, mark VACANT or permanently RETIRED if generation == 65535. OS decommit/free is permitted only after all pins have quiesced; no stale pointer remains in a callback.
- `Publish`: host-owned allocated memory, exact descriptor and size metadata, unique index nonzero, valid generation, no live old owner. Under lock transition BUILDING -> SEALED only after bytes and children verify. No uninitialized memory ever visible through a sealed borrow.

**The previous 32-byte `ArenaEntry` is insufficient for this protocol**: it mixes lifetime leaseCount with active borrowers and lacks RETIRING state, lock-protected metadata, allocation ownership and bounded table byte length. Do **not** pretend the old offsets remain an accepted secure arena ABI. Keep it solely for legacy sequential probes. A proposed production descriptor layout requires separate review/probes; do not silently change IAI-v1 Ref64 packing.

## B3. Native ABI boundaries

The proposed callback entry is deliberately **not yet assigned a machine-level struct**, because callback register ABI, failure unwind, nonreentrancy and locking must be frozen together. Define a `BorrowRequestV1` with immutable Ref64, expected descriptor class, byte size, alignment, and bounded callback identity; define `BorrowReplyV1` with status only, not a raw pointer. All handles remain private. Win64 assembler must preserve stack alignment, shadow space and nonvolatile regs across host callback. Avoid arbitrary function pointers sourced from untrusted JSON or IR.

## B4. Mandatory negative tests (all NOT-RUN)

| ID | Race or fault | Required result |
| --- | --- | --- |
| BR01 | reader holds borrow; retire starts | retire waits; data stays allocated until callback returns |
| BR02 | retire marks RETIRING; new reader starts | new acquire rejects |
| BR03 | reader releases; retire completes; old Ref64 reused | generation mismatch rejects |
| BR04 | two readers simultaneously access sealed bytes | both safe, retire waits for both |
| BR05 | duplicate release or forged token | internal fault; counts unmodified |
| BR06 | callback errors/unwinds | pin released exactly once |
| BR07 | callback recursively invokes arena allocation | reject with defined nonreentrant error |
| BR08 | requestedBytes crosses boundary | reject without pointer exposure |
| BR09 | wrong descriptor class with valid Ref64 | reject |
| BR10 | table count exceeds pinned table byte length | reject before indexing |
| BR11 | generation wrap at 65535 | permanently retire index |
| BR12 | publish unverified mutable memory as sealed | reject |
| BR13 | allocation/free failure | preserve old sealed state; no dangling published Ref64 |
| BR14 | OS scheduler preempts between borrow and use | pointer remains pinned |
| BR15 | callback retains pointer after return | prohibited; must be tested with debug poison/guard and API restriction |
| BR16 | cancellation during acquire/retire | deterministic cleanup; no deadlock |

## B5. Acceptance boundary

Complete production implementation needs OS synchronization, allocation ownership, callback ABI, descriptor-kind verifier, linearization-point stress tests, real Win64 executions and memory safety/guard pages. Prior sequential 5/5 or 12 assertions do not satisfy BR01–BR16. Keep X01 OPEN; T0–T8 and D1–D8 OPEN. No Python, Qt or CI additions.
