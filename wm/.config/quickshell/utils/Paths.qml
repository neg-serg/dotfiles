pragma Singleton

import Quickshell
import Quickshell.Io
import Qt.labs.platform

Singleton {
    id: root

    readonly property url home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property url pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

    readonly property url data: `${StandardPaths.standardLocations(StandardPaths.GenericDataLocation)[0]}/caelestia`
    readonly property url state: `${StandardPaths.standardLocations(StandardPaths.GenericStateLocation)[0]}/caelestia`
    readonly property url cache: `${StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]}/caelestia`

    readonly property url imagecache: `${cache}/imagecache`

    function mkdir(path: url): void {
        mkdirProc.path = path.toString().replace("file://", "");
        mkdirProc.startDetached();
    }

    Process {
        id: mkdirProc

        property string path

        command: ["mkdir", "-p", path]
    }
}
