# app/workers/bulk_upload_worker.rb
class BulkUploadWorker
    include Sidekiq::Worker
  
    def perform(file_path, user_id, resource_type)
      user = User.find_by(id: user_id)
      return unless user
  
      File.foreach(file_path).with_index do |line, index|
        next if line.strip.empty?
  
        case resource_type
        when 'posts'
          Post.create!(
            title: "Post automático #{index + 1}",
            content: line.strip,
            user_id: user.id
          )
        when 'tags'
          Tag.find_or_create_by!(name: line.strip)
        end
      end
  
      File.delete(file_path) if File.exist?(file_path)
    end
  end
  