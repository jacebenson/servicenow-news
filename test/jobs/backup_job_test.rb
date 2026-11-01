require "test_helper"
require "tmpdir"

class BackupJobTest < ActiveJob::TestCase
  self.fixture_table_names = []

  test "backup works with spaces and shell metacharacters in file paths" do
    Dir.mktmpdir("news backup ; $ ") do |dir|
      source = File.join(dir, "source.sqlite3")
      target = File.join(dir, "backup's \"copy\".sqlite3")
      SQLite3::Database.new(source) do |db|
        db.execute("CREATE TABLE example (value TEXT)")
        db.execute("INSERT INTO example VALUES ('saved')")
      end

      assert BackupJob.new.send(:create_local_backup, source, target)
      SQLite3::Database.new(target) do |db|
        assert_equal "saved", db.get_first_value("SELECT value FROM example")
      end
    end
  end
end
