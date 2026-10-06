import QtQuick
import QtQuick.Controls

// Keep full-width binding columns reachable without shrinking readable text.
Flickable {
  id: viewport
  signal interacted()
  contentWidth: Math.max(width, contentItem.childrenRect.width)
  contentHeight: contentItem.childrenRect.height
  height: contentHeight + (bar.visible ? bar.height : 0)
  clip: true
  flickableDirection: Flickable.HorizontalFlick
  boundsBehavior: Flickable.StopAtBounds
  interactive: contentWidth > width
  onContentXChanged: interacted()
  ScrollBar.horizontal: ScrollBar {
    id: bar
    policy: viewport.contentWidth > viewport.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    focusPolicy: Qt.NoFocus
  }
}
