library package ros2_sysmlv2_lifecycle {
    doc
    /* ROS2 managed lifecycle: Node, LifecycleNode, and LifecycleStates.

       LifecycleStates models the ROS2 default lifecycle state machine with
       its 10 states and 25 transitions. A requested transition accepts a
       request event and leads into a transition state. Each transition
       state runs its callback as its entry action and leaves by a
       transition guarded on the callback's result.

       Ground truth sources:
         - lifecycle_msgs/msg/State.msg (4 primary states, ids 1 to 4,
           and 6 transition states, ids 10 to 15)
         - lifecycle_msgs/msg/Transition.msg (transition ids and the
           3 callback return values)
         - rcl_lifecycle/src/default_state_machine.c (the 25 transitions
           of the default state machine, with source and target states)
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
    // Lifecycle request events (triggers of the requested transitions)
    // Each maps to a public TRANSITION_* constant in Transition.msg.
    // ===============================================================

    item def ConfigureEvent {
        doc /* Request for the configure transition.
               Maps to TRANSITION_CONFIGURE (id=1).
               Leads from unconfigured into configuring. */
    }

    item def CleanupEvent {
        doc /* Request for the cleanup transition.
               Maps to TRANSITION_CLEANUP (id=2).
               Leads from inactive into cleaningUp. */
    }

    item def ActivateEvent {
        doc /* Request for the activate transition.
               Maps to TRANSITION_ACTIVATE (id=3).
               Leads from inactive into activating. */
    }

    item def DeactivateEvent {
        doc /* Request for the deactivate transition.
               Maps to TRANSITION_DEACTIVATE (id=4).
               Leads from active into deactivating. */
    }

    item def ShutdownEvent {
        doc /* Request for a shutdown transition.
               Maps to TRANSITION_UNCONFIGURED_SHUTDOWN (id=5),
               TRANSITION_INACTIVE_SHUTDOWN (id=6), or
               TRANSITION_ACTIVE_SHUTDOWN (id=7), by source state.
               Leads from unconfigured, inactive, or active into
               shuttingDown. */
    }

    // ===============================================================
    // Lifecycle callback results and callback action definitions
    // ===============================================================

    enum def TransitionCallbackReturn {
        doc /* What a lifecycle callback returns. Maps to the callback
               return values of Transition.msg:
               TRANSITION_CALLBACK_SUCCESS (97), TRANSITION_CALLBACK_FAILURE
               (98), and TRANSITION_CALLBACK_ERROR (99), and to rclpy
               TransitionCallbackReturn. The outcome transitions of
               LifecycleStates are guarded on this value. */
        enum Success;
        enum Failure;
        enum Error;
    }

    action def OnConfigure {
        doc /* Entry action of the configuring state.
               Load configuration, allocate memory, set up connections.
               Maps to rclpy LifecycleNode.on_configure(). */
        out attribute result : TransitionCallbackReturn;
    }

    action def OnCleanup {
        doc /* Entry action of the cleaningUp state.
               Clear all state, release resources.
               Maps to rclpy LifecycleNode.on_cleanup(). */
        out attribute result : TransitionCallbackReturn;
    }

    action def OnActivate {
        doc /* Entry action of the activating state.
               Final preparations before active processing begins.
               Maps to rclpy LifecycleNode.on_activate(). */
        out attribute result : TransitionCallbackReturn;
    }

    action def OnDeactivate {
        doc /* Entry action of the deactivating state.
               Reverse the on_activate changes, pause processing.
               Maps to rclpy LifecycleNode.on_deactivate(). */
        out attribute result : TransitionCallbackReturn;
    }

    action def OnShutdown {
        doc /* Entry action of the shuttingDown state.
               Final cleanup before node destruction.
               Maps to rclpy LifecycleNode.on_shutdown(). */
        out attribute result : TransitionCallbackReturn;
    }

    action def OnError {
        doc /* Entry action of the errorProcessing state.
               Attempt to recover from a callback that returned Error.
               Maps to rclpy LifecycleNode.on_error(). */
        out attribute result : TransitionCallbackReturn;
    }

    // ===============================================================
    // Lifecycle state machine
    // ===============================================================

    state def LifecycleStates {
        doc /* The ROS2 default lifecycle state machine.

               10 states, with the ids of lifecycle_msgs State.msg:
               4 primary states (unconfigured 1, inactive 2, active 3,
               finalized 4) and 6 transition states (configuring 10,
               cleaningUp 11, shuttingDown 12, activating 13,
               deactivating 14, errorProcessing 15). The machine starts
               in unconfigured.

               25 transitions, the ones rcl_lifecycle registers in its
               default state machine:
               - 7 requested transitions, each accepting a request event
                 and leading from a primary state into a transition state:
                 configure, cleanup, activate, deactivate, and one
                 shutdown from each of unconfigured, inactive, and active
                 (shutdownFromUnconfigured, shutdownFromInactive,
                 shutdownFromActive).
               - 18 outcome transitions, 3 out of each transition state.
                 Each transition state runs its callback as its entry
                 action, and its 3 exits are guarded on that callback's
                 result: Success, Failure, or Error. Every Error leads to
                 errorProcessing, except an Error in errorProcessing itself,
                 which leads to finalized. They are named after their
                 Transition.msg constants, as onConfigureSuccess for
                 TRANSITION_ON_CONFIGURE_SUCCESS and onErrorError for
                 TRANSITION_ON_ERROR_ERROR.

               Not modeled: PRIMARY_STATE_UNKNOWN (id 0), which marks a
               state not yet set and has no registered transition, and
               TRANSITION_CREATE (0) and TRANSITION_DESTROY (8), which are
               not registered in the default state machine. */

        entry; then unconfigured;

        // ---- Primary states ----

        state unconfigured {
            doc /* Primary state (id=1), the initial state.
                   The node exists but is not configured.
                   Requested transitions: configure, shutdown. */
        }

        state inactive {
            doc /* Primary state (id=2).
                   Configured but not processing.
                   Requested transitions: activate, cleanup, shutdown. */
        }

        state active {
            doc /* Primary state (id=3).
                   The node reads data, publishes, responds to services.
                   Requested transitions: deactivate, shutdown. */
        }

        state finalized {
            doc /* Primary state (id=4).
                   The node is about to be destroyed.
                   No transition leaves it. */
        }

        // ---- Transition states ----

        state configuring {
            doc /* Transition state (id=10). Runs onConfigure on entry.
                   Success leads to inactive (TRANSITION_ON_CONFIGURE_SUCCESS,
                   id=10), Failure to unconfigured (id=11), Error to
                   errorProcessing (id=12). */
            entry action onConfigure : OnConfigure;
        }

        state cleaningUp {
            doc /* Transition state (id=11). Runs onCleanup on entry.
                   Success leads to unconfigured (TRANSITION_ON_CLEANUP_SUCCESS,
                   id=20), Failure to inactive (id=21), Error to
                   errorProcessing (id=22). */
            entry action onCleanup : OnCleanup;
        }

        state shuttingDown {
            doc /* Transition state (id=12). Runs onShutdown on entry.
                   Success leads to finalized (TRANSITION_ON_SHUTDOWN_SUCCESS,
                   id=50), Failure to finalized (id=51), Error to
                   errorProcessing (id=52). */
            entry action onShutdown : OnShutdown;
        }

        state activating {
            doc /* Transition state (id=13). Runs onActivate on entry.
                   Success leads to active (TRANSITION_ON_ACTIVATE_SUCCESS,
                   id=30), Failure to inactive (id=31), Error to
                   errorProcessing (id=32). */
            entry action onActivate : OnActivate;
        }

        state deactivating {
            doc /* Transition state (id=14). Runs onDeactivate on entry.
                   Success leads to inactive (TRANSITION_ON_DEACTIVATE_SUCCESS,
                   id=40), Failure to active (id=41), Error to
                   errorProcessing (id=42). */
            entry action onDeactivate : OnDeactivate;
        }

        state errorProcessing {
            doc /* Transition state (id=15). Runs onError on entry.
                   Success leads to unconfigured (TRANSITION_ON_ERROR_SUCCESS,
                   id=60), Failure to finalized (id=61), Error to finalized
                   (id=62). */
            entry action onError : OnError;
        }

        // ---- Requested transitions (7) ----

        transition configure
            first unconfigured
            accept ConfigureEvent
            then configuring;

        transition cleanup
            first inactive
            accept CleanupEvent
            then cleaningUp;

        transition activate
            first inactive
            accept ActivateEvent
            then activating;

        transition deactivate
            first active
            accept DeactivateEvent
            then deactivating;

        transition shutdownFromUnconfigured
            first unconfigured
            accept ShutdownEvent
            then shuttingDown;

        transition shutdownFromInactive
            first inactive
            accept ShutdownEvent
            then shuttingDown;

        transition shutdownFromActive
            first active
            accept ShutdownEvent
            then shuttingDown;

        // ---- Outcome transitions (18), guarded on the entry callback's result ----

        transition onConfigureSuccess
            first configuring
            if configuring.onConfigure.result == TransitionCallbackReturn::Success
            then inactive;

        transition onConfigureFailure
            first configuring
            if configuring.onConfigure.result == TransitionCallbackReturn::Failure
            then unconfigured;

        transition onConfigureError
            first configuring
            if configuring.onConfigure.result == TransitionCallbackReturn::Error
            then errorProcessing;

        transition onCleanupSuccess
            first cleaningUp
            if cleaningUp.onCleanup.result == TransitionCallbackReturn::Success
            then unconfigured;

        transition onCleanupFailure
            first cleaningUp
            if cleaningUp.onCleanup.result == TransitionCallbackReturn::Failure
            then inactive;

        transition onCleanupError
            first cleaningUp
            if cleaningUp.onCleanup.result == TransitionCallbackReturn::Error
            then errorProcessing;

        transition onActivateSuccess
            first activating
            if activating.onActivate.result == TransitionCallbackReturn::Success
            then active;

        transition onActivateFailure
            first activating
            if activating.onActivate.result == TransitionCallbackReturn::Failure
            then inactive;

        transition onActivateError
            first activating
            if activating.onActivate.result == TransitionCallbackReturn::Error
            then errorProcessing;

        transition onDeactivateSuccess
            first deactivating
            if deactivating.onDeactivate.result == TransitionCallbackReturn::Success
            then inactive;

        transition onDeactivateFailure
            first deactivating
            if deactivating.onDeactivate.result == TransitionCallbackReturn::Failure
            then active;

        transition onDeactivateError
            first deactivating
            if deactivating.onDeactivate.result == TransitionCallbackReturn::Error
            then errorProcessing;

        transition onShutdownSuccess
            first shuttingDown
            if shuttingDown.onShutdown.result == TransitionCallbackReturn::Success
            then finalized;

        transition onShutdownFailure
            first shuttingDown
            if shuttingDown.onShutdown.result == TransitionCallbackReturn::Failure
            then finalized;

        transition onShutdownError
            first shuttingDown
            if shuttingDown.onShutdown.result == TransitionCallbackReturn::Error
            then errorProcessing;

        transition onErrorSuccess
            first errorProcessing
            if errorProcessing.onError.result == TransitionCallbackReturn::Success
            then unconfigured;

        transition onErrorFailure
            first errorProcessing
            if errorProcessing.onError.result == TransitionCallbackReturn::Failure
            then finalized;

        transition onErrorError
            first errorProcessing
            if errorProcessing.onError.result == TransitionCallbackReturn::Error
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
