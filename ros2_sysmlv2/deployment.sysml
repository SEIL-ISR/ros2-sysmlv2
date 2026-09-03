package ros2_sysmlv2_deployment {
    doc
    /* ROS2 deployment constructs: executors, callback groups, and containers.

       Models how ROS2 nodes are deployed into OS processes:
         - Executors schedule callback execution (single/multi-threaded)
         - Callback groups control concurrency (mutually exclusive / reentrant)
         - Containers host composable nodes in a single process
         - NodeDeployment captures runtime configuration (remappings, params)

       Ground truth sources:
         - rclpy/executors.py (SingleThreadedExecutor, MultiThreadedExecutor)
         - rclpy/callback_groups.py (ReentrantCallbackGroup,
           MutuallyExclusiveCallbackGroup)
         - rclpy/node.py Node.__init__ (namespace, parameter_overrides,
           cli_args for remappings)

       Dependency: ros2_sysmlv2_foundation, ros2_sysmlv2_lifecycle. */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;
    private import ros2_sysmlv2_lifecycle::*;

    // ===============================================================
    // Executor kind enumeration
    // Source: rclpy/executors.py
    // ===============================================================

    enum def ExecutorKind {
        doc /* Threading model for callback execution.
               Maps to rclpy SingleThreadedExecutor / MultiThreadedExecutor. */
        enum SingleThreaded;
        enum MultiThreaded;
    }

    // ===============================================================
    // Callback group kind enumeration
    // Source: rclpy/callback_groups.py
    // ===============================================================

    enum def CallbackGroupKind {
        doc /* Concurrency policy for a group of callbacks.
               MutuallyExclusive: only one callback in the group executes
               at a time (default for rclpy nodes).
               Reentrant: callbacks may execute in parallel.
               Maps to rclpy MutuallyExclusiveCallbackGroup /
               ReentrantCallbackGroup. */
        enum MutuallyExclusive;
        enum Reentrant;
    }

    // ===============================================================
    // Callback group definition
    // Source: rclpy/callback_groups.py CallbackGroup
    // ===============================================================

    part def CallbackGroup {
        doc /* A group of callbacks sharing a concurrency policy.
               Subscriptions, timers, services, clients, and waitables
               are assigned to callback groups.
               Maps to rclpy.callback_groups.CallbackGroup.

               Usage in a node:
                 part def MyNode :> LifecycleNode {
                     part sensorGroup : CallbackGroup {
                         :>> kind = CallbackGroupKind::MutuallyExclusive;
                     }
                 } */

        attribute kind : CallbackGroupKind;
    }

    // ===============================================================
    // Executor definition
    // Source: rclpy/executors.py
    // ===============================================================

    part def Executor {
        doc /* Schedules and dispatches callbacks for one or more nodes.
               SingleThreaded: all callbacks run in the spin() thread.
               MultiThreaded: callbacks dispatched to a thread pool.
               Maps to rclpy.executors.Executor.

               Usage:
                 part exec : Executor {
                     :>> kind = ExecutorKind::MultiThreaded;
                     :>> numThreads = 4;
                 } */

        attribute kind : ExecutorKind;
        attribute numThreads : Integer;
    }

    // ===============================================================
    // Container (component container) definition
    // A process hosting one or more composable nodes with a shared executor.
    // Maps to the ROS2 component container pattern.
    // ===============================================================

    part def Container {
        doc /* An OS process hosting composable ROS2 nodes.
               All nodes in a container share a single process and
               can use intra-process communication for zero-copy.
               Maps to ros2 run rclcpp_components component_container.

               Usage:
                 part navContainer : Container {
                     :>> containerName = "nav_container";
                     part exec : Executor {
                         :>> kind = ExecutorKind::MultiThreaded;
                         :>> numThreads = 4;
                     }
                     // nodes allocated here via allocation model
                 } */

        attribute containerName : String;
        part executor : Executor;
    }

    // ===============================================================
    // Node deployment configuration
    // Captures runtime configuration for deploying a node instance.
    // ===============================================================

    attribute def NodeDeployment {
        doc /* Runtime deployment configuration for a node instance.
               Maps to ROS2 launch file parameters:
                 - remappings: topic/service name overrides
                 - parameterFile: path to YAML parameter file
                 - rmwConfig: RMW middleware selection and domain ID

               Usage:
                 part def MySystem {
                     part myNode : MyNode;
                     attribute myNodeDeploy : NodeDeployment {
                         :>> parameterFile = "config/my_params.yaml";
                         :>> rmwConfig {
                             :>> rmwImplementation = RMWKind::Zenoh;
                             :>> domainId = 0;
                         }
                     }
                 } */

        attribute remappings : String;
        attribute parameterFile : String;
        attribute rmwConfig : RMWConfig;
    }
}
