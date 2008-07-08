namespace :natto do
  desc "Load initial database fixtures (in db/bootstrap/*.yml) into the current environment's database. Load specific fixtures using FIXTURES=x,y" 
  task :bootstrap => :environment do
    puts "Bootstrapping CMS data..."
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    fixtures_directory = File.join(RAILS_ROOT, 'vendor', 'plugins', 'natto', 'db', 'bootstrap')
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(fixtures_directory, '*.{yml,csv}'))).sort.each do |fixture_file|

      table_names = File.basename(fixture_file, '.*')
      file_names = table_names
      class_names = {}

      table_names = table_names[0..table_names.length]
      table_names = [table_names].flatten.map { |n| n.to_s }

      connection = ActiveRecord::Base.connection
      ActiveRecord::Base.silence do
        fixtures_map = {}
        fixtures = table_names.map do |table_name|
          fixtures_map[table_name] = Fixtures.new(connection, File.split(table_name.to_s).last, class_names[table_name.to_sym], File.join(fixtures_directory, file_names.to_s))
        end
        Fixtures.all_loaded_fixtures.merge! fixtures_map

        connection.transaction(Thread.current['open_transactions'] == 0) do
          fixtures.reverse.each { |fixture| fixture.delete_existing_fixtures }
          fixtures.each { |fixture| fixture.insert_fixtures }

          # Cap primary key sequences to max(pk).
          table_names.each { |table_name| connection.reset_pk_sequence!(table_name) } if connection.respond_to?(:reset_pk_sequence!)
        end
      end
    end
    puts "Done."
  end
end