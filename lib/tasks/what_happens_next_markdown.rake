class TextHelpers
  include ActionView::Helpers::TextHelper
end

namespace :what_happens_next_markdown do
  desc "Populate what_happens_next_markdown field"
  task populate: :environment do
    Form.find_each do |form|
      formatted_html = TextHelpers.new.simple_format(
        form.what_happens_next_text,
        {},
        sanitize: true,
        sanitize_options: {
          tags: %w[a ol ul li p],
          attributes: %w[href class rel target title],
        },
      )
      markdown = ReverseMarkdown.convert(formatted_html).strip
      form.what_happens_next_markdown = form.what_happens_next_text.blank? ? "" : markdown

      form.made_live_forms.each do |made_live_form|
        form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

        formatted_html = TextHelpers.new.simple_format(
          form_blob[:what_happens_next_text],
          {},
          sanitize: true,
          sanitize_options: {
            tags: %w[a ol ul li p],
            attributes: %w[href class rel target title],
          },
        )
        markdown = ReverseMarkdown.convert(formatted_html).strip
        form_blob[:what_happens_next_markdown] = form_blob[:what_happens_next_text].blank? ? "" : markdown

        made_live_form.update!(json_form_blob: form_blob.to_json)
      end

      form.save!
    rescue StandardError => e
      puts "Error processing form #{form.id} (#{form.name})"
      puts e
    end
  end

  desc "Depopulate what_happens_next_markdown field"
  task depopulate: :environment do
    Form.find_each do |form|
      form.what_happens_next_markdown = nil

      form.made_live_forms.each do |made_live_form|
        form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

        form_blob[:what_happens_next_markdown] = nil

        made_live_form.update!(json_form_blob: form_blob.to_json)
      end

      form.save!
    rescue StandardError => e
      puts "Error processing form #{form.id} (#{form.name})"
      puts e
    end
  end
end
