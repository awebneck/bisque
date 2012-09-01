ActiveRecord::Schema.define(:version => 0) do
  create_table :frobnitzs, :force => true do |t|
    t.column :name, :string
    t.column :description, :text
    t.column :score, :integer
    t.column :cost, :decimal, :precision => 5, :scale => 2
    t.column :numberish, :float
    t.column :created_at, :datetime
    t.column :timish, :timestamp
    t.column :summed_at, :time
    t.column :created_on, :date
    t.column :boolish, :boolean
    t.column :binny, :binary
  end
end
