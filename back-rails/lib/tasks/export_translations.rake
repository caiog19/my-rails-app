namespace :i18n do
    desc "Export translations to public/locales"
    task export: :environment do
      require 'json'
      
      locales = I18n.available_locales
      output_dir = Rails.root.join('public', 'locales')
      FileUtils.mkdir_p(output_dir)
  
      locales.each do |locale|
        translations = I18n.backend.send(:translations)[locale]
        next unless translations
  
        json_content = translations.deep_transform_keys(&:to_s).to_json
  
        File.write(output_dir.join("#{locale}.json"), json_content)
        puts "Exported #{locale}.json"
      end
    end
  end
  