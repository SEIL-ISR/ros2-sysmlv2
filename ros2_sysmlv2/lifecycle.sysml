package ros2_sysmlv2_lifecycle {
    doc
    /* ROS2 managed lifecycle: Node, LifecycleNode, and LifecycleStates.

       Models the ROS2 managed node lifecycle as a proper finite automaton
       with event-triggered transitions (NOT sequential successions).

       The lifecycle has 4 primary states (Unconfigured, Inactive, Active,
       Finalized) plus an error recovery state (ErrorProcessing). Transitions
       are triggered by external commands (configure, activate, deactivate,
       cleanup, shutdown) and callback results (error recovery).

       Ground truth sources:
         - lifecycle_msgs/msg/State.msg (4 primary states, IDs 1-4)
         - lifecycle_msgs/msg/Transition.msg (9 public transitions, IDs 0-8)
         - lifecycle_msgs/srv/ (ChangeState, GetState, GetAvailableStates,
           GetAvailableTransitions)
         - rclpy/lifecycle/node.py (LifecycleNode, 6 callbacks)
         - rclpy/node.py (Node base: node_name, namespace)

       Reference: http://design.ros2.org/articles/node_lifecycle.html

       Dependency: ros2_sysmlv2_foundation, ros2_sysmlv2_comm. */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;
    private import ros2_sysmlv2_comm::*;

    // ===============================================================
    // Lifecycle transition events (triggers for state changes)
    // Each maps to a public TRANSITION_* constant in Transition.msg.
    // ===============================================================

    item def ConfigureEvent {
        doc /* Trigger: request configure transition.
               Maps to TRANSITION_CONFIGURE (id=1).
               Unconfigured -> [Configuring] -> Inactive. */
    }

    item def CleanupEvent {
        doc /* Trigger: request cleanup transition.
               Maps to TRANSITION_CLEANUP (id=2).
               Inactive -> [CleaningUp] -> Unconfigured. */
    }

    item def ActivateEvent {
        doc /* Trigger: request activate transition.
               Maps to TRANSITION_ACTIVATE (id=3).
               Inactive -> [Activating] -> Active. */
    }

    item def DeactivateEvent {
        doc /* Trigger: request deactivate transition.
               Maps to TRANSITION_DEACTIVATE (id=4).
               Active -> [Deactivating] -> Inactive. */
    }

    item def ShutdownEvent {
        doc /* Trigger: request shutdown transition.
               Maps to TRANSITION_UNCONFIGURED_SHUTDOWN (id=5),
               TRANSITION_INACTIVE_SHUTDOWN (id=6), or
               TRANSITION_ACTIVE_SHUTDOWN (id=7) depending on source state.
               Any primary state -> [ShuttingDown] -> Finalized. */
    }

    item def ErrorEvent {
        doc /* Trigger: transition callback returned ERROR.
               Any transition failure with error code enters ErrorProcessing.
               ErrorProcessing -> Unconfigured (on_error success) or
               ErrorProcessing -> Finalized (on_error failure). */
    }

    // ===============================================================
    // Lifecycle callback action definitions
    // Maps to the 6 overridable callbacks in rclpy LifecycleNode.
    // Each callback receives the current LifecycleState and returns
    // TransitionCallbackReturn (SUCCESS, FAILURE, ERROR).
    // ===============================================================

    action def OnConfigure {
        doc /* Called during Configuring transition state.
               Load configuration, allocate memory, set up connections.
               Maps to rclpy LifecycleNode.on_configure(). */
    }

    action def OnCleanup {
        doc /* Called during CleaningUp transition state.
               Clear all state, release resources.
               Maps to rclpy LifecycleNode.on_cleanup(). */
    }

    action def OnActivate {
        doc /* Called during Activating transition state.
               Final preparations before active processing begins.
               Maps to rclpy LifecycleNode.on_activate(). */
    }

    action def OnDeactivate {
        doc /* Called during Deactivating transition state.
               Reverse on_activate changes, pause processing.
               Maps to rclpy LifecycleNode.on_deactivate(). */
    }

    action def OnShutdown {
        doc /* Called during ShuttingDown transition state.
               Final cleanup before node destruction.
               Maps to rclpy LifecycleNode.on_shutdown(). */
    }

    action def OnError {
        doc /* Called during ErrorProcessing transition state.
               Attempt to recover from a transition error.
               Maps to rclpy LifecycleNode.on_error(). */
    }

    // ===============================================================
    // Lifecycle state machine
    // Models the ROS2 managed node lifecycle as a finite automaton
    // with event-triggered transitions.
    //
    // Primary states (from State.msg, IDs 1-4):
    //   unconfigured (1) - just created, not yet configured
    //   inactive (2)     - configured but not processing
    //   active (3)       - processing data, responding to requests
    //   finalized (4)    - about to be destroyed
    //
    // Error recovery state:
    //   errorProcessing  - callback returned ERROR, attempting recovery
    //
    // Transition states (Configuring, CleaningUp, etc.) are implicit
    // in the transitions. They represent callback execution, modeled
    // as entry actions on the target state side.
    // ===============================================================

    state def LifecycleStates {
        doc /* ROS2 managed node lifecycle state machine.

               4 primary states + error recovery, 9 event-triggered
               transitions. This is a directed graph with cycles
               (Inactive <-> Active, Inactive <-> Unconfigured) and
               multiple paths to Finalized (shutdown from any state).

               The state IDs match lifecycle_msgs/msg/State.msg:
                 unconfigured = 1, inactive = 2,
                 active = 3, finalized = 4.

               Reference: http://design.ros2.org/articles/node_lifecycle.html */

        // ---- Primary states ----

        state unconfigured {
            doc /* Initial state after node creation (id=1).
                   Node exists but is not configured.
                   Available transitions: configure, shutdown. */
        }

        state inactive {
            doc /* Configured but not processing (id=2).
                   All resources allocated, parameters loaded.
                   Available transitions: activate, cleanup, shutdown. */
            entry action onConfigure : OnConfigure;
        }

        state active {
            doc /* Main processing state (id=3).
                   Node reads data, publishes, responds to services.
                   Available transitions: deactivate, shutdown. */
            entry action onActivate : OnActivate;
        }

        state finalized {
            doc /* Terminal state before destruction (id=4).
                   Node is about to be deallocated.
                   No transitions available. */
            entry action onShutdown : OnShutdown;
        }

        state errorProcessing {
            doc /* Error recovery state (id=15).
                   Entered when a transition callback returns ERROR.
                   on_error callback attempts recovery.
                   Transitions: -> unconfigured (success) or
                                -> finalized (failure). */
            entry action onError : OnError;
        }

        // ---- Normal-path transitions (7 public transitions) ----

        transition configure
            first unconfigured
            accept ConfigureEvent
            then inactive;

        transition cleanup
            first inactive
            accept CleanupEvent
            then unconfigured;

        transition activate
            first inactive
            accept ActivateEvent
            then active;

        transition deactivate
            first active
            accept DeactivateEvent
            then inactive;

        transition shutdownFromUnconfigured
            first unconfigured
            accept ShutdownEvent
            then finalized;

        transition shutdownFromInactive
            first inactive
            accept ShutdownEvent
            then finalized;

        transition shutdownFromActive
            first active
            accept ShutdownEvent
            then finalized;

        // ---- Error recovery transitions ----

        transition errorRecoverySuccess
            first errorProcessing
            then unconfigured;

        transition errorRecoveryFailure
            first errorProcessing
            then finalized;
    }

    // ===============================================================
    // Base node definition (unmanaged)
    // Maps to rclpy.node.Node
    // ===============================================================

    part def Node {
        doc /* Base unmanaged ROS2 node.
               Maps to rclpy.node.Node(node_name, namespace=...).
               An unmanaged node has no lifecycle. It is active from
               creation to destruction. Managed nodes use LifecycleNode. */

        attribute nodeName : String;
        attribute namespace : String;
    }

    // ===============================================================
    // Lifecycle (managed) node definition
    // Maps to rclpy.lifecycle.LifecycleNode
    // ===============================================================

    part def LifecycleNode :> Node {
        doc /* ROS2 managed lifecycle node.
               Maps to rclpy.lifecycle.LifecycleNode.
               Inherits nodeName and namespace from Node.
               Exhibits the LifecycleStates state machine.

               Usage:
                 part def MyNode :> LifecycleNode {
                     port pub : TopicPublisher { ... };
                     // callbacks implemented in generated code
                 } */

        exhibit state lifecycleState : LifecycleStates;
    }
}
