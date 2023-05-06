# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
ActionView::Base.field_error_proc = proc { |html| html.html_safe }
# rubocop:enable Rails/OutputSafety
