import Quickshell.Io

Process {
    id: idleRoot
    
    // Uses systemd-inhibit to prevent idle/sleep
    command: ["systemd-inhibit", "--what=idle:sleep", "--who=noctalia", "--why=User requested", "sleep", "infinity"]
    
    // Track background process state
    property bool isRunning: running
    
    onStarted: {}
    
    onExited: function(exitCode, exitStatus) {}


    function start() {
        if (!running) {
            running = true
        }
    }
    
    function stop() {
        if (running) {
            // Force stop the process by setting running to false
            running = false
        }
    }
    
    function toggle() {
        if (running) {
            stop()
        } else {
            start()
        }
    }
}
