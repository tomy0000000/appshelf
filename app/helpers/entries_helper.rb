# frozen_string_literal: true

module EntriesHelper
  def app_store_link(entry)
    "https://apps.apple.com/#{entry.app.country}/app/id#{entry.app.id}"
  end

  def app_title(entry)
    link_to entry.app.name, app_store_link(entry), target: '_blank', rel: 'noopener'
  end

  def app_store_icon(entry)
    link_to image_tag(entry.app.artwork, alt: "Icon of #{entry.app.name}", class: 'app'), app_store_link(entry),
            target: '_blank', rel: 'noopener'
  end

  def user_remark(entry, inline: false)
    return if entry.remark.blank?

    content_tag(:blockquote, entry.remark, class: (inline ? 'long-text remark-inline' : 'long-text'))
  end
end
