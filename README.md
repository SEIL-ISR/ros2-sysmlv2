<p align="center">
  <img src="https://raw.githubusercontent.com/SEIL-ISR/ros2-sysmlv2/main/assets/ros2-sysmlv2-logo.svg" alt="" width="720">
</p>

# ros2-sysmlv2

The first SysML v2 domain library for ROS2 robotics system architectures.

**182 definitions** across **17 source files** covering message types, communication patterns, lifecycle, deployment, TF2, parameters, node archetypes, and the Nav2 navigation stack.

## Overview

This library is the **type vocabulary** for modeling ROS2 systems in SysML v2. You import it from your own `.sysml` models to obtain typed handles on messages, topics, services, actions, nodes, lifecycle states, QoS profiles, TF frames, and parameters that map directly to ROS2 Jazzy semantics. Every definition is validated against actual ROS2 source.

This library is **not** a code generator. A companion code-generation pipeline (separate project) reads models written against this vocabulary and generates buildable ROS2 packages. If you want runnable code from your SysML model, you want that pipeline; if you want the type vocabulary alone, you want this kpar.

## Nav2 support

Beyond the core ROS2 interfaces, the library ships out-of-the-box support for Nav2: the goal, feedback, and result types of its actions (NavigateToPose, FollowPath, ComputePathToPose, SmoothPath, Spin, BackUp, Wait) and its Costmap and SpeedLimit messages as `item def`s; its fourteen server nodes (planner, controller, behavior-tree navigator, behavior, smoother, costmap, AMCL, map server, velocity smoother, collision monitor, lifecycle manager, waypoint follower, docking, and route servers) as `part def`s carrying their topic names and action servers; and a `Nav2Stack` composite that wires them together, all checked against the Nav2 Jazzy sources. We will extend coverage to other widely used ROS2 stacks in future releases.

## Roadmap

This library is the first in a series of SysML v2 libraries for robotics that we are building. It covers architecture and implementation: the ROS2 vocabulary a robot's software architecture is written against. Two companions are in preparation, a library for analysis, with the model elements for design space exploration of robot architectures, and a library for verification, with the elements for verifying them. We will publish each on the sysand index under our organization.

## Installation

```bash
# From the public index
sysand add pkg:sysand/seil-isr/ros2-sysmlv2

# From a local archive built with `sysand build`
sysand add file:///path/to/ros2_sysmlv2-<version>.kpar
```

## Quick start

```sysml
package MyRobot {
    private import ros2_sysmlv2_lifecycle::*;
    private import ros2_sysmlv2_comm::*;
    private import ros2_sysmlv2_sensor_msgs::*;
    private import ros2_sysmlv2_archetypes::*;

    part def MyLidarNode :> SensorDriver {
        :>> nodeName = "lidar_driver";
        :>> updateRateHz = 10.0;
        :>> frameId = "lidar_link";

        port :>> sensorPub : TopicPublisher {
            :>> topicName = "/scan";
            :>> qos = sensorDataQoS;
            out item :>> msg : LaserScan;
        }
    }
}
```

## Contents

| Layer | File(s) | Definitions | Description |
|-------|---------|-------------|-------------|
| Foundation | `foundation.sysml`, `std_msgs.sysml` | 10 | Time, Duration, Header, ColorRGBA, etc. |
| Messages | `geometry_msgs.sysml`, `sensor_msgs.sysml`, `nav_msgs.sysml`, `trajectory_msgs.sysml`, `diagnostic_msgs.sysml`, `shape_msgs.sysml`, `action_msgs.sysml`, `visualization_msgs.sysml` | 87 | 85 ROS2 message types as `item def` |
| Communication | `comm.sysml` | 16 | QoS, TopicPublisher/Subscriber, ServiceServer/Client, ActionServer/Client, connections |
| Lifecycle | `lifecycle.sysml` | 15 | Node, LifecycleNode, LifecycleStates (5 states, 9 event-triggered transitions) |
| Deployment | `deployment.sysml` | 6 | Executor, Container, CallbackGroup, NodeDeployment |
| Parameters | `params.sysml` | 5 | ParameterTypeKind (10 values), ParameterDescriptor, ranges |
| TF2 | `tf2.sysml` | 7 | CoordinateFrame, StaticTransform, DynamicTransform, REP 105 frames |
| Archetypes | `archetypes.sysml` | 8 | 8 abstract node patterns (SensorDriver, Controller, Planner, etc.) |
| Nav2 | `nav2.sysml` | 28 | 14 Nav2 server nodes, the Nav2Stack composite, 13 action and message types |

## Mapping conventions

| SysML v2 | ROS2 |
|----------|------|
| `item def` | `.msg` type |
| `port def` with `out item` | Topic publisher |
| `port def` with `in item` | Topic subscriber |
| `port def` with `in` + `out` items | Service or Action |
| `part def` | Node class |
| `part` usage | Node instance |
| `connection` | Topic/service/action binding |
| `state def` with `transition` | Lifecycle state machine |
| `attribute def` | Parameter type |

## Validation

All definitions are validated against actual ROS2 Jazzy source code:

- **Message types**: field-by-field against `.msg` files from `ros2/common_interfaces` and `ros2/rcl_interfaces`
- **Communication**: against `rclpy/qos.py`, `rclpy/node.py`, `rmw/qos_profiles.h`
- **Lifecycle**: against `lifecycle_msgs/msg/State.msg`, `Transition.msg`, `rclpy/lifecycle/node.py`
- **Parameters**: against `rcl_interfaces/msg/ParameterDescriptor.msg`, `ParameterType.msg`
- **Nav2 nodes**: against Nav2 Jazzy server node C++ source (class inheritance, topic names, action servers)

## Requirements

- [Sysand](https://docs.sysand.com/client/) ≥ `0.2.1`
- [Syside Editor](https://docs.sensmetry.com/editor/) ≥ `0.10.1` (free) for authoring with this library
- [Syside Automator](https://docs.sensmetry.com/automator/) ≥ `0.10.1` (paid) for programmatic model access
- Target runtime: **ROS2 Jazzy**: message, service, and action definitions follow the ROS2 Jazzy sources

## Related projects

- A companion pipeline (separate project) uses Syside Automator, [Sensmetry](https://sensmetry.com)'s Python API for programmatic model access, to extract the ROS2 architecture from a SysML v2 model into a JSON intermediate representation and to generate buildable ROS2 packages, launch files, and runtime checks of the running system against the model.
- Release history: see `CHANGELOG.md`.

## Acknowledgements

We thank [Sensmetry](https://sensmetry.com) for a free academic license for Syside Modeler, which we used to author, validate, and visualize this library, and for the Syside Automator API behind our companion pipeline. The library is validated with `syside check` at zero errors and zero warnings.

## License

Apache-2.0

## Maintainers

Sai Sandeep Damera (sdamera@terpmail.umd.edu)
University of Maryland, College Park
