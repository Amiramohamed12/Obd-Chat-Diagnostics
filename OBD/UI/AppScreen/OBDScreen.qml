import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia
import SocketHandler 1.0

Rectangle {
    id: obdScreen
    visible: true
    anchors.fill: parent
    color: "transparent"

property bool listening : false
property string selectedModel: "LSTM"

onSelectedModelChanged: {
        console.log("QML: selectedModel changed to", selectedModel);
        socketHandler.sendOnly(selectedModel)
    }



SocketHandler {
       id: socketHandler
     onMessageReceived: function(msg) {
                  console.log("Received Message:", msg);
                  chatModel.append({ text: msg, isUser: false });
              }

       onAudioReceived: function(audioText) {
           chatModel.append({ text: audioText, isUser: true });
           socketHandler.sendToSocket(audioText)

       }
   }


Timer {
    id: hideNotificationTimer
    interval: 5000
    running: false
    repeat: false
    onTriggered:  notificationLabel.visible = false;
}

// Search Bar
Rectangle {
    id: searchBar
    radius: 10
    width: 500
    height: 50
    color: "white"
    anchors {
        bottom: obdScreen.bottom
        margins: 30
        horizontalCenter: obdScreen.horizontalCenter
    }
    visible: obdScreen.visible ? true : false

    TextInput{
        id: searchBarText
        font.pixelSize: 15
        clip: true
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: recordIcon.right
            right: parent.right
            leftMargin: 10
        }
        verticalAlignment: Text.AlignVCenter
        Keys.onReturnPressed: {
            console.log("User Message:", searchBarText.text); // Debugging
            chatModel.append({ "text": searchBarText.text, "isUser": true })
            socketHandler.sendToSocket(searchBarText.text); // Send text to Python
            searchBarText.text = "";  // Clear input for new entry
        }
    }
Text{
id: placeHolderSearchBar
anchors.fill: searchBarText
verticalAlignment: Text.AlignVCenter
font.pixelSize: 15
color: "#777D81"
text: (searchBarText.text ==="" ? "Ask anything" : "")

}
    Image {
        id: recordIcon
        source: listening ? "qrc:/UI/Assets/icons/microphone_active.png" : "qrc:/UI/Assets/icons/microphone.png"
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
        fillMode: Image.PreserveAspectFit
        width: 50
        height: 50

        MouseArea {
            id: recordMouseArea
            anchors.fill: parent

            onPressed: {
                           listening = true
                            console.log("Recording started...");
                             socketHandler.sendOnly("Start Recording");

                           }
                           onReleased: {
                               listening = false
                               console.log("Recording stopped...");
                              socketHandler.sendToSocket("Stop Recording");
                           }
                     }
        }
}


Rectangle {
    id: obdCode
    radius: 10
    height: 50
    width: 100
    anchors {
        left: obdScreen.left
        bottom: obdScreen.bottom
        margins: 30
    }
    TextField {
        id: obdCodeText
        font.pixelSize: 15
        clip: true
        verticalAlignment: Text.AlignVCenter
        placeholderText: (obdCodeText.text === "") ? "OBD Code" : ""
        anchors.fill: obdCode
        Keys.onReturnPressed: {
            var description = obdHandler.getErrorDescription(obdCodeText.text);
            notificationLabel.text = description + "!";  // Display the description
            notificationLabel.visible = true
            hideNotificationTimer.start()
            obdCodeText.text = ""
        }
    }
}

Text {
    id: notificationLabel
    text: ""
    font.pixelSize: 15
    color: "red"
    anchors {
        top: obdScreen.top
        topMargin: 10
        horizontalCenter: obdScreen.horizontalCenter
    }
    visible: false
}



    ListModel {
        id: chatModel
    }

    Flickable {
        id: chatScroll
        anchors {
            top: obdScreen.top
            left: verticalLineUser.left
            leftMargin: 5
            right: verticalLineModel.right
            rightMargin: 5
            bottom: searchBar.top
            margins: 30
        }
        clip: true
        contentHeight: chatColumn.height

        Column {
            id: chatColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: chatModel

                delegate: Component {
                    Rectangle {
                        width: Math.max(200, Math.min(textItem.implicitWidth + 20, 400))
                        height: Math.max(50, textItem.implicitHeight + 20)
                        radius: 10
                        color: model.isUser ? "white" : "lightblue"

                        anchors {
                            left: model.isUser ? parent.left : undefined
                            right: model.isUser ? undefined : parent.right
                        }

                        Text {
                            id: textItem
                            text: model.text
                            color: "black"
                            font.pixelSize: 15
                            wrapMode: Text.Wrap
                            anchors.fill: parent
                            anchors.margins: 10
                        }
                    }
                }
            }
        }
    }

    Image {
        id: newChat
        source: "qrc:/UI/Assets/icons/new-message.png"
        fillMode: Image .PreserveAspectFit
        anchors{
            top: obdScreen.top
            right: obdScreen.right
            margins: 30
            }
            width: 50
            height: 50
        MouseArea{
            id: newChatMouseArea
            anchors.fill: parent
            onClicked: chatModel.clear()
           }
     }

    Rectangle{
    id: verticalLineUser
    anchors{
    left: searchBar.left
    }
    width: 5
    height: obdScreen.height
    visible: false
    }

    Rectangle{
    id: verticalLineModel
    anchors{
    right: searchBar.right
    }
    width: 5
    height: obdScreen.height
    visible: false
    }


    Rectangle {
    id: selectModel
    radius: 10
    anchors{
    left: obdScreen.left
    top: obdScreen.top
    margins: 30
    }
    width: 200
    height: 50
    color: "white"

    Image{
    id: listModel
    source: "qrc:/UI/Assets/icons/down-arrow.png"
    fillMode: Image.PreserveAspectFit
    width: 20
    height: 20
    anchors{
    right: parent.right
    rightMargin: 20
    verticalCenter: parent.verticalCenter
         }
    MouseArea{
    id: listModelMouseArea
    anchors.fill: parent
    onClicked: {
      if(lstmButton.visible) {
          llmButton.visible = false
          lstmButton.visible = false
      }
      else {
      llmButton.visible = true
      lstmButton.visible = true }

            }

        }
     }

    Text {
      id: modelText
      text: lstmButton.visible ? "Select model" : selectedModel
      color: "black"
      font.bold: (text==="Select model") ? false : true
      font.pixelSize: lstmButton.visible ? 17 : 20
      anchors{
      left: parent.left
      leftMargin: 10
      verticalCenter: parent.verticalCenter

          }

        }
    }
    Button{
    id: llmButton
    visible: false
    anchors{
      top: lstmButton.bottom
      left: obdScreen.left
      leftMargin: 30
    }
    width: 150
    height: 50
    text: "LLM"
    font.pixelSize: 20
    font.bold: true
    onClicked: {
      selectedModel = "LLM"
      llmButton.visible = false
      lstmButton.visible = false
       console.log("the selected model is ",selectedModel)
      }
    }

    Button{
    id: lstmButton
    visible: false
    anchors{
      top: selectModel.bottom
      left: obdScreen.left
      leftMargin: 30

    }
    width: 150
    height: 50
    text: "LSTM"
    font.pixelSize: 20
    font.bold: true
    onClicked: {
      selectedModel = "LSTM"
      llmButton.visible = false
      lstmButton.visible = false
      console.log("the selected model is ",selectedModel)
            }
        }
    }
