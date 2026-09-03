# Changelog

## 0.1.0 (2026-09-03)

First public release, alpha quality: the vocabulary is complete and validated, and its shape may still change before 1.0.


- First public release of the ROS2 domain library for SysML v2, 17 source files under `ros2_sysmlv2/`.
- Foundation and standard message layers: time and header primitives plus the std, geometry, sensor, nav, trajectory, diagnostic, shape, action, and visualization message packages, each typed as `item def` against the ROS2 Jazzy interface sources.
- Communication layer: QoS profiles and the publisher, subscriber, service, and action port definitions with their matching connection definitions.
- Lifecycle, deployment, parameter, and TF2 layers: the managed-node state machine, executors and containers, parameter descriptors, and coordinate-frame transforms.
- Node archetypes and the Nav2 layer: eight abstract node patterns and the Nav2 server nodes with the composite Nav2 stack.
