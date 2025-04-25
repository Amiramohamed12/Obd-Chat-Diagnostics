import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.15
import "UI/AppScreen"


Window {
    id: window
    width: 1024
    height: 600
    visible: true
    title: qsTr("OBD App")
    color: "#B8B8B8"


    InputPanel {
        id: inputPanel
        z: 50
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height -80
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    OBDScreen {
        id: obdScreen
         objectName: "obdScreen"  // Required for C++ to find it

    }




}
