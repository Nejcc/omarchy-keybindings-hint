import QtQuick
import QtTest
import ".."

TestCase {
  id: test
  name: "BindingViewport"
  when: windowShown
  width: 1200
  height: 400
  BindingViewport {
    id: viewport
    width: 800
    Row {
      Rectangle { width: 400; height: 30 }
      Text { text: "A long custom binding description ".repeat(12); font.pixelSize: 9 }
      Rectangle { id: lastBinding; width: 70; height: 30 }
    }
  }
  function test_all_bindings_reachable_data() {
    return [ { tag: "narrow", width: 640 }, { tag: "scaled", width: 1920 / 2 },
      { tag: "wide", width: 1200 } ]
  }
  function test_all_bindings_reachable(data) {
    viewport.width = data.width
    wait(0)
    verify(viewport.contentWidth > viewport.width)
    verify(viewport.interactive)
    viewport.contentX = viewport.contentWidth - viewport.width
    verify(lastBinding.x - viewport.contentX >= 0)
    verify(lastBinding.x + lastBinding.width - viewport.contentX <= viewport.width + 1)
    viewport.contentX = 0
  }
  function test_scrolling_disabled_when_everything_fits() {
    viewport.width = 6000
    wait(0)
    compare(viewport.contentWidth, viewport.width)
    verify(!viewport.interactive)
  }
}
