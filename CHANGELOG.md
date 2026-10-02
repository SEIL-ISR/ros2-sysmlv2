# Changelog

## Unreleased

- Add `StringMessage` for `std_msgs/msg/String` and `TFMessage` for
  `tf2_msgs/msg/TFMessage`.
- Array fields declare their ordering. Arrays of primitive values, such as
  `LaserScan.ranges`, are `ordered nonunique`, so a list may repeat a value.
  Arrays of structured messages, such as `Path.poses`, are `ordered`.
- `ParameterDescriptor.floatingPointRange` and `integerRange` are optional
  (`[0..1]`), as in `rcl_interfaces/msg/ParameterDescriptor`.
- `LifecycleStates` follows the `rcl` default state machine: the four primary
  states, the six transition states, and 25 transitions. Seven are requested
  by events. Eighteen leave a transition state on the result of its callback,
  the new `TransitionCallbackReturn` (`Success`, `Failure`, `Error`). The six
  callback action definitions gain an `out` attribute `result`.
- Changes that affect models written against 0.1.1: the callbacks are entry
  actions of the transition states (`configuring`, `activating`, and so on)
  instead of the primary states; `ErrorEvent` is removed; the exits of
  `errorProcessing` are named `onErrorSuccess`, `onErrorFailure`, and
  `onErrorError` (before: `errorRecoverySuccess`, `errorRecoveryFailure`).
- Nav2 fields follow the Jazzy `nav2_msgs` sources. `SmoothPathResult` gains
  `errorMsg`. The new `CostmapMetaData` carries all seven fields of
  `nav2_msgs/msg/CostmapMetaData`, and `Costmap` carries it as
  `costmapMetadata`, since the ROS2 field name `metadata` is a reserved
  keyword.
- `QoSCompatible` carries its rule: false for a best-effort publisher with a
  reliable subscriber and for a volatile publisher with a transient-local
  subscriber, true for every other pair, including policies that defer to the
  middleware (system default, unknown, best available). Deadline and
  liveliness are not compared.
- The README gives the field naming rule with every renamed field, and which
  parts (goal, result, feedback) of the seven Nav2 actions are modeled.
- Breaking changes for models written against 0.1.1: `WaitGoal.waitTime` is
  renamed `time`, the name of the Jazzy field. `Costmap.metadataResolution`,
  `metadataWidth`, and `metadataHeight` are removed; their values are
  `costmapMetadata.resolution`, `costmapMetadata.sizeX`, and
  `costmapMetadata.sizeY`. A usage of `QoSCompatible` now has a value, so a
  publisher and subscriber pair that the rule calls incompatible evaluates to
  false.

## 0.1.1 (2026-09-03)

- README only: definition counts taken from the model (182), a Nav2 stack-coverage section, the local archive name as `sysand build` writes it, the series note reworded, and a logo that collapses cleanly where the index page blocks external images.
- No change to the library sources.

## 0.1.0 (2026-09-03)

First public release, alpha quality: the vocabulary is complete and validated, and its shape may still change before 1.0.


- First public release of the ROS2 domain library for SysML v2, 17 source files under `ros2_sysmlv2/`.
- Foundation and standard message layers: time and header primitives plus the std, geometry, sensor, nav, trajectory, diagnostic, shape, action, and visualization message packages, each typed as `item def` against the ROS2 Jazzy interface sources.
- Communication layer: QoS profiles and the publisher, subscriber, service, and action port definitions with their matching connection definitions.
- Lifecycle, deployment, parameter, and TF2 layers: the managed-node state machine, executors and containers, parameter descriptors, and coordinate-frame transforms.
- Node archetypes and the Nav2 layer: eight abstract node patterns and the Nav2 server nodes with the composite Nav2 stack.
