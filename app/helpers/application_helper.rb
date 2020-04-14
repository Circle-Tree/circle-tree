# frozen_string_literal: true

module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Circle Tree'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  def current_user_group
    Group.my_own_group(current_user)
  end

  def me?(user)
    user == current_user
  end

  def readable_event_date(event)
    start_date = event.start_date
    end_date = event.end_date
    if start_date == end_date
      l start_date, format: :short
    else
      "#{l start_date, format: :short} ~ #{l end_date, format: :short}"
    end
  end
end
