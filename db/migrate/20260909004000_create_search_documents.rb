class CreateSearchDocuments < ActiveRecord::Migration[8.0]
  def up
    create_table :search_documents do |t|
      t.string :record_type, null: false
      t.integer :record_id, null: false
      t.string :title, null: false
      t.string :subtitle
      t.text :content
      t.text :url
      t.string :local_path, null: false
      t.string :destination_label, null: false
      t.datetime :occurred_at
      t.timestamps
    end

    add_index :search_documents, [ :record_type, :record_id ], unique: true
    add_index :search_documents, :record_type

    execute <<~SQL
      CREATE VIRTUAL TABLE search_documents_fts USING fts5(
        title,
        subtitle,
        content,
        url,
        content='search_documents',
        content_rowid='id',
        tokenize='porter unicode61'
      );
    SQL

    SearchDocumentIndexer.rebuild!
  end

  def down
    execute "DROP TABLE IF EXISTS search_documents_fts"
    drop_table :search_documents
  end
end
