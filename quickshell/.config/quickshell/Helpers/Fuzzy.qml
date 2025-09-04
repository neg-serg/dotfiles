pragma Singleton
import QtQml
import "../vendor/Fuzzysort.js" as Vendored

// Thin QML singleton wrapper around vendored fuzzysort implementation.
QtObject {
    function go(search, targets, options) {
        return Vendored.go(search, targets, options)
    }

    function single(search, target) {
        return Vendored.single(search, target)
    }

    function highlight(result, open, close) {
        return Vendored.highlight(result, open, close)
    }
}

