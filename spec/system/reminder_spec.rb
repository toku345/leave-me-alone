require 'rails_helper'

describe 'Reminder', type: :system, js: true do
  let!(:user) { sign_up }

  before do
    todo_list = user.todo_list
    todo_list.tap do |list|
      list.add(content: 'Alpha')
      list.add(content: 'Bravo', done: true)
      list.save!
    end

    sign_in(user)
    visit todo_list_path
    clear_remind_at
  end

  context 'when show list' do
    it do
      visit todo_list_path
      expect_reminder_scheduled
    end
  end

  context 'when todo added' do
    it do
      add_todo('Charlie')
      expect_reminder_scheduled
    end
  end

  context 'when todo removed' do
    it do
      remove_todo(0)
      expect_reminder_scheduled
    end
  end

  context 'when todo edited' do
    it do
      edit_todo(0, 'Alice')
      expect_reminder_scheduled
    end
  end

  context 'when done' do
    it do
      done(0)
      expect_reminder_scheduled
    end
  end

  context 'when revert done' do
    it do
      revert_done(1)
      expect_reminder_scheduled
    end
  end

  private

    def expect_reminder_scheduled
      expect(about_min(30.minutes.from_now)).to include(remind_at)
    end

    def remind_at
      raw_remind_at = find('#test-remind-at')['data-reminder-at']
      Time.zone.parse(raw_remind_at)
    end

    def about_min(base_min)
      (base_min - 1.minutes)..(base_min + 1.minutes)
    end

    def clear_remind_at
      js = <<~JS
        document.getElementById('test-remind-at').dataset.reminderAt = '';
      JS
      execute_script(js)
    end
end
