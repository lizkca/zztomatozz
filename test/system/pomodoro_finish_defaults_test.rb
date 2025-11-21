require "application_system_test_case"

class PomodoroFinishDefaultsTest < ApplicationSystemTestCase
  test "dialog prefilled with defaults after finish" do
    visit "/?locale=zh"
    assert_text "开始"
    page.execute_script <<~JS
      (function(){
        var app = window.Stimulus;
        var ctrl = app.controllers.find(function(c){ return c.identifier === 'pomodoro' })
        ctrl.finish();
      })();
    JS
    assert_selector("dialog", visible: true)
    label_value = page.find("input[data-pomodoro-target='label']")[:value]
    note_value = page.find("textarea[data-pomodoro-target='note']").value
    assert_equal "专注番茄", label_value
    assert_equal "自动记录", note_value
  end
end
