# Architecture-to-Hardware Vertical Slice: Sensor Telemetry

**Status:** theoretical acceptance fixture, not a functioning example. Its purpose is to cross-check the graph, AUI, runtime, ABI, component palette, security and AI workflow specifications.

## Scenario and constraints

An ARM64 target obtains measurements from a sensor attached to an I2C bus. The driver receives hardware-triggered or polled completion notifications, decodes samples, publishes a bounded stream, and presents the latest value in a declarative AUI view. AELYXORA Studio displays the **same system** as an architecture map; the AI chat can target its driver node.

Hardware parameters below are placeholders, not claims about a particular physical sensor. No real register addresses or interrupt lines are assumed.

## Canonical graph

```text
[ARM64 Target Profile]
     │ runs on
     ▼
[Telemetry Application] ──uses──> [Sensor Service]
     │                                  │
     │ presents                         │ consumes typed samples
     ▼                                  ▼
[AUI SensorPanel]  <──binding── [Measurement State]
                                        ▲
                                        │ updated by bounded channel
                               [Decode / Sample Worker]
                                        ▲
                                        │ receives completion event
                                  [Sensor Driver]
                                        ▲
                                        │ bus transfer / IRQ-capability
                               [I2C Bus] ──hosts──> [Sensor Device]
```

All nodes have stable identities; visual coordinates are not part of behavior. Device, bus and driver expose **target-specific capability contracts**. AUI binds to observable measurement state, not raw MMIO addresses.

## Component and port examples

- `sensor.driver`: target=`aarch64-unknown-linux-gnu` as an example target triple; `readSample() -> Result<RawSample, DeviceError>`; capability `i2c.transfer`; no UI effects; execution domain I/O worker.
- `sensor.decoder`: pure `decode(RawSample) -> Result<Measurement, DecodeError>`, bounded input and no device capabilities.
- `sensor.channel`: `Channel<Measurement>` capacity=32; choose explicit drop or blocking policy; no blocking inside IRQ context.
- `sensor.state`: observable `Measurement` with last-good value, timestamp provenance and status; single-writer worker command.
- `sensor.view`: AUI component with typed `input reading: Measurement`; one-way binding only. User actions dispatch typed commands rather than touching device registers.
- `studio.ai`: user selects `sensor.driver`; disclosure covers only its contract, dependent ports, approved files and target/ABI profile.

## Event and task timeline

1. I2C operation completes; platform adapter emits an event with origin and ordering metadata.
2. IRQ-safe handler records minimal completion data and schedules a worker; never performs UI rendering or unbounded allocation in interrupt context.
3. Worker obtains raw bytes under an explicit buffer lifetime/ownership contract.
4. Decoder validates width, endianness and protocol checksum; error becomes a typed result.
5. Successful measurement enters the bounded channel; overflow policy records lost count if applicable.
6. A consumer task commits a new observable state revision.
7. Binding reevaluates affected derived/UI properties; AUI reconciles the view and schedules a frame.
8. Studio architecture map can show *recorded evidence* for the path, but cannot claim to be observing physical hardware unless a running trace adapter supplies such data.

## AI task example

User selects `sensor.driver` and asks: "Implement the I2C driver for this ARM64 target, respecting buffer ownership and error contracts." Studio displays a context manifest; AI proposes Assembly source and tests; the diff is reviewed against graph nodes and locked contracts; no device operation or project write occurs before approval. Native build and mock bus tests follow locally. On-device testing requires a distinct operator authorization.

## Negative cases

| Input/failure | Required behavior |
| --- | --- |
| Device requires unavailable I2C capability | Target validation error; no read |
| Driver ABI differs from target | Reject before linking or report precise link error |
| Two workers write single-writer measurement state | Graph validation error |
| Sensor sample queue reaches capacity | Enforce declared policy; no unbounded growth |
| Late completion refers to discarded view instance | Ignore/reject by generation identity |
| AI patch modifies unselected hardware contract | Request separate explicit approval |
| Missing approved access to physical device | Simulator/mock only; never attempt hardware write |
| Unverified target result | Status `not run`, not `passed` |

## Definition of design completion

A single fixture must contain stable graph IDs and target metadata; AUI view with typed state and accessibility attributes; driver ABI and ownership contract; event/worker/channel/binding semantics; source/graph diff schema; and exact expected diagnostics for invalid fixtures. A runnable demonstration is a later, separate gate.

## Open decisions

Specific physical board/device, error-code ABI, concurrency implementation, serialization format, text localization and UI renderer backend.
