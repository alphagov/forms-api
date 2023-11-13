namespace :forms_admin do
  desc "Unlive a form"
  task :make_unlive, [:form_id] => :environment do |_, args|
    form = Form.find(args[:form_id])

    if form.made_live_forms.empty?
      puts "Form #{form.name} is not live" unless Rails.env.test?
      exit
    end

    form.make_unlive!
    form.reload

    puts "Unlived form #{form.name}" unless Rails.env.test?
  end
end
