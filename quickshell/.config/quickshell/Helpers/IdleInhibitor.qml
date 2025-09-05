import qs.Components

ProcessRunner {
    id: idleRoot
    // Uses systemd-inhibit to prevent idle/sleep
    cmd: ["systemd-inhibit", "--what=idle:sleep", "--who=noctalia", "--why=User requested", "sleep", "infinity"]
    restartOnExit: false
    autoStart: false
    // Track background process state
    property bool isRunning: running
    function start() { if (!running) idleRoot.running = true }
    function stop()  { if (running) idleRoot.running = false }
    function toggle(){ if (running) stop(); else start(); }
}
