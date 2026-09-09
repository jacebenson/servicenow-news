namespace :search do
  desc "Rebuild the public SQLite search index"
  task rebuild: :environment do
    count = SearchDocumentIndexer.rebuild!
    puts "Indexed #{count} public search documents"
  end
end
