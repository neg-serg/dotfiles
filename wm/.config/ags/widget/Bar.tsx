import { App } from "astal/gtk4"
import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk4"
import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Battery from "gi://AstalBattery"
import Wp from "gi://AstalWp"
import Network from "gi://AstalNetwork"
import Tray from "gi://AstalTray"

function SysTray() {
    const tray = Tray.get_default()
    return <box className="SysTray">
        {bind(tray, "items").as(items => items.map(item => (
            <button
                className="tray-item"
                tooltipText={bind(item, "tooltipMarkup")}
                onClicked={() => item.activate()}
                setup={(self) => {
                    const ctrl = new Gtk.GestureClick()
                    ctrl.set_button(3) // Правая кнопка
                    ctrl.connect("pressed", () => item.showMenu())
                    self.add_controller(ctrl)
                }}
            >
                <image gicon={bind(item, "gicon")} pixelSize={16} />
            </button>
        )))}
    </box>
}

function Media() {
    const mpris = Mpris.get_default()
    return <box className="Media">
        {bind(mpris, "players").as(ps => ps[0] ? (
            <box className="media-player">
                <box
                    className="cover-art"
                    css={bind(ps[0], "coverArt").as(cover =>
                        `background-image: url('${cover}');`
                    )}
                />
                <label
                    label={bind(ps[0], "metadata").as(() =>
                        `${ps[0].title} - ${ps[0].artist}`
                    )}
                />
            </box>
        ) : (
            <label label="" />
        ))}
    </box>
}

function Workspaces() {
    const hypr = Hyprland.get_default();
    return <box className="Workspaces">
        {bind(hypr, "focusedWorkspace").as(fw => fw ? (
            <button
                className="focused"
                onClicked={() => fw.focus()}>
                {fw.name}
            </button>
        ) : null)}
    </box>;
}

function Time({ format = "%H:%M" }) {
    const time = Variable<string>("").poll(1000, () =>
        GLib.DateTime.new_now_local().format(format)!)
    return <label
        className="Time"
        onDestroy={() => time.drop()}
        label={time()}
    />
}

function Lhs() {
    return <label className="lhs"> </label>;
}

function Rhs() {
    return <label className="rhs"> </label>;
}

function Delim() {
    return <label className="delim">|</label>;
}

function Delim2() {
    return <label className="delim">{'>'}</label>;
}

export default function Bar(monitor: Gdk.Monitor) {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;  // Используем Astal вместо Gdk
    return <window
        className="Bar"
        // layer="bottom"  // или "top", "bottom", "background"
        monitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={BOTTOM | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}> 
                <Lhs /> <Time /> <Delim /> <Workspaces /> <Delim2 /> 
            </box>
            <box> <SysTray /> </box>
            <box hexpand halign={Gtk.Align.END}>
                <Media /> <Rhs /> 
            </box>
        </centerbox>
    </window>
}
